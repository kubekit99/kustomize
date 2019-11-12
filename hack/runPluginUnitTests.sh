#!/usr/bin/env bash
# Copyright 2019 The Kubernetes Authors.
# SPDX-License-Identifier: Apache-2.0

# TODO: get rid of this script, make individual targets
# in the makefile.

# Run this script with no arguments from the repo root
# to test all the plugins.

# Want this to keep going even if one test fails,
# to see how many pass, so do not errexit.
set -o nounset
# set -o errexit
set -o pipefail

rcAccumulator=0

function onLinuxAndNotOnTravis {
  [[ ("linux" == "$(go env GOOS)") && (-z ${TRAVIS+x}) ]] && return
  false
}

function runTest {
  local file=$1
  local code=0
  if grep -q "// +build notravis" "$file"; then
    if onLinuxAndNotOnTravis; then
      go test -v -tags=notravis $file 
      code=$?
    else
      # TODO: make work for non-linux
      echo "Not on linux or on travis; skipping $file"
    fi
  else
    go test -v $file
    code=$?
  fi
  rcAccumulator=$((rcAccumulator || $code))
  if [ $code -ne 0 ]; then
    echo "Failure in $d"
  fi
}

function scanDir {
  pushd $1 >& /dev/null
  echo "Testing $1"
  for t in $(find . -name '*_test.go'); do
    runTest $t
  done
  popd >& /dev/null
}

if onLinuxAndNotOnTravis; then
  # Some of these tests have special deps.
  make $(pwd)/hack/tools/bin/helm
  make $(pwd)/hack/tools/bin/kubeval
fi

for goMod in $(find ./plugin -name 'go.mod'); do
  d=$(dirname "${goMod}")
  if [[ "$d" == "./plugin/someteam.example.com/v1/gogetter" ]]; then
    echo "Skipping broken $d"
  else
    scanDir $d                                                             
  fi
done

if [ $rcAccumulator -ne 0 ]; then
  echo "FAILURE; exit code $rcAccumulator"
  exit 1
fi


