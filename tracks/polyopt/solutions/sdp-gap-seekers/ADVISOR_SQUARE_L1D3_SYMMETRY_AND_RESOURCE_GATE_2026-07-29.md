# Advisor note: Square \(L=1,d=3\) symmetry and resource gate

Date: 2026-07-29  
Status: live experiment; update this note after the build/solve terminates

## Executive assessment

Trying Square \(L=1,d=3\) is reasonable overnight, but the current run does
**not** use every symmetry or every possible assembly optimization.

It does use all exact spin reductions already available in the
`GenericGapModel` pipeline and then the proven anti-diagonal spatial
reflection. This is a strong conservative route. It does not compose that
pipeline with the separately implemented full Square \(D_4\) machinery, and
the degree-two continuous-spin reducer cannot be reused at \(d=3\) without
new rank-six invariant-tensor work.

The recommendation is therefore:

1. let the current \(L=1,d=3\) build gate run;
2. solve it if the final reduced inventory fits comfortably;
3. do **not** interrupt it for a last-minute full-\(D_4\) or continuous-spin
   refactor;
4. treat a joint spin \(\times D_4\) reducer or direct orbit-reduced assembly
   as future work unless the present build hits a hard resource wall.

## What “\(L=1,d=3\)” means here

This run uses the challenge-style hierarchy parameters:

- patch level \(L=1\);
- polynomial degree \(d=3\);
- outer patch \(N_{\rm out}=(2L+1)^2=9\) sites;
- inner patch \(N_{\rm in}=(2L-1)^2=1\) site;
- structured `one_symbol_lift` basis;
- Square \(J_1\)-\(J_2\) model at \(J_2/J_1=1/2\);
- decision point \(\gamma=2\).

There is no bond dimension \(D\) or \(N\) hierarchy parameter in this
formulation.

The exact source inventory observed in job `118172784` is:

| quantity | value |
|---|---:|
| source scalar moments | 3,535,570 |
| positive PSD side | 5,239 |
| gap PSD side | 7 |
| stationarity equalities | 3 |
| source-assembly peak RSS | about 5.9 GiB |
| source-assembly elapsed | about 10 minutes |

This agrees with the independent combinatorial prediction
\[
q(9,6)+\binom{q(9,3)}2
=104680+\binom{2620}2
=3,535,570,
\]
where \(q(n,k)=\sum_{j=0}^k\binom nj3^j\).

## Symmetry actually used

The build applies these exact, truth-gated reductions in order:

1. Pauli-algebra canonicalization and exact source assembly;
2. \(V_4\) spin rotations plus facial reduction;
3. conjugation projection and realification;
4. an order-two spin-axis involution;
5. the full implemented spin-axis permutation action;
6. redundant spin-character cone removal;
7. trivial/standard spin isotypic splitting;
8. anti-diagonal spatial reflection
   \((x,y)\mapsto(-y,-x)\), including a moment quotient and PSD eigenspace
   splitting.

These stages check Hamiltonian invariance, coefficient covariance, equality
space invariance, closure, vanishing cross-blocks, and invertibility of the
change-of-basis maps where applicable. Thus the reduction is intended to be
an exactly equivalent reparameterization of the finite relaxation, not an
extra physical-state assumption.

## Symmetry and optimization not used

### Full Square \(D_4\)

Full \(D_4\) code exists in the repository and was validated for the older
Rung-B `SquareGapConic` pipeline. It is **not currently composed** with the
new exact full-spin/isotypic pipeline used by this \(L=1,d=3\) run.

The missing work is not merely changing a site map. A correct composition
must quotient moments by the joint commuting spatial/spin actions and split
each already spin-reduced PSD row representation into the five \(D_4\)
isotypic sectors (including the two-dimensional \(E\) irrep), with new exact
covariance and off-block-zero gates.

This could reduce the post-spin model by another factor of a few, but doing
it now would be a substantial, high-risk refactor. The current single
reflection already obtains the first roughly factor-two spatial reduction.

There is also a concrete scaling obstacle to applying the existing Rung-B
code directly: `SquareSymmetryBlock` materializes dense rational
\(n\times n\) change-of-basis and permutation matrices. That was acceptable
for the 352-row Rung-B basis, but \(n=5,239\) here would create more than
27 million rational matrix slots before coefficient assembly. A viable
\(L=1,d=3\) implementation should instead use sparse orbit/partner maps on
the already spin-reduced blocks.

### Continuous \(SU(2)\)/\(SO(3)\)

The repository's continuous-spin prototype is degree-two specific: it
handles invariant tensors only through rank four. At \(d=3\), moment-matrix
products reach rank six. Reusing the degree-two code would therefore be
mathematically incomplete. A valid extension needs rank-six invariant
tensors, exact dependence handling, and new truth gates.

### Direct reduced assembly

The current builder first materializes all 3,535,570 source moments and only
then takes symmetry quotients. A purpose-built direct orbit-reduced
assembler could avoid much of that intermediate work. This is probably the
best long-term performance optimization, but it changes core assembly logic
and needs equivalence checks against the existing exact path.

## Comparison with the reported SS \(L=3,d=2\)

Do not compare only the labels \(L,d\). If Shastry--Sutherland \(L=3,d=2\)
uses the same `one_symbol_lift` gap formulation and the same definition
\(N_{\rm out}=(2L+1)^2\), its formal inventory would be approximately:

| quantity | same-formulation SS \(L=3,d=2\) |
|---|---:|
| outer sites | 49 |
| inner sites | 25 |
| positive side | 21,463 |
| gap side | 151 |
| source moments | 75,252,682 |

That is far larger than the current Square \(L=1,d=3\) source. Consequently,
the claim that SS \(L=3,d=2\) is runnable likely refers to at least one
different convention: a selected/bare basis, an energy rather than gap SDP,
a different patch interpretation, or a more direct locality/symmetry
implementation.

Before using it as a benchmark, request these four fields from the SS run:

1. exact basis family/manifest;
2. outer and inner site counts;
3. scalar-moment variable count before and after symmetry;
4. PSD block side dimensions and whether it is a gap or energy problem.

Only after those match is “SS \(L=3,d=2\)” an apples-to-apples resource
comparison.

## Live experiment provenance

- branch: `experiment/square-l1d3-spatial-scnet2`
- builder commit: `7e5c43ca915ca532840a1a49cdfe07d48f4d131b`
- fail-closed solver commit prepared while building:
  `996e4e0`
- scnet2 build job: `118172784`
- resources: 32 CPUs, 110 GiB, 12-hour wall limit
- current stage at this note revision: exact \(V_4\) and facial reduction

The solver is intentionally not submitted until the builder has completed
all exact truth gates, written and reloaded the optimizer-free MOF, and
reported the final variable/block inventory.
