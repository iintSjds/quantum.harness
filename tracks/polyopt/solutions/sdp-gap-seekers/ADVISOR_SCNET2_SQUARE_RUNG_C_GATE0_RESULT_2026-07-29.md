# Advisor report: scnet2 Square Rung C Gate 0

Date: 2026-07-29  
Experiment branch: `experiment/square-rungc-scnet2`  
Sizing commit: `d7078f1091cf377cfc3431931a5aab574199c1a0`  
Slurm job: `118169776`  
Decision: **stop before conic construction or optimization**

## Bottom line

The exact D4 representation sizing gate falsifies the premise that the
current Square Rung C model can fit scnet2's ordinary CPU nodes.

The current implementation would emit positive PSD cone sides

```text
139, 48, 90, 90, 336
```

for Rung C, compared with

```text
70, 24, 45, 45, 168
```

for measured Rung B. The sum of squared cone sides is `3.9926x` Rung B and
the sum of cubed sides is `7.9889x`. Scaling the measured Rung B memory range
of `74--87 GiB` by the squared-side ratio gives a screening estimate of
`295--347 GiB`.

scnet2 `kshcnormal` nodes contain about `123.5 GiB` physically, and the
partition's `DefMemPerCPU=3569 MB` with 32 CPUs limits a normal allocation to
about `111.5 GiB`. There is no credible headroom. Per the predeclared stop
rule, no Rung C conic build, Mosek attachment, or solve was submitted.

## Confirmed setup

- Hamiltonian:
  `H=(1/4) sum_J1(XX+YY+ZZ)+(g/4) sum_J2(XX+YY+ZZ)`.
- Antiferromagnetic `J1=1`, `g=J2/J1=1/2`.
- Local patch `Lambda_1={-1,0,1}^2`, one central inner site.
- `L=1`, `d=2`.
- Rung C basis `one_symbol_lift/v1`.
- Positive/gap dimensions `703/7`.
- Unrestricted finite KMS relaxation with exact D4 averaging/quotienting.
- Gate target `gamma=0`; no optimizer was attached.

## Gate 0 evidence

The job completed normally:

```text
State       COMPLETED
ExitCode    0:0
Elapsed     00:00:22
MaxRSS      362400K
CPU         1
```

The Julia calculation itself reported `0.99 s` sizing wall and `346780 KiB`
process high-water RSS. The remaining job time was startup overhead.

The result bundle's declared checksums all pass. The run used a clean source
tree and recorded:

```text
git commit  d7078f1091cf377cfc3431931a5aab574199c1a0
git tree    3d7b7e18adfa7386950f76f2f6d2a399b7506502
dirty paths []
```

Durable local artifacts:

```text
results/square-rungc-d4-sizing-118169776/
```

Important files:

- `sizing.toml`: exact dimensions, characters/fixed counts, orbit counts,
  ratios, and setup;
- `slurm.out` / `slurm.err`: full run transcript;
- `SHA256SUMS`: checksums for the fetched original bundle;
- `sacct-final.txt`: final accounting collected after completion.

## Exact representation results

### Rung B baseline

```text
positive dimension        352
gap dimension             4
D4 multiplicities         A1=70, A2=24, B1=45, B2=45, E=84
current emitted sides     70,24,45,45,168
complete-Schur sides      70,24,45,45,84
```

The emitted sides reproduce the existing measured Rung B result exactly,
which is a fail-closed baseline check for the sizing calculation.

### Rung C

```text
positive dimension        703
gap dimension             7
D4 multiplicities         A1=139, A2=48, B1=90, B2=90, E=168
current emitted sides     139,48,90,90,336
complete-Schur sides      139,48,90,90,168
```

The Rung C basis is exactly D4 closed. Its fixed counts are:

```text
e=703, r2=31, r1=r3=7,
sigma_x=sigma_y=sigma_d=sigma_d'=91
```

Its basis-orbit histogram is:

```text
size 1: 7 orbits
size 2: 12 orbits
size 4: 72 orbits
size 8: 48 orbits
total: 139 orbits
```

## Full Schur reduction assessment

The current D4 implementation retains the full two-dimensional `E` isotypic
space as one side-`2 n_E` cone. Schur's lemma permits an exact equivalent
side-`n_E` cone after the appropriate partner-space construction and exact
gates.

For Rung C this would replace side `336` with side `168`, producing:

```text
139,48,90,90,168
```

Relative to the *measured current Rung B formulation*, this still has:

```text
sum(side^2) ratio = 1.7496
sum(side^3) ratio = 1.7035
memory screening estimate = 129--152 GiB
```

That estimate remains above the roughly `111.5 GiB` normally allocatable on
`kshcnormal`, before reserving safety headroom. Therefore implementing only
the missing `E`-partner reduction does not make a scnet2 CPU solve a
responsible overnight launch.

This is a resource conclusion, not a proof that Mosek would consume exactly
the screening estimate. The estimate is sufficient for the negative launch
decision because even its optimistic endpoint exceeds the scheduler budget.

## High-memory partition check

scnet2 also exposes `ksagnormal01`:

```text
64--72 CPUs
about 1,031,000 MB RAM per node
8 RTX 4090 GPUs per node
DefMemPerCPU=15917 MB
```

The account can pass a Slurm test-only request only when at least one GPU is
requested. Without a GPU, the scheduler rejects the request with
`QOSMinGRES`.

With `--gres=gpu:1`, Slurm accepted the test-only shape but estimated:

```text
start time  2027-02-18T14:48:29
node        gnode39
```

This is not an affordable deadline resource. No real high-memory job was
queued.

## Coding findings

1. `build_square_d4_conic_mof.jl` does not currently allow
   `one_symbol_lift` at its command-line boundary, although the lower-level
   basis and D4 code is generic.
2. The documentation in `SquareSymmetryD4.irrep_multiplicities` describes the
   fully reduced side-`n_E` cone, but `SquareSymmetryBlock` /
   `SquareGapConic` currently emit side `2 n_E`.
3. This is an efficiency gap, not a correctness defect in the existing Rung B
   results: the larger `E` cone is redundant but exact after D4 moment
   quotienting.
4. The repository Slurm helper assumed Python 3.11's `tomllib`, while this
   environment uses Python 3.10. The isolated experiment branch adds the
   narrow `tomli` fallback. This helper compatibility change is unrelated to
   the scientific model.

## Recommendation

Do not pursue Square Rung C further before the deadline on scnet2.

The next viable Square implementation would need more than the missing D4
`E`-partner reduction—most likely an audited spin-rotation reduction combined
with D4, comparable in strength to the collaborator's Shastry--Sutherland
isotypic machinery. Implementing and proving those exact covariance,
congruence, partner-equality, and reconstruction gates is a post-deadline
project.

Return this agent lane to submission review, harvesting, and integration.
The worker's conservative Shastry--Sutherland route remains the only
deadline-compatible compute route.
