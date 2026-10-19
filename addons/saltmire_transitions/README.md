# Saltmire Transitions

![Godot 4.6+](https://img.shields.io/badge/Godot-4.6%2B-478cbf?logo=godotengine&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A tiny, free **scene-transition manager** for Godot 4. Change scenes with a
polished transition in one line — fade, iris circle, directional wipes, and a
pixelate dissolve, all built in. Drop-in autoload, no setup.

Part of the **Saltmire** game-feel family (see also
[Saltmire Juice](https://saltmire.itch.io/saltmire-juice)).

```gdscript
# Change scene with a transition:
Transition.to("res://levels/level_2.tscn", "circle")

# Or hide/show the screen yourself while you do work:
await Transition.cover("pixelate")
load_the_next_area()
await Transition.reveal("pixelate")
```

## Install

1. Copy `addons/saltmire_transitions/` into your project's `addons/` folder.
2. Enable **Saltmire Transitions** in `Project > Project Settings > Plugins`.
3. That's it — the `Transition` autoload is registered automatically.

## Built-in styles

`fade` · `circle` · `wipe_left` · `wipe_right` · `wipe_up` · `wipe_down` · `pixelate`

## API

| Call | What it does |
|------|--------------|
| `Transition.to(path, style, dur, color)` | Cover → change scene → reveal. Awaitable. |
| `Transition.cover(style, dur, color)` | Hide the screen. Awaitable. |
| `Transition.reveal(style, dur, color)` | Show the screen again. Awaitable. |
| `Transition.is_busy()` | `true` while a transition is running. |
| `Transition.add_style(name, opts)` | Register your own shader-backed style. |

All arguments after the first are optional. `dur` defaults to `Transition.duration`
(0.4s), `color` to `Transition.color` (black). Signals: `covered`, `revealed`,
`scene_changed(path)`.

### Custom styles

```gdscript
Transition.add_style("my_wipe", {"shader": "res://my_wipe.gdshader", "flip": true})
```
Your shader just needs a `uniform float progress` going `0.0 → 1.0` (covered).

## AI honesty

This addon was built with AI assistance and reviewed/tested by a human in Godot
4.6. Code is MIT — read it, fork it, ship it.

## License

MIT © 2026 Saltmire. See [LICENSE.txt](LICENSE.txt).
