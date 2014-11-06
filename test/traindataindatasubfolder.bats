#!/usr/bin/env bats

load test_helper

#
#
#
@test "training data is under data subfolder" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  mkdir -p "$THE_TMP/data/images"

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

  # Check output of createchmtrainjob.out file
  [ -s "$THE_TMP/$CREATECHMTRAINJOB_OUT" ]

  run cat "$THE_TMP/$CREATECHMTRAINJOB_OUT"
  [ "$status" -eq 0 ]
  echo "Output from $CREATECHMTRAINJOB_OUT file.  Should only see this if something below fails :${lines[@]}:"
  [[ "${lines[0]}" == "basictrain $THE_TMP/run -l $THE_TMP/data/labels -i $THE_TMP/data/images -S 3 -L 4"* ]]

}

