shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
    vec4 color = textureLod(screen_texture, SCREEN_UV, blur_amount);
    // Macht es zusätzlich ein bisschen dunkler
    COLOR = vec4(color.rgb * 0.8, 1.0); 
}