import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Creates a new session note from template",
  args: {
    session_note_name: tool.schema.string().describe("Name of the session note to create"),
  },
  async execute(args) {
    const results = await Bun.$`../scripts/create_session_note.sh ${args.session_note_name}`
    return results.stdout.toString() + results.stderr.toString()
  },
})