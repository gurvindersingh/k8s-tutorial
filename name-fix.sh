#!/bin/bash

# Set the app deployment name
function setName {
	sed  -i '' -e "s/APPNAME/$APPNAME/g" dep.yaml
	sed -i '' -e "s/APPNAME/$APPNAME/g" ingress.yaml
	sed  -i '' -e "s/APPNAME/$APPNAME/g" dep-dp.yaml
	sed  -i '' -e "s/APPNAME/$APPNAME/g" ingress-ssl.yaml
}

# To revert back to orig state, uncomment
function revertName {
	sed -i '' -e "s/$APPNAME/APPNAME/g" dp1.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" ingress.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" dep-dp.yaml
	sed -i '' -e "s/$APPNAME/APPNAME/g" ingress-ssl.yaml
}

if [ "$1" == "revert" ]; then
	revertName
else
	setName
fi