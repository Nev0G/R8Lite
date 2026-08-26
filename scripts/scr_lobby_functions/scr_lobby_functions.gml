function lobby_create()
{
    with (obj_lobby_manager)
    {
        lobby_state = "creating";
        steam_lobby_create(steam_lobby_type_friends_only, LOBBY_MAX_MEMBERS);
    }
    show_debug_message("Création de lobby demandée...");
}

function lobby_search_and_join()
{
    with (obj_lobby_manager)
    {
        lobby_state = "searching";
        steam_lobby_list_add_string_filter("game_name", "R8L", 0); // 0 = comparaison "égal à"
        steam_lobby_list_request();
    }
    show_debug_message("Recherche de lobby R8L en cours...");
}

function lobby_leave()
{
    with (obj_lobby_manager)
    {
        if (lobby_id != -1)
        {
            steam_lobby_leave(lobby_id);
            lobby_id = -1;
            lobby_state = "idle";
            lobby_members = [];
        }
    }
    show_debug_message("Lobby quitté.");
}

function lobby_refresh_members()
{
    with (obj_lobby_manager)
    {
        lobby_members = [];
        var _member_count = steam_lobby_get_member_count(lobby_id);

        for (var i = 0; i < _member_count; i++)
        {
            var _member_id = steam_lobby_get_member_id(lobby_id, i);
            array_push(lobby_members, _member_id);
        }

        show_debug_message("Membres du lobby: " + string(array_length(lobby_members)));

        if (array_length(lobby_members) >= LOBBY_MAX_MEMBERS && lobby_state == "in_lobby")
        {
            show_debug_message("Lobby complet ! Lancement de la partie...");
            lobby_state = "starting_game";
            game_start();
        }
    }
}


function game_start()
{
    with (obj_lobby_manager)
    {
        steam_lobby_set_joinable(lobby_id, false);

        global.is_host = is_lobby_host;
        global.local_steam_id = my_steam_id;

        // Trouve l'ID Steam de l'adversaire (l'autre membre du lobby)
        for (var i = 0; i < array_length(lobby_members); i++)
        {
            if (lobby_members[i] != my_steam_id)
            {
                global.opponent_steam_id = lobby_members[i];
            }
        }

        steam_net_set_auto_accept_p2p_sessions(true);

        show_debug_message("Démarrage. Host=" + string(global.is_host) + " Local=" + string(global.local_steam_id) + " Adversaire=" + string(global.opponent_steam_id));
    }

    room_goto(rm_test_movement);
}