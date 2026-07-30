# Advisor report: challenge-level mapping and the next Square relaxation

Date: 2026-07-29

Decision: **the completed “Rung C” run is an `L=1, d=2` selected-basis
calculation. The best next bounded experiment is `L=1, d=3`, not because it
is cheap, but because it is the smaller of the two natural parameter
increases.**

## Official challenge jargon

Challenge #88 labels a relaxation by `(L,d)`, not by our internal rung
letters:

- `L` is the local-window or patch level;
- `d` is the state-polynomial/moment-matrix degree;
- `gamma` is the candidate bulk-gap threshold, not an accuracy parameter.

The issue asks for gap upper bounds `Gamma_(L,d)(g)` at several accessible
`L,d`, and requires reporting the imposed symmetries, `L`, `d`, moment-matrix
size, solver status, runtime, and result:

<https://github.com/QuantumBFS/quantum.harness/issues/88>

For our Square geometry,

```text
outer patch = [-L,L]^2
outer site count N_outer = (2L+1)^2

inner patch = [-(L-1),L-1]^2
inner site count N_inner = (2L-1)^2
```

Thus `N` is a derived site count in this implementation, not a third
challenge hierarchy parameter. There is also no tensor-network bond
dimension `D` in this SDP calculation. The relevant symbol is lowercase
degree `d`.

## What “Rung C” actually means

Rungs A, B, and C are internal names for three different selected bases at
the **same** official coordinates:

| Internal name | `L` | `d` | outer / inner sites | positive / gap basis |
|---|---:|---:|---:|---:|
| Rung A, `bare_weight_one/v1` | 1 | 2 | 9 / 1 | 28 / 4 |
| Rung B, `bare_operator/v1` | 1 | 2 | 9 / 1 | 352 / 4 |
| Rung C, `one_symbol_lift/v1` | 1 | 2 | 9 / 1 | 703 / 7 |

The full-spin experiment therefore corresponds to:

```text
model                     Square J1-J2, g=1/2
official level            L=1, d=2
derived site count        N_outer=9, N_inner=1
selected basis            one_symbol_lift/v1
state class               unrestricted
spin treatment            exact reparameterization, not a state restriction
```

The name “Rung C” must not be presented as if it were a larger official
`L,d` level than Rungs A/B.

## Completeness caveat

At the complete formal `(L,d)=(1,2)` state-polynomial level, the positive
basis would have 1,810 rows. Rung C retains 703 of them:

```text
complete formal positive basis          1,810
one_symbol_lift/v1 positive basis          703
complete and selected gap basis              7
```

The omitted positive rows are mixed and multi-state-symbol monomials such as
`zeta(w)v` and `zeta(w1)zeta(w2)`.

This does not make the selected relaxation unsound. Validated
infeasibility would still exclude the tested gap. However, its threshold
should be reported with the basis qualifier, for example

```text
Gamma^(one-symbol/v1)_(L,d),
```

rather than silently identifying it with the complete formal
`Gamma_(L,d)`.

Completing `(1,2)` is not currently a quick parameter change. The first exact
reduction performs a special centered/scalar facial decomposition and
explicitly rejects rows outside the one-symbol form. A complete-basis port
would require a new general symmetry/block-reduction derivation, not just a
new manifest.

## The two natural parameter increases

### Option 1: increase degree to `L=1,d=3`

```text
outer / inner sites                  9 / 1
one-symbol positive / gap basis      5,239 / 7
source scalar moments                3,535,570
```

The gap basis stays at seven rows because a one-site inner patch has no
canonical Pauli support above degree one. The strengthening comes from the
larger positive moment matrix and its consistency with moments through
degree six.

The source-moment count is exact. If `q(n,d)` is the number of bare Pauli
words on `n` sites through support degree `d`, the one-symbol positivity
matrix uses

```text
q(n,2d) + binomial(q(n,d), 2)
```

distinct scalar moments. Here `q(9,3)=2,620` and
`q(9,6)=104,680`, giving

```text
104,680 + binomial(2,620,2) = 3,535,570.
```

This is `47.4x` the 74,602 source moments in the completed run. Before the
later full-spin quotient, the exact V4/conjugation PSD-coordinate work grows
from 31,810 to approximately 1,720,462 entries, a factor of `54.1x`.

Projecting the measured reduction ratios only as a sizing estimate gives:

```text
final moment variables       roughly 150,000
final packed PSD entries     roughly 330,000
largest PSD side             order 300--350
```

These are estimates, not promised inventories. The exact assembly is
quadratic in the 5,239-row selected basis and the existing truth gates are
also exhaustive. A several-hour build and tens of GiB of memory are
plausible; the current four-minute/1.2-GiB cost must not be extrapolated
linearly.

### Option 2: increase the patch to `L=2,d=2`

```text
outer / inner sites                  25 / 9
one-symbol positive / gap basis       5,551 / 55
source scalar moments                 4,941,226
```

Here `q(25,2)=2,776` and `q(25,4)=1,089,526`, so

```text
1,089,526 + binomial(2,776,2) = 4,941,226.
```

This is `66.2x` the completed source inventory. The early
V4/conjugation PSD-coordinate work is approximately 1,985,686 entries, or
`62.4x` the completed calculation. A rough measured-ratio projection gives
about 215,000 final moment variables and 380,000 packed PSD entries.

This option is more attractive scientifically because the inner window grows
from one site to nine and the gap basis grows from 7 to 55. It tests
multi-site local excitations directly. It is also the higher-risk scnet2
job because of the larger moment inventory, larger Hamiltonian term set, and
many more stationarity and gap coefficients.

## Resource assessment

The scnet2 `kshcnormal` nodes available to this account have:

```text
32 CPUs
126,500 MB physical node memory
default memory 3,569 MB per CPU
approximately 114,208 MB for a 32-CPU allocation
```

`L=1,d=3` might fit, but it is no longer safely “affordable” in the sense of
the completed `L=1,d=2` run. `L=2,d=2` is plausible only as a gated
experiment and may hit the node-memory ceiling. Neither should be launched as
an unbounded gamma scan.

## Recommended experiment

Proceed in this order:

1. Parameterize a new experiment runner with explicit `--L` and `--degree`.
   Do not weaken the current dynamic-input, hash, exact-assembly, or
   optimizer-free MOF-reload checks.
2. Replace the solver's hard-coded `(L,d)=(1,2)` inventory assertions with
   values bound into the run metadata and independently recomputed from the
   requested setup.
3. Run a solver-free/count-and-symmetry sizing gate for `L=1,d=3`.
4. If its exact reduced inventory is below the scnet2 budget, build and solve
   **gamma 2 first**. A strictly feasible exact gamma-2 witness automatically
   settles every lower gamma by monotonicity and avoids a redundant gamma-zero
   rebuild.
5. If gamma 2 is infeasible or numerically ambiguous, run gamma zero as the
   control before making a scientific claim.
6. Attempt `L=2,d=2` only if the degree-three run leaves substantial measured
   memory and time headroom.

Do not run a dense gamma grid. The useful outcomes are:

- exact feasibility at gamma 2, which again closes the interval `[0,2]` for
  that selected level; or
- validated infeasibility, followed by a small bracket and a dual
  certificate.

## Final recommendation

Yes, raising the official hierarchy parameters is possible. The correct
next target is:

```text
L=1, d=3, N_outer=9, N_inner=1,
one_symbol_lift/v1, gamma=2 first.
```

Call it the selected one-symbol `(L,d)=(1,3)` relaxation, not “Rung D”
unless the internal nickname is accompanied by the actual level and basis.
If that job fits comfortably, `L=2,d=2` is the next, more scientifically
direct strengthening.
