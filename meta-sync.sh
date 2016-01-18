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
org_label=$(hammer organization list | grep ^[0-9] | awk -F '|' '{print $3}' | tr -d " \t\n\r")
org=$" --organization-label ${org_label}"

function write_products_manifest {
    ${stem} product list --organization-id=1 --enabled true | grep ^[0-9] | awk -F',' '{print $1}' > products.csv
}

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

function exportRepositories {
artifact="repository"
prodId=$1
$stem $artifact list --product-id=$prodId $org $append | grep ^[0-9]
}

function writeLifecycles {
hammer --csv lifecycle-environment list $org > lifecycles.csv
}

function writeContentViews {
hammer --csv content-view list $org > cv.csv
}
function get_template_list {
command="${stem} template list"
$(command)
}

function write_activation_key_summary {
hammer --csv activation-key list ${org} > activation_key_summary.csv
}

function write_activation_key_detail {
for key in $(hammer --csv activation-key list ${org} | grep ^[0-9] | awk -F, '{print $1}')
do
	hammer --csv activation-key info --id=${key} > activation-key-info-${key}.csv
done
}

function write_hostgroup_summary {
hammer --csv hostgroup list --per-page 10000  > hostgroup_summary.csv
}

function write_hostgroup_info {
set -x
for hgig in $(hammer --csv hostgroup list --per-page 10000 | grep ^[0-9] )
do
    hammer --csv hostgroup info --id=${hgig} > hostgroup_info_${hgig}.csv
done
set +x
}

check_hammer_config_file
write_products_manifest
get_template_list
writeLifecycles
writeContentViews
write_activation_key_summary
write_activation_key_detail
write_hostgroup_summary 
write_hostgroup_info 

## Check a products.csv was create and b0rk if not

## For each of the products, list the repositories and write to reposForId_$id.csv
while read line
do
	id=$(echo $line | awk -F, '{print $1}' )
	name=$(echo $line | awk -F, '{print $2}' )
	echo " - Exporting repositories for $name"
	exportRepositories $id > reposForId_$id.csv
done < products.csv


