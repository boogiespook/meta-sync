#!/bin/sh 

##############################
## Satellite 6 Meta Sync    ##
##############################

###############################
## Script to sync artifacts
##
## ToDo: test
##
###############################

###############################
## Script settings & Constants
###############################
stem="hammer --csv "
append=""
org=" --organization-label chrisj "

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
    echo << EOF >> /root/.hammer/cli_config.yml
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

## Check /root/.hammer/cli_config.yml
## and get Organization

function exportProducts {
artifact="products"
append=" --enabled true"
echo " - Exporting $artifacts details to $artifact.csv"
$stem $artifact list $org $append | grep -v "^ID" > $artifact.csv
}

function exportRepositories {
artifact="repository"
prodId=$1
$stem $artifact list --product-id=$prodId $org $append
}

function get_template_list {
set -x
$(${stem} template list)
set +x
}

check_hammer_config_file
get_template_list
exportProducts


## Check a products.csv was create and b0rk if not

## For each of the products, list the repositories and write to reposForId_$id.csv
while read line
do
	id=$(echo $line | awk -F, '{print $1}' )
	name=$(echo $line | awk -F, '{print $2}' )
	echo " - Exporting repositories for $name"
	exportRepositories $id > reposForId_$id.csv
done < product.csv




