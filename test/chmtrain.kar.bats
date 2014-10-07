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

#
# Test CHM Train Workflow with no arguments
#
@test "chmtrain.kar with only -CWS_outputdir set" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

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
  [ "${lines[1]}" == "Job Name: jobname" ]
  [ "${lines[2]}" == "User:  user" ] 
  [ "${lines[3]}" == "Workflow Job Id: jobid" ]
  [ "${lines[6]}" == "Train options:  -s 2 -l 2" ] 
}

#
# CHM Train workflow where create chm train job has non zero
# exit code
#
@test "chmtrain.kar where create chm train job has nonzero exit code and stage and level set" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  echo "1,,,/bin/echo" > "$THE_TMP/bin/createchmtrain.tasks"
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainingdata /bar -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -Stage 3 -Level 4 -createCHMTrainJob $THE_TMP/bin/createchmtrain -CWS_outputdir $THE_TMP $CHM_TRAIN_WF

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
  [[ "${lines[0]}" == "basictrain $THE_TMP/run -l /bar/labels -i /bar/images -S 3 -L 4"* ]]

  # Check output of README.txt file
  [ -s "$THE_TMP/$README_TXT" ]
  run cat "$THE_TMP/$README_TXT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" == "CHM Train workflow" ]
  [ "${lines[1]}" == "Job Name: foo" ]
  [ "${lines[2]}" == "User:  johnny" ]
  [ "${lines[3]}" == "Workflow Job Id: 43" ]
  [ "${lines[6]}" == "Train options:  -s 3 -l 4" ]

}

#
# CHM Train workflow where create chm train job has non zero
# exit code
#
@test "chmtrain.kar where run chm train job has nonzero exit code" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  /bin/mkdir -p "$THE_TMP/run"
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runCHMTrainViaPanfish.sh

  echo "1,error,,/bin/echo" > "$THE_TMP/run/runCHMTrainViaPanfish.sh.tasks"

  echo "0,,,/bin/echo" > "$THE_TMP/bin/createchmtrain.tasks"
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainingdata /bar -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -Stage 3 -Level 4 -createCHMTrainJob $THE_TMP/bin/createchmtrain -CWS_outputdir $THE_TMP $CHM_TRAIN_WF

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
  [ "${lines[0]}" == "simple.error.message=Unable to run CHM Train job" ]
  [[ "${lines[1]}" == "detailed.error.message=Non zero exit code received from "* ]]

}


# CHM Train workflow successful run
#
@test "chmtrain.kar successful run" {

  # verify $KEPLER_SH is in path if not skip this test
  skipIfKeplerNotInPath

  /bin/mkdir -p "$THE_TMP/run"
  /bin/ln -s $THE_TMP/bin/command $THE_TMP/run/runCHMTrainViaPanfish.sh

  echo "0,,," > "$THE_TMP/run/runCHMTrainViaPanfish.sh.tasks"

  echo "0,,,/bin/echo" > "$THE_TMP/bin/createchmtrain.tasks"
  # Run kepler.sh with no other arguments
  run $KEPLER_SH -runwf -redirectgui $THE_TMP -trainingdata /bar -CWS_user johnny -CWS_jobname foo -CWS_jobid 43 -Stage 3 -Level 4 -createCHMTrainJob $THE_TMP/bin/createchmtrain -CWS_outputdir $THE_TMP $CHM_TRAIN_WF

  # Check exit code
  [ "$status" -eq 0 ]

  # Check output from kepler.sh
  [[ "${lines[0]}" == "The base dir is"* ]]

  echo "Output from kepler.  Should only see this if something below fails ${lines[@]}"

  # Verify we got a workflow failed txt file
  [ ! -e "$THE_TMP/$WORKFLOW_FAILED_TXT" ]
  
} 
 
