import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execSync } from "node:child_process";
import { writeFileSync, readdirSync, statSync, existsSync } from "node:fs";
import { join, relative, extname } from "node:path";

interface FileMetrics {
  path: string;
  lines: number;
  conditionals: number;
  functions: number;
  nesting: number;
  score: number; // composite complexity 0-100
}

const CODE_EXTS = new Set([
  ".ts", ".tsx", ".js", ".jsx", ".py", ".rb", ".go", ".rs",
  ".java", ".c", ".cpp", ".h", ".swift", ".kt", ".css", ".scss",
  ".html", ".vue", ".svelte", ".zig", ".elm",
]);

function countLines(filePath: string): number {
  try {
    return parseInt(
      execSync(`wc -l < "${filePath}"`, { encoding: "utf-8", timeout: 5000 }).trim()
    ) || 0;
  } catch {
    return 0;
  }
}

function countConditionals(filePath: string): number {
  try {
    const content = execSync(`cat "${filePath}"`, {
      encoding: "utf-8",
      timeout: 5000,
      maxBuffer: 10 * 1024 * 1024,
    });
    const patterns = [
      /\bif\b/g,
      /\belse\b/g,
      /\bfor\b/g,
      /\bwhile\b/g,
      /\bswitch\b/g,
      /\bcase\b/g,
      /\bcatch\b/g,
      /\?\s*:/g,       // ternary
      /&&/g,
      /\|\|/g,
    ];
    let total = 0;
    for (const p of patterns) {
      const matches = content.match(p);
      if (matches) total += matches.length;
    }
    return total;
  } catch {
    return 0;
  }
}

function countFunctions(filePath: string): number {
  try {
    const content = execSync(`cat "${filePath}"`, {
      encoding: "utf-8",
      timeout: 5000,
      maxBuffer: 10 * 1024 * 1024,
    });
    const patterns = [
      /\bfunction\b/g,
      /\bdef\b/g,
      /\bfunc\b/g,
      /\bfn\b/g,
      /=>/g,
      /\bclass\b/g,
    ];
    let total = 0;
    for (const p of patterns) {
      const matches = content.match(p);
      if (matches) total += matches.length;
    }
    return total;
  } catch {
    return 0;
  }
}

function maxNesting(filePath: string): number {
  try {
    const content = execSync(`cat "${filePath}"`, {
      encoding: "utf-8",
      timeout: 5000,
      maxBuffer: 10 * 1024 * 1024,
    });
    let maxDepth = 0;
    for (const line of content.split("\n")) {
      // Count leading spaces/tabs as nesting proxy
      const match = line.match(/^(\s*)/);
      if (match) {
        const indent = match[1].replace(/\t/g, "    ").length / 2;
        maxDepth = Math.max(maxDepth, Math.floor(indent));
      }
    }
    return maxDepth;
  } catch {
    return 0;
  }
}

function walkDir(dir: string, files: string[] = []): string[] {
  if (!existsSync(dir)) return files;
  try {
    for (const entry of readdirSync(dir)) {
      const fullPath = join(dir, entry);
      // Skip node_modules, .git, dist, build, .cache
      if (
        entry === "node_modules" ||
        entry === ".git" ||
        entry === "dist" ||
        entry === "build" ||
        entry === ".cache" ||
        entry === ".next" ||
        entry === "__pycache__" ||
        entry.startsWith(".")
      )
        continue;
      try {
        const st = statSync(fullPath);
        if (st.isDirectory()) {
          walkDir(fullPath, files);
        } else if (st.isFile() && CODE_EXTS.has(extname(entry))) {
          files.push(fullPath);
        }
      } catch {
        // permission error, skip
      }
    }
  } catch {
    // skip
  }
  return files;
}

function compositeScore(m: Omit<FileMetrics, "score">): number {
  // Normalize each 0-25 and sum to get 0-100
  const lineScore = Math.min(25, (m.lines / 500) * 25);
  const condScore = Math.min(25, (m.conditionals / 100) * 25);
  const funcScore = Math.min(25, (m.functions / 50) * 25);
  const nestScore = Math.min(25, (m.nesting / 10) * 25);
  return Math.round(lineScore + condScore + funcScore + nestScore);
}

function heatmapColor(score: number): string {
  if (score >= 75) return "#ff4444";   // hot — very complex
  if (score >= 50) return "#ff8844";   // warm
  if (score >= 25) return "#ffcc44";   // mild
  return "#44cc44";                     // cool — simple
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("heatmap", {
    description:
      "Generate code complexity heatmap — opens in browser showing which files need attention",
    handler: async (_args, ctx) => {
      const cwd = process.cwd();
      ctx.ui.notify("Scanning files...", "info");

      const files = walkDir(cwd);
      if (files.length === 0) {
        ctx.ui.notify("No source files found", "error");
        return;
      }

      const metrics: FileMetrics[] = [];
      for (const f of files) {
        const rel = relative(cwd, f);
        const lines = countLines(f);
        if (lines === 0) continue;
        const m = {
          path: rel,
          lines,
          conditionals: countConditionals(f),
          functions: countFunctions(f),
          nesting: maxNesting(f),
          score: 0,
        };
        m.score = compositeScore(m);
        metrics.push(m);
      }

      metrics.sort((a, b) => b.score - a.score);

      // Generate HTML heatmap
      const maxScore = metrics[0]?.score || 1;
      const rows = metrics
        .map((m, i) => {
          const bg = heatmapColor(m.score);
          const width = Math.max(2, Math.round((m.score / maxScore) * 100));
          return `
        <tr>
          <td style="text-align:right;color:#888">${i + 1}</td>
          <td style="font-family:monospace;font-size:13px">${m.path}</td>
          <td style="text-align:right">${m.lines}</td>
          <td style="text-align:right">${m.conditionals}</td>
          <td style="text-align:right">${m.functions}</td>
          <td style="text-align:right">${m.nesting}</td>
          <td style="text-align:right;font-weight:bold">${m.score}</td>
          <td>
            <div style="background:${bg};width:${width}px;height:14px;border-radius:3px" title="score:${m.score}"></div>
          </td>
        </tr>`;
        })
        .join("\n");

      const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8">
<title>Code Complexity Heatmap — ${cwd.split("/").pop()}</title>
<style>
  body { font-family: -apple-system, sans-serif; margin: 40px; background: #111; color: #ddd; }
  h1 { font-size: 20px; margin-bottom: 5px; }
  .sub { color: #888; font-size: 13px; margin-bottom: 20px; }
  table { border-collapse: collapse; width: 100%; }
  th { text-align: left; color: #888; font-size: 12px; text-transform: uppercase; padding: 8px 10px; border-bottom: 1px solid #333; }
  td { padding: 6px 10px; border-bottom: 1px solid #222; font-size: 13px; }
  tr:hover { background: #1a1a1a; }
  .legend { display: flex; gap: 8px; margin-bottom: 20px; font-size: 12px; align-items: center; }
  .legend div { width: 40px; height: 14px; border-radius: 3px; }
</style></head><body>
<h1>🔥 Code Complexity Heatmap</h1>
<p class="sub">${files.length} files • ${metrics.reduce((s,m)=>s+m.lines,0)} lines • composite score (lines×cond×func×nest)</p>
<div class="legend">
  <div style="background:#44cc44"></div> simple
  <div style="background:#ffcc44"></div> moderate
  <div style="background:#ff8844"></div> complex
  <div style="background:#ff4444"></div> hot
</div>
<table>
<tr><th>#</th><th>File</th><th>Lines</th><th>Cond</th><th>Func</th><th>Nest</th><th>Score</th><th>Heat</th></tr>
${rows}
</table>
</body></html>`;

      const outPath = join(cwd, ".context", "complexity-heatmap.html");
      try {
        const { mkdirSync } = await import("node:fs");
        mkdirSync(join(cwd, ".context"), { recursive: true });
      } catch {}
      writeFileSync(outPath, html);

      // Try to open in browser
      try {
        execSync(`open "${outPath}"`, { timeout: 3000 });
      } catch {
        // can't open browser, just save
      }

      ctx.ui.notify(
        `Heatmap: ${files.length} files, top: ${metrics[0]?.path} (${metrics[0]?.score}) — Saved to .context/`,
        "success"
      );
    },
  });
}
