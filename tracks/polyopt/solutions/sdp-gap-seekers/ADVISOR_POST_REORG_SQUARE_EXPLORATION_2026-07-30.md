# Advisor report: post-reorganization Square exploration

Date: 2026-07-30 (CST)

Purpose: record the theory/code audit, the decision between further Square
J1-J2 and triangular exploration, the live remote jobs, and the conditions
under which any result is worth handing to the submission worker.

## Executive decision

Continue with Square J1-J2, not triangular, for the two speculative compute
slots.

The primary deliverable remains the already working, reproducible `L=1,d=2`
Square result. Neither experiment below should delay or destabilize that
submission. The experiments are isolated from the submission checkout and
must be merged only if they produce a complete, checksum-bound artifact with
an honest result interpretation.

The two current experiments are:

1. salvage Square `L=1,d=3` at the last symmetry reduction whose exhaustive
   truth gate actually passes;
2. measure the terminal proven inventory for Square `L=2,d=2` using the same
   one-symbol basis and reduction chain.

Both are build/audit jobs first. A solver job is conditional.

## Repository snapshot reviewed

The worker reorganized the main integration branch and then landed the
submission documentation commit:

```text
5df3534 submission: rewrite README around the d=2 result + land docs + gamma-feasibility figure
0abbb30 merge Sihan SS latest ... dynamic L=2 path + SO(3)/stabilizer work
60b8455 merge advisor Square Rung C ... L=1/d=3 ... degree-generic gate fix
```

The main checkout was clean when this note was written. All advisor compute
changes were made in separate worktrees and experiment branches.

## Recent hackathon-chat evidence

The recent group messages support the following facts:

- the public challenge/PR snapshot contains the Square `L=1,d=2` result,
  triangular `L=1,d=2`, and the advisor's initial `L=1,d=3` code;
- Sihan's SS `L=2,d=2` formulation has 343,761 matching equations, 38 PSD
  blocks, 2,540,067 packed PSD entries, and maximum side 490, and Mosek failed
  during factor fill before iteration zero;
- Sihan correctly warned that the old `[1,81,81]` inventory is an `L=1,d=2`
  regression fixture, not a general theorem;
- a valid general reduction gate must prove covariance/coverage, exact
  congruence, zero cross blocks, invertibility, phase consistency, and
  reconstruction, rather than compare against one historical dimension list.

Important qualification: the triangular one-symbol `L=2,d=2` builder is not
the same basis construction as Sihan's dynamic full-state SS `L=2,d=2`
builder. Therefore the SS terminal inventory cannot be copied over as a
measured triangular inventory. The earlier triangular diagnostic never
reached a final reduced block report. It is reasonable to expect a difficult
solve, but it is not correct to claim that its final size was proved equal to
the SS size.

## Newly discovered L1d3 bug

### Observed failure

Corrected scnet2 build job `118196332` reproduced the full chain through the
exact full-spin cone reduction and then failed:

```text
ERROR: unexpected trivial-character S3 row-orbit size
FullSpinIsotypicReduction.jl:219
```

The dependent solve job `118196351` was cancelled by dependency and produced
no solver result.

The last successfully audited L1d3 inventory was:

```text
source moments       = 3,535,570
source positive side = 5,239
source gap side      = 7
source equalities    = 3

full-spin moments    = 118,708

cone positive sides  = 324,288,288,381,325,288,288,381
cone gap sides       = 1
maximum cone side    = 381
packed cone entries  = 417,632 (including the 1x1 gap block)
```

Peak recorded build-process RSS was about 4.8 GiB in Slurm accounting; the
in-process high-water report during the reduction was about 6.6 GiB. The
difference is an accounting/reporting detail, not a scientific issue.

### Root cause

The first generalization in `f85e12b` removed two invalid *dimension locks*,
but it did not make the terminal isotypic algorithm general.

`FullSpinIsotypicReduction.isotypic_rows` still accepts only S3 row orbits of
size one or three. For each size-three orbit it hardcodes the basis

```text
t = (1,1,1)
w = (1,1,-2)
m = (1,-1,0)
```

and proves the degree-two-specific proportionality relation between the two
standard directions. L1d3 contains at least one orbit outside this accepted
`1/3` pattern.

This is not safe to repair by merely allowing another orbit size. General S3
actions can have orbit sizes 1, 2, 3, or 6, with different trivial, sign, and
standard-isotypic multiplicities. A correct extension needs an exact rational
representation decomposition plus the same fail-closed cross-block,
congruence, rank, phase, and reconstruction checks. Until that exists:

- do not call the L1d3 isotypic or spatial-reflection model exact;
- do not weaken the gate;
- do not interpret job `118196332` as a physical feasibility result;
- use the cone-reduced assembly as the last currently proved endpoint.

The anti-diagonal spatial reducer is currently typed on the isotypic assembly,
so it cannot simply be applied to the cone assembly without a separately
audited implementation.

## Safe fallback implemented

Two isolated commits export a MOF immediately after the proved full-spin cone
gate and return before the unsupported isotypic/spatial code:

```text
3aa5dcf experiment: add fail-closed Square L2d2 cone build
40c49c5 experiment: salvage Square L1d3 at proven cone gate
```

The exported run metadata records:

- Git commit/tree and source-file hashes;
- Square J1-J2 setup, `J2/J1=1/2`, gamma, `L`, `d`, and
  `one_symbol_lift/v1`;
- source and reduced assembly hashes/inventories;
- exhaustive truth-gate flags through the cone reduction;
- MOF checksum, reload verification, timings, and memory observations.

These commits are experiment-only and intentionally do not modify the main
submission checkout.

## Live jobs and provenance

### scnet: Square L2d2 cone audit

```text
job                 = 23018668
state at last check = RUNNING
Git commit          = 3aa5dcf
branch on scnet     = experiment/square-l2d2-cone-advisor
checkout            = /work/home/iint_sjds/quantum.harness-square-l2d2-cone-3aa5dcf
run id              = square-l2d2-cone-gamma2-20260730-r1
resources           = 32 CPUs, 3800 MiB/CPU, 12 h
```

The source inventory has already been reproduced:

```text
moments       = 4,941,226
positive side = 5,551
gap side      = 55
equalities    = 351
peak RSS      = about 6.6 GiB after source assembly
```

It was in exact V4/facial reduction at the last check.

### scnet2: Square L1d3 cone salvage

```text
job                 = 118201670
state at last check = RUNNING
Git commit          = 40c49c5
branch on scnet2    = experiment/square-l1d3-cone-advisor
checkout            = /public/home/iint_sjds/quantum.harness-square-l1d3-cone-40c49c5
run id              = square-l1d3-cone-gamma2-20260730-r2
resources           = 32 CPUs, 110 GiB, 12 h
Julia project       = /public/home/iint_sjds/quantum.harness/julia-env
```

The Julia load/help preflight passed before this job was submitted.

### Non-scientific failed submission

Job `118201293` used a fresh clone's `julia-env`, which contained
`Project.toml` but no manifest, and failed in 12 seconds because JuMP was not
available. It was cancelled/retired and has no scientific meaning. The
corrected job uses the manifest-backed main environment listed above.

## Solver go/no-go gate

Do not submit a solve merely because a build exits zero. Require all of:

1. every truth gate through the cone reduction is exactly true;
2. MOF write, reload, dimension checks, and SHA256 manifest pass;
3. `runmeta.toml` matches the intended `L`, `d`, gamma, basis, and Git commit;
4. terminal block count, maximum side, packed-entry count, and equality count
   are recorded;
5. the estimated solve fits the remaining deadline and memory envelope.

For L1d3, the known 417,632 packed entries and maximum side 381 are well below
the failed SS L2 inventory of 2,540,067 entries, but this is only a coarse
screen. Mosek factor-fill memory depends on affine sparsity and elimination
structure, so the comparison does not guarantee success. One bounded solve is
worth trying if the MOF artifact passes.

For L2d2, wait for the measured terminal cone inventory. If it approaches the
SS factor-fill scale, stop at the build/audit artifact. If it is comparable to
or smaller than L1d3, one bounded gamma-2 solve is reasonable.

Use conservative result semantics:

- `OPTIMAL`/`FEASIBLE_POINT`: gamma is feasible for this finite relaxation;
- decisive infeasibility with adequate certificates/residual evidence:
  candidate upper threshold for this relaxation;
- OOM, time limit, numerical failure, or pre-iteration factor-fill failure:
  unknown, never infeasible;
- a feasible gamma value is not a proved lower bound on the physical gap.

## Why triangular is not the next slot

Triangular `L=1,d=2` has already passed the exact reduction gates and was
feasible at tested gamma values 0, 1, and 2. That says the rung is too weak to
locate a threshold.

Triangular `L=2,d=2` may still be worth a later inventory-only diagnostic, but
today it loses to Square for three reasons:

1. the Square target is directly aligned with the main challenge submission;
2. the Square L1d3 run exposed a concrete, repairable hierarchy/reduction
   boundary and already provides a measured cone inventory;
3. the triangular L2 terminal inventory remains unmeasured, while the deadline
   makes another long truth-gate build less likely to improve the deliverable.

## Handoff instructions

When harvesting:

```bash
ssh scnet  'sacct -j 23018668 --format=JobID,State,Elapsed,MaxRSS,ExitCode -P'
ssh scnet2 'sacct -j 118201670 --format=JobID,State,Elapsed,MaxRSS,ExitCode -P'
```

Read each `slurm-<job>.out`, the per-run `build.log`,
`build-process-time.txt`, generated `runmeta.toml`, and `SHA256SUMS`.

If a build succeeds, first write a result note containing the complete
inventory and truth/replay checks. Only then prepare a solver commit/job.

Do not merge either experiment into the submission PR merely because the code
loads. Merge only a small, reviewed subset that is backed by a completed
artifact and improves the final story without displacing the stable d=2
result.
