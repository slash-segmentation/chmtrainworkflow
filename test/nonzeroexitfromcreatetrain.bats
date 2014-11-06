#!/usr/bin/env bats

load test_helper

#
# CHM Train workflow where create chm train job has non zero
# exit code
#
@test "chmtrain.kar where create chm train job has nonzero exit code and stage and level set" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  mkdir "$THE_TMP/images"

  echo "1,,,/bin/echo" > "$THE_TMP/bin/createchmtrain.tasks"
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainingdata $THE_TMP -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -Stage 3 -Level 4 -createCHMTrainJob $THE_TMP/bin/createchmtrain -CWS_outputdir $THE_TMP $CHM_TRAIN_WF

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
  echo "Output from $CREATECHMTRAINJOB_OUT file.  Should only see this if something below fails :${lines[@]}:"
  [[ "${lines[0]}" == "basictrain $THE_TMP/run -l $THE_TMP/labels -i $THE_TMP/images -S 3 -L 4"* ]]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM Train workflow" ]
  [ "${lines[1]}" == "Job Name: foo" ]
  [ "${lines[2]}" == "User: johnny" ]
  [ "${lines[3]}" == "Workflow Job Id: 43" ]
  [ "${lines[8]}" == "Train options:  -s 3 -l 4" ]

}

