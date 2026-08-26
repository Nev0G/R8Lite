/// @desc Affichage du joueur + de l'arme orientée vers la souris

// --- Dessin du joueur ---
var _facing_right = (aim_direction > 270 || aim_direction < 90);
image_xscale = _facing_right ? 1 : -1;

draw_self();

// --- Calcul de la position de la main ---
var _hand_x = x + (weapon_sprite_offset_x * (_facing_right ? 1 : -1));
var _hand_y = y + weapon_sprite_offset_y;

// --- Dessin de l'arme ---
if (current_weapon_type != -1 && current_weapon_config != undefined)
{
    var _weapon_sprite = current_weapon_config.sprite;
    var _weapon_yscale = _facing_right ? 1 : -1;

    draw_sprite_ext(
        _weapon_sprite,
        0,
        _hand_x,
        _hand_y,
        1,
        _weapon_yscale,
        aim_direction,
        c_white,
        1
    );
}

// --- Effet visuel d'attaque de mêlée (Arc / Éventail) ---
if (melee_swing_timer > 0 && current_weapon_config != undefined && current_weapon_config.is_melee)
{
    var _alpha = melee_swing_timer / melee_swing_duration;
    draw_set_alpha(_alpha * 0.4);
    draw_set_color(c_white);

    var _radius = current_weapon_config.melee_range;
    var _half_angle = current_weapon_config.melee_angle * 0.5;
    var _start_angle = aim_direction - _half_angle;
    var _end_angle = aim_direction + _half_angle;
    var _steps = 8;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_hand_x, _hand_y); // Centre placé sur la main
    
    for (var i = 0; i <= _steps; i++)
    {
        var _ang = _start_angle + ((_end_angle - _start_angle) * (i / _steps));
        var _vx = _hand_x + lengthdir_x(_radius, _ang);
        var _vy = _hand_y + lengthdir_y(_radius, _ang);
        draw_vertex(_vx, _vy);
    }
    
    draw_primitive_end();
    draw_set_alpha(1);
}