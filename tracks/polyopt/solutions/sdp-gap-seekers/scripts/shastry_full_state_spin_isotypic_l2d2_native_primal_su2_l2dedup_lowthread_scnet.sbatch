#!/usr/bin/env bash
# Memory-squeeze decision run for the exact L=2,d=2 deduplicated native
# primal.  Construction remains parallel; MOSEK uses four threads to reduce
# factorization workspaces under the standard single-node memory cap.
#SBATCH --job-name=ss-l2-dedup-primal-t4
#SBATCH --partition=kshcnormal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=114000M
#SBATCH --time=12:00:00
#SBATCH --output=tracks/polyopt/solutions/sdp-gap-seekers/results/_slurm/scnet-ss-l2-dedup-native-primal-t4-%j.out

set -euo pipefail

export LC_ALL=C
export LANG=C
export JULIA_NUM_THREADS=32
export SS_MOSEK_THREADS=4
export SS_MOSEK_TIME_LIMIT_SECONDS=28800
export SS_MOSEK_LOG_LEVEL=2
export SS_MOSEK_SOLVE_FORM=primal
export SS_MOSEK_ORDER_METHOD=try_graphpar
export SS_MOSEK_BASIS_IDENTIFICATION=never
export SS_AUDIT_TOLERANCE=1e-9
export SHASTRY_STREAM_ROW_BATCH=32
export SHASTRY_NATIVE_FINGERPRINT=1
export SHASTRY_SU2_RANK4_REDUCTION=1
export SHASTRY_STABILIZER_COEFFICIENT_TRUTH=1
export SHASTRY_STABILIZER_CONE_SPLIT=1
export SHASTRY_SO3_L2_CONGRUENCE_TRUTH=1
export SHASTRY_SO3_L2_CONE_DEDUP=1

readonly EXPECTED_ROOT="${SS_EXPECTED_ROOT:-/public/home/sihhu/quantum-hackson/checkouts/ss-l2-dedup-primal-lowthread}"
readonly EXPECTED_COMMIT="${SS_EXPECTED_COMMIT:?SS_EXPECTED_COMMIT is required}"
readonly EXPECTED_HASH="ddd3795eb3b15034f2208f90fc98056fb8c63109852393def93d69fd7e17df1b"
readonly JULIA_ROOT="/public/home/sihhu/quantum-hackson/toolchains/julia-1.11.5"
readonly JULIA_BIN="$JULIA_ROOT/bin/julia"
readonly JULIA_PROJECT="/public/home/sihhu/quantum-hackson/envs/ss-full-state"
readonly MOSEK_LICENSE="/public/home/sihhu/quantum-hackson/licenses/mosek.lic"
readonly OUTPUT_DIR="tracks/polyopt/solutions/sdp-gap-seekers/results/ss-full-state-spin-isotypic-l2d2-g0p8-gamma2-native-primal-su2-l2dedup-t4-scnet-${SLURM_JOB_ID}"

cd "${SLURM_SUBMIT_DIR:?SLURM_SUBMIT_DIR is required}"
[[ "$PWD" == "$EXPECTED_ROOT" ]] || {
    echo "unexpected checkout: $PWD" >&2
    exit 2
}
[[ "$(git rev-parse HEAD)" == "$EXPECTED_COMMIT" ]] || {
    echo "unexpected commit: $(git rev-parse HEAD)" >&2
    exit 2
}
[[ -z "$(git status --porcelain)" ]] || {
    echo "refusing dirty checkout" >&2
    exit 2
}
[[ ! -e "$OUTPUT_DIR" ]] || {
    echo "output directory already exists: $OUTPUT_DIR" >&2
    exit 2
}
export SS_EXPECTED_COEFFICIENT_MAP_SHA256="$EXPECTED_HASH"

export LD_LIBRARY_PATH="$JULIA_ROOT/lib/julia:${LD_LIBRARY_PATH:-}"
export MOSEKLM_LICENSE_FILE="$MOSEK_LICENSE"

printf 'commit=%s\n' "$(git rev-parse HEAD)"
printf 'expected_hash=%s\n' "$EXPECTED_HASH"
printf 'formulation=native-affine-psd-primal-su2-l2-dedup-lowthread-v1\n'
printf 'construction_threads=%s mosek_threads=%s solve_form=%s ordering=%s basis=%s\n' \
    "$JULIA_NUM_THREADS" \
    "$SS_MOSEK_THREADS" \
    "$SS_MOSEK_SOLVE_FORM" \
    "$SS_MOSEK_ORDER_METHOD" \
    "$SS_MOSEK_BASIS_IDENTIFICATION"
printf 'host=%s allocated_cpus=%s start=%s\n' \
    "$(hostname)" \
    "${SLURM_CPUS_PER_TASK:-unknown}" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)"

/usr/bin/time -v -o "${OUTPUT_DIR}.process-time.txt" \
    "$JULIA_BIN" \
    --project="$JULIA_PROJECT" \
    --startup-file=no \
    tracks/polyopt/solutions/sdp-gap-seekers/scripts/build_shastry_full_state_spin_isotypic_mof.jl \
    --coupling 4/5 \
    --gamma 2 \
    --patch-level 2 \
    --mode native \
    --output "$OUTPUT_DIR"

printf 'finish=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
