/// @desc Gestionnaire de lobby Steamworks

lobby_id = -1;              // ID du lobby actuel (steam_id), -1 si aucun
lobby_state = "idle";       // "idle", "searching", "creating", "in_lobby"
lobby_members = [];         // liste des steam_id des membres du lobby

// Type de lobby : lobby amis uniquement, pour l'instant (le plus simple à tester)
LOBBY_MAX_MEMBERS = 1;      // 1v1 pour commencer

is_lobby_host = false; // true si c'est nous qui avons créé le lobby
my_steam_id = steam_get_user_steam_id();