# Energy-cert floor — run ledger

> The guaranteed-deliverable track: **certified ground-state energy bounds** for
> frustrated spin-1/2 models (2D square J1-J2 + Shastry–Sutherland), via the same
> QMBCertify/NCTSSoS stack the gap-SDP (#88) uses.
>
> Owner: xcai side. Separate branch (`feature/energy-cert-floor`) and ledger —
> per agreement with Sihan, energy bounds are **not mixed** with #88 bulk-gap
> bounds in reporting.
>
> Rationale: convergence data shows energy cert is ~0.17% at the relaxation where
> gap cert is ~74%. The floor is nearly paper-ready; the gap is the stretch.

## Deliverable

A short, certified result table + writeup:

1. **2D square J1-J2** — certified lower bounds E₀/N at g = 0, 0.5, 0.535, over a
   small (L,d) sweep, compared to ED/QMC references.
2. **Shastry–Sutherland** — g = 0 (exact anchor, E₀/N = −3/8·J for the dimer
   product) and the contested g ≈ 0.8 point, where a certified energy bound
   constrains the spin-liquid-vs-PVBS debate even though a gap bound may not.

## Exact-reference anchors (for the writeup and asserts)

| model | quantity | exact reference | source |
|---|---|---|---|
| Shastry–Sutherland, g=0 (J'=0) | E₀/N | **−3/8·J = −0.375** (product of N/2 singlet dimers, each ⟨S_i·S_j⟩ = −3/4) | analytic |
| Shastry–Sutherland, g=0 | Δ_bulk | 1 (gap to break one dimer) | analytic — also the #88 calibration anchor |
| 2D square Heisenberg, g=0 | E₀/N (thermodynamic) | ≈ −0.6694 | QMC/DMRG literature |
| 2D square Heisenberg, finite L | E₀/N | ED on the cluster | finite-size, must match boundary/PBC |

## Run ledger

Columns: model | (L, d, rdm/pso) | E₀/N certified lower bound | reference | gap | solver / version | runtime | status

| # | model | config | certified E₀/N | reference | gap | solver | runtime | status |
|---|---|---|---|---|---|---|---|---|
| 1 | 2D square J1-J2, g=0 | L=4, d=? (PBC?) | ≥ −0.7030 | −0.7018 (reported) | 0.17% | Mosek 11 (reported) | ? | **metadata pending** |
| 2 | Shastry–Sutherland, g=0 | TBD | — | −0.375 | — | — | — | planned (energy anchor) |
| 3 | Shastry–Sutherland, g≈0.8 | TBD | — | contested | — | — | — | planned (the key result) |
| 4 | 2D square J1-J2, g=0.5 | L=4, d=? | — | TBD | — | — | — | planned |
| 5 | 2D square J1-J2, g=0.535 | L=4, d=? | — | TBD | — | — | — | planned |

**Row 1 was produced by the other session.** I need from that session, before
citing it: the exact (L, d, rdm, pso) values; whether L=4 is PBC or open; the
ED reference source (own ED run? literature?); the SpectralGap/QMBCertify +
Mosek versions; the runtime; and the solver status (OPTIMAL vs other). Until
then it is a placeholder.

## Open data needs (blocking writeup)

1. **Row-1 metadata** (above) — request from the other session / SCNet logs.
2. **2D square finite-size reference** — confirm the ED values for the exact
   (L, boundary) used, or run a small ED cross-check (the harness `/method-ed`
   skill).
3. **QMBCertify 2D bug status** — the other session reported fixing the
   `resort`-undefined bug in `eigen_circmat` for the 2D square path; confirm the
   patch is captured (commit) and reproducible on SCNet before relying on rows
   4–5.

## Next compute steps (all on SCNet — laptop-compute constraint)

1. Re-run row 1 with full metadata capture (solver status, residuals, runtime).
2. SS g=0 at a small (L,d): must recover E₀/N ≥ −0.375 (within the relaxation
   gap). This is the energy-side calibration and the cheapest end-to-end check.
3. SS g≈0.8 at the largest affordable (L,d): the contested point — the headline
   floor result.
4. 2D square (L,d) sweep at g = 0, 0.5, 0.535 for the convergence plot.

## Status

Ledger opened 2026-07-27. No certified writeup-ready number yet (row 1 pending
metadata). This track is intentionally decoupled from the gap-SDP foundation
work on `feature/legacy-affine-inventory` / `feature/structured-basis-assembly`.
