# Implementation Plan: Dust2 Enhancement Plugin

## Overview

This plan breaks down the implementation of a Counter-Strike 1.6 AMX Mod X plugin that enhances the de_dust2 map experience. The plugin will be delivered as a single `.sma` source file containing map detection, HUD systems, spawn bonuses, weapon restrictions, and atmospheric messaging. Tasks are organized to build incrementally, with early validation through property-based tests.

## Tasks

- [x] 1. Set up plugin structure and core systems
  - [x] 1.1 Create plugin file with metadata and includes
    - Create `dust2_enhancement.sma` file
    - Add AMX Mod X includes (amxmodx, amxmisc, fun)
    - Define plugin metadata (name, version, author, description)
    - Set up code organization sections with comments
    - _Requirements: 8.4, 9.1, 9.3_

  - [x] 1.2 Implement map detection system
    - Create `plugin_cfg()` function to detect current map
    - Implement `is_dust2_active()` helper function
    - Add global state variable `g_bIsDust2` for activation flag
    - Use case-insensitive comparison for "de_dust2"
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [ ]* 1.3 Write property test for map detection
    - **Property 1: Map Name Detection Accuracy**
    - **Validates: Requirements 1.1**
    - Test with random map names and de_dust2 variants
    - Verify case-insensitive matching

  - [x] 1.4 Implement player validation system
    - Create `is_valid_player()` function with bounds checking (1-32)
    - Add connection status validation using `is_user_connected()`
    - _Requirements: 10.3, 10.5_

  - [ ]* 1.5 Write property test for player validation
    - **Property 11: Player Index Validation**
    - **Validates: Requirements 10.3**
    - Test invalid indices (negative, zero, >32)
    - Verify valid range handling

- [x] 2. Implement player welcome system
  - [x] 2.1 Create welcome message handler
    - Register `client_putinserver()` event in `plugin_init()`
    - Implement `show_welcome_message()` function
    - Create welcome message array with 3+ variants
    - Format messages with player name using `get_user_name()`
    - Display via `client_print()` within 2 seconds of connection
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [ ]* 2.2 Write property test for welcome message personalization
    - **Property 2: Welcome Message Personalization**
    - **Validates: Requirements 2.2**
    - Test with random player names
    - Verify name appears in generated message

- [x] 3. Implement HUD status panel system
  - [x] 3.1 Create status panel data structures
    - Define HUD position constants (HUD_STATUS_X = 0.02, HUD_STATUS_Y = 0.25)
    - Define HUD channel constant (HUD_STATUS_CHANNEL = 1)
    - Create player state tracking arrays (health, armor, team, alive status)
    - _Requirements: 6.5_

  - [x] 3.2 Implement status HUD update function
    - Create `update_status_hud()` function with player validation
    - Get player health, armor, and team using AMX functions
    - Implement health-based color coding (green >75, yellow 40-75, red <40)
    - Format HUD text with Unicode icons (❤️ health, 🛡️ armor, 👥 team)
    - Use `set_hudmessage()` and `show_hudmessage()` for display
    - _Requirements: 6.1, 6.2, 6.3, 6.5_

  - [x] 3.3 Set up HUD update timer
    - Create timer in `plugin_cfg()` when dust2 is active
    - Call `update_status_hud()` for all players every 1 second
    - Store timer handle in global variable
    - Clean up timer in `plugin_end()` and on map change
    - _Requirements: 6.4, 10.2_

  - [ ]* 3.4 Write property test for HUD content completeness
    - **Property 9: HUD Content Completeness**
    - **Validates: Requirements 6.1, 6.2, 6.3**
    - Test with random player states
    - Verify HUD contains health, armor, and team values

  - [ ]* 3.5 Write unit tests for HUD positioning
    - Test status panel coordinates (0.02, 0.25)
    - Verify HUD channel assignment (channel 1)
    - Test color coding logic for different health values

- [x] 4. Checkpoint - Verify core systems
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement round start notification system
  - [x] 5.1 Create round alert handler
    - Register round start event in `plugin_init()`
    - Define HUD position constants for round alerts (center top: -1.0, 0.15)
    - Create round message array with 5+ variants
    - Include round number and tactical hints in messages
    - _Requirements: 3.1, 3.3_

  - [x] 5.2 Implement round alert display function
    - Create `show_round_alert()` function
    - Format messages with round number and tactical context
    - Use HUD channel 2 with cyan color
    - Display for 5 seconds to all players (player_id = 0)
    - _Requirements: 3.2, 3.4_

  - [ ]* 5.3 Write property test for round message variety
    - **Property 3: Round Start Message Variety**
    - **Validates: Requirements 3.2**
    - Request 10 messages and count unique ones
    - Verify at least 2 different messages exist

- [x] 6. Implement spawn bonus system
  - [x] 6.1 Create spawn bonus configuration
    - Define bonus constants (BONUS_HEALTH_AMOUNT = 10, BONUS_HEALTH_MAX = 110)
    - Define armor constants (BONUS_ARMOR_AMOUNT = 10, BONUS_ARMOR_MAX = 100)
    - _Requirements: 4.3, 4.4_

  - [x] 6.2 Implement spawn event handler
    - Register spawn event in `plugin_init()`
    - Create `apply_spawn_bonus()` function with player validation
    - Check player is alive before applying bonus
    - _Requirements: 4.1, 4.5_

  - [x] 6.3 Implement bonus application logic
    - Use `random(2)` for 50/50 health vs armor selection
    - Get current health/armor using `get_user_health()` and `get_user_armor()`
    - Apply +10 bonus with cap enforcement using `min()` function
    - Set new values using `set_user_health()` and `set_user_armor()`
    - _Requirements: 4.2, 4.3, 4.4_

  - [x] 6.4 Add bonus notification HUD
    - Create `show_bonus_notification()` function
    - Display brief message (2 seconds) in HUD channel 4
    - Use green color for health, blue for armor
    - Include Unicode icon (⚡) and bonus type
    - _Requirements: 4.2_

  - [ ]* 6.5 Write property test for spawn bonus application
    - **Property 4: Spawn Bonus Application**
    - **Validates: Requirements 4.2**
    - Test with random player states (alive)
    - Verify either health or armor changes (if not at cap)

  - [ ]* 6.6 Write property test for bonus cap enforcement
    - **Property 5: Bonus Cap Enforcement**
    - **Validates: Requirements 4.3, 4.4**
    - Apply bonuses multiple times
    - Verify health never exceeds 110, armor never exceeds 100

  - [ ]* 6.7 Write property test for dead player bonus restriction
    - **Property 6: Living Player Bonus Restriction**
    - **Validates: Requirements 4.5**
    - Test with dead player states
    - Verify no stat changes occur

- [x] 7. Implement weapon restriction system
  - [x] 7.1 Create weapon restriction handler
    - Register weapon purchase event in `plugin_init()`
    - Create `event_weapon_purchase()` function
    - Add weapon ID validation (bounds checking)
    - _Requirements: 5.1, 10.4_

  - [x] 7.2 Implement AWP restriction logic
    - Check if weapon ID equals CSW_AWP
    - Return PLUGIN_HANDLED to block purchase
    - Return PLUGIN_CONTINUE to allow other weapons
    - Apply restriction equally to both teams
    - _Requirements: 5.2, 5.4_

  - [x] 7.3 Create restriction notification messages
    - Define array of 5+ restriction messages
    - Implement `show_restriction_message()` function
    - Select random message from array
    - Display via `client_print()` with print_center
    - _Requirements: 5.3_

  - [ ]* 7.4 Write property test for weapon restriction consistency
    - **Property 7: Weapon Restriction Consistency**
    - **Validates: Requirements 5.2, 5.4**
    - Test AWP restriction for both teams
    - Verify same result regardless of team

  - [ ]* 7.5 Write property test for restriction message generation
    - **Property 8: Restriction Message Generation**
    - **Validates: Requirements 5.3**
    - Test blocked purchase attempts
    - Verify informative message is generated

- [x] 8. Checkpoint - Verify gameplay systems
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Implement message engine with tips and atmosphere
  - [x] 9.1 Create message content arrays
    - Define tactical tips array with 10+ unique messages
    - Include Dust2-specific callouts (Long A, Catwalk, B Tunnels, Xbox, etc.)
    - Define atmospheric flavor array with 10+ unique messages
    - Use Unicode icons (💡 for tips, 🏜️ for atmosphere)
    - _Requirements: 7.1, 7.2, 7.4, 7.5_

  - [x] 9.2 Implement message rotation system
    - Create `message_timer()` function
    - Add global state for alternating tips/atmosphere
    - Implement `get_random_message()` helper for array selection
    - Display messages via `client_print()` to all players
    - _Requirements: 7.1, 7.2_

  - [x] 9.3 Set up message timing with randomization
    - Initialize timer in `plugin_cfg()` when dust2 is active
    - Use `random_float(45.0, 60.0)` for interval variance
    - Schedule next message at end of timer function
    - Clean up timer on map change and plugin end
    - _Requirements: 7.3, 10.2_

  - [ ]* 9.4 Write property test for message timing variance
    - **Property 10: Message Timing Variance**
    - **Validates: Requirements 7.3**
    - Generate multiple intervals
    - Verify variance exists and intervals are within 45-60 second range

  - [ ]* 9.5 Write unit tests for message content
    - Verify tip array has at least 5 messages
    - Verify atmosphere array has at least 5 messages
    - Test random message selection function
    - Verify messages contain expected keywords

- [x] 10. Implement error handling and validation
  - [x] 10.1 Add player validation to all functions
    - Call `is_valid_player()` at start of all player-specific functions
    - Return early (silent fail) if validation fails
    - _Requirements: 10.3, 10.5_

  - [x] 10.2 Implement state management and cleanup
    - Create `plugin_init()` with event registration
    - Implement `plugin_cfg()` with map detection and timer initialization
    - Create `plugin_end()` with timer cleanup
    - Clear player tracking arrays on map change
    - _Requirements: 10.2_

  - [x] 10.3 Add error logging for critical failures
    - Use `log_amx()` for map detection failures
    - Log timer initialization issues
    - Add defensive checks for weapon ID bounds
    - _Requirements: 10.1, 10.4_

  - [ ]* 10.4 Write property test for invalid player safety
    - **Property 12: Invalid Player Safety**
    - **Validates: Requirements 10.1, 10.5**
    - Call functions with invalid player indices
    - Verify no crashes occur (operations complete safely)

  - [ ]* 10.5 Write unit tests for edge cases
    - Test player with 100 HP receiving health bonus (stays at 100)
    - Test player with 105 HP receiving health bonus (caps at 110)
    - Test empty map name handling (features disabled)
    - Test null/empty player name in welcome message

- [x] 11. Add code documentation and polish
  - [x] 11.1 Add comprehensive code comments
    - Document each major section with block comments
    - Add inline comments for complex logic
    - Explain magic numbers and constants
    - Document function parameters and return values
    - _Requirements: 8.1, 8.2_

  - [x] 11.2 Verify code organization and naming
    - Ensure sections follow design document structure
    - Verify descriptive variable names throughout
    - Check function naming conventions (public vs helper)
    - Validate boolean variable naming (bool: tag)
    - _Requirements: 8.2, 8.3_

  - [x] 11.3 Optimize performance
    - Verify early exit checks (g_bIsDust2 flag first)
    - Minimize string operations in hot paths
    - Use efficient HUD update patterns (1 second interval)
    - Validate timer cleanup prevents leaks
    - _Requirements: 10.4_

- [x] 12. Final integration and validation
  - [x] 12.1 Verify single file delivery
    - Confirm all code in single `.sma` file
    - Verify only standard AMX Mod X includes used
    - Check no external dependencies required
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 12.2 Create compilation and installation instructions
    - Document compilation command (`amxxpc dust2_enhancement.sma`)
    - Provide file structure for installation
    - Document `plugins.ini` configuration line
    - Add server restart instructions
    - _Requirements: 9.4_

  - [ ]* 12.3 Run full test suite
    - Execute all property-based tests (100+ iterations each)
    - Run all unit tests
    - Verify test coverage meets 90% goal
    - Document any test failures for investigation

- [x] 13. Final checkpoint - Complete validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Property tests validate universal correctness across randomized inputs
- Unit tests validate specific examples and edge cases
- The plugin is a single `.sma` file for AMX Mod X (Counter-Strike 1.6)
- All features activate only when the map is de_dust2
- Checkpoints ensure incremental validation at logical breaks
