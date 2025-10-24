# Changelog
All notable changes to this project will be documented in this file.

## [2.3.0] - 2025-10-05
- Config block can now accept prefix colour options. Can be applied to the whole prefix or configure individual components.

## [2.2.1] - 2025-09-15
- Fixed issue with ANSI exit codes breaking on string interpolation
- Added strip_colour method to String which we now call when sending logs to file
- Added colours/styles: yellow, bg_yellow, bg_white, bg_bright_red, bg_bright_green, bg_bright_blue, bg_bright_magenta, bg_bright_cyan, dim
- Removed colours/styles: bright_black (that's just gray), bright_yellow (that's just yellow), blink (inconsistent/unsupported)
- Added a changelog


## [2.2.0] - 2025-09-08
- Added colourise method to handle colour exist codes
- Added alias for colour/color
- Added alias for brown/yellow
