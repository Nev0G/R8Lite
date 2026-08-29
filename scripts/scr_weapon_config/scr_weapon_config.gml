/// @desc Définition des types d'armes et de leurs statistiques

enum WeaponType {
    PISTOL,
    SHOTGUN,
    BOUNCER,
    MELEE_KNIFE
}

function weapon_get_config(_type)
{
    switch (_type)
    {
        case WeaponType.PISTOL:
            return {
                name: "Pistol",
                damage: 34,
                headshot_mult: 2.0,
                fire_rate: 25,
                bullet_speed: 18,
                bullet_object: obj_bullet_straight,
                is_melee: false,
                max_bounces: 0,
                sprite: spr_weapon_pistol,
                mag_size: 12,
                reload_time: 60,
                reserve_ammo: 24,
                barrel_length: 34,
                throw_gravity: 0.45,
                recoil_force: 2.0
            };

        case WeaponType.SHOTGUN:
            return {
                name: "Shotgun",
                damage: 16,
                headshot_mult: 1.5,
                fire_rate: 45,
                bullet_speed: 15,
                bullet_object: obj_bullet_straight,
                pellet_count: 6,
                spread_angle: 22,
                is_melee: false,
                max_bounces: 0,
                sprite: spr_weapon_shotgun,
                mag_size: 2,
                reload_time: 90,
                reserve_ammo: 8,
                barrel_length: 35,
                throw_gravity: 0.50,
                recoil_force: 7.5 // Recoil Jump puissant !
            };

        case WeaponType.BOUNCER:
            return {
                name: "Bouncer",
                damage: 25,
                headshot_mult: 1.8,
                fire_rate: 30,
                bullet_speed: 13,
                bullet_object: obj_bullet_bounce,
                is_melee: false,
                max_bounces: 3,
                sprite: spr_weapon_bouncer,
                mag_size: 6,
                reload_time: 75,
                reserve_ammo: 18,
                barrel_length: 25,
                throw_gravity: 0.40,
                recoil_force: 3.5
            };

        case WeaponType.MELEE_KNIFE:
            return {
                name: "Knife",
                damage: 60,
                headshot_mult: 1.0,
                fire_rate: 15,
                bullet_speed: 0,
                bullet_object: noone,
                is_melee: true,
                melee_range: 56,
                melee_angle: 100,
                sprite: spr_weapon_knife,
                barrel_length: 0,
                throw_gravity: 0.12, // Trajectoire tendue et droite
                recoil_force: 0.0
            };
    }

    return undefined;
}