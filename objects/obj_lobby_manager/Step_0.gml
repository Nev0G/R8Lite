/// @desc Traitement des paquets réseau entrants (à chaque frame)

while (steam_net_packet_receive())
{
    var _sender_id = steam_net_packet_get_sender_id();
    var _size = steam_net_packet_get_size();
    var _buf = buffer_create(_size, buffer_fixed, 1);
    steam_net_packet_get_data(_buf);

    var _packet_type = buffer_read(_buf, buffer_u8);

    switch (_packet_type)
    {
        case PKT_STATE:
    var _px = buffer_read(_buf, buffer_f32);
    var _py = buffer_read(_buf, buffer_f32);
    var _pvx = buffer_read(_buf, buffer_f32); // ajouté
    var _pvy = buffer_read(_buf, buffer_f32); // ajouté
    var _aim = buffer_read(_buf, buffer_f32);
    var _hp = buffer_read(_buf, buffer_s16);
    var _dead = buffer_read(_buf, buffer_u8);
    var _weapon = buffer_read(_buf, buffer_s8);
    var _facing = buffer_read(_buf, buffer_u8);

    with (obj_player)
    {
        if (!is_local_player)
        {
            net_pos_x = _px;
            net_pos_y = _py;
            net_vel_x = _pvx;
            net_vel_y = _pvy;
            aim_direction = _aim;
            hp_current = _hp;
            is_dead = _dead;
            current_weapon_type = _weapon;
            current_weapon_config = (_weapon != -1) ? weapon_get_config(_weapon) : undefined;
            image_xscale = (_facing == 1) ? 1 : -1;
        }
    }
    break;

        case PKT_HIT:
            var _damage = buffer_read(_buf, buffer_s16);
            // On a été touché : c'est NOUS qui sommes autorité sur notre propre HP
            with (obj_player)
            {
                if (is_local_player && !is_dead)
                {
                    hp_current -= _damage;
                    if (hp_current <= 0)
                    {
                        hp_current = 0;
                        is_dead = true;

                      if (global.is_host)
						{
						    var _killer_instance = noone;
						    with (obj_player) { if (!is_local_player) _killer_instance = id; }
						    with (obj_round_manager) { player_died(other, _killer_instance); }
						}
                        else
                        {
                            network_send_player_died(global.opponent_steam_id);
                        }
                    }
                }
            }
            break;

        case PKT_PLAYER_DIED:
            // Seul l'hôte doit traiter ceci (le client qui est mort nous le signale)
            if (global.is_host)
            {
                var _killer_id = buffer_read(_buf, buffer_u64);
                with (obj_round_manager)
                {
                    var _dead_player = noone;
                    var _killer_player = noone;
                    with (obj_player)
                    {
                        if (!is_local_player) _dead_player = id;
                        else _killer_player = id;
                    }
                    player_died(_dead_player, _killer_player);
                }
            }
            break;

        case PKT_ROUND_SYNC:
            // Seul le client (non-hôte) applique ceci
            if (!global.is_host)
            {
                var _state = buffer_read(_buf, buffer_string);
                var _round_num = buffer_read(_buf, buffer_s32);
                var _s1 = buffer_read(_buf, buffer_s16);
                var _s2 = buffer_read(_buf, buffer_s16);

                with (obj_round_manager)
                {
                    round_state = _state;
                    round_number = _round_num;
                    score_player1 = _s1;
                    score_player2 = _s2;
                }
            }
            break;
			
			case PKT_SHOOT:
    var _px = buffer_read(_buf, buffer_f32);
    var _py = buffer_read(_buf, buffer_f32);
    var _aim = buffer_read(_buf, buffer_f32);
    var _weapon = buffer_read(_buf, buffer_s8);

    with (obj_player)
    {
        if (!is_local_player)
        {
            // On met à jour la cible d'extrapolation plutôt que de téléporter
            net_pos_x = _px;
            net_pos_y = _py;
            aim_direction = _aim;
            
            var _cfg = weapon_get_config(_weapon);
            if (_cfg != undefined)
            {
                var _torse_offset_y = -16;
                var _barrel_dist = _cfg.barrel_length;
                var _spawn_x = x + lengthdir_x(_barrel_dist, aim_direction);
                var _spawn_y = (y + _torse_offset_y) + lengthdir_y(_barrel_dist, aim_direction);

                if (variable_struct_exists(_cfg, "pellet_count"))
                {
                    var _spread = _cfg.spread_angle;
                    var _count = _cfg.pellet_count;
                    for (var i = 0; i < _count; i++)
                    {
                        var _angle_offset = random_range(-_spread * 0.5, _spread * 0.5);
                        var _bullet = instance_create_layer(_spawn_x, _spawn_y, "Instances", _cfg.bullet_object);
                        _bullet.damage = 0;
                        _bullet.move_speed = _cfg.bullet_speed;
                        _bullet.direction_travel = aim_direction + _angle_offset;
                        _bullet.owner = id;
                    }
                }
                else
                {
                    var _bullet = instance_create_layer(_spawn_x, _spawn_y, "Instances", _cfg.bullet_object);
                    _bullet.damage = 0;
                    _bullet.move_speed = _cfg.bullet_speed;
                    _bullet.direction_travel = aim_direction;
                    _bullet.owner = id;

                    if (variable_struct_exists(_cfg, "max_bounces")) _bullet.bounces_max = _cfg.max_bounces;
                }
            }
        }
    }
    break;
			
			case PKT_WEAPON_THROW:
            var _px = buffer_read(_buf, buffer_f32);
            var _py = buffer_read(_buf, buffer_f32);
            var _hx = buffer_read(_buf, buffer_f32);
            var _vy = buffer_read(_buf, buffer_f32);
            var _wtype = buffer_read(_buf, buffer_s8);
            var _ammo = buffer_read(_buf, buffer_s16);
            var _res = buffer_read(_buf, buffer_s16);

            var _thrown = instance_create_layer(_px, _py, "Instances", obj_weapon_thrown);
            _thrown.weapon_type = _wtype;
            _thrown.hspeed_current = _hx;
            _thrown.vspeed_current = _vy;
            _thrown.ammo_current = _ammo;
            _thrown.reserve_ammo_current = _res;
            
            // Le lanceur est l'adversaire
            with (obj_player) { if (!is_local_player) _thrown.owner = id; }

            var _cfg = weapon_get_config(_wtype);
            if (_cfg != undefined) _thrown.sprite_index = _cfg.sprite;
            break;

        case PKT_WEAPON_PICKUP:
            var _px = buffer_read(_buf, buffer_f32);
            var _py = buffer_read(_buf, buffer_f32);

            // On cherche l'arme au sol située à ces coordonnées et on la supprime
            var _nearest = instance_nearest(_px, _py, obj_weapon_pickup);
            
            // Marge de tolérance de 10 pixels au cas où les arrondis varient légèrement d'un PC à l'autre
            if (_nearest != noone && point_distance(_px, _py, _nearest.x, _nearest.y) < 10) 
			{
			    instance_destroy(_nearest);
			}
            break;
			
			
			case PKT_MELEE:
    var _px = buffer_read(_buf, buffer_f32);
    var _py = buffer_read(_buf, buffer_f32);
    var _aim = buffer_read(_buf, buffer_f32);

    with (obj_player)
    {
        if (!is_local_player)
        {
            net_pos_x = _px;
            net_pos_y = _py;
            aim_direction = _aim;
            melee_swing_timer = melee_swing_duration;
        }
    }
    break;
    }
	
	
	

    buffer_delete(_buf);
}



if (keyboard_check_pressed(vk_f1) && lobby_state == "idle")
{
    lobby_search_and_join();
}