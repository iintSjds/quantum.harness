# Advisor current-status review

Date: 2026-07-29  
Branch reviewed: `challenge/polyopt-sdp-gap` at `79a1157`  
Review mode: static inspection only; no Julia, tests, solver, or numerical job
was run

## Executive assessment

The project has made a real transition from scaffolding to a runnable Square
J1-J2 SDP pipeline. The exact Hamiltonian/Pauli algebra, structured basis,
CoreMGK assembly, MOF export, and conservative solver-status handling are
substantial work. The D4 idea has also turned an otherwise intractable Rung B
calculation into a tractable one.

The scientific deliverable is not reached yet:

- there is no positive-`gamma` Square Rung B result;
- there is no Square infeasibility witness or certified upper bound;
- the completed remote D4 solve was generated before the moment-orbit quotient
  was implemented;
- the current quotient model has only a local build/reload report;
- the claimed exact equivalence of the D4 model is not covered by the current
  validation gates;
- the physical meaning of “D4 averaging without symmetry restriction”
  conflicts with both the local specification and Remark 2.7 of the source
  paper and needs an explicit resolution.

The honest headline is:

> A Square J1-J2 Rung B relaxation has become computationally tractable through
> D4 block compression. A `gamma=0` pre-quotient variant solved successfully,
> and a newer 1,831-variable moment-orbit quotient builds and reloads locally.
> No Square gap threshold or certificate has yet been obtained.

## Current status by layer

| Layer | Evidence currently present | Advisor assessment |
|---|---|---|
| Square model and normalization | Exact `J1=1`, `J2/J1=1/2`, `S=sigma/2` construction; local-buffer logic; ED/algebra checks | Strong prerequisite |
| Core moment/gap assembly | `CoreMGK.jl` and `SquareGapConic.jl`; exact rational coefficient construction; Hermiticity checks | Promising, but D4 covariance gates are missing |
| Rung A | `gamma=0,1/4,2` all `OPTIMAL` in about 1.5–2.3 s | Valid pipeline smoke; too weak to bound the gap |
| Unsymmetrized Rung B | 352-dimensional complex positive block; OOM/stalled on large nodes | Intractable on available hardware |
| Archived D4 Rung B | Job `23004880`, `gamma=0`, `OPTIMAL`, about 33.3 min, process high-water RSS about 86.6 GiB | Tractability/ground-state smoke only; not the quotient model and not a gap result |
| Current D4 quotient | 12,826 moments collapsed to 1,831 orbit variables; 4.1 MB MOF; local build/reload reported | Newest implementation, not yet remotely solved or equivalence-tested |
| Square certificate | Solver script records statuses but exports no Square ray/certificate | Not implemented |
| Requested observables/models | No Square Neel interval, Shastry-Sutherland result, or triangular result | Not started |

## P0 — correct before making or using a positive-`gamma` claim

### P0.1 The archived D4 solve is not the claimed exactly equivalent quotient

The evidence bundle
`evidence/square-d4-rungb-gamma0-23004880/` records that its MOF was built from
commit `695df27`, with:

```text
moment_count  = 12826
variable_count = 12826
```

The moment-orbit quotient was added later in commit `79a1157`. At `695df27`,
the D4 builder imposed the five diagonal congruence blocks
`Q_lambda' M Q_lambda` but retained independent, non-D4-identified moment
variables. It omitted the off-irrep blocks without first making `M` invariant.
Therefore that model was not an invertible reparameterization of the full
unsymmetrized moment constraint.

What is still true is useful:

- every full PSD moment matrix has PSD diagonal compressions;
- therefore the pre-quotient block model is a weaker, sound
  principal-compression relaxation;
- its successful `gamma=0` solve demonstrates tractability and exercises much
  of the build/solve path.

What is not supported:

- the evidence bundle's `equivalence_note`;
- the statement that matching the unsymmetrized `assembly_sha256` proves
  equivalence;
- treating job `23004880` as a solve of the current 1,831-variable quotient.

Required action:

1. Add a correction banner or replacement note to the archived evidence claim.
2. Describe job `23004880` as a **pre-quotient D4 block-compression smoke**.
3. Do not discard the evidence; its tractability result remains valuable.
4. Produce fresh evidence from current committed source for the quotient model.

### P0.2 Exact equivalence of the current quotient is plausible, not validated

The current builder checks that `Q' U(g) Q` is block diagonal for the group
representation. That validates the symmetry-adapted basis, not the assembled
SDP coefficients. The source comment in `SquareSymmetryBlock.jl` says four
exact CoreMGK invariance/covariance gates were checked, but no such checks are
present in the test suite or D4 scripts.

The build script also writes these booleans as literals:

```text
gate_1_hamiltonian_invariant = true
gate_2_basis_closed = true
```

rather than carrying computed gate results into the bundle.

Before calling the current model “exactly equivalent,” add exact regression
gates for:

1. group closure, site permutations, Hamiltonian invariance, and exact positive
   and gap basis closure;
2. moment-inventory orbit closure or a precise partial-orbit contract;
3. positive-matrix covariance under every D4 element;
4. `K`, `G_moment`, and `G_product` covariance under every D4 element;
5. closure/covariance of the stationarity equality space;
6. exact cancellation of every off-irrep coefficient after moment quotienting;
7. exact equality between the complete `Q' M Q` coefficient map and the union
   of the emitted diagonal blocks;
8. the unchanged gap block being genuinely the full A1 block;
9. a small fixture comparing the full and reduced models, including at
   nonzero `gamma`.

All coefficient comparisons should use the existing exact Gaussian-rational
representation. A floating `max_off_block=0.0` on `Q' U(g) Q` is not a
substitute for these assembly checks.

### P0.3 Resolve the theory/claim conflict around symmetry averaging

There are three incompatible descriptions in the repository:

- `square-j1j2-gap-sdp-spec.md` says imposing state symmetry changes the target
  to a symmetry-restricted bulk gap;
- the D4 design note initially says the same;
- the current builder/runmeta says D4 group averaging is exactly equivalent to
  the unrestricted relaxation and is not symmetry restricted.

The distinction matters because the source paper explicitly notes that the set
of locally non-degenerate `gamma`-gapped KMS states need not be convex. A group
average of symmetry-related pure gapped states can be a mixed, locally
degenerate state. Conversely, at the finite SDP-functional level, averaging a
feasible functional over a covariant finite group appears to preserve every
linear/PSD constraint.

The team must write a short lemma that states exactly which object is averaged:

- a physical KMS state;
- an evaluation functional generated by one state; or
- a relaxed state-polynomial functional/pseudo-moment sequence.

Then prove which conclusion follows. In particular, explain how the averaging
argument is reconciled with Remark 2.7 of `arXiv:2606.03836`, which presents
the invariance constraints as a physical state restriction. If the paper's
linear invariance constraints only enforce an invariant measure/relaxed
functional rather than support on fixed physical states, say so explicitly and
check with the challenge authors.

Until this is settled, use the neutral label:

> D4-averaged finite relaxation; physical symmetry interpretation under review.

Do not market a positive-`gamma` result as an unrestricted physical bound or a
symmetry-restricted physical bound merely from the current runmeta string.

## P1 — required for a defensible next result

### P1.1 Put the D4 work into the real test suite

The existing `test/runtests.jl` does not exercise `SquareSymmetryD4.jl`,
`SquareSymmetryBlock.jl`, `SquareGapConic.jl`, or the moment quotient. Current
D4 validation is in manually invoked smoke/check scripts.

Add regression tests covering at least:

- the expected orbit histograms and irrep dimensions;
- quotient idempotence and independence of group-element ordering;
- every original moment mapping to exactly one representative;
- rejection of incomplete/invalid permutation sets;
- exact coefficient gates listed in P0.2;
- deliberate corruption of one site permutation, one orbit mapping, one Q
  column, and one block coefficient;
- MOF reload after quotienting;
- `gamma=0` and `gamma>0` producing the expected coefficient differences.

### P1.2 `gamma=0` does not exercise the covariance term

At `gamma=0`, the `G_moment + G_product` part vanishes. The successful remote
solve therefore does not validate the most distinctive nonlinear
state-polynomial part of the gap condition.

Before an expensive scan, add a nonzero-`gamma` exact assembly regression that
checks selected `A_gamma = K - gamma G` entries against an independent symbolic
construction. Then run a very small number of declared Rung B probes; do not
start a dense scan until a transition appears.

### P1.3 Give the reduced model its own semantic manifest and hash

`assembly_sha256` currently identifies the unreduced 12,826-moment assembly.
It remains unchanged when the D4 transformation and quotient change, so its
agreement cannot validate the reduced MOF.

The reduced-model identity should hash:

- ordered D4 elements and site permutations;
- the exact rational Q matrix or a canonical sparse representation;
- block labels/ranges;
- ordered orbit representatives;
- the complete original-moment-to-representative mapping;
- the post-quotient coefficient map;
- normalization, stationarity, positive blocks, and gap block;
- source assembly hash and schema version.

Export a quotient-variable manifest mapping every `moment[i]` to its canonical
representative. The current `variable_order_contract = moment[1]...moment[n]`
does not say what the 1,831 variables mean.

### P1.4 Wire Square into the adopted certificate path

`solve_square_primal_mof.jl` records status and summary values only. An
infeasibility-certificate status would currently be classified as
`infeasibility_candidate_requires_ray_replay`, but no Square ray is exported
or replayed.

Before calling any threshold certified:

1. export the complete ray against the frozen reduced MOF;
2. replay it using the adopted independent MOF verifier;
3. bind the formulation manifest and reduced-model hash to the MOF;
4. use scale-aware numerical checks;
5. complete rational/interval post-processing for the final certified claim.

Until then, the strongest allowed language is “numerical status transition for
the declared finite relaxation.”

### P1.5 Refresh the canonical status documents

The top-level project documents are materially stale:

- `README.md` says the committed prototype does not assemble or solve an SDP;
- `validation-report.md` opens with “No state-polynomial SDP was assembled or
  solved”;
- the D4 design note says implementation is pending;
- several dated lead notes still say there is no Square status.

Keep dated historical notes, but add one canonical current-status page and
link it prominently from the README. It should distinguish:

- Rung A;
- unsymmetrized Rung B;
- pre-quotient D4 Rung B evidence;
- current quotient D4 Rung B;
- status-only, numerically audited, formulation-bound, and rigorous claim
  levels.

## P2 — engineering/provenance cleanup

- `Ion.lock` is modified at the review snapshot. Decide whether this is an
  intentional skill-sync update; otherwise keep it out of scientific commits.
- The archived `sacct-provisional.txt` was captured while the job was still
  `RUNNING`. Add final accounting if resource claims use Slurm evidence.
- The solver progress line reports `solve_form=dual` even when the metadata says
  `mosek_default`; make the log reflect the actual value.
- `D4Element` contains a mutable matrix and the quotient builder accepts an
  arbitrary permutation list. Defensively copy/validate these inputs or make
  their immutability an enforced contract.
- `orbit_seen` in `d4_moment_quotient` is unused.
- Checking only that the D4 basis and positive basis have the same length is
  insufficient. Compare their exact ordered entries or basis hash.
- A locally generated quotient runmeta was produced from a dirty pre-commit
  tree. Regenerate the durable bundle from a clean, pinned commit.

## Recommended worker sequence

1. **Correct the archived D4 equivalence claim.**
2. **Write and settle the D4 averaging/symmetry lemma.**
3. **Implement the exact coefficient-level D4 gates and corruption tests.**
4. **Add the reduced-model manifest/hash and quotient variable map.**
5. **Generate a clean current-head quotient bundle and rerun `gamma=0` remotely.**
6. **Run only a few nonzero-`gamma` Rung B probes** at `g=1/2`, after the
   independent `A_gamma` regression passes.
7. If a transition appears, **export/replay/post-process the witness** before
   using “certified.”
8. Only then extend to the requested Neel observable bounds and the next
   geometries.

## Acceptance checklist for the next advisor review

- [ ] Job `23004880` is no longer described as a solve of the quotient model or
      as an exact reparameterization.
- [ ] A written lemma resolves unrestricted versus symmetry-restricted
      semantics, with the source paper discrepancy addressed.
- [ ] D4 tests are part of the standard test suite, not only smoke scripts.
- [ ] Exact CoreMGK covariance and off-block cancellation tests pass.
- [ ] The reduced model has a versioned semantic hash and variable manifest.
- [ ] A clean pinned 1,831-variable quotient bundle is archived.
- [ ] At least one nonzero-`gamma` assembly is independently cross-checked.
- [ ] Any reported threshold uses three-way status semantics.
- [ ] Any “certified” claim has a formulation-bound, independently replayed,
      rigorously post-processed witness.
- [ ] README/current-status documentation matches the actual branch.

## Overall comment

The strongest part of the project is now the combination of exact symbolic
assembly, careful status semantics, and a concrete tractability breakthrough.
The main risk is no longer “can the team run Square J1-J2?” It is that a
compression result is promoted faster than its equivalence and physical
semantics are proved.

Pause the scan for one short hardening cycle. If the quotient passes the exact
gates above, the project will have a credible and efficient platform for the
first genuinely new Square result. If it does not, the failures will be found
before they contaminate an expensive scan or a final presentation.
