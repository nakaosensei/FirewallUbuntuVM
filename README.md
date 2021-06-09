# Configurando um Firewall (políticas de segurança) em um ambiente virtualizado. 
Esse é um projeto de configuração de políticas de segurança de  Firewall em 5 máquinas virtuais, foram utilizadas 5 VM's Ubuntu 18.04 (servidor), sendo 4 hosts e um roteador que contém as políticas de Firewall. A Figura 1 ilustra o cenário de rede a configurar, na qual são apresentadas as redes LAN, DMZ e WAN. As redes da LAN e DMZ estão atrás do Firewall, ou seja, todo tráfego que sair do Firewall deve ser mascarado através do uso de mascáramento NAT. O Host 4 tem acesso a internet e o compartilha com os demais dispositivos da rede. Também são apresentadas 7 políticas de segurança a serem implementadas.

<p>
  <img src="images/setup.png" alt="Cenário proposto" style="width:100%">
  <p align="center">Figura 1 - Cenário proposto</p>
</p>
<br>

# Carregamento das VM's no virtualbox
Faça o download da imagem do Ubuntu 18.04 (server), abra o Virtualbox, clique em "Novo", selecione uma quantidade de memória RAM, defina o tamanho do disco virtual e crie conclua a criação da VM. 

Uma vez criada, aperte o botão direito do mouse na VM e selecione a opção configurações. Vá no menu Sistema, e deixe o disco óptico no topo da ordem de boot. Agora vá ao menu armazenamento, acrescente um disco na opção "Controladora:IDE", selecione o disco existente com o cursor do mouse, a direita aparecerá uma seção de atributos, nela haverá um ícone de um disco azul, clique com o botão direito nele e carregue a ISO do Ubuntu Server baixada.

Feito isso, vá ao menu Rede e habilite uma placa de rede, selecione a opção Rede interna, e se atente ao nome da rede em que essa placa está conectada. Para se obter o resultado esperado, máquinas na mesma rede devem estar no mesmo nome de rede. A Figura 2 ilustra essa configuração.

<p>
  <img src="images/virtualbox.png" alt="Cenário proposto" style="width:100%">
  <p align="center">Figura 2 - Habilitando placa de rede </p>
</p>
<br>


Agora abra mais uma vez o menu Configurações->Sistema, e deixe o disco rígido no topo da lista de sequência de boot. Finalmente ligue a máquina virtual, defina o seu usuário, e execute os comandos:
```bash
sudo apt install nginx
sudo apt install openssh-server
sudo apt install lynx
sudo apt install ftp
sudo apt install iptables
sudo apt install bind9
sudo apt install proftpd
sudo apt install telnetd
```
Essas instalações serão utilizadas para testes nas políticas de segurança posteriormente definidas pelo Firewall.

Para poupar trabalho, iremos clonar essa primeira maquina virtual 4 vezes, se atente as opções para gerar novos discos virtuais e novos endereços MAC para as placas de rede. Feche a VM carregada e realize as clonagens, basta clicar com o botão direito na VM e clonar (seguindo os menus).

Terminadas as clonagens, renomeie as VM's para: host1a, host1b, host2a, host3a e Firewall. Em seguida, iremos ativar as interfaces de rede do nós (tal qual na Figura 2), nas VM's LAN (host1a, host1b) e DMZ (host2a) habilite uma placa de rede interna, na VM da WAN (host3a) habilite uma placa de rede interna e uma placa de rede NAT, na VM do Firewall habilite três placas de rede interna.

Nas máquinas da LAN (host1a e host1b), o nome associada a placa de rede será intnet1, na máquina da DMZ (host2a) o nome será intnet2, na placa de rede interna da WAN (host3a) o nome será intnet3, por fim, na VM do Firewall nomeie a primeira placa de rede interna com a intnet1, a segunda com intnet2 e a terceira com a intnet3. A tabela 1 apresenta as redes internas das VM's. 

| VM        | Redes Internas | 
| ------------- |:-------------:| 
| host1a (LAN)        | intnet1 |
| host1b (LAN)     | intnet1     |  
| host2a (DMZ) | intnet2      |
| host3a (WAN) | intnet3, NAT |
| Firewall | intnet1, intnet2, intnet3 |    
 <p align="center">Tabela 1 - Placas de rede </p>

# Configuração das redes nas VM's
Iremos configurar as redes de acordo com o cenário  apresentado na Figura 1, as redes são apresentadas na Tabela 2, na qual as máquinas da LAN estão na rede 172.16.1.0, da DMZ na rede 172.16.2.0 e da WAN na rede 172.16.3.0, nessa prática deixamos explícitos os nomes de algumas interfaces de rede que serão utilizadas nas regras do Firewall.
| VM        | Rede | Ip |
| ------------- |:-------------:|:-------------:| 
| host1a (LAN)        | 172.16.1.0/24 | 172.16.1.1|
| host1b (LAN)     | 172.16.1.0/24     |  172.16.1.2|
| host2a (DMZ) | 172.16.2.0/24      |172.16.2.1|
| host3a (WAN) | 172.16.3.0 e NAT (enp0s3) |172.16.3.1 e gerado por dhcp|
| Firewall | 172.16.1.0 (enp0s9), 172.16.2.0 (enp0s10), 172.16.3.0 (enp0s3) | 172.16.1.254 (enp0s9), 172.16.2.254 (enp0s10), 172.16.3.254 (enp0s3) | 
 <p align="center">Tabela 2 - Redes das VM's </p>

Para realizar as configurações, inicie todas as VM's e edite o arquivo /etc/netplan/00-installer-config.yaml, iremos passar pelas configurações de rede de cada VM.

## Arquivo /etc/netplan/00-installer-config.yaml do host1a
```bash
network:
  ethernets:
    enp0s9:
      dhcp4: no
      addresses: [172.16.1.1/24]
      gateway4: 172.16.1.254
  version: 2
```
## Arquivo /etc/netplan/00-installer-config.yaml do host1b
```bash
  network:
    ethernets:
      enp0s9:
        dhcp4: no
        addresses: [172.16.1.2/24]
        gateway4: 172.16.1.254
    version: 2
```
## Arquivo /etc/netplan/00-installer-config.yaml do host2a
```bash
network:
  ethernets:
    enp0s9:
      dhcp4: no
      addresses: [172.16.2.3/24]
      gateway4: 172.16.2.254
  version: 2
```
## Arquivo /etc/netplan/00-installer-config.yaml do host3a
```bash
network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s9:
      dhcp4: no
      addresses: [172.16.3.1/24]
      gateway4: 172.16.3.254
  version: 2
```
## Arquivo /etc/netplan/00-installer-config.yaml do Firewall
```bash
network:
  ethernets:
    enp0s3:
      dhcp4: false
      addresses: [172.16.3.254/24]
    enp0s9:
      dhcp4: false
      addresses: [172.16.1.254/24]
    enp0s10: 
      dhcp4: false
      addresses: [172.16.2.254/24]      
  version: 2
```

## Tornando nós roteadores 
Agora ligaremos ligaremos o modo de roteamento para o firewall e para o host3a (WAN), nessa configuração o host3a é quem possui uma interface com acesso à Internet, e ele que de fato irá ceder aos demais nós da rede. Para isso, no firewall e no host3a abra o arquivo /etc/sysctl.conf, e acrescente a linha abaixo:
```bash
net.ipv4.ip_forward=1
```

## Configuração do host3a (DMZ)
Agora vá até a VM do host3a (DMZ), observe como está a tabela de rotamento, usando o comando route -n:
```bash
host3a@nakao:~$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.16.3.254    0.0.0.0         UG    0      0        0 enp0s9
0.0.0.0         10.0.2.2        0.0.0.0         UG    100    0        0 enp0s3
10.0.2.0        0.0.0.0         255.255.255.0   U     0      0        0 enp0s3
10.0.2.2        0.0.0.0         255.255.255.255 UH    100    0        0 enp0s3
172.16.3.0      0.0.0.0         255.255.255.0   U     0      0        0 enp0s9
```
A interface que tem acesso à Internet no host3a é a enp0s3, a primeira regra define
que os pacote destinados a 0.0.0.0 devem sair para o endereço do Firewall (172.16.3.254), essa regra impede o acesso a Internet, por esse motivo, remova-a com o comando:
```bash
host3a@nakao:~$ sudo route del -net 0.0.0.0 gw 172.16.3.254 netmask 0.0.0.0 dev enp0s9
```
Agora vamos acrescentar rotas para as redes LAN e DMZ para o host3a, usando os comandos:
```
host3a@nakao:~$ sudo ip route add 172.16.1.0/24 via 172.16.3.254
host3a@nakao:~$ sudo ip route add 172.16.2.0/24 via 172.16.3.254
```
E por fim, vamos dizer que todo pacote que sair da WAN para Internet será mascarado (os pacotes do Firewall já virão mascarados, e serão mais uma vez nesse ponto).
```
host3a@nakao:~$ sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
```

# Configuração do Firewall
Finalmente chegamos as configurações realizadas no Firewall












