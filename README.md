# Introduction

This GitHub show how to leverage Azure System-assigned and User-assigned Managed Identity to access Azure Resources.

This git repository illustrate a common web scenario when you have a web application trying to connect to multiple database.  The server name and the object ID of the user-assigned identity is saved in an Azure KeyVault accessible using a system-assinged managed identity.

For more information about Azure Managed Identities click [here](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)

# Architecture

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



![architecture](/diagram/architecture.drawio.png)

1. The user is accessing the website
2. The WebApp is accessing the Azure Resources using [VNET Integration](https://docs.microsoft.com/en-us/azure/app-service/overview-vnet-integration), this is needed because Azure KeyVault and Azure SQL are leveraging both private endpoint.
3. The WebApp retrieve the connection string **TodoCnxString** and **OrderCnxString** from Azure KeyVault.
4. The WebApp create one client for each database.
5. When the user try to go to one of the page t