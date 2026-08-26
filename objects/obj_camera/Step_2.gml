/// @desc Suivi de cible et secousse d'écran

// Trouver le joueur local
if (!instance_exists(target))
{
    with (obj_player)
    {
        if (is_local_player) other.target = id;
    }
}

if (instance_exists(target))
{
    var _target_x = target.x - (view_w * 0.5);
    var _target_y = (target.y + target.weapon_sprite_offset_y) - (view_h * 0.5);

    var _cur_x = camera_get_view_x(cam);
    var _cur_y = camera_get_view_y(cam);

    var _new_x = lerp(_cur_x, _target_x, 0.15);
    var _new_y = lerp(_cur_y, _target_y, 0.15);

    // Calcul du Screenshake
    var _offset_x = 0;
    var _offset_y = 0;

    if (shake_duration > 0)
    {
        shake_duration--;
        _offset_x = random_range(-shake_intensity, shake_intensity);
        _offset_y = random_range(-shake_intensity, shake_intensity);
        shake_intensity = lerp(shake_intensity, 0, 0.1);
    }

    camera_set_view_pos(cam, _new_x + _offset_x, _new_y + _offset_y);
}