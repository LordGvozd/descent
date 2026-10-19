shader_type canvas_item;
// Pixelate-to-solid cover. As progress rises the screen blocks grow and the
// color fades in, ending fully covered. It samples the screen texture so the
// dissolve reads as the scene itself breaking into blocks.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

void fragment() {
	// block size grows with progress (min 1px-ish up to chunky)
	float blocks = mix(220.0, 6.0, progress);
	vec2 grid = floor(UV * blocks) / blocks + (0.5 / blocks);
	vec3 scene = texture(screen_tex, grid).rgb;
	// crossfade from the pixelated scene toward the solid cover color
	vec3 rgb = mix(scene, COLOR.rgb, progress);
	// alpha rises so that at progress=1 it's a full solid cover
	float a = smoothstep(0.0, 1.0, progress);
	COLOR = vec4(rgb, a);
}
