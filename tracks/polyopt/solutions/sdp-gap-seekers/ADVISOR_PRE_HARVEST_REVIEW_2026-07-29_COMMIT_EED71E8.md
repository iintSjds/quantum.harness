# Advisor pre-harvest commit review

Date: 2026-07-29  
Branch: `challenge/polyopt-sdp-gap`  
Reviewed HEAD: `eed71e8`  
Previous review point: `3338706`  
Scope: static commit review only; running jobs were not queried, interrupted, or
harvested

## Decision

The previous code-level launch blockers are fixed. I see no reason from this
static review to cancel the running jobs.

The new commits successfully:

- remove the accidentally nested/duplicated gate functions;
- make the gate runner fail nonzero;
- preserve a pinned passing gate transcript;
- state a finite-relaxation D4 averaging lemma with an explicit physical-state
  caveat;
- add a quotient-variable manifest and reduced semantic hash;
- reproduce the old `gamma=0` MOF byte-for-byte after cleanup.

At harvest, keep two caveats visible:

1. runmeta still says “unrestricted; not symmetry restricted,” which is stronger
   than the new lemma's own conservative public label;
2. `reduced_model_sha256` identifies the quotient semantics but does not hash
   the exact Q matrix or transformed MOF coefficients, so it must be reported
   together with the MOF SHA-256.

## Commit-by-commit assessment

### `5f79c93` — builder cleanup and fail-closed gate

Assessment: **accepted**.

The accidental copy of the gate functions inside
`d4_positive_block_matrix` was removed, leaving one global implementation. The
runner now raises an error when any gate fails. This addresses the two immediate
P0 findings from the previous review.

The remaining unindented `end` in the inner coefficient loop is stylistically
awkward but has the intended nesting and is not a scientific blocker.

### `4dbd283` — gate transcript

Assessment: **accepted with minor provenance caveat**.

The committed transcript records:

```text
source commit                 = 5f79c93
Julia                         = 1.11.5
moment closure                = true, 0 missing
positive M covariance         = 497024 checked, 0 violations
gap K/G covariance            = 80 checked, 0 violations
off-irrep sampled cancellation = 1440 checked, 0 violations
overall                       = PASS
```

The gate is fail-closed at the pinned source, and source/output hashes are
committed. The worktree was not literally clean because of `Ion.lock`, advisor
notes, and the evidence directory being written, but the relevant source commit
and source-file hashes are identified. This is sufficient for the deadline
claim.

Minor follow-up: the transcript does not explicitly record the shell exit code,
and `source-sha256.txt` omits some included dependencies such as `CoreMGK.jl`.
The pinned repository commit resolves the latter; neither issue warrants
delaying the jobs.

### `9ab02c2` — finite-relaxation D4 averaging lemma

Assessment: **sufficient for the finite-SDP claim; physical interpretation
remains open**.

The note correctly distinguishes the averaged object:

> a relaxed state-polynomial functional/pseudo-moment sequence, not a physical
> KMS state.

For a convex, D4-stable finite SDP feasible set, the averaging proof

```text
F(gamma) nonempty  iff  F(gamma)^D4 nonempty
```

is sound under its listed invariance/closure assumptions. The positive-matrix
covariance gate, gap-component covariance gate, basis representation, and
central-site geometry substantially support those assumptions.

The note does not fully resolve the apparent conflict with Remark 2.7 of the
source paper. In fact, the finite-functional averaging result is precisely why
linear invariance of a relaxed functional must not automatically be identified
with support on symmetric physical states. The note handles this responsibly by
retaining the public label:

> D4-averaged finite relaxation; feasibility-equivalent to the unrestricted
> finite relaxation by convex averaging; physical symmetry interpretation under
> review.

Use that sentence in the final report. Do not shorten it to “unrestricted
physical bound.”

An explicit row-by-row stationarity covariance gate remains desirable but is
not a deadline blocker for this `L=1` setup: the inner site is D4-fixed, the
candidate axes are unchanged by spatial D4, and H is invariant.

### `eed71e8` — quotient manifest and reduced semantic hash

Assessment: **accepted as the deadline-minimum semantic identity**.

The manifest now records:

- schema and source assembly hash;
- all eight site permutations;
- D4 block labels/dimensions;
- quotient variable count and orbit histogram;
- ordered representative moment for every quotient variable;
- complete original-moment-to-variable mapping.

This makes the 1,831 variables interpretable and reproducible. The manifest is
included in `SHA256SUMS`, and runmeta records `reduced_model_sha256`.

Important scope:

- `reduced_model_sha256` is the SHA-256 of the semantic quotient manifest;
- it does not include the exact rational Q entries;
- it does not include the post-congruence coefficient map;
- it is therefore not, by itself, a hash of every emitted reduced conic
  coefficient.

The MOF SHA-256 supplies the byte identity of the actual conic model. Always
report the pair:

```text
reduced semantic SHA-256  = quotient/reduction identity
MOF SHA-256               = exact emitted conic instance
```

Do not describe `reduced_model_sha256` alone as a complete model hash.

## One wording mismatch to correct at harvest

`build_square_d4_conic_mof.jl` still writes:

```text
equivalence_note =
  "exactly-equivalent reparameterization of the unrestricted relaxation;
   not a symmetry-restricted bound"

state_symmetry = "none_unrestricted"
```

This wording is more categorical than `notes/d4-averaging-lemma.md`, which
correctly limits the conclusion to the finite relaxed-functional feasible set.

Preferred fix for future bundles:

```text
equivalence_note =
  "D4-averaged finite relaxation; feasibility-equivalent to the unrestricted
   finite relaxation by convex averaging; physical symmetry interpretation
   under review."

state_symmetry =
  "D4-invariant relaxed functional; physical-state interpretation not asserted"
```

If the current running jobs already contain the old runmeta string, do not
alter the original input artifact. Add a harvest-time `INTERPRETATION.md`
correction beside it.

## Harvest requirements for each running job

When a job reaches a terminal state, archive:

- final solver result;
- full solver log;
- input runmeta;
- `quotient-manifest.txt`;
- input MOF SHA-256;
- reduced semantic SHA-256;
- source commit and relevant dirty paths;
- final, not provisional, Slurm accounting;
- solver exit code;
- complete `SHA256SUMS`.

Before interpreting the result, verify:

1. source commit is `eed71e8` or a documented descendant;
2. basis is `bare_operator/v1`, `L=1`, `d=2`, `g=1/2`;
3. requested `gamma` matches runmeta and launch expectation;
4. quotient variable count is 1,831;
5. block dimensions are `70,24,45,45,168` plus gap block 4;
6. quotient manifest and MOF checksums pass;
7. result status is classified using the existing three-way semantics.

Interpretation:

- `OPTIMAL + FEASIBLE_POINT` → feasible candidate only;
- timeout, numerical status, or ambiguous certificate → unknown;
- apparent infeasibility → candidate requiring independent ray replay;
- no “certified upper bound” until formulation-bound rigorous replay passes.

## Recommended action while jobs run

Do not add another scientific feature. Use the time to prepare:

- the harvest script/checklist;
- the result table with empty status cells;
- the D4 resource-comparison figure;
- the interpretation correction;
- the final report and README update.

## Updated status

| Item | Status at `eed71e8` |
|---|---|
| Accidental builder regression | Fixed |
| Fail-closed D4 gate | Fixed |
| Pinned passing gate evidence | Present |
| Finite-relaxation averaging argument | Present |
| Conservative physical interpretation | Present in lemma, not yet in runmeta |
| Quotient variable manifest | Present |
| Reduced semantic hash | Present |
| Complete conic identity | Available via semantic hash + MOF hash pair |
| Current `gamma=0` solve | Already achieved at earlier pinned source |
| Positive-`gamma` result | Awaiting running jobs |
| Square certified upper bound | Not yet |

The project is in the correct state for the planned small positive-`gamma`
experiment. The next meaningful review should be based on terminal job
artifacts, not another implementation expansion.
