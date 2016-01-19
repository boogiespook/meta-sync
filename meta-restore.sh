#!/usr/bin/bash

##############################
## Satellite 6 Meta Restore ##
##############################

###############################
## Script to sync artifacts
##
## ToDo: Everything
##
###############################

###############################
## Script settings & Constants
###############################

stem="hammer --csv "
append=""
org_label=$(hammer organization list | grep ^[0-9] | awk -F '|' '{print $3}' | tr -d " \t\n\r")
org=$" --organization-label ${org_label}"

###############
## Functions ##
###############

## Output utility functions

function printOK {
  echo -e "${GREEN}[OK]\t\t $1 ${RESET}" | tee -a $TMPDIR/success
}

function printWarning {
  ((WARNINGS=WARNINGS+1))
  echo -e "${ORANGE}[WARNING] $WARNINGS\t $1 ${RESET}" | tee -a $TMPDIR/warnings
}

function printError {
    ((ERRORS=ERRORS+1))
  echo -e "${RED}[ERROR] $ERRORS\t $1 ${RESET}" | tee -a $TMPDIR/errors
}


function remedialAction {
  echo -e "$1" | tee -a $TMPDIR/remedialAction
}

function check_hammer_config_file {
    if [[ ! -f /root/.hammer/cli_config.yml ]]
    then
        echo -e "A hammer config file has not been created.  This is used to interogate foreman.
    Please do the following:
    mkdir ~/.hammer
    chmod 600 ~/.hammer
    cat << EOF > /root/.hammer/cli_config.yml
      :foreman:
           :host: 'https://$(hostname -f)'
           :username: 'admin'
           :password: 'password'

    EOF"
        echo -n "Would you like me to create this file ? [y|n] :"
        read yesno
        if [ ${yesno} == 'y' ]
        then
            echo -n "Please enter your admin username : "
            read username
            echo -n "Please enter your admin password : "
            read password

            mkdir ~/.hammer
            chmod 600 ~/.hammer
cat << EOF > /root/.hammer/cli_config.yml
:foreman:
     :host: 'https://$(hostname -f)'
     :username: '${username}'
     :password: '${password}'

EOF
            echo "/root/.hammer/cli_config.yml has been created"
            else
                exit 2
            fi

    fi

}

function write_upload_manifest {
cat << EOF >> $output_script
manifest_file="/root/manifest.zip"
if [ ! -f $manifest_file ]
then
    printError "Unable to find manifest $manifest_file, please make sure it exists."
    exit 1
else
    printOK "Manifest file $manifest_file found, attempting upload."
    hammer subscription upload ${org} --file $manifest_file
    if [ $? -eq 0]
    then
        printOK "Upload successful"
    else
        printError "Unable to uplad manifest $manifest_file"
        exit 1
    fi
fi
EOF
}

function restore_templates {
templates=$( 
}

## Main
check_hammer_config_file
write_upload_manifest



