# Dust2 Enhancement Plugin - Installation Guide

## Overview
This plugin enhances the de_dust2 map experience in Counter-Strike 1.6 with HUD displays, spawn bonuses, weapon restrictions, and atmospheric messages.

## Features
- **Welcome Messages**: Personalized greetings when players join
- **HUD Status Panel**: Real-time health, armor, and team display
- **Round Start Alerts**: Dynamic round notifications with tactical hints
- **Spawn Bonuses**: Random +10 HP or +10 Armor on spawn
- **Weapon Restrictions**: AWP is restricted for balanced gameplay
- **Atmospheric Messages**: Tips and flavor text every 45-60 seconds
- **Map-Specific**: Only activates on de_dust2

## Requirements
- Counter-Strike 1.6 Server
- AMX Mod X 1.8.2 or higher
- Standard AMX Mod X modules (amxmodx, amxmisc, fun)

## Installation Steps

### 1. Compile the Plugin

**Option A: Using AMX Mod X Compiler (Recommended)**
```bash
# Navigate to your AMX Mod X scripting directory
cd addons/amxmodx/scripting

# Compile the plugin
./amxxpc dust2_enhancement.sma

# This will create dust2_enhancement.amxx
```

**Option B: Using Web Compiler**
1. Visit https://www.amxmodx.org/websc.php
2. Upload `dust2_enhancement.sma`
3. Click "Compile"
4. Download the compiled `dust2_enhancement.amxx` file

### 2. Install the Compiled Plugin

Copy the compiled plugin to your plugins directory:
```bash
cp dust2_enhancement.amxx addons/amxmodx/plugins/
```

### 3. Enable the Plugin

Edit `addons/amxmodx/configs/plugins.ini` and add:
```
dust2_enhancement.amxx
```

### 4. Restart Your Server

Restart your Counter-Strike 1.6 server or change the map:
```
amx_map de_dust2
```

## File Structure

After installation, your directory should look like this:
```
cstrike/
├── addons/
│   └── amxmodx/
│       ├── configs/
│       │   └── plugins.ini          (add plugin here)
│       ├── plugins/
│       │   └── dust2_enhancement.amxx  (compiled binary)
│       └── scripting/
│           └── dust2_enhancement.sma   (source code)
```

## Verification

To verify the plugin is loaded:

1. Start your server
2. Change map to de_dust2: `amx_map de_dust2`
3. Check the server console for:
   ```
   Dust2 Enhancement Plugin v1.0.0 initialized
   Dust2 Plugin: de_dust2 detected, features enabled
   ```
4. Join the server and look for:
   - Welcome message in chat
   - HUD status panel on the left side
   - Round start messages at the top
   - Spawn bonuses when you respawn

## Configuration

This plugin requires no additional configuration. All features are pre-configured for optimal gameplay.

### Default Settings:
- **Spawn Bonus**: +10 HP (max 110) or +10 Armor (max 100)
- **HUD Update**: Every 1 second
- **Messages**: Every 45-60 seconds (randomized)
- **Restricted Weapons**: AWP only

## Troubleshooting

### Plugin Not Loading
- Check `addons/amxmodx/logs/error_*.log` for errors
- Verify AMX Mod X version is 1.8.2 or higher
- Ensure `fun` module is enabled in `modules.ini`

### Features Not Working
- Verify you're on de_dust2 map
- Check server console for "features enabled" message
- Restart the server after installation

### Compilation Errors
- Ensure you have the latest AMX Mod X compiler
- Check that all include files are present (amxmodx.inc, amxmisc.inc, fun.inc)
- Verify the source file is not corrupted

## Uninstallation

To remove the plugin:

1. Edit `addons/amxmodx/configs/plugins.ini`
2. Remove or comment out the line: `dust2_enhancement.amxx`
3. Restart your server

## Support

For issues or questions:
- Check AMX Mod X forums: https://forums.alliedmods.net/
- Review the source code comments for implementation details
- Verify all requirements are met

## Credits

- **Author**: CS 1.6 Community
- **Version**: 1.0.0
- **Platform**: AMX Mod X for Counter-Strike 1.6

## License

This plugin is provided as-is for Counter-Strike 1.6 community servers.
Feel free to modify and redistribute with attribution.
