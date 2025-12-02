import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Creates a new organization entry from template",
  args: {
    organization_name: tool.schema.string().describe("Name of the organization to create"),
  },
  async execute(args) {
    const results = await Bun.$`../scripts/create_organization.sh ${args.organization_name}`
    return results.stdout.toString() + results.stderr.toString()
  },
})