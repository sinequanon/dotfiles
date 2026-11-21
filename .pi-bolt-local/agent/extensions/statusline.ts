/**
 * My Statusline Extension
 *
 * A themed footer statusline for pi showing:
 *   📁 ~/proj  🌿 branch  🤖 model  🎨 theme  ⚡ thinking-level  [████████░░░░] 67%  💰 $0.042    🔄 5
 *
 * - Thinking/effort level displayed with a per-level emoji + name
 * - All content packed left; turn counter pinned to the far right
 * - Context percentage rendered as an ASCII bar
 *
 * Place: ai/pi/dot-pi/agent/extensions/my-statusline.ts  (→ ~/.pi/agent/extensions/)
 */

import { execFile, execFileSync } from "node:child_process";
import { basename, relative, sep as pathSep } from "node:path";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ThemeColor } from "@earendil-works/pi-coding-agent";
import { hyperlink, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

// ─── Config ───────────────────────────────────────────────────────────────────

const BAR_WIDTH = 12; // ASCII bar character count (excluding brackets)

/**
 * Theme-independent bold red π brand mark.
 *   \x1b[1m              → bold on
 *   \x1b[38;2;255;59;48m → 24-bit truecolor red (#ff3b30, the iOS system red — vivid on light & dark terminals)
 *   \x1b[39m             → reset fg to terminal default
 *   \x1b[22m             → bold off
 * Self-contained so it never inherits color from surrounding theme.bold() / theme.fg() wrappers.
 */
const PI_BRAND = "\x1b[1m\x1b[38;2;255;59;48mπ\x1b[39m\x1b[22m";

// ─── Helpers ─────────────────────────────────────────────────────────────────

/** Build an ASCII progress bar: [████████░░░░] */
function asciiBar(percent: number): string {
	const filled = Math.round((Math.min(100, Math.max(0, percent)) / 100) * BAR_WIDTH);
	const empty = BAR_WIDTH - filled;
	return "[" + "█".repeat(filled) + "░".repeat(empty) + "]";
}

/** Replace leading home dir with ~ (same idea as Pi built-in footer). */
function homeAbbrev(absPath: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	if (home && absPath.startsWith(home)) {
		return `~${absPath.slice(home.length)}`;
	}
	return absPath;
}

/**
 * Cache the git toplevel for each cwd we see so we don't shell out on every render.
 * Maps absolute cwd → absolute repo root (or null if cwd is not in a git repo).
 */
const repoRootCache = new Map<string, string | null>();

function getGitRepoRoot(cwd: string): string | null {
	if (repoRootCache.has(cwd)) return repoRootCache.get(cwd) ?? null;
	try {
		const out = execFileSync("git", ["-C", cwd, "rev-parse", "--show-toplevel"], {
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
		}).trim();
		const root = out || null;
		repoRootCache.set(cwd, root);
		return root;
	} catch {
		repoRootCache.set(cwd, null);
		return null;
	}
}

/**
 * Extract the host from a git remote URL.
 *   git@github.com:Netflix/spectator.git      → github.com
 *   https://github.com/Netflix/spectator.git  → github.com
 *   git@git.netflix.net:corp/pi-agent.git     → git.netflix.net
 */
export function remoteHost(url: string): string | null {
	const scp = url.match(/^[^/@]+@([^:]+):/); // scp-like ssh: user@host:path
	if (scp) return scp[1];
	const m = url.match(/^[a-z]+:\/\/(?:[^@/]+@)?([^/:]+)/i); // scheme://[user@]host[:port]/path
	return m ? m[1] : null;
}

/**
 * Cache the GH_HOST override per repo root. Netflix's `gh` wrapper defaults to the
 * internal GHE host (git.netflix.net), so `gh pr status` finds nothing for a
 * public github.com repo unless GH_HOST=github.com is set. We only override when a
 * github.com remote is detected; GHE repos keep `gh`'s default host.
 */
const ghHostCache = new Map<string, string | null>();

export function getGhHost(root: string): string | null {
	if (ghHostCache.has(root)) return ghHostCache.get(root) ?? null;
	let host: string | null = null;
	try {
		const out = execFileSync("git", ["-C", root, "config", "--get-regexp", "^remote\\..*\\.url$"], {
			encoding: "utf8",
			stdio: ["ignore", "pipe", "ignore"],
		});
		for (const line of out.split("\n")) {
			const url = line.split(/\s+/)[1];
			if (url && remoteHost(url) === "github.com") {
				host = "github.com";
				break;
			}
		}
	} catch {
		// git unavailable or not a repo: no override, fall back to gh's default host.
	}
	ghHostCache.set(root, host);
	return host;
}

interface PrInfo {
	number: number;
	url: string;
}

/** How long a resolved PR lookup stays fresh before we re-query `gh` (ms). */
const PR_TTL_MS = 60_000;

/**
 * Cache the open PR (number + url) per `${repoRoot}\n${branch}` so we don't shell
 * out to `gh` on every render. Lookups are async; in-flight keys are tracked to
 * avoid duplicate `gh` processes, and stale entries are served while refreshing.
 * Entries expire after PR_TTL_MS so a PR opened mid-session is eventually picked
 * up and a transient `gh` failure doesn't hide the link permanently.
 */
const prInfoCache = new Map<string, { info: PrInfo | null; at: number }>();
const prInfoInFlight = new Set<string>();

/** Open PR for the current branch (or null). Refreshes async past the TTL, then calls `onResolved`. */
function getPrInfo(cwd: string, branch: string, onResolved: () => void): PrInfo | null {
	const root = getGitRepoRoot(cwd);
	if (!root || !branch) return null;
	const key = `${root}\n${branch}`;
	const cached = prInfoCache.get(key);
	const fresh = cached && Date.now() - cached.at < PR_TTL_MS;
	if (!fresh && !prInfoInFlight.has(key)) {
		prInfoInFlight.add(key);
		// `gh pr status` finds the current branch's PR even in a fork/triangular workflow,
		// where the head lives on a fork and `gh pr view <branch>` reports nothing.
		const jq = '.currentBranch | select(. != null) | "\\(.number)\\t\\(.url)"';
		// Public github.com repos need GH_HOST=github.com because Netflix's `gh` wrapper
		// defaults to the internal GHE host; otherwise the lookup errors and shows no PR.
		const ghHost = getGhHost(root);
		const env = ghHost ? { ...process.env, GH_HOST: ghHost } : process.env;
		execFile("gh", ["pr", "status", "--json", "number,url", "--jq", jq], { cwd: root, env }, (err, stdout) => {
			prInfoInFlight.delete(key);
			if (err) {
				// `gh` failed (not installed, network/auth, not a repo): keep any prior
				// value and just bump the timestamp so we retry after the TTL, not every tick.
				prInfoCache.set(key, { info: cached?.info ?? null, at: Date.now() });
				return;
			}
			const [numStr, url] = stdout.trim().split("\t");
			const num = Number.parseInt(numStr ?? "", 10);
			const info = Number.isFinite(num) && url ? { number: num, url } : null;
			prInfoCache.set(key, { info, at: Date.now() });
			if ((cached?.info?.number ?? null) !== (info?.number ?? null)) onResolved();
		});
	}
	return cached?.info ?? null; // serve stale (or null) while a refresh is in flight
}

/**
 * Display path for the statusline.
 * - Inside a git repo: show just the repo name, optionally with a relative subpath
 *   (e.g. `dotfiles` or `dotfiles/ai/pi`).
 * - Outside a git repo: fall back to ~-abbreviated absolute path.
 */
function displayPath(absPath: string): string {
	const root = getGitRepoRoot(absPath);
	if (root) {
		const repoName = basename(root);
		const rel = relative(root, absPath);
		if (!rel || rel === ".") return repoName;
		return `${repoName}${pathSep}${rel}`;
	}
	return homeAbbrev(absPath);
}

/** Format token count: 12345 → 12.3k, 200000 → 200k */
function fmtTokens(n: number): string {
	if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
	if (n >= 1_000) return `${(n / 1_000).toFixed(1)}k`;
	return `${n}`;
}

/** Emoji for each thinking level (the label text is the mapped wire value). */
const THINKING_ICON: Record<string, string> = {
	off:     "💤",
	minimal: "🌱",
	low:     "💡",
	medium:  "🔥",
	high:    "⚡",
	xhigh:   "🚀",
	max:     "🧠",
};

/** Theme color slot for each thinking level — colors get brighter as effort increases. */
const THINKING_COLOR: Record<string, ThemeColor> = {
	off:     "thinkingOff",
	minimal: "thinkingMinimal",
	low:     "thinkingLow",
	medium:  "thinkingMedium",
	high:    "thinkingHigh",
	xhigh:   "thinkingXhigh",
	max:     "thinkingMax",
};

/**
 * Status-line effort label: the emoji for the Pi thinking level plus the wire
 * value that level maps to for the active model. Native xhigh and max remain
 * distinct; only custom provider maps may change the displayed value.
 */
export function effortLabel(level: string, thinkingLevelMap?: Record<string, string | null>): string {
	const mapped = thinkingLevelMap?.[level];
	const value = typeof mapped === "string" ? mapped : level;
	return `${THINKING_ICON[level] ?? "🧠"} ${value}`;
}

export function effortColor(level: string): ThemeColor {
	return THINKING_COLOR[level] ?? "accent";
}

// ─── Extension ───────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	let turnCount = 0;
	let requestRender: (() => void) | null = null;

	const triggerRender = () => requestRender?.();

	pi.on("session_start", async (_event, ctx) => {
		turnCount = 0;

		ctx.ui.setFooter((tui, theme, footerData) => {
			/** Wrap any styled string in ANSI bold (\x1b[1m … \x1b[22m). */
			const bold = (s: string) => theme.bold(s);

			requestRender = () => tui.requestRender();

			const unsubBranch = footerData.onBranchChange(triggerRender);

			return {
				dispose() {
					unsubBranch();
					requestRender = null;
				},
				invalidate() {},

				render(width: number): string[] {
					// Separator uses `borderAccent` — the theme's dedicated border-accent color,
					// which is intentionally distinct from foreground colors (and never red) in
					// every shipped pi theme, so it always reads as a divider and visually
					// separates the bold-red π brand mark from the chips that follow.
					const sep = bold(theme.fg("borderAccent", " │ "));

					// ── Session cost ──────────────────────────────────────────────
					let totalCost = 0;
					for (const e of ctx.sessionManager.getBranch()) {
						if (e.type === "message" && e.message.role === "assistant") {
							const m = e.message as AssistantMessage;
							totalCost += m.usage?.cost?.total ?? 0;
						}
					}

					// ── Context usage ─────────────────────────────────────────────
					const usage = ctx.getContextUsage();
					const pct = usage?.percent ?? null;
					const tokens = usage?.tokens ?? null;
					const window = usage?.contextWindow ?? 200_000;

					const barColor =
						pct !== null && pct >= 80 ? "error" :
						pct !== null && pct >= 60 ? "warning" :
						"success";

					const bar = pct !== null ? asciiBar(pct) : asciiBar(0);
					const pctLabel = pct !== null ? ` ${Math.round(pct)}%` : " --%";
					const tokenLabel =
						tokens !== null
							? bold(theme.fg("syntaxNumber", ` ${fmtTokens(tokens)}/${fmtTokens(window)}`))
							: "";

					// ── Working directory (session cwd) ───────────────────────────
					const pwd = displayPath(ctx.sessionManager.getCwd());

					// ── Git branch (+ PR number if one is open) ───────────────────
					const branch = footerData.getGitBranch();
					const prInfo = branch
						? getPrInfo(ctx.sessionManager.getCwd(), branch, triggerRender)
						: null;
					const branchLabel = prInfo
						? `${branch} (${hyperlink(`#${prInfo.number}`, prInfo.url)})`
						: branch;

					// ── Model name ────────────────────────────────────────────────
					const modelId = ctx.model?.id ?? "";
					const modelShort = modelId.replace(/^claude-/, "");

					// ── Theme name ────────────────────────────────────────────────
					const themeName = theme.name ?? "unknown";

					// ── Thinking level (ExtensionAPI only — not on ExtensionContext) ─
					const thinkingLevel = pi.getThinkingLevel();
					const thinkingLabel = effortLabel(thinkingLevel, ctx.model?.thinkingLevelMap as Record<string, string | null> | undefined);
					const thinkingColor = effortColor(thinkingLevel);

					// ── Agent-beach status (promoted to line 1 chip) ─────────────
					const allStatuses = footerData.getExtensionStatuses();
					const beachStatus = allStatuses.get("agent-beach") ?? "";

					// ── Compose main content (left-packed) ────────────────────────
					// Each chunk gets a distinct vivid theme color — no "dim" / "muted" so every
					// chip pops, while the separator stays dim to keep them visually separated.
					const parts: string[] = [];
					                 parts.push(PI_BRAND);
					if (pwd)         parts.push(bold(theme.fg("mdLink",         `📁 ${pwd}`)));
					if (branch)      parts.push(bold(theme.fg("success",       `🌿 ${branchLabel}`)));
					if (modelShort)  parts.push(bold(theme.fg("syntaxKeyword", `🤖 ${modelShort}`)));
					                 parts.push(bold(theme.fg(thinkingColor,   thinkingLabel)));
					                 parts.push(bold(theme.fg(barColor as any, `📊 ${bar}${pctLabel}`)) + tokenLabel);
					                 parts.push(bold(theme.fg("mdHeading",     `💰 $${totalCost.toFixed(3)}`)));
					                 parts.push(bold(theme.fg("accent",        `🎨 ${themeName}`)));
					const mainContent = parts.join(sep);

					// ── Right-anchored: beach badge + turns ───────────────────────
					const rightParts: string[] = [];
					if (beachStatus) rightParts.push(beachStatus);
					rightParts.push(bold(theme.fg("bashMode", `🔄 ${turnCount}`)));
					const rightSeg = rightParts.join(sep);

					// ── Layout ────────────────────────────────────────────────────
					const gap = Math.max(1, width - visibleWidth(mainContent) - visibleWidth(rightSeg));
					const spacer = " ".repeat(gap);

					// ── Extension statuses (line 2) ───────────────────────────────
					// agent-beach is promoted to line 1; remaining extension statuses
					// (e.g. netflix-provider 🎬 flash) go on line 2 only if present.
					// We push "skills" status last so it appears after active runner/spinner states.
					const statusEntries: string[] = [];
					let skillsVal: string | undefined = undefined;
					for (const [key, val] of allStatuses.entries()) {
						if (key === "agent-beach" || !val) continue;
						if (key === "skills") {
							skillsVal = val;
						} else {
							statusEntries.push(val);
						}
					}
					if (skillsVal) {
						statusEntries.push(skillsVal);
					}
					const line1 = truncateToWidth(mainContent + spacer + rightSeg, width);
					if (statusEntries.length > 0) {
						return [line1, truncateToWidth(statusEntries.join(sep), width)];
					}
					return [line1];
				},
			};
		});
	});

	pi.on("turn_start", async () => {
		turnCount++;
		triggerRender();
	});

	pi.on("turn_end", async () => {
		triggerRender();
	});

	/** Model switch reclamps thinking; refresh model + thinking labels without waiting for a turn. */
	pi.on("model_select", async () => {
		triggerRender();
	});

	pi.on("session_shutdown", async () => {
		turnCount = 0;
		requestRender = null;
	});
}
