/// @desc Fonctions du gestionnaire de round

function player_died(_player, _killer)
{
    if (round_state != "active") return;

    if (_killer != noone && _killer != _player)
    {
        if (_killer.player_index == 1) score_player1++;
        else if (_killer.player_index == 2) score_player2++;
    }

    round_state = "round_end";
    round_end_timer = round_end_delay;

    show_debug_message("Round " + string(round_number) + " terminé. Score: " 
        + string(score_player1) + " - " + string(score_player2));

    if (global.is_host)
    {
        network_send_round_sync();
    }
}

function respawn_all_players()
{
    // On récupère la liste de tous les spawn points disponibles dans un tableau
    var _spawn_list = [];
    var _spawn_count = instance_number(obj_spawn_point);

    for (var i = 0; i < _spawn_count; i++)
    {
        array_push(_spawn_list, instance_find(obj_spawn_point, i));
    }

    // Mélange le tableau pour un ordre aléatoire
    array_shuffle(_spawn_list);

    var _index = 0;

    with (obj_player)
    {
        hp_current = hp_max;
        is_dead = false;

        // Assigne un spawn point différent à chaque joueur, dans l'ordre mélangé
        if (_index < array_length(_spawn_list))
        {
            x = _spawn_list[_index].x;
            y = _spawn_list[_index].y;
            _index++;
        }

        current_weapon_type = -1;
        current_weapon_config = undefined;
    }
}

/// @desc Mélange un tableau en place (algorithme de Fisher-Yates)
function array_shuffle(_array)
{
    var _len = array_length(_array);
    for (var i = _len - 1; i > 0; i--)
    {
        var _j = irandom(i);
        var _temp = _array[i];
        _array[i] = _array[_j];
        _array[_j] = _temp;
    }
    return _array;
}