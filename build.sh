#!/bin/bash

FULL_NAME="github.com/callumj/example"
APP_NAME="example"
RESOURCES="utils app main.go"

if [[ -z "$BUILDBOX_BRANCH" ]]
then
  BUILDBOX_BRANCH=`git branch | sed -n '/\* /s///p'`
fi
VERSION=`cat VERSION`

if ! [[ "${BUILDBOX_BRANCH}" == "master" ]]
then
  if [[ "${BUILDBOX_BRANCH}" == "development" ]]
  then
    VERSION="${VERSION}-dev"
  else
    echo "Builds are only performed on master!"
    exit -1
  fi
fi

rm -r -f tmp/go
rm -r -f builds/${VERSION}

# vet the source (capture errors because the current version does not use exit statuses currently)
echo "Vetting..."
VET=`go tool vet . 2>&1 >/dev/null`

cur=`pwd` 

if ! [ -n "$VET" ]
then
  echo "All good"
  mkdir -p tmp/go
  mkdir -p builds/
  mkdir tmp/go/src tmp/go/bin tmp/go/pkg
  mkdir -p tmp/go/src/${FULL_NAME}
  cp -R ${RESOURCES} tmp/go/src/${FULL_NAME}

  go_src=$'package utils\nconst AppVersion string = "'"${VERSION}"$'"'
  echo "$go_src" > tmp/go/src/${FULL_NAME}/utils/version.go

  mkdir -p builds/${VERSION}/darwin_386 builds/${VERSION}/darwin_amd64 builds/${VERSION}/linux_386 builds/${VERSION}/linux_amd64
  mkdir -p builds/${VERSION}/windows_386 builds/${VERSION}/windows_amd64
  GOPATH="${cur}/tmp/go"
  echo "Getting"
  GOPATH="${cur}/tmp/go" go get -d .
  echo "Starting build"

  GOPATH="${cur}/tmp/go" GOOS=darwin GOARCH=386 go build -o builds/${VERSION}/darwin_386/${APP_NAME}

  GOPATH="${cur}/tmp/go" GOARCH=amd64 GOOS=darwin go build -o builds/${VERSION}/darwin_amd64/${APP_NAME}

  GOPATH="${cur}/tmp/go" GOOS=linux GOARCH=amd64 go build -o builds/${VERSION}/linux_amd64/${APP_NAME}

  GOPATH="${cur}/tmp/go" GOOS=linux GOARCH=386 go build -o builds/${VERSION}/linux_386/${APP_NAME}

  GOPATH="${cur}/tmp/go" GOOS=windows GOARCH=amd64 go build -o builds/${VERSION}/windows_amd64/${APP_NAME}

  GOPATH="${cur}/tmp/go" GOOS=windows GOARCH=386 go build -o builds/${VERSION}/windows_386/${APP_NAME}
else
  echo "$VET"
  exit -1
fi

# rewrite the binaries

FILES=builds/${VERSION}/*/${APP_NAME}
for f in $FILES
do
  str="/${APP_NAME}"
  repl=""
  path=${f/$str/$repl}
  tar  -C ${path} -cvzf "${f}.tgz" ${APP_NAME}
  rm ${f}
done