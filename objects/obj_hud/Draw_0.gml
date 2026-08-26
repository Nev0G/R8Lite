/// @desc Affichage du HUD (barres de vie + score)

draw_set_font(font_hud);

var _local_player = noone;
var _remote_player = noone;

with (obj_player)
{
    if (is_local_player) _local_player = id;
    else _remote_player = id;
}

// --- Barre de vie du joueur LOCAL (toujours à gauche, "Vous") ---
if (_local_player != noone)
{
    draw_hud_healthbar(hud_bar_margin, hud_bar_margin, _local_player.hp_current, _local_player.hp_max, c_lime);
    draw_set_color(c_white);
    draw_text(hud_bar_margin, hud_bar_margin - 20, "Vous");

    // --- NOUVEAU : Affichage des munitions ---
    if (_local_player.current_weapon_type != -1 && _local_player.current_weapon_config != undefined)
    {
        var _cfg = _local_player.current_weapon_config;
        
        // On n'affiche les munitions que si ce n'est pas une arme de mêlée
        if (!variable_struct_exists(_cfg, "is_melee") || !_cfg.is_melee)
        {
            var _ammo_y = hud_bar_margin + hud_bar_height + 5; // Juste sous la barre de vie
            
            if (_local_player.is_reloading)
            {
                draw_set_color(c_yellow);
                draw_text(hud_bar_margin, _ammo_y, "Rechargement...");
            }
            else if (_local_player.ammo_current == 0 && _local_player.reserve_ammo_current == 0)
            {
                // Plus aucune balle nulle part !
                draw_set_color(c_red);
                draw_text(hud_bar_margin, _ammo_y, "VIDE ! CLIC DROIT POUR JETER !");
            }
            else
            {
                if (_local_player.ammo_current == 0) draw_set_color(c_red);
                else draw_set_color(c_white);
                
                // Calcul du total absolu (ce qu'il y a dans l'arme + les poches)
                var _total_ammo = _local_player.ammo_current + _local_player.reserve_ammo_current;
                
                // Affichage clair du chargeur et du total
                draw_text(hud_bar_margin, _ammo_y, "Chargeur : " + string(_local_player.ammo_current) + " | Total restant : " + string(_total_ammo));
			 }
            }
        }
    }


// --- Barre de vie de l'ADVERSAIRE (toujours à droite) ---
if (_remote_player != noone)
{
    var _x2 = display_get_gui_width() - hud_bar_margin - hud_bar_width;
    draw_hud_healthbar(_x2, hud_bar_margin, _remote_player.hp_current, _remote_player.hp_max, c_red);
    draw_set_color(c_white);
    draw_set_halign(fa_right);
    draw_text(_x2 + hud_bar_width, hud_bar_margin - 20, "Adversaire");
    draw_set_halign(fa_left);
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