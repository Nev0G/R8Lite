// Récupération de la gravité spécifique à l'arme
var _cfg = weapon_get_config(weapon_type);
if (_cfg != undefined && variable_struct_exists(_cfg, "throw_gravity"))
{
    gravity_force = _cfg.throw_gravity;
}

if (!has_landed)
{
    // --- Collision avec un joueur (uniquement si l'arme est dangereuse) ---
    if (can_deal_damage)
    {
        var _hit = instance_place(x + hspeed_current, y + vspeed_current, obj_player);
        if (_hit != noone && _hit != owner && !_hit.is_dead)
        {
            // --- CORRECTION : C'est le lanceur qui valide le hit ---
            if (owner != noone && owner.is_local_player)
            {
                _hit.hp_current -= throw_damage;
                network_send_hit(throw_damage); 
                
                if (_hit.hp_current <= 0)
                {
                    _hit.hp_current = 0;
                    _hit.is_dead = true;
                    if (global.is_host) with (obj_round_manager) player_died(_hit, other.owner);
                    else network_send_player_died(global.opponent_steam_id);
                }
            }
            
            // Rebond de l'arme sur la tête du joueur !
            hspeed_current = -hspeed_current * 0.5; 
            vspeed_current = -4; 
            
            // L'arme ne peut plus blesser personne
            can_deal_damage = false; 
        }
    }

    vspeed_current += gravity_force;

    // Collision horizontale avec les murs
    if (place_meeting(x + hspeed_current, y, obj_wall))
    {
        hspeed_current = -hspeed_current * bounce_damping;
        can_deal_damage = false; // Elle a rebondi, elle n'est plus dangereuse
    }
    x += hspeed_current;

    // Collision verticale avec le sol/plafond
    if (place_meeting(x, y + vspeed_current, obj_wall))
    {
        vspeed_current = -vspeed_current * bounce_damping;
        can_deal_damage = false; // Elle a rebondi, elle n'est plus dangereuse
        
        if (abs(vspeed_current) < 1)
        {
            has_landed = true;
            vspeed_current = 0;
            hspeed_current = 0;

            // --- Transformation en pickup ramassable ---
            var _pickup = instance_create_layer(x, y, "Instances", obj_weapon_pickup);
            _pickup.weapon_type = weapon_type;
            _pickup.ammo_current = ammo_current;
            _pickup.reserve_ammo_current = reserve_ammo_current;
            
            instance_destroy();
        }
    }
    y += vspeed_current;
}