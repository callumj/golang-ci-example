# Example Go repo with CI build support

This repo demonstrates a Go application being built in a CI environment without messing with the system `GOPATH`. 

`build.sh` sets a temporary `GOPATH` which contains this application, it then performs a go get on this temporary go package which forces dependencies to be resolved. Finally the application is cross compiled to Linux, Darwin (OS X) and Windows and tar gzipped into the builds directory under the correct `VERSION`.

You may wish to see the `build.sh` yourself for a better explanation.

The build script will automatically copy the `VERSION` into a constant under `utils.AppVersion`.