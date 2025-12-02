import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Creates a new NPC entry from template",
  args: {
    npc_name: tool.schema.string().describe("Name of the NPC to create"),
    dry_run: tool.schema.boolean().describe("Show what would be created without creating files").default(false),
    verbose: tool.schema.boolean().describe("Show detailed output").default(false),
    quiet: tool.schema.boolean().describe("Suppress output (except errors)").default(false),
  },
  async execute(args) {
    const results = await Bun.$`../scripts/create_npc.sh ${args.npc_name}`
    return results.stdout.toString() + results.stderr.toString()
  },
})