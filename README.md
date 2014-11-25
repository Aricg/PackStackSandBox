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

Modify Vagrantfile.yml to reflect the name of your bridgei, your netmask and the ips you want to give the virtualbox instnaces. Note that I have a /22 avaliable on my home network, We will need a /24 section of this network so that we can create a route via the neutron router we later create. eg:

    route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.3.1 

Without this, you will not be able to route to your VMs. (Outbound traffic will still work)

    bridge: docker0
    netmask: 255.255.252.0
    gateway: 192.168.0.1
    controller:
      bridged_ip: 192.168.1.91
      private_ip: 192.168.22.92
    compute:
      bridged_ip: 192.168.1.93
      private_ip: 192.168.22.94

Launch Vagrant
    
    vagrant up

ssh into the vagrant controller (password is vagrant)

    vagrant ssh controller

run packstack

    cd /vagrant
    sudo bash
    packstack  --answer-file=ans.txt
    cp /root/keystonerc_admin /vagrant

Networking
==========
This part is not done, insofar as I have hard coded ips in the script below. I will integrate this into Vagrantfile.yml. 
vagrant ssh into the networking (compute node) and run:

    [root@compute vagrant]# cd /vagrant && ./SetupComputeNode

Trouble-shooting
================
When restarting netwoking, the neutron switch become unresponsive

    service network restart
    for i in dhcp-agent l3-agent metadata-agent openvswitch-agent; \
    do service neutron-$i restart; done
    neutron agent-list
    #takes me 38 seconds before I can ping a the router


