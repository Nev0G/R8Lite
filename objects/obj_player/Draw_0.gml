/// @desc Affichage du joueur, des armes, effets et visées

// =========================================================
// 1. ORIENTATION ET CORPS DU JOUEUR
// =========================================================
// Pour le joueur local on regarde la souris, pour l'adversaire on regarde son angle de visée
var _facing_right = is_local_player ? (mouse_x >= x) : (aim_direction > 270 || aim_direction < 90);
image_xscale = _facing_right ? 1 : -1;

// Effet de traînée lumineuse pendant le Dash
if (dash_timer > 0)
{
    gpu_set_fog(true, c_aqua, 0, 0);
    draw_sprite_ext(
        sprite_index,
        image_index,
        x - (hspeed_current * 0.5),
        y - (vspeed_current * 0.5),
        image_xscale,
        image_yscale,
        image_angle,
        c_white,
        0.4
    );
    gpu_set_fog(false, c_white, 0, 0);
}

// Rendu du sprite avec flash blanc si le joueur prend des dégâts
if (flash_timer > 0)
{
    flash_timer--;
    gpu_set_fog(true, c_white, 0, 0);
    draw_self();
    gpu_set_fog(false, c_white, 0, 0);
}
else
{
    draw_self();
}


// =========================================================
// 2. POSITION DES MAINS ET RENDU DE L'ARME
// =========================================================
var _hand_x = x + (weapon_sprite_offset_x * (_facing_right ? 1 : -1));
var _hand_y = y + weapon_sprite_offset_y;

if (current_weapon_type != -1 && current_weapon_config != undefined)
{
    var _weapon_sprite = current_weapon_config.sprite;
    var _weapon_yscale = _facing_right ? 1 : -1;
    var _tint = active_reload_boost ? c_yellow : c_white;

    draw_sprite_ext(
        _weapon_sprite,
        0,
        _hand_x,
        _hand_y,
        1,
        _weapon_yscale,
        aim_direction,
        _tint,
        1
    );
}


// =========================================================
// 3. EFFET VISUEL D'ATTAQUE DE MÊLÉE (Arc / Éventail)
// =========================================================
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
    draw_vertex(_hand_x, _hand_y);

    for (var i = 0; i <= _steps; i++)
    {
        var _ang = _start_angle + ((_end_angle - _start_angle) * (i / _steps));
        var _vx = _hand_x + lengthdir_x(_radius, _ang);
        var _vy = _hand_y + lengthdir_y(_radius, _ang);
        draw_vertex(_vx, _vy);
    }

    draw_primitive_end();
    draw_set_alpha(1.0);
}


// =========================================================
// 4. PRÉDICTION DU JET D'ARME CHARGÉ (Style Worms)
// =========================================================
if (is_local_player && throw_charge > 0 && current_weapon_type != -1 && current_weapon_config != undefined)
{
    var _charge_ratio = throw_charge / throw_charge_max;
    var _sim_speed = lerp(throw_speed_min, throw_speed_max, _charge_ratio);
    if (current_weapon_config.is_melee) _sim_speed *= 1.25;

    var _sim_vx = lengthdir_x(_sim_speed, aim_direction);
    var _sim_vy = lengthdir_y(_sim_speed, aim_direction);
    var _grav = variable_struct_exists(current_weapon_config, "throw_gravity") ? current_weapon_config.throw_gravity : 0.45;

    // Trajectoire en pointillés
    draw_set_color(c_yellow);
    draw_set_alpha(0.7);

    var _steps = 14;
    for (var i = 1; i <= _steps; i++)
    {
        var _t = i * 2.5;
        var _pt_x = _hand_x + (_sim_vx * _t);
        var _pt_y = _hand_y + (_sim_vy * _t) + (0.5 * _grav * _t * _t);
        draw_circle(_pt_x, _pt_y, 2, false);
    }

    // Jauge de force au-dessus de la tête
    var _bar_w = 32;
    var _bar_h = 4;
    var _bar_x = x - (_bar_w * 0.5);
    var _bar_y = bbox_top - 14;

    draw_set_color(c_dkgray);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

    var _bar_color = merge_color(c_lime, c_red, _charge_ratio);
    draw_set_color(_bar_color);
    draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _charge_ratio), _bar_y + _bar_h, false);

    draw_set_alpha(1.0);
    draw_set_color(c_white);
}


// =========================================================
// 5. INTERFACE DU RECHARGEMENT ACTIF
// =========================================================
if (is_local_player && is_reloading && reload_timer_start > 0)
{
    var _bar_w = 36;
    var _bar_h = 5;
    var _bx = x - (_bar_w * 0.5);
    var _by = bbox_top - 8;

    // Cadre noir
    draw_set_color(c_black);
    draw_rectangle(_bx - 1, _by - 1, _bx + _bar_w + 1, _by + _bar_h + 1, false);

    // Zone parfaite de timing (40 % à 65 %)
    draw_set_color(c_aqua);
    draw_rectangle(_bx + (_bar_w * 0.40), _by, _bx + (_bar_w * 0.65), _by + _bar_h, false);

    // Curseur blanc en mouvement
    var _progress = 1.0 - (reload_timer_current / reload_timer_start);
    draw_set_color(c_white);
    draw_line_width(_bx + (_bar_w * _progress), _by - 2, _bx + (_bar_w * _progress), _by + _bar_h + 2, 2);
}