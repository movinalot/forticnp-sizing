# Fortinet FortiCNP Sizing One Line Commands

[Fortinet](https://www.fortinet.com/) FortiCNP One Line commands are used to gather Storage Utilization and VM instance information/count from provider Clouds in order to determine [FortiCNP](https://www.fortinet.com/products/public-cloud-security/cloud-security-posture-management) protection requirements.

- One Line commands presented in this README are **meant to be run from the Cloudshell interface** of the respective Cloud provider.

- One Line commands **do not** require the user to install any additional tools. The commands use the utilities **already available** in the provider's **Cloudshell**.

- One Line commands **do not require FortiCNP**, these commands **can be used** to determine Storage Utilization and VM instance information/count for **whatever your purpose** may be.

## Cloud Provider One Line commands

- [Azure](#azure)
- [AWS](#aws)
- [GCP](#gcp)

### Azure

Azure storage utilization and VM instance information gathering for FortiCNP can be done in Azure Cloudshell utilizing either PowerShell or the Azure az CLI.

#### Azure Subscription Selection

When initially starting an Azure Cloudshell session you may need to **Select** a specific Subscription if your account has access to more than one Subscription.

##### PowerShell

1. Determine the Current Subscription

    ```PowerShell
    Get-AzContext
    ```

    ```PowerShell
    Name                                     Account                  SubscriptionName        Environment             TenantId
    ----                                     -------                  ----------------        -----------             --------
    Subscription One (00000000-0000-…        MSI@33333                Subscription Zero       AzureCloud              22222222-2222-2222-2222…
    ```

    If this Subscription is not the desired Subscription, follow the next steps to select the desired Subscription.

1. Get the Subscriptions

    ```PowerShell
    Get-AzSubscription
    ```

    ```PowerShell
    Name                    Id                                   TenantId                             State
    ----                    --                                   --------                             -----
    Subscription Zero       00000000-0000-0000-0000-000000000000 22222222-2222-2222-22222-22222222222 Enabled
    Subscription One        11111111-1111-1111-1111-111111111111 22222222-2222-2222-22222-22222222222 Enabled
    ```

1. Select the Subscription

    ```PowerShell
    Select-AzSubscription -Subscription "Subscription One"
    ```

    ```PowerShell
    Name                                     Account                  SubscriptionName        Environment             TenantId
    ----                                     -------                  ----------------        -----------             --------
    Subscription One (11111111-1111-…        MSI@33333                Subscription One        AzureCloud              22222222-2222-2222-222…
    ```

    > If the name of the Subscription is known the process can be done in one step
    > Get-AzSubscription | Where-Object {$_.Name -eq 'Subscription One'} | Select-AzSubscription

##### AZ CLI

1. Determine the Current Subscription

    ```bash
    az account show
    ```

    ```json
    {
        "cloudName": "AzureCloud",
        "homeTenantId": "22222222-2222-2222-22222-22222222222",
        "id": "00000000-0000-0000-0000-000000000000",
        "isDefault": true,
        "managedByTenants": [],
        "name": "Subscription Zero",
        "state": "Enabled",
        "tenantId": "22222222-2222-2222-22222-22222222222",
        "user": {
            "cloudShellID": true,
            "name": "userid@company.com",
            "type": "user"
        }
    }
    ```

1. Get the Subscriptions

    ```bash
    az account account list
    ```

    ```json
    [
        {
            "cloudName": "AzureCloud",
            "homeTenantId": "22222222-2222-2222-22222-22222222222",
            "id": "00000000-0000-0000-0000-000000000000",
            "isDefault": true,
            "managedByTenants": [],
            "name": "Subscription Zero",
            "state": "Enabled",
            "tenantId": "22222222-2222-2222-22222-22222222222",
            "user": {
                "cloudShellID": true,
                "name": "userid@company.com",
                "type": "user"
            }
        },
        {
            "cloudName": "AzureCloud",
            "homeTenantId": "22222222-2222-2222-22222-22222222222",
            "id": "11111111-1111-1111-1111-111111111111",
            "isDefault": false,
            "managedByTenants": [],
            "name": "Subscription One",
            "state": "Enabled",
            "tenantId": "22222222-2222-2222-22222-22222222222",
            "user": {
                "cloudShellID": true,
                "name": "userid@company.com",
                "type": "user"
            }
        }
    ]
    ```

1. Select the Subscription

    ```bash
    az account set --subscription 11111111-1111-1111-1111-111111111111
    ```

    > If the name of the Subscription is known the process can be done in one step
    > az account list --query '[?name == "Subscription One"].id' -o tsv | xargs -n1 -ISUB az account set --subscription SUB

#### Azure Storage - PowerShell

Using PowerShell retrieve a total of all the Bytes utilized by all the blobs in all the containers in all the storage accounts across all Azure Regions (Locations). Change the size constant in the calculation for alternate representations of the total size. PowerShell provides these B constants 1KB, 1MB, 1GB, 1TB, 1PB, adjust accordingly

```PowerShell
Get-AzStorageAccount | Get-AzStorageContainer | Get-AzStorageBlob | Measure-Object -Property Length -Sum | Select-Object @{Name="Total Storage MB";Expression={[math]::round($_.Sum/1MB,2)}}
```

```PowerShell
   MB
   --
77.85
```

#### Azure VM List and Count - PowerShell

#### All VMs

Using PowerShell list all the VMs across all Azure Regions (Locations) with VM instance information and provide a total count.

> Note: Get-AzVM **does not** retrieve VMs that are part of an Azure Scale Set. This command will list VMs in a scale set.
> `Get-AzResource -ResourceType Microsoft.Compute/virtualMachineScaleSets | Get-AzVmssVM`

To return a count of **all** VMs

```PowerShell
Get-AzVm -Status | Select-Object ResourceGroupName, Location, Name, PowerState -ExpandProperty HardwareProfile | Format-Table; "Total VMs: " + $(Get-AzVM).count
```

```PowerShell
ResourceGroupName         Location      Name                   PowerState       VmSize
-----------------         --------      ----                   ----------       ------
RG_01                     eastus        MY_VM                  VM running       Standard_B1s
RG_02                     eastus        tester-01              VM deallocated   Standard_F4
RG_02                     eastus        tester-02              VM deallocated   Standard_B1s
RG_03                     eastus        centos8-sub-3-0        VM deallocated   Standard_B1s
RG_03                     eastus        win10-sub-3-1          VM deallocated   Standard_D2s_v3
RG_04                     eastus2       L8C-A                  VM deallocated   Standard_B1s
RG_04                     eastus2       L8C-B                  VM deallocated   Standard_DS1_v2
RG_04                     eastus2       L8C-C                  VM deallocated   Standard_DS1_v2
My_RG                     westcentralus HA-AP-FGT-01           VM stopped       Standard_A2_v2
My_RG                     westcentralus HA-AP-FGT-02           VM running       Standard_A2_v2
MY_RG                     westcentralus UTILITY-RHEL-HOST      VM deallocated   Standard_A2_v2

Total VMs: 11
```

#### All Running VMS

Using PowerShell list all the Running VMs across all Azure Regions (Locations) with VM instance information and provide a total count.

To return a count of **running** VMs

```PowerShell
Get-AzVm -Status | ?{$_.PowerState -eq "VM running"} | Select-Object ResourceGroupName, Location, Name, PowerState -ExpandProperty HardwareProfile | Format-Table; "Total VMs: " + $(Get-AzVM -Status | ?{$_.PowerState -eq "VM running"}).count
```

```PowerShell
ResourceGroupName         Location      Name                   PowerState       VmSize
-----------------         --------      ----                   ----------       ------
RG_01                     eastus        MY_VM                  VM running       Standard_B1s
My_RG                     westcentralus HA-AP-FGT-02           VM running       Standard_A2_v2

Total VMs: 2
```

#### Azure Storage - AZ CLI

```bash
az storage account list --query [].name -o tsv | xargs -ISTOACCT az storage container list --account-name STOACCT --only-show-errors --query '[].{STOACCT:name}' | jq '.[] | to_entries[] | "--account-name "+.key, "--container-name "+.value' | xargs -n2 echo az storage blob list --only-show-errors | awk '{system($0)}' | jq .[].properties.contentLength | awk 'BEGIN {print "Storage Total"} {st+=$1} END {printf "Total Size: %.6f GB\n", st/1024/1024/1024}'
```

```bash
Storage Total
Total Size: 0.010787GB
```

#### Azure VM List and Count - AZ CLI

> Note: az vmss list **does not** retrieve VMs that are part of an Azure Scale Set. This command will list VMs in a scale set.
> `az vmss list --query [].resourceGroupName | jq .[]`

To return **all** VMs

```bash
az vm list --show-details --query '[].{ResourceGroupName:resourceGroup, Location:location, Name:name, "PowerState":powerState, VmSize:hardwareProfile.vmSize}' -o table --only-show-errors ; echo " "; echo "Total VMs: " $(az vm list --query '[].name | length([])' --only-show-errors)
```

```bash
ResourceGroupName          Location       Name                        PowerState      VmSize
-------------------------  -------------  --------------------------  --------------  ---------------
RG_01                      eastus         MY_VM                       VM running       Standard_B1s
RG_02                      eastus         tester-01                   VM deallocated   Standard_F4
RG_02                      eastus         tester-02                   VM deallocated   Standard_B1s
RG_03                      eastus         centos8-sub-3-0             VM deallocated   Standard_B1s
RG_03                      eastus         win10-sub-3-1               VM deallocated   Standard_D2s_v3
RG_04                      eastus2        L8C-A                       VM deallocated   Standard_B1s
RG_04                      eastus2        L8C-B                       VM deallocated   Standard_DS1_v2
RG_04                      eastus2        L8C-C                       VM deallocated   Standard_DS1_v2
My_RG                      westcentralus  HA-AP-FGT-01                VM stopped       Standard_A2_v2
My_RG                      westcentralus  HA-AP-FGT-02                VM running       Standard_A2_v2
MY_RG                      westcentralus  UTILITY-RHEL-HOST           VM deallocated   Standard_A2_v2

Total VMs:  11
```

To return only **running** VMs

```bash
az vm list --show-details --query '[?powerState == `VM running`].{ResourceGroupName:resourceGroup, Location:location, Name:name, "PowerState":powerState, VmSize:hardwareProfile.vmSize}' -o table --only-show-errors ; echo " "; echo "Total VMs: " $(az vm list --show-details --query '[?powerState == `VM running`] | length([])' --only-show-errors)
```

```bash
ResourceGroupName          Location       Name                        PowerState      VmSize
-------------------------  -------------  --------------------------  --------------  ---------------
RG_01                      eastus         MY_VM                       VM running       Standard_B1s
My_RG                      westcentralus  HA-AP-FGT-02                VM running       Standard_A2_v2

Total VMs:  2
```

### AWS

AWS storage utilization and VM instance count can be done in AWS Cloudshell utilizing the AWS aws CLI.

#### AWS Storage - AWS CLI

```bash
aws s3api list-buckets --query "Buckets[].Name" | jq '.[]' | sort | xargs -n1 -IBUCKET bash -c "echo BUCKET; aws s3api list-objects --bucket BUCKET --query 'sum(Contents[].Size || [\`0\`])'" | awk 'BEGIN {print "Bucket Name and Size"} {bn=$1; getline ; bs=$1;print bn": "bs ;bt+=bs} END {printf "Total Size: %.6fGB\n", bt/1024/1024/1024}'
```

```bash
Bucket Name and Size
bucketname-bucket1-us-east-1: 1826370
bucketname-bucket1-us-east-2: 183610
bucketname-bucket2-us-east-1: 0
Total Size: 0.001872GB
```

## AWS VM Region List and Count - AWS CLI

To return a count of **all** VMs

```bash
aws ec2 describe-regions --query 'Regions[].RegionName' | jq '.[]' | sort | xargs -n1 -IREGION bash -c "echo -e REGION; aws ec2 describe-instances --region REGION --query 'Reservations[].Instances[].InstanceId | length(@)'" | awk 'BEGIN {print "Region Name and VM Count"} {rn=$1; getline ; vc=$1;print rn": "vc ;vt+=vc} END {print "Total VMs: " vt}'
```

```bash
Region Name and VM Count
ap-northeast-1: 0
ap-northeast-2: 0
ap-south-1: 0
ap-southeast-1: 4
ap-southeast-2: 0
ca-central-1: 0
eu-central-1: 0
eu-north-1: 0
eu-west-1: 0
eu-west-2: 0
eu-west-3: 0
sa-east-1: 0
us-east-1: 0
us-east-2: 0
us-west-1: 0
us-west-2: 40
Total VMs: 44
```

To return a count of **all running** VMs

```bash
aws ec2 describe-regions --query 'Regions[].RegionName' | jq '.[]' | sort | xargs -n1 -IREGION bash -c "echo -e REGION; aws ec2 describe-instances --region REGION --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId | length(@)'" | awk 'BEGIN {print "Region Name and VM Count"} {rn=$1; getline ; vc=$1;print rn": "vc ;vt+=vc} END {print "Total Running VMs: " vt}'
```

```bash
Region Name and VM Count
ap-northeast-1: 0
ap-northeast-2: 0
ap-south-1: 0
ap-southeast-1: 0
ap-southeast-2: 0
ca-central-1: 0
eu-central-1: 0
eu-north-1: 0
eu-west-1: 0
eu-west-2: 0
eu-west-3: 0
sa-east-1: 0
us-east-1: 0
us-east-2: 0
us-west-1: 0
us-west-2: 9
Total Running VMs: 9
```

### GCP

#### GCP Project Selection

When initially starting a GCP Cloudshell session you need to **Select** a  Project.

- Select Project

```bash
gcloud config set project project-name
```

GCP storage utilization and VM instance count can be done in GCP Cloudshell utilizing the GCP gcloud and gsutil CLI.

##### Storage - GCP CLI

```bash
gsutil du -shc
```

```bash
58.48 MiB    gs://agentile-fortios-6-4-1
1.05 GiB     gs://fortinac-bucket
148.9 MiB    gs://fortitester
148.26 MiB   gs://fortitester-146
110.17 MiB   gs://skc-fortiproxy-gcp
1.5 GiB      total
```

##### VM Region List and Count - GCP CLI

To return a count of **all** VMs

```bash
gcloud compute instances list --format="csv[no-heading](zone.basename())" | awk -F"-" '{zn="";for (i=1;i<=NF-1;i++){zn=zn$i; if (i < NF-1) {zn=zn"-"}}; zns[zn]+=1} END {for (key in zns) {print key": " zns[key]}}' | sort | awk 'BEGIN {print "Region Name and VM Count"} {print $0; vt+=$2} END {print "Total VMs: "vt}'
```

```bash
Region Name and VM Count
asia-northeast1: 3
asia-south1: 13
asia-southeast1: 7
asia-southeast2: 6
europe-north1: 6
europe-west1: 17
europe-west2: 1
europe-west3: 6
europe-west4: 12
europe-west6: 6
northamerica-northeast1: 1
southamerica-east1: 1
us-central1: 44
us-east1: 13
us-east4: 6
us-west1: 13
us-west2: 4
Total VMs: 159
```

To return a count of **all running** VMs

```bash
gcloud compute instances list --filter="status=RUNNING" --format="csv[no-heading](zone.basename())" | awk -F"-" '{zn="";for (i=1;i<=NF-1;i++){zn=zn$i; if (i < NF-1) {zn=zn"-"}}; zns[zn]+=1} END {for (key in zns) {print key": " zns[key]}}' | sort | awk 'BEGIN {print "Region Name and VM Count"} {print $0; vt+=$2} END {print "Total Running VMs: "vt}'
```

```bash
Region Name and VM Count
asia-southeast2: 3
europe-north1: 2
europe-west1: 5
europe-west3: 2
europe-west4: 4
southamerica-east1: 1
us-central1: 21
us-west1: 2
us-west2: 1
Total Running VMs: 41
```