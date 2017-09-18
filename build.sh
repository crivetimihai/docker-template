#!/bin/sh
# Mihai Criveti
set -e

#------------------------------------------------------------------------------
# PARAMETERS
#------------------------------------------------------------------------------
DEFAULT_TARGET='ps' # FIXME

# DEFAULT
if [ $# -eq 0 ]; then
    echo "--- No arguments provided. See usage. Defaulting to ps target ---"
    BUILD_TARGET="${DEFAULT_TARGET}"
else
    BUILD_TARGET=""
fi

#for i in "$@"
#do
#    echo $i
#done

TARGETS='start stop rm clean distclean test bluemix stats stop build shell run ps inspect gitpush validate'
contains () {
    for param in $1; do
        [ "$param" = "$2" ] && return 0
    done
    return 1
}


#------------------------------------------------------------------------------
# CONFIGURATION
#------------------------------------------------------------------------------
BUILD_ROOT=$(dirname "${PWD}")
IMAGE_NAMESPACE=$(basename "${BUILD_ROOT}")
IMAGE_NAME=$(basename "${PWD}")
IMAGE_BUILD='latest'
DOCKER_IMAGE="${IMAGE_NAMESPACE}/${IMAGE_NAME}"
DOCKER_INSTANCE="${IMAGE_NAME}"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------


#=== FUNCTION: script_usage ===================================================
# DESCRIPTION: Display help
#==============================================================================
script_usage () {
    echo "Usage: $0 {start|stop|rm|clean|distclean|test|bluemix|stats|stop|build|shell|run|ps|inspect|gitpush|validate}"
}


#=== FUNCTION: docker_start ===================================================
#  DESCRIPTION: Start docker instance
#==============================================================================
docker_start () {
    echo '***' docker start "${DOCKER_INSTANCE}" '***'
    docker start "${DOCKER_INSTANCE}"
}


#=== FUNCTION: docker_stop ====================================================
# DESCRIPTION: Stop docker instance
#==============================================================================
docker_stop () {
    echo '***' docker stop "${DOCKER_INSTANCE}" '***'
    docker stop "${DOCKER_INSTANCE}"
}


#=== FUNCTION: docker_rm ======================================================
# DESCRIPTION: Remove docker instance
#==============================================================================
docker_rm () {
    echo '***' docker rm "${DOCKER_INSTANCE}" '***'
    docker rm "${DOCKER_INSTANCE}"
}


#=== FUNCTION: docker_rmi =====================================================
# DESCRIPTION: Remove docker image
#==============================================================================
docker_rmi () {
    echo '***' docker rmi "${DOCKER_IMAGE}" '***'
    docker rmi "${DOCKER_IMAGE}"
}


#=== FUNCTION: docker_rm ======================================================
# DESCRIPTION: Force remove docker instance (stop && rm)
#==============================================================================
docker_clean () {
    docker_stop
    docker_rm
}


#=== FUNCTION: docker_distclean ===============================================
# DESCRIPTION: Stop and rmove the instance and remove the docker image
#==============================================================================
docker_distclean () {
    docker_clean
    docker_rmi
}


#=== FUNCTION: docker_test ====================================================
# DESCRIPTION: Test running docker instance (nc / curl IP:exposed_port)
#==============================================================================
docker_test () {
    echo '***' ./testPorts.sh "${DOCKER_INSTANCE}" '***'
    ./testPorts.sh "${DOCKER_INSTANCE}"
}


#=== FUNCTION: docker_build ===================================================
# DESCRIPTION: Push docker image to bluemix
#==============================================================================
docker_bluemix () {
    echo '***' 'Push to bluemix here' '***'
    echo 'Push to bluemix here'

}


#=== FUNCTION: docker_stats ===================================================
# DESCRIPTION: Show statistics for running docker image
#==============================================================================
docker_stats () {
    echo '***' docker stats "${DOCKER_INSTANCE}" '***'
    docker stats "${DOCKER_INSTANCE}"
}


#=== FUNCTION: docker_stop ====================================================
# DESCRIPTION: Stop docker instance
#==============================================================================
docker_stop () {
    echo '***' docker stop "${DOCKER_INSTANCE}" '***'
    docker stop "${DOCKER_INSTANCE}"
}



#=== FUNCTION: docker_build ===================================================
# DESCRIPTION: Build docker image in working dir. as parent_dir/current_dir img
#==============================================================================
docker_build () {
    echo '***' docker build --rm=true '***'
    docker build \
	   --rm=true \
	   --tag="${IMAGE_NAMESPACE}/${IMAGE_NAME}:${IMAGE_BUILD}" \
	   .
}


#=== FUNCTION: docker_shell ===================================================
# DESCRIPTION: Run /bin/sh instead of CMD for a docker image
#==============================================================================
docker_shell () {
    echo '***' docker run '***'
    docker run \
	   --rm \
	   --name "${IMAGE_NAME}" \
	   --interactive=true \
	   --tty=true \
	   "${IMAGE_NAMESPACE}/${IMAGE_NAME}" \
	   /bin/sh
}


#=== FUNCTION: docker_run =====================================================
# DESCRIPTION: Run docker container (detatched)
#==============================================================================
docker_run () {
    echo '***' docker run '***'
    docker run \
	   --detach=true \
	   --name "${IMAGE_NAME}" \
	   -v "/volumes/${IMAGE_NAME}:/volumes/${IMAGE_NAME}" \
	   --publish-all=true \
	   "${IMAGE_NAMESPACE}/${IMAGE_NAME}"
}


#=== FUNCTION: docker_ps ======================================================
# DESCRIPTION: Display docker container information
#==============================================================================
docker_ps () {
    echo '***' docker ps -a '***'
    docker ps -a
}


#=== FUNCTION: docker_inspect =================================================
# DESCRIPTION: Inspect docker container instance
#==============================================================================
docker_inspect () {
    echo '***' docker inspect "${DOCKER_INSTANCE}" '***'
    docker inspect "${DOCKER_INSTANCE}"
}


#=== FUNCTION: docker_gitpush =================================================
# DESCRIPTION: Push changes in current directory to git (add, commit, push)
#==============================================================================
docker_gitpush () {
    echo '*** Pushing changes to git ***'
    git add .
    git commit
    git push -u origin master
}


#=== FUNCTION: docker_validate ================================================
# DESCRIPTION: Run static analysis tools (shlint, shellcheck, docker_lint, etc)
#==============================================================================
docker_validate () {
    echo '*** Validating shell scripts and Dockerfile ***'

    # npm install -g dockerlint dockerfile_lint

    echo '*** Running dockerfile_lint ***'
    dockerfile_lint -f Dockerfile

    echo '*** Running dockerlint ***'
    dockerlint -f Dockerfile

    echo '*** Running shellcheck ***'
    shellcheck ./*.sh

    #./validate.sh
}


#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
# for i in $(grep '()' build.sh  | awk '{print $1}'); do echo -e "    ${i##*_})\n        ${i}\n        ;;"; done
# Loop over arguments..
for BUILD_TARGET in "$@"; do
    case ${BUILD_TARGET} in
        start)
            docker_start
            ;;
        stop)
            docker_stop
            ;;
        rm)
            docker_rm
            ;;
        clean)
            docker_clean
            ;;
        distclean)
            docker_distclean
            ;;
        test)
            docker_test
            ;;
        bluemix)
            docker_bluemix
            ;;
        stats)
            docker_stats
            ;;
        stop)
            docker_stop
            ;;
        build)
            docker_build
            ;;
        shell)
            docker_shell
            ;;
        run)
            docker_run
            ;;
        ps)
            docker_ps
            ;;
        inspect)
            docker_inspect
            ;;
        gitpush)
            docker_gitpush
        ;;
        validate)
            docker_validate
            ;;
        usage|man|help|-man|-help)
            script_usage
            ;;
        *)
            echo "Invalid target: ${BUILD_TARGET}"
            script_usage
            exit 1
            ;;
    esac
done

