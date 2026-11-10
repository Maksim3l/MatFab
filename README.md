# Matfab

Matfab is a factory-building math game for phones and tablets, in the style of Shapez, where numbers take the place of shapes. Miners pull numbers out of ore patches, conveyors carry them across the map, and math blocks combine them until the mothership receives the numbers each level asks for. Player-facing text is in Slovenian.

## Gameplay

- Each level places the mothership at the centre of the map, scatters ore patches with numbers on them, and sets a list of goals: a number and how many of it the mothership must receive.
- The mothership asks for one goal at a time, in order. Every number it receives is kept, so numbers delivered early count as soon as their goal comes up.
- Blocks: miner (Rudar), conveyor, sum, subtract, multiply, divide, square and cube. Each level lists the blocks it allows.
- Levels are grouped by school grade ("1. razred", ...). The tutorial level "Kako se igra" sits under "Navodila" before the first grade.
- Building supports drag placement, straight lines, rotate and flip, select, copy, cut, paste, eraser, and undo/redo.
- Progress and the factory of every level are saved automatically every 30 seconds, on level complete, on leaving to the menu, and when the app goes to the background.

## Requirements

- Godot 4.4 or newer (the project is edited in 4.7), GL Compatibility renderer
- Android export templates, for building the APK

## Running

Open `project.godot` in Godot and press Play. The main scene is `ui/main_menu.tscn`. Mouse input is emulated as touch, so the game plays in the editor as it does on a device.

`debug/debug_play.tscn` starts one level directly (`LEVEL_ID` in `debug/debug_play.gd`, `r1_01` by default), without going through the menus.

## Tests

The tests use [GUT](https://github.com/bitwes/Gut) and live in `tests/`, mirroring the source folders. Run them headless with:

```bash
godot --headless -s addons/gut/gut_cmdln.gd
```

`.gutconfig.json` points GUT at `res://tests` and exits when the run finishes. In the editor, the GUT bottom panel runs the same suite.

## Building for Android

`export_presets.cfg` holds an Android preset. With the export templates installed, use Project > Export > Android, or:

```bash
godot --headless --export-release "Android" build/matfab.apk
```

## Project layout

```
data/      Resources: block defs, levels, settings, control buttons, and their schemas
sim/       Simulation: buildings, ports, conveyors, processors, goal tracking; holds no nodes
view/      World drawing, touch gestures, camera, build tool, undo history, blueprints
ui/        Menus, level select, HUD, action bar, tutorial panel
game/      Autoloads (Registry, Settings, Game), save store, tutorial, autosave
debug/     Scene for starting a level directly
tests/     GUT tests and fixtures
assets/    Sprites (real/) and placeholder icons (placeholder/)
addons/    GUT
docs/      Design document and work plan
```

`view` and `ui` read `sim`, `sim` reads `data/schema`, and `game` builds a simulation from a level and hands it to the view.

## Adding content

`Registry` loads every `.tres` under `data/blocks`, `data/levels`, `data/settings` and `data/controls` at startup and uses the file name as its id.

- **Level:** add a `LevelDef` resource to `data/levels/`. The file name prefix (`r1_01`, `r6_02`, ...) sets the order in level select.
- **Math block:** add a `BuildingDef` resource to `data/blocks/` and its operation to `data/blocks/operations.gd`. At startup `Registry` checks that the operation exists and takes as many arguments as the block has inputs.

Saves store these ids, so renaming a level or block file drops its saved progress or buildings.

See [docs/design.md](docs/design.md) for the full design.
