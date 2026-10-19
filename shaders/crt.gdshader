shader_type canvas_item;

// Настройки эффекта (можно менять в инспекторе)
uniform float curvature : hint_range(0.0, 10.0) = 4.0; // Сила "пузатости"
uniform float scanline_count : hint_range(0.0, 1000.0) = 300.0; // Частота линий
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.15; // Заметность линий

// Читаем то, что уже нарисовано на экране
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    // 1. Искривление экрана (Barrel Distortion)
    vec2 uv = UV * 2.0 - 1.0;
    uv *= 1.0 + pow(length(uv), 2.0) * curvature * 0.01;
    uv = (uv + 1.0) * 0.5;

    // Если UV выходит за пределы экрана — рисуем чёрный (рамка телевизора)
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // 2. Берём пиксель с экрана по искажённым координатам
        vec4 tex = texture(screen_texture, uv);
        
        // 3. Скан-линии (Scanlines)
        float scanline = sin(uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
        tex.rgb -= scanline * scanline_opacity;
        
        COLOR = tex;
    }
}