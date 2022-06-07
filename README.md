# Introduction

This GitHub show how to leverage Azure System-assigned and User-assigned Managed Identity to access Azure Resources.

This git repository illustrate a common web scenario when you have a web application trying to connect to multiple database.  The server name and the object ID of the user-assigned identity is saved in an Azure KeyVault accessible using a system-assinged managed identity.

For more information about Azure Managed Identities click [here](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)

# Architecture

![architecture](/diagram/architecture.drawio.png)

This is all resources created with this sample:

1. One Azure Virtual Network with three subnets, one for the VNET Integration, one for the two private endpoints and finally one for the jumpbox.
2. An Azure Web App with a System-assigned Managed Identity and one User-assigned Managed Identity
3. An Azure Key Vault, the vault will keep the two connection string used in the application
4. An Azure SQL Server with two Azure SQL Databases
5. Two Azure Private DNS Zones, one for the KeyVault and one for the Azure SQL Server
6. A jumpbox for debug purposes

This sample create an Azure WebApp where a simple application is deployed.  The WebApp is leveraging [Entity Framework](https://docs.microsoft.com/en-us/aspnet/entity-framework) to create connection to the two Azure SQL Database.

![ef](/diagram/ef.png)

Here you can see we configure two DBContext, one for the TodoDB and one for the OrderDB.

The **connection string** needed to create those two clients is saved in Azure KeyVault as a **secret**.

The WebApp has two identities

A System-assigned Identity that provides access to the Azure KeyVault to read the secrets.

![architecture](/diagram/systemassigned.png)

A User-assigned Identity that is used to connect to both database, this avoid storing any username and password anywhere.

![architecture](/diagram/userassigned.png)

This is the main page of the Web App.


# Install the demo

## Fork the GitHub repository

The first step it's to Fork this Github Repository

## Create GitHub Secrets

You will need to create some [GitHub Secrets](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-codespaces) before running the GitHub Actions.

Here the list of the secrets you need to create

| Name | Value | Link |
|------|-------| ------|
| ADMIN_LOGIN | The username to login to the Jumpbox and SQL Azure. the Azure SQL Database support SQL authentication and Azure AD Authentication | [Azure AD Only Authentication](https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-azure-ad-only-authentication-create-server?tabs=azure-cli&view=azuresql)
| ADMIN_PASSWORD | The password to login to the Jumpbox and SQL Azure
| AZURE_CREDENTIALS | [GitHub Action](https://github.com/marketplace/actions/azure-login)
| PA_TOKEN_MANAGED_IDENTITY_WEBAPP | GitHub Personal access tokens to write Repository secret | [GitHub Action](https://github.com/gliech/create-github-secret-action)

## Run the GitHub Action to create Azure Resources

Now, go to the GitHub Actions tab and execute the action called **Create Azure Resources**

## Configure the ADMIN of the Azure SQL Server

Now, you need to assign an admin to the Azure SQL Server, this can be any user in your Azure AD but it's recommended to assign an AD Group.

