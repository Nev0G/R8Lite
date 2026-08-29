/// @desc Bloc 0 : Vérification de vie
if (is_dead)
{
    if (is_local_player) network_send_state();
    exit;
}

if (is_local_player)
{
    /// @desc Bloc 1 : Acquisition des inputs
    key_left = keyboard_check(vk_left) || keyboard_check(ord("Q"));
    key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
    key_down = keyboard_check(vk_down) || keyboard_check(ord("S"));
    key_jump_pressed = keyboard_check_pressed(vk_space);
    key_slide = keyboard_check(vk_control) || keyboard_check(ord("C"));
    key_dash = keyboard_check_pressed(vk_shift);

    if (key_jump_pressed) key_jump = true;

    /// @desc Bloc 2 : Mouvements & Capacités physiques

    // --- Gestion du Dash ---
    if (dash_cooldown > 0) dash_cooldown--;

    if (key_dash && dash_cooldown <= 0 && dash_timer <= 0)
    {
        var _dx = (key_right - key_left);
        var _dy = (key_down - (keyboard_check(vk_up) || keyboard_check(ord("Z"))));

        if (_dx == 0 && _dy == 0) _dx = (aim_direction > 270 || aim_direction < 90) ? 1 : -1;

        var _d_len = point_distance(0, 0, _dx, _dy);
        dash_dir_x = (_dx / _d_len) * dash_speed;
        dash_dir_y = (_dy / _d_len) * dash_speed;

        dash_timer = dash_duration;
        dash_cooldown = dash_cooldown_max;
        is_ground_pounding = false;
    }

    if (dash_timer > 0)
    {
        dash_timer--;
        hspeed_current = dash_dir_x;
        vspeed_current = dash_dir_y;
    }
    else
    {
        // --- Coyote Time & Jump Buffer ---
        if (is_grounded) {
            coyote_time_current = coyote_time_max;
            is_ground_pounding = false;
        } else if (coyote_time_current > 0) {
            coyote_time_current--;
        }

        if (key_jump) {
            jump_buffer_current = jump_buffer_max;
        } else if (jump_buffer_current > 0) {
            jump_buffer_current--;
        }

        // --- Ground Pound (Pilonnage vertical) ---
        if (!is_grounded && key_down && !is_wall_sliding && !is_ground_pounding)
        {
            is_ground_pounding = true;
            vspeed_current = ground_pound_speed;
            hspeed_current *= 0.2;
        }

        // --- Glissade (Slide) & Super-Slide à l'atterrissage ---
        if (slide_cooldown_current > 0) slide_cooldown_current--;

        if (!is_sliding && key_slide && is_grounded && abs(hspeed_current) >= slide_speed_min && slide_cooldown_current <= 0)
        {
            is_sliding = true;
            slide_duration_current = slide_duration_max;
            hspeed_current *= slide_speed_boost;
        }

        if (is_sliding)
        {
            slide_duration_current--;
            if (!key_slide || !is_grounded || slide_duration_current <= 0 || abs(hspeed_current) < slide_speed_min)
            {
                is_sliding = false;
                slide_cooldown_current = slide_cooldown_max;
            }
        }

        // --- Mouvement horizontal standard ---
        var _input_dir = 0;
        if (key_left)  _input_dir -= 1;
        if (key_right) _input_dir += 1;

        if (wall_jump_lock_timer <= 0)
        {
            var _current_accel = is_grounded ? accel : accel_air;
            var _current_friction = is_sliding ? slide_friction : (is_grounded ? friction_ground : friction_air);

            if (_input_dir != 0 && !is_sliding)
            {
                var _target_speed = hspeed_current + _input_dir * _current_accel;
                if (abs(hspeed_current) > move_speed_max) hspeed_current = _target_speed;
                else hspeed_current = clamp(_target_speed, -move_speed_max, move_speed_max);
            }
            else
            {
                if (hspeed_current > 0) hspeed_current = max(0, hspeed_current - _current_friction);
                else if (hspeed_current < 0) hspeed_current = min(0, hspeed_current + _current_friction);
            }
        }
        else
        {
            wall_jump_lock_timer--;
        }

        // --- Détection murs & Gravité ---
        is_touching_wall_left  = place_meeting(x - 1, y, obj_wall);
        is_touching_wall_right = place_meeting(x + 1, y, obj_wall);

        is_wall_sliding = false;
        if (!is_grounded && vspeed_current > 0 && (is_touching_wall_left || is_touching_wall_right) && !is_ground_pounding)
        {
            is_wall_sliding = true;
            vspeed_current = min(vspeed_current, wall_slide_speed_max);
        }

        if (!is_grounded)
        {
            if (is_ground_pounding) vspeed_current = ground_pound_speed;
            else vspeed_current = min(vspeed_current + gravity_force, gravity_max);
        }
        else
        {
            vspeed_current = 0;
        }

        // --- Sauts ---
        if (jump_buffer_current > 0 && is_sliding)
        {
            hspeed_current *= slide_jump_cancel_boost;
            is_sliding = false;
            slide_cooldown_current = slide_cooldown_max;
            vspeed_current = jump_force;
            jump_buffer_current = 0;
            coyote_time_current = 0;
            is_grounded = false;
        }
        else if (jump_buffer_current > 0 && coyote_time_current > 0 && !is_wall_sliding)
        {
            vspeed_current = jump_force;
            jump_buffer_current = 0;
            coyote_time_current = 0;
            is_grounded = false;
        }
        else if (jump_buffer_current > 0 && is_wall_sliding)
        {
            vspeed_current = wall_jump_force_y;
            hspeed_current = is_touching_wall_left ? wall_jump_force_x : -wall_jump_force_x;
            wall_jump_lock_timer = wall_jump_lock_duration;
            jump_buffer_current = 0;
        }

        key_jump = false;
    }

    // --- Plafond absolu & Collisions ---
    hspeed_current = clamp(hspeed_current, -absolute_speed_cap, absolute_speed_cap);

    if (place_meeting(x + hspeed_current, y, obj_wall))
    {
        while (!place_meeting(x + sign(hspeed_current), y, obj_wall)) x += sign(hspeed_current);
        hspeed_current = 0;
    }
    x += hspeed_current;

    var _was_in_air = !is_grounded;
    if (place_meeting(x, y + vspeed_current, obj_wall))
    {
        while (!place_meeting(x, y + sign(vspeed_current), obj_wall)) y += sign(vspeed_current);
        vspeed_current = 0;
    }
    y += vspeed_current;

    is_grounded = place_meeting(x, y + 1, obj_wall);

    // Déclenchement du Super-Slide si on atterrit d'un Ground Pound avec la touche slide
    if (_was_in_air && is_grounded && is_ground_pounding)
    {
        is_ground_pounding = false;
        if (key_slide)
        {
            is_sliding = true;
            slide_duration_current = slide_duration_max;
            hspeed_current = (aim_direction > 270 || aim_direction < 90 ? 1 : -1) * 14.0;
        }
    }

   /// @desc Bloc 3 : Visée vers la souris depuis la main
    var _facing_right = (mouse_x >= x);
    
    // IMPORTANT : On retire le "var" ici pour pouvoir lire "other.hand_x" dans la mêlée
    hand_x = x + (weapon_sprite_offset_x * (_facing_right ? 1 : -1));
    hand_y = y + weapon_sprite_offset_y;

    aim_direction = point_direction(hand_x, hand_y, mouse_x, mouse_y);

    /// @desc Bloc 4 : Ramassage automatique
    if (current_weapon_type == -1)
    {
        var _nearby_weapon = instance_place(x, y, obj_weapon_pickup);
        if (_nearby_weapon != noone && point_distance(x, y, _nearby_weapon.x, _nearby_weapon.y) <= aim_range_pickup && current_time >= _nearby_weapon.pickup_locked_until)
        {
            var _pickup_x = _nearby_weapon.x;
            var _pickup_y = _nearby_weapon.y;

            current_weapon_type = _nearby_weapon.weapon_type;
            current_weapon_config = weapon_get_config(current_weapon_type);

            if (!current_weapon_config.is_melee)
            {
                if (_nearby_weapon.ammo_current != -1) {
                    ammo_current = _nearby_weapon.ammo_current;
                    reserve_ammo_current = _nearby_weapon.reserve_ammo_current;
                } else {
                    ammo_current = current_weapon_config.mag_size;
                    reserve_ammo_current = current_weapon_config.reserve_ammo;
                }
            }

            is_reloading = false;
            reload_timer_current = 0;
            active_reload_boost = false;

            instance_destroy(_nearby_weapon);

            if (global.opponent_steam_id != -1)
            {
                var _buf = buffer_create(9, buffer_fixed, 1);
                buffer_write(_buf, buffer_u8, PKT_WEAPON_PICKUP);
                buffer_write(_buf, buffer_f32, _pickup_x);
                buffer_write(_buf, buffer_f32, _pickup_y);
                steam_net_packet_send(global.opponent_steam_id, _buf, -1);
                buffer_delete(_buf);
            }
        }
    }

    /// @desc Bloc 5 : Combat (Tir, Parade, Rechargement actif)
    if (fire_cooldown_current > 0) fire_cooldown_current--;

    if (current_weapon_type != -1)
    {
        var _cfg = current_weapon_config;
        var _is_melee = _cfg.is_melee;
        var _reload_pressed = keyboard_check_pressed(ord("R"));

        // --- 5a. Rechargement actif ---
        if (!_is_melee)
        {
            if (is_reloading)
            {
                reload_timer_current--;

                var _prog = 1.0 - (reload_timer_current / reload_timer_start);
                if (_reload_pressed && _prog >= 0.40 && _prog <= 0.65)
                {
                    is_reloading = false;
                    reload_timer_current = 0;
                    active_reload_boost = true;

                    var _needed = _cfg.mag_size - ammo_current;
                    var _load = min(_needed, reserve_ammo_current);
                    ammo_current += _load;
                    reserve_ammo_current -= _load;
                }
                else if (reload_timer_current <= 0)
                {
                    is_reloading = false;
                    var _needed = _cfg.mag_size - ammo_current;
                    var _load = min(_needed, reserve_ammo_current);
                    ammo_current += _load;
                    reserve_ammo_current -= _load;
                }
            }
            else if (((_reload_pressed && ammo_current < _cfg.mag_size) || (mouse_check_button(mb_left) && ammo_current <= 0)) && reserve_ammo_current > 0)
            {
                is_reloading = true;
                reload_timer_current = _cfg.reload_time;
                reload_timer_start = _cfg.reload_time;
                active_reload_boost = false;
            }
        }

        // --- 5b. Logique de Tir / Mêlée ---
        var _fire_pressed = mouse_check_button(mb_left);

        if (_fire_pressed && fire_cooldown_current <= 0 && !is_reloading && (_is_melee || ammo_current > 0))
        {
            if (_is_melee)
            {
                var _hit_target = noone;
                with (obj_player)
                {
                    if (!is_local_player && !is_dead)
                    {
                        // CORRECTION : On utilise other.hand_x/y au lieu de other.x/y pour une précision parfaite !
                        var _dist = point_distance(other.hand_x, other.hand_y, x, y);
                        var _ang_diff = abs(angle_difference(point_direction(other.hand_x, other.hand_y, x, y), other.aim_direction));
                        
                        if (_dist <= _cfg.melee_range && _ang_diff <= _cfg.melee_angle * 0.5)
                        {
                            _hit_target = id;
                        }
                    }
                }

                if (_hit_target != noone)
                {
                    _hit_target.hp_current -= _cfg.damage;
                    network_send_hit(_cfg.damage);

                    if (_hit_target.hp_current <= 0)
                    {
                        _hit_target.hp_current = 0;
                        _hit_target.is_dead = true;
                        if (global.is_host) with (obj_round_manager) { player_died(_hit_target, other.id); }
                        else network_send_player_died(global.opponent_steam_id);
                    }
                }

                melee_swing_timer = melee_swing_duration;
                fire_cooldown_current = _cfg.fire_rate;

                if (global.opponent_steam_id != -1)
                {
                    var _buf_melee = buffer_create(13, buffer_fixed, 1);
                    buffer_write(_buf_melee, buffer_u8, PKT_MELEE);
                    buffer_write(_buf_melee, buffer_f32, x);
                    buffer_write(_buf_melee, buffer_f32, y);
                    buffer_write(_buf_melee, buffer_f32, aim_direction);
                    steam_net_packet_send(global.opponent_steam_id, _buf_melee, -1);
                    buffer_delete(_buf_melee);
                }
            }
            else
            {
                ammo_current--;

                var _barrel_dist = _cfg.barrel_length;
                var _barrel_offset_y = -32; // --32 !!!!! A AJUSTER SI BALLE PARTENT PAS AU BON ENDROIT

                var _spawn_x = hand_x + lengthdir_x(_barrel_dist, aim_direction) + lengthdir_x(_barrel_offset_y, aim_direction - 90);
                var _spawn_y = hand_y + lengthdir_y(_barrel_dist, aim_direction) + lengthdir_y(_barrel_offset_y, aim_direction - 90);

                if (variable_struct_exists(_cfg, "pellet_count"))
                {
                    var _spread = _cfg.spread_angle;
                    var _count = _cfg.pellet_count;
                    for (var i = 0; i < _count; i++)
                    {
                        var _angle_offset = random_range(-_spread * 0.5, _spread * 0.5);
                        var _bullet = instance_create_layer(_spawn_x, _spawn_y, "Instances", _cfg.bullet_object);
                        _bullet.damage = _cfg.damage;
                        _bullet.move_speed = _cfg.bullet_speed;
                        _bullet.direction_travel = aim_direction + _angle_offset;
                        _bullet.owner = id;
                    }
                }
                else
                {
                    var _bullet = instance_create_layer(_spawn_x, _spawn_y, "Instances", _cfg.bullet_object);
                    _bullet.damage = _cfg.damage;
                    _bullet.move_speed = _cfg.bullet_speed;
                    _bullet.direction_travel = aim_direction;
                    _bullet.owner = id;

                    if (variable_struct_exists(_cfg, "max_bounces")) _bullet.bounces_max = _cfg.max_bounces;
                }

                fire_cooldown_current = _cfg.fire_rate;

                if (global.opponent_steam_id != -1)
                {
                    var _buf_shoot = buffer_create(16, buffer_fixed, 1);
                    buffer_write(_buf_shoot, buffer_u8, PKT_SHOOT);
                    buffer_write(_buf_shoot, buffer_f32, x);
                    buffer_write(_buf_shoot, buffer_f32, y);
                    buffer_write(_buf_shoot, buffer_f32, aim_direction);
                    buffer_write(_buf_shoot, buffer_s8, current_weapon_type);
                    steam_net_packet_send(global.opponent_steam_id, _buf_shoot);
                    buffer_delete(_buf_shoot);
                }
            }
        }
    }

    /// @desc Bloc 6 : Lancer d'arme chargé (style Worms)
    if (current_weapon_type != -1)
    {
        if (mouse_check_button(mb_right))
        {
            throw_charge = min(throw_charge + 1, throw_charge_max);
        }

        if (mouse_check_button_released(mb_right) && throw_charge > 0)
        {
            var _charge_ratio = throw_charge / throw_charge_max;
            var _speed = lerp(throw_speed_min, throw_speed_max, _charge_ratio);
            if (current_weapon_config.is_melee) _speed *= 1.25;

            var _hx = lengthdir_x(_speed, aim_direction);
            var _vy = lengthdir_y(_speed, aim_direction);

            // CORRECTION : L'arme lancée part de la main et non plus du centre du torse.
            var _thrown = instance_create_layer(hand_x, hand_y, "Instances", obj_weapon_thrown);
            _thrown.weapon_type = current_weapon_type;
            _thrown.hspeed_current = _hx;
            _thrown.vspeed_current = _vy;
            _thrown.sprite_index = current_weapon_config.sprite;
            _thrown.ammo_current = ammo_current;
            _thrown.reserve_ammo_current = reserve_ammo_current;
            _thrown.owner = id;

            if (current_weapon_config.is_melee) _thrown.throw_damage = round(lerp(35, current_weapon_config.damage * 1.25, _charge_ratio));
            else _thrown.throw_damage = round(lerp(15, 35, _charge_ratio));

            if (global.opponent_steam_id != -1)
            {
                var _buf = buffer_create(22, buffer_fixed, 1);
                buffer_write(_buf, buffer_u8, PKT_WEAPON_THROW);
                buffer_write(_buf, buffer_f32, hand_x);
                buffer_write(_buf, buffer_f32, hand_y);
                buffer_write(_buf, buffer_f32, _hx);
                buffer_write(_buf, buffer_f32, _vy);
                buffer_write(_buf, buffer_s8, current_weapon_type);
                buffer_write(_buf, buffer_s16, ammo_current);
                buffer_write(_buf, buffer_s16, reserve_ammo_current);
                steam_net_packet_send(global.opponent_steam_id, _buf, -1);
                buffer_delete(_buf);
            }

            current_weapon_type = -1;
            current_weapon_config = undefined;
            ammo_current = 0;
            reserve_ammo_current = 0;
            throw_charge = 0;
        }
    }
    else
    {
        throw_charge = 0;
    }

    network_send_state();
}
else
{
    net_pos_x += net_vel_x;
    net_pos_y += net_vel_y;
    x = lerp(x, net_pos_x, 0.35);
    y = lerp(y, net_pos_y, 0.35);
}

if (melee_swing_timer > 0) melee_swing_timer--;

// --- Écrasement visuel (Slide & Ground Pound) ---
if (is_sliding) image_yscale = 0.6;
else if (is_ground_pounding) image_yscale = 1.3;
else
{
    if (image_yscale != 1)
    {
        image_yscale = 1;
        var _pushed = 0;
        while (place_meeting(x, y, obj_wall) && _pushed < 4) { y -= 1; _pushed++; }
    }
}