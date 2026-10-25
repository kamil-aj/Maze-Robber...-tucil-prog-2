# Maze Robber

Top-down stealth game made in Godot 4.3. Take every coin, then get to the exit without being caught. Five levels.

Controls: WASD or arrows to move, Shift to sneak, Esc or P to pause, F5 to save, F9 to load.

To run it, open Godot 4.3+, import `project.godot` and press F5.

## Files

- `levels.gd` – maps and per-level settings
- `game_world.gd` – level building, raycast, pathfinding, game state
- `entity.gd`, `player.gd`, `guard.gd`, `hunter.gd` – characters
- `coin.gd` – pickup and its animation
- `hud.gd`, `game_theme.gd` – menus and HUD
- `save_manager.gd` – save/load (JSON in `user://`)
- `palette.gd`, `pixel_art.gd` – colours and built-in sprites

## Modular concepts

1. Raycasting – `GameWorld.has_line_of_sight()`, used by `Guard`
2. Pathfinding – `AStarGrid2D` in `GameWorld`, used for patrol, chase and search
3. Save & Load – `SaveManager`
4. UI/UX – menus, HUD, pause, toasts
5. Animation – tweens on coins, player blink, toasts

## OOP

`Player` and `Guard` extend `Entity`, and `Hunter` extends `Guard`. `Hunter` overrides `_chase_target()` and `get_label()`. Other custom classes: `GameWorld`, `Coin`, `HUD`, `Levels`, `SaveManager`, `Palette`, `PixelArt`, `GameTheme`.
