/// @desc Déplacement en ligne droite + durée de vie
x += lengthdir_x(move_speed, direction_travel);
y += lengthdir_y(move_speed, direction_travel);

lifetime_current++;
if (lifetime_current >= lifetime_max)
{
    instance_destroy();
}

// --- Collision avec un mur ---
if (place_meeting(x, y, obj_wall))
{
    instance_destroy();
}

// --- Collision avec un joueur (sauf le tireur) ---
var _hit_player = instance_place(x, y, obj_player);
if (_hit_player != noone && _hit_player != owner && !_hit_player.is_dead)
{
    if (owner != noone && owner.is_local_player) 
    {
        _hit_player.hp_current -= damage;
        network_send_hit(damage); // ← AJOUTÉ : notifie le vrai HP côté adversaire

        if (_hit_player.hp_current <= 0)
        {
            _hit_player.hp_current = 0;
            _hit_player.is_dead = true;
            if (global.is_host) with (obj_round_manager) { player_died(_hit_player, other.owner); }
            else network_send_player_died(global.opponent_steam_id);
        }
    }
    
    instance_destroy(); 
}