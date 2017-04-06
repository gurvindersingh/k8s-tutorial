#!/bin/bash

# Set the app deployment name
function setName {
	sed  -i '' -e "s/APPNAME/$APPNAME/g" nb-dep.yaml
	sed  -i '' -e "s/APPNAME/$APPNAME/g" README.md
}

# To revert back to orig state, uncomment
function revertName {
	sed -i '' -e "s/$APPNAME/APPNAME/g" nb-dep.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" README.md
}

if [ "$1" == "revert" ]; then
	revertName
else
	setName
fi