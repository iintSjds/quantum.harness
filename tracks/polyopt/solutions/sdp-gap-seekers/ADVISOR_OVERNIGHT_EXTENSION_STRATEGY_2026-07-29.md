# Advisor strategy: one affordable overnight extension

Date: 2026-07-29  
Current main-team head reviewed: `291d5db`  
Collaborator branch reviewed:
`flyingwagner/challenge/polyopt-ss-exact-reduction` at `f1fb24c`

## Decision

**Yes, pursue one extension overnight—but use the already validated
Shastry–Sutherland exact-reduction route. Do not start Square Rung C or a new
model implementation.**

The specific experiment is the prepared sequential `g=4/5`, `L=1`, `d=2`
coarse scan at

```text
gamma = 1, 2, 4
```

stopping at the first solver-reported infeasibility candidate.

This is the only current option that is simultaneously:

- directly inside challenge #88 Target 2;
- already implemented;
- protected by extensive exact coefficient/reduction gates;
- empirically cheap;
- capable of changing the scientific conclusion overnight; and
- recoverable as a negative result if every tested point stays feasible.

## Why this route dominates

The collaborator branch already establishes the following for the
Shastry–Sutherland model at `g=0.8`:

1. Correct orthogonal-dimer geometry and Pauli normalization.
2. Exact `g=0` product-singlet oracle:
   `E/N=-3/8`, local gap `1`, and singlet projector expectation `1`.
3. A full `L=1,d=2` one-symbol source relaxation with:
   - `74,602` source moments;
   - positive/gap dimensions `703/7`;
   - no dropped finite-relaxation constraints.
4. Six exact symmetry/reparameterization layers reducing the solved model to:
   - `3,250` moment variables;
   - nine real PSD cones;
   - `6,104` packed PSD coordinates;
   - maximum block side `45`.
5. Audited numerical feasibility at `gamma=0` and `gamma=1/2`.
6. Exact rational replay of the `gamma=1/2` primal point: all nine rational
   PSD blocks have strictly positive exact LDL pivots.
7. Measured `gamma=1/2` performance:
   - Mosek solve wall about `7.8 s`;
   - process peak RSS about `1.1 GiB`;
   - a `39.1x` RSS and `52.2x` solver-wall improvement over the original exact
     Hermitian representation, without changing the finite relaxation.

Thus `gamma=1/2` is not merely a floating solver status: there is an exact
strictly feasible witness for the declared finite relaxation. It still does
not prove a physical lower bound.

The prepared dynamic scan rebuilds the exact source assembly and replays every
reduction gate at each gamma. A build has taken roughly 2–3 minutes, while the
reduced solve is seconds. Three points should be comfortably overnight within
the existing `16 CPU / 24 GiB / 3 h` request.

## Why the previous scan failure is not a scientific blocker

The first coarse scan attempt failed before the optimizer because the Slurm
output parent directory did not exist. The second built the gamma-one model
successfully and then failed before attaching Mosek because a helper accepted
`String` but Julia `split` returned `SubString{String}`.

Branch head `f1fb24c`:

- generalizes the runner-facing string boundaries to `AbstractString`;
- adds dedicated split/regex boundary regression tests; and
- runs those tests before any scan assembly.

This is an entry-point repair, not a changed model or relaxation. One corrected
resubmission is justified.

## Exact overnight experiment

Use the collaborator branch's:

```text
scripts/shastry_sutherland_isotypic_gamma_scan_xh5.sbatch
```

with the declared ordered grid:

```text
SS_SCAN_GAMMAS="1 2 4"
```

The worker must preserve these launch gates:

1. checkout at the reviewed/final scan-runner commit;
2. clean source tree;
3. create the ignored `tracks/.../results/` parent before `sbatch`, because
   Slurm opens its output file before the script starts;
4. set the actual xH5 Julia project, Mosek binary, licence, and repository-root
   paths explicitly rather than relying on Sihan-specific defaults;
5. retain the pre-run string-boundary test;
6. keep the sequential order and stop at the first infeasibility candidate;
7. retain all build/solve logs, runmeta, model/result hashes, exit codes, final
   Slurm accounting, and generated `SHA256SUMS`;
8. do not resubmit while the shared `AssocGrpSubmitJobsLimit` signature is
   unchanged.

## Decision tree

| Scan outcome | Scientific interpretation | Next action |
|---|---|---|
| `gamma=1` infeasible candidate | Numerical finite-relaxation transition bracket between the exact-feasible `1/2` point and `1` | Stop scan. Preserve candidate and time-box independent ray extraction/replay. |
| `1` feasible, `2` infeasible candidate | Numerical bracket `[1,2]` | Stop scan; attempt ray replay only. |
| `1,2` feasible, `4` infeasible candidate | Numerical bracket `[2,4]` | Stop scan; attempt ray replay only. |
| `1,2,4` all feasible | The declared `d=2` relaxation is too weak through 4 | Stop. Do not probe larger gamma. Report the exact reduction and negative scan. |
| Timeout/unknown | No transition conclusion at that point | Do not reinterpret as infeasible. Preserve it as unknown; avoid a solver-tuning campaign. |
| Another pre-optimizer interface failure | Runner problem, not science | Permit one narrow repair with a targeted regression, then one retry. Do not redesign the model. |

If an infeasibility candidate appears, the claim remains:

> numerical finite-relaxation upper-bound candidate

until a formulation-bound infeasibility ray is independently replayed. The
existing rational-witness replay validates feasible primal points; it is not
an infeasibility-ray verifier. Do not call the scan result certified merely
because the gamma-half feasible witness is exact.

If the ray path cannot be completed quickly, a coarse numerical bracket plus
the exact feasible endpoint is already a strong honest result.

## Integration plan

The Shastry work is currently on a collaborator branch rather than the main
team branch. Run the scan on its validated branch first; do not delay compute
for integration.

In parallel, the worker should prepare a normal Git merge/integration branch
that preserves both histories. The collaborator diff is large but the
meaningful overlaps are concentrated in:

- `README.md`;
- `src/GenericGapModel.jl`;
- `test/runtests.jl`; and
- the global SCNet profile.

Resolution policy:

1. preserve the current Square D4 work and evidence;
2. preserve the Shastry model, exact-reduction modules, proof notes, runners,
   and result summary;
3. combine—not choose between—the Square and Shastry test includes;
4. rewrite the final README around both results;
5. restore the global `skills/using-slurm/profiles/scnet.toml` before final
   submission, as already decided;
6. do not silently copy code without its source history and exact proof/gate
   documents;
7. keep generated result bundles outside git, with compact hashes and result
   tables in the solution.

Do not merge a partially resolved tree directly into the submission branch.
Let the worker inspect the integration diff first.

## Optional stretch after the scan

Only one of the following is justified, in this order:

### Stretch A — independent infeasibility-ray replay

Do this only if the coarse scan actually returns a candidate. It has the
highest possible payoff because it can promote a numerical transition to an
audited upper-bound result. Time-box implementation and audit; never infer a
certificate from a status enum alone.

### Stretch B — actual `g=0` finite-relaxation calibration

If the scan finishes early and no ray work is needed, parameterize the same
exact-reduced builder at `g=0` and test `gamma=1` followed by a point just
above 1. This directly compares the relaxation with the known dimer gap.

This requires changing the currently fixed `g=4/5` setup and all associated
fail-closed metadata. It is optional and must pass the exact dimer oracle and
gamma-zero/truth gates before optimization. Feasibility above 1 would mean
only that the relaxation is loose; it would not invalidate the exact physical
dimer oracle.

## Explicit no-go options

### Square Rung C

Do not launch it overnight from the current main branch:

- positive/gap dimensions are `703/7`;
- the source model has `74,602` moments and about `989,226` real affine-conic
  rows before exact reductions;
- the unreduced attempt already exhausted or stalled on the approximately
  486-GiB node;
- the current Square D4 builder accepts only Rung A/B basis families;
- extending D4 to one-symbol Rung C still leaves a substantially larger
  factorization than the 74–87-GiB, 24–28-minute Rung B solves; and
- combining spatial and full-spin reductions correctly would require new
  exact covariance/congruence gates.

Agents can write this code quickly, but they cannot make the new equivalence
proof and high-memory validation free. It is a post-deadline project.

### More Square Rung B points

Do not run `g=0`, `g=0.535`, or gamma values above 2 merely to collect rows.
The present Square relaxation is already diagnosed as weak; more feasible
points will not change the submission.

### New lattices or observables

Do not start the triangular model, Néel/plaquette observable optimization,
larger `L/d`, or a new general API overnight.

## Recommended allocation

```text
Compute lane:
    one corrected Shastry gamma=1,2,4 sequential scan

Integration lane:
    merge collaborator Shastry work with current Square branch

Reporting lane:
    prepare tables now; fill the scan outcome when harvested

Stretch lane:
    only infeasibility-ray replay if a candidate appears
```

This adds a second challenge-target model, an exact reduction with a measured
39x/52x computational gain, an exact rational finite-relaxation witness at
gamma `1/2`, and possibly the first actual transition bracket. It is much more
valuable than another uninformative Square feasibility point.

