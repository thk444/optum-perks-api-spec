#!/bin/bash

set -eu
echo $AZURE_REPOSITORY_PASSWORD | docker login --username "LivefrontSearchRx" --password-stdin livefrontsearchrx.azurecr.io
az login --service-principal --username $AZURE_SP_APP_ID --password $AZURE_SP_PASSWORD --tenant $AZURE_SP_TENANT
docker build -t searchrx-api-spec .
docker tag searchrx-api-spec "livefrontsearchrx.azurecr.io/searchrx-api-spec"
docker push "livefrontsearchrx.azurecr.io/searchrx-api-spec"
az webapp restart --name "livefront-searchrx-api-spec" --resource-group SearchRx
