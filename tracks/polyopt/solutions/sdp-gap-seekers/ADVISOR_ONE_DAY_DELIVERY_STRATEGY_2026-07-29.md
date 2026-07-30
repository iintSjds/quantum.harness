# Advisor one-day delivery strategy

Date: 2026-07-29  
Time remaining: approximately one working day, including final packaging  
Assumption: the worker is addressing the D4 correctness/provenance findings in
`ADVISOR_CURRENT_STATUS_REVIEW_2026-07-29.md`

## Decision

Optimize for one defensible Square J1-J2 deliverable:

> A reproducible Square J1-J2 state-polynomial SDP implementation, an exact
> D4 compression/validation result, and a small declared `gamma` experiment
> with conservative status semantics.

Do not make completion depend on obtaining a rigorous Square infeasibility
certificate. If one appears and can be replayed in time, it is an upgrade. The
minimum deliverable is the new Square formulation plus its tractability and
finite-relaxation evidence.

The best final narrative is:

1. the requested Square geometry was implemented;
2. the direct Rung B problem was computationally intractable;
3. an exact or explicitly sound D4 reduction made it runnable;
4. a small `gamma` experiment determined what this finite relaxation can or
   cannot exclude;
5. every result is labelled at its actual evidence level;
6. the existing TFIM certificate work demonstrates the stricter evidence
   pipeline, without being presented as the Square novelty.

This remains useful even if the Square relaxation produces no finite
transition. “The first runnable relaxation is too weak” is a valid,
reproducible scientific result when accompanied by the exact formulation,
cost reduction, and a clear next stronger rung.

## What must ship

### Must-have A — one frozen Square formulation

Freeze exactly one configuration:

```text
model          = Square J1-J2 Heisenberg
J1             = 1
J2/J1          = 1/2
spin convention = S=sigma/2
patch          = L=1, outer 3x3, inner centre
degree         = d=2
basis          = bare_operator/v1 (Rung B)
state class    = whatever the completed D4 lemma actually justifies
```

The artifact needs:

- Hamiltonian, patch, basis, stationarity, and moment manifests;
- source commit and clean status;
- reduced-model/MOF hash;
- exact block dimensions and variable count;
- one command to regenerate it;
- explicit result semantics.

Do not add another basis, patch size, coupling, or model unless this bundle is
already frozen.

### Must-have B — a validated D4 statement

The worker should produce the smallest sufficient correctness package:

- exact coefficient covariance/off-block tests;
- an explicit statement of whether the result is:
  - exactly equivalent to the unrestricted finite relaxation;
  - a D4-symmetry-restricted relaxation; or
  - merely a weaker but sound block-compression relaxation;
- a corrected description of the older pre-quotient run;
- one compact before/after resource table.

The deliverable does not require the strongest possible theorem. It requires
the claim to match the implementation.

### Must-have C — a very small `gamma` experiment

Run only enough points to classify the relaxation:

1. `gamma=0` on the current frozen quotient/reduced model;
2. one moderate positive threshold;
3. one deliberately high threshold.

A reasonable geometric probe pattern is `gamma=0`, `1/4`, and `2`, followed by
one higher probe only if all three are feasible and the run is cheap. The
exact choices may be adjusted from the first logs, but they must be declared
before seeing the status.

Possible outcomes:

| Outcome | Deliverable language |
|---|---|
| All probes feasible | “Rung B remains too weak over the tested range; no Square upper bound obtained.” |
| Clean status transition, no replayed witness | “Numerical finite-relaxation transition candidate.” |
| Independently replayed floating witness | “Numerically audited upper-bound candidate for the frozen relaxation.” |
| Formulation-bound rigorous witness | “Certified finite-level upper bound.” |

Do not spend hours tightly bracketing a transition before the witness path and
final report are secure. A coarse bracket is enough for the deadline.

### Must-have D — one short final report

The final report should contain:

1. physical question and logical direction;
2. exact Square setup;
3. basis/constraint sizes;
4. why the original solve failed;
5. what D4 changed and why it is sound;
6. the three-point `gamma` table;
7. evidence level and limitations;
8. one tractability figure or table;
9. reproduction command and artifact hashes;
10. next scientific step.

The first page/slide must not be dominated by TFIM, Kagome, infrastructure,
or the history of failed branches. Those are validation/background.

## What to stop doing now

Do not spend the remaining day on:

- Kagome `N=27`;
- additional Kagome scans;
- Rung C or larger `L/d`;
- Shastry-Sutherland implementation;
- triangular J1-J2;
- Square Neel-observable intervals;
- a full rewrite of old notes;
- perfect general-purpose APIs;
- a second certificate format;
- tight binary search of `gamma`;
- cosmetic refactors that do not enter the final bundle;
- resolving every theoretical issue in the source paper.

For the D4 symmetry-averaging issue, a precise statement of the unresolved
point and conservative labelling is sufficient if a complete proof cannot be
finished quickly.

## Time-boxed schedule

Use hours relative to the start of the final-day push.

### T+0 to T+3 — correctness freeze

- Correct the old D4 equivalence claim.
- Complete the minimal exact D4 coefficient gates.
- Write the one-page D4 averaging/symmetry lemma or conservative caveat.
- Freeze the configuration and reduced-model schema.

Stop-gate at T+3:

- if exact equivalence is proved, proceed with that label;
- if not, relabel the construction as the strongest demonstrably sound weaker
  relaxation and proceed;
- do not let the proof consume the entire day.

### T+3 to T+8 — generate one clean bundle and launch probes

- Generate the current model from a clean pinned commit.
- Launch `gamma=0` first.
- Once model identity and the first solver log are confirmed, launch at most
  two positive probes, in parallel if resources allow.
- Archive logs and metadata immediately after each job.

In parallel, begin the report and resource-comparison table. Do not wait for
the jobs before writing the setup/method sections.

### T+8 to T+13 — classify, do not over-scan

- Record the three-way statuses.
- If all positive probes are feasible, stop the scan and report relaxation
  weakness.
- If a transition appears, run at most one additional point to make a coarse
  bracket.
- Start witness export/replay only for a promising excluded point.

Stop-gate at T+13:

- no transition: freeze the negative result;
- transition but no valid witness: freeze it as a numerical status candidate;
- replayed witness: promote only to the evidence level actually achieved.

### T+13 to T+18 — evidence and presentation

- Finish `SHA256SUMS`, run metadata, and source pinning.
- Produce the final result table and one visual comparison:

```text
unsymmetrized Rung B -> OOM/stalled
pre-quotient D4 blocks -> gamma=0 solved
current quotient D4 -> final variable/memory/runtime/status
```

- Make README/current-status wording agree with the final result.
- Draft the talk/poster around the Square contribution.

### Last 4–6 hours — release freeze

- No new scientific features.
- No additional large jobs unless they repair a missing required artifact.
- Check links, hashes, commands, figure captions, and claim language.
- Tag or record the final commit.
- Preserve time for upload/submission failures and presentation rehearsal.

## Hard deadline fallbacks

### Fallback 1 — D4 equivalence is not settled

Ship:

- exact Square assembly;
- a clearly labelled sound block-compression relaxation;
- tractability evidence;
- Rung A and any valid reduced-model statuses;
- the exact missing equivalence gate as future work.

Do not abandon the whole deliverable because the strongest equivalence claim
did not survive review.

### Fallback 2 — current quotient solve fails

Ship:

- the validated solver-free quotient artifact;
- the successful older pre-quotient `gamma=0` tractability run, correctly
  relabelled;
- unsymmetrized failure/resource evidence;
- no numerical Square gap claim.

This is an implementation/method deliverable, not a gap-bound deliverable.

### Fallback 3 — positive probes are all feasible

Ship:

- a clean negative statement that Rungs A and B cannot exclude the tested
  thresholds;
- the monotone relaxation ladder and sizes;
- the next required basis strengthening.

Do not hide or over-interpret the negative result.

### Fallback 4 — an apparent exclusion cannot be certified

Ship it as a numerical transition candidate only. Use the TFIM exact/replayed
certificate as proof that the team understands the distinction and has a
working rigorous evidence path on a calibration instance.

## Suggested task split for two collaborators

### Worker/implementation owner

- D4 gates and claim correction;
- clean quotient artifact;
- cluster launches and evidence capture;
- witness export/replay if a transition appears.

### Other collaborator/presentation owner

- final report skeleton immediately;
- setup and result tables;
- tractability visual;
- README/status cleanup;
- artifact index and reproduction instructions;
- slides/poster and deadline submission.

Both should jointly review only:

- the final D4 semantics;
- the three-way solver classification;
- any sentence containing “certified,” “upper bound,” “unrestricted,” or
  “symmetry restricted.”

## Final recommendation

The target for the final day is not “complete challenge #88.” It is:

> Deliver the first honest, reproducible Square J1-J2 implementation and show
> exactly how far its smallest tractable state-polynomial relaxation gets.

That is new relative to the upstream TFIM/Kagome examples, directly aligned
with the requested Square target, and robust to the numerical outcome. A
rigorous Square bound would be an excellent bonus, but making the submission
depend on it is too risky with one day remaining.
