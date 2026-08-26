/// @desc Initialisation des variables du joueur

// --- Variables d'ACTION (alimentées par input local OU réseau) ---
key_left = false;
key_right = false;
key_jump = false;
key_jump_pressed = false;

// --- Physique horizontale ---
hspeed_current = 0;
move_speed_max = 5.5;      // était 4.5 — un peu plus rapide
accel = 0.9;               // était 0.5 — atteint la vitesse max quasi instantanément
accel_air = 0.7;           // était 0.35 — bien plus de contrôle aérien, essentiel pour un arena shooter nerveux
friction_ground = 0.65;    // était 0.4 — s'arrête plus net, moins de glisse résiduelle
friction_air = 0.08;       // inchangé — on garde un peu de glisse en l'air pour le style

// --- Physique verticale ---
vspeed_current = 0;
gravity_force = 0.55;
gravity_max = 12;
jump_force = -10.5;

// --- États ---
is_grounded = false;
is_touching_wall_left = false;
is_touching_wall_right = false;
is_wall_sliding = false;
wall_slide_speed_max = 2.5;

// --- Wall jump ---
wall_jump_force_x = 6;
wall_jump_force_y = -9.5;
wall_jump_lock_timer = 0;
wall_jump_lock_duration = 6;

// --- Slide ---
is_sliding = false;
slide_speed_min = 2.5;        // vitesse minimum requise pour pouvoir déclencher un slide
slide_friction = 0.03;        // quasi nulle : on garde l'élan pendant le slide
slide_duration_max = 30;      // durée max d'un slide (frames) avant qu'il s'arrête tout seul
slide_duration_current = 0;
slide_cooldown_max = 70;      // ~2s à 60fps avant de pouvoir re-slider
slide_cooldown_current = 0;
slide_speed_boost = 1.4;      // multiplicateur de vitesse au moment du déclenchement
slide_jump_cancel_boost = 1.3; // boost supplémentaire si on saute pendant le slide
key_slide = false;

// --- Coyote time & Jump buffer ---
coyote_time_max = 6;
coyote_time_current = 0;
jump_buffer_max = 6;
jump_buffer_current = 0;

// --- Arsenal ---
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

melee_swing_timer = 0;
melee_swing_duration = 10;

// --- Système de jet chargé (style Worms) ---
throw_charge = 0;
throw_charge_max = 40;       // ~0,65 seconde pour charger au maximum
throw_speed_min = 4.0;       // Jet court / lâcher
throw_speed_max = 16.0;      // Jet puissant tendu

// --- Santé & état de round ---
hp_max = 100;
hp_current = hp_max;
is_dead = false;
is_round_active = true;

// --- Prédiction réseau (pour le joueur distant uniquement) ---
net_pos_x = x;
net_pos_y = y;
net_vel_x = 0;
net_vel_y = 0;

// --- Identité du joueur (valeur par défaut, peut être écrasée par le Creation Code de l'instance) ---
player_index = 1;

// --- Garde-fou : s'assure que les globals réseau existent avant de les lire ---
if (!variable_global_exists("is_host")) { global.is_host = true; }
if (!variable_global_exists("local_steam_id")) { global.local_steam_id = steam_get_user_steam_id(); }
if (!variable_global_exists("opponent_steam_id")) { global.opponent_steam_id = -1; }

// --- Réseau : détermine si CETTE instance est notre joueur local ou l'adversaire ---
is_local_player = (player_index == 1) ? global.is_host : !global.is_host;
steam_owner_id = is_local_player ? global.local_steam_id : global.opponent_steam_id;