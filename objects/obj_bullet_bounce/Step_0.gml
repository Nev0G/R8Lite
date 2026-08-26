/// @desc Déplacement avec gestion du rebond sur les murs

var _next_x = x + lengthdir_x(move_speed, direction_travel);
var _next_y = y + lengthdir_y(move_speed, direction_travel);

// --- Rebond horizontal ---
if (place_meeting(_next_x, y, obj_wall))
{
    if (bounces_current >= bounces_max)
    {
        instance_destroy();
        exit; // sort du step immédiatement
    }
    direction_travel = 180 - direction_travel; // inverse la composante horizontale
    bounces_current++;
}

// --- Rebond vertical ---
if (place_meeting(x, _next_y, obj_wall))
{
    if (bounces_current >= bounces_max)
    {
        instance_destroy();
        exit;
    }
    direction_travel = -direction_travel; // inverse la composante verticale
    bounces_current++;
}

x += lengthdir_x(move_speed, direction_travel);
y += lengthdir_y(move_speed, direction_travel);

lifetime_current++;
if (lifetime_current >= lifetime_max)
{
    instance_destroy();
}

// --- Collision avec un joueur (sauf le tireur) ---
var _hit_player = instance_place(x, y, obj_player);
if (_hit_player != noone && _hit_player != owner)
{
    // _hit_player.hp -= damage; (Phase 3)
    instance_destroy();
}