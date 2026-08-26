/// @desc Trajectoire et calcul des tirs à la tête

x += lengthdir_x(move_speed, direction_travel);
y += lengthdir_y(move_speed, direction_travel);
image_angle = direction_travel;

// Collision mur
if (place_meeting(x, y, obj_wall))
{
    instance_destroy();
    exit;
}

// Collision joueur
var _hit = instance_place(x, y, obj_player);
if (_hit != noone && _hit != owner && !_hit.is_dead)
{
    if (owner != noone && owner.is_local_player)
    {
        var _head_threshold = _hit.bbox_top + (_hit.bbox_bottom - _hit.bbox_top) * 0.30;
        var _is_headshot = (y <= _head_threshold);

        var _mult = _is_headshot ? headshot_mult : 1.0;
        var _final_damage = round(damage * _mult);

        _hit.hp_current -= _final_damage;
        _hit.flash_timer = 3; // Flash blanc sur la cible
        network_send_hit(_final_damage);

        // Effets de Juice
        spawn_damage_popup(_hit.x, _hit.bbox_top, _final_damage, _is_headshot);
        trigger_screenshake(_is_headshot ? 6.0 : 3.0, _is_headshot ? 12 : 6);

        // Feedback au tireur local
        owner.hitmarker_timer = 8;
        owner.hitmarker_is_crit = _is_headshot;

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