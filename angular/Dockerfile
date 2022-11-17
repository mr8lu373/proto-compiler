FROM node:18.7.0-buster-slim as debugging_image

RUN apt update && apt install -y parallel gnupg gnupg2 wget sed vim tmux curl unzip tree

# --------------- Installing protoc (Protobuf compiler binary)
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v21.5/protoc-21.5-linux-x86_64.zip -O /tmp/protoc.zip &&\
 unzip -o /tmp/protoc.zip  -d /tmp/protoc/ &&\
 cp /tmp/protoc/bin/protoc /usr/local/bin/protoc &&\
 cp -r /tmp/protoc/include/* /usr/local/include &&\
 chmod a+x /usr/local/bin/protoc

# --------------- Copy all files from "image-data" directory to docker container
WORKDIR /image-data
ADD image-data /image-data

# --------------- Install npm modules required for compilation with angular
RUN npm i -g @angular/cli@^14.0.0 @angular/compiler-cli@^14.0.0

RUN npm i -g @ngx-grpc/common @ngx-grpc/core @ngx-grpc/grpc-web-client @ngx-grpc/well-known-types grpc-web
RUN npm i -g @ngx-grpc/protoc-gen-ng @types/google-protobuf
#RUN ng new workspace --no-create-application


#RUN npm run reinstall

# mount:
# workspace of ng project = input-volume
# dest folder src of library = output-volume
# root folder of protos = proto-volume

# --------------- Entrypoint when the docker container is executed
ENTRYPOINT ["bash"]

# -----------------------------------------------------------------------------------------------------
