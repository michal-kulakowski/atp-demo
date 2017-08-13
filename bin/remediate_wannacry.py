#!/usr/bin/env python
############################################################################
## TITLE: Demo remediation capabilities of FortiSIEM
## AUTHOR: mkulakowski@fortinet.com
## BASED ON CODE BY: ifranzoni@fortinet.com; dtomic@fortinet.com cdurkin@fortinet.com
##
## DESCRIPTION: 
## THIS SCRIPT INTERPRETS INCIDENT PARAMETERS PASSED BY SAMPLE WANNACRY DETECTION
## DEMO RULE DEFINED UNDER https://github.com/michal-kulakowski/atp-demo AND WALLS
## ACTIONS TO BE TAKEN TO ALL CLI USERS
############################################################################

import requests, os, re, sys, time 
import xml.dom.minidom


##Validations
if len(sys.argv) != 2:
   print "Usage: parseTargetIP.py incident.xml"
   exit()
else:
   fileName = sys.argv[1]

##PARSE THE IPDETAIL SECTION
doc = xml.dom.minidom.parse(fileName)
incident = doc.getElementsByTagName
nodes = doc.getElementsByTagName('incidentTarget')
if nodes.length < 1:
   print "no incident target found!"
else:
   sourceNode = nodes[0]
# Look for Host IP
hostIP = ""
for node in sourceNode.childNodes :
   if node.nodeType == node.ELEMENT_NODE:
      if node.getAttribute("attribute") == "hostIpAddr":
         hostIP = node.firstChild.data
if hostIP == "":
   print "no host ip found!"
hostIP = hostIP.strip()
# Look for host MAC
hostMAC = ""
for node in sourceNode.childNodes :
   if node.nodeType == node.ELEMENT_NODE:
      if node.getAttribute("attribute") == "hostMACAddr":
         hostMAC = node.firstChild.data
if hostMAC == "":
   print "no host MAC found!"
hostMAC = hostMAC.strip()

##PARSE THE INCIDENT STATUS
incident_status = doc.getElementsByTagName('incident')
for node in incident_status:
    status_value=node.getAttribute('status')
#    print status_value
    sev_value=node.getAttribute('severity')
#    print sev_value


##Remediation
os.system('wall "INCIDENT: Wannacry attack detected - threshold\nIf I had an external system to talk to, I would quarantine IP '+hostIP+' and/or MAC '+hostMAC+' now."')

