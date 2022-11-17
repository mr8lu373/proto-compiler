#/bin/bash
PROTO_PATH=$1


echo "generate proto local source"
mkdir -p protos
for i in "${@:2}"; do cp $PROTO_PATH/$i/*.proto protos ; done