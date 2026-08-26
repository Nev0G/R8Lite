/// @desc Initialisation complète du joueur

weapon_sprite_offset_x = 4;   // Léger décalage horizontal vers l'avant
weapon_sprite_offset_y = -34; // Remonte de 34 pixels depuis les pieds jusqu'au torse

// --- Inputs ---
key_left = false;
key_right = false;
key_down = false;
key_jump = false;
key_jump_pressed = false;
key_slide = false;
key_dash = false;

// --- Physique & Déplacements standards ---
hspeed_current = 0;
vspeed_current = 0;
move_speed_max = 5.5;
accel = 0.9;
accel_air = 0.7;
friction_ground = 0.65;
friction_air = 0.08;
gravity_force = 0.55;
gravity_max = 12;
jump_force = -10.5;
absolute_speed_cap = 20;

// --- États au sol & aux murs ---
is_grounded = false;
is_touching_wall_left = false;
is_touching_wall_right = false;
is_wall_sliding = false;
wall_slide_speed_max = 2.5;
wall_jump_force_x = 6;
wall_jump_force_y = -9.5;
wall_jump_lock_timer = 0;
wall_jump_lock_duration = 6;

// --- Coyote Time & Jump Buffer ---
coyote_time_max = 6;
coyote_time_current = 0;
jump_buffer_max = 6;
jump_buffer_current = 0;

// --- Glissade (Slide) ---
is_sliding = false;
slide_speed_min = 2.5;
slide_friction = 0.03;
slide_duration_max = 30;
slide_duration_current = 0;
slide_cooldown_max = 70;
slide_cooldown_current = 0;
slide_speed_boost = 1.4;
slide_jump_cancel_boost = 1.3;

// --- NOUVEAU : Dash multidirectionnel ---
dash_timer = 0;
dash_duration = 8;
dash_speed = 13.5;
dash_cooldown = 0;
dash_cooldown_max = 60; // 1 seconde de recharge
dash_dir_x = 0;
dash_dir_y = 0;

// --- NOUVEAU : Ground Pound (Pilonnage au sol) ---
is_ground_pounding = false;
ground_pound_speed = 15.0;

// --- Arsenal & Combat ---
current_weapon_type = -1;
current_weapon_config = undefined;
weapon_sprite_offset_x = 8;
weapon_sprite_offset_y = -4;
aim_direction = 0;
aim_range_pickup = 24;
fire_cooldown_current = 0;

ammo_current = 0;
reserve_ammo_current = 0;
is_reloading = false;
reload_timer_current = 0;
reload_timer_start = 0;
active_reload_boost = false; // Bonus de dégâts après un rechargement parfait

melee_swing_timer = 0;
melee_swing_duration = 10;

// --- Jet d'arme chargé ---
throw_charge = 0;
throw_charge_max = 40;
throw_speed_min = 4.0;
throw_speed_max = 16.0;

// --- Santé & Round ---
hp_max = 100;
hp_current = hp_max;
is_dead = false;
is_round_active = true;

// --- Prédiction réseau ---
net_pos_x = x;
net_pos_y = y;
net_vel_x = 0;
net_vel_y = 0;
player_index = 1;

if (!variable_global_exists("is_host")) global.is_host = true;
if (!variable_global_exists("local_steam_id")) global.local_steam_id = steam_get_user_steam_id();
if (!variable_global_exists("opponent_steam_id")) global.opponent_steam_id = -1;

is_local_player = (player_index == 1) ? global.is_host : !global.is_host;
steam_owner_id = is_local_player ? global.local_steam_id : global.opponent_steam_id;

// --- Game Feel : Flash & Hitmarker ---
flash_timer = 0;
hitmarker_timer = 0;
hitmarker_is_crit = false;
hp_lag = hp_current; // Barre intermédiaire pour le HUD