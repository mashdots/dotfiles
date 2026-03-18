---
name: ai-contribution
description: "Generate a summary report of AI vs human code contributions for the current branch. Reads the live .cache/AI-DIFF file (maintained automatically per AGENTS.md) and compares it against the total git diff to compute contribution percentages. Use when wrapping up a task, reviewing AI contribution, or when asked about contribution stats."
---

# AI Contribution Report

Generate a contribution summary by comparing the AI change log against the actual git diff.

## Steps

1. **Read the AI change log**:
   ```bash
   cat .cache/AI-DIFF
   ```
   This file is maintained live by the agent as it works (per AGENTS.md). It contains raw diffs of every change the AI made, before any human revision.

2. **Get the total branch diff**:
   ```bash
   git diff --stat $(git merge-base HEAD master)..HEAD
   ```
   Include uncommitted changes too:
   ```bash
   git diff --stat
   ```

3. **Count lines**:
   - **AI-written lines**: Count the `+` and `-` lines in `.cache/AI-DIFF` (excluding diff headers).
   - **Total changed lines**: Count insertions + deletions from the git diff stat (committed + uncommitted).
   - **Human-revised lines**: Total changed lines minus AI-written lines. Note: this can be negative if humans deleted AI code or positive if humans added their own changes.

4. **Report**:

   ```
   ## AI Contribution Summary

   **Branch**: <branch-name> (vs master)

   | | Lines | % |
   |---|---|---|
   | AI-authored | +X, -Y | Z% |
   | Total in diff | +X, -Y | 100% |

   **AI contribution**: Z% of the final diff originated from AI edits.

   Note: Humans may have revised AI-generated code before committing.
   The AI-authored count reflects what the agent originally wrote.
   ```

## Notes

- The `.cache/AI-DIFF` file captures what the AI *originally wrote*, not what ended up in the final commit. This is intentional — it measures AI contribution before human review.
- If `.cache/AI-DIFF` doesn't exist, report that no AI changes have been tracked and suggest the agent may not have been logging changes.
- The `.cache/` directory is gitignored, so this file won't be committed.
