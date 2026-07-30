# Advisor final packaging review: commit `25f857e`

Date: 2026-07-30 13:54 CST

Reviewed:

```text
PR       https://github.com/QuantumBFS/quantum.harness/pull/160
head     25f857ec7da33fdc4cdbbcc452a2ba4b909deba1
state    OPEN, ready for review, mergeable
checks   none reported
diff     415 files, +91,346/-14 relative to upstream main
```

## Verdict

**Not ready to freeze yet.**

Commit `25f857e` improves navigation, but it is almost entirely a packaging
rename plus a new README TL;DR. It does not address the P0 scientific and
reproducibility findings in
`ADVISOR_SUBMISSION_READINESS_REVIEW_2026-07-30.md`.

The project itself remains a defensible method/negative result. The remaining
fixes are small enough to complete before the deadline and do not require a
new solve.

## What the packing commit improved

- The team root is much easier to scan.
- Process logs, proof notes, and specifications are grouped under
  `notes/{process,proofs,specs}`.
- `REMOTE_AGENT_STATUS.md` no longer pollutes the repository root.
- The README begins with a concise description.
- The live PR remains marked ready and GitHub reports it mergeable.
- Strict “feasible is not a bound” language remains prominent and correct.

Qualification: the process material was moved, not removed. The PR still has
415 files, and `REMOTE_AGENT_STATUS.md` is now under `notes/process/`.
This is a polish issue rather than the main blocker.

## Unresolved P0 findings

### 1. The submission still misidentifies the triangular calculation

The live PR body and README still say:

```text
all three #88 target models
```

The triangular result is J1-only (`J2=0`). Issue #88's triangular target is
J1-J2 at `J2/J1=0.10` and `0.12`. The current calculation is a useful
third-geometry control, but it is not the third requested target.

Current affected README locations include lines 7, 39, 68, and 143-146.
The same error remains in:

- the live PR body;
- `docs/issue88_metadata.md:90`;
- `docs/tractability_reduction.md:86`;
- local `run.json`, `report.json`, and `report.html`.

The claim that the same reduction transfers across three geometries is valid.
The claim that all three calculations are issue-#88 targets is not.

Minimum replacement:

> At selected Square J1-J2 and Shastry-Sutherland target points, plus a
> triangular-J1 portability control, every tested `L=1,d=2` relaxation was
> feasible.

### 2. The PR title and body still describe a bound that was not obtained

The live title is unchanged:

```text
[polyopt] sdp-gap-seekers: Certified spectral-gap bounds for frustrated
spin-1/2 models (#88)
```

The body is clearer than the original registration plan because it explicitly
says no bound was obtained, but its headline still reads as though certified
bounds are the deliverable. It also repeats the false three-target claim and
the stale “in flight” state.

Recommended title:

```text
[polyopt] sdp-gap-seekers: Exact symmetry reductions and feasibility
audits for spin spectral-gap SDPs (#88)
```

### 3. The committed environment is still not clean-checkout reproducible

The final file set still contains:

```text
julia-env/Project.toml
```

as a repo-wide replacement of the upstream shared environment. It removes the
upstream tensor-network/ED dependencies and substitutes the team's SDP
dependencies.

There is still no `Project.toml` or `Manifest.toml` under the team directory.
The working manifest is ignored, and the external `SpectralGap` path
dependency is not encoded as a self-contained committed source.

The README itself admits at lines 152-154 that this cleanup is deferred to
“final packaging”; that cleanup has not happened.

Minimum fix:

1. put the SDP `Project.toml` under the team directory;
2. restore the shared root project to upstream;
3. give an exact clean-checkout procedure for the pinned `SpectralGap` commit
   and patch;
4. commit a manifest if repository policy permits, otherwise document the
   exact instantiate/develop sequence.

### 4. Both documented quick-reproduction paths are still wrong

From the team directory:

```text
README:                 --project=julia-env
docs/reproducibility:   --project=../../../julia-env
```

The first points to a nonexistent team-local directory. The second resolves
to `tracks/julia-env`, also nonexistent. The current root environment would
be `../../../../julia-env`.

After adding a team-local project, use:

```text
julia --project=. ...
```

The primary README also still shows a Square `sbatch` invocation without its
mandatory `CONIC_*` variables. Therefore the advertised “two reproduction
routes” are not copy-paste reproducible from the final PR.

## Unresolved result-status issues

### 5. “In flight” is stale

The README, PR body, metadata, and generated report still call Square
`L=1,d=3` and SS `L=2,d=2` in flight.

Actual terminal status:

- Square `L=1,d=3`: exact cone-reduced MOF build completed in job `118201670`;
  no solve was run.
- SS `L=2,d=2`: model built, but Mosek exhausted memory during factor fill
  before iteration zero; no feasibility status.
- Square `L=2,d=2`: failed closed at an exact cone-redundancy gate; no MOF or
  solve.

Remove pending rows from the completed-results table. Put these facts in a
short “stronger-level computational boundary” paragraph.

### 6. Triangular numerical evidence is still absent

`docs/issue88_metadata.md` cites:

```text
results/triangular-j1-scan-20260729/
```

No such directory or curated triangular evidence bundle exists in the
reviewed PR. Either harvest the minimal provenance bundle under `evidence/`
or demote the quantitative status/runtime/RSS claims.

### 7. The challenge report is stale and not tracked

The local files remain timestamped from 11:19-11:31 CST, before both advisor
reviews:

```text
tracks/polyopt/results/20260730-d2-gamma-feasibility/run.json
tracks/polyopt/results/20260730-d2-gamma-feasibility/report.json
tracks/polyopt/results/20260730-d2-gamma-feasibility/report.html
```

They remain gitignored and repeat:

- “all three #88 targets”;
- stale “in flight” status;
- “feasibility can certify an interval,” which should say finite-relaxation
  feasibility on the lower interval;
- a broken estimate/actual comparison whose actual columns render as dashes.

Correct `run.json`, regenerate the outputs, and use the organizer's report
submission mechanism. Do not treat the present local report as final.

## Remaining hygiene issues

- `skills/using-slurm/profiles/scnet.toml` is still changed outside the team
  directory. It is a local infrastructure configuration and should be
  excluded from the PR.
- The public reproducibility guide still contains personal account names and
  absolute cluster paths.
- It still says evidence `git-status.txt` must be clean, although curated
  Square records contain untracked scratch files. Say “no tracked source
  modifications” instead.
- Moving the notes broke several internal relative Markdown links. For
  example, files under `notes/` still link to
  `../square-j1j2-gap-sdp-spec.md` and `../basis-counts.md`, while those files
  now live under `notes/specs/`. These are internal-process links, so fix them
  only after the public submission path is correct.
- The `<1 min` laptop timing remains unsupported by a committed
  clean-checkout record. Remove the timing if it has not been measured.

## Deadline-safe minimum patch

Do these in order:

1. Correct the PR title/body and replace every “three #88 targets” statement.
2. Add the team-local Julia environment, restore the root project, and make
   the quick commands resolve.
3. Replace pending rows with terminal build/OOM status.
4. Harvest or demote the triangular quantitative claims.
5. Correct and regenerate `challenge-report`.
6. Drop the shared SCNet profile change.

Then inspect the final PR diff and freeze. No new computation is warranted.

If time is extremely short, items 1-3 are the minimum needed to avoid a
scientifically misleading and visibly non-reproducible submission.
