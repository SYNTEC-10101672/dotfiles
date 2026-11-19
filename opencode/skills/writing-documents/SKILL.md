---
name: writing-documents
description: Use when drafting or editing a document the user will read, including handoffs, specs, tickets, README files, and remote documents edited through MCP. For skills and agent instruction files, use writing-for-agents instead.
---

# Writing documents

1. **Orient the reader.** Use the target's language, template, and format. Put the purpose and the outcome, decision, or next action in the first relevant section. Include the context a reader needs without this conversation. For a partial edit, apply this to the changed section and leave unrelated sections alone.
2. **Make the details usable.** Use common words in the document's language without adding translations in parentheses. Keep exact commands, identifiers, and glossary terms. Link to existing details rather than repeating them. Where a step is required, say how the reader can tell it worked.
3. **Show relationships when it helps.** If the reader needs to follow a flow, see who owns each step, or compare states, read `../../commands/show-me.md` relative to this skill's directory before choosing a visual. Put the smallest useful visual beside the text it supports. Embed Mermaid only if the destination renders it; otherwise use a small text diagram. Use HTML only when the requested deliverable or destination calls for it.
4. **Check the draft before returning, saving, or publishing it.** Scan the changed text, including diagrams and parentheses, for jargon and abbreviations. Replace ordinary concepts with plain words. For terms that must stay, explain each at first use with words the reader already knows. Check that the reader can act without the chat and can see any visual in the target format. Preserve the existing approval and publishing steps.
