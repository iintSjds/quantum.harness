# Advisor report: can symmetry make Square Rung C feasible?

Date: 2026-07-29  
Reviewed branch: `integration/square-and-ss`  
Reviewed head: `e652894`  
Relevant integration commit: `ede083b`  
Decision: **yes—port the integrated full-spin isotypic reduction before
abandoning Square Rung C**

## Executive decision

There is now a credible, deadline-compatible way to make Square Rung C
computationally feasible. It is not the D4-only route tested in scnet2 Gate 0.
It is the six-layer global-spin reduction already implemented and audited for
the Shastry--Sutherland calculation:

```text
source
  -> V4 spin rotations + gap facial reduction
  -> computational-basis conjugation / realification
  -> order-two spin-axis split
  -> full spin-axis-permutation moment quotient
  -> redundant nontrivial-character cone removal
  -> trivial-character S3 isotypic split
```

The Square J1--J2 Hamiltonian is a sum of Heisenberg dot products and is
globally spin-rotation invariant. The Square and Shastry source problems also
use the same `L=1`, `d=2`, `one_symbol_lift/v1` basis on the same 3-by-3
patch. Both have:

```text
positive dimension          703
gap dimension                 7
source moments           74,602
stationarity equalities        3
```

Consequently, the already-measured Shastry reduced inventory is the expected
Square inventory as well:

```text
invariant moment variables             3,250
real PSD cones                              9
positive cone sides       36,36,36,45,37,36,36,45
gap cone side                                1
packed real PSD entries                  6,104
maximum cone side                           45
```

This is far below the scnet2 CPU-node limit. The corresponding Shastry models
used about 1.0--1.1 GiB process peak RSS and 6.6--7.8 seconds of Mosek solve
wall. Square coefficients may change factor fill and solve behavior, so those
numbers are not a resource guarantee, but the size margin is enormous
compared with the approximately 111.5 GiB normal scnet2 allocation.

The recommendation is therefore:

> Do not abandon Square Rung C yet. Ask the worker to adapt the existing
> full-spin-isotypic builder and runner to Square J1--J2, run all exact truth
> gates on the actual Square coefficients, and attempt gamma zero. Do not
> combine this with D4 in the first implementation.

## Update to the previous Gate 0 conclusion

`ADVISOR_SCNET2_SQUARE_RUNG_C_GATE0_RESULT_2026-07-29.md` correctly concluded
that:

- current D4-only Rung C, with sides `139,48,90,90,336`, is not affordable;
- completing only the missing D4 `E`-partner reduction, giving
  `139,48,90,90,168`, probably remains above the CPU-node memory budget.

Its further statement that spin reduction was necessarily a post-deadline
project is now outdated. At the time, the full generic spin pipeline was not
available on the Square branch. Commit `ede083b` has since integrated the
complete Shastry reduction implementation, its exact truth gates, JuMP
translations, builders, runners, and proof notes.

This does not invalidate Gate 0. It changes the available implementation
options after Gate 0.

## Why the spin reduction should transfer

### 1. The symmetry is exact for Square J1--J2

Each Square interaction is

```text
S_i . S_j = (X_i X_j + Y_i Y_j + Z_i Z_j) / 4.
```

It is invariant under global proper spin rotations. In particular, it is
invariant under the 24-element signed-axis rotation group used by the current
pipeline: the Klein four group of pi rotations followed by permutations of
the three axes.

The computational-basis conjugation step is also valid: it changes the sign
of each individual `Y`, while every Hamiltonian `YY` term contains two
`Y` factors.

### 2. The reduction modules are model-generic

The core modules operate on generic primal assemblies and basis rows:

- `ExactSymmetryReduction.jl`
- `ReducedPrimalGapAssembly.jl`
- `ConjugationSymmetryReduction.jl`
- `SpinAxisInvolutionReduction.jl`
- `FullSpinPermutationReduction.jl`
- `FullSpinConeReduction.jl`
- `FullSpinIsotypicReduction.jl`

They contain no Square-versus-Shastry dispatch or hard-coded Shastry model
test. The Shastry builder becomes model-specific when it constructs:

```julia
GapProblem(
    square_patch_geometry(1),
    shastry_sutherland_model(G_COUPLING),
    gamma,
    2;
    basis_mode=:structured,
    basis_spec=StructuredBasisSpec(:one_symbol_lift, 1),
)
```

The first Square prototype should replace the model with
`square_j1j2_model(1//2)` and update model-specific metadata, names, and
source/hash allowlists.

### 3. The implementation fails closed on the actual coefficients

Portability must not be accepted merely from the symmetry argument. The
existing builder checks, over exact arithmetic, the actual source passed to
it. Among other things, its gates test:

- Hamiltonian invariance;
- covariance of every retained positive- and gap-block coefficient;
- closure of the complete moment inventory;
- invariance of the equality row space;
- exact zero cross blocks;
- exact ranks of every change of row basis;
- exact congruence of redundant cones;
- the `W=3M` isotypic relation;
- two deterministic coefficient builds; and
- optimizer-free JuMP reconstruction.

Thus a hidden Square incompatibility should stop the build rather than
silently produce a smaller incorrect SDP.

## Expected reduction sizes

The following are the proved Shastry counts and the expected Square counts.
They are determined predominantly by the common patch, basis, and spin
action, but must still be regenerated and recorded for Square.

| Stage | Moments | Maximum PSD side | Packed real PSD entries |
|---|---:|---:|---:|
| Source | 74,602 | 703 | not the final real form |
| V4 spin + facial reduction | 19,108 | 109 | not yet realified |
| Conjugation / realification | 16,660 | 109 | 31,810 |
| Order-two spin-axis split | 8,803 | 81 | 16,707 |
| Full spin-permutation quotient | 3,250 | 81 | 16,707 |
| Redundant cone removal | 3,250 | 73 | 10,064 |
| Trivial isotypic split | 3,250 | 45 | 6,104 |

For comparison, D4-only Square Rung C had maximum side `336`, or `168` after
the unimplemented D4 partner reduction. The spin-isotypic representation is
not a marginal improvement; it changes the resource regime.

## Mathematical status

This route is an exact reparameterization of the finite relaxation, not a
restriction to a chosen physical spin sector.

The finite feasible set is convex and stable under the global spin group.
Given any feasible functional, averaging it over the finite rotation group
preserves normalization, stationarity, and all positive and gap PSD
constraints. Therefore the unrestricted feasible set is nonempty if and only
if its spin-invariant subset is nonempty. The subsequent block decompositions
and redundant-cone removals are exact congruence/isotypic operations, subject
to the truth gates above.

This statement concerns the declared finite relaxation only. It does not turn
finite-relaxation feasibility into a physical bulk-gap lower bound, and a
solver infeasibility status remains only a candidate until independently
certified.

## Worker implementation handoff

### P0: minimal Square spin-isotypic port

1. Start from
   `scripts/build_shastry_sutherland_full_spin_isotypic_reduced_mof.jl`;
   copy or generalize it under an explicitly Square name.
2. Fix the physical setup to:
   - model `square-j1-j2`;
   - `J1=1`, `g=J2/J1=1/2`;
   - `L=1`, `d=2`;
   - `one_symbol_lift/v1`;
   - gamma `0` for the first gate.
3. Replace all Shastry-only setup checks, result names, schemas, and source
   allowlists with explicit Square versions. Do not reuse stale Shastry
   model/runmeta hashes.
4. Run the complete six-layer exact truth chain on the Square source:
   - V4/facial;
   - conjugation;
   - spin-axis involution;
   - full spin permutation;
   - nontrivial cone redundancy;
   - trivial isotypic.
5. Require two deterministic builds, optimizer-free JuMP reconstruction,
   MOF write, independent reload, named-cone inventory, and complete
   checksums before attaching Mosek.
6. Compare the generated counts with the table above. Any failed exact gate,
   unexpected nonzero equality, changed cone inventory, or incomplete moment
   reconstruction is a stop-and-review event.

Do not add Square D4 to this first model. Global spin and spatial D4 commute
mathematically, but the current Square D4 and Shastry spin implementations are
different assembly paths. Combining them immediately adds proof and software
risk without being necessary for memory.

### P1: first numerical decision

1. Solve gamma `0` first as the equivalence and resource calibration gate.
2. Require the fixed setup, exact-reduction schemas/hashes, source hashes,
   reloaded cone inventory, solver status, and independent residual/PSD audit.
3. If gamma zero is clean and comfortably inside the resource limit, run one
   decision-relevant positive gamma point.
4. A reasonable coarse first point is gamma `2`, followed by bracketing only
   if it returns an audited infeasibility candidate. If the team prefers the
   more conservative sequence, run gamma `1/2` then `1` then `2`.
5. Stop if the tested positive points remain feasible and no transition is
   appearing. Do not spend the deadline accumulating many feasible rows.

The existing Shastry gamma-scan runner can guide the fail-closed structure,
but its model identity, source hashes, and expected coefficient hashes must be
Square-specific.

## Further reductions, ranked

### A. One spatial reflection after spin: optional, not needed initially

`SpatialReflectionReduction.jl` implements the anti-diagonal map

```text
(x,y) -> (-y,-x).
```

Square J1--J2 preserves this reflection, as well as the rest of D4. On the
Shastry isotypic model, the exact reflection gate reduced:

```text
moments                    3,250 -> 1,711
packed PSD entries         6,104 -> 3,191
maximum PSD side              45 -> 24
```

It produced 16 positive cones with sides
`21,15,21,15,21,15,24,21,22,15,21,15,21,15,24,21` and one scalar gap cone.
Because the action uses the same patch and basis, these are the expected
Square dimensions too. Nevertheless, the actual Square coefficient
covariance and equality gates must pass.

Use this only after the basic spin-isotypic gamma-zero build/solve works. The
side-45 model is already easily affordable, so reflection is a robustness or
performance improvement rather than an unblocker.

### B. Continuous `SO(3)` moments: scientifically valid, lower priority

The integrated continuous-spin moment gate maps the Shastry isotypic
inventory from `3,250` moments to `2,458` exact pivots. The same invariant
tensor argument applies to Square. However:

- fewer variables did not always mean less solver fill in the earlier stages;
- the separate theorem needed to remove two duplicate side-36 cones was
  source-prepared but not recorded as a passing Slurm truth gate; and
- neither reduction is needed to fit scnet2.

Do not make this the first Square port.

### C. Full spatial D4 combined with spin: post-deadline unless everything
else is complete

Square has more spatial symmetry than the Shastry window, so a full
`D4 x spin` decomposition can reduce the model further. It is likely the
best eventual representation, but the present code does not provide a
drop-in composition of the Square D4 quotient and full-spin isotypic
assembly. It would require new commuting-action, coefficient-reconstruction,
row-rank, and cone-cross-zero gates.

### D. Translation and chordal shortcuts: not recommended

- The fixed 3-by-3 local window is not invariant under nontrivial
  translations, so lattice translation symmetry does not give a direct
  finite-patch block decomposition.
- Chordal PSD decomposition is not automatically exact for a dense moment
  cone and should not be introduced as a deadline shortcut.
- A new first-order solver or tolerance campaign would weaken auditability
  and is unnecessary if the spin-isotypic port succeeds.

## Stop rules

Stop this route and reconsider if any of the following occurs:

1. a global-spin Hamiltonian, coefficient-covariance, inventory-closure, or
   equality-invariance truth gate fails on the Square source;
2. an exact row-basis rank, cross-zero, cone-congruence, or isotypic relation
   fails;
3. the reduced coefficient build does not reproduce the expected moment
   inventory or deterministic hashes;
4. the gamma-zero model fails preflight, reload, or residual audit for a
   scientific rather than interface reason;
5. the supposedly reduced gamma-zero solve unexpectedly approaches the
   scnet2 memory or time limit; or
6. the adaptation expands into a redesign of the reduction core rather than
   a model-specific builder/runner port.

One narrow interface repair with a targeted regression is reasonable. A new
symmetry theorem under deadline pressure is not.

## Final assessment

Confidence that Square Rung C can be made **computationally runnable** by this
port is high. Confidence that it will produce a nontrivial gap upper bound is
unknown: the relaxation may still be feasible at all useful gamma values.

The asymmetry in risk is favorable. The new path reuses already-integrated,
exactly gated machinery; the remote calculation should be small if the port
passes; and even a feasible result would determine whether the stronger
Square rung remains too weak. Therefore it is worth one tightly scoped
worker attempt before reconsidering the project direction.

No new computation was started for this advisory assessment.
