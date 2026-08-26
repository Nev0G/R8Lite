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
var _hit = instance_place(x, y, obj_player);

if (_hit != noone && _hit != owner && !_hit.is_dead)
{
    // C'est le tireur local qui valide le tir
    if (owner != noone && owner.is_local_player)
    {
        // Détection de la zone touchée
        var _head_threshold = _hit.bbox_top + (_hit.bbox_bottom - _hit.bbox_top) * 0.30;
        var _is_headshot = (y <= _head_threshold);

        // Multiplicateur : x2 si headshot, x1 sinon
        var _multiplier = _is_headshot ? 2.0 : 1.0;
        var _final_damage = round(damage * _multiplier);

        _hit.hp_current -= _final_damage;
        network_send_hit(_final_damage);

        // Feedback visuel / sonore (optionnel)
        if (_is_headshot)
        {
            // Ex: Jouer un son d'impact métallique plus aigu ou afficher un popup
            // audio_play_sound(snd_headshot, 10, false);
        }

        if (_hit.hp_current <= 0)
        {
            _hit.hp_current = 0;
            _hit.is_dead = true;
            if (global.is_host) with (obj_round_manager) { player_died(_hit, other.owner); }
            else network_send_player_died(global.opponent_steam_id);
        }
    }

    instance_destroy();
}