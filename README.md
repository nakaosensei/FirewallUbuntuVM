# Configurando um Firewall (políticas de segurança) em um ambiente virtualizado. 
Esse é um projeto de configuração de políticas de segurança de  Firewall em 5 máquinas virtuais, foram utilizadas 5 VM's Ubuntu 18.04 server, sendo 4 hosts e um roteador que contém as políticas de Firewall. A Figura 1 ilustra o cenário de rede a configurar, na qual são apresentadas as redes LAN, DMZ e WAN. As redes da LAN e DMZ estão atrás do Firewall, ou seja, todo tráfego que sair do Firewall deve ser mascarado através do uso de mascáramento NAT. O Host 4 tem acesso a internet e o compartilha com os demais dispositivos da rede. Também são apresentadas 7 políticas de segurança a serem implementadas.

<p>
  <img src="images/setup.png" alt="Cenário proposto" style="width:100%">
  <p align="center">Figura 1 - Cenário proposto</p>
</p>
<br>

Seguindo...
