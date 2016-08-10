#!/bin/bash
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG=${GIT_BRANCH#*/}

function usage() {
    echo "$0 <image name>"
    echo "build Jenkins DIND Agent docker images."
    echo ""
    echo "<image name> is the image name, with prefix."
    echo ""
    exit -1
}

function preflight {
    if [ ! -d ".git" ]
    then
        echo "This directory does not contain a .git directory."
        echo "Please run this script from the jenkins-dind-agent root directory."
        echo ""
        exit -2
    fi
}

function dock_build {
    local image=$1
    local tag=$2
    local file=$3
    
    echo "Building $image:$tag ..."
    docker build -t $image:$tag -f $file .
}

function build_images() {
    if [ "x$1" == "x" ]
    then
        usage
    else
        image_name="$1"
    fi

    preflight

    for i in Dockerfile*
    do
        local possible_tag=${i#*.}
        local tag_suffix=""
        if [ "$possible_tag" != "Dockerfile" ]
        then
            tag_suffix="-${possible_tag}"
        fi

        final_tag="$TAG${tag_suffix}"

        dock_build "$image_name" "$final_tag" "$i"
    done
}

build_images $1
