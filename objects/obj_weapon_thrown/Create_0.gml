weapon_type = -1;
hspeed_current = 0;
vspeed_current = 0;
gravity_force = 0.4;
bounce_damping = 0.5; // perte de vitesse à chaque rebond au sol
has_landed = false;

ammo_current = 0;
reserve_ammo_current = 0;
owner = noone;
throw_damage = 25; // Dégâts infligés par l'arme
can_deal_damage = true; // L'arme est dangereuse quand on vient de la jeter