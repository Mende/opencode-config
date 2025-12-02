import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Creates a new location entry from template",
  args: {
    location_name: tool.schema.string().describe("Name of the location to create"),
  },
  async execute(args) {
    const results = await Bun.$`../scripts/create_location.sh ${args.location_name}`
    return results.stdout.toString() + results.stderr.toString()
  },
})