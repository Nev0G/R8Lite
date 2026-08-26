/// @desc Rendu du texte avec contour
if (alpha <= 0) exit;

draw_set_alpha(alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _color = is_crit ? c_yellow : c_white;
var _str = is_crit ? string(damage_text) + "!" : string(damage_text);

// Contour noir
draw_set_color(c_black);
draw_text_transformed(x - 1, y, _str, scale, scale, 0);
draw_text_transformed(x + 1, y, _str, scale, scale, 0);
draw_text_transformed(x, y - 1, _str, scale, scale, 0);
draw_text_transformed(x, y + 1, _str, scale, scale, 0);

// Texte principal
draw_set_color(_color);
draw_text_transformed(x, y, _str, scale, scale, 0);

draw_set_alpha(1.0);
draw_set_color(c_white);