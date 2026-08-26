weapon_type = WeaponType.BOUNCER; 

// --- NOUVEAU : Sauvegarde des munitions ---
ammo_current = -1;         // -1 signifie "arme neuve"
reserve_ammo_current = -1;

pickup_locked_until = 0; // frame de fin de verrou (anti race-condition)