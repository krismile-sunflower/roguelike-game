# Asset Sources

This folder tracks every third-party or downloaded asset used by the game.

## Required Entry Format

- Asset pack:
- Source URL:
- Author:
- License:
- Files imported:
- Notes:

## Planned Sources

- Kenney assets: https://kenney.nl/assets
- Kenney license/support: https://kenney.nl/support
- Kenney Tiny Dungeon: https://kenney.nl/assets/tiny-dungeon
- Kenney 1-Bit Pack: https://kenney.nl/assets/1-bit-pack
- Kenney All-in-1: https://kenney.itch.io/kenney-game-assets
- itch.io free roguelike assets: https://itch.io/game-assets/free/tag-roguelike
- OpenGameArt CC0 resources: https://opengameart.org/content/cc0-resources

Only import files after confirming their license on the source page.

## Imported Assets

- Asset pack: Kenney Tiny Dungeon
- Source URL: https://kenney.nl/assets/tiny-dungeon
- Download URL: https://kenney.nl/media/pages/assets/tiny-dungeon/f8422efb44-1674742415/kenney_tiny-dungeon.zip
- Author: Kenney
- License: Creative Commons Zero (CC0)
- License file: `assets/art/kenney_tiny-dungeon/License.txt`
- Files imported: `assets/art/kenney_tiny-dungeon/**`
- Files currently referenced by code:
  - `Tiles/tile_0048.png`, `tile_0049.png`, `tile_0042.png` as floor variants
  - `Tiles/tile_0014.png`, `tile_0040.png` as wall variants
  - `Tiles/tile_0045.png` as the level exit
  - `Tiles/tile_0085.png` as the player
  - `Tiles/tile_0096.png`, `tile_0110.png`, `tile_0112.png`, `tile_0120.png`, `tile_0122.png`, `tile_0123.png` as enemies
  - `Tiles/tile_0101.png`, `tile_0102.png`, `tile_0103.png`, `tile_0113.png`, `tile_0114.png` as pickups and gear
  - `Tiles/tile_0029.png`, `tile_0041.png`, `tile_0053.png`, `tile_0079.png`, `tile_0090.png` as dungeon decor and interactables

- Asset pack: Kenney Interface Sounds (1.0)
- Source URL: https://kenney.nl/assets/interface-sounds
- Download URL: https://kenney.nl/media/pages/assets/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip
- Author: Kenney
- License: Creative Commons Zero (CC0)
- License file: `assets/audio/kenney_interface-sounds/License.txt`
- Files imported: `assets/audio/kenney_interface-sounds/Audio/*.ogg`
- Files currently referenced by code:
  - `click_003.ogg` as `pickup`
  - `drop_003.ogg` as `drop_success`
  - `error_004.ogg` as `drop_reset`
  - `confirmation_001.ogg` as `complete`
  - `click_005.ogg` as `hint`
  - `click_002.ogg` as `button`
