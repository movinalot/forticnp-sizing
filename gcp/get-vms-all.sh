#!/bin/bash
gcloud compute instances list --format="csv[no-heading](zone.basename())" | awk -F"-" '{zn="";for (i=1;i<=NF-1;i++){zn=zn$i; if (i < NF-1) {zn=zn"-"}}; zns[zn]+=1} END {for (key in zns) {print key": " zns[key]}}' | sort | awk 'BEGIN {print "Region Name and VM Count"} {print $0; vt+=$2} END {print "Total VMs: "vt}'
