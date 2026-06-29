---
name: dl
description: Download music from Apple Music, SoundCloud, YouTube Music, or Spotify into the Kratos DJ library inbox. Use when the user says "/dl", "download this", shares any music URL (Apple Music, SoundCloud, YouTube Music, Spotify), or asks to add/get/save a track or playlist. Trigger whenever the user pastes a music.apple.com, soundcloud.com, on.soundcloud.com, music.youtube.com, or open.spotify.com URL and wants it downloaded. Also trigger for requests like "get the explicit version", "download this album", or "add these tracks".
---

# /dl — Download Music to Library

Download from Apple Music, SoundCloud, YouTube Music, or Spotify into the Kratos library inbox (`~/Music/Kratos/.inbox/`), flattened to `Artist - Title.ext`, logged to `downloads.csv`.

## Routing

Detect the source from the URL:

| URL pattern | Source | Tool | Cookies |
|-------------|--------|------|---------|
| `music.apple.com/.../song/` | Apple Music (single) | gamdl | `~/Music/Kratos/.arc_cookies.txt` |
| `music.apple.com/.../album/` | Apple Music (album) | gamdl | same |
| `music.apple.com/.../playlist/` | Apple Music (playlist) | gamdl | same |
| `soundcloud.com/...` or `on.soundcloud.com/...` | SoundCloud | yt-dlp | none |
| `music.youtube.com/...` | YouTube Music | yt-dlp | `~/Music/Kratos/.arc_yt_cookies.txt` |
| `open.spotify.com/...` | Spotify | zotify | Spotify auth |

## Source priority

**Apple Music is the preferred source.** It serves 256kbps AAC in M4A containers — the native format for djay Pro, fully taggable, no transcoding needed.

Fallback order when a track is not on Apple Music:
1. **Apple Music** (primary — native AAC, best djay Pro compatibility)
2. **SoundCloud** (native AAC/MP3, no transcoding)
3. **Spotify** (320kbps Ogg Vorbis — transcode to AAC, see below)
4. **YouTube Music** (256kbps AAC via Premium — last resort, unreliable search)

### Spotify downloads and transcoding

Spotify serves **Ogg Vorbis** files (320kbps for Premium). OGG is not reliably supported in djay Pro (playback errors, database issues with large collections). Always **transcode to AAC** after downloading:

```bash
# Download with zotify
zotify download --output-format ogg "{SPOTIFY_URL}"

# Transcode OGG → AAC (256kbps, M4A container)
ffmpeg -i "input.ogg" -c:a aac -b:a 256k -map_metadata 0 "output.m4a"
```

The transcode loss (Ogg → AAC) is negligible for DJ use (~5-10% perceptual, inaudible through speakers at these bitrates). Do NOT convert to FLAC — it would preserve the already-degraded OGG quality at 3x the file size with no benefit.

## Naming convention

All files: `Artist - Title.ext` — flat, no subfolders, in `.inbox/`.

**Artist rules:**
- Canonical spellings: `AC/DC` not `AC-DC`, `N.W.A` not `NWA`, `Phonte` not `PHONTE`
- Multiple artists: comma-separated, primary first. No "feat./ft./featuring" in artist field
- No "Unknown Artist" prefix

**Title rules:**
- Strip "(feat. ...)" and production credits from titles
- Strip promotional text: "FREE DOWNLOAD", "OUT NOW", "[PREMIERE]"
- Keep remix/flip credits: `(Paul Mond Flip)`, `(Jeftuz UKG Remix)`
- Strip YouTube `[xxxxxxxxxxx]` and numeric IDs
- Underscores → apostrophes in contractions (`Can_t` → `Can't`) but NOT inside brackets

**IMPORTANT:** Always verify the actual artist and title from the downloaded file's embedded metadata via `ffprobe` — do NOT guess from the URL or album name. This catches mislabeled albums, compilations, and edge cases.

## Apple Music downloads

### Single track
```bash
gamdl -c ~/Music/Kratos/.arc_cookies.txt -n \
  -o "{TEMP_DIR}" \
  "{SONG_URL}"
```

Download to a temp directory, then flatten (see below). gamdl creates nested `Artist/Album/NN Title.m4a`.

### Playlist or album
```bash
gamdl -c ~/Music/Kratos/.arc_cookies.txt -n \
  -o ~/Music/Kratos/.inbox \
  "{PLAYLIST_OR_ALBUM_URL}"
```

gamdl handles its own pacing — no additional delays needed between tracks.

### Storefront: always search TH first

The Apple Music account is registered in **Thailand (TH)**. gamdl always downloads from the TH storefront regardless of the URL. This has important consequences:

- **TH track IDs are different from US track IDs.** A track found via the US iTunes API may 404 when gamdl tries to download it.
- **The iTunes search API hides explicit albums** in both storefronts — you can't find explicit versions by searching for tracks.
- **The TH storefront sometimes has tracks the US doesn't**, and vice versa.

**Always search TH first.** Only fall back to US if TH yields nothing.

### Explicit version preference

**Always prefer explicit (dirty) versions when available.** Apple Music has separate clean and explicit albums that look identical in search — the iTunes search API only returns clean versions. To find explicit versions, you must use the **artist lookup API** (not track search):

1. Find the artist ID on the **TH** storefront:
   ```
   https://itunes.apple.com/search?term={artist}&entity=musicArtist&limit=3&country=TH
   ```
2. Look up ALL albums for the artist on **TH**:
   ```
   https://itunes.apple.com/lookup?id={artistId}&entity=album&limit=200&country=TH
   ```
3. Filter to albums with `collectionExplicitness == "explicit"`
4. Find the matching track by title on the explicit album — use the **TH** track ID for download
5. If no explicit album on TH, repeat steps 1–4 on **US** (`country=US`)
6. If a TH track ID is found, download with `https://music.apple.com/th/song/{trackId}`
7. If only a US track ID is found, it will likely 404 on gamdl (TH account) — note this to the user

**If the artist-lookup approach fails, also try a broader search.** Explicit tracks can appear on compilation albums that aren't in the artist's own catalog (e.g., DMX - Party Up explicit was found on a "2000s Retro Gamer" compilation). Search by track title:
```
https://itunes.apple.com/search?term={artist}+{title}&entity=song&limit=50&country=TH
```
Filter results to `trackExplicitness == "explicit"` and verify the artist name matches.

If no explicit version exists in either storefront, download the clean version and note it to the user.

### Intake precedence: explicit over clean

When processing `.inbox/` files into `.library/`, the intake dedup uses fingerprinting to catch duplicates. But **explicit versions take precedence over clean versions** — a new file that's a fingerprint match for an existing library file should still **replace** it if:

1. The new file is explicit (`rating` tag = 1) and the existing is clean (`rating` = 2)
2. The new file has a higher bitrate than the existing
3. The new file is rated and the existing is unrated

Apple Music embeds a `rating` tag in downloaded m4a files:
- `rating: 1` = explicit
- `rating: 2` = clean (censored)
- `rating: 0` = not explicit (no profanity)
- no tag = unknown

Always check this tag when deciding whether to replace or discard a duplicate.

### Quality

gamdl downloads at 256kbps AAC by default — do not override codec settings.

## SoundCloud downloads

```bash
yt-dlp -f bestaudio --embed-metadata --no-warnings --no-playlist \
  -o "{INBOX}/{Artist} - {Title}.%(ext)s" \
  "{URL}"
```

- `-f bestaudio` — highest quality available (usually ~160kbps AAC)
- Do NOT transcode — keep native format (m4a/aac is higher quality than transcoding to mp3)
- Exception: WAV sources → convert to FLAC for taggable format

Resolve artist/title from the SoundCloud page (fetch content, read page heading and description for collaborators).

## YouTube Music downloads

```bash
yt-dlp --cookies ~/Music/Kratos/.arc_yt_cookies.txt \
  --remote-components ejs:github \
  -f 141/140 \
  --embed-metadata \
  --sleep-requests 2 \
  -o "{INBOX}/{Artist} - {Title}.%(ext)s" \
  "{URL}"
```

- Format `141` = 256kbps AAC (Premium), fallback `140` = 130kbps AAC
- `--remote-components ejs:github` required for YouTube signature challenges
- Cookies extracted from Arc browser Chromium cookie DB (see Cookie Extraction section)

**Warning:** yt-dlp's YouTube Music search often returns user-uploaded videos (karaoke, live, lyric videos) instead of official catalog tracks. Always verify the download with fingerprinting against the expected track. If downloading by search, prefer Apple Music first.

## Flatten

After any download, flatten nested directories to `Artist - Title.ext` in `.inbox/`:

```python
import os, shutil, re

INBOX = os.path.expanduser('~/Music/Kratos/.inbox')

def flatten_dir(directory):
    """Move all audio files from nested dirs to directory root as Artist - Title.ext."""
    for root, dirs, files in os.walk(directory, topdown=False):
        for f in sorted(files):
            ext = os.path.splitext(f)[1].lower()
            if ext not in {'.m4a', '.mp3', '.flac', '.wav'}:
                continue
            full = os.path.join(root, f)
            rel = os.path.relpath(full, directory)
            parts = rel.split(os.sep)

            if len(parts) > 1:
                artist = parts[0]
                stem = os.path.splitext(f)[0]
                stem = re.sub(r'^\d{1,2}-\d{1,2}\s+', '', stem)
                stem = re.sub(r'^\d{1,2}\s+', '', stem)
                new_name = f"{artist} - {stem}{ext}".replace('/', '_')
            else:
                new_name = f

            dst = os.path.join(directory, new_name)
            if os.path.exists(dst) and full != dst:
                base, e = os.path.splitext(new_name)
                i = 2
                while os.path.exists(os.path.join(directory, f"{base} ({i}){e}")):
                    i += 1
                dst = os.path.join(directory, f"{base} ({i}){e}")
            if full != dst:
                shutil.move(full, dst)

    # Clean empty dirs and non-audio files
    for root, dirs, files in os.walk(directory, topdown=False):
        for f in files:
            fpath = os.path.join(root, f)
            ext = os.path.splitext(f)[1].lower()
            if ext not in {'.m4a', '.mp3', '.flac', '.wav'} and root != directory:
                os.unlink(fpath)
        for d in dirs:
            path = os.path.join(root, d)
            try:
                os.rmdir(path)
            except OSError:
                pass
```

After flattening, verify the filename using embedded metadata:
```bash
ffprobe -v error -show_entries format_tags=artist,title -of csv=p=0 "{FILE}"
```
If the metadata artist/title doesn't match the filename, fix the filename.

## Log every download

Append to `~/Music/Kratos/downloads.csv` (columns: `artist,title,source`):

```python
import csv, os

CSV = os.path.expanduser('~/Music/Kratos/downloads.csv')
INBOX = os.path.expanduser('~/Music/Kratos/.inbox')

def log_download(artist, title, source_url):
    with open(CSV, 'a', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow([artist, title, source_url])
```

The `source` should be the original URL the user provided.

## Report

Tell the user:
- What was downloaded and the final filename(s)
- Note any failures or version issues (clean vs explicit)
- If a track was replaced/upgraded, mention the old and new bitrate

## Paths

- **Inbox**: `~/Music/Kratos/.inbox/`
- **Download log**: `~/Music/Kratos/downloads.csv`
- **Apple Music cookies**: `~/Music/Kratos/.arc_cookies.txt`
- **Spotify**: requires zotify and Premium account auth

## Cookie extraction (when cookies expire)

Both cookie files come from the Arc browser's Chromium cookie database. When gamdl or yt-dlp starts failing with auth errors:

### Apple Music cookies
1. Copy Arc's Cookies DB: `~/Library/Application Support/Arc/User Data/Default/Cookies`
2. Get the keychain password: `security find-generic-password -w -s "Arc Safe Storage"`
3. Derive AES key: `PBKDF2(password, salt='saltysalt', dkLen=16, count=1003)`
4. Decrypt each cookie value (strip `v10` prefix, AES-128-CBC with IV=16 spaces, strip PKCS7 padding)
5. Write Netscape format to `~/Music/Kratos/.arc_cookies.txt`
6. Filter to `apple.com` domain cookies only

### YouTube Music cookies
Same process but:
4b. After decryption, strip the 32-byte SHA256(domain) prefix from each value
5b. Filter to `youtube.com` and `google.com` domain cookies
6b. Write to `~/Music/Kratos/.arc_yt_cookies.txt`
7b. Verify auth cookies present: `SAPISID`, `__Secure-1PSID`, `SID`, `SSID`, `APISID`, `HSID`, `LOGIN_INFO`

### Using yt-dlp for Arc cookies (alternative for YouTube Music)
yt-dlp can read Arc's cookie DB directly via the Chromium format:
```bash
yt-dlp --cookies-from-browser "chrome::/Users/.../Arc/User Data/Default" URL
```
Note: yt-dlp's `--cookies-from-browser` may ignore the custom path and use the default Chrome profile. A manually extracted Netscape file is more reliable.

## Edge cases

- **DRM-protected tracks**: gamdl/yt-dlp will error. Report to user, skip and continue.
- **TH storefront 404s**: Track IDs from the US iTunes API will 404 on gamdl because the account is TH. Always resolve TH-specific track IDs before downloading. If a track is only on US, it cannot be downloaded — tell the user.
- **Duplicate downloads**: Overwrite is fine — likely a re-download at higher quality. Fingerprinting during intake catches true duplicates.
- **Compilation albums**: gamdl uses album artist (e.g., "Compilations"). Verify actual artist from metadata and fix filename.
- **Clean-only tracks**: Some tracks only have clean versions on Apple Music (e.g., Big L - MVP). Download the clean version and note it to the user.
- **Wrong track from AM search**: Always verify artist/title from embedded metadata after download, not from the URL or search result.
- **Non-English titles**: Keep original characters. Don't transliterate.
- **WAV sources**: Convert to FLAC for taggable format. Only convert genuine lossless WAV → FLAC. Never transcode lossy → lossy.
- **Spotify OGG → AAC**: Always transcode Spotify downloads to AAC/M4A for djay Pro compatibility. See Source priority section.
- **Playlist modifications**: Cannot remove tracks from Apple Music playlists programmatically (no write API). User must do it manually.
