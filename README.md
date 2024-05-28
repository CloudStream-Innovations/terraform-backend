# Terraform State Backend Deployment

## Overview
This repository contains Terraform code to deploy a state backend for managing the infrastructure state. The state backend is a crucial component of Terraform that stores the state file, which keeps track of the resources provisioned by Terraform.

## Note
**One-Time Deployment:**  
The state backend should only be deployed once at the beginning of the project. Subsequent Terraform configurations should reference the existing state backend rather than deploying a new one.

## Deployment
Please note that this repository forms a submodule in the main-solution repository. Deploy this backend from the main-solution repository unless you are familiar with how this works and what you wish to achieve.
