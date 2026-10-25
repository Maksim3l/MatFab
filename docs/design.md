# Matfab design

Shapez-style factory game for phones and tablets: numbers replace shapes, and the factory feeds a mothership that counts them. Godot 4.4+ with GDScript. Player-facing text is Slovenian and lives in data fields and scenes.

## Folders and layers

```
matfab/
  data/
    schema/     building_def.gd, port_def.gd, level_def.gd, ore_patch.gd, setting_def.gd, action_button_def.gd
    blocks/     mothership.tres, conveyor.tres, miner.tres, sum.tres, operations.gd
    levels/     r1_01.tres, ...
    settings/   01_master_volume.tres, ..., setting_actions.gd
    controls/   01_rotate.tres, ...
  sim/          simulation.gd, building_state.gd, goal_tracker.gd, ports.gd, sim_clock.gd
    behaviors/  processor.gd, conveyor.gd, mothership.gd
  view/         world_view, ground_view, building_view, item_view, build_tool, touch_gestures,
                camera_rig, edit_history.gd, blueprint.gd
  ui/           main_menu, level_select, settings_menu, hud, action_bar, pause_menu, level_complete
  game/         registry.gd, game.gd, settings.gd, save_store.gd
  debug/        debug_play.tscn
  tests/        mirrors the source folders; fixtures/ holds test data
  addons/gut/
  assets/placeholder/
```

- `view` and `ui` read `sim`, `sim` reads `data/schema`, and `game` builds a sim from a `LevelDef` and passes it to the view. `sim` holds no nodes. Scripts sit beside their scenes.
- Autoloads, in this order: `Registry`, `Settings`, `Game`. `save_store.gd` is a plain class owned by `Game`.
- `Registry` loads every `.tres` under `data/blocks`, `data/levels`, `data/settings` and `data/controls` with `ResourceLoader.list_directory`, which returns source names in exported builds too, and sets `id` from the file name. Saves store these ids. Lists shown in order (levels, setting rows, action buttons) sort by file name, so those files carry a number prefix.
- Godot 4.4+ for typed dictionaries and `list_directory`.

## Levels and the mothership

A level is one `.tres` in `data/levels/`. `goals` maps each number to the amount the mothership must receive, one entry per number, and `ore_patches` lists the numbers that exist on the map and where.

```gdscript
class_name LevelDef extends Resource

@export var title := ""
@export var grade := 1
@export var map_size := Vector2i(40, 30)
@export var ore_patches: Array[OrePatch] = []
@export var goals: Dictionary[int, int] = {}
@export var buildable: Array[BuildingDef] = []

# Progress and world saves store this id; renaming the .tres loses that level's progress and save.
var id: StringName
```

```gdscript
class_name OrePatch extends Resource

@export var value := 1
@export var cell := Vector2i.ZERO
@export var size := Vector2i(3, 3)
```

`Simulation.from_level(level)` places `mothership.tres` at cell (0, 0), fills the ore map from `ore_patches`, sets the map bounds from `map_size` centered on (0, 0), and creates a `GoalTracker`. Every cell in level data is relative to the mothership. The mothership accepts every number on every edge and calls `receive`, which ignores numbers outside `goals`:

```gdscript
class_name GoalTracker extends RefCounted

signal counted(number: int, count: int)
signal completed

var goals: Dictionary[int, int]
var received: Dictionary[int, int] = {}

func _init(level_goals: Dictionary[int, int]) -> void:
	goals = level_goals

func receive(number: int) -> void:
	if not goals.has(number) or is_complete():
		return
	received[number] = received.get(number, 0) + 1
	counted.emit(number, received[number])
	if is_complete():
		completed.emit()

func is_complete() -> bool:
	for number in goals:
		if received.get(number, 0) < goals[number]:
			return false
	return true
```

The HUD lists the goals in data order as the number and `received / amount`. Level select lists levels under their `grade` ("1. razred"), sorted by file name.

`data/levels/r1_01.tres`:

```
title        "Prvi koraki"
grade        1
ore_patches  value 1 at (-8, -2) 3x3, value 2 at (6, 3) 3x3
goals        {2: 10, 3: 10, 4: 10, 5: 10, 6: 10}
buildable    conveyor, miner, sum
```

## Blocks

A block is a `.tres` in `data/blocks/`, and a math block adds one function to `data/blocks/operations.gd`.

```gdscript
class_name PortDef extends Resource

# Clockwise: rotation adds to this value, so reordering breaks every rotated port.
enum Side { UP, RIGHT, DOWN, LEFT }
enum Source { NEIGHBOR, ORE }

@export var cell := Vector2i.ZERO
@export var side := Side.DOWN
@export var source := Source.NEIGHBOR
```

```gdscript
class_name BuildingDef extends Resource

enum Behavior { PROCESSOR, CONVEYOR, MOTHERSHIP }

@export var display_name := ""
@export var symbol := ""
@export var sprite: Texture2D
@export_range(0, 3) var sprite_turns := 0
@export var behavior := Behavior.PROCESSOR
@export var size := Vector2i.ONE
@export var inputs: Array[PortDef] = []
@export var outputs: Array[PortDef] = []
@export var operation: StringName
@export var duration := 0.5
@export var keep_selected := false

# World saves store this id; renaming the .tres drops saved buildings of this type.
var id: StringName
```

Ports describe rotation 0 with the front facing UP, and the sim rotates them with the building. `cell` is a cell inside `size`, `side` is the edge a number crosses, and an ORE port reads the ore value under `cell` instead of a neighbor. Math blocks and the miner are PROCESSOR; CONVEYOR and MOTHERSHIP ignore the port lists because their sim rules fix their sides.

Input ports map to function arguments in order. A function for one output returns an `int`; for several it returns an `Array[int]` in output port order. The processor calls it with `callv` and wraps a lone `int` into an array.

```gdscript
class_name Operations extends RefCounted

func mine(ore: int) -> int:
	return ore

func sum(a: int, b: int) -> int:
	return a + b
```

`sum.tres`:

```
display_name  "Seštevalnik"
symbol        "+"
size          (2, 1)
inputs        (0, 0) DOWN, (1, 0) DOWN
outputs       (0, 0) UP
operation     &"sum"
duration      0.5
```

The other core defs:
- `miner.tres` ("Rudar"): PROCESSOR, 1x1, one input at (0, 0) with `source = ORE`, one output UP, `operation = &"mine"`, `duration = 1.0`
- `conveyor.tres` ("Tekoči trak"): CONVEYOR, 1x1, `duration = 0.25`, `keep_selected = true`
- `mothership.tres` ("Matična ladja"): MOTHERSHIP, 4x4

Adding a block:
1. Write the function in `operations.gd`.
2. Create `data/blocks/<id>.tres` from `BuildingDef`.
3. Add it to `buildable` in each level that offers it.

`Registry` loads the file at startup, the toolbar lists it from the level, the view draws it from `symbol` until it has a `sprite`, and world saves store it by id. At startup `Registry` also checks every PROCESSOR def: `has_method(operation)` on an `Operations` instance, and `get_method_argument_count(operation)` against the input port count. A mismatch goes to `push_error` with the `.tres` path.

## Simulation

The sim uses `RefCounted` objects and no nodes.

- `cells: Dictionary[Vector2i, BuildingState]` maps every cell a building covers to that building; `ore: Dictionary[Vector2i, int]` comes from `ore_patches`.
- `BuildingState` holds `def`, `origin`, `rotation`, `inputs`, `outputs` and `timer`. `inputs` and `outputs` hold one slot per port, each an int or null. Every behavior keeps its state in these six fields, so saving needs no per-behavior code.
- Each script in `sim/behaviors/` implements `tick(building)` and `accept(building, cell, side, number) -> bool`. `Simulation.offer(cell, side, number)` finds the building across `side` and calls its `accept` with the side the number enters from; every transfer goes through it.
- `step()` ticks every building once. `SimClock` turns frame time into whole steps at a fixed 20 per second and exposes the fraction toward the next step for interpolation. `duration` converts from seconds to ticks on placement.

Rules:
- PROCESSOR: while every input slot is full and every output slot is empty, its timer runs. At `duration` it calls the operation, writes the result into the output slots and empties its NEIGHBOR inputs. Every tick it offers each full output slot through its port. An ORE slot always holds the ore value under it, which makes a miner produce a number every `duration` while its output is free.
- CONVEYOR: one slot. It accepts a number from any side except its front when the slot is empty, holds it for `duration`, then offers it to the front.
- MOTHERSHIP: accepts every number on every edge and calls `tracker.receive(number)`.

Commands:
- `place(def_id, origin, rotation) -> bool` fails outside the map, on overlap, or with an ORE port off ore. A conveyor placed on a conveyor replaces it and keeps its number.
- `remove(cell) -> bool` removes the building covering the cell and leaves the mothership in place.

## View

The view reads sim state every frame. Conveyor numbers interpolate between ticks from `timer` and the clock fraction, and the view draws a conveyor fed from its side as a corner. A building with `sprite` draws it fitted to its footprint and turned by `rotation + sprite_turns`, with port marks on top; conveyors draw the straight or turn belt art from `assets/real/`, and the ground tiles `background.png`. Placeholders: a building without `sprite` is a rect with `symbol`, a number is a circle with its value, an ore cell is a tinted cell with its value. Ghosts show the tool with port arrows, red where `place` would fail.

## Touch input

`view/touch_gestures.gd` reads `InputEventScreenTouch` and `InputEventScreenDrag` and calls build tool and camera functions. The tool is what a tap places: a def with a rotation, or a blueprint.

| Input | Effect |
|---|---|
| Tap, building tool | The ghost shows under the finger while it is down; release places it. A tap on a building of the same def rotates that building instead |
| Drag, building tool | Ghosts along the cells the finger enters, red where `place` fails; release commits them with the drag rules below |
| Drag, blueprint | The ghost follows the finger; release places it when every part fits |
| Tap or drag, eraser | Buildings under the path turn red; release removes them |
| Drag, selector | Selects a rectangle |
| Long press, 0.5 s with the finger still | On a building, its def and rotation become the tool; on bare ore, the first buildable def with an ORE port. The release after a long press places nothing |
| One finger, no tool | Pans |
| Two fingers | Pan and pinch-zoom; the second finger cancels the first finger's pending ghosts |
| Tap the active toolbar slot | Drops the tool |
| Android back | `Game.go_back()`: drops the tool or selection; with neither, opens the pause menu; on the main menu, quits |

Placement commits on release instead of while the finger moves, because the first finger of a pinch starts as a drag.

## Placement rules

**Drags**

- A conveyor drag places a conveyor in every cell the finger enters, each facing the next cell, so a turn in the drag makes a corner. With `conveyors_flipped` on, each faces the previous cell.
- A conveyor placed on a conveyor replaces it and keeps its number, so redrawing a line re-routes it.
- Any other def places one copy per `size` step along the drag and skips cells where `place` fails, so a miner dragged across an ore patch fills that row.
- With `straight_line` on, a drag stays on the axis of its first step.

**Keep placing**

After a tap or drag, the tool drops unless `keep_placing` is on or its def has `keep_selected`; a blueprint drops the same way. Held Shift counts as `keep_placing` on a keyboard.

**Undo**

A gesture (tap, drag, paste, delete) is one undo step. `view/edit_history.gd` records each gesture as the buildings it added and removed, each as `[def_id, origin, rotation]`. Undo applies the inverse through `place` and `remove`; redo applies the gesture again.

**Blueprints**

`view/blueprint.gd` stores the selected buildings as def id, offset from the selection's top-left cell, and rotation. As the tool it rotates as a whole on Rotate, draws parts that do not fit in red, and places when every part fits.

## Action bar

Each on-screen button is a `.tres` in `data/controls/`:

```gdscript
class_name ActionButtonDef extends Resource

enum Context { ALWAYS, BUILDING_TOOL, CONVEYOR_TOOL, BLUEPRINT_TOOL, SELECTION, CLIPBOARD }

@export var label := ""
@export var icon: Texture2D
@export var shown_with: Array[Context] = [Context.ALWAYS]
@export var command: StringName
@export var toggles_property: StringName

var id: StringName
```

With `toggles_property` set, the button toggles that bool on `build_tool`; otherwise it calls `command`. The bar builds one button per def in file-name order and shows it while one of its contexts is active. `build_tool` emits `state_changed` after every command, and the bar refreshes visibility and toggle states from it.

| File | Label | Shown with | Command or property |
|---|---|---|---|
| `01_rotate` | Zasukaj | building tool, blueprint | `rotate_cw()` |
| `02_keep_placing` | Gradi naprej | building tool | `keep_placing` |
| `03_straight_line` | Ravna črta | building tool | `straight_line` |
| `04_flip` | Obrni smer | conveyor tool | `conveyors_flipped` |
| `05_eraser` | Radirka | always | `use_eraser()` |
| `06_select` | Izberi | always | `use_selector()` |
| `07_delete` | Izbriši | selection | `delete_selection()` |
| `08_copy` | Kopiraj | selection | `copy()` |
| `09_cut` | Izreži | selection | `cut()` |
| `10_paste` | Prilepi | clipboard | `paste()` |
| `11_undo` | Razveljavi | always | `undo()` |
| `12_redo` | Uveljavi | always | `redo()` |
| `13_center` | Matična ladja | always | `center_camera()` |

Adding a button:
1. Write the function or bool property in `build_tool.gd`.
2. Create `data/controls/<nn>_<name>.tres` from `ActionButtonDef`.

## Key dispatcher

A second input path for hardware keyboards and editor runs. Every key shortcut is an Input Map action named `build_<function>`, and `build_tool.gd` calls the function of that name. A trailing number becomes the argument: `build_select_slot_3` calls `select_slot(3)`. `hold_` actions are read with `Input.is_action_pressed` while a gesture runs, and `camera_` actions belong to `camera_rig`.

```gdscript
const SHORTCUT_PREFIX := "build_"

var _shortcut_calls: Dictionary[StringName, Callable] = {}

func _ready() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with(SHORTCUT_PREFIX):
			_shortcut_calls[action] = _call_for(String(action).trim_prefix(SHORTCUT_PREFIX))

func _shortcut_input(event: InputEvent) -> void:
	for action in _shortcut_calls:
		# exact_match: with false, Shift+R also fires build_rotate_cw.
		if event.is_action_pressed(action, false, true):
			get_viewport().set_input_as_handled()
			_shortcut_calls[action].call()
			return

func _call_for(shortcut: String) -> Callable:
	var head_and_number := shortcut.rsplit("_", true, 1)
	var has_number := head_and_number.size() == 2 and head_and_number[1].is_valid_int()
	var function_name := head_and_number[0] if has_number else shortcut
	if not has_method(function_name):
		push_error("Input Map action build_%s has no function %s in build_tool.gd" % [shortcut, function_name])
	var function_call := Callable(self, function_name)
	return function_call.bind(head_and_number[1].to_int()) if has_number else function_call
```

| Key | Input Map action | Effect |
|---|---|---|
| 1 to 9, 0 | `build_select_slot_1` to `build_select_slot_10` | `select_slot(n)` |
| Q | `build_pipette` | `pipette()` at the pointer cell |
| R, Shift+R | `build_rotate_cw`, `build_rotate_ccw` | `rotate_cw()`, `rotate_ccw()` |
| F | `build_flip_conveyors` | `flip_conveyors()` |
| Delete, Backspace | `build_delete_selection` | `delete_selection()` |
| Ctrl+C, Ctrl+X, Ctrl+V | `build_copy`, `build_cut`, `build_paste` | `copy()`, `cut()`, `paste()` |
| Ctrl+Z | `build_undo` | `undo()` |
| Ctrl+Y, Ctrl+Shift+Z | `build_redo` | `redo()` |
| Shift held | `hold_place_multiple` | counts as `keep_placing` |
| Ctrl held | `hold_straight_line` | counts as `straight_line` |
| Esc | `go_back` | `Game.go_back()` |
| WASD, arrows; Space | `camera_pan_up` / `_down` / `_left` / `_right`; `camera_center` | read by `camera_rig` |

Adding a shortcut:
1. Add `build_<name>` with its key in Project Settings > Input Map.
2. Write `func <name>()` in `build_tool.gd`.

## Game state, menus, settings, saving

**Game state**

- `Game` holds the open `LevelDef`, its sim and a pause flag, and steps the sim through `SimClock` in `_physics_process` while a level is open and not paused.
- `SCREENS: Dictionary[StringName, String]` maps screen ids to scene paths, and `Game.open(id)` changes scene. Pause and level complete are overlays on the play screen.
- `Game.go_back()` runs for Esc and for `NOTIFICATION_WM_GO_BACK_REQUEST`. On the play screen it calls `build_tool.cancel()`, which drops the tool or selection and returns whether it dropped anything; with nothing dropped it opens the pause overlay (Nadaljuj, Nastavitve, Glavni meni). On the main menu it quits.
- The HUD has a pause button for devices without a back gesture.
- `tracker.completed` → world save, level marked complete in progress, level complete overlay ("Stopnja opravljena", Glavni meni).

**Main menu**

Nadaljuj (last played level, hidden without one), Igraj (level select), Nastavitve. Level select builds one section per grade and one button per level from `Registry.levels`, and marks completed levels.

**Settings**

A setting is `data/settings/<nn>_<id>.tres` from `SettingDef` plus a function in `data/settings/setting_actions.gd`.

```gdscript
class_name SettingDef extends Resource

enum Kind { TOGGLE, SLIDER, CHOICE }

@export var label := ""
@export var kind := Kind.SLIDER
@export var default_value := 1.0
@export var min_value := 0.0
@export var max_value := 1.0
@export var step := 0.05
@export var choices: PackedStringArray = []
@export var action: StringName

# settings.cfg stores values under this id; renaming the .tres resets the setting to its default.
var id: StringName
```

- Every kind stores a float: toggles 0 or 1, choices an index.
- `Settings` reads `user://settings.cfg` with `ConfigFile`, falls back to `default_value`, and calls every `action` at boot; a change calls its action and writes the file.
- The settings screen builds one row per def from `kind`: TOGGLE → `CheckButton`, SLIDER → `HSlider`, CHOICE → `OptionButton`.
- Defs: `01_master_volume` (Glasnost), `02_music_volume` (Glasba), `03_effects_volume` (Zvočni učinki), on audio buses Master, Music and SFX.

**Saving**

- `user://progress.sav`: completed level ids and the last played level.
- `user://worlds/<level_id>.sav`: every building except the mothership as `[def_id, origin, rotation, inputs, outputs, timer]`, plus `tracker.received`.
- `FileAccess.store_var` writes both files, so ints, `Vector2i` and `StringName` load back with their types.
- Loading skips unknown def ids and resizes slot arrays to the def's current port counts, which keeps old saves loadable after a def changes.
- Autosave every 30 s while playing, on level complete, on leaving to the menu and on `NOTIFICATION_APPLICATION_PAUSED`.

## Project settings

- Renderer: Compatibility (OpenGL ES 3) for desktop and mobile.
- `display/window/stretch/mode` = `canvas_items`, `display/window/stretch/aspect` = `expand`.
- `input_devices/pointing/emulate_touch_from_mouse` on, so a mouse in the editor run produces touch events; the world reads `InputEventScreenTouch` and `InputEventScreenDrag` only.
- `application/config/quit_on_go_back` off, so `NOTIFICATION_WM_GO_BACK_REQUEST` reaches `Game.go_back()`.
