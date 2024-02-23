#!/bin/bash

Networking=(
	['vmbr1']='RTR-HQ<=>ISP' ['vmbr3']='RTR-HQ<=>SW-HQ' ['vmbr5']='SW-HQ<=>CLI-HQ' ['vmbr6']='SW-HQ<=>CICD-HQ' ['vmbr7']='SW-HQ<=>SRV-HQ'
	['vmbr2']='ISP<=>RTR-BR' ['vmbr4']='RTR-BR<=>SW-BR' ['vmbr8']='SW-BR<=>SRV-BR' ['vmbr9']='SW-BR<=>CLI-BR'
)

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
done

systemctl reload networking

ya_url() { echo $(curl -G --silent --data-urlencode "public_key=$1" 'https://cloud-api.yandex.net/v1/disk/public/resources/download' | grep -Po '"href":"\K[^"]+'); }
curl -L $(ya_url https://disk.yandex.ru/d/lyptnAHegU3ehA) -o ISP.vmdk
curl -L $(ya_url https://disk.yandex.ru/d/RTO6rzQCgoi_2w) -o vESR.vmdk
curl -L $(ya_url https://disk.yandex.ru/d/xlvUKh4LTK_Pog) -o ALT_Server.vmdk
curl -L $(ya_url https://disk.yandex.ru/d/Vf9gwcrzDPE1FQ) -o ALT_Workstation.vmdk

qm create 100 --name "ISP" --cores 1 --memory 1024 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1 --net2 virtio,bridge=vmbr2
qm importdisk 100 ISP.vmdk local-lvm --format qcow2 
qm set 100 -scsi0 local-lvm:vm-100-disk-0 --boot order=scsi0
echo "ISP is done!!!"

qm create 101 --name "RTR-HQ" --cores 4 --memory 4096 --ostype l26 --scsihw virtio-scsi-single --net0 e1000,bridge=vmbr1 --net1 e1000,bridge=vmbr3 
qm importdisk 101 vESR.vmdk local-lvm --format qcow2 
qm set 101 -scsi0 local-lvm:vm-101-disk-0 --boot order=scsi0
echo "RTR-HQ is done!!!"

qm create 102 --name "RTR-BR" --cores 4 --memory 4096 --ostype l26 --scsihw virtio-scsi-single  --net0 e1000,bridge=vmbr2 --net1 e1000,bridge=vmbr4
qm importdisk 102 vESR.vmdk local-lvm --format qcow2 
qm set 102 -scsi0 local-lvm:vm-102-disk-0 --boot order=scsi0
echo "RTR-BR is done!!!"

qm create 103 --name "SW-HQ" --cores 1 --memory 1024 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr3 --net1 virtio,bridge=vmbr5 --net2 virtio,bridge=vmbr6 --net3 virtio,bridge=vmbr7
qm importdisk 103 ALT_Server.vmdk local-lvm --format qcow2 
qm set 103 -scsi0 local-lvm:vm-103-disk-0 --boot order=scsi0
echo "SW-HQ is done!!!"

qm create 104 --name "SW-BR" --cores 1 --memory 1024 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr4 --net1 virtio,bridge=vmbr8 --net2 virtio,bridge=vmbr9
qm importdisk 104 ALT_Server.vmdk local-lvm --format qcow2 
qm set 104 -scsi0 local-lvm:vm-104-disk-0 --boot order=scsi0
echo "SW-BR is done!!!"

qm create 105 --name "SRV-HQ" --cores 2 --memory 4096 --ostype l26 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr7
qm importdisk 105 ALT_Server.vmdk local-lvm --format qcow2
qm set 105 -scsi0 local-lvm:vm-105-disk-0 -scsi1 local-lvm:1 -scsi2 local-lvm:1 --boot order=scsi0
echo "SRV-HQ is done!!!"

qm create 106 --name "SRV-BR" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr8 
qm importdisk 106 ALT_Server.vmdk local-lvm --format qcow2
qm set 106 -scsi0 local-lvm:vm-106-disk-0 -scsi1 local-lvm:1 -scsi2 local-lvm:1 --boot order=scsi0
echo "SRV-BR is done!!!"

qm create 107 --name "CLI-HQ" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr5 
qm importdisk 107 ALT_Workstation.vmdk local-lvm --format qcow2
qm set 107 -scsi0 local-lvm:vm-107-disk-0 --boot order=scsi0
echo "CLI-HQ is done!!!"

qm create 108 --name "CLI-BR" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr9 
qm importdisk 108 ALT_Workstation.vmdk local-lvm --format qcow2 
qm set 108 -scsi0 local-lvm:vm-108-disk-0 --boot order=scsi0
echo "CLI-BR is done!!!"

qm create 109 --name "CICD-HQ" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr6 
qm importdisk 109 ALT_Workstation.vmdk local-lvm --format qcow2 
qm set 109 -scsi0 local-lvm:vm-109-disk-0 --boot order=scsi0
echo "CICD-HQ is done!!!"

rm -f ISP.vmdk vESR.vmdk ALT_Server.vmdk ALT_Workstation.vmdk

echo "ALL DONE!!!"
