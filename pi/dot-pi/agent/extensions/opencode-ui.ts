import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  let currentModel = "";
  let thinkingLevel = "";

  function updateStatus(ctx: any) {
    const thinking = thinkingLevel || pi.getThinkingLevel() || "high";
    const parts: string[] = [];
    if (currentModel) parts.push(currentModel);
    parts.push(`thinking:${thinking}`);
    ctx.ui.setStatus("opencode-ui", parts.join(" | "));
  }

  // Set terminal title to match opencode style
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    const cwd = ctx.cwd.split("/").pop() || ctx.cwd;
    ctx.ui.setTitle(`pi - ${cwd}`);
    thinkingLevel = pi.getThinkingLevel();
    updateStatus(ctx);
  });

  // Track model changes and update status
  pi.on("model_select", async (event, ctx) => {
    if (!ctx.hasUI) return;
    currentModel = event.model.name || event.model.id;
    updateStatus(ctx);
  });

  // Show a working message during agent turns
  pi.on("turn_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    thinkingLevel = pi.getThinkingLevel();
    updateStatus(ctx);
  });
}
