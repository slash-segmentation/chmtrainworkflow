#!/usr/bin/env bats

setup() {
  CHM_TRAIN_WF="${BATS_TEST_DIRNAME}/../src/chmtrain.kar"
  KEPLER_SH="kepler.sh"
  WORKFLOW_FAILED_TXT="WORKFLOW.FAILED.txt"
  CREATECHMTRAINJOB_OUT="createchmtrainjob.out"
  README_TXT="README.txt"
  export THE_TMP="${BATS_TMPDIR}/"`uuidgen`
  /bin/mkdir -p $THE_TMP
  /bin/cp -a "${BATS_TEST_DIRNAME}/bin" "${THE_TMP}/."
  /bin/rm -rf ~/.kepler
}

teardown() {
  #echo "Removing $THE_TMP" 1>&2
  /bin/rm -rf $THE_TMP
}

#
# Verify $KEPLER_SH is in path if not skip whatever test we are in
#
skipIfKeplerNotInPath() {

  # verify $KEPLER_SH is in path if not skip this test
  run which $KEPLER_SH

  if [ "$status" -eq 1 ] ; then
    skip "$KEPLER_SH is not in path"
  fi

}

