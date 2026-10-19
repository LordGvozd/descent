shader_type canvas_item;

uniform float glow_radius : hint_range(0.0, 16.0) = 1.0;   // Радиус ореола
uniform float glow_intensity : hint_range(0.0, 5.0) = .3;  // Яркость свечения
uniform int samples : hint_range(4, 32) = 16;                // Кол-во сэмплов по кругу

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    
    // Собираем альфу и цвет соседних непрозрачных пикселей
    float glow_alpha = 0.0;
    vec3 glow_rgb = vec3(0.0);
    float sample_count = 0.0;
    
    float r_x = glow_radius * TEXTURE_PIXEL_SIZE.x;
    float r_y = glow_radius * TEXTURE_PIXEL_SIZE.y;
    
    for (int i = 0; i < samples; i++) {
        float angle = float(i) / float(samples) * 6.2831853;
        vec2 offset = vec2(cos(angle) * r_x, sin(angle) * r_y);
        vec4 s = texture(TEXTURE, UV + offset);
        
        if (s.a > 0.1) {
            glow_rgb += s.rgb;
            glow_alpha += s.a;
            sample_count += 1.0;
        }
    }
    
    // Усредняем цвет и альфу ореола
    if (sample_count > 0.0) {
        glow_rgb /= sample_count;
        glow_alpha /= sample_count;
    } else {
        // Если рядом нет текста — ореола нет
        glow_rgb = base.rgb;
        glow_alpha = 0.0;
    }
    
    // Формируем свечение
    vec4 glow = vec4(glow_rgb * glow_intensity, glow_alpha * glow_intensity);
    
    // Смешиваем: свечение снизу, буквы сверху
    COLOR = mix(glow, base, base.a);
    COLOR.a = max(glow.a, base.a);
}