# Advisor audit: submission requirements and immediate preparation

Date: 2026-07-29 (Asia/Shanghai)  
Team: `sdp-gap-seekers`  
Submission: [upstream PR #160](https://github.com/QuantumBFS/quantum.harness/pull/160)  
Audited local head: `eed71e8`

## Bottom line

The submission object is **the team's one upstream pull request**, not a zip,
paper, or separately uploaded result directory. By **Thursday 2026-07-30 at
20:00 local time**, the team must have run `/challenge-report`, left that PR
**ready for review (not draft)**, and stopped updating it. Generated run data
and figures belong under `tracks/<track>/results/` and stay out of git.

The phrase "reproducible PR" is a fair summary, but it is not a separately
defined file format. In practice the PR must contain, under the team solution
directory, enough code, pinned setup information, commands, tests, compact
result summaries, and limitations for an advisor to understand and reproduce
the claim. The costly SCNet calculation itself does not need to run in GitHub
CI, but its exact inputs and provenance must be recoverable.

No provided rule says that all three models or every requested parameter point
in issue #88 must be completed for a valid submission. Those are the
challenge's scientific targets and judging rubric. A partial result must be
labelled partial and must not claim to complete or close #88.

## Team decisions after review

These decisions supersede the urgency ranking in the initial audit:

1. The global SCNet profile is only local/remote operational support. Restore
   it from the final PR; it does not need a replacement in the deliverable.
2. The root `julia-env/Project.toml` will be assessed for reproducibility and
   relocated or removed only during final packaging.
3. CI is currently unavailable because upstream Actions require approval. The
   team will not spend time on it unless the organizers enable it or request
   it.
4. `run.json` will be created after a headline result is selected and before
   `/challenge-report`; it is not on the computation critical path.
5. PR length is accepted because review is AI-assisted. Do not prune merely to
   reduce line count.
6. README, PR body, and generated-result packaging will be finalized once the
   running jobs have been harvested.

## Sources checked

- [Official participant guide](https://giggleliu.github.io/summer-school-2026/guide),
  especially "Deadlines", "Work in the draft PR", and "Review & showcase".
- Repository `.github/PULL_REQUEST_TEMPLATE.md`.
- Repository skills `skills/take-challenge/SKILL.md`,
  `skills/challenge-report/SKILL.md`, and `skills/report/SKILL.md`.
- [Challenge issue #88](https://github.com/QuantumBFS/quantum.harness/issues/88).
- Local `notes/event-logistics.md`, distilled from organizer announcements.
- Live state of upstream PR #160 and its GitHub Actions runs.

There is a documentation inconsistency about whether a **draft** PR initially
registers a team: the public guide says yes, while the current PR template and
`/take-challenge` skill say no. It has no practical effect now because PR #160
is already open and non-draft. The final deadline and final state are
unambiguous: ready for review by Thursday 20:00, then freeze.

## Hard gates

| Gate | Exact requirement | Current state | Action |
|---|---|---|---|
| One PR | Continue the existing team PR; do not open a second submission PR. | Satisfied: PR #160 is open. | Keep using #160. |
| Correct state and deadline | PR ready for review by Thu 20:00; no updates after that. | State satisfied early: PR is already non-draft. | Run the report and keep it ready; do not toggle it just to mimic the documented sequence. Freeze at the deadline. |
| Submission path | Commit only under `tracks/polyopt/solutions/sdp-gap-seekers/`. | Final-packaging item. PR #160 also changes `julia-env/Project.toml` and `skills/using-slurm/profiles/scnet.toml`. | Restore the SCNet profile before submission. Preserve the Julia dependency information by relocating it under the team folder before restoring the shared root project. |
| Generated results | Generated data and figures go to `tracks/polyopt/results/<run>/` and stay out of git. | Deferred by team decision until final packaging. | Leave current evidence in place while jobs are active; decide the committed summary versus ignored raw-artifact split during finalization. |
| Challenge report | Run `/challenge-report` before final submission. It expects a completed `tracks/*/results/*/run.json`, then produces `report.json` and a standalone `report.html`. | Not yet due. No polyopt `run.json`, `report.json`, or `report.html` exists locally. | After selecting the headline result, normalize it into a local `tracks/polyopt/results/<run>/run.json` with at least one nonempty result, then run `/challenge-report`. Do not commit the results directory. |
| Cleanliness | `/challenge-report` starts with `git status` and diff-scope checks; unexplained changes stop the workflow. | Local worktree was clean before this advisor note, but the PR scope itself violates the path rule above. | Finish/prune the implementation, account for every remaining file, and run the report from a clean tree. |
| CI | Organizer-derived logistics mention passing CI, but upstream controls whether fork workflows can run. | Deferred by team decision. Recent workflow runs all end as `action_required`; no test job has run. | Take no action unless the organizers enable or request CI. If enabled, distinguish approval gating from a real code failure. |

The public guide says `report.json`/`report.html` are generated through
`/challenge-report`, while both the guide and template say `results/` stays out
of git. Therefore the provided materials do **not** require committing the HTML
report to the PR. It is a local review/presentation artifact. If the organizers
want it uploaded through another channel, that channel is not documented here
and should be confirmed with them.

## What `run.json` does

`run.json` is a **report manifest**, not a solver input, certificate, or
submission uploaded to GitHub. `/challenge-report` scans
`tracks/*/results/*/run.json` to find a run, then reads its:

- model and method description;
- tool/settings and resource estimates;
- figure/result paths;
- verdict text and key numerical values.

It uses those fields to draft the Challenge, Approach, Results, and Highlight
sections of `report.json`, which is rendered to `report.html`.

The skill considers a run completed only when at least one figure has a
nonempty `results` object containing a result figure or match verdict. An empty
skeleton therefore does not unblock the workflow. The correct timing here is:

1. finish or harvest candidate jobs;
2. choose the result actually being presented;
3. create `tracks/polyopt/results/<run>/run.json` from that result and its
   provenance;
4. run `/challenge-report`.

The current TOML/log evidence can be the source for this normalization. It does
not need to be converted while the result choice is still changing.

## Assessment of the root Julia project

The modified `julia-env/Project.toml` is **operationally important but located
incorrectly for the final PR**:

- the team's build, solve, validation, and Slurm scripts explicitly invoke
  `julia --project=julia-env`;
- the modified file is the only declared environment containing JuMP, Mosek,
  MosekTools, Clarabel, SpectralGap, QMBCertify, NCTSSoS, and related packages;
- simply reverting it now would make those documented commands incomplete;
- leaving it at the root replaces the harness's shared MPS/ED-oriented Julia
  environment and affects unrelated tracks.

It is also not sufficient by itself for a clean-checkout reproduction. The
working `julia-env/Manifest.toml` is gitignored, and its SpectralGap entry is a
path dependency at `../.external/SpectralGap`, also outside the committed
solution. The committed patch and setup notes explain how that source is
constructed, but the environment is not currently one-step reproducible.

Final packaging should therefore:

1. place a solution-specific Julia project under
   `tracks/polyopt/solutions/sdp-gap-seekers/`;
2. point final reproduction scripts to that project;
3. document or automate the exact SpectralGap source pin plus patch;
4. optionally commit a solution-local Manifest after removing/fixing
   machine-local path assumptions; and
5. restore the shared root `julia-env/Project.toml`.

This is important for reproducibility, not for the mathematical validity of
the results already obtained, and can safely wait until final packaging.

## Required scientific reporting for issue #88

For **every calculation that the final submission chooses to present**, issue
#88 asks for:

| Field | Required content |
|---|---|
| Model | Geometry/Hamiltonian and all coupling parameters |
| Restrictions | Every imposed symmetry; state whether the result is unrestricted or symmetry-restricted |
| Relaxation | \(L\), \(d\), and any extra basis/rung/radius definition needed to make those labels unambiguous |
| Size | Moment-matrix/block dimensions and preferably scalar/cone counts |
| Solver | Solver/version and raw termination, primal, and dual statuses |
| Cost | Runtime and relevant hardware/resources |
| Gap result | Certified gap upper bound, or explicitly "not certified/not produced" |
| Observable result | Certified observable optima, or explicitly "not produced" |

The discussion must say:

1. exactly which gap thresholds are excluded by a valid certificate;
2. whether each statement is unrestricted or symmetry-restricted;
3. how it compares with the phase picture in the literature; and
4. what changes with increasing \(L\), \(d\), or observable radius \(R\).

Do not populate a "certified" field with a merely feasible numerical solve, an
ambiguous/timeout status, or a result lacking the required certificate
semantics. `N/A — not obtained` is correct and safer.

## Reproduction stage versus challenge result

The public guide describes the weekly workflow as: reproduce the track's
published target, then go beyond it. For `polyopt`, the track README names
Table 8 / Figure 7 of the Heisenberg energy-certification work as the pinned
reproduction target.

PR #160 currently presents the 1D TFIM SpectralGap calculation as its baseline.
That is useful challenge-code calibration, but the README/PR body does not show
that the prescribed polyopt reproduction was completed. This is not a GitHub
mechanical gate, but it is a judging risk. Do not start a new expensive sweep
solely for this now. Instead:

- if a valid energy-reference calculation already exists, report its one best
  matched point compactly and honestly;
- otherwise label the TFIM calculation as a substituted method calibration and
  ask the polyopt mentor/organizer whether that is acceptable.

## Current PR-specific submission risks

1. **Reviewability is large but accepted.** PR #160 had 154 changed files and
   24,199 added lines at the initial audit. The team accepts this because
   review is AI-assisted; no pruning is required merely to reduce length.
2. **The landing page is stale.** The team README still says the prototype does
   not assemble or solve an SDP, contradicting the later Square Rung A/B work
   and committed solver evidence.
3. **The PR body is stale.** Its "Plan" still describes early future steps and
   credits only Jie Wang as releaser; issue #88 credits Xiangling Xu and Jie
   Wang.
4. **No report input exists.** The evidence is organized as TOML/log bundles,
   not the `run.json` consumed by `/challenge-report`.
5. **No CI has run.** `action_required` needs maintainer approval; the team is
   deferring this external condition unless organizers request it.

## Minimal final PR shape

Aim for a small review surface:

```text
tracks/polyopt/solutions/sdp-gap-seekers/
├── README.md                  # claim, headline table, limitations, quick start
├── Project.toml / Manifest…   # environment pinned inside the team folder
├── src/                       # implementation
├── scripts/                   # build/solve/validate entry points
├── test/                      # fast solver-free and structural checks
├── patches/                   # any required external-source patch with exact pin
├── docs/                      # only the authoritative theory/design documents
└── result-summary.*           # compact, curated result/provenance record
```

Raw Slurm output, Mosek logs, generated MOF/JLS files, plots, intermediate
result TOMLs, and superseded internal review notes should not dominate the final
diff. Preserve them locally under `tracks/polyopt/results/<run>/`; record
checksums and the command that regenerates them.

The README should support two explicit routes:

1. a quick, clean-checkout validation route that an advisor can run without
   SCNet and preferably without a Mosek licence; and
2. the full build/solve route with the exact Julia environment, external source
   pin/patch, Mosek requirement, SCNet resources, commands, expected outputs,
   and runtime.

## Work order before the deadline

### P0 — while jobs run

1. Do not interrupt scientific work for CI, PR-length cleanup, or premature
   result conversion.
2. Keep the current Julia environment intact until the active jobs and their
   reproduction commands are frozen.
3. Prepare the reporting-column checklist, but do not create `run.json` until
   the headline result is selected.

### P1 — as jobs finish

5. Harvest complete provenance, checksums, solver status, matrix dimensions,
   runtime, and hardware for the selected result.
6. Update the README and PR body from "plan" to "result"; state the precise
   certification level and limitations.
7. Decide the final placement of raw results and evidence; prune only where it
   helps correctness or packaging, not merely line count.
8. Run the team's quick clean-checkout reproduction and the relevant tests.

### P2 — finalization

9. Ensure the worktree is clean and every PR path is under the team directory.
10. Run `/challenge-report`; inspect the standalone HTML for missing fields and
    overclaims.
11. If organizers enable or request CI, obtain green checks; otherwise record
    that workflows remained approval-gated.
12. Check PR #160 remains ready for review, then stop pushing by Thu 20:00.

## Final go/no-go checklist

- [ ] Exactly one upstream PR: #160.
- [ ] PR is open and non-draft.
- [ ] All changed paths are under the team solution directory.
- [ ] Generated data/figures are outside git under `tracks/polyopt/results/`.
- [ ] README gives clean-checkout setup and exact quick/full commands.
- [ ] Every reported calculation has all issue-#88 metadata.
- [ ] Certified/numerical/unknown language is mathematically accurate.
- [ ] Best result and limitations are visible in the first screen of README.
- [ ] PR body reflects the final result, both challenge releasers, and
      `Addresses #88`.
- [ ] `/challenge-report` completed from a clean tree.
- [ ] `report.html` was inspected locally.
- [ ] Upstream Actions approved and CI green.
- [ ] No pushes after Thu 20:00.
