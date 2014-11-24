PackStackSandBox
================

A template for further sanbox work with packstack, brings up two nodes. One controller and One Compute/Netowrking. Should be easy to modify to meet your needs. 

they can be reached after vagrant up with
    vagrant ssh controller
    vagrant ssh compute 

Requirements
============
Get VirtualBox https://www.virtualbox.org/wiki/Downloads

Get Vagrant https://www.vagrantup.com/downloads.html

Install vagrant-vbguest

    vagrant plugin install vagrant-vbguest

Enable bridged mode on your local machine

    $ brctl show
    bridge name     bridge id               STP enabled     interfaces
    docker0         8000.28d244719f30       no              enp0s25

Get this repo

    git clone git@github.com:Aricg/PackStackSandBox.git && cd PackStackSandBox

Modify Vagrantfile.yml to reflect the name of your bridge and the ips you want to give the virtualbox instnaces 

    bridge: docker0
    controller:
      bridged_ip: 192.168.1.91
      private_ip: 192.168.22.92
    compute:
      bridged_ip: 192.168.1.93
      private_ip: 192.168.22.94

Launch Vagrant
    
    vagrant up

ssh into the vagrant controller (password is vagrant)

    #eval $(./parse_yaml Vagrantfile.yml) && ssh root@$controller_bridged_ip
    vagrant ssh controller

run packstack

The default route gets deleted when br-ex comes up, the installer fails. in the steps below I've readded the route and run packstack again. this is a temporary workaround
    
    cd /vagrant
    sudo bash
    packstack  --answer-file=ans.txt
    ip route add default via 192.168.0.1
    packstack  --answer-file=ans.txt
    cp /root/keystonerc_admin /vagrant

Networking
==========
This part is not done, insofar as I have hard coded ips below. I will integrate this into Vagrantfile.yml shortly. 
vagrant ssh into the networking (compute node)

    cd /vagrant
    ./switch_to_qemu.sh
    ./setup-neutron
    ./CreateAndSourceKey
    ./GetCirrosMinimalImage
    ./LaunchCirrosVM cirros
    route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.3.1
    echo "GATEWAYDEV=br-ex" >> /etc/sysconfig/network
    echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-br-ex

Trouble-shooting
================
When restarting netwoking, the neutron switch become unresponsive

    service network restart
    for i in dhcp-agent l3-agent metadata-agent openvswitch-agent; \
    do service neutron-$i restart; done
    neutron agent-list
    #takes me 38 seconds before I can ping a the router


