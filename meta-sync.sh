#!/bin/sh 

##############################
## Satellite 6 Meta Sync    ##
##############################

###############################
## Script to sync artifacts
##
## ToDo:
##
###############################

###############################
## Script settings & Constants
###############################
stem="hammer --csv "
append=""
org_label=$(hammer organization list | grep ^[0-9] | awk -F '|' '{print $3}' | tr -d " \t\n\r")
org=$" --organization-label ${org_label}"

function blank_script {
echo "#!/usr/bin/bash" > populate.sh
}
function write_products_manifest {
    ${stem} product list ${org} --enabled true | grep ^[0-9] | awk -F',' '{print $1}' > products.csv
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
${stem} lifecycle-environment list $org > lifecycles.csv
}

function writeContentViews {
${stem} content-view list $org > cv.csv
}
function get_template_list {
command="${stem} template list"
$(command)
}

function write_activation_key_summary {
${stem} activation-key list ${org} > activation_key_summary.csv
}

function write_activation_key_detail {
for key in $(${stem} activation-key list ${org} | grep ^[0-9] | awk -F, '{print $1}')
do
	${stem} activation-key info --id=${key} > activation-key-info-${key}.csv
done
}

function write_hostgroup_summary {
${stem} hostgroup list --per-page 10000  > hostgroup_summary.csv
}

function write_hostgroup_info {
for hgig in $(${stem} hostgroup list --per-page 10000 | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} hostgroup info --id=${hgig} > hostgroup_info_${hgig}.csv
done
}

function write_gpgkeys {
${stem} gpg list $org > gpgkeys.csv
numkeys=$(cat gpgkeys.csv | grep ^[0-9] | wc -l)
if [ $numkeys -lt 1 ]
then
	printWarning "No gpgkeys found"
fi

}

function write_gpgkey_info {
for gpgkeys in $(${stem} gpg list $org --per-page 10000 | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} gpg info ${org} --id=${gpgkeys} > gpgkey_${gpgkeys}.csv
done
}

function write_locations {
${stem} location list  > locations.csv
}

function write_location_info {
for location_id in $(${stem} location list --per-page 10000 | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} location info --id=${location_id} > location_${location_id}.csv
done
}

function write_sync_plans {
${stem} sync-plan list ${org} > sync-plan-summary.csv
}

function write_sync_plan_info {
for syncpanid in $(${stem} sync-plan list ${org}  | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} sync-plan info ${org} --id=${syncpanid} > sync_plan_${syncpanid}.csv
done
}

function write_os_list {
${stem} os list > os-summary.csv
}

function write_os_info {
for os in $(${stem} os list | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} os info --id=${os} > os_info_${os}.csv
done
}

function write_domain_list {
${stem} domain list > domain-summary.csv
}

function write_domain_info {
for domain in $(${stem} domain list | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} domain info --id=${domain} > domain_info_${domain}.csv
done
}

function write_subnet_list {
${stem} subnet list > subnet-summary.csv
}

function write_subnet_info {
for subnet in $(${stem} subnet list | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} subnet info --id=${subnet} > subnet_info_${subnet}.csv
done
}

function write_hostcollection_plans {
${stem} host-collection list ${org} > host-collection-summary.csv
}

function write_hostcollection_plan_info {
for hostcollectionid in $(${stem} host-collection  list ${org}  | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} host-collection info ${org} --id=${hostcollectionid} > host-collection_${hostcollectionid}.csv
done
}

function write_templates_summary {
${stem} template list > templates-summary.csv
}

function write_template_info {
for template in $(${stem} template list | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} template info --id=${template} > template_info_${template}.csv
done
}

function write_template_template {
for template in $(${stem} template list | grep ^[0-9] | awk -F, '{print $1}')
do
    ${stem} template dump --id=${template} > template_dump_${template}.csv
done
}

blank_script
printOK "Blank script"
check_hammer_config_file
printOK "hammer config file"
write_products_manifest
printOK "products manifest"
get_template_list
printOK "template list"
writeLifecycles
printOK "lifecycle environments"
writeContentViews
printOK "Content Views"
write_activation_key_summary
printOK "Activation keys"
write_activation_key_detail
printOK "Activation key detail"
write_hostgroup_summary 
printOK "hostgroup list"
write_hostgroup_info 
printOK "hostgroup detailed information"
write_gpgkeys
printOK "GPG Key list"
write_gpgkey_info
printOK "GPG Key info"
write_sync_plans
printOK "Sync plans"
write_sync_plan_info
printOK "sync plan info"
write_os_list
printOK "OS list"
write_os_info
printOK "OS info"
write_domain_list
printOK "Domain list"
write_domain_info
printOK "domain info"
write_subnet_list
printOK "subnet list"
write_subnet_info
printOK "subnet info"
write_hostcollection_plans
printOK "host collection plans"
write_hostcollection_plan_info
printOK "host collection plan info"
write_templates_summary
printOK "template summary"
write_template_info
printOK "template info"
write_template_template
printOK "template dump"

## Check a products.csv was create and b0rk if not

## For each of the products, list the repositories and write to reposForId_$id.csv
while read line
do
	id=$(echo $line | awk -F, '{print $1}' )
	name=$(echo $line | awk -F, '{print $2}' )
	exportRepositories $id > reposForId_$id.csv
done < products.csv


