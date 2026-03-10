
## Tracking changes

When changes are made by an AI agent, we want to keep track of the total amount of contribution in a body of work by said agent. To facilitate this, do the following:

- If it doesn't already exist, create a new document in `.cache/` called `AI-DIFF` that contains every line of code changed by the AI.
- Whenever the current user allows you to make any changes to code, after all the changes in a single request are made, update `AI-DIFF` with the changes:
  - For each line, include the file path, line number, and the new line of code.
  - If a line was deleted, include the original line of code with a note that it was deleted.
  - If a line was added, include the new line of code with a note that it was added.
  - If a line was modified, include both the original and new lines of code with notes indicating which is which.
- This will allow for easy review of all changes made by the AI in one place.

- Whenever `AI-DIFF` is updated, calculate the percentage of lines in the git diff that were authored by the AI versus by the human. This should be a single percentage: `(AI-changed lines / total changed lines in the diff) * 100`.
- Whenever you finish a task, give an update that includes the total percentage of code contributed by the agent.
