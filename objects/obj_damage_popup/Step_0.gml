/// @desc Animation et disparition
x += hspd;
y += vspd;

vspd = lerp(vspd, -0.4, 0.1);
hspd = lerp(hspd, 0, 0.08);

scale = lerp(scale, scale_target, 0.15);
alpha -= 0.025;

if (alpha <= 0)
{
    instance_destroy();
}