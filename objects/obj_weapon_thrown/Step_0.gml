/// @desc obj_weapon_thrown - Step Event corrigé (Gravité et Chute)

// 1. Appliquer la gravité pour que l'arme tombe vers le sol
vspeed_current += 0.35; 

// 2. Friction de l'air légère
hspeed_current *= 0.99;

// 3. Gestion des collisions horizontales (Murs)
if (place_meeting(x + hspeed_current, y, obj_wall)) {
    hspeed_current *= -0.4; // Rebond amorti
}
x += hspeed_current;

// 4. Gestion des collisions verticales (Sol / Plafond)
if (place_meeting(x, y + vspeed_current, obj_wall)) {
    vspeed_current *= -0.3; // Rebond vertical amorti
    hspeed_current *= 0.8;  // Friction quand elle touche le sol
}
y += vspeed_current;

// 5. Rotation visuelle rapide en l'air (Style Arcade)
image_angle += hspeed_current * 4;

// Collision et dégâts sur les joueurs adverses
var _target = instance_place(x, y, obj_player);
if (_target != noone && _target != owner && !_target.is_dead)
{
    _target.hp_current -= throw_damage;
    
    // --- POPUP DE DÉGÂTS ---
    var _popup = instance_create_layer(_target.x, _target.y - 40, "Instances", obj_damage_popup);
    with (_popup) {
        damage_text = other.throw_damage; // Utilisation de damage_text
        is_crit = false;
    }

    if (_target.hp_current <= 0)
    {
        _target.hp_current = 0;
        _target.is_dead = true;
        if (global.is_host) with (obj_round_manager) { player_died(_target, other.owner); }
        else network_send_player_died(global.opponent_steam_id);
    }

    // Rebond de l'arme après l'impact
    hspeed_current *= -0.3;
    vspeed_current *= -0.3;
}

// 7. Si l'arme est presque à l'arrêt ET qu'elle touche le sol, elle se pose (devient un pickup)
if (abs(hspeed_current) < 0.4 && abs(vspeed_current) < 0.4 && place_meeting(x, y + 2, obj_wall))
{
    var _pickup = instance_create_layer(x, y, "Instances", obj_weapon_pickup);
    _pickup.weapon_type = weapon_type;
    _pickup.ammo_current = ammo_current;
    _pickup.reserve_ammo_current = reserve_ammo_current;
    _pickup.pickup_locked_until = current_time + 300; 
    
    instance_destroy();
}