# -------------- Create pulbic-api.ts from the commonjs output of the proto compilation step
# to pass a single file to webpack as an entry point

#Root directory of the compilation ( -> public api file in this directory + proto commonjs stubs are in this )
TEMP_SRC_DIRECTORY=$1

DEFAULT_FILES_DIR=default-lib-files
FILE_EXT=".ts"

#Can also be specified in provided directory -> no auto generation
PUBLIC_API_FILE=$TEMP_SRC_DIRECTORY/public-api$FILE_EXT

if [ ! -f $PUBLIC_API_FILE ]; then
    echo "No public-api$FILE_EXT specified in source directory -> copying default file"
    cp $DEFAULT_FILES_DIR/public-api$FILE_EXT $PUBLIC_API_FILE

    # Trying to auto generate public-api file
    cd $TEMP_SRC_DIRECTORY

    #ES6 Style exports
    export PREFIX="import * as "
    export FROM=" from '"
    export POSTFIX="';"
    export EXPORT="export default {"    
    #find . -iname "*$FILE_EXT" -exec bash -c 'printf "$PREFIX./%s$POSTFIX\n" "${@%.*}"' _ {} + >> $public-api$FILE_EXT
    #find ./lib -iname "*.pb*$FILE_EXT" -exec bash -c 'printf "$PREFIX%s$POSTFIX\n" "${@%.*}"' _ {} + >> public-api$FILE_EXT
     for full_name in $(find ./lib -iname "*.pb*$FILE_EXT"); 
     do 
        xpath=${full_name%/*}; 
        xbase=${full_name##*/};         
        xpref=${xbase%.*}; 
        EXPORT_NAME=$(sed 's/\./_/g' <<<$xpref)
        FULL_NAME_NO_TS=$(sed 's/\.ts//g' <<<$full_name)
        echo "$PREFIX$EXPORT_NAME$FROM$FULL_NAME_NO_TS$POSTFIX" >> public-api$FILE_EXT; 
        EXPORT="$EXPORT...$EXPORT_NAME,"
    done
    EXPORT="$EXPORT}"
    echo "">>public-api$FILE_EXT
    echo $EXPORT>>public-api$FILE_EXT
fi
