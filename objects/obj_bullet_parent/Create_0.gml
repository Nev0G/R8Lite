/// @desc Variables de base d'un projectile
damage = 0;
move_speed = 0;
direction_travel = 0;   // angle en degrés
owner = noone;          // instance du joueur qui a tiré (évite le tir sur soi-même)
lifetime_max = 90;      // frames avant auto-destruction (évite les balles perdues à l'infini)
lifetime_current = 0;