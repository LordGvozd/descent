shader_type canvas_item;
// Circle iris wipe. progress 0 = fully open (transparent), 1 = fully closed (covered).
// Covers from the edges inward to the center.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float feather : hint_range(0.0, 0.5) = 0.02;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	// aspect-correct so the circle stays round
	uv.x *= 1.0; // color_rect UV is 0..1; keep simple, radius in UV space
	float dist = length(UV - vec2(0.5)) / 0.7071; // normalized 0..1 to corner
	// radius shrinks as progress rises; at progress=1 radius=0 => everything covered
	float radius = 1.0 - progress;
	float a = smoothstep(radius, radius - feather, dist);
	// when covering, outside the circle is opaque. At progress=1, a=1 everywhere.
	COLOR = vec4(COLOR.rgb, a);
}
