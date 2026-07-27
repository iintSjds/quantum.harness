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

| # | model | config | certified E₀/N | reference | gap% | solver | runtime | status |
|---|---|---|---|---|---|---|---|---|
| 1 | 2D square Heisenberg, g=0 | L=4, d=4, rdm=0 | ≥ −0.7030 | −0.7018 (ED) | 0.18% | Mosek 11.2.2 (local) | ? | **local-validated** |
| 2 | 2D square Heisenberg, g=0 | L=4, d=4, rdm=8 | ≥ −0.7025 | −0.7018 (ED) | 0.10% | Mosek 11.2.2 (local) | ? | **local-validated** |
| 3 | 2D square Heisenberg, g=0 | L=6, d=4, rdm=8 | ≥ −0.6836 | −0.6789 (ED) | 0.7% | Mosek 11.2.2 (local) | ? | **local-validated** |
| 4 | 2D square J1-J2, g=0.3 | L=4, d=4, rdm=8 | ≥ −0.5826 | −0.5559 | 4.8% | Mosek 11.2.2 (local) | ? | **local-validated** |
| 5 | 2D square J1-J2, g=0.5 | L=4, d=4, rdm=8 | ≥ −0.5173 | −0.4976 | 4.0% | Mosek 11.2.2 (local) | ? | **local-validated** |
| 6 | Shastry–Sutherland, g=0 | TBD | — | −0.375 | — | — | — | planned (energy anchor) |
| 7 | Shastry–Sutherland, g≈0.8 | TBD | — | contested | — | — | — | planned (key result) |
| 8 | 2D square Heisenberg, g=0 | L=8, d=4 | — | −0.676370 (paper) | — | — | — | planned (SCNet) |

**Rows 1–5 are local-laptop runs** (the other session's `GSB(..., lattice="square",
rdm=8, d=4)` calls, validated against ED references). Source: the other session's
handoff. **Finite-size sanity check passes**: the g=0 Heisenberg sequence
L=4 (−0.7030) → L=6 (−0.6836) → ∞ (−0.6694 literature) is monotone approaching
the thermodynamic limit from below, as it must for a lower bound. rdm=8 tightens
the L=4 bound by ~0.08 ppt vs rdm=0 (extra reduced-density-matrix positivity).

**Caveats on rows 1–5** (before citing in a writeup):
- runtime not recorded — recover from the other session's logs if needed;
- ED reference provenance (own ED? literature?) to confirm for each (L, g);
- the local laptop is memory-constrained (one prior WSL OOM-kill), so these were
  near the feasible edge — SCNet is needed to push L=8 and higher rdm.

The **#88 gap-side** has separate local results (1D Ising Δ≤0.258 @ d=2,
Δ≤0.152 @ d=3 vs exact 1.0) — reported under the gap track, not here.

## Open data needs (blocking writeup)

1. **Rows 1–5 metadata** — filled from the handoff; still missing **runtime** and
   **ED-reference provenance** for each (L, g). Recover from the other session's
   local logs or re-run with metadata capture on SCNet.
2. **2D square finite-size reference** — confirm the ED values for the exact
   (L, boundary) used, or run a small ED cross-check (the harness `/method-ed`
   skill).
3. **QMBCertify `resort` fix is an @eval injection, not a committed patch** — it
   must be present in every job script (`@eval QMBCertify function resort(...)`),
   not assumed. On SCNet the deeper blocker is the **missing `~/.julia/artifacts/`**
   tree (QMBCertify's deps fail to load without it) — tracked in the SCNet
   handoff; a subagent is on it.

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
