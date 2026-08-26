/// @desc Initialisation des variables globales réseau (valeurs par défaut)

if (!variable_global_exists("is_host"))
{
    global.is_host = true; // valeur par défaut pour tests solo, sera écrasée par game_start()
}
if (!variable_global_exists("local_steam_id"))
{
    global.local_steam_id = steam_get_user_steam_id();
}
if (!variable_global_exists("opponent_steam_id"))
{
    global.opponent_steam_id = -1;
}