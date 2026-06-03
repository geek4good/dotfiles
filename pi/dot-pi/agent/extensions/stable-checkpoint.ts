import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execSync } from "node:child_process";
import { writeFileSync } from "node:fs";

function exec(cmd: string): string {
  return execSync(cmd, { encoding: "utf-8", timeout: 15_000 }).trim();
}

function execQuiet(cmd: string): string {
  try {
    return exec(cmd);
  } catch {
    return "";
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("stable", {
    description: "Create a tagged git checkpoint with documentation",
    handler: async (_args, ctx) => {
      try {
        // Verify we're in a git repo
        const isRepo = execQuiet("git rev-parse --git-dir 2>/dev/null");
        if (!isRepo) {
          ctx.ui.notify("Not a git repository", "error");
          return;
        }

        // Check for uncommitted changes
        const dirty = execQuiet("git status --porcelain");
        if (dirty) {
          const ok = await ctx.ui.confirm(
            "Uncommitted changes",
            "You have uncommitted changes. Create checkpoint anyway?"
          );
          if (!ok) {
            ctx.ui.notify("Checkpoint cancelled. Commit your changes first.", "info");
            return;
          }
        }

        const timestamp = new Date()
          .toISOString()
          .replace(/[-:]/g, "")
          .replace(/\..+/, "")
          .replace("T", "-");

        const tagName = `stable-${timestamp}`;
        const branchName = `checkpoint/${tagName}`;
        const commitHash = exec("git rev-parse HEAD");
        const shortHash = commitHash.slice(0, 7);
        const currentBranch = execQuiet("git branch --show-current") || "detached HEAD";

        // Create annotated tag
        exec(
          `git tag -a "${tagName}" -m "Stable checkpoint ${timestamp}"`
        );

        // Create checkpoint branch
        exec(`git branch "${branchName}" "${tagName}"`);

        // Generate documentation
        const fileCount = exec("git ls-files | wc -l | tr -d ' '");
        const recentCommits = execQuiet("git log --oneline -10");
        const lastStable = execQuiet(
          'git tag -l "stable-*" | sort -V | tail -2 | head -1'
        );
        const changesSince = lastStable
          ? execQuiet(`git diff --stat "${lastStable}..HEAD" 2>/dev/null`)
          : "";

        const readme = `# Stable Checkpoint: ${tagName}

## Checkpoint Info
- **Tag:** \`${tagName}\`
- **Branch:** \`${branchName}\`
- **Commit:** \`${shortHash}\`
- **Date:** ${new Date().toISOString()}
- **Branch:** ${currentBranch}
- **Files tracked:** ${fileCount}

## How to Restore
\`\`\`bash
git checkout ${tagName}              # view this checkpoint
git checkout -b new-work ${tagName}  # branch from this point
git diff ${tagName}..HEAD            # compare with current
\`\`\`

## Recent Commits
\`\`\`
${recentCommits}
\`\`\`
${changesSince ? `## Changes Since Last Stable\n\`\`\`\n${changesSince}\n\`\`\`\n` : ""}
`;

        writeFileSync("stable-readme.md", readme);
        exec('git add stable-readme.md');
        exec(
          `git commit -m "docs: stable checkpoint ${tagName}"`
        );

        ctx.ui.notify(
          `Stable checkpoint created: ${tagName} (${shortHash})`,
          "success"
        );
      } catch (err: any) {
        ctx.ui.notify(`Checkpoint failed: ${err.message}`, "error");
      }
    },
  });
}
