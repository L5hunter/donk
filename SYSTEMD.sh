#!/bin/bash

iptables-save > iptables.rules
iptables-restore < iptables.rules
ip6tables-save > ip6tables.rules
ip6tables-restore < ip6tables.rules

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -F

echo "Type ip range and CIDR"
read range 

iptables -A INPUT -p tcp -s $range --match multiport --dports 20,21,22,25,53,80,110,139,143,443,445,465 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d $range --match multiport --sports 20,21,22,25,53,80,110,139,143,443,445,465 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -s 192.168.7.0/24 --match multiport --dports 601,587,993,995,3306,3385,3386,6514,8080 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 192.168.7.0/24 --match multiport --sports 601,587,993,995,3306,3385,3386,6514,8080 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -s 192.168.7.0/24 --match multiport --dports 53,137,138,514 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -d 192.168.7.0/24 --match multiport --sports 53,137,138,514 -m state --state NEW,ESTABLISHED -j ACCEPT

##PING
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
ip6tables -I INPUT ! -i lo -j DROP
ip6tables -I OUTPUT ! -o lo -j DROP
ip6tables -I FORWARD -j DROP
iptables -P OUTPUT DROP

##DNS
echo "Type dns ip"
read dns
iptables -A OUTPUT -p udp --dport 53 -d $dns -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -d $dns -m state --state NEW,ESTABLISHED -j ACCEPT 
iptables -A INPUT -p udp --sport 53 -s $dns -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -s $dns -m state --state NEW,ESTABLISHED -j ACCEPT 

##HTTP/S
iptables -A OUTPUT -p tcp --match multiport --dports 80,443 -j ACCEPT 
iptables -A INPUT -p tcp --match multiport --sports 80,443 -j ACCEPT 

##EXPORT RULES
iptables-save > step7.iptables.rules
ip6tables-save > step7.ip6tables.rules

##DISPLAY RULES
iptables -nL INPUT --line-numbers
