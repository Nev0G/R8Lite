/// @desc Fonctions d'envoi/réception réseau P2P

function network_send_state()
{
    var _buf = buffer_create(72, buffer_fixed, 1);
    buffer_write(_buf, buffer_u8, PKT_STATE);
    buffer_write(_buf, buffer_f32, x);
    buffer_write(_buf, buffer_f32, y);
    buffer_write(_buf, buffer_f32, hspeed_current); // ajouté
    buffer_write(_buf, buffer_f32, vspeed_current); // ajouté
    buffer_write(_buf, buffer_f32, aim_direction);
	buffer_write(_buf, buffer_f32, is_sliding);
    buffer_write(_buf, buffer_s16, hp_current);
    buffer_write(_buf, buffer_u8, is_dead);
    buffer_write(_buf, buffer_s8, current_weapon_type);
    buffer_write(_buf, buffer_u8, image_xscale > 0 ? 1 : 0);

    steam_net_packet_send(global.opponent_steam_id, _buf, -1);
    buffer_delete(_buf);
}

function network_send_hit(_damage)
{
    var _buf = buffer_create(8, buffer_fixed, 1);
    buffer_write(_buf, buffer_u8, PKT_HIT);
    buffer_write(_buf, buffer_s16, _damage);

    steam_net_packet_send(global.opponent_steam_id, _buf, -1);
    buffer_delete(_buf);
}

function network_send_player_died(_killer_steam_id)
{
    var _buf = buffer_create(16, buffer_fixed, 1);
    buffer_write(_buf, buffer_u8, PKT_PLAYER_DIED);
    buffer_write(_buf, buffer_u64, _killer_steam_id);

    steam_net_packet_send(global.opponent_steam_id, _buf, -1);
    buffer_delete(_buf);
}

function network_send_round_sync()
{
    with (obj_round_manager)
    {
        var _buf = buffer_create(32, buffer_fixed, 1);
        buffer_write(_buf, buffer_u8, PKT_ROUND_SYNC);
        buffer_write(_buf, buffer_string, round_state);
        buffer_write(_buf, buffer_s32, round_number);
        buffer_write(_buf, buffer_s16, score_player1);
        buffer_write(_buf, buffer_s16, score_player2);

        steam_net_packet_send(global.opponent_steam_id, _buf, -1);
        buffer_delete(_buf);
    }
}

