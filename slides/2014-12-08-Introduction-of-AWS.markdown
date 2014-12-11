---
title: Introduction of AWS
date: December 8, 2014
tags: slide
description: Introduction of AWS
---

% Introduction of AWS
% Wei Shi
% December 8, 2014

# Xen

## Xen toolstacks

![Toolstacks](/images/toolstacks.png)

## XCP & XenServer

- XenServer is Citrix' commercial distribution of XCP. XCP contains a subset of
    features of XenServer functionality
- But...

------------------

- 2013/06/25, Citrix announced that XenServer would be fully open sourced and
    that it will be made available from XenServer.org. XenServer always has
    been based on open source software: containing the Xen hypervisor, the
    Linux kernel, the CentOS Linux distribution and user tools.

## Xen on Linux

- All Linux distros (except RHEL6/RHEL7)
- http://wiki.xen.org/wiki/Category:Host_Install

## XenServer on Linux

------------------

![XenServer](/images/xenserver.png)

## Xen & Cloud

- Amazon Web Services
- Rackspace Hosting
- IaaS Trusted Public S5(Fujitsu)
- Verizon Cloud
- IBM SoftLayer
- Liquid Web
- Linode
- OrionVM

------------------

![Cloud support](/images/support.png)

# Amazon Web Services

## Services
### Services at a glance

## What to do with AWS

- Store public or private data.
- Host a static website
- Host a dynamic website
- ...

## How to access AWS

- AWS Management Console
- AWS Command Line Interface (AWS CLI)
- Command Line Tools
- AWS Software Development Kits (SDK)
    * APIs that are specific to your programming language or platform.
- Query APIs
    * Low-level APIs that you access using HTTP requests.

## What about the price

- Pay only for what you use.(But...)
- New AWS account is eligible for the AWS Free Tier within the first 12 months.
- http://aws.amazon.com/pricing/

## IAM
### AWS Identity and Access Management

- AWS account
- IAM user

------------------

![Consolidated Billing](/images/ConsolidatedBilling_IAM.png)

## Solution for Static Website

- Amazon S3
- Amazon Route 53
- CloudFront

------------------

![Hosting a Static Website on AWS](/images/AWS_StaticWebsiteHosting_Architecture.png)

## Solution for Web App

- Amazon EC2
- Amazon EBS
- Amazon RDS
- Elastic Load Balancing
- Auto Scaling
- CloudWatch
- Amazon Route 53

------------------

![Hosting a Web App on AWS](/images/AWS_WebAppHosting_Architecture.png)

------------------

![Regions](/images/aws_regions.png)

------------------

![Regions](/images/regions.png)

## Features of EC2

- Virtual computing environments, known as instances

- Preconfigured templates for your instances, known as Amazon Machine Images
(AMIs), that package the bits you need for your server (including the operating
system and additional software)

- Various configurations of CPU, memory, storage, and networking capacity for
your instances, known as instance types

- Secure login information for your instances using key pairs (AWS stores the
public key, and you store the private key in a secure place)

------------------

- Storage volumes for temporary data that's deleted when you stop or terminate
your instance, known as instance store volumes

- Persistent storage volumes for your data using Amazon Elastic Block Store
(Amazon EBS), known as Amazon EBS volumes

- Multiple physical locations for your resources, such as instances and Amazon
EBS volumes, known as regions and Availability Zones

- A firewall that enables you to specify the protocols, ports, and source IP
ranges that can reach your instances using security groups

------------------

- Static IP addresses for dynamic cloud computing, known as Elastic IP addresses

- Metadata, known as tags, that you can create and assign to your Amazon EC2
resources

- Virtual networks you can create that are logically isolated from the rest of
the AWS cloud, and that you can optionally connect to your own network, known
as virtual private clouds (VPCs)

## multi-tenancy problem

- Noisy neighbors

# Other Cloud Providers

## Rackspace
### OnMetal Cloud Servers are single-tenant, bare-metal systems that you can:

- Provision in minutes via an OpenStack® API.
- Mix and match with virtual cloud servers.
- Pay by the minute.

------------------

![Web request flow](/images/onmetal-flowchart.png)

## Google Cloud Platform

- Google App Engine - PaaS
- Google Compute Engine uses KVM as the hypervisor
- Google Container Engine - Kubernetes managed GCE nodes in the cluster

