# Design Document: Dust2 Enhancement Plugin

## Overview

The Dust2 Enhancement Plugin transforms the classic de_dust2 experience into an immersive, polished gameplay environment through intelligent HUD systems, dynamic messaging, strategic spawn mechanics, and atmospheric elements. Built as a single AMX Mod X plugin for Counter-Strike 1.6, it activates exclusively on de_dust2 to deliver a memorable experience without modifying map files.

### Design Philosophy

This plugin embraces three core principles:

1. **Contextual Awareness**: Every feature responds to the iconic Dust2 setting - from desert-themed messages to tactical callouts referencing Long A, Catwalk, and B Tunnels
2. **Progressive Disclosure**: Information appears when relevant, avoiding HUD clutter while keeping players informed
3. **Personality with Purpose**: Messages entertain while providing strategic value, creating engagement without distraction

### Key Innovations

- **Adaptive HUD System**: Multi-zone display that reorganizes based on player state (alive/spectating/buying)
- **Contextual Message Engine**: Dynamic messages that reference actual Dust2 locations and tactical situations
- **Smart Spawn Bonus Algorithm**: Balances team economy and player performance to distribute bonuses strategically
- **Weapon Meta System**: Restricts AWP with economy-aware messaging that explains the strategic reasoning
- **Desert Atmosphere Layer**: Immersive flavor text that reinforces the Dust2 setting and lore

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Plugin Core Engine                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Map Detector │  │ Event Router │  │ State Manager│      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│  HUD Subsystem  │  │Message Subsystem│  │ Gameplay System │
│                 │  │                 │  │                 │
│ • Status Panel  │  │ • Welcome Msgs  │  │ • Spawn Bonuses │
│ • Round Alerts  │  │ • Tips Engine   │  │ • Weapon Rules  │
│ • Info Overlays │  │ • Atmosphere    │  │ • Balance Logic │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Activation Flow


The plugin uses a state-based activation model:

```
Map Change Event
      │
      ▼
┌──────────────────┐
│ Extract Map Name │
└──────────────────┘
      │
      ▼
┌──────────────────┐      No      ┌──────────────────┐
│ Is "de_dust2"?   │─────────────▶│ Disable Features │
└──────────────────┘              └──────────────────┘
      │ Yes
      ▼
┌──────────────────┐
│ Enable Features  │
│ • Register Hooks │
│ • Start Timers   │
│ • Init HUD Zones │
└──────────────────┘
```

### Data Flow Architecture

Player events flow through a centralized event router that dispatches to specialized handlers:

```
Player Event (Join/Spawn/Death/Purchase)
              │
              ▼
      ┌───────────────┐
      │ Event Router  │
      └───────────────┘
              │
    ┌─────────┼─────────┬─────────┐
    ▼         ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│  HUD   │ │Message │ │Gameplay│ │ State  │
│Handler │ │Handler │ │Handler │ │Manager │
└────────┘ └────────┘ └────────┘ └────────┘
```

## Components and Interfaces

### 1. Map Detection System

**Purpose**: Identify de_dust2 and control feature activation

**Interface**:
```pawn
// Check if current map is de_dust2
bool:is_dust2_active()

// Called on map change
public plugin_cfg()
```

**Implementation Strategy**:
- Use `get_mapname()` to retrieve current map string
- Perform case-insensitive comparison with "de_dust2"
- Set global boolean flag `g_bIsDust2` for fast checks
- All feature functions check this flag before executing



### 2. Adaptive HUD System

**Purpose**: Display contextual player information across multiple screen zones

**HUD Zone Layout**:
```
┌─────────────────────────────────────────────────────────┐
│  [Round Alert Zone]                                     │  Top Center
│  "🏜️ DUST2 ENHANCED • Round 3 • Fight for Mid Control" │  (Round Start)
├─────────────────────────────────────────────────────────┤
│                                                         │
│                    [Gameplay Area]                      │
│                                                         │
│  [Status Panel]                                         │  Left Side
│  ┌──────────────┐                                       │  (Always Visible)
│  │ ❤️  95 HP    │                                       │
│  │ 🛡️  100 AR   │                                       │
│  │ 👥 CT        │                                       │
│  └──────────────┘                                       │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  [Tip/Atmosphere Zone]                                  │  Bottom Center
│  "💡 Control Catwalk for B site dominance"             │  (Periodic)
└─────────────────────────────────────────────────────────┘
```

**Interface**:
```pawn
// Update player status HUD (called every second)
update_status_hud(player_id)

// Display round start message
show_round_alert(round_number)

// Show contextual tip or atmosphere message
show_message_rotation()
```

**Creative HUD Features**:

1. **Status Panel** (Left Side, Persistent):
   - Uses Unicode icons for visual appeal (❤️ health, 🛡️ armor, 👥 team)
   - Color-coded: Green (>75 HP), Yellow (40-75 HP), Red (<40 HP)
   - Compact 3-line format to minimize obstruction
   - Updates every 1 second via `set_hudmessage()` with HUD channel 1

2. **Round Alert Zone** (Top Center, 5 seconds):
   - Appears at round start with dramatic flair
   - Includes round number and tactical hint
   - Examples:
     - "🏜️ DUST2 ENHANCED • Round 1 • Secure Long A!"
     - "⚔️ Round 5 • B Rush or Fake? You Decide!"
     - "🎯 Match Point • Every Position Counts!"
   - Uses HUD channel 2, cyan color, 5-second hold time

3. **Tip/Atmosphere Zone** (Bottom Center, Rotating):
   - Alternates between tactical tips and atmospheric flavor
   - Appears every 45-60 seconds (randomized timing)
   - Uses HUD channel 3, white/yellow color
   - Fades in/out smoothly



### 3. Dynamic Message Engine

**Purpose**: Deliver engaging, contextual messages that enhance immersion

**Message Categories**:

1. **Welcome Messages** (On Player Join):
   ```
   "Welcome to DUST2 ENHANCED, [PlayerName]!"
   "The desert awaits. Enhanced features active."
   "Prepare for tactical warfare with style."
   ```
   - Personalized with player name
   - Displayed via `client_print()` in chat
   - Appears within 2 seconds of connection

2. **Tactical Tips** (10 unique messages):
   ```
   "💡 Smoke Xbox to safely cross Mid to B"
   "💡 Flash over Long Doors before peeking"
   "💡 Listen for footsteps in B Tunnels"
   "💡 Catwalk control = B site dominance"
   "💡 AWP at Long A? Take Mid to B instead"
   "💡 Boost on A platform for surprise angles"
   "💡 Molotov CT spawn to delay rotations"
   "💡 Check corners at A site - many hiding spots"
   "💡 Coordinate pushes - don't peek alone"
   "💡 Economy matters - save when behind"
   ```

3. **Atmospheric Flavor** (10 unique messages):
   ```
   "🏜️ The desert sun beats down on ancient stones"
   "🏜️ Dust swirls through the abandoned marketplace"
   "🏜️ Echoes of past battles linger in these walls"
   "🏜️ Long A stretches endlessly toward destiny"
   "🏜️ The tunnels hold secrets and danger"
   "🏜️ Catwalk sways gently in the desert wind"
   "🏜️ Double doors creak with anticipation"
   "🏜️ CT spawn: where legends begin their defense"
   "🏜️ T spawn: the staging ground for glory"
   "🏜️ Mid doors: the gateway to chaos"
   ```

**Interface**:
```pawn
// Display welcome message to connecting player
show_welcome_message(player_id)

// Rotate through tips and atmosphere messages
public message_timer()

// Select random message from category
get_random_message(MessageCategory:category, output[], maxlen)
```

**Message Timing Algorithm**:
- Welcome: Triggered by `client_putinserver()` event
- Tips/Atmosphere: Timer-based, every 45-60 seconds (randomized)
- Alternates between tip and atmosphere (tip → atmosphere → tip...)
- Pauses during round start alerts to avoid overlap



### 4. Smart Spawn Bonus System

**Purpose**: Reward players strategically while maintaining balance

**Bonus Algorithm**:

```
Player Spawns
     │
     ▼
┌─────────────────┐
│ Validate Player │ ──No──▶ Skip
│ (Alive & Valid) │
└─────────────────┘
     │ Yes
     ▼
┌─────────────────┐
│ Roll Random     │
│ 50% Health      │
│ 50% Armor       │
└─────────────────┘
     │
     ├──Health──▶ ┌──────────────────┐
     │            │ Current HP < 100?│──Yes──▶ Add +10 HP (max 110)
     │            └──────────────────┘
     │                     │ No
     │                     ▼
     │            ┌──────────────────┐
     │            │ Skip (already    │
     │            │ at max)          │
     │            └──────────────────┘
     │
     └──Armor───▶ ┌──────────────────┐
                  │ Current AR < 100?│──Yes──▶ Add +10 AR (max 100)
                  └──────────────────┘
                           │ No
                           ▼
                  ┌──────────────────┐
                  │ Skip (already    │
                  │ at max)          │
                  └──────────────────┘
```

**Interface**:
```pawn
// Called on player spawn event
public event_player_spawn(player_id)

// Apply bonus with validation
apply_spawn_bonus(player_id)

// Notify player of bonus received
show_bonus_notification(player_id, BonusType:type, amount)
```

**Creative Bonus Features**:

1. **Balanced Distribution**:
   - 50/50 random split between health and armor
   - Prevents stacking (checks current values)
   - Small bonuses (+10) avoid game-breaking advantages
   - Health cap at 110 HP (slight edge without invincibility)
   - Armor cap at 100 (standard maximum)

2. **Visual Feedback**:
   - Small HUD notification on bonus grant
   - Examples:
     - "⚡ +10 HP • Desert Blessing"
     - "⚡ +10 Armor • Fortified"
   - Appears briefly (2 seconds) in HUD channel 4
   - Green color for health, blue for armor

3. **Strategic Impact**:
   - Encourages aggressive play (small HP buffer)
   - Reduces eco round disadvantage slightly
   - Rewards survival (bonuses accumulate if not at cap)



### 5. Weapon Restriction System

**Purpose**: Enhance strategic gameplay by restricting AWP sniper rifle

**Restriction Strategy**:

The AWP (Arctic Warfare Police sniper rifle) is restricted because:
- Dominates long sightlines on Dust2 (Long A, Mid)
- Reduces tactical variety when overused
- Creates more dynamic, movement-based gameplay
- Encourages rifle skill development

**Interface**:
```pawn
// Hook weapon purchase attempts
public event_weapon_purchase(player_id)

// Check if weapon is restricted
bool:is_weapon_restricted(weapon_id)

// Block purchase and notify player
block_purchase_with_message(player_id, weapon_name[])
```

**Implementation Flow**:

```
Player Attempts Purchase
         │
         ▼
┌──────────────────┐
│ Get Weapon ID    │
└──────────────────┘
         │
         ▼
┌──────────────────┐      No      ┌──────────────────┐
│ Is AWP?          │─────────────▶│ Allow Purchase   │
└──────────────────┘              └──────────────────┘
         │ Yes
         ▼
┌──────────────────┐
│ Block Purchase   │
└──────────────────┘
         │
         ▼
┌──────────────────┐
│ Show Message     │
│ (Contextual)     │
└──────────────────┘
```

**Creative Restriction Messages** (Rotated randomly):

```
"🚫 AWP restricted • Master the AK/M4 instead!"
"🚫 No AWP on this server • Rifle skills matter here"
"🚫 AWP disabled • Keep the action fast-paced"
"🚫 Snipers restricted • Try the Scout for long range"
"🚫 AWP not available • Adapt your strategy"
```

**Strategic Benefits**:
- Forces players to use rifles, SMGs, and Scout
- Increases close-quarters combat frequency
- Makes positioning more important than one-shot kills
- Levels playing field between skill levels
- Maintains Dust2's iconic rifle duels



### 6. State Management System

**Purpose**: Track plugin state and player data efficiently

**Global State Variables**:
```pawn
// Plugin activation state
new bool:g_bIsDust2 = false

// Player tracking
new g_iPlayerHealth[33]      // Cached health values
new g_iPlayerArmor[33]       // Cached armor values
new bool:g_bPlayerAlive[33]  // Alive status

// Message rotation state
new g_iMessageIndex = 0      // Current message in rotation
new bool:g_bShowTip = true   // Alternate between tips/atmosphere

// Timer handles
new g_hHudTimer = 0          // HUD update timer
new g_hMessageTimer = 0      // Message rotation timer
```

**Interface**:
```pawn
// Initialize plugin state
public plugin_init()

// Reset state on map change
public plugin_cfg()

// Clean up on plugin end
public plugin_end()

// Validate player index
bool:is_valid_player(player_id)
```

**State Lifecycle**:

1. **Initialization** (`plugin_init()`):
   - Register events (spawn, death, join, round_start)
   - Register commands (weapon purchase hooks)
   - Initialize arrays and variables
   - Set up timer handles

2. **Configuration** (`plugin_cfg()`):
   - Detect current map
   - Enable/disable features based on map
   - Start timers if on Dust2
   - Reset player tracking arrays

3. **Runtime Updates**:
   - Player events update tracking arrays
   - Timers trigger HUD/message updates
   - Validation checks prevent crashes

4. **Cleanup** (`plugin_end()`):
   - Stop all timers
   - Clear state variables
   - Unregister hooks



## Data Models

### Player State Model

```pawn
// Player state is tracked using parallel arrays indexed by player ID (1-32)
// This approach is idiomatic for Pawn and memory-efficient

struct PlayerState {
    health: integer (0-255)      // Current health points
    armor: integer (0-255)       // Current armor points
    alive: boolean               // Is player currently alive
    team: integer (1=T, 2=CT)    // Team affiliation
    valid: boolean               // Is player slot occupied
}

// Implemented as:
new g_iPlayerHealth[33]    // Index 0 unused, 1-32 for players
new g_iPlayerArmor[33]
new bool:g_bPlayerAlive[33]
new g_iPlayerTeam[33]
```

### Message Model

```pawn
// Messages stored as string arrays with category grouping

enum MessageCategory {
    MSG_WELCOME,      // Player join messages
    MSG_TIP,          // Tactical tips
    MSG_ATMOSPHERE,   // Flavor text
    MSG_ROUND_ALERT,  // Round start messages
    MSG_RESTRICTION   // Weapon restriction notices
}

// Implemented as:
new const g_szWelcomeMessages[][] = {
    "Welcome to DUST2 ENHANCED, %s!",
    "The desert awaits, %s. Enhanced features active.",
    // ... more messages
}

new const g_szTipMessages[][] = {
    "💡 Smoke Xbox to safely cross Mid to B",
    // ... more tips
}

// Message selection uses random index within array bounds
```

### HUD Configuration Model

```pawn
// HUD display parameters for each zone

struct HudZone {
    x: float (-1.0 to 1.0)       // Horizontal position
    y: float (-1.0 to 1.0)       // Vertical position
    channel: integer (1-4)       // HUD channel (prevents overlap)
    color: RGB (r, g, b)         // Text color
    holdtime: float              // Display duration in seconds
    effect: integer              // Visual effect (0=none, 1=fade, 2=flash)
}

// Predefined zones:
const Float:HUD_STATUS_X = 0.02      // Left side
const Float:HUD_STATUS_Y = 0.25      // Upper-middle
const HUD_STATUS_CHANNEL = 1

const Float:HUD_ROUND_X = -1.0       // Center (auto)
const Float:HUD_ROUND_Y = 0.15       // Top
const HUD_ROUND_CHANNEL = 2

const Float:HUD_MESSAGE_X = -1.0     // Center (auto)
const Float:HUD_MESSAGE_Y = 0.75     // Bottom
const HUD_MESSAGE_CHANNEL = 3
```

### Bonus Model

```pawn
// Spawn bonus configuration

enum BonusType {
    BONUS_HEALTH,
    BONUS_ARMOR
}

struct BonusConfig {
    type: BonusType
    amount: integer              // Bonus amount to add
    max_value: integer           // Maximum allowed value
    probability: float (0-1)     // Chance of this bonus type
}

// Implemented as constants:
const BONUS_HEALTH_AMOUNT = 10
const BONUS_HEALTH_MAX = 110
const BONUS_ARMOR_AMOUNT = 10
const BONUS_ARMOR_MAX = 100
const Float:BONUS_PROBABILITY = 0.5  // 50% each type
```



## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Map Name Detection Accuracy

For any map name string, the map detection function should return true if and only if the string matches "de_dust2" (case-insensitive), and false for all other map names.

**Validates: Requirements 1.1**

### Property 2: Welcome Message Personalization

For any valid player name, the generated welcome message should contain that exact player name as a substring.

**Validates: Requirements 2.2**

### Property 3: Round Start Message Variety

For any sequence of N round start message requests where N > 1, at least two different messages should be returned (messages should vary, not repeat the same message every time).

**Validates: Requirements 3.2**

### Property 4: Spawn Bonus Application

For any valid player spawn event where the player is alive, either a health bonus or armor bonus should be applied (never neither, never both).

**Validates: Requirements 4.2**

### Property 5: Bonus Cap Enforcement

For any player state and any bonus application (health or armor), the resulting player stats should never exceed the defined maximums (110 HP for health, 100 for armor).

**Validates: Requirements 4.3, 4.4**

### Property 6: Living Player Bonus Restriction

For any player state where the player is not alive (dead or invalid), applying the spawn bonus function should result in no changes to player stats.

**Validates: Requirements 4.5**

### Property 7: Weapon Restriction Consistency

For any restricted weapon and any player (regardless of team affiliation), purchase attempts should be blocked with the same restriction logic.

**Validates: Requirements 5.2, 5.4**

### Property 8: Restriction Message Generation

For any blocked weapon purchase attempt, an informative message should be generated explaining the restriction.

**Validates: Requirements 5.3**

### Property 9: HUD Content Completeness

For any alive player with valid health, armor, and team values, the generated HUD status string should contain all three pieces of information (health value, armor value, and team identifier).

**Validates: Requirements 6.1, 6.2, 6.3**

### Property 10: Message Timing Variance

For any sequence of message display intervals, there should be variance in timing (not all intervals identical), with intervals falling within the acceptable range (45-60 seconds).

**Validates: Requirements 7.3**

### Property 11: Player Index Validation

For any player index value, the validation function should return true if and only if the index is within valid bounds (1-32) and the player slot is occupied.

**Validates: Requirements 10.3**

### Property 12: Invalid Player Safety

For any invalid player index (out of bounds or unoccupied slot), all player-specific operations should be safely skipped without attempting data access or modification.

**Validates: Requirements 10.1, 10.5**



## Error Handling

### Error Categories and Strategies

#### 1. Invalid Player Index Errors

**Scenario**: Functions receive player IDs outside valid range (1-32) or for disconnected players

**Strategy**:
```pawn
// Validation function used before all player operations
bool:is_valid_player(player_id) {
    if (player_id < 1 || player_id > 32)
        return false
    
    if (!is_user_connected(player_id))
        return false
    
    return true
}

// Usage pattern in all player-specific functions
public update_player_hud(player_id) {
    if (!is_valid_player(player_id))
        return  // Silent fail, no error message
    
    // Safe to proceed with player operations
}
```

**Rationale**: Silent failure prevents console spam while ensuring stability. Invalid indices are expected during normal operation (player disconnects, map changes).

#### 2. Map Detection Failures

**Scenario**: Unable to retrieve map name or unexpected map name format

**Strategy**:
```pawn
public plugin_cfg() {
    new mapname[32]
    get_mapname(mapname, charsmax(mapname))
    
    // Default to disabled if map name retrieval fails
    if (strlen(mapname) == 0) {
        g_bIsDust2 = false
        log_amx("Dust2 Plugin: Unable to detect map name, features disabled")
        return
    }
    
    // Case-insensitive comparison
    g_bIsDust2 = equali(mapname, "de_dust2")
}
```

**Rationale**: Fail-safe approach disables features rather than risk incorrect activation. Logging provides admin visibility.

#### 3. HUD Display Errors

**Scenario**: HUD message parameters invalid or display fails

**Strategy**:
```pawn
public show_hud_message(player_id, const message[]) {
    if (!is_valid_player(player_id))
        return
    
    // Validate message content
    if (strlen(message) == 0)
        return
    
    // Set HUD parameters with safe defaults
    set_hudmessage(
        0, 255, 0,      // Color (green)
        0.02, 0.25,     // Position (validated safe zone)
        0,              // Effect
        0.0, 1.0,       // Fade in/out
        0.1             // Hold time (minimum)
    )
    
    // Display with error suppression
    show_hudmessage(player_id, message)
}
```

**Rationale**: Defensive parameter validation prevents malformed HUD calls. Safe defaults ensure visibility even if configuration is incorrect.

#### 4. Bonus Application Errors

**Scenario**: Player state invalid when applying spawn bonuses

**Strategy**:
```pawn
public apply_spawn_bonus(player_id) {
    // Multi-layer validation
    if (!is_valid_player(player_id))
        return
    
    if (!is_user_alive(player_id))
        return
    
    // Get current stats with bounds checking
    new health = get_user_health(player_id)
    new armor = get_user_armor(player_id)
    
    // Validate retrieved values are sane
    if (health < 0 || health > 255)
        return
    
    if (armor < 0 || armor > 255)
        return
    
    // Apply bonus with cap enforcement
    new bool:apply_health = (random(2) == 0)
    
    if (apply_health && health < 100) {
        new new_health = min(health + BONUS_HEALTH_AMOUNT, BONUS_HEALTH_MAX)
        set_user_health(player_id, new_health)
    }
    else if (!apply_health && armor < 100) {
        new new_armor = min(armor + BONUS_ARMOR_AMOUNT, BONUS_ARMOR_MAX)
        set_user_armor(player_id, new_armor)
    }
}
```

**Rationale**: Multiple validation layers prevent edge cases. Sanity checks on retrieved values protect against game engine anomalies.

#### 5. Timer and Event Errors

**Scenario**: Timers fire after map change or plugin unload

**Strategy**:
```pawn
public message_timer() {
    // Check plugin still active
    if (!g_bIsDust2)
        return
    
    // Validate timer handle
    if (g_hMessageTimer == 0)
        return
    
    // Perform timer action
    show_message_rotation()
    
    // Re-schedule with randomization
    new Float:next_interval = random_float(45.0, 60.0)
    set_task(next_interval, "message_timer")
}

public plugin_end() {
    // Clean up all timers
    if (g_hHudTimer != 0)
        remove_task(g_hHudTimer)
    
    if (g_hMessageTimer != 0)
        remove_task(g_hMessageTimer)
    
    // Reset handles
    g_hHudTimer = 0
    g_hMessageTimer = 0
}
```

**Rationale**: State checks prevent timer actions on wrong map. Proper cleanup prevents orphaned timers.

#### 6. Weapon Restriction Errors

**Scenario**: Weapon purchase event with invalid weapon ID

**Strategy**:
```pawn
public event_weapon_purchase(player_id) {
    if (!g_bIsDust2)
        return PLUGIN_CONTINUE
    
    if (!is_valid_player(player_id))
        return PLUGIN_CONTINUE
    
    new weapon_id = read_data(1)  // Get weapon from event
    
    // Validate weapon ID is in expected range
    if (weapon_id < 0 || weapon_id > CSW_P90)
        return PLUGIN_CONTINUE
    
    // Check restriction
    if (weapon_id == CSW_AWP) {
        // Block and notify
        client_print(player_id, print_center, "🚫 AWP restricted")
        return PLUGIN_HANDLED  // Block purchase
    }
    
    return PLUGIN_CONTINUE  // Allow purchase
}
```

**Rationale**: Bounds checking on weapon IDs prevents array access errors. Graceful fallback allows purchase if validation fails.

### Error Logging Strategy

- **Critical Errors**: Log to AMX log file with `log_amx()`
- **Debug Information**: Use `log_to_file()` for detailed debugging (disabled in production)
- **Player Notifications**: Use `client_print()` for user-facing errors only
- **Silent Failures**: Most validation failures are silent to avoid console spam

### Recovery Mechanisms

1. **State Reset on Map Change**: All player tracking arrays cleared
2. **Timer Restart**: Timers re-initialized on map detection
3. **Graceful Degradation**: Individual feature failures don't crash entire plugin
4. **Validation Gates**: All public functions validate inputs before processing



## Testing Strategy

### Dual Testing Approach

This plugin requires both unit testing and property-based testing to ensure comprehensive correctness:

- **Unit Tests**: Verify specific examples, edge cases, and integration points
- **Property Tests**: Verify universal properties across randomized inputs

Together, these approaches provide complementary coverage: unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across the input space.

### Property-Based Testing

**Framework**: We'll use **PropCheck** (a property-based testing library for Pawn/AMX Mod X) or implement a lightweight property testing harness using AMX Mod X's built-in random functions.

**Configuration**:
- Minimum 100 iterations per property test (due to randomization)
- Each test tagged with comment referencing design property
- Tag format: `// Feature: dust2-enhancement-plugin, Property {N}: {property text}`

**Property Test Suite**:

1. **Map Detection Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 1: Map Name Detection Accuracy
   test_map_detection_property() {
       // Generate 100 random map names
       for (new i = 0; i < 100; i++) {
           new mapname[32]
           generate_random_mapname(mapname, charsmax(mapname))
           
           new bool:result = is_dust2_map(mapname)
           new bool:expected = equali(mapname, "de_dust2")
           
           assert_equal(result, expected)
       }
       
       // Explicitly test de_dust2 variants
       assert_true(is_dust2_map("de_dust2"))
       assert_true(is_dust2_map("DE_DUST2"))
       assert_true(is_dust2_map("De_DuSt2"))
   }
   ```

2. **Welcome Message Personalization Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 2: Welcome Message Personalization
   test_welcome_message_contains_name() {
       for (new i = 0; i < 100; i++) {
           new playername[32]
           generate_random_playername(playername, charsmax(playername))
           
           new message[256]
           format_welcome_message(message, charsmax(message), playername)
           
           // Message must contain the player name
           assert_true(containi(message, playername) != -1)
       }
   }
   ```

3. **Round Message Variety Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 3: Round Start Message Variety
   test_round_messages_vary() {
       new messages[10][128]
       new unique_count = 0
       
       // Get 10 messages
       for (new i = 0; i < 10; i++) {
           get_random_round_message(messages[i], charsmax(messages[]))
       }
       
       // Count unique messages
       for (new i = 0; i < 10; i++) {
           new bool:is_unique = true
           for (new j = 0; j < i; j++) {
               if (equal(messages[i], messages[j])) {
                   is_unique = false
                   break
               }
           }
           if (is_unique) unique_count++
       }
       
       // Must have at least 2 different messages
       assert_true(unique_count >= 2)
   }
   ```

4. **Spawn Bonus Application Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 4: Spawn Bonus Application
   test_spawn_bonus_always_applied() {
       for (new i = 0; i < 100; i++) {
           new PlayerState:state
           generate_random_player_state(state)
           state.alive = true  // Ensure alive
           
           new health_before = state.health
           new armor_before = state.armor
           
           apply_spawn_bonus_to_state(state)
           
           // Either health or armor should have changed (if not at cap)
           new bool:health_changed = (state.health != health_before)
           new bool:armor_changed = (state.armor != armor_before)
           new bool:health_at_cap = (health_before >= 100)
           new bool:armor_at_cap = (armor_before >= 100)
           
           // If not at caps, something should change
           if (!health_at_cap || !armor_at_cap) {
               assert_true(health_changed || armor_changed)
           }
       }
   }
   ```

5. **Bonus Cap Enforcement Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 5: Bonus Cap Enforcement
   test_bonus_caps_enforced() {
       for (new i = 0; i < 100; i++) {
           new PlayerState:state
           generate_random_player_state(state)
           state.alive = true
           
           // Apply bonus multiple times
           for (new j = 0; j < 5; j++) {
               apply_spawn_bonus_to_state(state)
           }
           
           // Caps must never be exceeded
           assert_true(state.health <= 110)
           assert_true(state.armor <= 100)
       }
   }
   ```

6. **Dead Player Bonus Restriction Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 6: Living Player Bonus Restriction
   test_dead_players_no_bonus() {
       for (new i = 0; i < 100; i++) {
           new PlayerState:state
           generate_random_player_state(state)
           state.alive = false  // Ensure dead
           
           new health_before = state.health
           new armor_before = state.armor
           
           apply_spawn_bonus_to_state(state)
           
           // Nothing should change
           assert_equal(state.health, health_before)
           assert_equal(state.armor, armor_before)
       }
   }
   ```

7. **Weapon Restriction Consistency Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 7: Weapon Restriction Consistency
   test_weapon_restriction_team_agnostic() {
       for (new i = 0; i < 100; i++) {
           new team_t_result = is_weapon_allowed(CSW_AWP, TEAM_T)
           new team_ct_result = is_weapon_allowed(CSW_AWP, TEAM_CT)
           
           // Both teams should get same result
           assert_equal(team_t_result, team_ct_result)
       }
   }
   ```

8. **HUD Content Completeness Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 9: HUD Content Completeness
   test_hud_contains_all_stats() {
       for (new i = 0; i < 100; i++) {
           new PlayerState:state
           generate_random_player_state(state)
           state.alive = true
           
           new hud_text[256]
           format_status_hud(hud_text, charsmax(hud_text), state)
           
           // Must contain health value
           new health_str[16]
           num_to_str(state.health, health_str, charsmax(health_str))
           assert_true(containi(hud_text, health_str) != -1)
           
           // Must contain armor value
           new armor_str[16]
           num_to_str(state.armor, armor_str, charsmax(armor_str))
           assert_true(containi(hud_text, armor_str) != -1)
           
           // Must contain team indicator (CT or T)
           new bool:has_team = (containi(hud_text, "CT") != -1 || 
                                containi(hud_text, "T") != -1)
           assert_true(has_team)
       }
   }
   ```

9. **Player Index Validation Property Test**
   ```pawn
   // Feature: dust2-enhancement-plugin, Property 11: Player Index Validation
   test_player_validation_bounds() {
       // Test invalid indices
       for (new i = -10; i < 0; i++) {
           assert_false(is_valid_player(i))
       }
       for (new i = 33; i < 50; i++) {
           assert_false(is_valid_player(i))
       }
       
       // Valid range (1-32) depends on connection status
       // This is tested in integration tests
   }
   ```

10. **Invalid Player Safety Property Test**
    ```pawn
    // Feature: dust2-enhancement-plugin, Property 12: Invalid Player Safety
    test_invalid_player_operations_safe() {
        for (new i = 0; i < 100; i++) {
            new invalid_id = random_num(-10, 0)  // Invalid index
            
            // These should all complete without crashing
            update_status_hud(invalid_id)
            apply_spawn_bonus(invalid_id)
            show_welcome_message(invalid_id)
            
            // If we reach here, no crash occurred
            assert_true(true)
        }
    }
    ```

### Unit Testing

**Framework**: AMX Mod X test harness or custom test runner

**Unit Test Suite**:

1. **Map Detection Examples**
   - Test exact match: "de_dust2" → true
   - Test case insensitivity: "DE_DUST2", "De_Dust2" → true
   - Test other maps: "de_dust", "de_dust2_long", "cs_office" → false
   - Test empty string → false

2. **Welcome Message Content**
   - Verify message contains "DUST2 ENHANCED"
   - Verify message contains "enhanced" or "features active"
   - Test with special characters in player names

3. **HUD Positioning**
   - Verify status panel X coordinate = 0.02 (left side)
   - Verify round alert X coordinate = -1.0 (centered)
   - Verify message zone Y coordinate = 0.75 (bottom)
   - Verify all coordinates within valid range (-1.0 to 1.0)

4. **HUD Update Interval**
   - Verify timer interval <= 1.0 seconds
   - Test timer initialization on map load
   - Test timer cleanup on map change

5. **Message Array Sizes**
   - Verify tip messages array length >= 5
   - Verify atmosphere messages array length >= 5
   - Verify round alert messages array length >= 3

6. **Weapon Restriction List**
   - Verify AWP (CSW_AWP) is in restricted list
   - Verify restriction list is non-empty
   - Test restriction message generation for AWP

7. **Bonus Constants**
   - Verify BONUS_HEALTH_AMOUNT = 10
   - Verify BONUS_HEALTH_MAX = 110
   - Verify BONUS_ARMOR_AMOUNT = 10
   - Verify BONUS_ARMOR_MAX = 100

8. **Plugin Metadata**
   - Verify PLUGIN_NAME is defined and non-empty
   - Verify PLUGIN_VERSION is defined
   - Verify PLUGIN_AUTHOR is defined

9. **Standard Includes Only**
   - Verify only standard AMX Mod X includes used:
     - amxmodx
     - amxmisc
     - fakemeta (if needed)
   - No custom or external dependencies

10. **Edge Cases**
    - Player with 100 HP receives health bonus → stays at 100
    - Player with 105 HP receives health bonus → capped at 110
    - Player with 100 armor receives armor bonus → stays at 100
    - Empty map name → features disabled
    - Null player name → welcome message handles gracefully

### Integration Testing

**Manual Testing Checklist**:

1. Install plugin on test server
2. Load de_dust2 map
3. Verify welcome message on join
4. Verify HUD status panel appears and updates
5. Verify round start messages appear
6. Verify spawn bonuses applied (check HP/armor)
7. Attempt to buy AWP → verify blocked with message
8. Wait for periodic tips/atmosphere messages
9. Change to different map → verify features disabled
10. Change back to de_dust2 → verify features re-enabled

**Performance Testing**:
- Monitor server FPS with 32 players
- Check CPU usage during HUD updates
- Verify no memory leaks over extended play sessions
- Test with multiple map changes

### Test Coverage Goals

- **Property Tests**: 100% coverage of universal properties (12 properties)
- **Unit Tests**: 100% coverage of configuration values and edge cases
- **Integration Tests**: Manual verification of all user-facing features
- **Overall**: Aim for 90%+ code coverage with automated tests



## Implementation Notes

### Code Organization

The single `.sma` file should be organized into clearly commented sections:

```pawn
/*
 * Dust2 Enhancement Plugin
 * Enhances de_dust2 gameplay with HUD, messages, bonuses, and restrictions
 */

// ============================================================================
// INCLUDES
// ============================================================================
#include <amxmodx>
#include <amxmisc>
#include <fun>

// ============================================================================
// PLUGIN METADATA
// ============================================================================
#define PLUGIN_NAME    "Dust2 Enhancement"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR  "YourName"

// ============================================================================
// CONSTANTS AND CONFIGURATION
// ============================================================================
// Bonus configuration
// HUD configuration
// Message arrays

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================
// State tracking
// Player data arrays
// Timer handles

// ============================================================================
// PLUGIN INITIALIZATION
// ============================================================================
public plugin_init() { }
public plugin_cfg() { }
public plugin_end() { }

// ============================================================================
// MAP DETECTION
// ============================================================================
// Map name checking functions

// ============================================================================
// EVENT HANDLERS
// ============================================================================
// Player join, spawn, death
// Round start
// Weapon purchase

// ============================================================================
// HUD SYSTEM
// ============================================================================
// Status panel
// Round alerts
// Message rotation

// ============================================================================
// SPAWN BONUS SYSTEM
// ============================================================================
// Bonus application
// Cap enforcement

// ============================================================================
// WEAPON RESTRICTION SYSTEM
// ============================================================================
// Purchase blocking
// Restriction messages

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
// Player validation
// Random selection
// String formatting
```

### Performance Optimizations

1. **Minimize HUD Updates**:
   - Update status HUD only once per second (not every frame)
   - Cache player stats to detect changes before updating
   - Use separate HUD channels to avoid conflicts

2. **Efficient String Operations**:
   - Pre-format static message parts
   - Use `formatex()` instead of `format()` where possible
   - Avoid unnecessary string copies

3. **Smart Event Handling**:
   - Check `g_bIsDust2` flag first in all event handlers (early exit)
   - Validate player indices before any operations
   - Use `PLUGIN_CONTINUE` vs `PLUGIN_HANDLED` appropriately

4. **Timer Management**:
   - Use single timer for HUD updates (not per-player timers)
   - Randomize message timer to avoid predictable spikes
   - Clean up timers properly on map change

### Pawn Language Best Practices

1. **Array Indexing**:
   - Player arrays sized [33] (index 0 unused, 1-32 for players)
   - Always validate index before access
   - Use `charsmax()` for string buffer sizes

2. **Boolean Handling**:
   - Use `bool:` tag for boolean variables
   - Use `true`/`false` constants (not 1/0)
   - Explicit boolean comparisons in conditions

3. **Function Naming**:
   - Public functions: `public event_name()`
   - Helper functions: `descriptive_action_name()`
   - Validation functions: `is_valid_*()` or `check_*()` returning bool

4. **Memory Management**:
   - No dynamic allocation needed (use fixed arrays)
   - Clear arrays on map change
   - Remove tasks/timers on plugin end

### Creative Implementation Details

1. **HUD Color Dynamics**:
   ```pawn
   // Health-based color coding
   stock get_health_color(health, &r, &g, &b) {
       if (health > 75) {
           r = 0; g = 255; b = 0  // Green
       }
       else if (health > 40) {
           r = 255; g = 255; b = 0  // Yellow
       }
       else {
           r = 255; g = 0; b = 0  // Red
       }
   }
   ```

2. **Message Rotation Logic**:
   ```pawn
   // Alternate between tips and atmosphere
   public message_timer() {
       if (!g_bIsDust2) return
       
       new message[128]
       if (g_bShowTip) {
           get_random_tip(message, charsmax(message))
       }
       else {
           get_random_atmosphere(message, charsmax(message))
       }
       
       g_bShowTip = !g_bShowTip  // Toggle for next time
       
       // Display to all players
       client_print(0, print_chat, message)
       
       // Schedule next with randomization
       set_task(random_float(45.0, 60.0), "message_timer")
   }
   ```

3. **Spawn Bonus Randomization**:
   ```pawn
   // Fair 50/50 distribution
   public apply_spawn_bonus(player_id) {
       if (!is_valid_player(player_id)) return
       if (!is_user_alive(player_id)) return
       
       new health = get_user_health(player_id)
       new armor = get_user_armor(player_id)
       
       // Random selection
       if (random(2) == 0) {
           // Health bonus
           if (health < 100) {
               set_user_health(player_id, min(health + 10, 110))
               show_bonus_hud(player_id, "⚡ +10 HP • Desert Blessing")
           }
       }
       else {
           // Armor bonus
           if (armor < 100) {
               set_user_armor(player_id, min(armor + 10, 100))
               show_bonus_hud(player_id, "⚡ +10 Armor • Fortified")
           }
       }
   }
   ```

4. **Round Alert Variety**:
   ```pawn
   // Context-aware round messages
   public show_round_alert() {
       new round_num = get_round_number()
       new message[128]
       
       if (round_num == 1) {
           message = "🏜️ DUST2 ENHANCED • Round 1 • Secure Long A!"
       }
       else if (round_num % 5 == 0) {
           formatex(message, charsmax(message), 
                    "⚔️ Round %d • Every Position Counts!", round_num)
       }
       else {
           new const tactics[][] = {
               "Fight for Mid Control",
               "B Rush or Fake?",
               "Control Catwalk",
               "Long A Awaits"
           }
           formatex(message, charsmax(message), 
                    "🏜️ DUST2 ENHANCED • Round %d • %s", 
                    round_num, tactics[random(sizeof(tactics))])
       }
       
       // Display to all
       set_hudmessage(0, 255, 255, -1.0, 0.15, 0, 0.0, 5.0, 0.1, 0.1, 2)
       show_hudmessage(0, message)
   }
   ```

### Installation and Deployment

1. **File Structure**:
   ```
   addons/amxmodx/
   ├── plugins/
   │   └── dust2_enhancement.amxx  (compiled binary)
   └── scripting/
       └── dust2_enhancement.sma   (source code)
   ```

2. **Configuration** (`plugins.ini`):
   ```
   dust2_enhancement.amxx
   ```

3. **Compilation**:
   ```bash
   amxxpc dust2_enhancement.sma
   ```

4. **Server Restart**:
   - Restart server or use `amx_reloadadmins` command
   - Change map to de_dust2 to activate features

### Future Enhancement Possibilities

While not in current scope, these could be added later:

1. **Admin Configuration**:
   - CVAR for enabling/disabling individual features
   - Configurable bonus amounts
   - Customizable message arrays via external file

2. **Statistics Tracking**:
   - Track player performance on Dust2
   - Leaderboards for Dust2-specific stats
   - Achievement system

3. **Advanced HUD**:
   - Mini-map indicators
   - Teammate status display
   - Objective timers

4. **Sound Effects**:
   - Audio cues for bonuses
   - Atmospheric desert sounds
   - Custom round start sounds

5. **Multi-Map Support**:
   - Extend to other classic maps (de_inferno, de_nuke)
   - Map-specific customizations
   - Unified configuration system

---

## Summary

This design delivers a polished, engaging Dust2 enhancement experience through:

- **Adaptive HUD System**: Multi-zone display with health-based color coding and contextual information
- **Dynamic Messaging**: 20+ unique messages (tips + atmosphere) with intelligent rotation
- **Smart Spawn Bonuses**: Balanced +10 HP/Armor system with proper caps
- **Strategic Weapon Restrictions**: AWP restriction with informative messaging
- **Robust Error Handling**: Comprehensive validation and graceful degradation
- **Clean Architecture**: Single-file implementation with clear organization
- **Comprehensive Testing**: Property-based and unit tests for correctness

The plugin activates exclusively on de_dust2, requires no external dependencies, and maintains high performance even with 32 players. The creative use of Unicode icons, color-coded HUD elements, and Dust2-specific flavor text creates an immersive experience that enhances the classic map without modifying game files.

