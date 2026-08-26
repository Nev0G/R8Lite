/// @desc Affichage du HUD (barres de vie + score)

draw_set_font(font_hud);

var _local_player = noone;
var _remote_player = noone;

with (obj_player)
{
    if (is_local_player) _local_player = id;
    else _remote_player = id;
}


// --- Score (centré en haut) ---
with (obj_round_manager)
{
    var _score_text = string(score_player1) + "  -  " + string(score_player2);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text(display_get_gui_width() / 2, other.hud_bar_margin, _score_text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}