#!/bin/sh 

##############################
## Satellite 6 Meta Sync    ##
##############################

######################
## Work In Progress 
##
## ToDo: test
##
######################

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

#exportProducts

## Check a products.csv was create and b0rk if not

## For each of the products, list the repositories and write to reposForId_$id.csv
while read line
do
	id=$(echo $line | awk -F, '{print $1}' )
	name=$(echo $line | awk -F, '{print $2}' )
	echo " - Exporting repositories for $name"
	exportRepositories $id > reposForId_$id.csv
done < product.csv




