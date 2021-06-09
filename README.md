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


Agora, execute a máquina virtual, defina o seu usuário, e execute os comandos:
<p>
sudo apt install nginx
sudo apt install openssh-server
sudo apt install lynx
sudo apt install ftp
sudo apt install iptables
sudo apt install bind9
sudo apt install proftpd
sudo apt install telnetd
<p>

Para poupar trabalho, iremos clonar essa primeira maquina virtual 4 vezes, se atente as opções para gerar novos discos virtuais e novos endereços MAC para as placas de rede. Feche a VM carregada e realize as clonagens, basta clicar com o botão direito na VM e clonar (seguindo os menus).

Terminadas as clonagens, renomeie as VM's para: host1a, host1b, host2a, host3a e Firewall. Em seguida, iremos ativar as interfaces de rede do nós (tal qual na Figura 2), nas VM's LAN (host1a, host1b) e DMZ (host2a) habilite uma placa de rede interna, na VM da WAN (host3a) habilite uma placa de rede interna e uma placa de rede NAT, na VM do Firewall habilite três placas de rede interna.

Nas máquinas da LAN (host1a e host1b), o nome associada a placa de rede será intnet1, na máquina da DMZ (host2a) o nome será intnet2, na placa de rede interna da WAN (host3a) o nome será intnet3, por fim, na VM do Firewall nomeie a primeira placa de rede interna com a intnet1, a segunda com intnet2 e a terceira com a intnet3. 


















