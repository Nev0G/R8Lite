/// @desc Dessine une barre de vie avec fond, remplissage et contour
/// @param _x Position X du coin supérieur gauche
/// @param _y Position Y du coin supérieur gauche
/// @param _hp_current HP actuel
/// @param _hp_max HP maximum
/// @param _color_fill Couleur de remplissage de la barre

function draw_hud_healthbar(_x, _y, _hp_current, _hp_max, _color_fill)
{
    var _width = 200;
    var _height = 24;
    var _ratio = clamp(_hp_current / _hp_max, 0, 1);

    // Fond (barre vide, gris foncé)
    draw_set_color(c_dkgray);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);

    // Remplissage proportionnel au HP actuel
    draw_set_color(_color_fill);
    draw_rectangle(_x, _y, _x + (_width * _ratio), _y + _height, false);

    // Contour
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _width, _y + _height, true);

    // Texte HP par-dessus (ex: "66/100")
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_x + _width / 2, _y + _height / 2, string(_hp_current) + "/" + string(_hp_max));
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}