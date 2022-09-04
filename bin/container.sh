#!/bin/bash

# ---
# Functions
# ---

# Documentation
display_help() {
    echo "Usage: [variable=value] $0 -o" >&2
    echo
    echo "   -h   , --help              display help"
    echo "   -p   , --pull              pull latest container"
    echo "   -r -o, --run_container -o  run container with o in (l, p, a)"
    echo
    # echo some stuff here for the -a or --add-options
    exit 1
}

make_variables() {
	set -a # automatically export all variables
	source .env
	set +a

	# Check if variable is defined in .env file
	if [[ -z ${REGISTRY_USER} ]]; then
		echo "Error! Variable REGISTRY_USER is not defined" 1>&2
		exit 1

	fi

	PROJECT_DIR=$(git rev-parse --show-toplevel)
	PROJECT_NAME=$(basename ${PROJECT_DIR})

    if [[ -z ${DOCKER_IMAGE_NAME} ]]; then
        DOCKER_IMAGE_NAME=${PROJECT_NAME}
    fi

	DOCKER_REGISTRY=docker.pkg.github.com
    DOCKER_IMAGE=${DOCKER_REGISTRY}/${REGISTRY_USER}/${PROJECT_NAME}/${DOCKER_IMAGE_NAME}

	DOCKER_TAG=${DOCKER_TAG:-latest}
    DOCKER_IMAGE_TAG=${DOCKER_IMAGE}:${DOCKER_TAG}

	RED='\033[1;31m'
	BLUE='\033[1;34m'
	GREEN='\033[1;32m'
	NC='\033[0m'
	BOLD=$(tput bold)
    NORMAL=$(tput sgr0)
}

# Get container id
get_container_id() {
    echo "Getting container id for image ${DOCKER_IMAGE_TAG} ..."

    CONTAINER_ID=$(docker ps | grep "${DOCKER_IMAGE_TAG}" | awk '{ print $1}')

    if [[ -z "${CONTAINER_ID}" ]]; then
        echo "No container id found"

    else
        echo "Container id: ${BOLD}${CONTAINER_ID}${NORMAL}"

    fi
}

pull() {
    docker pull 
    docker tag 
}

run_container() {

    make_variables
    get_container_id

    if [[ -z "${CONTAINER_ID}" ]]; then
        echo "Creating Container from image ${DOCKER_IMAGE_TAG} ..."

        echo "Running container with options ${RUN_LATEX_OPTION}"

        if [[ "${RUN_LATEX_OPTION}" == "-l" ]]; then
            echo "Running container with letter option"
            docker run -i -t --env-file .env -e DOCKER_USER=$USER -e uid=$UID -v $(pwd):/home/${PROJECT_NAME} -it ${DOCKER_IMAGE_TAG} /bin/bash -c "bash bin/run_latex.sh -l"
        elif [[ "${RUN_LATEX_OPTION}" == "-p" ]]; then
            echo "Running container with publications option"
            docker run -i -t --env-file .env -e DOCKER_USER=$USER -e uid=$UID -v $(pwd):/home/${PROJECT_NAME} -it ${DOCKER_IMAGE_TAG} /bin/bash -c "bash bin/run_latex.sh -p"
        elif [[ "${RUN_LATEX_OPTION}" == "-a" ]]; then
            echo "Running container with all options"
            docker run -i -t --env-file .env -e DOCKER_USER=$USER -e uid=$UID -v $(pwd):/home/${PROJECT_NAME} -it ${DOCKER_IMAGE_TAG} /bin/bash -c "bash bin/run_latex.sh -a"
        # else
        #     echo "Running container with default option"
        #     docker run -i -t --env-file .env -e DOCKER_USER=$USER -e uid=$UID -v $(pwd):/home/${PROJECT_NAME} -it ${DOCKER_IMAGE_TAG} /bin/bash "./bin/run_latex.sh"
        fi

        echo "Done"

    else
	    echo "Container already running"
	fi

}
RUN_LATEX_OPTION=$2
# Available options
while :
do
    case "$1" in
        -h | --help)
            display_help  # Call your function
            exit 0
            ;;

        -p | --pull)
            pull  # Call your function
            exit 0
            ;;

        -r | --run_container)
            run_container  # Call your function
            exit 0
            ;;

        "")
            display_help  # Call your function
            break
            ;;

        --) # End of all options
            shift
            break
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            ## or call function display_help
            exit 1
            ;;
        *)  # No more options
            break
            ;;
    esac
done


set -a # automatically export all variables
source .env
set +a