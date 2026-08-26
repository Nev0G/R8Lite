function scr_juice(){

}/// @desc Déclenche une secousse d'écran
function trigger_screenshake(_intensity, _duration)
{
    if (instance_exists(obj_camera))
    {
        obj_camera.shake_intensity = max(obj_camera.shake_intensity, _intensity);
        obj_camera.shake_duration = max(obj_camera.shake_duration, _duration);
    }
}

/// @desc Crée un chiffre flottant de dégâts
function spawn_damage_popup(_x, _y, _amount, _is_crit)
{
    var _pop = instance_create_layer(_x, _y - 10, "Instances", obj_damage_popup);
    _pop.damage_text = _amount;
    _pop.is_crit = _is_crit;
    _pop.scale = _is_crit ? 1.6 : 1.1;
    _pop.scale_target = _is_crit ? 1.3 : 1.0;
}