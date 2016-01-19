#!/usr/bin/bash
manifest_file="/root/manifest.zip"
if [ ! -f  ]
then
    printError "Unable to find manifest , please make sure it exists."
    exit 1
else
    printOK "Manifest file  found, attempting upload."
    hammer subscription upload  --organization-label  --file 
    if [ 0 -eq 0]
    then
        printOK "Upload successful"
    else
        printError "Unable to uplad manifest "
	exit 1
    fi
fi
manifest_file="/root/manifest.zip"
if [ ! -f  ]
then
    printError "Unable to find manifest , please make sure it exists."
    exit 1
else
    printOK "Manifest file  found, attempting upload."
    hammer subscription upload  --organization-label Nixgeek --file 
    if [ 127 -eq 0]
    then
        printOK "Upload successful"
    else
        printError "Unable to uplad manifest "
	exit 1
    fi
fi
