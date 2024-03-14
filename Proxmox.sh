#!/bin/bash
cat ./ProxmoxInterfaces.txt >> /etc/network/interfaces;
systemctl restart networking;
apt-get install python3-pip python3-venv -y;
python3 -m venv myenv;
source myenv/bin/activate;
pip3 install wldhx.yadisk-direct;
read -p "Введите имя вашего локального хранилища: " STORAGE
curl -L $(yadisk-direct https://disk.yandex.ru/d/lyptnAHegU3ehA) -o ISP-disk001.vmdk
qm create 100 --name "ISP" --cores 1 --memory 1024 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1 --net2 virtio,bridge=vmbr2
qm importdisk 100 ISP-disk001.vmdk $STORAGE --format qcow2 
qm set 100 -ide0 $STORAGE:vm-100-disk-0 --boot order=ide0
echo "ISP is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/RTO6rzQCgoi_2w) -o RTR-HQ-disk001.vmdk
qm create 101 --name "RTR-HQ" --cores 4 --memory 4096 --ostype l26 --scsihw virtio-scsi-single --net0 e1000,bridge=vmbr1 --net1 e1000,bridge=vmbr3 
qm importdisk 101 RTR-HQ-disk001.vmdk $STORAGE --format qcow2 
qm set 101 -ide0 $STORAGE:vm-101-disk-0 --boot order=ide0
echo "RTR-HQ is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/arhOlptNl4fIQg) -o RTR-BR-disk001.vmdk
qm create 102 --name "RTR-BR" --cores 4 --memory 4096 --ostype l26 --scsihw virtio-scsi-single  --net0 e1000,bridge=vmbr2 --net1 e1000,bridge=vmbr4
qm importdisk 102 RTR-BR-disk001.vmdk $STORAGE --format qcow2 
qm set 102 -ide0 $STORAGE:vm-102-disk-0 --boot order=ide0
echo "RTR-BR is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/xlvUKh4LTK_Pog) -o SW-HQ-disk001.vmdk
qm create 103 --name "SW-HQ" --cores 1 --memory 1024 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr3 --net1 virtio,bridge=vmbr5 --net2 virtio,bridge=vmbr6 --net3 virtio,bridge=vmbr7
qm importdisk 103 SW-HQ-disk001.vmdk $STORAGE --format qcow2 
qm set 103 -ide0 $STORAGE:vm-103-disk-0 --boot order=ide0
echo "SW-HQ is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/nlslynxUxOcdNw) -o SW-BR-disk001.vmdk
qm create 104 --name "SW-BR" --cores 1 --memory 1024 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr4 --net1 virtio,bridge=vmbr8 --net2 virtio,bridge=vmbr9
qm importdisk 104 SW-BR-disk001.vmdk $STORAGE --format qcow2 
qm set 104 -ide0 $STORAGE:vm-104-disk-0 --boot order=ide0
echo "SW-BR is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/eeydoZIZbWG9Iw) -o SRV-HQ-disk001.vmdk
curl -L $(yadisk-direct https://disk.yandex.ru/d/--CnGh-_AI5YqQ) -o 1gb.raw
qm create 105 --name "SRV-HQ" --cores 2 --memory 4096 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr7
qm importdisk 105 SRV-HQ-disk001.vmdk $STORAGE --format qcow2
qm importdisk 105 1gb.raw $STORAGE --format qcow2
qm importdisk 105 1gb.raw $STORAGE --format qcow2
qm set 105 -ide0 $STORAGE:vm-105-disk-0 -ide1 $STORAGE:vm-105-disk-1 -ide2 $STORAGE:vm-105-disk-2 --boot order=ide0
echo "SRV-HQ is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/TOg9N-oZVjXfdw) -o SRV-BR-disk001.vmdk
qm create 106 --name "SRV-BR" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr8 
qm importdisk 106 SRV-BR-disk001.vmdk $STORAGE --format qcow2 
qm importdisk 106 1gb.raw $STORAGE --format qcow2
qm importdisk 106 1gb.raw $STORAGE --format qcow2
qm set 106 -ide0 $STORAGE:vm-106-disk-0 -ide1 $STORAGE:vm-106-disk-1 -ide2 $STORAGE:vm-106-disk-2 --boot order=ide0
echo "SRV-BR is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/Vf9gwcrzDPE1FQ) -o CLI-HQ-disk001.vmdk
qm create 107 --name "CLI-HQ" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr5 
qm importdisk 107 CLI-HQ-disk001.vmdk $STORAGE --format qcow2 
qm set 107 -ide0 $STORAGE:vm-107-disk-0 --boot order=ide0
echo "CLI-HQ is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/DetNZ_gicbh-Kg) -o CLI-BR-disk001.vmdk
qm create 108 --name "CLI-BR" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single  --net0 virtio,bridge=vmbr9 
qm importdisk 108 CLI-BR-disk001.vmdk $STORAGE --format qcow2 
qm set 108 -ide0 $STORAGE:vm-108-disk-0 --boot order=ide0
echo "CLI-BR is done!!!"
curl -L $(yadisk-direct https://disk.yandex.ru/d/db0TxXSedEzJDw) -o CICD-HQ-disk001.vmdk
qm create 109 --name "CICD-HQ" --cores 2 --memory 2048 --ostype l26 --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr6 
qm importdisk 109 CICD-HQ-disk001.vmdk $STORAGE --format qcow2 
qm set 109 -ide0 $STORAGE:vm-109-disk-0 --boot order=ide0
echo "CICD-HQ is done!!!"
echo "ALL DONE!!!"
