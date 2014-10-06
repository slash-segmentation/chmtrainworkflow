#!/usr/bin/env bats

setup() {
  CHM_TRAIN_WF="${BATS_TEST_DIRNAME}/../src/chmtrain.kar"
  KEPLER_SH="kepler.sh"
  WORKFLOW_FAILED_TXT="WORKFLOW.FAILED.txt"
  CREATECHMTRAINJOB_OUT="createchmtrainjob.out"
  README_TXT="README.txt"
  export THE_TMP="${BATS_TMPDIR}/"`uuidgen`
  /bin/mkdir -p $THE_TMP
}

teardown() {
  /bin/rm -rf $THE_TMP
}
#
# Test CHM Train Workflow with no arguments
#
@test "chmtrain.kar with only -CWS_outputdir set" {

  # verify $KEPLER_SH is in path if not skip this test
  run which $KEPLER_SH

  if [ "$status" -eq 1 ] ; then
    skip "$KEPLER_SH is not in path"
  fi

  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -CWS_outputdir $THE_TMP $CHM_TRAIN_WF 

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

  # Verify we got a workflow failed txt file
  [ -s "$THE_TMP/$WORKFLOW_FAILED_TXT" ] 

  # Check output of workflow failed txt file
  run cat "$THE_TMP/$WORKFLOW_FAILED_TXT"
  [ "$status" -eq 0 ] 
  [ "${lines[0]}" == "simple.error.message=Unable to create CHM Train job" ] 
  [[ "${lines[1]}" == "detailed.error.message=Non zero exit code received from "* ]]

  # Check output of createchmtrainjob.out file
  [ -s "$THE_TMP/$CREATECHMTRAINJOB_OUT" ]

  run cat "$THE_TMP/$CREATECHMTRAINJOB_OUT"
  [ "$status" -eq 0 ] 
  [[ "${lines[0]}" == *"No such file or directory"* ]]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM Train workflow" ]
  [ "${lines[1]}" == "Job Name: taskname" ]
  [ "${lines[2]}" == "User:  user" ] 
  [ "${lines[3]}" == "Workflow Task Id: taskid" ]
  [ "${lines[6]}" == "Train options:  -s 2 -l 2" ] 
}


