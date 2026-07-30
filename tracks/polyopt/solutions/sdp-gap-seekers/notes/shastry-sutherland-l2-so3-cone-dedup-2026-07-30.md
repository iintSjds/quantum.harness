# Shastry--Sutherland L=2 SO(3) cone-dedup decision

## Fixed target

- Model: unrestricted Shastry--Sutherland local KMS relaxation.
- Parameters: `L=2`, `d=2`, `g=4/5`, `gamma=2`.
- A retained formulation is exact only if both the stabilizer cross block and
  every proposed `l=2` cone congruence are reconstructed coefficient by
  coefficient after the exact SO(3) rank-four moment projection.

## Prior exact evidence

- SO(3) rank-four projection: 461,186 to 343,761 moment equations.
- Stabilizer coefficient gate: all 1,906,425 `l=1`/`l=2` cross entries are
  exactly zero.
- Stabilizer split inventory: 38 PSD blocks, 2,540,067 packed entries,
  maximum side 490, and coefficient hash
  `b4a9884636dcea65be67e60e6f2ef0dffe23812e1ab8e6bf5205f23f549874e5`.
- That formulation exhausted a 500,000-MiB cgroup during MOSEK's first
  factorization, before iteration zero.

## Current decision gate

SCNet job `118196521`, immutable source `6dd911f`, completed the full L=2
coefficient audit in 57:50 with 31,578,308 KiB peak RSS. It retained every
cone, reconstructed 940,050 mapped triangle entries, and checked exact
`T = D P R P^T D` congruence after SO(3) projection. The exceptional scale
was inferred from coefficient algebra; the Euclidean row-norm ratio was
diagnostic and did not authorize the scale.

All 12 blocks passed: 916,725 entries were directly equal and the exact
exceptional permutation resolved the remaining 23,325. Final unmatched and
opposite counts are both zero. The immutable runmeta SHA-256 is
`5dca02a5be9d0e368f8edaa43e7a448b78e72f9d3aecf38a7962ba42763defa7`.
This authorizes the separate build to remove the three nontrivial-character
`l=2` copies in each family/parity group.

## Verified reduced inventory

The separate full build reproduced the exact coefficient gate and emitted:

- 26 PSD blocks: 20 positive and 6 gap blocks;
- positive block dimensions
  `[485,485,440,440,490,460,490,460,490,460,336,335,290,290,315,310,315,310,315,310]`;
- gap block dimensions `[6,3,6,3,6,3]`;
- 343,761 moment variables;
- 10,375,308 scalar coefficient terms;
- 1,600,017 packed PSD entries;
- maximum side 490;
- coefficient-map SHA-256
  `ddd3795eb3b15034f2208f90fc98056fb8c63109852393def93d69fd7e17df1b`.

This is a 37.0% packed-entry reduction from the stabilizer-split model and is
exactly equivalent to it.

## Decision-solve outcome

The native affine-PSD primal task completed all coefficient gates, reproduced
the inventory and hash above, and reached solver presolve. It then exhausted a
114,000-MiB memory budget before interior-point iteration zero.

The deduplication is therefore valid but the current solve route is not yet
tractable at this memory scale. Reducing packed storage alone did not reduce
the maximum block side or the factorization fill sufficiently. The run
provides neither feasibility nor infeasibility evidence.

## Required next optimization

A subsequent solver attempt must change the factorization problem rather than
repeat this inventory at the same memory scale. Candidate directions are:

- an exact component or chordal decomposition with a full coefficient
  reconstruction gate;
- elimination or localization of globally coupled moment variables;
- a certificate-oriented formulation with a smaller Newton system.

The operational memory ceiling is approximately 114 GB. A viable next route
must fit below it; larger-memory execution is not an available fallback.
