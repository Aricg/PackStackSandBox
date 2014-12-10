PackStackSandBox
================

A template for further sanbox work with packstack, brings up two nodes. One controller and One Compute/Netowrking. Should be easy to modify to meet your needs. 

Can be run in bridged mode or nat mode, see below for details

nodes can be reached after vagrant up with
    vagrant ssh controller
    vagrant ssh compute 

Requirements
============
Get VirtualBox https://www.virtualbox.org/wiki/Downloads

Get Vagrant https://www.vagrantup.com/downloads.html

Install vagrant-vbguest

    vagrant plugin install vagrant-vbguest

Get this repo

    git clone https://github.com/Aricg/PackStackSandBox.git && cd PackStackSandBox


Nat Mode
========

Copy Vagrantfile.yml.template.natmode to Vagrantfile.yml 

Nat networking will provide the gateway to the internet as well as connectivity between hosts throught the vboxnetX interface created by vagrant

Setup Masquerade/Forwarding on your host to you vboxnet interface

make sure these are set in /etc/sysctl.d

    net.ipv4.ip_forward = 1
    net.ipv4.conf.all.proxy_arp = 1

And loaded

    sudo sysctl -p

In my example my hosts interface for internet connetiviy is docker0 (yours might be eth0 for example) and my the vboxnet brought up by vagrant up is vboxnet4 and the subnet I have set for the sandbox machines in the vagrantfile.yaml is 10.0.20.0/22

    iptables -A FORWARD -o docker0 -i vboxnet4 -s 10.0.20.0/22 -m conntrack --ctstate NEW -j ACCEPT
    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A POSTROUTING -t nat -j MASQUERADE

In this example we have set the vboxnet to  the 10.0.20.0/22 range.

Vagrant ssh into the compute and the controller node and set the default route to vboxnet0 rather than the nat device that vagrant sets at default

TODO automate this.

    ip route del default
    ip route add default via 10.0.20.1 (the gateway set it your Vagrantfile.yml) dev eth1

You are now ready to "Launch Vagrant" (see below) 

Bridged Mode
===========

If you are able to configure and use a bridge we can bring up openstack VMs on your local network. you will need a netmask of 23 or below.

My bridge in this readme is called docker0

    $ brctl show
    bridge name     bridge id               STP enabled     interfaces
    docker0     


To start copy Vagrantfile.yml.template.bridgemode to Vagrantfile.yml to reflect the network avaliable to you. In this example I have a /22 avaliable on my home network, Later we reserve a /24 section of my /22 network for the neutron router we create. 

My example config:

    bridge: docker0  
    netmask: 255.255.252.0 
    gateway: 192.168.0.1
    neutron_router_start: 192.168.3.1
    neutron_router_end: 192.168.3.128
    controller:
      bridged_ip: 192.168.1.91
      private_ip: 10.2.20.2
    compute:
      bridged_ip: 192.168.1.93
      private_ip: 10.2.20.3
    
You are now ready to "Launch Vagrant" (see below)

Vagrantfile.yml Explanation
==========================

Warning, make sure there are no trailing white spaces in this file

**nat_mode:** set to yes for nat mode, leave blank for bridge mode

**bridge:** name of your bridge interface ($ brctl show ) leave blank for nat mode

**netmask:** netmask of your private subnet, probably given to you via dhcp. you can see this with ifconfig, however on osx if will be in the unreadble format, something like 0xffffff00 Refer here for a table that human can read. http://www.pawprint.net/designresources/netmask-converter.php Most home networks only give out a /24 you will need to log into your router and change your range to at least a /23 so that we an properly route to the router that neutron creates. 

**gateway:**  For bridged mode Your workstations gateway to the internet (your routers ip, this is also the ip you go to to increase your network size
) you can check this with ip r on linux or netstat -nr on osx
For nat mode set this to the first ip in the range you are choosing for private_ip 

**neutron_router_start:** This will be the start of your openstack dhcp, I also use this as your neutron router gateway. give neutron its own /24 range

**neutron_router_end:** the end of the range explained above

controller:

  **bridged_ip:** this interface should be given an ip on the same /24 as your workstation.

  **private_ip:** this interface can have any ip you want, virtualbox deals with the routing.

compute:

  **bridged_ip:** same rules as the controller bridged_ip but unique

  **private_ip:** same rules as controller: private_ip but unique

for nat mode set the bridged_ip and private_ip to the same values for each host (as seen in Vagrantfile.yml.template.natmode)

Launch Vagrant
==============
    
    vagrant up

ssh into the vagrant controller (password is vagrant)

    vagrant ssh controller

run packstack (for nat mode complete steps below first) 

    cd /vagrant
    sudo bash
    packstack  --answer-file=ans.txt && yes|cp /root/keystonerc_admin /vagrant

the answerfile is generated from ans.template or ans.NAT.template when you run vagrant up. 
packstack should now prompt you for the root password of both nodes. The password is "vagrant"
if packstack fails for some reason, just run it again. 

Networking
==========
To setup networking, and launch the cirros minimal VM you must wait for the above operations to complete. (packstack and copying the keystonerc_admin) Once those are done, vagrant ssh into the networking (compute node):

    vagrant ssh compute
    [vagrant@compute]# sudo bash
    [root@compute ]# cd /vagrant && ./SetupComputeNode

That's it everything should work now.

Tools
=====

Ideally this sandbox will be loaded with usefull tools enumerated here. Right now there are some scripts that I use to setup the networking node

SetupNeutron

this setups neutron with a router for external connectivity for your VM's, this file is generated by ./build_SetupNeutron 

SwitchToQemu 

KVM is not supported inside virtualbox, this script switches to qemu

LaunchCirrosVM

    ./LaunchCirrosVM $1

Launches a vm with the name $1


DeleteNetwork

Runs throught some loops and removes all openstack networking, must be run on the compute node

Trouble-shooting
================
When restarting netwoking, the neutron switch become unresponsive, you'll need to restart various neutron components

    service network restart
    for i in dhcp-agent l3-agent metadata-agent openvswitch-agent; \
    do service neutron-$i restart; done
    neutron agent-list
    #takes me 38 seconds before I can ping a the router

Vagrant exits with a syntax error
    
    Message: undefined method `[]' for nil:NilClass

Try running the included ./testyaml you may need to install the ruby yaml library

Vagrant Can't download the box on OSX

    vagrant box add --name controller https://build.opnfv.org/downloads/controller.box 
    vagrant init controller

This will help you debug some wierd permission erros that we've seen on osx

Wierd locale issue. 

    ERROR : Error appeared during Puppet run: 10.0.20.2_glance.pp
    Notice: /Stage[main]/Glance::Registry/Exec[glance-manage db_sync]/returns: ValueError: unknown locale: UTF-8

Edit your /etc/ssh_config file on your Mac OS X system and remove LC_CTYPE from SendEnv. This will cause the ssh client to stop propagating LC_CTYPE to the ssh servers.



Caveats
======================
Vagrant reconfigures the network device eth1 on boot. even tho I have managed set to false.
You will need to run /vagrant/SetupComputeNodeAfterReboot each time the compute node is rebooted.


Contribute!
===========

Fork this repo
Create your feature branch (git checkout -b my-new-feature)
Commit your changes (git commit -am 'Add some feature')
Push to the branch (git push origin my-new-feature)
Create new Pull Request

