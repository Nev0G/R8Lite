/// @desc Affichage du HUD et du Viseur

if (!is_local_player) exit;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// ==========================================
// 1. BARRE DE VIE ANIMÉE (Haut - Gauche)
// ==========================================
var _bar_x = 40;
var _bar_y = 40;
var _bar_w = 260;
var _bar_h = 18;

// La barre "lag" rattrape doucement la vraie vie
hp_lag = lerp(hp_lag, hp_current, 0.08);

var _pct_real = clamp(hp_current / hp_max, 0, 1);
var _pct_lag  = clamp(hp_lag / hp_max, 0, 1);

// Fond noir
draw_set_color(c_black);
draw_rectangle(_bar_x - 3, _bar_y - 3, _bar_x + _bar_w + 3, _bar_y + _bar_h + 3, false);

// Barre jaune (dégâts temporaires)
draw_set_color(c_yellow);
draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _pct_lag), _bar_y + _bar_h, false);

// Barre rouge (vie actuelle)
draw_set_color(make_color_rgb(220, 40, 40));
draw_rectangle(_bar_x, _bar_y, _bar_x + (_bar_w * _pct_real), _bar_y + _bar_h, false);

// Texte PV
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_text(_bar_x, _bar_y - 6, "HP : " + string(ceil(hp_current)) + " / " + string(hp_max));


// ==========================================
// 2. MUNITIONS & ARME (Bas - Droite)
// ==========================================
var _box_w = 200;
var _box_h = 70;
var _box_x = _gui_w - _box_w - 40;
var _box_y = _gui_h - _box_h - 40;

// Fond du bloc arme
draw_set_color(c_black);
draw_set_alpha(0.6);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);
draw_set_alpha(1.0);

draw_set_color(c_white);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);

if (current_weapon_type != -1 && current_weapon_config != undefined)
{
    var _cfg = current_weapon_config;

    // Nom de l'arme
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(_box_x + 15, _box_y + 12, _cfg.name);

    // Compteur de munitions
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    if (_cfg.is_melee)
    {
        draw_text_transformed(_box_x + _box_w - 15, _box_y + _box_h - 10, "INF", 1.3, 1.3, 0);
    }
    else
    {
        var _ammo_str = string(ammo_current) + " / " + string(reserve_ammo_current);
        var _color_ammo = (ammo_current <= 0) ? c_red : c_white;
        draw_set_color(_color_ammo);
        draw_text_transformed(_box_x + _box_w - 15, _box_y + _box_h - 10, _ammo_str, 1.2, 1.2, 0);
    }
}
else
{
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_gray);
    draw_text(_box_x + (_box_w * 0.5), _box_y + (_box_h * 0.5), "AUCUNE ARME");
}


// ==========================================
// 3. CURSEUR DYNAMIQUE & HITMARKER
// ==========================================
var _mx = window_mouse_get_x();
var _my = window_mouse_get_y();

// Réticule central
draw_set_color(c_white);
draw_circle(_mx, _my, 3, false);
draw_line(_mx - 9, _my, _mx - 4, _my);
draw_line(_mx + 5, _my, _mx + 10, _my);
draw_line(_mx, _my - 9, _mx, _my - 4);
draw_line(_mx, _my + 5, _mx, _my + 10);

// Hitmarker en X si une touche est confirmée
if (hitmarker_timer > 0)
{
    hitmarker_timer--;
    var _hm_color = hitmarker_is_crit ? c_yellow : c_red;
    var _size = hitmarker_is_crit ? 9 : 6;

    draw_set_color(_hm_color);
    draw_line_width(_mx - _size, _my - _size, _mx - 3, _my - 3, 2);
    draw_line_width(_mx + 3, _my + 3, _mx + _size, _my + _size, 2);
    draw_line_width(_mx + 3, _my - 3, _mx + _size, _my - _size, 2);
    draw_line_width(_mx - _size, _my + _size, _mx - 3, _my + 3, 2);
}

draw_set_color(c_white);
draw_set_alpha(1.0);