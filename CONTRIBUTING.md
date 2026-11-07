# Contributing

Keep each change linked to a ticket and limited to its acceptance criteria. Record framework and architecture decisions in `docs/decisions/` before introducing major dependencies.

Use synthetic fixtures. Never commit access tokens, customer data, real payment details, production exports, or signing keys.

Changes to sale completion, stock, reversal, payment, and synchronization require meaningful tests for duplicate requests, failure recovery, and concurrency. Printer support requires verification on named hardware.

Move work from Todo to In Progress when implementation starts, then In QA when it is ready for verification. Mark Done only when acceptance criteria and relevant checks pass. Do not equate a placeholder screen with a completed feature.
