#!/bin/bash
set -e
cd "$(dirname "$0")"

VERBOSE_LOG="benchmark_verbose.txt"
SUMMARY_LOG="benchmark.txt"
TIME="60s"

echo "Benchmarking started at $(date -u)" >"$SUMMARY_LOG"
echo "Benchmarking started at $(date -u)" >"$VERBOSE_LOG"

echo "" >>"$SUMMARY_LOG"
echo "" >>"$VERBOSE_LOG"

variants=("yes" "yesm" "yesm_sse2")

args_sets=(
  ""
  "HELLO WORLD!"
  "FOO BAR BAZ"
  "THIS_IS_A_VERY_LONG_SINGLE_ARGUMENT_TO_BENCHMARK_WITH"
  "THIS IS A VERY LONG MULTI ARGUMENT LIST TO_BENCHMARK_WITH"
)

RANDOM_ARG=$(head -c 8192 /dev/urandom | base64 | tr -dc '[:alnum:]')
RAND_ARG_LABEL="RANDOM_8KiB_ARG"

for variant in "${variants[@]}"; do
  total_avg=0
  count=0

  for args in "${args_sets[@]}" "$RAND_ARG_LABEL"; do
    if [ -z "$args" ]; then
      echo "$variant (No Args):" >>"$VERBOSE_LOG"
      split_args=()
    elif [ "$args" = "$RAND_ARG_LABEL" ]; then
      echo "$variant (Random 8KiB Argument):" >>"$VERBOSE_LOG"
      split_args=("$RANDOM_ARG")
    else
      echo "$variant (Args: ${args:0:100}):" >>"$VERBOSE_LOG"
      read -r -a split_args <<<"$args"
    fi

    START=$(date +%s.%N)

    if [ "$variant" = "yes" ]; then
      BYTES=$(timeout "$TIME" yes "${split_args[@]}" | wc -c)
    else
      BYTES=$(timeout "$TIME" ./build/"$variant" "${split_args[@]}" | wc -c)
    fi

    END=$(date +%s.%N)
    ELAPSED=$(echo "$END - $START" | bc)
    AVG=$(echo "$BYTES / $ELAPSED" | bc)

    total_avg=$(echo "$total_avg + $AVG" | bc)
    count=$((count + 1))

    HR_BINARY=$(numfmt --to=iec --suffix=iB "$BYTES")
    HR_DECIMAL=$(numfmt --to=si --suffix=B "$BYTES")
    HR_AVG_BINARY=$(numfmt --to=iec --suffix=iB "$AVG")
    HR_AVG_DECIMAL=$(numfmt --to=si --suffix=B "$AVG")

    {
      echo "Bytes: $BYTES ($HR_BINARY / $HR_DECIMAL)"
      echo "Elapsed: $ELAPSED sec"
      echo "Average: $AVG bytes/sec ($HR_AVG_BINARY/s / $HR_AVG_DECIMAL/s)"
      echo ""
    } >>"$VERBOSE_LOG"
  done

  AVG_ALL=$(echo "$total_avg / $count" | bc)
  HR_AVG_ALL_BINARY=$(numfmt --to=iec --suffix=iB "$AVG_ALL")
  HR_AVG_ALL_DECIMAL=$(numfmt --to=si --suffix=B "$AVG_ALL")

  echo "$variant (Average over all arg sets): $AVG_ALL bytes/sec ($HR_AVG_ALL_BINARY/s / $HR_AVG_ALL_DECIMAL/s)" >>"$SUMMARY_LOG"
done

echo "" >>"$SUMMARY_LOG"
