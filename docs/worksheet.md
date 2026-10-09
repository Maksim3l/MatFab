# Matfab worksheet

Every `## E` section is a Jira epic and every `### T` section a task under it, in this order. Each task depends only on tasks above it, so the To Do column runs top to bottom. Jira space `KAN` is the live backlog and this file stays as the original plan.

Every task names the `docs/design.md` sections it implements, what is true when it is done, and the tests it adds.

## E0 Project setup

A Godot project that imports headless and runs a test suite.

### T00 Project skeleton

Design: Folders and layers, Project settings

Done when:
- `project.godot` exists with the name `Matfab` and every setting under Project settings.
- The folders from the design exist; empty ones hold a `.gitkeep`.
- GUT 9.x matching the installed Godot version sits in `addons/gut` and is enabled; `.gutconfig.json` runs every `test_*.gd` under `res://tests` including subfolders and exits.

Tests:
- `tests/test_smoke.gd` with one passing test.

## E1 Data layer

Every schema exists, and the Registry loads all data at startup and reports broken block definitions.

### T01 Resource schemas

Design: Levels and the mothership, Blocks, Action bar, Game state, menus, settings, saving (Settings)

Done when:
- `PortDef`, `BuildingDef`, `LevelDef`, `OrePatch`, `SettingDef` and `ActionButtonDef` exist in `data/schema/` with exactly the fields in the design.
- Each can be created in the inspector and saved as a `.tres`.

Tests:
- Each schema instantiates with its defaults.
- `PortDef.Side` is ordered UP, RIGHT, DOWN, LEFT.

### T02 Registry

Design: Folders and layers

Done when:
- The `Registry` autoload loads every `.tres` under `data/blocks`, `data/levels`, `data/settings` and `data/controls` with `ResourceLoader.list_directory` and sets `id` from the file name.
- `Registry.buildings`, `levels`, `settings` and `controls` are typed dictionaries keyed by id; levels, settings and controls are also available sorted by file name.
- The folder loader takes the folder path as an argument.

Tests:
- A folder under `tests/fixtures/` loads with the right ids and sort order.

### T03 Operations and the startup check

Design: Blocks

Done when:
- `data/blocks/operations.gd` (`class_name Operations extends RefCounted`) holds `mine`.
- At startup `Registry` checks every PROCESSOR def: `has_method(operation)` on an `Operations` instance, and `get_method_argument_count(operation)` against the input port count. A mismatch goes to `push_error` with the `.tres` path.

Tests:
- The check passes for a valid fixture def.
- The check reports a fixture def with a missing function and one with a wrong argument count.

### T04 Core block and level data

Design: Blocks, Levels and the mothership

Done when:
- `mothership.tres`, `conveyor.tres` and `miner.tres` exist with the values and Slovenian names in the design.
- `data/levels/r1_01.tres` matches the design example, with `buildable` holding conveyor and miner; T17 adds sum.

Tests:
- `Registry` loads the three blocks and `r1_01` with the expected ids, and the startup check reports nothing.

## E2 Simulation core

A node-free simulation that places buildings, moves numbers through ports and runs processors.

### T05 Building state and port rotation

Design: Simulation, Blocks

Done when:
- `BuildingState` holds `def`, `origin`, `rotation`, `inputs`, `outputs` and `timer`.
- `sim/ports.gd` rotates a size, a cell inside that size and a side by 0 to 3 clockwise quarter turns, and returns each port's world cell and world side for a placed building.

Tests:
- All four rotations of a 2x1 block with ports on two sides.
- Side rotation wraps from LEFT to UP.

### T06 Grid, place and remove

Design: Simulation

Done when:
- `Simulation` keeps `cells` and `ore`.
- `place(def_id, origin, rotation) -> bool` fails outside the map, on overlap, or with an ORE port off ore, and converts `duration` to ticks at 20 per second.
- A conveyor placed on a conveyor replaces it and keeps its number.
- `remove(cell) -> bool` removes the building covering the cell and leaves the mothership in place.

Tests:
- Each failure case of `place`.
- Conveyor replacement keeps the number.
- `remove` clears every covered cell and returns false on the mothership.

### T07 Transfers and the processor

Design: Simulation

Done when:
- Every behavior script implements `tick(building)` and `accept(building, cell, side, number) -> bool`, and `Simulation.offer(cell, side, number)` is the only transfer path.
- PROCESSOR follows the design rules: the timer runs while all inputs are full and all outputs empty, `callv` runs at `duration`, a lone `int` result becomes a one-element array, NEIGHBOR inputs empty after firing, ORE inputs stay full.
- `Simulation.step()` ticks every building once.

Tests:
- A processor with its input slots set directly produces the operation result after `duration` ticks.
- A full output slot stops the timer.
- An ORE input stays full after firing.

### T08 Sim clock

Design: Simulation

Done when:
- `sim/sim_clock.gd` turns frame deltas into whole steps at 20 per second, carries the remainder between calls, and exposes the fraction toward the next step.

Tests:
- Deltas summing to one second give 20 steps.
- The remainder carries across calls.

## E3 Ore and the debug scene

A level loads into a scene that shows the ground, the ore numbers and the mothership, with a touch camera.

### T09 Loading a level

Design: Levels and the mothership

Done when:
- `Simulation.from_level(level)` fills `ore` from `ore_patches`, places `mothership.tres` at (0, 0) and sets the map bounds from `map_size` centered on (0, 0).

Tests:
- `r1_01` produces the expected ore cells and a mothership covering the expected cells.

### T10 Debug scene and touch camera

Design: View, Touch input

Done when:
- `debug/debug_play.tscn` loads `r1_01` and steps the sim with `SimClock`; `ground_view` draws ore cells as tinted cells with their values, and the mothership shows as its placeholder.
- `view/touch_gestures.gd` handles one-finger pan with no tool, two-finger pan and pinch zoom through `camera_rig`, and `camera_rig` centers on the mothership.
- A mouse works in the editor run through touch emulation.

Tests:
- Pinch distance to zoom factor lives in a plain function with a test.

## E4 Mothership and goals

Numbers that reach the mothership count against the level goals, and the HUD shows the counts.

### T11 Goal tracker and the mothership

Design: Levels and the mothership, Simulation

Done when:
- `GoalTracker` matches the design code, and `from_level` creates it.
- The MOTHERSHIP behavior accepts every number on every edge and calls `tracker.receive`.

Tests:
- Only goal numbers count.
- `completed` emits once, and numbers after completion are ignored.
- The mothership accepts from all four sides.

### T12 HUD goal list

Design: Levels and the mothership

Done when:
- `ui/hud.tscn` lists the goals in data order as the number and `received / amount`, updated from `counted`.

Tests:
- None; the tracker tests cover the counts.

## E5 Conveyor

Players draw conveyors with a finger, and numbers move along them to the mothership.

### T13 Conveyor behavior

Design: Simulation

Done when:
- The CONVEYOR behavior holds one slot, accepts from any side except its front when the slot is empty, holds the number for `duration`, then offers it to the front.

Tests:
- A line of three conveyors moves a number into the mothership in three times `duration`.
- A conveyor fed from its side passes the number on.
- A full slot refuses a second number.

### T14 Building and number views

Design: View

Done when:
- `building_view` draws a def without `sprite` as a rect with `symbol`, and `item_view` draws a number as a circle with its value.
- Conveyor numbers interpolate between ticks from `timer` and the clock fraction, and a conveyor fed from its side draws as a corner.

Tests:
- The interpolated position along a conveyor lives in a plain function with a test.

### T15 Toolbar, tap and conveyor drag

Design: Touch input, Placement rules

Done when:
- The HUD toolbar lists `level.buildable`; tapping a slot selects it, and tapping the active slot drops the tool.
- A tap shows the ghost under the finger, and release places it.
- A conveyor drag shows ghosts along the cells, each facing the next cell and red where `place` fails; release commits them, and a second finger cancels them and moves the camera instead.
- A conveyor drag over existing conveyors re-routes them.
- The tool drops after placing unless its def has `keep_selected`.

Tests:
- Drag path to cells and facing lives in a plain class with tests, including a turn.

## E6 Miner

Miners placed on ore produce its number.

### T16 Miner

Design: Blocks, Simulation

Done when:
- A miner places only on ore, and its ghost is red elsewhere.
- A miner produces its ore value every `duration` while its output is free.

Tests:
- A miner on ore 2 next to a conveyor line feeds 2 into the mothership.
- Placing a miner off ore fails.

## E7 Sum

The first math block arrives through the three-step path in the design, with no sim code changes.

### T17 Sum block

Design: Blocks

Done when:
- `sum` is in `operations.gd`, `sum.tres` matches the design, and `r1_01` lists sum in `buildable`.
- No file under `sim/` changes in this PR.

Tests:
- Two miners on ore 1 into a sum feed 2 into the mothership.
- Ore 1 and ore 2 into a sum feed 3.

## E8 Placement controls

Every placement shortcut in the design works by touch, and keyboard keys reach the same functions.

### T18 Action bar and rotation

Design: Action bar, Touch input

Done when:
- `ui/action_bar.tscn` builds one button per `ActionButtonDef` in file-name order, shows it while one of its contexts is active, calls `command` or toggles `toggles_property` on `build_tool`, and refreshes on `state_changed`.
- `01_rotate.tres` exists; `rotate_cw()` rotates the tool, each def keeps its last rotation, and a tap on a building of the same def rotates that building.
- `13_center.tres` exists; `center_camera()` centers `camera_rig` on the mothership.

Tests:
- Context filtering and order live in a plain class with tests.
- Each def keeps its own last rotation.

### T19 Keep placing, straight line and flip

Design: Placement rules, Action bar

Done when:
- `keep_placing`, `straight_line` and `conveyors_flipped` are bool properties on `build_tool`, with the button defs `02_keep_placing`, `03_straight_line` and `04_flip`.
- After a tap or drag, the tool drops unless `keep_placing` is on or its def has `keep_selected`.
- Drags of any other def place one copy per `size` step and skip cells where `place` fails; `straight_line` keeps a drag on the axis of its first step; `conveyors_flipped` makes conveyor drags face the drag start.

Tests:
- The drag path class covers step size, skips, the axis lock and flip.

### T20 Long-press pipette

Design: Touch input

Done when:
- A long press of 0.5 s with the finger still makes the pressed building's def and rotation the tool, or on bare ore the first buildable def with an ORE port.
- The release after a long press places nothing.

Tests:
- The pipette lookup lives in a plain function with tests for a building, bare ore and empty ground.

### T21 Undo and redo

Design: Placement rules, Action bar

Done when:
- `view/edit_history.gd` records each gesture (tap, drag, paste, delete) as the buildings it added and removed.
- `11_undo` and `12_redo` call `undo()` and `redo()`, which apply the inverse and reapply through `place` and `remove`.

Tests:
- Sequences of place, drag and remove followed by undo and redo restore the same set of buildings.

### T22 Eraser

Design: Touch input, Action bar

Done when:
- `05_eraser` calls `use_eraser()`, which makes the eraser the tool.
- A tap or drag marks buildings red and release removes them, the mothership excepted, as one gesture.

Tests:
- Erasing along a path through the drag path class and the sim.

### T23 Selection, delete, copy and cut

Design: Placement rules, Action bar

Done when:
- `06_select` calls `use_selector()`; a drag selects a rectangle.
- `07_delete`, `08_copy` and `09_cut` show while a selection exists.
- Copy and cut store a blueprint in `view/blueprint.gd` (def id, offset from the selection's top-left cell, rotation); delete and cut remove the selection, the mothership excepted.

Tests:
- Capturing a blueprint from a known layout.

### T24 Paste

Design: Placement rules, Touch input, Action bar

Done when:
- `10_paste` shows while a blueprint exists and makes it the tool.
- The ghost follows the finger, rotates as a whole on Rotate, draws parts that do not fit in red, and release places it when every part fits.

Tests:
- Blueprint rotation and the fit check.

### T25 Key dispatcher

Design: Key dispatcher

Done when:
- The dispatcher from the design is in `build_tool.gd`.
- The Input Map holds every action in the design's key table, and held Shift and Ctrl count as `keep_placing` and `straight_line`.

Tests:
- `_call_for` maps `select_slot_3` to `select_slot(3)` and `rotate_cw` to `rotate_cw()`.

## E9 Game state and menus

Screens, pause, back handling and the menus that open levels.

### T26 Game autoload and back handling

Design: Game state, menus, settings, saving (Game state)

Done when:
- `Game` holds the open level, its sim and a pause flag; `SCREENS` maps screen ids to scene paths, and `Game.open(id)` changes scene.
- `Game` steps the sim through `SimClock` while a level is open and not paused, and the debug scene keeps stepping on its own.
- `Game.go_back()` handles Esc and `NOTIFICATION_WM_GO_BACK_REQUEST` as the design describes, with `build_tool.cancel()` returning whether it dropped anything.
- The HUD pause button and the pause overlay (Nadaljuj, Nastavitve, Glavni meni) work; `tracker.completed` opens the level complete overlay.

Tests:
- Every id in `SCREENS` points at an existing scene.
- Steps stop while paused.

### T27 Main menu and level select

Design: Game state, menus, settings, saving (Main menu), Levels and the mothership

Done when:
- The main menu shows Igraj and Nastavitve; Nadaljuj stays hidden until the saving epic shows it.
- Level select shows one section per grade ("1. razred") and one button per level from `Registry.levels` in file-name order, with completed levels marked.

Tests:
- Grouping by grade and ordering live in a plain function with tests.

## E10 Settings

Settings as data, stored on the device.

### T28 Settings

Design: Game state, menus, settings, saving (Settings)

Done when:
- Audio buses Master, Music and SFX exist, and `setting_actions.gd` holds `master_volume`, `music_volume` and `effects_volume`.
- The `Settings` autoload reads `user://settings.cfg` with `ConfigFile`, falls back to `default_value`, calls every action at boot, and on change calls the action and writes the file.
- `ui/settings_menu.tscn` builds one row per def from `kind`.
- `01_master_volume`, `02_music_volume` and `03_effects_volume` exist with the labels Glasnost, Glasba and Zvočni učinki.

Tests:
- A missing file falls back to defaults.
- A changed value survives a save and reload through a temporary path.

## E11 Saving

Progress and worlds survive closing the app.

### T29 Save store

Design: Game state, menus, settings, saving (Saving)

Done when:
- `user://progress.sav` holds completed level ids and the last played level.
- `user://worlds/<level_id>.sav` holds every building except the mothership as `[def_id, origin, rotation, inputs, outputs, timer]`, plus `tracker.received`.
- `FileAccess.store_var` writes both files.
- Loading skips unknown def ids and resizes slot arrays to the def's current port counts.

Tests:
- A world survives a save and load.
- An unknown def id is skipped.
- A def with a changed port count loads.

### T30 Autosave and Nadaljuj

Design: Game state, menus, settings, saving (Saving, Main menu)

Done when:
- Autosave runs every 30 s while playing, on level complete, on leaving to the menu and on `NOTIFICATION_APPLICATION_PAUSED`.
- Entering a level with a world file loads it.
- Nadaljuj shows when a last played level exists and opens it.

Tests:
- The 30 s autosave timer lives in a plain class with a test.
