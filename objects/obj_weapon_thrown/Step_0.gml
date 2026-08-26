/// @desc Physique de vol, dégâts et retombée au sol

// 1. Gravité spécifique à l'arme
var _cfg = weapon_get_config(weapon_type);
if (_cfg != undefined && variable_struct_exists(_cfg, "throw_gravity"))
{
    gravity_force = _cfg.throw_gravity;
}
vspeed_current += gravity_force;

// 2. Rotation visuelle de l'arme en vol
image_angle -= hspeed_current * 3.5;

// 3. Collision et dégâts sur les joueurs
if (is_active && point_distance(0, 0, hspeed_current, vspeed_current) > 2.5)
{
    var _hit_player = instance_place(x, y, obj_player);
    if (_hit_player != noone && _hit_player != owner && !_hit_player.is_dead)
    {
        if (owner != noone && owner.is_local_player)
        {
            _hit_player.hp_current -= throw_damage;
            network_send_hit(throw_damage);

            if (_hit_player.hp_current <= 0)
            {
                _hit_player.hp_current = 0;
                _hit_player.is_dead = true;
                if (global.is_host) with (obj_round_manager) { player_died(_hit_player, other.owner); }
                else network_send_player_died(global.opponent_steam_id);
            }
        }

        // Rebond après impact
        hspeed_current = -hspeed_current * 0.3;
        vspeed_current = -3;
        is_active = false;
    }
}

// 4. Collisions avec les murs
if (place_meeting(x + hspeed_current, y, obj_wall))
{
    while (!place_meeting(x + sign(hspeed_current), y, obj_wall)) x += sign(hspeed_current);
    hspeed_current = -hspeed_current * 0.4;
    if (abs(hspeed_current) < 1) hspeed_current = 0;
}
x += hspeed_current;

if (place_meeting(x, y + vspeed_current, obj_wall))
{
    while (!place_meeting(x, y + sign(vspeed_current), obj_wall)) y += sign(vspeed_current);

    if (vspeed_current > 0 && bounces_left > 0)
    {
        vspeed_current = -vspeed_current * 0.35;
        bounces_left--;
    }
    else
    {
        vspeed_current = 0;
    }
}
y += vspeed_current;

// 5. Retombée au sol : redevient un pickup ramassable
if (place_meeting(x, y + 1, obj_wall) && abs(hspeed_current) < 0.5 && abs(vspeed_current) < 0.5)
{
    var _pickup = instance_create_layer(x, y, "Instances", obj_weapon_pickup);
    _pickup.weapon_type = weapon_type;
    _pickup.ammo_current = ammo_current;
    _pickup.reserve_ammo_current = reserve_ammo_current;
    _pickup.pickup_locked_until = current_time + 400; // Délai anti-ramassage immédiat

    instance_destroy();
}