# Advisor review of worker update `291d5db`

Date: 2026-07-29  
Reviewed range: `1a33eac..291d5db`  
Scope: evidence-only update for Square J1-J2 D4-quotient Rung B at
`gamma=1/4` and `gamma=2`; no project code was executed during this review.

## Verdict

**Accept the computations as a numerical negative result, after correcting the
claim language and two misleading diagnostics.**

The two new Mosek solves are genuine SDP solves and reached coherent numerical
feasible statuses. Together with the existing `gamma=0` and `gamma=2/5`
results, they support:

> At `g=1/2`, `L=1`, `d=2`, the `bare_operator` Rung B relaxation with the
> exactly equivalent D4-invariant quotient remained numerically solver-feasible
> at `gamma = 0, 1/4, 2/5, 2`. No finite-level gap upper bound at or below
> `gamma=2` was obtained; this relaxation is too weak over the tested range.

They do **not** support:

- “Rung B can never upper-bound the gap”;
- “Rung B is feasible for every gamma”;
- a physical lower bound on the Square J1-J2 gap;
- a certified physical statement; or
- convergence of the SDP hierarchy.

This is still a worthwhile deliverable. It shows that a nontrivial,
memory-intensive relaxation was built, symmetry-reduced, solved, and diagnosed
as insufficient, which identifies the next mathematical strengthening.

## Evidence checked

| gamma | Job | MOI termination | Primal / dual | Final numerical residual scale | Solve wall | Peak process RSS |
|---:|---:|---|---|---:|---:|---:|
| `0` | `23005746` | `OPTIMAL` | feasible / feasible | `PFEAS=4.0e-12`, `DFEAS=2.0e-13`, `MU=2.0e-13` | 1700.5 s | about 86.5 GiB |
| `1/4` | `23006792` | `OPTIMAL` | feasible / feasible | `PFEAS=DFEAS=1.5e-11`, `MU=1.5e-11` | 1482.9 s | about 87.4 GiB |
| `2/5` | `23006706` | `OPTIMAL` | feasible / feasible | `PFEAS=DFEAS=1.8e-9`, `MU=1.8e-9` | 1416.9 s | about 74.4 GiB |
| `2` | `23006793` | `OPTIMAL` | feasible / feasible | `PFEAS=DFEAS=2.0e-9`, `MU=2.0e-9` | 1461.7 s | about 74.5 GiB |

For each positive-gamma model:

- positive-basis dimension: `352`;
- gap-basis dimension: `4`;
- D4 positive blocks: `70, 24, 45, 45, 168`;
- gap block: `4`;
- D4 moment-quotient variables: `1837`;
- scalar normalization/stationarity constraints: `4`;
- affine conic constraints: `6`;
- affine-conic rows: `75,888`;
- Mosek reports six semidefinite variables after scalarization/presolve.

The MOF and input metadata have distinct gamma-dependent SHA-256 values. The
source commit and relevant source-file hashes are recorded. The latest commit
adds evidence only; it does not change the formulation.

## Findings

### P0.1 — Narrow the “cannot upper-bound” statement

The commit message says:

> it cannot upper-bound the Square J1-J2 gap

The scan stops at `gamma=2`. A finite infeasibility threshold could still
exist above 2, so the absolute statement is not established. The precise
statement is:

> No upper bound at or below 2 was obtained. Rung B remained numerically
> feasible throughout the tested range and is not useful at the physical
> scales of interest.

Likewise, do not copy the older Rung A phrase “feasible at every gamma” to this
Rung B result unless an analytic all-gamma pseudo-moment construction is
actually proved.

No history rewrite is necessary. Correct the final README, PR body, result
summary, and `run.json` narrative.

### P0.2 — “Fully converged” must refer only to the numerical solve

The decreasing Mosek barrier parameter and primal/dual residuals show that each
interior-point solve reached Mosek's `OPTIMAL` status. They do not show
convergence with `L`, `d`, basis strength, or hierarchy level.

Use:

> Mosek reached `OPTIMAL` with primal and dual feasible points and final
> residual/barrier scales between `1.5e-11` and `2.0e-9`.

Avoid the standalone phrase “fully converged.”

### P1.1 — `preopt.toml` misleadingly reports zero PSD structure

Every new `preopt.toml` records:

```toml
semidefinite_variable_count = 0
semidefinite_dimensions = []
semidefinite_constraint_nonzero_count = 0
```

This initially looks like the PSD cones were dropped. They were **not**:
MosekTools represents the JuMP Hermitian PSD constraints as six affine conic
constraints before optimization. The Mosek log reports:

```text
Affine conic cons.      : 6 (75888 rows)
...
Semi-definite variables: 6 scalarized : 75888
```

The current diagnostic calls only the Mosek “bar variable” API and therefore
does not count PSD cones represented through affine conic constraints.

Before final reporting, either:

1. extend `mosek_task_summary` to record affine-conic constraint/domain counts;
   or
2. rename the existing fields to make clear that they count only native
   pre-opt bar variables, and add the six expected JuMP PSD block dimensions
   from the validated run metadata.

Do not report `PSD_dimensions=[]` as the problem size. Report the validated
block dimensions `70,24,45,45,168` plus gap block `4`.

This is a diagnostic/provenance bug, not a formulation or solver-result bug.
No scientific rerun is needed.

### P1.2 — The transcript incorrectly prints `solve_form=dual`

`solve_square_primal_mof.jl` currently prints:

```text
Mosek task: ... solve_form=dual
```

unconditionally. In these runs:

- `preopt.toml` correctly says `solve_form = "mosek_default"`;
- the forced-dual environment option was off; and
- Mosek's log says it solved the **primal** problem.

Change the progress message to print `preopt["solve_form"]`. In the final
report, use the preopt metadata and Mosek log, not the erroneous transcript
line.

Again, this does not require rerunning the completed solves.

### P1.3 — Terminal Slurm accounting was not harvested

Both new `sacct-provisional.txt` files still say `RUNNING`, with blank `MaxRSS`,
even though the application transcript reaches `finished` and solver exit code
zero. This is a normal accounting-lag snapshot, but it is not final provenance.

Fetch one terminal `sacct` record per job showing final state, exit code,
elapsed time, and MaxRSS. If accounting is no longer available, label the
existing files explicitly provisional and use the process high-water mark from
`result.toml`.

No solver rerun is needed.

### P1.4 — Do not interpret `relative_gap` for a zero-objective feasibility SDP

The reported relative gaps include `3.976...` at `gamma=2`, even though the
primal objective is identically zero and the dual objective is numerical noise
near zero. This ratio is not a useful quality metric for a feasibility problem.
Report termination status and primal/dual feasibility residuals instead.

### P2.1 — Explain the `gamma=0` size difference

The zero-gamma artifact has `12826` original moments and `1831` quotient
variables, while each positive-gamma artifact has `12832` and `1837`.
This is consistent with exact support pruning: six moments occur only in the
gamma-dependent covariance terms and disappear when their coefficients are
exactly zero.

Add one sentence explaining this in the result summary. Do not imply that all
four MOFs have identical inventories. The positive-gamma points do share the
same dimensions.

## Theory assessment

The result semantics are coherent:

1. The finite relaxation asks whether a pseudo-state satisfying its constraints
   exists at an assumed gap threshold.
2. Numerical feasibility does not prove the physical system is gapped.
3. Feasibility at a deliberately high threshold shows that the relaxation has
   insufficient constraints to exclude that threshold.
4. Therefore this scan diagnoses relaxation weakness; it yields no physical
   gap bound.

The D4 quotient does not by itself change this conclusion. Under the previously
documented covariance and averaging gates, it is an exactly equivalent search
over an invariant representative of the finite convex feasible set, not a
restriction to a physically D4-symmetric ground state. The latest evidence
does not alter that earlier theory argument.

## Recommended next action

1. **Bank this as the final Square result.** No rerun of gamma `0`, `1/4`,
   `2/5`, or `2` is warranted.
2. Fix the two reporting diagnostics above and harvest terminal accounting.
3. Add one compact four-row table to the final README/report using the exact
   wording in this review.
4. Present the contribution as:
   - exact model assembly and coefficient gates;
   - D4-equivalent reduction from roughly 12.8k moments to roughly 1.8k;
   - a tractable 75,888-row SDP requiring 74–87 GiB and 24–28 minutes;
   - a negative gamma scan showing that this smallest tractable rung is too
     weak through gamma 2.
5. Attempt Rung C or a spin-adapted `V4rtS3` strengthening only if an
   implementation and resource estimate already exist. With the submission
   window closing, a new formulation should be treated as optional stretch
   work, not as a prerequisite for a valid deliverable.

## Claim-status matrix

| Claim | Status after `291d5db` |
|---|---|
| Solver-free Square assembly is reproducible and hash-bound | Supported |
| D4 quotient model contains the intended PSD cones | Supported by MOF reload and Mosek ACC log |
| Four Rung B thresholds were numerically solver-feasible | Supported |
| Rung B produced a Square gap upper bound | **No** |
| Rung B is too weak over `0 <= gamma <= 2` at the tested points | Supported, with “tested points/range” wording |
| Rung B is feasible for every gamma | Not established |
| Physical Square J1-J2 system has gap at least 2 | False inference; do not claim |
| Certified physical bulk-gap result | Not obtained |

