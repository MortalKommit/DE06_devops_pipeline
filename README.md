![Github Actions Build Status](https://github.com/MortalKommit/DE06_devops_pipeline/actions/workflows/actions.yml/badge.svg)

# Project 06 : Building a CI/CD Pipeline in Azure

## Overview

This project creates a Continuous Integration/Continuous Delivery pipeline in Microsoft Azure from scratch following the Agile project management strategy.  
In the first phase, under Agile Planning, tasks and features(stories) are listed and categorized with relevant tools.
In Continuous Integration, tools that check and test code for errors are used.
Finally in Continous Delivery, usage of the GitOps paradigm is explored, with tooling that help build and deploy applications in cloud-native environments.


## Project Plan

### Agile Planning
* [Public Trello Planning Board](https://trello.com/b/kMLggxDk/data-engineer-project-6-ci-cd-pipeline-in-azure)
* [Google Sheets Link](https://docs.google.com/spreadsheets/d/1T-81GkagNErgDYWhceByO3krUganOfq5i20evQmcKzU/edit?usp=sharing)

The plan for this project initially included simple setup and deployment of the app. However, as a result of Azure deprecating support for older versions of Python  
in Azure shell, the default version of python was changed to python 3.9.
![Python 3.9 Screen](images/azure-shell-python.png)

This caused issues with running the project in the Azure shell environment, so a separate pre-compiled version of python had to be installed (due to a lack of privileges to run apt-get), using a miniconda distribution.

## Instructions

![Basic Architecture Diagram](images/building-a-ci-cd-pipeline.png)

<TODO:  Instructions for running the Python project.  How could a user with no context run this project without asking you for any help.  Include screenshots with explicit steps to create that work. Be sure to at least include the following screenshots:

* Project running on Azure App Service

* Project cloned into Azure Cloud Shell

* Passing tests that are displayed after running the `make all` command from the `Makefile`

* Output of a test run

* Successful deploy of the project in Azure Pipelines.  [Note the official documentation should be referred to and double checked as you setup CI/CD](https://docs.microsoft.com/en-us/azure/devops/pipelines/ecosystems/python-webapp?view=azure-devops).

* Running Azure App Service from Azure Pipelines automatic deployment

* Successful prediction from deployed flask app in Azure Cloud Shell.  [Use this file as a template for the deployed prediction](https://github.com/udacity/nd082-Azure-Cloud-DevOps-Starter-Code/blob/master/C2-AgileDevelopmentwithAzure/project/starter_files/flask-sklearn/make_predict_azure_app.sh).
The output should look similar to this:

```bash
udacity@Azure:~$ ./make_predict_azure_app.sh
Port: 443
{"prediction":[20.35373177134412]}
```

* Output of streamed log files from deployed application

> 

## Enhancements

<TODO: A short description of how to improve the project in the future>

## Demo 

<TODO: Add link Screencast on YouTube>


