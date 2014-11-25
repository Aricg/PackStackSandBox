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


 Vagrantfile.yml 
=================

Modify Vagrantfile.yml to reflect the network avaliable to you. Note that I have a /22 avaliable on my home network, We will need to reserve a /24 section of whatever network you are on so that we can create a route to the neutron router we later create. eg:

    route add -net 192.168.x.0 netmask 255.255.255.0 gw 192.168.x.1 

Without this, you will not be able to route to your VMs. (Outbound traffic will still work)

My working config:

    bridge: docker0  
    netmask: 255.255.252.0 
    gateway: 192.168.0.1
    neutron_router_start: 192.168.3.1
    neutron_router_end: 192.168.3.128
    controller:
      bridged_ip: 192.168.1.91
      private_ip: 192.168.22.92
    compute:
      bridged_ip: 192.168.1.93
      private_ip: 192.168.22.94

Explanation

bridge: name of your bridge interface ($ brctl show )

netmask: netmask of your private subnet, probably given to you via dhcp. you can see this with ifconfig,
however on osx if will be in the unreadble format, something like 0xffffff00 Refer here for a table that human can read. http://www.pawprint.net/designresources/netmask-converter.php Most home networks only give out a /24 you will need to log into your router and change your range to at least a /23 so that we an properly route to the router that neutron creates. 

gateway: gateway for internet (your routers ip, this is also the ip you go to to increase your network size
) you can check this with ip r on linux or netstat -nr on osx

neutron_router_start: This will be the start of your openstack dhcp, I also use this to guess your neutron router gateway. Make it something that is routable but that none of your computers are using. 
eg: mycomputer is 192.168.0.2 so we make the neutron range 192.168.1.1-192.168.1.254

neutron_router_end: the end of the range explained above

controller:
  bridged_ip: this interface should be on the same /24 as your workstation.

  private_ip: this interface can have any ip you want, virtualbox deals with the routing.

compute:
  bridged_ip: same but unique

  private_ip: same but unique and on the same /24 as the private_ip above

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
vagrant ssh into the networking (compute node) and run:

    vagrant ssh compute
    [vagrant@compute]# sudo bash
    [root@compute ]# cd /vagrant && ./SetupComputeNode

Trouble-shooting
================
When restarting netwoking, the neutron switch become unresponsive, you'll need to restart various neutron components

    service network restart
    for i in dhcp-agent l3-agent metadata-agent openvswitch-agent; \
    do service neutron-$i restart; done
    neutron agent-list
    #takes me 38 seconds before I can ping a the router

Things that still suck
======================
Vagrant reconfigures the network device eth1 on boot. even tho I have managed set to false.
this breaks everything. Gar.


