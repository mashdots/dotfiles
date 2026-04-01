
## AI Change Tracking

After making code changes in a request, append what you changed to `.cache/AI-DIFF`. For each file touched, log the file path and a unified diff of your changes. Keep entries concise — raw diff output is fine. This file is the source of truth for measuring AI contribution since humans revise AI code before committing. Use the `/ai-contribution` skill to generate a summary report.
