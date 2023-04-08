#! /bin/bash
 
####### Menage avant initialisation
# Si pas d'autres scripts avec iptables :
iptables -X
iptables -F
# On nettoie les chaines du code
iptables -X INTO-P2
iptables -X INTO-P3
iptables -X INTO-P4
 
###### Accepter les connexions en cours #######
iptables -A INPUT -p tcp --dport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m state --state RELATED -j ACCEPT
 
####### Etapes du code secret #######
####### Creation des chaines puis ajout des regles
iptables -N INTO-P2
iptables -A INTO-P2 -m recent --name P1 --remove
iptables -A INTO-P2 -m recent --name P2 --set
iptables -A INTO-P2 -j LOG --log-prefix "INTO P2: "
 
iptables -N INTO-P3
iptables -A INTO-P3 -m recent --name P2 --remove
iptables -A INTO-P3 -m recent --name P3 --set
iptables -A INTO-P3 -j LOG --log-prefix "INTO P3: "
 
iptables -N INTO-P4
iptables -A INTO-P4 -m recent --name P3 --remove
iptables -A INTO-P4 -m recent --name P4 --set
iptables -A INTO-P4 -j LOG --log-prefix "INTO P4: "
 
iptables -A INPUT -m recent --update --name P1
 
####### Definition du code secret avec le délai pour chaque phase avant expiration. 
####### Ici exemple 100 puis 200 puis 300 puis 400. Aléatoire conseillé
 
iptables -A INPUT -p tcp --dport 100 -m recent --name P1 --set
iptables -A INPUT -p tcp --dport 200 -m recent --rcheck --seconds 10 --name P1 -j INTO-P2
iptables -A INPUT -p tcp --dport 300 -m recent --rcheck --seconds 10 --name P2 -j INTO-P3
iptables -A INPUT -p tcp --dport 400 -m recent --rcheck --seconds 10 --name P3 -j INTO-P4
 
####### Une fois la P4 atteinte, la connexion port SSH dispo.
 
iptables -A INPUT -p tcp --dport 22 -m recent --rcheck --seconds 10 --name P4 -j ACCEPT
 
####### Règle par défaut si tout ce qui est au dessus est pas respecté : port 22 fermé ########
 
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j DROP