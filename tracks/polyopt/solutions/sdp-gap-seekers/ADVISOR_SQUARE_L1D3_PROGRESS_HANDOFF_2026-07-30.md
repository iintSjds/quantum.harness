# Advisor progress handoff: Square \(L=1,d=3\) experiment

Date: 2026-07-30  
Owner of this experimental route: advisor/scnet2  
Status at this revision: corrected exact build running; solver dependency-gated

## Executive summary

The advisor-side experiment raises the Square \(J_1\)-\(J_2\) gap relaxation
from the completed internal Rung C (\(L=1,d=2\), `one_symbol_lift`) to
challenge-style \(L=1,d=3\) at \(J_2/J_1=1/2\) and decision point
\(\gamma=2\).

The first full build was computationally affordable and reached the full-spin
quotient:

\[
3{,}535{,}570
\;\longrightarrow\;
886{,}114
\;\longrightarrow\;
694{,}666
\;\longrightarrow\;
350{,}263
\;\longrightarrow\;
118{,}708
\]

moments through source, \(V_4\), conjugation, spin-axis, and full-spin
stages. It then stopped safely because two truth functions contained
degree-two inventory regression constants. This was a necessary failure at
\(d=3\), independent of whether the underlying coefficient identities pass.

Commit `f85e12b` replaces only those numeric \(d=2\) locks with
degree-generic representation-structure checks. It retains all exhaustive
coefficient projection, cone congruence, cross-block-zero, invertibility,
Hamiltonian-invariance, and equality-covariance gates. A clean rerun is in
progress, with the solve configured to start only after every remaining
truth gate and the optimizer-free MOF reload succeed.

No result about \(L=1,d=3\) feasibility or a gap bound may be claimed yet.

## Relation to the completed \(L=1,d=2\) experiment

The previous advisor-side Square Rung-C experiment is the same hierarchy
family at:

- \(L=1,d=2\);
- `one_symbol_lift`;
- \(J_2/J_1=1/2\);
- unrestricted state class;
- no physical boundary condition, only a local consistency window.

That run produced an exact rational feasible witness at \(\gamma=2\)
(denominator \(10^6\), exact positive pivots). By monotonicity it established
feasibility throughout \([0,2]\) for that finite relaxation, so
\(L=1,d=2\) does not certify a Square gap upper bound below 2.

The purpose of \(L=1,d=3\) is to test whether increasing moment degree at the
same nine-site window materially strengthens the decision problem before
attempting the more spatially informative but somewhat larger \(L=2,d=2\).

## Exact hierarchy definition

This experiment uses:

| field | value |
|---|---|
| model | Square \(J_1\)-\(J_2\) |
| \(J_2/J_1\) | \(1/2\) exactly |
| decision \(\gamma\) | \(2\) exactly |
| patch level \(L\) | 1 |
| polynomial degree \(d\) | 3 |
| outer sites | \((2L+1)^2=9\) |
| inner sites | \((2L-1)^2=1\) |
| positive/gap basis | structured `one_symbol_lift`, version 1 |
| state class | unrestricted |
| physical boundary condition | none; local consistency window |

There is no bond-dimension parameter \(D\) or independent site-count
hierarchy parameter \(N\) in this formulation.

The formal source count agrees with the independent combinatorial check

\[
q(9,6)+\binom{q(9,3)}2
=104680+\binom{2620}2
=3{,}535{,}570,
\qquad
q(n,k)=\sum_{j=0}^{k}\binom nj3^j.
\]

## Symmetry/reduction route

The build applies, in order:

1. exact Pauli/source assembly;
2. exact \(V_4\) spin rotation quotient and facial reduction;
3. conjugation projection and realification;
4. an exact spin-axis involution split;
5. the implemented full spin-axis permutation quotient;
6. proof and removal of redundant nontrivial-character cones;
7. proof and reduction of the remaining trivial/standard spin isotypic
   sectors;
8. exact anti-diagonal spatial reflection
   \((x,y)\mapsto(-y,-x)\), including the moment quotient and PSD
   eigenspace split;
9. optimizer-free real-symmetric JuMP/MOF construction;
10. independent MOF reload and structural validation;
11. only then, a fail-closed Mosek solve and numerical residual/eigenvalue
    audit.

These are intended as exactly equivalent reparameterizations of the finite
relaxation. They do not assume that an underlying physical state itself
breaks no symmetry; the equivalence rests on convex group averaging and the
explicit coefficient/equality covariance gates.

### Symmetries/optimizations not composed into this run

- Full Square \(D_4\) is implemented and validated for the older Rung-B
  `SquareGapConic` path, but is not composed with this full-spin/isotypic
  path.
- The existing continuous \(SO(3)\) prototype is degree-two specific and
  handles tensors only through rank four. Degree three reaches rank six, so
  reusing it would be mathematically incomplete.
- The builder materializes the full source inventory before quotienting.
  Direct orbit-reduced assembly could save time and memory but would require
  a new equivalence implementation.
- The existing Rung-B \(D_4\) implementation uses dense rational
  \(n\times n\) matrices. Applying it directly at positive side
  \(n=5{,}239\) would allocate over 27 million rational slots before
  coefficient assembly and is not an acceptable last-minute port.

## Measured inventories from the first full attempt

Job `118172784` ran for 1:05:51 and reached the cone-redundancy truth gate.
The exact inventories emitted before that gate were:

| stage | moment count | PSD information |
|---|---:|---|
| source | 3,535,570 | positive side 5,239; gap side 7 |
| exact \(V_4\) | 886,114 | positive sides 612,669,669,669,613,669,669,669; gap 1,1,1 |
| conjugation/realification | 694,666 | 1,720,462 real triangle entries |
| spin-axis split | 350,263 | positive 324,288,669,288,381,325,288,669,288,381; gap 1,1 |
| full-spin quotient | 118,708 | 865,863 real triangle entries |

The builder's `/proc` high-water measurement reached about 6.46 GiB. Slurm
did not report an OOM or time-limit event. Thus construction is
computationally slow but comfortably within the 110 GiB node allocation.

## Failed-attempt chronology

### Non-scientific launch/environment failures

- `118172575`: Slurm could not open its output path because the isolated
  clone lacked the ignored `results/` parent. No Julia/model work ran.
- `118172594`: Julia started but the fresh clone's `julia-env` had no
  Manifest-backed installation. It stopped at `using JuMP`.

The corrected jobs explicitly use scnet2's known-good Manifest-backed
project at `/public/home/iint_sjds/quantum.harness/julia-env`.

### First scientific build

- builder job: `118172784`;
- builder commit: `7e5c43ca915ca532840a1a49cdfe07d48f4d131b`;
- status: failed safely at
  `full_spin_nontrivial_cone_redundancy_truth`;
- dependent solve `118173311`: automatically cancelled because the build
  dependency did not succeed.

The exact failure predicate in `FullSpinConeReduction.jl` included

```julia
expected_orbit_dimensions == [1, 81, 81]
```

which is a \(d=2\) regression inventory. The \(d=3\) spin-axis inventory
necessarily changes these block dimensions (the observed candidate pattern
is \(1,288,288\)), so the aggregate `exact` flag had to be false even if all
coefficient-level identities were true.

Inspection found a second downstream \(d=2\) regression lock in
`FullSpinIsotypicReduction.jl`, fixing source/trivial/standard dimensions to
\([108,109]\), \([36,37]\), and \([36,36]\). It had not yet been reached by
the failed build.

## Degree-generic truth-gate fix

Branch:
`experiment/square-l1d3-spatial-scnet2`

Relevant commits:

| commit | purpose |
|---|---|
| `7e5c43c` | locked \(L=1,d=3,\gamma=2\) spatially reduced build gate |
| `996e4e0` | fail-closed dynamic solver/auditor |
| `f85e12b` | degree-generic cone/isotypic inventory truth checks |

`f85e12b` changes only inventory-shape predicates:

- cone representatives must have shape \([1,m,m]\), while every actual
  projection, congruence, gauge-phase, cross-block-zero, and basis-rank check
  remains exhaustive;
- centered isotypic rows must consist of three-element orbits;
- scalar rows must contain exactly one singleton and otherwise
  three-element orbits;
- source, trivial, and standard dimensions must satisfy the representation
  identities
  \[
  n_c=3m_c,\quad n_s=1+3m_s,\quad
  t_c=m_c,\quad t_s=1+m_s;
  \]
- singleton/triple counts must agree with those derived multiplicities;
- all existing unsigned-action, conjugation-even, involution, cross-block,
  proportional-standard-block, and invertibility checks remain mandatory.

The patch passed `git diff --check` and Julia `Meta.parseall` on scnet2. The
clean rerun is the required dynamic validation; until it passes, we should
not infer that the other conjuncts in the original aggregate truth flag were
true.

## Current live jobs

At the time of this note revision:

| job | role | state |
|---|---|---|
| `118196332` | corrected exact build, run `square-l1d3-spatial-gamma2-20260730-r4` | running; exact \(V_4\) stage |
| `118196351` | fail-closed Mosek solve, run `square-l1d3-spatial-gamma2-solve-20260730-r2` | pending on `afterok:118196332` |

Both request 32 CPUs, 110 GiB, and a 12-hour wall limit on scnet2
`kshcnormal`. The solve cannot start from a partial or failed model.

The corrected source stage has already reproduced:

- 3,535,570 moments;
- positive side 5,239;
- gap side 7;
- three stationarity equalities;
- about 6.35 GiB process high-water RSS at that checkpoint.

## Solver/audit policy

The prepared solver does not trust only Mosek status. Before attaching an
optimizer it checks:

- `SHA256SUMS` for MOF and run metadata;
- locked physical/hierarchy setup;
- exact reduction schemas and truth flags;
- monotone moment-count inventories;
- source-file hashes;
- MOF variable/constraint counts;
- all named real PSD cone dimensions and cone types;
- normalization and equality names.

If primal values are returned, it exports their exact IEEE-754 bit patterns,
reconstructs every real symmetric PSD block, computes minimum eigenvalues,
and audits normalization and every affine equality with normalized
residuals.

A feasible floating result is labelled only
`feasible_residual_checked_float`. An infeasible solver status is only an
`infeasibility_candidate_requires_independent_ray_replay`; it is not by
itself a certified bound.

## Interpretation and next actions

When the corrected chain terminates:

1. verify build and solve exit codes;
2. harvest `sacct`, build/solve logs, process-time reports, run metadata,
   MOF/primal-value hashes, and the final result;
3. inspect every exact truth flag and final PSD inventory;
4. if \(\gamma=2\) is feasible with residual audit:
   - conclude only that this \(L=1,d=3\) relaxation still excludes no gap
     through 2;
   - do not spend time scanning lower \(\gamma\);
   - consider \(L=2,d=2\) next if resources/deadline permit;
5. if \(\gamma=2\) is infeasible:
   - independently replay/validate an infeasibility ray before claiming a
     bound;
   - then bracket the threshold with a small number of rational
     \(\gamma\) points;
6. if another truth gate fails:
   - report the individual failed invariant;
   - do not bypass a coefficient-level identity;
   - distinguish another degree-specific regression lock from a genuine
     failure of the proposed reduction.

## Comparison warning for reported SS \(L=3,d=2\)

If Shastry--Sutherland \(L=3,d=2\) used this same `one_symbol_lift` gap
definition, it would have approximately:

- 49 outer and 25 inner sites;
- positive side 21,463;
- gap side 151;
- 75,252,682 formal source moments.

Therefore an SS run described only as “\(L=3,d=2\)” is not an
apples-to-apples resource comparison. Before using it strategically, obtain
its basis manifest, outer/inner site counts, pre/post-symmetry variable
counts, PSD block dimensions, and whether it solves an energy or gap
problem.

## Repository/worktree handoff

- The experimental implementation is isolated on the scnet2 branch above;
  it has not been merged into the main integration branch.
- Advisor notes in the main worktree are intentionally untracked and should
  be preserved for handoff.
- Do not merge the experimental code solely because the job runs. First
  review the corrected truth-gate semantics and harvest a complete
  build/solve evidence bundle.

