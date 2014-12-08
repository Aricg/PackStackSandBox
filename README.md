PackStackSandBox
================

A template for further sanbox work with packstack, brings up two nodes. One controller and One Compute/Netowrking. Should be easy to modify to meet your needs. 

Can be run in bridged mode or nat mode, see below for details

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

    git clone https://github.com/Aricg/PackStackSandBox.git && cd PackStackSandBox


 Vagrantfile.yml 
=================

Modify Vagrantfile.yml.template.bridgemode or Vagrantfile.yml.template.natmode and copy to Vagrantfile.yml to reflect the network avaliable to you. (for the nat template it should just work as is)  Below I am setting up under bridged mode and have a /22 avaliable on my home network, We will need to reserve a /24 section of whatever network you are on so that we can create a route to the neutron router we later create. eg:

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


Vagrantfile.yml Explanation
==========================

Warning, make sure there are no trailing white spaces in this file

**nat_mode:** set to yes for nat mode, leave blank for bridge mode

**bridge:** name of your bridge interface ($ brctl show ) leave blank for nat mode

**netmask:** netmask of your private subnet, probably given to you via dhcp. you can see this with ifconfig, however on osx if will be in the unreadble format, something like 0xffffff00 Refer here for a table that human can read. http://www.pawprint.net/designresources/netmask-converter.php Most home networks only give out a /24 you will need to log into your router and change your range to at least a /23 so that we an properly route to the router that neutron creates. 

**gateway:**  For bridged mode Your workstations gateway to the internet (your routers ip, this is also the ip you go to to increase your network size
) you can check this with ip r on linux or netstat -nr on osx
For nat mode set this to the first ip in the range you are choosing for private_ip 

**neutron_router_start:** This will be the start of your openstack dhcp, I also use this as your neutron router gateway. Make it something that is routable but that none of your computers are using. 
eg: If my workstation and gateway(router) were in the 192.168.0.0/24 range I could make the neutron range inside 192.168.1.0/24 eg: 192.168.1.1-192.168.1.254

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
    packstack  --answer-file=ans.txt && cp /root/keystonerc_admin /vagrant

Networking
==========
To setup networking, and launch the cirros minimal VM you must wait for the above operations to complete. (packstack and copying the keystonerc_admin) Once those are done, vagrant ssh into the networking (compute node):

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

Vagrant exits with a syntax error
    
    Message: undefined method `[]' for nil:NilClass

Try running the included ./testyaml you may need to install the ruby yaml library

Vagrant Can't download the box on OSX

    vagrant box add --name controller https://build.opnfv.org/downloads/controller.box 
    vagrant init controller

This will help you debug some wierd permission erros that we've seen on osx


Nat Networks
=============
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

#TODO automate this.
    ip route del default
    ip route add default via 10.0.20.1 (the gateway set it your Vagrantfile.yml) dev eth1

You are now ready to "run packstack" (see above) 

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

