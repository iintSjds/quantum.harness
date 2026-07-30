# Advisor plan: Square Rung C on scnet2

Date: 2026-07-29  
Local branch reviewed: `challenge/polyopt-sdp-gap` at `291d5db`  
Status: proposed for setup ratification; **no compute submitted**

## Recommendation

Use scnet2 for a bounded Square Rung C experiment in parallel with the
worker's conservative Shastry--Sutherland route. This is a sensible division
only if:

1. the submission does not depend on the Square result;
2. the Square experiment advances through explicit size/memory gates;
3. gamma zero is the only initially authorized solve point; and
4. a failed size gate is recorded as a result, not turned into an open-ended
   optimization project.

## Exact proposed setup

- Model:
  `H=(1/4) sum_J1 (XX+YY+ZZ) + (g/4) sum_J2 (XX+YY+ZZ)`.
- Couplings: antiferromagnetic `J1=1`, `g=J2/J1=1/2`.
- Geometry: the `L=1` local square patch
  `Lambda_1={-1,0,1}^2`, with one central inner site. This is a local
  consistency window, not a finite periodic or open-boundary lattice.
- Relaxation degree: `d=2`.
- Basis: `one_symbol_lift/v1`, with declared positive/gap dimensions
  `703/7`.
- State/sector: unrestricted KMS functional. D4 averaging and moment
  quotienting are exact reparameterizations of this finite relaxation, not a
  physical symmetry-sector assumption.
- Stationarity: `bare_inner_pauli/v1`, expected three nonzero real
  equalities.
- Target: feasibility of the finite relaxation at `gamma=0`.

This setup must be explicitly confirmed or corrected before an sbatch job is
submitted, per `AGENTS.md`.

## Live scnet2 audit

Read-only audit on 2026-07-29:

- SSH alias works: `scnet2`.
- Login host: `login09`.
- CPU partition: `kshcnormal`, state `UP`.
- Node shape reported by `sinfo`: 32 CPUs, 126,500 MB, i.e. about 123.5 GiB.
- Partition default memory: 3,569 MB/CPU.
- User queue was empty at inspection time.
- Working clone branch: `challenge/polyopt-sdp-gap`.
- Working clone head: `8f38f86`.
- Bare-repository branch head: `79a1157`.
- Both remote revisions are stale relative to local `291d5db`; code must be
  pushed and the working clone fast-forwarded before any run.
- The remote working clone has many old untracked scripts/logs. They must not
  be deleted or included in provenance commits. Result paths must be unique.

The old remote Git does not support `git -C` or
`git branch --show-current`; operational scripts must use `cd` and
`git symbolic-ref --short HEAD`.

## Why a direct solve is not justified yet

Measured Square Rung B D4 results provide the closest empirical baseline:

- positive basis dimension `352`;
- positive D4 side dimensions `70,24,45,45,168`;
- D4 quotient variables about `1,831--1,837`;
- peak node memory about `74--87 GiB`;
- solve wall about `24--28 min` on 32 CPUs.

Rung C doubles the positive basis dimension to `703`, increases the
unreduced source moments to `74,602`, and previously exhausted or stalled on
an approximately 486-GiB node without the Square D4 reduction. A naive
dense-cone cubic extrapolation from Rung B therefore exceeds scnet2's memory
by a large margin. It would be irresponsible to submit the solve blindly.

## Important implementation finding

The current Square D4 code does not yet accept `one_symbol_lift` in
`build_square_d4_conic_mof.jl`; only the command-line allowlist blocks it.
The underlying generic assembly and D4 routines appear compatible, but that
must be validated.

There is also an unused exact reduction opportunity:

- `SquareSymmetryD4.irrep_multiplicities` correctly states that the two-
  dimensional `E` isotypic component is
  `C^2 tensor C^n_E` and, by Schur's lemma, needs one `n_E x n_E` PSD cone.
- `SquareSymmetryBlock` and `SquareGapConic` currently emit the full
  `2 n_E x 2 n_E` E-isotypic cone. For Rung B that is side `168`, although
  the fully reduced side would be `84`.

This is not a correctness bug in existing results: the larger cone is an
exact but redundant representation after the D4 moment quotient. It is a
material efficiency gap. Removing the redundancy could reduce the E-cone
factorization cost by roughly a factor of eight, but a rushed implementation
must not be trusted without exact off-partner, equal-partner, and reconstruction
gates.

## Gated experiment

### Gate 0 -- basis-only exact sizing

Run no solver and build no conic model. Compute:

- D4 fixed counts and exact irrep multiplicities for the Rung C positive
  basis;
- current emitted block sides
  `n_A1,n_A2,n_B1,n_B2,2 n_E`;
- fully Schur-reduced candidate sides
  `n_A1,n_A2,n_B1,n_B2,n_E`;
- `sum side^2` and `sum side^3` ratios against measured Rung B.

This is the cheapest reliable feasibility estimate.

### Gate 1 -- solver-free source/D4 model build

Proceed only if Gate 0 is compatible with the node budget. Extend the
builder allowlist to `one_symbol_lift`, then assemble at `gamma=0` and retain:

- source and reduced semantic hashes;
- exact coefficient/covariance gates;
- D4 block sizes;
- original and quotient moment counts;
- MOF size and reload verification;
- per-stage wall time, allocations, and process high-water RSS;
- final Slurm accounting.

No optimizer is attached at this gate.

Suggested resource cap: 32 CPUs, at most 110 GiB requested/usable memory,
and a 60-minute wall limit. Keep at least about 13 GiB node headroom.

### Gate 2 -- attach-only inventory

Proceed only if Gate 1 peak RSS and cone-size ratios leave credible headroom.
Attach Mosek, write the pre-optimization inventory, then exit before
`optimize!`. Because solver attachment can expand the affine-conic
representation substantially, this must be a separate killable job.

Suggested stop rule: do not solve if attach peak RSS exceeds 90 GiB or if the
process is already growing toward the node limit.

### Gate 3 -- one gamma-zero solve

Proceed only after reviewing Gates 0--2. Run exactly one feasibility solve at
`gamma=0`, with 32 threads and a hard wall limit. Preserve raw MOI/Mosek
statuses and treat timeout, OOM, or interrupted presolve as `unknown`, never
as infeasible.

No positive-gamma point is part of this authorization. If gamma zero is a
clean feasible candidate and resource use is comfortable, choose a positive
gamma only after comparing the scientific value against final packaging time.

## Stop rules

Stop the Square lane immediately if any of the following occurs:

- exact D4 closure/covariance/congruence gate fails;
- predicted memory lacks at least roughly 10% node headroom;
- solver-free build approaches the node limit;
- Mosek attach exceeds 90 GiB RSS;
- gamma zero is unknown, times out, or is OOM-killed;
- fixing the experiment begins to compete with submission integration and
  writeup.

## Strategic assessment

This parallel lane has asymmetric value:

- best case: it establishes that Rung C is tractable after exact spatial
  reduction and gives the first stronger Square data point;
- useful negative case: exact dimensions and measured resource failure define
  the next computational bottleneck reproducibly;
- worst case, if ungated: it consumes the remaining deadline window in an OOM.

Therefore the experiment is recommended, but only in the sequence
`basis sizing -> solver-free build -> attach -> gamma-zero solve`, with a
review between gates.
