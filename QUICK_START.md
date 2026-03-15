# Quick Start Guide - Dust2 Enhancement Plugin

## What You Get

A single `.sma` file that adds these features to de_dust2:

✅ Personalized welcome messages  
✅ Real-time HUD status panel (HP, Armor, Team)  
✅ Dynamic round start alerts  
✅ Spawn bonuses (+10 HP or Armor)  
✅ AWP restriction for balanced gameplay  
✅ Tactical tips and atmospheric messages  

## Installation (3 Steps)

### 1. Compile
```bash
cd addons/amxmodx/scripting
./amxxpc dust2_enhancement.sma
```

### 2. Install
```bash
cp dust2_enhancement.amxx addons/amxmodx/plugins/
```

### 3. Enable
Add to `addons/amxmodx/configs/plugins.ini`:
```
dust2_enhancement.amxx
```

Restart server or run: `amx_map de_dust2`

## Verify It Works

Join your server on de_dust2 and check for:
- Welcome message in chat
- HUD panel on left side showing HP/Armor/Team
- Round start message at top
- Spawn bonus notification when you respawn
- AWP purchase blocked with message

## Files Included

- `dust2_enhancement.sma` - Source code (compile this)
- `README.md` - Detailed explanation of all features
- `INSTALLATION.md` - Complete installation guide
- `QUICK_START.md` - This file

## Compilation Options

**Local Compiler:**
```bash
./amxxpc dust2_enhancement.sma
```

**Web Compiler:**
1. Go to https://www.amxmodx.org/websc.php
2. Upload `dust2_enhancement.sma`
3. Download `dust2_enhancement.amxx`

## Requirements

- Counter-Strike 1.6 Server
- AMX Mod X 1.8.2+
- Standard modules (amxmodx, amxmisc, fun)

## Troubleshooting

**Plugin not loading?**
- Check `addons/amxmodx/logs/error_*.log`
- Verify AMX Mod X version
- Ensure `fun` module is enabled

**Features not working?**
- Make sure you're on de_dust2 map
- Check console for "features enabled" message
- Restart server after installation

## Support

For detailed information, see:
- `README.md` - Component explanations
- `INSTALLATION.md` - Full installation guide

## Credits

**Version**: 1.0.0  
**Author**: CS 1.6 Community  
**Platform**: AMX Mod X

Enjoy your enhanced Dust2 experience! 🏜️
