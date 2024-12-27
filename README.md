# crime-portal-infra

[![Build Status](https://dev.azure.com/hmcts/PlatformOperations/_apis/build/status%2FHeritage%2FCrime%20Portal%2Fhmcts.crime-portal-infra?repoName=hmcts%2Fcrime-portal-infra&branchName=main)](https://dev.azure.com/hmcts/PlatformOperations/_build/latest?definitionId=860&repoName=hmcts%2Fcrime-portal-infra&branchName=main)

## Introduction

The Crime Portal service comprises of a thin client user interface, with the back-end application formed by a series of Service-oriented architecture (SOA) components, deployed as a Docker image to an Azure hosted environment. The Crime Portal storage is hosted in a Postgres database.

Communication between Libra and Crime Portal is maintained by additional Gateway and Data Access components. Libra sends content data, in the form of binary and XML, through these Gateway services to be consumed by external endpoints who have subscribed to this data. These communication services also allows the Crime Portal application to enquire on case and person information held within the Libra database. These Crime Portal services are referred to as ‘Follow a Case’ and ‘Follow a Person’ respectively. 

As well as external interfaces, there is an administration role performed by Crime IT staff. 

## Overview

This README file provides an overview of the project, including VM details, networking configurations, automation/installation of the operating system, relevant documentation links, diagrams and operational information.

Resource group: `crime-portal-rg-prod`
KeyVault: `crime-portal-kv-prod`

## Responsibilities

| Area of Responsibility                        | Responsible Party |
| --------------------------------------------- | ----------------- |
| Azure Infrastructure                          | PlatOps           |
| AADSSHLoginForLinux                           | PlatOps           |
| Domain Join                                   | PlatOps           |
| OS/Software/SQL config                        | CGI               |

## VM Details

Crime Portal is deployed to two environments, Staging (STG), and Production (Prod) as two sets of redundant virtual machines:


| VM Name                          | VM SKU           | Operating System |
| -------------------------------- | ---------------- | ---------------- |
| crime-portal-frontend-vm01-{env} | Standard D4ds v5 | Ubuntu 22.04     |
| crime-portal-frontend-vm02-{env} | Standard D4ds v5 | Ubuntu 22.04     |
| crime-portal-ldap-vm01-{env}     | Standard D4ds v5 | Ubuntu 22.04     |
| crime-portal-ldap-vm02-{env}     | Standard D4ds v5 | Ubuntu 22.04     |

## Disk configurations

Each Crime Portal VM is configured with one OS Disk only. All disks are configured to use Server Side Encryption (SSE) utilizing a Platform Managed Key (PMK)

| Disk Name                                 | Disk Type | Disk SKU         | Disk Size (GB) | Encryption   |
| ----------------------------------------- | --------- | ---------------- | -------------- | ------------ |
| crime-portal-frontend-vm01-{env}_OsDisk_1 | OS        | Standard SSD LRS | 128            | SSE with PMK |
| crime-portal-frontend-vm02-{env}_OsDisk_1 | OS        | Standard SSD LRS | 128            | SSE with PMK |
| crime-portal-ldap-vm01-{env}_OsDisk_1     | OS        | Standard SSD LRS | 128            | SSE with PMK |
| crime-portal-ldap-vm02-{env}_OsDisk_1     | OS        | Standard SSD LRS | 128            | SSE with PMK |

## Backup Policy


The Crime Portal VMs are Backed up daily. The backup process is managed by a Azure Recovery Services Vault in each environment.

| Environment | Backup Frequency      | Daily Backup Retention Period | Monthly Backup Retention Period | Yearly Backup Retention Period |
| ----------- | --------------------- | ----------------------------- | ------------------------------- | ------------------------------ |
| Production  | Daily at 01:00 AM UTC | 28 Days                       | 12 Months                       | 1 Year                         |
| Staging     | Daily at 01:00 AM UTC | 7 Days                        | 12 Months                       | 1 Year                         |

## Application Gateway

The application gateway load balances traffic between the two Crime-Portal VMs and provides HA functionality. The application gateway also handles the SSL termination for the traffic coming from Libra in IH. The certificate is stored in Key Vault and rotated by the enterprise-acme function apps. The Crime-Portal pipeline has a scheduled trigger to get the latest certificate available.

## FrontDoor

The Front Door provides SSL termination of inbound traffic from the internet as well as provide WAF functionality to protect the application. The Front Door is used to route traffic to the Application Gateway via the Hub Palos.

## Database

The Crime Portal Database is implemented using a PostgreSQL flexible server instance in each environment. The database is configured with an automatic daily backup and the backups are retained for 35 days.

Host: crime-portal-postgresql-{env}.postgres.database.azure.com

## VM Access

The Crime Portal VMs can be accessed over the HMCTS Jumpboxes or bastions using the az CLI with the SSH extension. The Crime Portal VMs use Azure Entra ID to authenticate, so it is necessary to use `az ssh` as opposed to plain `ssh` when logging in.

## Networking Configs

Inbound/outbound traffic in Crime Portal is detailed in the below HLD diagram:

![A Design diagram detailing the inbound, outbound and internal traffic flows within the Crime Portal infrastructure, listing relevant ports and services](images/HLD.png)

## Additional Software

The following software is installed on the VMs using virtual machine extensions:

- Docker
- AAD SSH Login for Linux
- Azure Monitor
- Dynatrace One Agent
- Splunk Universal Forwarder
- Tenable Nessus

## Change Process

Changes to Crime Portal must go through the [change management process](https://hmcts.github.io/ops-runbooks/Change-Requests/How-to-raise-a-Change-request.html#raise-a-change-request). Crime Portal falls under the 'Libra Crime Portal' service offering and changes require approval from the 'Libra Crime Portal Business Change Approvals' in addition to the normal change approvers. [CHG5000501](https://mojcppprod.service-now.com/nav_to.do?uri=change_request.do?sys_id=eb3e7d301bb2841cd9b81f4c2e4bcbed) may be used as a template change request from which to clone.

## Crime Portal Documentation

The High Level Design (HLD) for Crime Portal can be found on [sharepoint](https://justiceuk.sharepoint.com/:w:/r/sites/DTSPlatformOperations/_layouts/15/Doc.aspx?sourcedoc=%7BF287484A-1A51-4E9E-AB75-8E33B3F49924%7D&file=DLRM%20Crime%20Portal%20HLD%20v1.0%20-%20Copy.docx&action=default&mobileredirect=true).

The Low Level Design (LLD) for Crime Portal can be found on [sharepoint](https://justiceuk.sharepoint.com/:w:/r/sites/DTSPlatformOperations/_layouts/15/Doc.aspx?sourcedoc=%7BD7D28853-C4B6-4A1C-ADDE-BD2C888256EC%7D&file=HMCTS%20Crime%20Portal%20LLD%20v0.4%20-%20Copy.docx&action=default&mobileredirect=true)