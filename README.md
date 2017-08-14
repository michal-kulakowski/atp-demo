# Advanced Threat Protection demo scenario featuring FortiSIEM

This repository contains set of scripts and configuration files needed to set up ATP demo instance on empty FortiSIEM virtual appliance. Scripts are compatible and tested with FortiSIEM 4.9.

## Purpose
Complex SIEM demo scenarios are time consuming to build. The goal of this package is to streamline that process. Package contains:

1. Device discovery data and logs showing specific scenario
2. FortiSIEM rule to interpret it
3. Sample automatic remediation script
4. Documented and predictable demo flow with talking points, clicks and screenshots

## Installation

Clone this repository (`git clone https://github.com/michal-kulakowski/atp-demo.git`). Refer to `doc/install.html`.

## Usage

Refer to `doc/use.html`

## Changelog
Version 1.0

* initial release

Version 2.0

* added remediation script example
* added dashboards to demo flow
* no restart on installation required anymore

## Future Enhancements

* Script to artificially create traffic baseline so that it can be shown in the demo
