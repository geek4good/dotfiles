#!/usr/bin/env python3
"""Surface connection-error causes in Pi's error messages.

Pi collapses network-level failures to the generic "Connection error." because
its bundled OpenAI SDK wraps them as APIConnectionError(message="Connection
error.", cause=<real error>) and Pi's error handler only reads `.message`,
dropping `.cause` (which holds the real ECONNRESET / ETIMEDOUT / fetch-failed
detail).

This rewires the error-message construction to append the cause chain, so the
session log and UI show e.g.:

    Connection error. [fetch failed -> ECONNRESET: socket hang up]

It is idempotent and safe to run repeatedly. Re-applied by post-update.sh after
each `pi` update (the bundle chunks are hashed and get replaced on update).

Usage:
    patch-pi-error-cause.py            # apply if needed
    patch-pi-error-cause.py --check    # report status only, don't modify
"""

import os
import shutil
import sys

# The exact minified snippet Pi uses to build an error message (4 chat/image
# sites in the main chunk, plus one each in a couple of adjacent chunks).
OLD = "errorMessage:error instanceof Error?error.message:String(error)"
NEW = "errorMessage:__piErrMsg(error)"
MARKER = "__piErrMsg"
HELPER = (
    'function __piErrMsg(e){'
    'if(!(e instanceof Error))return String(e);'
    'var m=e.message,s=[],c=e.cause,d=0;'
    'while(c&&d<5){s.push((c.code?c.code+": ":"")+(c.message||String(c)));c=c.cause;d++}'
    'return s.length?m+" ["+s.join(" -> ")+"]":m}'
)


def find_chunks_dir():
    pi = shutil.which("pi")
    if not pi:
        # Fall back to the common mise/npm install layout.
        pi = os.path.expanduser(
            "~/.local/share/mise/installs/node/26/bin/pi"
        )
    cli = os.path.realpath(pi)  # resolves the bin symlink to dist/bundle/cli.js
    return os.path.join(os.path.dirname(cli), "chunks")


def main():
    check_only = "--check" in sys.argv[1:]

    chunks = find_chunks_dir()
    if not os.path.isdir(chunks):
        print(f"error: pi chunks dir not found at {chunks}", file=sys.stderr)
        return 2

    patched = []
    already = []
    targets = []
    for name in sorted(os.listdir(chunks)):
        if not name.endswith(".js"):
            continue
        path = os.path.join(chunks, name)
        with open(path, encoding="utf-8") as f:
            content = f.read()
        if OLD in content:
            targets.append((path, name, content))
        elif MARKER in content:
            already.append(name)

    for name in already:
        print(f"  already patched: {name}")

    if not targets and not already:
        print("pi error-cause patch: no matching bundle found (pi may have changed layout)")
        return 1

    if check_only:
        if targets:
            print("would patch:")
            for _, name, _ in targets:
                print(f"  {name}")
        return 0

    for path, name, content in targets:
        if MARKER not in content:
            content += "\n" + HELPER + "\n"
        new = content.replace(OLD, NEW)
        with open(path, "w", encoding="utf-8") as f:
            f.write(new)
        patched.append(name)
        print(f"  patched: {name}")

    if patched:
        print(f"pi error-cause patch applied ({len(patched)} file(s)). Restart pi to take effect.")
    else:
        print("pi error-cause patch already applied.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
