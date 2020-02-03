#! /usr/bin/env sh

set -e
set -u

STATUS=0

###############################################################################

run_test() {
  t1="$1"
  t2="$2"
  grp="$3"
  name=$(basename "$grp")
  name="${name%.*}"

  ./mcti-detect -t "$t1" -t "$t2" -g "$grp" --dot-output "examples/img/$name.dot" --
}

expect_intersect_at() {
  t1="examples/tasks/$1"
  t2="examples/tasks/$2"
  grp="examples/groups/$3"
  intersect_a="$4"
  intersect_b="$5"
  date="$6"

  text=$(run_test "$t1" "$t2" "$grp")
  if [ "$text" != "Found intersection between '$intersect_a' and '$intersect_b' at date '$date'" ]; then
    echo "*** Test with tasks [$t1, $t2] failed for group [$3]"
    echo "$text"
    STATUS=$((STATUS + 1))
  else
    echo "./mcti-detect -t '$t1' -t '$t2' -g '$grp'  [OK - found intersection]"
  fi
}

expect_no_intersect() {
  t1="examples/tasks/$1"
  t2="examples/tasks/$2"
  grp="examples/groups/$3"

  text=$(run_test "$t1" "$t2" "$grp")
  if [ "$text" != "No intersection found" ]; then
    echo "*** Test with tasks [$t1, $t2] failed for group [$3]"
    echo "$text"
    STATUS=$((STATUS + 1))
  else
    echo "./mcti-detect -t '$t1' -t '$t2' -g '$grp'  [OK - no intersection]"
  fi
}

###############################################################################

expect_no_intersect \
  "taskA.json" "taskB.json" \
  "A-B-no-overlap.json"

expect_intersect_at \
  "taskA.json" "taskB.json" \
  "A-B-with-overlap.json" \
  "A1" "B3" 3

expect_intersect_at \
  "taskB.json" "taskC.json" \
  "B-C-with-overlap.json" \
  "C2" "B4" 4

expect_intersect_at \
  "taskB.json" "taskC.json" \
  "B-C-with-overlap2.json" \
  "B1" "C4" 5

expect_intersect_at \
  "taskC.json" "taskD.json" \
  "C-D-overlap.json" \
  "C2" "D15" 7

expect_no_intersect \
  "taskD.json" "taskE.json" \
  "D-E-no-overlap.json"

expect_intersect_at \
  "taskD.json" "taskE.json" \
  "D-E-with-overlap.json" \
  "D9" "E7" 5

if [ $STATUS -ne 0 ]; then
  echo "*** Error: $STATUS test(s) failed" 
fi
exit $STATUS
