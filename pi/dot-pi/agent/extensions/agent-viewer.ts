import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execSync } from "node:child_process";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "agent_viewer_plan",
    label: "Agent Viewer Plan",
    description:
      "Open an editable browser-based plan review UI for a markdown plan file. Returns JSON with user edits and comments.",
    parameters: Type.Object({
      file: Type.String({
        description: "Path to the markdown plan file (e.g. .context/todo.md)",
      }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      try {
        const stdout = execSync(
          `agent-viewer plan --file "${params.file}" --json`,
          {
            encoding: "utf-8",
            timeout: 300_000, // 5 min — user needs time to review in browser
            maxBuffer: 10 * 1024 * 1024,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: stdout.trim() || "(viewer closed with no changes)",
            },
          ],
          details: { file: params.file },
        };
      } catch (err: any) {
        return {
          content: [
            { type: "text", text: `agent-viewer error: ${err.message || err}` },
          ],
          details: {},
        };
      }
    },
  });

  pi.registerTool({
    name: "agent_viewer_spec",
    label: "Agent Viewer Spec",
    description:
      "Open an editable browser-based spec review UI for a spec folder. Returns JSON with user feedback and edits.",
    parameters: Type.Object({
      folder: Type.String({
        description:
          "Path to the spec folder (e.g. context-os/specs/2026-06-03-feature/)",
      }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      try {
        const stdout = execSync(
          `agent-viewer spec --folder "${params.folder}" --json`,
          {
            encoding: "utf-8",
            timeout: 300_000,
            maxBuffer: 10 * 1024 * 1024,
          }
        );
        return {
          content: [
            {
              type: "text",
              text: stdout.trim() || "(viewer closed with no changes)",
            },
          ],
          details: { folder: params.folder },
        };
      } catch (err: any) {
        return {
          content: [
            { type: "text", text: `agent-viewer error: ${err.message || err}` },
          ],
          details: {},
        };
      }
    },
  });
}
