/// @desc Types de paquets réseau

#macro PKT_STATE 0    // état d'un joueur (position, hp, arme, visée)
#macro PKT_HIT 1      // notification de dégâts reçus
#macro PKT_PLAYER_DIED 2  // un joueur signale sa propre mort à l'hôte
#macro PKT_ROUND_SYNC 3   // l'hôte diffuse l'état du round au client
#macro PKT_SHOOT 5
#macro PKT_WEAPON_THROW 6
#macro PKT_WEAPON_PICKUP 7
#macro PKT_MELEE 8
#macro PKT_DISARM 9