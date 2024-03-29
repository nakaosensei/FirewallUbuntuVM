echo "Zerando Firewall..."
iptables -t nat -F
iptables -F

echo "Realizando mascaramento para tudo que sair pela enp0s8"
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

echo "Permitindo que o host 1 acesse o firewall via ssh"
iptables -A INPUT -p tcp --dport 22 -i enp0s9 -s 172.16.1.1 -j ACCEPT

echo "Permitindo que o firewall seja cliente HTTP, HTTPS, FTP e DNS"
iptables -A INPUT -p icmp --icmp-type echo-reply -i enp0s8 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -i enp0s8  -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -i enp0s8 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 21 -i enp0s8 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -i enp0s8 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Bloqueando o trafego que vai diretamente para o firewall"
iptables -A INPUT -j DROP

echo "Permitindo que o Firewall se comunique com a LAN e DMZ via output"
iptables -A OUTPUT -o enp0s9 -j ACCEPT

echo "Bloqueando o trafego que sai do firewall"
iptables -A OUTPUT -j DROP


echo "Permitindo que maquinas da DMZ(net2) possam ser acessados via SSH pelas maquinas da LAN(net1)"
iptables -A FORWARD -i enp0s9 -o enp0s10 -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s9 -m state --state ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i enp0s10 -m state --state ESTABLISHED,RELATED -p tcp --sport 22 -j ACCEPT

echo "Permitindfo que o host3(host2a) seja apenas servidor http ou dns"
iptables -A FORWARD -o enp0s10 -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i enp0s10 -m state --state ESTABLISHED,RELATED -p tcp --sport 80 -j ACCEPT
iptables -A FORWARD -i enp0s10 -j DROP
iptables -A FORWARD -o enp0s10 -j DROP

echo "Permitindo que a LAN seja apenas cliente, nao servidor"
iptables -A FORWARD -o enp0s9 -m state --state NEW,INVALID -j DROP
iptables -A FORWARD -i enp0s9 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -o enp0s9 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Permitindo a passagem de trafego encaminhado pelo firewall"
iptables -A FORWARD -j ACCEPT
