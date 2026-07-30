# Shastry--Sutherland bulk-gap SDP: progress summary

## Headline

For the infinite Shastry--Sutherland model at `g = 4/5`, the complete
`L=1,d=2` KMS-ground-state relaxation is feasible throughout the tested
gamma range. The correct conclusion is that this hierarchy level is too weak
to constrain the physical bulk gap, not that the model has a very large gap.

The main contribution so far is the exact reduction machinery that makes
stronger relaxations accessible. The current stretch target is the first
decision-relevant `L=2,d=2` result.

## Result at `L=1,d=2`

The relaxation remains feasible through all tested values up to `gamma=256`.
An exact rational witness independently proves finite-level feasibility at
`gamma=1/2`.

The feasible solutions approach the SDP boundary as gamma grows, consistent
with a pseudo-moment escape direction. Continuing to scan gamma at fixed
`L=1,d=2` therefore has little value. Accuracy must instead be improved by
increasing the spatial window `L` or polynomial order `d`.

This is a finite-relaxation result. It is neither a measured physical gap nor
a certified nonzero lower bound.

## Method contribution

The original complete-state SDP is reduced through exact spatial and spin
representation theory. Each reduction is checked coefficient by coefficient
and preserves the unrestricted finite relaxation; it does not assume a
symmetry-broken or symmetry-invariant physical state.

At `L=1,d=2`, this produces a compact native affine-PSD model whose independent
assemblies agree exactly and whose numerical solution passes residual checks.
The same reduction framework depends mainly on the patch, basis, and spin
symmetry, so substantial parts transfer to other isotropic Heisenberg
geometries.

At `L=2,d=2`, three exact ingredients have now been composed:

1. an SO(3) rank-four moment quotient;
2. a stabilizer decomposition of the nontrivial spin sectors;
3. coefficient-level congruence and deduplication of repeated SO(3) `l=2`
   cones.

The last step reduces the exact cone inventory from 38 to 26 PSD blocks and
the packed cone entries by 37%, from 2,540,067 to 1,600,017, without weakening
the relaxation.

An earlier shortcut based only on row-norm ratios was rejected. The accepted
deduplication derives the exceptional scaling from the coefficient algebra
and closes every proposed congruence exactly.

## Current stretch result

The exact cone-deduplicated `L=2,d=2` model now builds reproducibly, and
independent assemblies have the same complete coefficient fingerprint.
However, the resulting native affine-PSD solve still exhausts a 114 GB memory
budget immediately after presolve and before the first interior-point
iteration.

The 37% reduction in packed cone entries is therefore mathematically valid but
not yet sufficient to make the `L=2,d=2` decision problem tractable. It leaves
the maximum block side at 490 and does not reduce sparse KKT fill enough.

This failure gives no feasibility or bulk-gap conclusion. The current
deduplicated implementation should be described as a verified reduction and
an incomplete solver route, not as a working `L=2` solution.

Further progress requires an algorithmic reduction of the factorization graph:
for example an exact component/chordal decomposition, fewer globally coupled
moment variables, or a certificate-oriented formulation. A larger-memory run
can measure the remaining requirement but does not replace this optimization.

## Submission boundary

The defensible result today is:

- `L=1,d=2` is demonstrably too weak for the Shastry--Sutherland bulk gap;
- a reusable chain of exact symmetry reductions has been implemented and
  independently checked;
- exact `L=2,d=2` cone deduplication substantially reduces the stronger
  problem;
- the current deduplicated solver route remains memory-intractable and needs
  further factorization-level optimization;
- no nonzero physical bulk-gap certificate has yet been obtained.

The submission should lead with the finite-level physics conclusion and the
general exact-reduction machinery. It must not present the current `L=2,d=2`
route as solved.
