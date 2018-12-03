#!/bin/bash
set -e

BASE_PATH='./images'

# Delete loaded vars
clearVars() {
	unset TAG
	unset HUB_REPO
}

## TODO: PUSH IMAGE
pushImage () {
	docker push $1
}

dockerLogin() {
	if [ -z "$DOCKER_USERNAME" ]; then
		echo "[ERROR] Can't login into dockerhub"
		exit 1
	fi

	if [ -z "$DOCKER_PASSWORD" ]; then
		echo "[ERROR] Can't login into dockerhub"
		exit 1
	fi
	
	echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
}

## TODO: docker image build -t $HUB_REPO:$TAG $DOCKERFILE
buildImage() {
	DIRECTORY=$1
	BUILD_FILE="$DIRECTORY/.docker-build"
	DOCKERFILE="$DIRECTORY/Dockerfile"

	source $BUILD_FILE

	if [ -z "$TAG" ]; then
		echo "[ERROR] Tag is not defined in $BUILD_FILE. Skipping build for $DOCKERFILE"
		return 0
	fi

	if [ -z "$HUB_REPO" ]; then
		echo "[ERROR] Dockerfile is not defined in $BUILD_FILE. Skipping build for $DOCKERFILE"
		return 0
	fi

	IMAGE_NAME="$HUB_REPO:$TAG"

	docker image build -t $IMAGE_NAME $DIRECTORY

	pushImage $IMAGE_NAME
	
}

## Try to login into docker
dockerLogin

## Search for every docker build file
for DIRECTORY in `find $BASE_PATH -name '.docker-build' |  sed -E 's|/[^/]+$||' | sort -u`; do
	# Check if dockerfile
	if [ ! -f "$DIRECTORY/Dockerfile" ]; then
		echo "$DIRECTORY/Dockerfile does not exists"
		exit 1
	else
		buildImage $DIRECTORY
		clearVars
	fi
done
