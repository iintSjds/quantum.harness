# Advisor handoff: Square Rung C full-spin experiment

Date: 2026-07-29

Decision: **stop this experiment and integrate the result.**

The full-spin-isotypic reduction makes Square Rung C inexpensive enough to
run, but the resulting finite relaxation is exactly feasible at
`gamma = 2`. It therefore supplies no useful Square gap upper bound through
gamma 2.

## What passed

The Square-specific port reused the existing six-layer spin-reduction
modules without changing their mathematics. On the actual Square
coefficients, all exact gates passed, including:

- global spin invariance;
- coefficient covariance under the spin actions;
- conjugation and equality-space invariance;
- all cross-entry-zero and cone-congruence checks;
- exact isotypic `W = 3M` relations;
- full retained-basis ranks;
- deterministic exact assembly; and
- optimizer-free construction followed by an independent MOF reload.

The final model has:

```text
source moments                         74,602
reduced variables                       3,250
real PSD cones                              9
positive sides             36,36,36,45,37,36,36,45
gap side                                     1
packed PSD entries                        6,104
maximum side                                 45
MOF size                            about 1.87 MB
```

This invalidates the old D4-only memory estimate as a practical resource
forecast: the complete build and solve remained below 1.3 GiB process peak
RSS and took only minutes on scnet2.

## Scientific result

The decisive floating-point run was:

```text
job                         118171150
gamma                       2
status                      OPTIMAL
primal / dual               FEASIBLE_POINT / FEASIBLE_POINT
audited violations          0
smallest reconstructed eig  0.01949018704413008
gap scalar                  0.06801361474504297
elapsed                     00:04:20
```

Job `118171424` then rounded the 3,250-coordinate solution to denominator
`10^6`, rebuilt all 6,104 entries from exact source coefficients, and
performed rational no-pivot LDL on all nine PSD blocks. All 308 pivots were
strictly positive. The exact one-dimensional gap pivot was

```text
4251 / 62500 = 0.068016.
```

Key certificate hashes:

```text
gamma-2 MOF
3310ea7c41b857223fe001e6bb3f9a64c75f187a33788585accbb10091055e68

gamma-2 floating values
5b4a9c8b93fc51d0033997e82404809b09136f0804ae3d987f48d2bcae3a43e2

exact replay
41b2ae3e761ce7a6e2b8c015d43d1e8af4098e61dad48a4b3658d2a2232e840a

rational witness
1c9106f4ea27aefcfc3eefb037350baa62745e79254d48115186003238455089
```

For the same functional, the gap block is

```text
G(gamma) = E - gamma C,
```

with `C` constrained positive semidefinite. Hence, for
`0 <= gamma_1 <= gamma_2`,

```text
G(gamma_1) = G(gamma_2) + (gamma_2 - gamma_1) C.
```

The exact witness at gamma 2 therefore proves nonemptiness of this finite
relaxation for every gamma in `[0,2]`. Intermediate scans cannot add
information.

This is a statement about feasibility of the declared finite relaxation. It
is **not** evidence that the physical bulk gap is at least 2.

## Integration source

The complete implementation, detailed advisor report, and compact evidence
bundle are pushed to:

```text
remote branch
scnet2: experiment/square-spin-isotypic-scnet2

e7c83b2  Square builder, solver, and Slurm runner
7064ad0  exact rational witness replay
b302f65  report and checksummed compact evidence bundle
```

The detailed tracked report on that branch is:

```text
tracks/polyopt/solutions/sdp-gap-seekers/
ADVISOR_SQUARE_RUNG_C_SPIN_EXPERIMENT_RESULT_2026-07-29.md
```

The evidence directory is:

```text
tracks/polyopt/solutions/sdp-gap-seekers/evidence/
square-spin-rungc-isotypic-20260729/
```

It includes run metadata, results, logs, Slurm accounting, the rational
witness, exact replay output, and `SHA256SUMS`. Large generated MOFs and
floating value tables are omitted from Git, but their hashes are recorded.

## Recommendation to the worker

1. Fetch and review the three commits above, then merge the experiment branch
   or cherry-pick the desired pieces.
2. Retain the Square builder, solver, and exact replay as a reproducible
   computational contribution.
3. Decide whether scnet2-specific Slurm wrappers belong in the PR or only in
   the reproducibility instructions.
4. Update the README/result table with the exact finite-relaxation negative
   result.
5. Phrase the conclusion narrowly: Rung C is exactly feasible through
   gamma 2 and hence gives no bound there.

Do not spend remaining deadline compute on intermediate gamma values, extra
spatial symmetry, or a gamma value above 2. Additional symmetry only reduces
the representation; it cannot turn this feasible relaxation into an
infeasible one. A future positive result would require a genuinely stronger
relaxation or additional valid physical constraints.
