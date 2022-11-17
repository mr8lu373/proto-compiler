#/bin/bash!
WORKSPACE=$1
LIB_NAME=$2

echo "Checking the library $LIB_NAME"

if [[ -d "$WORKSPACE/projects/$LIB_NAME" && ! -f "$WORKSPACE/projects/$LIB_NAME/package.json" ]];
then
	rm -rf "$WORKSPACE/projects/$LIB_NAME"
fi

if [[ ! -d "$WORKSPACE/projects/$LIB_NAME" || ! -f "$WORKSPACE/projects/$LIB_NAME/package.json" ]];
then
	cd $WORKSPACE
	echo "Library $LIB_NAME not exixst, generate"
	ng generate library --defaults --force $LIB_NAME 
	cd -
fi

LIB_BASE=$WORKSPACE/projects/$LIB_NAME
LIB_SRC=$LIB_BASE/src
echo "Checking repository in package.json..."
cd $LIB_BASE

npm pkg set "name"="@proto-all-angular/$LIB_NAME"

PUBLISH_REPO_URL=$(npm pkg get "publishConfig.@proto-all-angular:registry")
if [[ -z $PUBLISH_REPO_URL ]];
then
	echo "publishConfig not found add it..."
	npm pkg set "publishConfig.@proto-all-angular:registry"="https://gitlab.medusa-labs.com/api/v4/projects/1357/packages/npm/"
fi

cd -

rm -f $LIB_SRC/public-api.ts_
mv $LIB_SRC/public-api.ts $LIB_SRC/public-api.ts_