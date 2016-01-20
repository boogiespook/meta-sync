#!/bin/sh 
###################################
## Create lifecycle environments ##
## in the correct order as per   ##
## the meta-export script        ##
## Note: $1 is the org name      ##
###################################

file="lifecycles.csv"
env="Library"
org=$1
if [[ $org == "" ]]
then
	echo "ERROR - No Organization give"
	echo "Usage: $0 OrgName"
	exit 1
fi

while [[ $env != "" ]]
do
	newEnv=$(awk -F, -v env=$env '$3 == env {print $2}' ${file})
	if [[ $newEnv == "" ]]
        then
		break
	fi
	echo "hammer lifecycle-environment create --name $newEnv --description $newEnv --organization $org --prior $env"

        #echo " Create $newEnv"
        env=$newEnv
        
done
