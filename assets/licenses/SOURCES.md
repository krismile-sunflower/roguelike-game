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
- Kenney Furniture Kit: https://kenney.nl/assets/furniture-kit
- Kenney All-in-1: https://kenney.itch.io/kenney-game-assets
- itch.io free cozy 2D assets: https://itch.io/game-assets/free/tag-2d/tag-cozy
- OpenGameArt CC0 resources: https://opengameart.org/content/cc0-resources

Only import files after confirming their license on the source page.

## Imported Assets

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
