#!/bin/bash

# Set the app deployment name
function setName {
	sed  -i '' -e "s/APPNAME/$APPNAME/g" nb-dep.yaml
	sed -i '' -e "s/APPNAME/$APPNAME/g" nb-ing.yaml
	sed  -i '' -e "s/APPNAME/$APPNAME/g" nb-local.yaml
	sed  -i '' -e "s/APPNAME/$APPNAME/g" nb-ing-ssl.yaml
}

# To revert back to orig state, uncomment
function revertName {
	sed -i '' -e "s/$APPNAME/APPNAME/g" nb-dep.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" nb-ing.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" nb-local.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" nb-ing-ssl.yaml
}

if [ "$1" == "revert" ]; then
	revertName
else
	setName
fi