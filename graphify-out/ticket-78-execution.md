# Ticket #78 execution evidence

The owner requested continuing the final release acceptance gate after the full board audit and configurable cutter delivery. Latest main was pulled and pinned at `aa052c733105525c3dc904c6ea3d7b7b25d64a65`.

The gate found a live digital receipt display regression under #75. A 35000-minor-unit manual transaction and public digital receipt reproduced `MANUAL_EXTERNAL` in customer-facing HTML/text. The added unit regression fails before correction. Receipt rendering now uses QRIS / Non-cash. Candidate source `08184e6c9842da52bcd59655cda12d7a3f8a6944` contains that narrow correction and three regression cases.

The [release handoff](../docs/release-acceptance-78.md) pins the environment/schema/toolchain, prerequisite decisions, test evidence and remaining QA steps. Raw before/after runtime, unit and restore logs accompany this record. The #78 handoff comment records matching PR/CI results after the full gate completes.

Software/local acceptance includes actual Node API process restart and same-key recovery/replay, cash/non-cash report reconciliation, exact stock/payment effects, local manual reversal/restart/restock, customer digital receipts and production-manual endpoint gating. Local restore compares ten critical fingerprints and financial totals and tests runtime/backup grants.

Final release acceptance remains pending physical #74 execution and the owner's deferred operator/deployment testing. #78 is handed off open and In QA. The owner deferred #76 representative operator testing, deferred #77 intended deployment acceptance until deployment preparation, and selected manual QRIS/non-cash recording with future automatic provider integration excluded from current scope.
