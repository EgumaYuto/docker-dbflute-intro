#!/bin/sh

BUILD_VERSION=$1

if [ -z $BUILD_VERSION ]; then
	BUILD_VERSION="latest"
fi
echo "build version : $BUILD_VERSION"

echo "\n"
echo "======================================== Image Build"
docker build ./ -t dbflute/dbflute-intro:$BUILD_VERSION

echo "\n"
echo "========================================= Image Push"
docker push dbflute/dbflute-intro:$BUILD_VERSION
