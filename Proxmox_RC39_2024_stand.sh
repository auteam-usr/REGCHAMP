#!/bin/bash

comp_name='Competitor1'
comp_passwd='Competitor1'
stand_name='RC39_2024_stand_1'

Networking=(
	['vmbr1']='ISP<=>RTR-HQ'	['vmbr11']='ISP<=>RTR-BR'
	['vmbr2']='RTR-HQ<=>SW-HQ'	['vmbr12']='RTR-BR<=>SW-BR'
	['vmbr3']='SW-HQ<=>SRV-HQ'	['vmbr13']='SW-BR<=>SRV-BR'
	['vmbr4']='SW-HQ<=>CLI-HQ'	['vmbr14']='SW-BR<=>CLI-BR'
	['vmbr5']='SW-HQ<=>CICD-HQ'
)

pveum role add Competitor -privs "VM.Monitor VM.Console VM.PowerMgmt VM.Snapshot.Rollback VM.Config.Network"
pvesh create access/users --userid $comp_name@pve --password $comp_passwd --comment "Competition account"
pveum pool add $stand_name
pveum acl modify /pool/$stand_name -user $comp_name -role Competitor

for i in "${!Networking[@]}"
do
  iface=$i; desc=${Networking[$i]}
  cat <<IFACE >> /etc/network/interfaces

auto ${iface}
iface ${iface} inet manual
        bridge-ports none
        bridge-stp off
        bridge-fd 0
#${desc}
IFACE
  ifup $i
  pveum acl modify /sdn/zones/localnetwork/$1 -user $comp_name -role PVEAuditor
done

ya_url() { echo $(curl --silent -G --data-urlencode "public_key=$1" 'https://cloud-api.yandex.net/v1/disk/public/resources/download' | grep -Po '"href":"\K[^"]+'); }
curl -L $(ya_url https://disk.yandex.ru/d/lyptnAHegU3ehA) -o ISP.vmdk
curl -L $(ya_url https://disk.yandex.ru/d/RTO6rzQCgoi_2w) -o vESR.vmdk
curl -L $(ya_url https://disk.yandex.ru/d/xlvUKh4LTK_Pog) -o ALT_Server.vmdk
curl -L $(ya_url https://disk.yandex.ru/d/Vf9gwcrzDPE1FQ) -o ALT_Workstation.vmdk

qm create 100 --name "ISP" --cores 1 --memory 1024 --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1 --net2 virtio,bridge=vmbr11 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single 
qm importdisk 100 ISP.vmdk local-lvm --format qcow2 
qm set 100 -scsi0 local-lvm:vm-100-disk-0 --boot order=scsi0
echo "ISP is done!!!"

qm create 101 --name "RTR-HQ" --cores 4 --memory 4096 --net0 e1000,bridge=vmbr1 --net1 e1000,bridge=vmbr2 --serial0 socket --acpi 0 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 101 vESR.vmdk local-lvm --format qcow2 
qm set 101 -scsi0 local-lvm:vm-101-disk-0 --boot order=scsi0
echo "RTR-HQ is done!!!"

qm create 102 --name "SW-HQ" --cores 1 --memory 1024 --net0 virtio,bridge=vmbr2 --net1 virtio,bridge=vmbr4 --net2 virtio,bridge=vmbr5 --net3 virtio,bridge=vmbr3 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 102 ALT_Server.vmdk local-lvm --format qcow2 
qm set 102 -scsi0 local-lvm:vm-102-disk-0 --boot order=scsi0
echo "SW-HQ is done!!!"

qm create 103 --name "SRV-HQ" --cores 2 --memory 4096 --net0 virtio,bridge=vmbr3 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 103 ALT_Server.vmdk local-lvm --format qcow2
qm set 103 -scsi0 local-lvm:vm-103-disk-0 -scsi1 local-lvm:1 -scsi2 local-lvm:1 --boot order=scsi0
echo "SRV-HQ is done!!!"

qm create 104 --name "CLI-HQ" --cores 2 --memory 2048 --net0 virtio,bridge=vmbr4 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 104 ALT_Workstation.vmdk local-lvm --format qcow2
qm set 104 -scsi0 local-lvm:vm-104-disk-0 --boot order=scsi0
echo "CLI-HQ is done!!!"

qm create 105 --name "CICD-HQ" --cores 2 --memory 2048 --net0 virtio,bridge=vmbr5 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 105 ALT_Workstation.vmdk local-lvm --format qcow2 
qm set 105 -scsi0 local-lvm:vm-105-disk-0 --boot order=scsi0
echo "CICD-HQ is done!!!"

qm create 106 --name "RTR-BR" --cores 4 --memory 4096 --net0 e1000,bridge=vmbr11 --net1 e1000,bridge=vmbr12 --serial0 socket --acpi 0 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 106 vESR.vmdk local-lvm --format qcow2 
qm set 106 -scsi0 local-lvm:vm-106-disk-0 --boot order=scsi0
echo "RTR-BR is done!!!"

qm create 107 --name "SW-BR" --cores 1 --memory 1024 --net0 virtio,bridge=vmbr12 --net1 virtio,bridge=vmbr13 --net2 virtio,bridge=vmbr14 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 107 ALT_Server.vmdk local-lvm --format qcow2 
qm set 107 -scsi0 local-lvm:vm-107-disk-0 --boot order=scsi0
echo "SW-BR is done!!!"

qm create 108 --name "SRV-BR" --cores 2 --memory 2048 --net0 virtio,bridge=vmbr13 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 108 ALT_Server.vmdk local-lvm --format qcow2
qm set 108 -scsi0 local-lvm:vm-108-disk-0 -scsi1 local-lvm:1 -scsi2 local-lvm:1 --boot order=scsi0
echo "SRV-BR is done!!!"

qm create 109 --name "CLI-BR" --cores 2 --memory 2048 --net0 virtio,bridge=vmbr14 --serial0 socket -agent 1 --ostype l26 --scsihw virtio-scsi-single
qm importdisk 109 ALT_Workstation.vmdk local-lvm --format qcow2 
qm set 109 -scsi0 local-lvm:vm-109-disk-0 --boot order=scsi0
echo "CLI-BR is done!!!"

pvesh set /pool/$stand_name -vms "100,101,102,103,104,105,106,107,108,109"

rm -f ISP.vmdk vESR.vmdk ALT_Server.vmdk ALT_Workstation.vmdk

echo "ALL DONE!!!"
