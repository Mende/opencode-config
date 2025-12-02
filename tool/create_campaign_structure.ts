import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Creates a complete D&D campaign file structure with directories and template files",
  args: {
    campaign_name: tool.schema.string().describe("Name of the campaign to create"),
    dry_run: tool.schema.boolean().describe("Show what would be created without creating files").default(false),
    verbose: tool.schema.boolean().describe("Show detailed output").default(false),
    quiet: tool.schema.boolean().describe("Suppress output (except errors)").default(false),
  },
  async execute(args) {
    // Your database logic here
    const results = await Bun.$`../scripts/create_campaign_structure.sh ${args.campaign_name}`
    return results.stdout.toString() + results.stderr.toString()
  },
})


