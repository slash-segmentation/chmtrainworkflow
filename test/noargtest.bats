#!/usr/bin/env bats

load test_helper

#
# Test CHM Train Workflow with no arguments
#
@test "chmtrain.kar with only -CWS_outputdir set" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  mkdir "$THE_TMP/images"

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
  [ "${lines[0]}" == "simple.error.message=Training data not found" ] 
  [[ "${lines[1]}" == "detailed.error.message=No images path found in "* ]]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM Train workflow" ]
  [ "${lines[1]}" == "Job Name: jobname" ]
  [ "${lines[2]}" == "User: user" ] 
  [ "${lines[3]}" == "Workflow Job Id: jobid" ]
  [ "${lines[5]}" == "Create CHM Train Job Script: /sharktopus/megashark/cws/bin/panfishCHM/createCHMTrainJob.sh" ]
  [ "${lines[8]}" == "Train options:  -s 2 -l 2" ] 
}

