#Root directory of the compilation -> public api file + package.js
ANGULAR_WORKSPACE_DIR=$1
LIB_NAME=$2
LIB_VERSION=${3:-'patch'}
cd $ANGULAR_WORKSPACE_DIR

# -------------- Start the angular build process
echo "Starting angular build process of library package ..."
echo "Executing build (prod)"
cd projects/$LIB_NAME
CURRENT_VERSION=$(npm version)
if [[ $CURRENT_VERSION == $LIB_VERSION ]];
then
	LIB_VERSION="patch"
fi
npm version $LIB_VERSION
cd -
npm run build $LIB_NAME
echo "Finished angular build."

if [[ ! -d dist/$LIB_NAME ]];
then
	echo "Error build library"
	exit 1
fi

echo "Starting publish"
cp /image-data/default-lib-files/.npmrc dist/$LIB_NAME/
cd dist/$LIB_NAME/
npm publish
echo "Finished publish angular build."
