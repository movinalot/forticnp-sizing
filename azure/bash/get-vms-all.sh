#!/bin/bash
az vm list --show-details --query '[].{ResourceGroupName:resourceGroup, Location:location, Name:name, "PowerState":powerState, VmSize:hardwareProfile.vmSize}' -o table --only-show-errors ; echo " "; echo "Total VMs: " $(az vm list --query '[].name | length([])' --only-show-errors)
