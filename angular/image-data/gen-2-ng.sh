#!/bin/bash

echo "Start Angular Proto Compile"

printUsage() {
    echo "generate library grpc client for angular"
    echo " "
    echo "Usage: proto-2-angular  --proto-file <protobuf file to compile> --version <number|patch|minor|major>"
    echo " "
    echo "options:"
    echo " -h, --help                                       Show help"
    echo " -f, --proto-file                                 protobuff file to compile, is used also for generate the angular library inside the workspace"
    echo " -p, --proto-root                                 Override the path of protobuf <root path of protobuf files>"
    echo " -l, --lib-name                                   Override the name of the library inside the workspace"
    echo " --version                                        Set the version of the library"
    echo " --git-push                                       Push the new library on git repo on HEAD"
}

#Input volumes mouted at root
INPUT_VOLUME_FS=/input-volume
OUTPUT_VOLUME_FS=/output-volume
PROTO_VOLUME_FS=/proto-volume

PROTO_ROOT_DIR=$PROTO_VOLUME_FS
PROTO_FILE=""

echo $@
while test $# -gt 0; do
    case "$1" in
        -h|--help)
            printUsage
            exit 0
            ;;
        -p|--proto-root)
            shift
            if test $# -gt 0; then
                PROTO_ROOT_DIR=$1
                shift
            else
                echo "no directory specified"
                exit 1
            fi
            ;;       
        --git-push)
            GIT_PUSH=true
            shift
            ;;                     
        -f|--proto-file )
            shift
            if test $# -gt 0; then
                PROTO_FILE=$1
                LIB_NAME=$1
                shift
            else
                echo "no protobuf file specified"
                exit 1
            fi            
            ;;
        --version)
            shift
            if test $# -gt 0; then
                VERSION=$1
                shift
            else
                echo "no version specified"
                exit 1
            fi            
            ;;           
        -l|--lib-name )
            shift
            if test $# -gt 0; then
                LIB_NAME=$1
                shift
            else
                echo "no lib name specified"
                exit 1
            fi   
            ;;       
    esac
done    

if [[ -z $VERSION ]]; then
    VERSION="patch"
fi

if [[ -z $PROTO_FILE || -z $PROTO_ROOT_DIR ]]; then
    echo "Error: You must specify a proto file and proto directory"
    printUsage
    exit 1
fi



LIB_SRC=$INPUT_VOLUME_FS/projects/$LIB_NAME/src

echo "START: Executing \"generate-angular-lib.sh\"..."
bash ./generate-angular-lib.sh "$INPUT_VOLUME_FS" "$LIB_NAME"
echo "DONE: Executing \"generate-angular-lib.sh\"..."

echo "START: Executing \"compile-proto-2-stubs.sh\"..."
bash ./compile-proto-2-stubs.sh "$LIB_SRC/lib" "$PROTO_ROOT_DIR" "$PROTO_FILE"
echo "DONE: Executing \"compile-proto-2-stubs.sh\"..."

echo "START: Executing \"make-lib-entry-point.sh\"...$LIB_SRC"
bash ./make-lib-entry-point.sh $LIB_SRC
echo "DONE: Executing \"make-lib-entry-point.sh\"..."

echo "START: Executing \"compile-stubs-2-lib.sh\"..."
bash ./compile-stubs-2-lib.sh $INPUT_VOLUME_FS $LIB_NAME $VERSION
echo "DONE: Executing \"compile-stubs-2-lib.sh\"..."

if [[ $GIT_PUSH ]]; then
    echo "START: pushing the lib on repo..."
    cd $INPUT_VOLUME_FS/workspace/$LIB_NAME
    git add .
    git commit -am "add proto compiled"
    git push -u origin HEAD
    echo "DONE: pushing the lib on repo..."
fi

echo
echo ".proto to angular library compilation finished successfully."
echo "Files are located in given output directory."
echo
#echo "Also a npm-folder for publishing to NPM was created."
#echo "For publishing on NPM run: 'npm publish npm --access public' from output directory or run the publish-npm script."
#echo "(Check if versions in package.json and RELEASE.md are correct)"
