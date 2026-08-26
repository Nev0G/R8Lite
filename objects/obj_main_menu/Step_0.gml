/// @desc Navigation (Clavier & Souris) et Exécution

var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _select = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);

// 1. Navigation au clavier
if (_up)
{
    menu_index--;
    if (menu_index < 0) menu_index = menu_count - 1;
}
if (_down)
{
    menu_index++;
    if (menu_index >= menu_count) menu_index = 0;
}

// 2. Détection du survol à la souris sur le GUI
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

for (var i = 0; i < menu_count; i++)
{
    var _item_y = menu_y_start + (i * menu_item_height);
    var _btn_w = 320;
    var _btn_h = 40;

    // Si la souris survole cette option
    if (_mx >= menu_x && _mx <= menu_x + _btn_w && _my >= _item_y - 20 && _my <= _item_y + 20)
    {
        if (menu_index != i) menu_index = i;
        if (mouse_check_button_pressed(mb_left)) _select = true;
    }

    // Animation d'agrandissement doux pour l'option sélectionnée
    var _target_scale = (menu_index == i) ? 1.15 : 1.0;
    item_scales[i] = lerp(item_scales[i], _target_scale, 0.2);
}

// 3. Exécution de l'action sélectionnée
if (_select)
{
    switch (menu_index)
    {
        case 0: // Héberger une partie
            global.is_host = true;
            // Crée un lobby Steam (type: amis uniquement, 2 joueurs max)
            if (variable_global_exists("steam_api_active") && global.steam_api_active)
            {
                steam_lobby_create(steam_lobby_type_friends_only, 2);
            }
            room_goto(rm_test_movement); // Remplace par le nom de ta salle de jeu
            break;

        case 1: // Rejoindre un ami
            global.is_host = false;
            // Ouvre l'overlay Steam sur la liste d'amis
            if (variable_global_exists("steam_api_active") && global.steam_api_active)
            {
                steam_activate_overlay("Friends");
            }
            break;

        case 2: // Entraînement / Solo
            global.is_host = true;
            global.opponent_steam_id = -1;
            room_goto(rm_test_movement);
            break;

        case 3: // Basculer le plein écran
            window_set_fullscreen(!window_get_fullscreen());
            break;

        case 4: // Quitter
            game_end();
            break;
    }
}