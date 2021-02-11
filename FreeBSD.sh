#!/bin/bash

sysrc pf_enable=YES

sysrc pflog_enable=YES

pfctl -s rules > pf.rules

pfctl -s nat > pf.nat

echo "

# allow scoreboard range to access these ports (INBOUND)
pass in quick proto tcp from “<UPSTREAM/CIDR>” to port {20,21,22,25,53,80,110,139,143,443,445,465,601,587,993 995,3306,3385,3386,6514,8080}
pass in quick proto udp from “<UPSTREAM/CIDR>” to port {53,137,138,514} 

# dont allow anything else from upstream 
block in quick from “<upstream/cidr>” 
# block output by default YOU MAY ONLY DISABLE THIS RULE WITH CAPTAINS PERMISSION TO DOWNLOAD SOMETHING
block out 

# rules wont apply to localhost 
set skip on lo0
# block all inbound traffic by default YOU MAY ONLY DISABLE THIS RULE WITH CAPTAINS PERMISSION TO DOWNLOAD SOMETHING
block in all 
# allow icmp 
pass inet proto icmp from any to any 

# allow local traffic 
pass in on dc0 from <your_ip_address> to <downstream/CIDR>
pass out on dc0 from <downstream/CIDR> to <your_ip_address>
	Substitute the interface for dc0 ie vnet0 or eth0 etc
# allow scored ports in 
pass in proto { tcp } to port {20,21,22,25,53,80,110,139,143,443,445,465,601,587,993 995,3306,3385,3386,6514,8080}
pass in proto { udp } to port {53,137,138,514} 
" > /etc/pf.conf