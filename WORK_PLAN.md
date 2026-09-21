# MOSt Work Plan

## 1. Consultation letter workflow — finalize mail merge

- Start from the stable consultation workflow baseline at GitHub commit `5073cab`.
- Preserve LetterBuilder's existing Word merge action.
- Make sure the operator can open the chart, choose a template after New, click Create Consult, and receive the merged consultation letter with the latest Vision to Plan information inserted.
- Test the generated document and confirm the chart is not replaced or left as a blank document.

## 2. Third party billing

- Resume the third party billing work after the consultation workflow is finalized.
- Review the current V16.64 state and continue the remaining billing changes.
- Build and verify an installer after the billing work is complete.

## Current saved state

- GitHub branch: `codex/v16.28-verified`
- Consultation work baseline to use: `5073cab`
- Later commit `26fa460` should not be used as the starting point because it produced a blank document with partial text.

## Future plans

- Complete and validate the consultation mail merge workflow.
- Continue and finish the third party billing work in V16.64.
- Build, checksum, and archive installers for each validated release.

