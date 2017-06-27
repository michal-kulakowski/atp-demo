# Advanced Threat Protection demo scenario featuring FortiSIEM

This repository contains set of scripts and configuration files needed to set up ATP demo instance on empty FortiSIEM virtual appliance. Scripts are compatible and tested with FortiSIEM 4.9.

## Purpose
Complex SIEM demo scenarios are time consuming to build. The goal of this package is to streamline that process. Package contains:

1. Device discovery data and logs showing specific scenario
2. FortiSIEM rule to interpret it
3. Documented and predictable demo flow with talking points, clicks and screenshots

## Usage
1. Log onto your FortiSIEM instance (super) as root
2. Clone github repository to convenient location
	* `git clone git@github.com:michal-kulakowski/atp-demo.git`
3. Enter ATP demo directory
	* `cd atp-demo`
4. Set up file based discovery
	* `./setup.sh`
5. Load the rule
	* `view rules.xml`
	* copy contents
	* Click Analytics > Rules > Import
	* Paste & Import
6. Open doc/index.html with your browser and execute demo scenario described

## Future Enhancements

* Script to artificially create traffic baseline so that it can be shown in the demo