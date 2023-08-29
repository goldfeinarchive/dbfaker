#!/bin/bash

# dbfaker
# A wrapper script for invoking dbfaker with docker
# Put this script in $PATH as `dbfaker`

PROGNAME="$(basename $0)"
ACCT=$(aws sts get-caller-identity --query Account --output text)
ECR="${ACCT}.dkr.ecr.us-east-1.amazonaws.com"

# Helper functions for guards
error(){
    error_code=$1
    echo "ERROR: $2" >&2
    echo "($PROGNAME wrapper version: $VERSION, error code: $error_code )" >&2
    exit $1
}
check_cmd_in_path(){
    cmd=$1
    which $cmd > /dev/null 2>&1 || error 1 "$cmd not found!"
}

# Guards (checks for dependencies)
check_cmd_in_path docker

DOCKER_CLI_OPTIONS=""

if [ -t 0 ]; then
  # Script is being called from an interactive shell"
  DOCKER_CLI_OPTIONS+="--interactive --tty "
fi

# When running on AWS servers, AWS access os controlled by IAM roles.  When running locally, we need to set these via
# environment variables.  If you are running locally, set these variables to your AWS credentials.

if [ -n "${AWS_ACCESS_KEY_ID}" ] && [ -n "${AWS_SECRET_ACCESS_KEY}" ]; then
  DOCKER_CLI_OPTIONS+="-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} "
  DOCKER_CLI_OPTIONS+="-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} "
fi

# If you want access to the output of email ripper after execution, then specify a path to a local directory
# via DBFAKER_DATA.  Otherwise, the data will be stored in a default volume location used by docker.
if [ -n "${DBFAKER_DATA}" ]; then
  DOCKER_CLI_OPTIONS+="--volume ${DBFAKER_DATA}:/app/data "
else
  DOCKER_CLI_OPTIONS+="--volume ${PWD}/docdata:/app/data "
fi

# Setting up looging.  When deploying in AWS DBFAKER_LOGS should be specified as /home/deploy/logs

if [ -n "${DBFAKER_LOGS}" ]; then
  DOCKER_CLI_OPTIONS+="--volume ${DBFAKER_LOGS}:/app/logs/ "
else
  DOCKER_CLI_OPTIONS+="--volume ${PWD}/logs:/app/logs "
fi

# Environmental variables for the dbfaker container can be set in a file and passed to the
# container via the the ENVFILE environment variable.
if [ -n "${ENVFILE}" ]; then
  DOCKER_CLI_OPTIONS+="--env-file ${ENVFILE} "
fi

docker run \
  --rm \
  $DOCKER_CLI_OPTIONS \
  "dbfaker-image" "$@"