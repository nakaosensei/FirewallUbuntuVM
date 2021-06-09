# Configurando um Firewall (políticas de segurança) em um ambiente virtualizado. 
Esse é um projeto de configuração de políticas de segurança de  Firewall em um ambiente de virtualização, foram utilizadas 5 VM's Ubuntu 18.04 (servidor), sendo 4 hosts e um roteador que contém as políticas de Firewall. A Figura 1 ilustra o cenário de rede a configurar, na qual são apresentadas as redes LAN, DMZ e WAN. As redes da LAN e DMZ estão atrás do Firewall, ou seja, todo tráfego que sair do Firewall deve ser mascarado através do uso de mascáramento NAT. O Host 4 tem acesso a internet e o compartilha com os demais dispositivos da rede. Também são apresentadas 7 políticas de segurança a serem implementadas.

<p>
  <img src="images/setup.png" alt="Cenário proposto" style="width:100%">
  <p align="center">Figura 1 - Cenário proposto</p>
</p>
<br>

# Carregamento das VM's no virtualbox
Faça o download da imagem do Ubuntu 18.04 (server), abra o Virtualbox, clique em "Novo", nomeie a VM de host1a, selecione o tipo Linux, escolha a versão Ubuntu (64 bits), selecione uma quantidade de memória RAM, crie e defina o tamanho do disco virtual e conclua a criação inicial da VM. 

Uma vez criada, aperte o botão direito do mouse na VM e selecione a opção configurações. Vá no menu Sistema, e deixe o disco óptico no topo da ordem de boot. Agora vá ao menu armazenamento, acrescente um disco na opção "Controladora:IDE", selecione o disco existente com o cursor do mouse, a direita aparecerá uma seção de atributos, nela haverá um ícone de um disco azul, clique com o botão direito nele e carregue a ISO do Ubuntu Server.

Feito isso, vá ao menu Rede e habilite uma placa de rede, selecione a opção Rede interna, e se atente ao nome da rede em que essa placa está conectada. Para se obter o resultado esperado, máquinas na mesma rede devem estar no mesmo nome de rede. A Figura 2 ilustra essa configuração.

<p>
  <img src="images/virtualbox.png" alt="Cenário proposto" style="width:100%">
  <p align="center">Figura 2 - Habilitando placa de rede </p>
</p>
<br>


Agora abra mais uma vez o menu Configurações->Sistema, e deixe o disco rígido no topo da lista de sequência de boot. Finalmente ligue a máquina virtual, defina o seu usuário, e execute os comandos:
```bash
sudo apt install apache2
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

## Ligando roteamento no host3a e no firewall
Agora ligaremos ligaremos o modo de roteamento para o firewall e para o host3a (WAN), nessa configuração o host3a é quem possui uma interface com acesso à Internet, e ele que de fato irá ceder aos demais nós da rede. Para isso, no firewall e no host3a abra o arquivo /etc/sysctl.conf, e acrescente a linha abaixo:
```bash
net.ipv4.ip_forward=1
```

## Alterando o index.html dos nós
Nos testes, precisaremos testar o acessos HTTP nos nós, convém mudar a página padrão dos hosts para facilitar, em cada nó, altere o arquivo /var/www/index.html, deixando uma mensagem de "Bem vindo ao host X" ou "Bem vindo ao firewall". O apache estará rodando em todas as máquinas executadas, dessa forma em todo acesso http bem sucedido será possível visualizar claramente se ele foi barrado ou não.

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
Finalmente chegamos as configurações realizadas no Firewall, para isso criaremos um único arquivo executável que conterá todas políticas de segurança, abaixo segue o arquivo rules.sh, que contém
as regras do firewall. Inicialmente, acrescentamos uma rota para que o Firewall saiba que caso surja um endereço que não é das interfaces existentes, seja redirecionado para a WAN (172.16.3.1), e depois de fato iniciamos as regras, sendo:
* Zerar as tabelas do Firewall
* Máscarar todo tráfego que sair da LAN, DMZ ou do pŕoprio Firewall
* Permitir que o host1a acesse o Firewall via ssh
* Impedir acessos diretos ao Firewall
* Permitir tráfego encaminhado para o Firewall
* Permitir que as máquinas da DMZ sejam acessadas somente por máquinas da LAN via SSH
* Permitir que o host2a (DMZ) seja somente servidor http ou dns
* Impedir que as LAN's atuem como servidores

## Arquivo rules.sh
```bash
echo "Deletando e criando rota de saida para a WAN (host3a)"
route del -net 0.0.0.0 gw 172.16.3.1 netmask 0.0.0.0 dev enp0s3
ip route add 0.0.0.0/0 via 172.16.3.1

echo "Zerando Firewall..."
iptables -t nat -F
iptables -F

echo "Realizando mascaramento para tudo que sair pela enp0s3"
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

echo "Permitindo que o host 1 acesse o firewall via ssh"
iptables -A INPUT -p tcp --dport 22 -i enp0s9 -s 172.16.1.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -i enp0s8 -j ACCEPT

echo "Bloqueando o trafego que vai diretamente para o firewall"
iptables -A INPUT -j DROP

echo "Permitindo que maquinas da DMZ(net2) possam ser acessados via SSH pelas maquinas da LAN(net1)"
iptables -A FORWARD -i enp0s9 -o enp0s10 -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s9 -m state --state ESTABLISHED,RELATED -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i enp0s10 -m state --state ESTABLISHED,RELATED -p tcp --sport 22 -j ACCEPT

echo "Permitindo que o host2a (DMZ) seja apenas servidor http ou dns"
iptables -A FORWARD -o enp0s10 -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i enp0s10 -m state --state ESTABLISHED,RELATED -p tcp --sport 80 -j ACCEPT
iptables -A FORWARD -i enp0s10 -j DROP
iptables -A FORWARD -o enp0s10 -j DROP

echo "Permitindo que a LAN seja apenas cliente, nao servidor"
iptables -A FORWARD -o enp0s9 -m state --state NEW,INVALID -j DROP
iptables -A FORWARD -i enp0s9 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -o enp0s9 -m state --state ESTABLISHED,RELATED -j ACCEPT

echo "Permitindo a passagem de trafego encaminhado pelo firewall"
echo "iptables -A FORWARD -j ACCEPT"
iptables -A FORWARD -j ACCEPT
```

Para executarmos o script, devemos torná-lo um executável e executá-lo, fazendo:
```
firewall@nakao:~$ sudo chmod a+x ./rules.sh
firewall@nakao:~$ sudo ./rule
```

# Testes no Firewall
Iremos realizar os seguintes testes:
* A LAN consegue acessar serviços na Internet. (resultado esperado: sim)
* A LAN e o h3a conseguem acessar HTTP de h2a. (resultado esperado: sim)
* o firewall consegue acessar serviços na Internet, teste principalmente HTTP e um FTP.(resultado esperado: sim)
* host1a consegue acessar o firewall via ssh. (resultado esperado: sim)
* host1b consegue acessar o firewall via ssh. (resultado esperado: não)
* host2a consegue acessar o firewall via ssh. (resultado esperado: não)
* host3a consegue acessar o firewall via ssh. (resultado esperado: não)
* h1b consegue acessar host2a via ssh. (resultado esperado: sim)
* h2a consegue acessar serviços na Internet. (resultado esperado: sim)
* h2a consegue acessar h1b via HTTP. (resultado esperado: não)
* h3a consegue acessar h1a via HTTP, via IP normal. (resultado esperado: não)

## Teste 1: A LAN consegue acessar serviços na Internet (OK)
Nesse teste, fizemos as máquinas da LAN enviarem mensagens ICMP echo request para o ip do google (8.8.8.8), a Figura 3 apresenta o resultado bem sucedido.
<p>
  <img src="images/teste1.png" alt="LAN acessando Internet" style="width:100%">
  <p align="center">Figura 3 - LAN (host1a e host1b) acessando Internet </p>
</p>
<br>

## Teste 2: A LAN e o h3a conseguem acessar HTTP de host2a. (OK)
Nesse teste, fizemos as máquinas da LAN e a máquina da WAN enviarem requisições HTTP GET fazendo uso do software Lynx, a Figura 4 mostra a chamada dos comandos, e a Figura 5 mostra os resultados.
<p>
  <img src="images/teste2a.png" alt="Acesso http host2a" style="width:100%">
  <p align="center">Figura 4 - LAN (host1a e host1b) e WAN (host3a) acessando DMZ (host2a) via HTTP </p>
</p>
<br>
<p>
  <img src="images/teste2a.png" alt="Acesso http host2a" style="width:100%">
  <p align="center">Figura 5 - Resultado LAN (host1a e host1b) e WAN (host3a) acessando DMZ (host2a) via HTTP </p>
</p>
<br>




