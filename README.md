# Dust2 Enhancement Plugin

A creative and polished AMX Mod X plugin that enhances the classic de_dust2 experience in Counter-Strike 1.6.

## Main Components Explained

### 1. Plugin Structure & Initialization

The plugin follows a clean, organized structure with clearly commented sections:

- **Includes**: Standard AMX Mod X libraries (amxmodx, amxmisc, fun)
- **Constants**: Configuration values for bonuses, HUD positions, and channels
- **Global Variables**: State tracking for map detection, player stats, and timers
- **Message Arrays**: Pre-defined messages for welcome, tips, atmosphere, and restrictions

### 2. Map Detection System

**How it works:**
- `plugin_cfg()` is called when the map loads
- Uses `get_mapname()` to retrieve the current map name
- Performs case-insensitive comparison with "de_dust2"
- Sets global flag `g_bIsDust2` to enable/disable features
- All feature functions check this flag before executing

**Why it matters:**
This ensures the plugin only activates on de_dust2, preventing interference with other maps.

### 3. Player Welcome System

**How it works:**
- `client_putinserver()` event triggers when a player connects
- After 1 second delay, `show_welcome_message()` is called
- Gets player name using `get_user_name()`
- Selects random message from `g_szWelcomeMessages` array
- Formats message with player name and displays in chat

**Creative touch:**
Messages are personalized and use color codes (^x04 for green, ^x01 for white) to make them visually appealing.

### 4. HUD Status Panel System

**How it works:**
- Timer runs every 1 second calling `timer_update_hud()`
- For each alive player, `update_status_hud()` is called
- Gets player health, armor, and team
- Determines color based on health (green >75, yellow 40-75, red <40)
- Displays compact 3-line HUD on left side (channel 1)

**Creative touch:**
Health-based color coding provides instant visual feedback about player status.

### 5. Round Start Notification System

**How it works:**
- `event_round_start()` triggers at the beginning of each round
- Increments global round counter
- Selects random message from `g_szRoundMessages` array
- Formats with current round number
- Displays cyan HUD message at top center for 5 seconds (channel 2)

**Creative touch:**
Messages include tactical hints specific to Dust2 locations (Long A, Mid Control, Catwalk).

### 6. Spawn Bonus System

**How it works:**
- `event_player_spawn()` triggers when player spawns
- After 0.5 second delay, `apply_spawn_bonus()` is called
- Validates player is alive and connected
- Random 50/50 selection between health and armor bonus
- Checks current stats and applies +10 bonus if below cap
- Health cap: 110 HP, Armor cap: 100
- Shows brief notification HUD (channel 4)

**Creative touch:**
- Green notification for health ("Desert Blessing")
- Blue notification for armor ("Fortified")
- Bonuses are small enough to be balanced but meaningful

### 7. Weapon Restriction System

**How it works:**
- `cmd_say()` intercepts player chat commands
- Checks if player is trying to buy AWP (contains "awp" or "magnum")
- Blocks the command and shows restriction message
- Selects random message from `g_szRestrictionMessages` array
- Displays in both center screen and chat

**Why AWP is restricted:**
- Dominates long sightlines on Dust2 (Long A, Mid)
- Reduces tactical variety when overused
- Encourages rifle skill development
- Creates more dynamic, movement-based gameplay

### 8. Message Engine (Tips & Atmosphere)

**How it works:**
- Timer runs every 45-60 seconds (randomized) calling `timer_message_rotation()`
- Alternates between tactical tips and atmospheric flavor
- Uses global flag `g_bShowTip` to track which type to show next
- Selects random message from appropriate array
- Displays to all players in chat
- Schedules next message with new randomized interval

**Creative touch:**
- **Tips**: Practical Dust2 tactics (smoke Xbox, flash Long Doors, control Catwalk)
- **Atmosphere**: Immersive flavor text (desert sun, dust swirls, echoes of battles)
- Randomized timing prevents predictability and spam

### 9. Helper Functions

**`is_valid_player(player_id)`**
- Validates player index is within bounds (1-32)
- Checks if player is connected using `is_user_connected()`
- Used at the start of every player-specific function
- Prevents crashes from invalid player indices

**`is_dust2_active()`**
- Simple getter for `g_bIsDust2` flag
- Provides clean API for checking plugin activation

### 10. State Management & Cleanup

**Initialization (`plugin_init()`):**
- Registers plugin metadata
- Registers events (round start, spawn, death)
- Registers command hooks (say commands)
- Logs initialization message

**Configuration (`plugin_cfg()`):**
- Detects current map
- Starts timers if on de_dust2
- Clears player tracking arrays
- Logs activation status

**Cleanup (`plugin_end()`):**
- Removes all timers
- Resets timer handles
- Logs unload message
- Prevents memory leaks

## Code Quality Features

### 1. Comprehensive Comments
Every major section has block comments explaining its purpose. Complex logic has inline comments.

### 2. Descriptive Naming
- Functions: `show_welcome_message()`, `apply_spawn_bonus()`, `timer_update_hud()`
- Variables: `g_bIsDust2`, `g_iRoundNumber`, `g_szTipMessages`
- Constants: `BONUS_HEALTH_MAX`, `HUD_STATUS_CHANNEL`

### 3. Error Handling
- Player validation before all operations
- Sanity checks on retrieved values (health, armor)
- Silent failures to prevent console spam
- Logging for critical errors

### 4. Performance Optimization
- Early exit checks (`if (!g_bIsDust2) return`)
- Efficient timer usage (1 second for HUD, 45-60 seconds for messages)
- Minimal string operations
- Proper cleanup prevents memory leaks

### 5. Beginner-Friendly
- Clear structure with section headers
- Well-commented code
- Follows Pawn conventions
- Single file for easy distribution

## Technical Details

### HUD Channels
- **Channel 1**: Status panel (left side, persistent)
- **Channel 2**: Round alerts (top center, 5 seconds)
- **Channel 3**: Reserved for future use
- **Channel 4**: Bonus notifications (center, 2 seconds)

### Color Codes in Chat
- `^x01`: White (default)
- `^x03`: Team color (blue for CT, red for T)
- `^x04`: Green (highlights)

### Timer System
- HUD timer: Repeating task every 1 second
- Message timer: One-shot task with randomized re-scheduling
- Proper cleanup on map change and plugin end

### Player Arrays
- Indexed 1-32 (index 0 unused, standard Pawn convention)
- Parallel arrays for health, armor, alive status, team
- Cleared on map change to prevent stale data

## Customization

Want to modify the plugin? Here are the key areas:

### Change Bonus Amounts
Edit these constants:
```pawn
#define BONUS_HEALTH_AMOUNT 10
#define BONUS_HEALTH_MAX    110
#define BONUS_ARMOR_AMOUNT  10
#define BONUS_ARMOR_MAX     100
```

### Add More Messages
Add to these arrays:
```pawn
new const g_szTipMessages[][] = { ... }
new const g_szAtmosphereMessages[][] = { ... }
new const g_szRoundMessages[][] = { ... }
```

### Adjust HUD Positions
Modify these constants:
```pawn
#define HUD_STATUS_X  0.02  // 0.0 = left, 1.0 = right
#define HUD_STATUS_Y  0.25  // 0.0 = top, 1.0 = bottom
```

### Change Message Timing
Edit the interval in `timer_message_rotation()`:
```pawn
new Float:next_interval = random_float(45.0, 60.0)  // 45-60 seconds
```

## Why This Plugin is Special

1. **Map-Specific**: Only activates on de_dust2, respecting other maps
2. **Balanced**: Small bonuses that enhance without breaking gameplay
3. **Immersive**: Dust2-themed messages create atmosphere
4. **Informative**: HUD provides useful info without clutter
5. **Strategic**: AWP restriction encourages diverse tactics
6. **Polished**: Clean code, proper error handling, performance optimized
7. **Beginner-Friendly**: Well-documented, easy to understand and modify

## License

This plugin is provided as-is for the Counter-Strike 1.6 community.
Feel free to modify and redistribute with attribution.

---

**Version**: 1.0.0  
**Author**: CS 1.6 Community  
**Platform**: AMX Mod X for Counter-Strike 1.6
# de_dust2
