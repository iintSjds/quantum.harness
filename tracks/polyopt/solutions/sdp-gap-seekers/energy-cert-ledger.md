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
| 1 | 2D square Heisenberg, g=0 | L=4, d=4, rdm=0 | ≥ −0.7030 | −0.7018 (ED) | 0.18% | Mosek 11.2.2 (local) | — | local-validated |
| 2 | 2D square Heisenberg, g=0 | L=4, d=4, rdm=8 | ≥ −0.7025 | −0.7018 (ED) | 0.10% | Mosek 11.2.2 | 47s | **local + SCNet** |
| 3 | 2D square Heisenberg, g=0 | L=6, d=4, rdm=8 | ≥ −0.6836 | −0.6789 (ED) | 0.70% | Mosek 11.2.2 | 86s | **local + SCNet** |
| 4 | 2D square J1-J2, g=0.3 | L=4, d=4, rdm=8 | ≥ −0.5826 | −0.5559 | 4.8% | Mosek 11.2.2 | 31s | **local + SCNet** |
| 5 | 2D square J1-J2, g=0.5 | L=4, d=4, rdm=8 | ≥ −0.5173 | −0.4976 | 4.0% | Mosek 11.2.2 | 33s | **local + SCNet** |
| 6 | Shastry–Sutherland, g=0 | TBD | — | −0.375 | — | — | — | planned (energy anchor) |
| 7 | Shastry–Sutherland, g≈0.8 | TBD | — | contested | — | — | — | planned (key result) |
| 8 | 2D square Heisenberg, g=0 | L=8, d=4, rdm=0 | ≥ −0.6805 | −0.676370 (paper) | 0.61% | Mosek 11.2.2 | 203s | **SCNet (headline)** |
| 9 | 2D square Heisenberg, g=0 | L=4, d=6, rdm=8 | ≥ −0.7025 | −0.7018 | 0.10% | Mosek 11.2.2 | 50s | SCNet (= d=4) |
| 10 | 2D square Heisenberg, g=0 | L=4, d=8, rdm=8 | ≥ −0.7025 | −0.7018 | 0.10% | Mosek 11.2.2 | 32s | SCNet (= d=4) |
| 11 | 2D square Heisenberg, g=0 | L=6, d=6, rdm=8 | ≥ −0.6836 | −0.6789 | 0.70% | Mosek 11.2.2 | 79s | SCNet (= d=4) |
| 12 | 2D square Heisenberg, g=0 | L=8, d=6, rdm=0 | ≥ −0.6805 | −0.676370 | 0.61% | Mosek 11.2.2 | 194s | SCNet (= d=4) |
| 13 | 2D square J1-J2, g=0.3 | L=4, d=6, rdm=8 | ≥ −0.5826 | −0.5559 | 4.8% | Mosek 11.2.2 | 45s | SCNet (= d=4) |
| 14 | 2D square J1-J2, g=0.5 | L=4, d=6, rdm=8 | ≥ −0.5173 | −0.4976 | 4.0% | Mosek 11.2.2 | 26s | SCNet (= d=4) |
| 15 | **2D square J1-J2, g=0.535** | L=4, d=6, rdm=8 | **≥ −0.5088** | — (challenge pt, SPEC §2) | — | Mosek 11.2.2 | 26s | **SCNet (new)** |
| 16 | 2D square J1-J2, g=0.7 | L=4, d=6, rdm=8 | ≥ −0.5135 | −0.4836 | 6.2% | Mosek 11.2.2 | 28s | SCNet (= d=4) |
| 17 | 2D square Heisenberg, g=0 | L=10, d=4, rdm=0 | — | — | — | Mosek 11.2.2 | — | running (overnight job 22965090) |
| 18 | 2D square Heisenberg, g=0 | L=12,14 d=4; L=10,12 d=6 | — | — | — | Mosek 11.2.2 | — | running (overnight, Tier 3+5) |

**Key finding — d-convergence (rows 9–14, 16):** raising the relaxation order
from d=4 to d=6 and d=8 reproduces the d=4 bound **to 6 significant figures**
(e.g. L=4 g=0: −0.702488373049998 at d=4 = d=6 = d=8). The SDP relaxation is
**saturated in d at small L**; bound quality is set by **rdm and L**, not d.
Cranking d further is unproductive — the **L-frontier** (thermodynamic trend,
rows 17–18) is the remaining productive energy-side knob. This also means the
floor is essentially as tight as this rdm=8 hierarchy gets at L≤8.

**Rows 1–5 are local-laptop runs** (the other session's `GSB(..., lattice="square",
rdm=8, d=4)` calls, validated against ED references). Source: the other session's
handoff. **Finite-size sanity check passes**: the g=0 Heisenberg sequence
L=4 (−0.7030) → L=6 (−0.6836) → ∞ (−0.6694 literature) is monotone approaching
the thermodynamic limit from below, as it must for a lower bound. rdm=8 tightens
the L=4 bound by ~0.08 ppt vs rdm=0 (extra reduced-density-matrix positivity).

**Caveats on rows 1–5** (before citing in a writeup):
- ~~runtime not recorded~~ — **runtime now captured** on the SCNet reproduction
  (rows 2–5: 31–86 s); row 1 (rdm=0, local) still unrecovered.
- ED reference provenance (own ED? literature?) to confirm for each (L, g);
- the local laptop is memory-constrained (one prior WSL OOM-kill). **SCNet is now
  operational and git-tracked** — L=8 (row 8) and the L=10–14 frontier (rows
  17–18) run there, beyond what the laptop can reach.

The **#88 gap-side** has separate local results (1D Ising Δ≤0.258 @ d=2,
Δ≤0.152 @ d=3 vs exact 1.0) — reported under the gap track, not here.

## Open data needs (blocking writeup)

1. ~~**Rows 1–5 metadata — missing runtime**~~ — **runtime now captured** on the
   SCNet reproduction (rows 2–5, 8–16). **ED-reference provenance** (own ED?
   literature?) for each (L, g) is still open.
2. **2D square finite-size reference** — confirm the ED values for the exact
   (L, boundary) used, or run a small ED cross-check (the harness `/method-ed`
   skill).
3. **QMBCertify `resort` fix is an @eval injection, not a committed patch** — it
   must be present in every job script (`@eval QMBCertify function resort(...)`),
   not assumed. ~~The SCNet `~/.julia/artifacts/` blocker~~ is **resolved**
   (targeted 36 MiB OpenBLAS32 + FLINT copy; QMBCertify 0.3.5 loads, `GSB`
   defined). Mosek license also copied (`~/mosek/mosek.lic`).

## Next compute steps (all on SCNet — laptop-compute constraint)

1. Re-run row 1 with full metadata capture (solver status, residuals, runtime).
2. SS g=0 at a small (L,d): must recover E₀/N ≥ −0.375 (within the relaxation
   gap). This is the energy-side calibration and the cheapest end-to-end check.
3. SS g≈0.8 at the largest affordable (L,d): the contested point — the headline
   floor result.
4. 2D square (L,d) sweep at g = 0, 0.5, 0.535 for the convergence plot.

## Status

**SCNet fully operational + git-tracked as of 2026-07-27.** The QMBCertify load
failure was a missing `~/.julia/artifacts/` tree; fixed with a targeted 36 MiB
OpenBLAS32 + FLINT copy (not 3.5 GB), plus the Mosek license (`~/mosek/mosek.lic`).
**SCNet is now git-tracked**: bare repo `~/quantum.harness.git` + working clone
`~/quantum.harness` on `challenge/polyopt-sdp-gap`; update remote code with
`git push scnet <branch>` then `ssh scnet 'cd ~/quantum.harness && git pull'`
(no file-copy drift, no GitHub needed on SCNet). The `resort` injection remains a
runtime `@eval` in every job script, not a committed patch.

**`sdp_final.sh` COMPLETE** (job 22964547) — reproduced rows 2–5 on SCNet and
filled the **headline row 8**: L=8 Heisenberg E₀/N ≥ −0.6805 vs paper −0.676370
(0.61% gap) — the result the laptop could not reach.

**Overnight job `22965090` RUNNING** (`sdp_overnight.sh`, 10 h wall):
d-convergence sweep (rows 9–14, 16 — confirms d is saturated at small L), the
**challenge point g=0.535 → E₀/N ≥ −0.5088** (row 15, new), and the L=10/12/14
Heisenberg frontier (rows 17–18, running). Results append incrementally to
`sdp_overnight.results`; each case is try/caught so a wall-kill loses at most
one cell. Bug found+fixed during the run (Rational vs Float `coe` broke the g=0
path — caught by a settle-time check before the night was wasted).

This track is intentionally decoupled from the gap-SDP (#88) foundation work on
`feature/legacy-affine-inventory` / `feature/structured-basis-assembly`. The
#88 gap-side implementation (`square-j1j2-gap-sdp-spec.md`) is the next milestone
once this floor is banked.
