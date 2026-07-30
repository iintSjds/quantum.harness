# Advisor submission-readiness review

Date: 2026-07-30 13:00 CST

Reviewed submission snapshot:

```text
PR       QuantumBFS/quantum.harness#160
branch   challenge/polyopt-sdp-gap
commit   5df3534831e20aabf8f158a7dd9627fbed2bee59
state    OPEN, ready for review, mergeable
checks   none reported
```

## Executive verdict

The submission has a defensible result, but the live PR is **not ready to
freeze as written**. The numerical evidence is mostly sound; the urgent
problems are inaccurate scope/framing and a non-portable Julia environment.

The honest deliverable is:

> An exact, fail-closed symmetry-reduction pipeline and a reproducible
> feasibility study. At `L=1,d=2`, the tested relaxations remain feasible and
> therefore produce no certified bulk-gap upper bound.

That is a useful negative/method result. Do not present it as a certified-gap
bound or as complete coverage of all issue-#88 targets.

The fixes below are documentation/environment work. No new scientific solve is
needed for a credible deadline submission.

## What is already solid

- The README correctly explains the crucial result semantics: finite-level
  infeasibility can exclude a gamma threshold; feasibility excludes nothing.
- Square Rung A, Square D4 Rung B, Square spin-reduced Rung C, and
  Shastry-Sutherland `L=1,d=2` have curated evidence bundles.
- The checked evidence `SHA256SUMS` manifests verify.
- Square Rung C at gamma 2 has the strongest evidence: a numerical feasible
  solve plus an exact rational feasible witness with exact positive LDL
  pivots.
- The exact reduction pipeline is a real contribution. Its fail-closed
  covariance, congruence, block-zero, rank, phase, and reconstruction gates
  distinguish a proved reparameterization from an assumed symmetry-sector
  restriction.
- The local `challenge-report` artifacts exist at
  `tracks/polyopt/results/20260730-d2-gamma-feasibility/{run.json,report.json,report.html}`.
- The live PR is already marked ready for review. Lack of CI is not treated as
  a blocker under the agreed submission assumptions.

## P0: fix before the deadline

### 1. Retitle and rewrite the live PR

The current title,

```text
[polyopt] sdp-gap-seekers: Certified spectral-gap bounds for frustrated
spin-1/2 models (#88)
```

claims an output the project did not obtain. A safer title is:

```text
[polyopt] sdp-gap-seekers: Exact symmetry reductions and feasibility
audits for spin spectral-gap SDPs (#88)
```

The PR body is still the registration-time plan. It says the goal is to
compute certified upper bounds and lists work that is no longer the actual
submission. Replace it with the actual outcome, tested parameter points,
reproduction routes, and limitations.

Suggested opening:

> We implement exact, fail-closed D4 and spin-isotypic reductions for the
> state-polynomial spectral-gap SDP. At the tested `L=1,d=2` points, every
> gamma relaxation was feasible, so this submission reports no certified
> bulk-gap upper bound. The contribution is the exact reduction machinery,
> audited feasibility evidence, and a measured boundary between tractable and
> currently intractable stronger relaxations.

### 2. Correct the issue-#88 coverage claim everywhere

The submission repeatedly calls Square J1-J2, Shastry-Sutherland, and
**Triangular J1** “all three #88 targets.” This is false.

Issue #88's triangular target is **Triangular J1-J2 at `J2/J1=0.10` and
`0.12`**. The submitted triangular calculation is **J1 only, `J2=0`**. It is a
useful portability/control calculation, not completion of the third target.

Coverage is also partial within the other model families: the submission
tests Square at `J2/J1=0.5` and Shastry-Sutherland at `g=0.8`, not every
coupling listed in issue #88.

At minimum fix:

```text
README.md:25-27, 41-43, 54-59, 129-132
docs/issue88_metadata.md:77-90
docs/tractability_reduction.md:78-87
run.json/report.json/report.html: every "three #88 targets" occurrence
```

Use:

> two selected issue-#88 target points, plus a triangular-J1 control that
> demonstrates portability of the exact spin reduction

Do not merely rename the triangular J1 model as J1-J2; its Hamiltonian and
data are genuinely at `J2=0`.

### 3. Make the Julia environment reproducible and submission-local

`julia-env/Project.toml` currently replaces the shared repository environment:
it removes the upstream tensor-network/ED dependencies and installs the
team's SDP stack. This is a repo-wide side effect, not an isolated team
environment.

Worse, there is no team-local `Project.toml` or `Manifest.toml`. The
documentation says the working manifest is ignored and `SpectralGap` is a
path dependency at `../.external/SpectralGap`, but the committed project has
no `[sources]` entry that constructs that path. A clean checkout therefore
does not have a pinned, directly instantiable environment.

Required action:

1. add a project under
   `tracks/polyopt/solutions/sdp-gap-seekers/`;
2. pin package compatibility and describe or encode the exact
   `SpectralGap` source/patch;
3. preferably commit the team manifest if repository policy permits;
4. restore the root `julia-env/Project.toml` to upstream.

The README and reproducibility guide must then use that team-local project.
Do not leave “final packaging will do this” in the submitted limitations.

### 4. Fix the reproduction commands

The current quick commands do not resolve the committed root environment:

- from the team directory, `--project=julia-env` points to a nonexistent
  team-local directory;
- `docs/reproducibility.md` uses `--project=../../../julia-env`, which resolves
  to `tracks/julia-env`, also nonexistent;
- the correct path to the current root environment would be
  `../../../../julia-env`.

If the P0 environment fix is made, the preferred command from the team
directory becomes simply `julia --project=. ...`.

The README's Square `sbatch` command omits mandatory `CONIC_*` variables, and
the Shastry-Sutherland command says only “see file for gamma env.” Copy exact,
tested commands from the detailed guide into the primary reproduction route.
Do not claim “under a minute on a laptop” unless a recorded clean-checkout
timing supports it.

## P1: strongly recommended

### 5. Remove stale “in flight” statements

The README, metadata document, tractability document, and generated report
still say Square `L=1,d=3` and SS `L=2,d=2` are in flight.

Final status:

- Square `L=1,d=3`: a cone-reduced MOF build completed; no solve was run.
- SS `L=2,d=2`: the final model inventory was obtained, but Mosek exhausted
  memory during factor fill before iteration zero; status is unknown, not
  infeasible.
- Square `L=2,d=2`: the advisor audit failed closed at an exact
  cone-redundancy gate; no MOF and no physical result.

Move these to “stronger-relaxation boundary/future work.” Pending rows do not
belong in the completed gamma-feasibility table.

### 6. Rephrase “stronger relaxations are affordable”

The reductions make the `L=1,d=2` problems cheap and make the Square
`L=1,d=3` cone-reduced model affordable to **construct**. They have not shown
that SS `L=2,d=2` is affordable to solve; that solve failed during factor
fill. Also, Rung C is a richer basis at the same formal `L=1,d=2`, not a
higher `L,d` hierarchy level.

Prefer:

> exact reductions cut the fixed-level SDP size dramatically and expose which
> stronger formulations remain computationally blocked

### 7. Curate or demote the triangular quantitative result

`docs/issue88_metadata.md` points to
`results/triangular-j1-scan-20260729/`, but no such result directory or
curated triangular evidence bundle is present in the reviewed checkout.

Either:

- harvest a minimal checksum-bound evidence bundle under `evidence/`; or
- retain triangular as a code-port/control observation but remove the
  quantitative solver-status, time, RSS, and headline-result claims.

The gitignored remote result path is not independently reviewable from the PR.

### 8. Regenerate `challenge-report`

The report exists, but its source and generated outputs contain the false
“three #88 targets” claim and stale “in flight” text. It also says feasibility
at one gamma can “certify an interval”; say instead that monotonicity
establishes **finite-relaxation feasibility** on the lower interval, not a
physical gap certificate.

The estimate/actual comparison table renders dashes in the actual columns
because the `estimate` and `actual` point labels do not match. Use matching
keys if this table is meant to carry the measured timing/RSS.

Regenerate `report.json` and `report.html` from the corrected `run.json`.
Because `tracks/**/results/` is ignored, confirm that the organizer's
`challenge-report` workflow uploads/captures the generated files; they are not
currently part of PR #160.

### 9. Remove submission-irrelevant root changes

Exclude these from the PR:

```text
REMOTE_AGENT_STATUS.md
skills/using-slurm/profiles/scnet.toml
```

The SCNet profile is useful locally but changes a shared repository skill and
is not needed to reproduce the submitted science. The root status file is an
internal coordination artifact.

Also remove personal account names and absolute home-directory examples from
the public reproducibility guide. Describe cluster requirements through
variables instead.

### 10. Correct the evidence cleanliness wording

The guide says every `git-status.txt` “must show a clean source tree,” but the
curated Square evidence records many untracked scratch files. This does not
invalidate the results if tracked source was unchanged, but it is not a clean
status.

Use:

> no tracked source modifications; the captured untracked-file inventory is
> retained for provenance

The folder `square-d4q-rungb-gamma1p4-23006792` contains gamma `1/4`, not
`1.4`; its `runmeta.toml` is correct. Rename the directory if cheap, or note
the historical slug to avoid reviewer confusion.

## P2: polish if time remains

- PR #160 contains about 415 files and a large amount of internal decision
  history. This need not block an AI-reviewed submission, but the primary
  README and PR body should link directly to the small set of canonical
  result/evidence files so the scientific story is not buried.
- The plotting script produced a figure only in the ignored report directory.
  Either embed/commit a canonical figure in the solution documentation or do
  not emphasize the plotting script as a deliverable.
- Make the “two reproduction routes” wording descriptive rather than saying
  “as the submission requires” unless that exact requirement is linked.

## Advisor exploration update worth reporting

### Square J1-J2 `L=1,d=3`: exact cone-reduced build succeeded

The final scnet2 audit job completed:

```text
job                  118201670
commit               40c49c5
model                Square J1-J2, J2/J1=1/2
relaxation           L=1, d=3, one_symbol_lift/v1
gamma                2
state                COMPLETED
elapsed              01:09:32
Slurm batch MaxRSS   4,860,620 KiB
in-process peak      6,310,720 KiB (~6.0 GiB)
```

Every exact gate through the full-spin nontrivial-character cone reduction
passed. The final optimizer-free model is:

```text
source moments       3,535,570
source positive side 5,239
source gap side      7
stationarity eqs     3

reduced moments      118,708
positive PSD sides   324, 288, 288, 381, 325, 288, 288, 381
gap PSD side         1
PSD blocks           9
packed PSD entries   417,632
MOF size             92,827,368 bytes (~88.5 MiB)
MOF SHA-256          4e5ff5727480245994c34d3e811856c734130949b39c64d1efb7feef06293e11
write/reload check   passed
```

This is worth reporting as a **tractability and exact-construction result**.
It is not a feasibility result, gap bound, or observable result. The
degree-two terminal isotypic/spatial reducer remains unsupported at `d=3`, so
the build intentionally stops at the last proved cone gate.

Do not rush this experiment into the PR unless the small code delta and its
checksum-bound artifact can be reviewed and harvested. With the deadline
close, a short “future work / measured stronger-level inventory” paragraph is
safer than initiating a new solve.

### Square `L=2,d=2`: useful fail-closed boundary, not a result

Advisor job `23018668` reached:

```text
source moments       4,941,226
source positive/gap  5,551 / 55
stationarity eqs     351
full-spin moments    231,826
full-spin entries    1,039,091
```

It then failed at the exhaustive full-spin cone-redundancy truth gate. This is
good fail-closed behavior: it exposed a non-general reduction assumption
rather than silently shrinking the SDP. There is no terminal MOF, solver
status, or physical conclusion. Report it only as an implementation boundary.

## Deadline execution order

1. Correct PR title/body and every false #88-target claim.
2. Isolate/pin the Julia environment and make all documented commands resolve
   from a clean checkout.
3. Remove stale pending rows and correct stronger-level language.
4. Harvest triangular evidence or demote its quantitative claims.
5. Regenerate the challenge report.
6. Remove the two root coordination/config files.
7. Perform a final diff/read-through; stop new experiments and freeze.

If time becomes tight, items 1-4 are the minimum scientifically credible
submission. The L1d3 update is optional; do not let it displace those fixes.
