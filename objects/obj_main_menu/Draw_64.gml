/// @desc Affichage du titre et des boutons

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// ==========================================
// 1. TITRE DU JEU
// ==========================================
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _title_x = menu_x;
var _title_y = 120;

// Ombre portée
draw_set_color(c_dkgray);
draw_text_transformed(_title_x + 4, _title_y + 4, "PROJECT R8L", 2.2, 2.2, 0);

// Texte principal
draw_set_color(c_white);
draw_text_transformed(_title_x, _title_y, "PROJECT R8L", 2.2, 2.2, 0);

// Sous-titre
draw_set_color(c_gray);
draw_text_transformed(_title_x, _title_y + 65, "FAST-PACED 2D ARENA SHOOTER", 1.0, 1.0, 0);


// ==========================================
// 2. LISTE DES OPTIONS
// ==========================================
draw_set_valign(fa_middle);

for (var i = 0; i < menu_count; i++)
{
    var _item_y = menu_y_start + (i * menu_item_height);
    var _is_selected = (menu_index == i);
    var _scale = item_scales[i];

    var _btn_w = 300 * _scale;
    var _btn_h = 36 * _scale;
    var _draw_x = menu_x + (_is_selected ? 15 : 0); // Décalage vers la droite si sélectionné

    // Fond du bouton
    draw_set_alpha(_is_selected ? 0.25 : 0.08);
    draw_set_color(_is_selected ? c_aqua : c_white);
    draw_rectangle(_draw_x - 10, _item_y - (_btn_h * 0.5), _draw_x + _btn_w, _item_y + (_btn_h * 0.5), false);

    // Bordure gauche d'accentuation
    if (_is_selected)
    {
        draw_set_alpha(1.0);
        draw_rectangle(_draw_x - 10, _item_y - (_btn_h * 0.5), _draw_x - 6, _item_y + (_btn_h * 0.5), false);
    }

    // Texte du bouton
    draw_set_alpha(1.0);
    draw_set_color(_is_selected ? c_white : c_silver);
    draw_text_transformed(_draw_x + 10, _item_y, options[i], _scale, _scale, 0);
}

// ==========================================
// 3. INFORMATIONS STEAM (Bas - Gauche)
// ==========================================
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_color(c_dkgray);

var _user_name = steam_get_persona_name();
if (_user_name == "") _user_name = "Joueur Local";
draw_text(30, _gui_h - 20, "Connecté : " + _user_name);

draw_set_color(c_white);