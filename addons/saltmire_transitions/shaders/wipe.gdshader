shader_type canvas_item;
// Directional wipe with a soft edge. progress 0 = clear, 1 = fully covered.
// `direction` points toward where the cover travels (e.g. (1,0) covers to the right).

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float feather : hint_range(0.0, 0.5) = 0.05;
uniform vec2 direction = vec2(1.0, 0.0);

void fragment() {
	// project UV onto the direction axis -> t in [0,1]
	vec2 d = normalize(direction);
	// remap so t=0 is the trailing edge, t=1 the leading edge
	float t = dot(UV - vec2(0.5), d) + 0.5;
	// threshold sweeps from 0..1 as progress rises
	float edge = progress * (1.0 + feather);
	float a = smoothstep(edge, edge - feather, t);
	COLOR = vec4(COLOR.rgb, a);
}
