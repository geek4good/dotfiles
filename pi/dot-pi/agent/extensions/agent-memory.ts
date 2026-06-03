import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execSync } from "node:child_process";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "agent_memory_search",
    label: "Agent Memory Search",
    description:
      "Hybrid search (vector + BM25) over memory files. Returns semantically relevant results from project memory. Use for finding past decisions, patterns, or context.",
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      mode: Type.Optional(
        Type.Union([
          Type.Literal("hybrid"),
          Type.Literal("vector"),
          Type.Literal("keyword"),
        ])
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const mode = params.mode || "hybrid";
      const flag =
        mode === "vector"
          ? "--vector"
          : mode === "keyword"
            ? "--keyword"
            : "";

      try {
        const stdout = execSync(
          `agent-memory search "${params.query}" ${flag} --json`,
          {
            encoding: "utf-8",
            timeout: 30_000,
            maxBuffer: 50 * 1024 * 1024,
          }
        );
        const results = JSON.parse(stdout);
        return {
          content: [{ type: "text", text: JSON.stringify(results, null, 2) }],
          details: { mode, resultCount: Array.isArray(results) ? results.length : "N/A" },
        };
      } catch (err: any) {
        return {
          content: [
            { type: "text", text: `agent-memory error: ${err.message || err}` },
          ],
          details: {},
        };
      }
    },
  });

  pi.registerTool({
    name: "agent_memory_code_nav",
    label: "Agent Memory Code Nav",
    description:
      "Navigate indexed code tree to find relevant code structures (functions, classes) based on a natural language query.",
    parameters: Type.Object({
      query: Type.String({ description: "Natural language query to navigate code tree" }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      try {
        const stdout = execSync(
          `agent-memory code-nav "${params.query}" --json`,
          {
            encoding: "utf-8",
            timeout: 30_000,
            maxBuffer: 50 * 1024 * 1024,
          }
        );
        return {
          content: [{ type: "text", text: stdout.trim() || "No results" }],
          details: {},
        };
      } catch (err: any) {
        return {
          content: [
            { type: "text", text: `agent-memory code-nav error: ${err.message || err}` },
          ],
          details: {},
        };
      }
    },
  });
}
