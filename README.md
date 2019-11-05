# SearchRx API Specification

The API spec for SearchRx mobile and web client apps.

## Contents

- [Azure Setup](#azure-setup)
  - [Azure Websites](#azure-websites)
  - [App Service Setup (One-time Only)](#app-service-setup-one-time-only)
  - [Other Useful Azure Commands](#other-useful-azure-commands)

## Azure Setup

### Azure Website

* https://livefront-searchrx-api-spec.azurewebsites.net/

    Browsable Swagger UI for the latest API spec version.

### App Service Setup (One-time Only)

1. Login via your web browser by running the following command:

        $ az login

2. Create a service principal account. We use this account to authenticate via the CI server. Keep a copy of the output on file, since we won't be able to look up these values in the future.

        $ az ad sp create-for-rbac --name "LivefrontSearchRx"
        {
          "appId": "<app>",
          "displayName": "LivefrontSearchRx",
          "name": "http://LivefrontSearchRx",
          "password": "<password-A>",
          "tenant": "<tenant>"
        }

3. Authenticate via the service principal account:

        $ az login --service-principal --username <app> --password <password-A> --tenant <tenant>

4. Create a resource group to hold the dev and staging web apps:

        $ az group create --location centralus --name SearchRx \
            && az appservice plan create --name SearchRx --resource-group SearchRx --is-linux --sku B1 \
            && az acr create --resource-group SearchRx --name LivefrontSearchRx --sku Basic --admin-enabled true \
            && az acr login --name LivefrontSearchRx

5. Push initial Docker images to Azure. Subsequent images will be created automatically via Travis CI.

        $ docker build -t searchrx-api-spec .
        $ docker tag searchrx livefrontsearchrx.azurecr.io/searchrx-api-spec
        $ docker push livefrontsearchrx.azurecr.io/searchrx-api-spec

6. Record the Azure Docker repository password.

        $ az acr credential show --name LivefrontSearchRx
        {
          "passwords": [
            {
              "name": "password",
              "value": "<password-B>"
            },
            {
              "name": "password2",
              "value": "<password-C>"
            }
          ],
          "username": "LivefrontSearchRx"
        }

7. Use `<password-B>` to create web apps for dev and staging.

        $ az webapp create --name livefront-searchrx-api-spec \
              --resource-group SearchRx \
              --plan SearchRx \
              --deployment-container-image-name "livefrontsearchrx.azurecr.io/searchrx-api-spec" \
              --docker-registry-server-user LivefrontSearchRx \
              --docker-registry-server-password "<password-B>" \
            && az webapp config set --name livefront-searchrx-api-spec \
              --resource-group SearchRx \
              --always-on true \
            && az webapp deployment container config --name livefront-searchrx-api-spec \
              --resource-group SearchRx \
              --enable-cd true \
            && az webapp log config --name livefront-searchrx-api-spec \
              --resource-group SearchRx \
              --docker-container-logging filesystem

8. Configure Travis CI with the following Azure secrets.

| Name                      | Description                                                                                                         |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| AZURE_REPOSITORY_PASSWORD | Password used to push new Docker images to the Azure Docker repository. `<password-B>` in the example output above. |
| AZURE_SP_APP_ID           | App ID for the Azure service principal account. `<app>` in the example output above.                                |
| AZURE_SP_PASSWORD         | Password for the Azure service principal account. `<password-A>` in the example output above.                       |
| AZURE_SP_TENANT           | Tenant ID for the Azure service principal account. `<tenant>` in the example output above.                          |

### Other Useful Azure Commands

Tail the logs:

        $ az webapp log tail --name livefront-searchrx-api-spec --resource-group SearchRx

Restart an App Service:

        $ az webapp restart --name livefront-searchrx-api-spec --resource-group SearchRx

