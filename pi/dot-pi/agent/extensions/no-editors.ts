/**
 * No-Editors Extension
 *
 * Blocks interactive editors, pagers, and commands that would launch one
 * (git commit without -m, git rebase -i, crontab -e, ...). These hang or
 * corrupt the non-interactive shell Pi uses for the bash tool.
 *
 * Blocked calls return an actionable reason so the model self-corrects and
 * uses non-interactive alternatives instead of retrying.
 *
 * Complements `shellCommandPrefix` in settings.json, which sets
 * EDITOR/VISUAL/GIT_EDITOR=true and PAGER=cat as a safety net for
 * editor-launching commands that slip past this blocklist (e.g. inside
 * `bash -c "..."` wrappers, which are not tokenized here).
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const EDITORS = new Set([
	"vim", "nvim", "vi", "view", "vile", "emacs", "nano", "pico", "micro",
	"joe", "jove", "ed", "helix", "hx", "kak", "kakoune", "ne", "amp",
]);
const PAGERS = new Set(["less", "more", "most", "pg"]);
const WRAPPERS = new Set(["sudo", "nohup", "command", "exec", "nice", "stdbuf"]);
const ALWAYS_EDITOR = new Set(["visudo", "sudoedit", "vipw", "vigr"]);

const REASON =
	"Blocked: interactive editors/pagers cannot run in this non-interactive shell. " +
	"Use a non-interactive alternative: `git commit -m '<msg>'` or `--amend --no-edit`, " +
	"`cat`/`head`/`tail` instead of less, and the edit/write tools instead of vim/nano.";

/** Split a command line into token lists, one per pipeline/sequence segment. */
function segments(command: string): string[][] {
	return command
		.split(/\n|&&|\|\||[|;&()<>]/)
		.map((s) => s.trim().split(/\s+/).filter(Boolean))
		.filter((tokens) => tokens.length > 0);
}

/** Drop leading wrapper tokens (sudo, env VAR=x, timeout 30, ...) and return the rest. */
function stripWrappers(tokens: string[]): string[] {
	const t = [...tokens];
	while (t.length > 0) {
		const head = t[0];
		if (head === "env") {
			t.shift();
			while (t.length > 0 && /^\w+=/.test(t[0])) t.shift();
			continue;
		}
		if (head === "timeout") {
			t.shift();
			if (t.length > 0 && /^\d+[smhd]?$/i.test(t[0])) t.shift();
			continue;
		}
		if (WRAPPERS.has(head)) {
			t.shift();
			continue;
		}
		break;
	}
	return t;
}

/** Returns a block reason if a git subcommand is interactive, else undefined. */
function gitReason(tokens: string[]): string | undefined {
	const sub = tokens[1];
	const rest = tokens.slice(2);
	const has = (...flags: string[]) => flags.some((f) => rest.some((t) => t === f || t.startsWith(f + "=") || t.startsWith(f)));
	switch (sub) {
		case "commit":
			if (!has("-m", "--message", "-F", "--file", "-C", "--reuse-message", "--fixup", "--no-edit", "-t", "--template")) {
				return REASON;
			}
			return undefined;
		case "rebase":
			if (has("-i", "--interactive")) return REASON;
			return undefined;
		case "add":
		case "checkout":
		case "restore":
		case "reset":
		case "stash":
		case "switch":
			if (has("-i", "--interactive", "-p", "--patch")) return REASON;
			return undefined;
		case "tag":
			if (has("-a", "--annotate") && !has("-m", "--message", "-F", "--file")) return REASON;
			return undefined;
		default:
			return undefined;
	}
}

/** Returns a human-readable reason when the command tries to open an editor/pager. */
export function findEditorInvocation(command: string): string | undefined {
	for (const raw of segments(command)) {
		const tokens = stripWrappers(raw);
		if (tokens.length === 0) continue;
		const head = tokens[0].split("/").pop() ?? tokens[0];
		if (EDITORS.has(head) || PAGERS.has(head) || ALWAYS_EDITOR.has(head)) return REASON;
		if (head === "git") {
			const reason = gitReason(tokens);
			if (reason) return reason;
		}
		if (head === "crontab" && tokens.some((t) => t === "-e" || t === "--edit")) return REASON;
	}
	return undefined;
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = event.input.command as string;
		const reason = findEditorInvocation(command);
		if (reason) {
			if (ctx.hasUI) {
				ctx.ui.notify(`Blocked interactive editor/pager: ${command.split(/\s+/)[0]}`, "warning");
			}
			return { block: true, reason };
		}
		return undefined;
	});
}
