/// @desc Réception des résultats asynchrones de Steamworks

var _event_type = async_load[? "event_type"];

switch (_event_type)
{
    // --- Résultat de la création de lobby ---
    case "lobby_created":
    var _success = async_load[? "success"];
    if (_success)
    {
        lobby_id = async_load[? "lobby_id"];
        lobby_state = "in_lobby";
        is_lobby_host = true;
        show_debug_message("Lobby créé avec succès. ID: " + string(lobby_id));
        steam_lobby_set_data(lobby_id, "game_name", "R8L");
        
        lobby_refresh_members(); // ← AJOUT : vérifie immédiatement si on doit démarrer
    }
    else
    {
        lobby_state = "idle";
        show_debug_message("Échec de la création du lobby.");
    }
    break;

    // --- Résultat de la recherche de lobbys disponibles ---
    case "lobby_list":
        var _lobby_count = async_load[? "lobby_count"];
        show_debug_message("Lobbys trouvés: " + string(_lobby_count));

        if (_lobby_count > 0)
        {
            var _target_lobby = steam_lobby_list_get_lobby_id(0);
			steam_lobby_join_id(_target_lobby);
        }
        else
        {
            show_debug_message("Aucun lobby trouvé, création d'un nouveau lobby...");
            lobby_create();
        }
        break;

    // --- Résultat de la tentative de rejoindre un lobby ---
    case "lobby_joined":
    var _join_success = (async_load[? "response"] == 0);
    if (_join_success)
    {
        lobby_id = async_load[? "lobby_id"];
        lobby_state = "in_lobby";
        show_debug_message("Lobby rejoint avec succès. ID: " + string(lobby_id));
        
        lobby_refresh_members(); // ← AJOUT ici aussi
    }
    else
    {
        lobby_state = "idle";
        show_debug_message("Échec pour rejoindre le lobby.");
    }
    break;

    case "lobby_member_join":
        show_debug_message("Un joueur a rejoint le lobby.");
        lobby_refresh_members();
        break;

	case "lobby_member_leave":
    show_debug_message("Un joueur a quitté le lobby.");
    
    if (room == rm_test_movement)
    {
        show_debug_message("L'adversaire a quitté la partie. Retour au menu.");
        
        lobby_state = "idle";
        lobby_id = -1;
        global.opponent_steam_id = -1;
        
        room_goto(rm_menu);
    }
    else
    {
        lobby_refresh_members();
    }
    break;

    // --- Debug : affiche tout event_type non géré explicitement ---
    default:
        show_debug_message("Event Steam non géré: " + string(_event_type));
        break;
}

show_debug_message("=== ASYNC STEAM EVENT REÇU ===");
var _keys = ds_map_keys_to_array(async_load);
for (var i = 0; i < array_length(_keys); i++)
{
    show_debug_message(string(_keys[i]) + " = " + string(async_load[? _keys[i]]));
}
