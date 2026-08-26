/// @desc Définition des types d'armes et de leurs statistiques

enum WeaponType {
    PISTOL,
    SHOTGUN,
    RIFLE,
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
                fire_rate: 20,
                bullet_speed: 16,
                bullet_object: obj_bullet_straight,
                is_melee: false,
                max_bounces: 0,
                sprite: spr_weapon_pistol,
                mag_size: 12,
                reload_time: 60,
                reserve_ammo: 24,
                barrel_length: 20,
                throw_gravity: 0.45 // Gravité normale (effet cloche classique)
            };

        case WeaponType.SHOTGUN:
            return {
                name: "Shotgun",
                damage: 18,
                fire_rate: 45,
                bullet_speed: 14,
                bullet_object: obj_bullet_straight,
                pellet_count: 6,
                spread_angle: 20,
                is_melee: false,
                max_bounces: 0,
                sprite: spr_weapon_shotgun,
                mag_size: 2,
                reload_time: 90,
                reserve_ammo: 8,
                barrel_length: 35 // Longueur du canon du shotgun
            };

        case WeaponType.BOUNCER:
            return {
                name: "Bouncer",
                damage: 25,
                fire_rate: 30,
                bullet_speed: 12,
                bullet_object: obj_bullet_bounce,
                is_melee: false,
                max_bounces: 3,
                sprite: spr_weapon_bouncer,
                mag_size: 6,
                reload_time: 75,
                reserve_ammo: 18,
                barrel_length: 25
            };
	

		        case WeaponType.MELEE_KNIFE:
            return {
                name: "Knife",
                damage: 60,
                fire_rate: 15,
                bullet_speed: 0,
                bullet_object: noone,
                is_melee: true,
                melee_range: 56,
                melee_angle: 100,
                sprite: spr_weapon_knife,
                barrel_length: 0,
                throw_gravity: 0.12 // Très faible gravité : vol tendu et droit !
            };
    }

    return undefined;
}