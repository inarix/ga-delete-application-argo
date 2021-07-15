#!/bin/bash

if [[ -z $INPUT_TOKEN ]] 
then
    echo "[$(date +"%m/%d/%y %T")] Missing token input required to handle API requests"
    exit 1
elif [[ -z $INPUT_APPLICATION ]]
then
    echo "[$(date +"%m/%d/%y %T")] Missing application input as the name of the application to delete"
    exit 1
elif [[ -z $INPUT_ARGOSERVER ]]
then
    echo "[$(date +"%m/%d/%y %T")] Missing argoserver input as the host of your ArgoCD server (https://argocd.example.com/)"
    exit 1
fi

APPLICATION_EXISTS_HTTP_CODE=$(curl --write-out %{http_code} --silent --output /dev/null -H "Authorization: Bearer $INPUT_TOKEN"  $INPUT_ARGOSERVER/api/v1/applications/$INPUT_APPLICATION)

if [[ $APPLICATION_EXISTS_HTTP_CODE -ne 200 ]]
then
# APPLICATION DOES NOT EXISTS !!!
echo "[$(date +"%m/%d/%y %T")] Application $INPUT_APPLICATION does not exists in $INPUT_ARGOSERVER (code: $APPLICATION_EXISTS_HTTP_CODE)"
exit 404
fi

echo "[$(date +"%m/%d/%y %T")] Application $INPUT_APPLICATION does exists, it will be deleted soon"
APPLICATION_HAS_BEEN_DELETED_HTTP_CODE=$(curl -X DELETE --write-out %{http_code} --silent --output /dev/null -H "Authorization: Bearer $INPUT_TOKEN"  $INPUT_ARGOSERVER/api/v1/applications/$INPUT_APPLICATION?cascade=true)

if [[ $APPLICATION_HAS_BEEN_DELETED_HTTP_CODE -ne 200 ]]
then
echo "[$(date +"%m/%d/%y %T")] An error occured during deletion of application $INPUT_APPLICATION (code: $APPLICATION_HAS_BEEN_DELETED_HTTP_CODE)"
fi

echo "[$(date +"%m/%d/%y %T")] $INPUT_APPLICATION has been deleted successfully (code: $APPLICATION_HAS_BEEN_DELETED_HTTP_CODE)"
exit 0

