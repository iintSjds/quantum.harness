#!/usr/bin/env bash
# Exact L=2,d=2 Shastry--Sutherland decision solve on one SCNet large-memory
# node.  The full coefficient gates run before the deduplicated native primal
# task is passed to MOSEK.
# Submit with:
#   sbatch --gres-flags=disable-binding \
#     --export=ALL,SS_EXPECTED_COMMIT=<commit> \
#     scripts/shastry_full_state_spin_isotypic_l2d2_native_primal_su2_l2dedup_optimized_highmem_scnet.sbatch
#SBATCH --job-name=ss-l2-dedup-primal-hm
#SBATCH --partition=ksagnormal01
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=900000M
#SBATCH --gres=gpu:1
#SBATCH --gres-flags=disable-binding
#SBATCH --time=12:00:00
#SBATCH --output=tracks/polyopt/solutions/sdp-gap-seekers/results/_slurm/scnet-ss-l2-dedup-native-primal-optimized-highmem-%j.out

set -euo pipefail

export LC_ALL=C
export LANG=C
# Model construction is allocation/GC bound above 32 Julia threads.  The
# remaining cores reserve same-node capacity for MOSEK's factorization.
export JULIA_NUM_THREADS=32
export SS_MOSEK_THREADS=32
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

readonly EXPECTED_ROOT="${SS_EXPECTED_ROOT:-/public/home/sihhu/quantum-hackson/checkouts/ss-l2-dedup-primal-highmem}"
readonly EXPECTED_COMMIT="${SS_EXPECTED_COMMIT:?SS_EXPECTED_COMMIT is required}"
readonly EXPECTED_HASH="${SS_EXPECTED_COEFFICIENT_MAP_SHA256:-}"
readonly JULIA_ROOT="/public/home/sihhu/quantum-hackson/toolchains/julia-1.11.5"
readonly JULIA_BIN="$JULIA_ROOT/bin/julia"
readonly JULIA_PROJECT="/public/home/sihhu/quantum-hackson/envs/ss-full-state"
readonly MOSEK_LICENSE="/public/home/sihhu/quantum-hackson/licenses/mosek.lic"
readonly OUTPUT_DIR="tracks/polyopt/solutions/sdp-gap-seekers/results/ss-full-state-spin-isotypic-l2d2-g0p8-gamma2-native-primal-su2-l2dedup-optimized-highmem-scnet-${SLURM_JOB_ID}"

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
if [[ -n "$EXPECTED_HASH" ]]; then
    export SS_EXPECTED_COEFFICIENT_MAP_SHA256="$EXPECTED_HASH"
fi

export LD_LIBRARY_PATH="$JULIA_ROOT/lib/julia:${LD_LIBRARY_PATH:-}"
export MOSEKLM_LICENSE_FILE="$MOSEK_LICENSE"

printf 'commit=%s\n' "$(git rev-parse HEAD)"
printf 'expected_hash=%s\n' "${EXPECTED_HASH:-self-fingerprint-pending}"
printf 'formulation=native-affine-psd-primal-su2-l2-dedup-optimized-highmem-v1\n'
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
