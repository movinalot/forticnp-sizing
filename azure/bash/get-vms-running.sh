#!/bin/bash
az vm list --show-details --query '[?powerState == `VM running`].{ResourceGroupName:resourceGroup, Location:location, Name:name, "PowerState":powerState, VmSize:hardwareProfile.vmSize}' -o table --only-show-errors ; echo " "; echo "Total VMs: " $(az vm list --show-details --query '[?powerState == `VM running`] | length([])' --only-show-errors)
