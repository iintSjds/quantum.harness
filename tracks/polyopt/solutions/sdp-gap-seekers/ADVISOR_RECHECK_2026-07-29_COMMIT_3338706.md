# Advisor recheck — latest worker update

Date: 2026-07-29  
Branch: `challenge/polyopt-sdp-gap`  
Reviewed HEAD: `3338706`  
Previous review point: `79a1157`  
Review mode: static inspection only; no Julia, tests, gate script, solver, or
numerical job was run by the advisor

## Bottom line

The worker made meaningful progress:

- the old pre-quotient equivalence overclaim is explicitly corrected;
- exact coefficient-covariance gate code was added;
- the current 1,831-variable moment-quotient model was solved remotely at
  `gamma=0`;
- job `23005746` returned `OPTIMAL / FEASIBLE_POINT` in about 28.4 minutes with
  process high-water RSS about 86.5 GiB;
- the quotient MOF and evidence bundle are committed and hash-bound.

This closes the question “can the current quotient model reach a clean
`gamma=0` solver status?” The answer is yes.

The update is not ready for positive-`gamma` scientific use yet. The hardening
commit introduced an accidental duplicated/nested block of gate functions
inside `d4_positive_block_matrix`, the gate runner is fail-open, the exact gate
output is not archived, and the physical symmetry/group-averaging issue remains
unresolved. These are small enough to repair quickly, but they should be fixed
before launching the deadline-critical probes.

## What was fixed well

### 1. The old evidence is now honestly corrected

`evidence/square-d4-rungb-gamma0-23004880/CORRECTION.md` accurately states that
job `23004880` was:

- pre-quotient;
- a weaker sound principal-compression relaxation;
- a tractability smoke;
- not an exact reparameterization of the full Rung B moment constraint.

This addresses the previous P0.1 finding. Keeping the old evidence while
correcting its interpretation is the right choice.

### 2. The current quotient model has a genuine remote solve

The new bundle
`evidence/square-d4q-rungb-gamma0-23005746/` identifies:

```text
source commit              = 79a1157
gamma                      = 0
original moment inventory  = 12826
quotient variables         = 1831
positive D4 blocks         = 70, 24, 45, 45, 168
gap block                  = 4
MOF SHA-256                = 56bdd76e...
termination                = OPTIMAL
primal status              = FEASIBLE_POINT
solve wall                 = 1701.65 s
process high-water RSS     = 90748332 KiB
```

The classification `feasible_candidate` is conservative and appropriate. This
is a successful ground-state/pipeline smoke, not a gap bound.

### 3. The covariance gates target the right mathematical objects

The new code checks:

- moment-inventory D4 closure;
- exact positive-moment coefficient covariance;
- exact `K`, `G_moment`, and `G_product` covariance;
- orbit-aggregated cancellation in sampled off-irrep entries.

Separately checking the three gap components is better than merely comparing
one numerical `A_gamma` matrix. It ensures the covariance term is present in
the audit even though the archived solve used `gamma=0`.

### 4. The worker did not hide the remaining provenance gap

Commit `3338706` explicitly says:

- the archived assembly hash is the unreduced hash;
- a reduced-model hash remains open;
- the solve was generated at `79a1157`, before the gate commit;
- a clean pinned follow-up remains desirable.

That is good claim discipline.

## P0 — repair before any new solver launch

### P0.1 Accidental gate-code insertion inside the model builder

In current `src/SquareGapConic.jl`, lines approximately 694–818 contain one
copy of:

- `_m_component`;
- `_covariant_match`;
- `gate_moment_closure`;
- `gate_positive_m_covariance`;
- `gate_gap_covariance`;
- `gate_off_irrep_cancellation`.

This copy is textually inside the nested loops of
`d4_positive_block_matrix`. A second, different copy appears at module scope
around lines 986–1102.

Consequences:

- current HEAD is not the same builder source that generated job `23005746`;
- the nested definitions are dead/accidental work inside a hot assembly loop;
- the first off-irrep implementation checks raw coefficients, while the later
  global implementation correctly checks orbit-aggregated coefficients;
- maintenance and dispatch behavior are ambiguous;
- the gate run does not exercise `d4_positive_block_matrix`, so a passing gate
  transcript would not catch this builder regression.

Required repair:

1. Remove the complete nested copy from the builder.
2. Keep one global implementation of each gate.
3. Restore the original loop indentation and `end` structure.
4. Review the resulting diff against `79a1157` to confirm that only deliberate
   gate functions remain.
5. Build the MOF from the repaired clean head and confirm its SHA-256 matches
   `56bdd76e...` for the same inputs before spending solver time.

The archived `79a1157` MOF remains valid evidence for the algorithm at that
commit. This finding concerns current HEAD and future runs.

### P0.2 The gate runner is fail-open

`scripts/check_d4_coefficient_gates.jl` computes:

```text
ALL_D4_COEFFICIENT_GATES_PASS = all_pass
```

but then returns exit code zero regardless of `all_pass`. A failed gate can
therefore print `false` and still look successful to a shell script, CI job, or
human checking only the exit code.

Required repair:

```text
all_pass || error("one or more D4 coefficient gates failed")
```

or an equivalent nonzero exit path.

The script should also assert rather than merely print:

- `closed`;
- Hamiltonian invariance;
- zero missing moments;
- zero positive covariance violations;
- zero gap covariance violations;
- zero off-irrep violations.

### P0.3 The claimed gate result is not preserved as evidence

Commit `7afcb5c` says all gates passed and gives counts, but it commits no gate
stdout, environment, source hash, or result file. The reviewer can inspect the
gate implementation but cannot audit the reported execution.

Required minimal evidence:

- exact command;
- clean source commit;
- Julia version;
- complete stdout/stderr;
- exit code;
- SHA-256 of the gate source and output.

Given the deadline, a small text bundle is enough. It need not become another
large framework.

### P0.4 “Exact equivalence proved” is still ahead of the committed argument

The strongest checks are useful, but the current wording is too strong:

- off-irrep cancellation is sampled, not exhaustive;
- stationarity-space covariance/invariance is not checked explicitly;
- the symmetry-adapted `Q` representation check remains a floating check,
  albeit on dyadic rationals that should be exactly representable here;
- no written group-averaging lemma was added;
- the conflict with Remark 2.7 of the source paper remains untouched.

Full positive-matrix covariance over 497,024 cases plus representation theory
can support a general off-block theorem; an exhaustive off-block loop is not
strictly necessary. But that theorem must be written, with its assumptions:

1. the moment quotient makes the functional D4 invariant;
2. the basis and all constraint spaces are D4 closed;
3. `M`, `K`, `G`, stationarity, and normalization are covariant/invariant;
4. averaging preserves feasibility of this finite convex SDP;
5. the statement is about relaxed functionals, not automatically about a
   symmetric physical KMS state.

Until that note exists, retain the conservative label recommended previously:

> D4-averaged finite relaxation; physical symmetry interpretation under review.

Do not use the current runmeta's “unrestricted, not symmetry-restricted” phrase
as a settled physical theorem.

## P1 — next deadline-critical work

### P1.1 Add the gates to the standard tests

The new gates remain a standalone script and are not part of
`test/runtests.jl`. At minimum, add small regression fixtures for:

- fail-closed behavior;
- a deliberately corrupted permutation;
- a deliberately corrupted coefficient;
- quotient closure and representative mapping;
- one nonzero-`gamma` `A_gamma` comparison.

The full 497,024-case audit may remain a slower explicit gate if it is too
expensive for the default suite.

### P1.2 Produce a minimal reduced-model identity

The current bundle has a strong MOF hash, but `assembly_sha256` still identifies
the unreduced assembly and the 1,831 variables have no committed semantic map.

For the deadline, the minimum acceptable addition is:

- ordered quotient representative list;
- original-moment-to-representative mapping hash;
- D4 permutation/Q/block metadata hash;
- one `reduced_model_sha256` combining those hashes with the source assembly
  hash and schema version.

This can be narrower than the full ideal manifest requested previously.

### P1.3 Move to positive `gamma` after the small repair

There is still no positive-`gamma` Square Rung B status. Once P0.1–P0.2 are
fixed and a same-input clean build reproduces the MOF hash, do not spend another
28 minutes re-solving `gamma=0`.

Launch only the small declared probe set from the one-day plan:

- one moderate positive `gamma`;
- one high `gamma`;
- at most one additional point if a transition appears.

The `gamma=0` evidence is now sufficient as the sanity anchor.

### P1.4 Interpret the resource result correctly

The quotient reduced scalar variables from 12,826 to 1,831 and the MOF from
about 17 MB to 4.1 MB, but peak process memory remained about 87 GiB:

```text
pre-quotient job 23004880  ~86.6 GiB, 33.3 min
quotient job 23005746      ~86.5 GiB, 28.4 min
```

Therefore:

- D4 PSD block decomposition was the main tractability breakthrough;
- moment quotienting improves model size and runtime modestly;
- it did not materially reduce peak interior-point memory in this run.

Use this more precise comparison in the final presentation.

## Remaining lower-priority items

- `sacct-provisional.txt` again records the job while `RUNNING`; obtain final
  accounting if Slurm `MaxRSS` is quoted.
- The solver progress line still prints `solve_form=dual` while preopt metadata
  says `mosek_default`.
- The builder runmeta still hardcodes gate booleans rather than recording a
  machine-produced gate report.
- README and `validation-report.md` remain stale.
- `Ion.lock` remains modified outside the scientific commits.
- The two advisor notes are still untracked in the local worktree; preserve
  them if they are intended as project records.

## Recommended next worker packet

In order:

1. Surgically remove the nested/duplicate gate block.
2. Make the gate script fail nonzero.
3. Preserve one clean gate transcript.
4. Write the short finite-functional D4 lemma or conservative caveat.
5. Add the minimal quotient/reduced hash.
6. Rebuild the `gamma=0` MOF only and verify byte identity; do not re-solve it.
7. Launch the two positive-`gamma` probes.
8. Package results at the evidence level actually achieved.

## Updated delivery assessment

| Goal | Status at `3338706` |
|---|---|
| Square end-to-end pipeline | Achieved |
| Current quotient `gamma=0` remote solve | Achieved |
| Old equivalence claim corrected | Achieved |
| Exact covariance gate implementation | Substantial progress |
| Current HEAD safe for new runs | Not yet; duplicate/nested code repair needed |
| Fail-closed automated gate | Not yet |
| D4 physical semantics settled | Not yet |
| Reduced-model semantic hash | Not yet |
| Positive-`gamma` Square result | Not yet |
| Square numerical upper-bound candidate | Not yet |
| Square certified upper bound | Not yet |

The project is closer to a deliverable than at the previous review. The new
`gamma=0` result is worth keeping. The immediate task is not another redesign:
it is a short code cleanup and evidence freeze, followed by the first
positive-`gamma` probes.
