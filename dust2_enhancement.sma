/*
 * ============================================================================
 * Dust2 Enhancement Plugin
 * ============================================================================
 * 
 * Description:
 *   Enhances de_dust2 gameplay with HUD displays, spawn bonuses, weapon
 *   restrictions, and atmospheric messages. Features activate only on de_dust2.
 * 
 * Author: CS 1.6 Community
 * Version: 1.0.0
 * 
 * ============================================================================
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
#define PLUGIN_AUTHOR  "CS 1.6 Community"

// ============================================================================
// CONSTANTS AND CONFIGURATION
// ============================================================================

// Bonus configuration
#define BONUS_HEALTH_AMOUNT 10
#define BONUS_HEALTH_MAX    110
#define BONUS_ARMOR_AMOUNT  10
#define BONUS_ARMOR_MAX     100

// HUD configuration - Status Panel (Left Side)
#define HUD_STATUS_X       0.02
#define HUD_STATUS_Y       0.25
#define HUD_STATUS_CHANNEL 1

// HUD configuration - Round Alert (Top Center)
#define HUD_ROUND_X       -1.0
#define HUD_ROUND_Y       0.15
#define HUD_ROUND_CHANNEL 2

// HUD configuration - Message Zone (Bottom Center)
#define HUD_MESSAGE_X       -1.0
#define HUD_MESSAGE_Y       0.75
#define HUD_MESSAGE_CHANNEL 3

// HUD configuration - Bonus Notification
#define HUD_BONUS_CHANNEL 4

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

// Plugin activation state
new bool:g_bIsDust2 = false

// Player tracking arrays (index 0 unused, 1-32 for players)
new g_iPlayerHealth[33]
new g_iPlayerArmor[33]
new bool:g_bPlayerAlive[33]
new g_iPlayerTeam[33]

// Message rotation state
new g_iMessageIndex = 0
new bool:g_bShowTip = true

// Timer handles
new g_hHudTimer = 0
new g_hMessageTimer = 0

// ============================================================================
// MESSAGE ARRAYS
// ============================================================================


// Welcome messages (personalized with player name)
new const g_szWelcomeMessages[][] = {
	"Welcome to DUST2 ENHANCED, %s!",
	"The desert awaits, %s. Enhanced features active.",
	"Prepare for tactical warfare with style, %s!"
}

// Tactical tips (Dust2-specific callouts)
new const g_szTipMessages[][] = {
	"^x04[TIP]^x01 Smoke Xbox to safely cross Mid to B",
	"^x04[TIP]^x01 Flash over Long Doors before peeking",
	"^x04[TIP]^x01 Listen for footsteps in B Tunnels",
	"^x04[TIP]^x01 Catwalk control = B site dominance",
	"^x04[TIP]^x01 AWP at Long A? Take Mid to B instead",
	"^x04[TIP]^x01 Boost on A platform for surprise angles",
	"^x04[TIP]^x01 Molotov CT spawn to delay rotations",
	"^x04[TIP]^x01 Check corners at A site - many hiding spots",
	"^x04[TIP]^x01 Coordinate pushes - don't peek alone",
	"^x04[TIP]^x01 Economy matters - save when behind"
}

// Atmospheric flavor messages
new const g_szAtmosphereMessages[][] = {
	"^x03[DUST2]^x01 The desert sun beats down on ancient stones",
	"^x03[DUST2]^x01 Dust swirls through the abandoned marketplace",
	"^x03[DUST2]^x01 Echoes of past battles linger in these walls",
	"^x03[DUST2]^x01 Long A stretches endlessly toward destiny",
	"^x03[DUST2]^x01 The tunnels hold secrets and danger",
	"^x03[DUST2]^x01 Catwalk sways gently in the desert wind",
	"^x03[DUST2]^x01 Double doors creak with anticipation",
	"^x03[DUST2]^x01 CT spawn: where legends begin their defense",
	"^x03[DUST2]^x01 T spawn: the staging ground for glory",
	"^x03[DUST2]^x01 Mid doors: the gateway to chaos"
}

// Round start messages
new const g_szRoundMessages[][] = {
	"DUST2 ENHANCED * Round %d * Secure Long A!",
	"DUST2 ENHANCED * Round %d * Fight for Mid Control!",
	"DUST2 ENHANCED * Round %d * B Rush or Fake?",
	"DUST2 ENHANCED * Round %d * Control Catwalk!",
	"DUST2 ENHANCED * Round %d * Every Position Counts!",
	"DUST2 ENHANCED * Round %d * Tactical Warfare Begins!"
}

// Weapon restriction messages
new const g_szRestrictionMessages[][] = {
	"AWP restricted - Master the AK/M4 instead!",
	"No AWP on this server - Rifle skills matter here",
	"AWP disabled - Keep the action fast-paced",
	"Snipers restricted - Try the Scout for long range",
	"AWP not available - Adapt your strategy"
}

// ============================================================================
// PLUGIN INITIALIZATION
// ============================================================================

public plugin_init() {
	// Register plugin
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	// Register events
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("ResetHUD", "event_player_spawn", "be")
	register_event("DeathMsg", "event_player_death", "a")
	
	// Register client connection
	register_clcmd("say", "cmd_say")
	register_clcmd("say_team", "cmd_say")
	
	// Log initialization
	log_amx("Dust2 Enhancement Plugin v%s initialized", PLUGIN_VERSION)
}

public plugin_cfg() {
	// Detect current map
	new mapname[32]
	get_mapname(mapname, charsmax(mapname))
	
	// Check if map name retrieval failed
	if (strlen(mapname) == 0) {
		g_bIsDust2 = false
		log_amx("Dust2 Plugin: Unable to detect map name, features disabled")
		return
	}
	
	// Case-insensitive comparison for de_dust2
	g_bIsDust2 = equali(mapname, "de_dust2")
	
	if (g_bIsDust2) {
		log_amx("Dust2 Plugin: de_dust2 detected, features enabled")
		
		// Start HUD update timer (every 1 second)
		g_hHudTimer = 1
		set_task(1.0, "timer_update_hud", g_hHudTimer, _, _, "b")
		
		// Start message rotation timer (45-60 seconds, randomized)
		g_hMessageTimer = 2
		new Float:first_interval = random_float(45.0, 60.0)
		set_task(first_interval, "timer_message_rotation", g_hMessageTimer)
		
		// Clear player tracking arrays
		for (new i = 1; i <= 32; i++) {
			g_iPlayerHealth[i] = 0
			g_iPlayerArmor[i] = 0
			g_bPlayerAlive[i] = false
			g_iPlayerTeam[i] = 0
		}
	} else {
		log_amx("Dust2 Plugin: Map is not de_dust2, features disabled")
		
		// Clean up any existing timers
		if (g_hHudTimer != 0) {
			remove_task(g_hHudTimer)
			g_hHudTimer = 0
		}
		if (g_hMessageTimer != 0) {
			remove_task(g_hMessageTimer)
			g_hMessageTimer = 0
		}
	}
}

public plugin_end() {
	// Clean up timers
	if (g_hHudTimer != 0) {
		remove_task(g_hHudTimer)
		g_hHudTimer = 0
	}
	if (g_hMessageTimer != 0) {
		remove_task(g_hMessageTimer)
		g_hMessageTimer = 0
	}
	
	log_amx("Dust2 Enhancement Plugin unloaded")
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Validate player index and connection status
stock bool:is_valid_player(player_id) {
	// Check bounds (1-32)
	if (player_id < 1 || player_id > 32)
		return false
	
	// Check if player is connected
	if (!is_user_connected(player_id))
		return false
	
	return true
}

// Check if plugin is active on de_dust2
stock bool:is_dust2_active() {
	return g_bIsDust2
}


// ============================================================================
// PLAYER WELCOME SYSTEM
// ============================================================================

public client_putinserver(player_id) {
	// Only show welcome on de_dust2
	if (!g_bIsDust2)
		return
	
	// Validate player
	if (!is_valid_player(player_id))
		return
	
	// Show welcome message after a short delay (1 second)
	set_task(1.0, "show_welcome_message", player_id)
}

public show_welcome_message(player_id) {
	// Validate player is still connected
	if (!is_valid_player(player_id))
		return
	
	// Get player name
	new player_name[32]
	get_user_name(player_id, player_name, charsmax(player_name))
	
	// Select random welcome message
	new msg_index = random(sizeof(g_szWelcomeMessages))
	
	// Format message with player name
	new message[256]
	formatex(message, charsmax(message), g_szWelcomeMessages[msg_index], player_name)
	
	// Display in chat with color
	client_print(player_id, print_chat, "^x04[DUST2 ENHANCED]^x01 %s", message)
	
	// Also show a center message
	client_print(player_id, print_center, "Welcome to DUST2 ENHANCED!")
}

// ============================================================================
// HUD STATUS PANEL SYSTEM
// ============================================================================

// Timer callback for HUD updates (runs every 1 second)
public timer_update_hud() {
	// Check if plugin is active
	if (!g_bIsDust2)
		return
	
	// Update HUD for all connected players
	new players[32], num_players
	get_players(players, num_players, "ch") // Get alive and connected players
	
	for (new i = 0; i < num_players; i++) {
		update_status_hud(players[i])
	}
}

// Update status HUD for a single player
public update_status_hud(player_id) {
	// Validate player
	if (!is_valid_player(player_id))
		return
	
	// Only show HUD to alive players
	if (!is_user_alive(player_id))
		return
	
	// Get player stats
	new health = get_user_health(player_id)
	new armor = get_user_armor(player_id)
	new team = get_user_team(player_id)
	
	// Validate stats are sane
	if (health < 0 || health > 255)
		return
	if (armor < 0 || armor > 255)
		return
	
	// Determine team name
	new team_name[8]
	switch (team) {
		case 1: formatex(team_name, charsmax(team_name), "T")
		case 2: formatex(team_name, charsmax(team_name), "CT")
		default: formatex(team_name, charsmax(team_name), "SPEC")
	}
	
	// Determine color based on health
	new r, g, b
	if (health > 75) {
		r = 0; g = 255; b = 0  // Green
	} else if (health > 40) {
		r = 255; g = 255; b = 0  // Yellow
	} else {
		r = 255; g = 0; b = 0  // Red
	}
	
	// Format HUD message
	new hud_text[128]
	formatex(hud_text, charsmax(hud_text), "HP: %d^nAR: %d^nTeam: %s", health, armor, team_name)
	
	// Set HUD message parameters
	set_hudmessage(r, g, b, HUD_STATUS_X, HUD_STATUS_Y, 0, 0.0, 1.1, 0.0, 0.0, HUD_STATUS_CHANNEL)
	
	// Display HUD
	show_hudmessage(player_id, hud_text)
}

// ============================================================================
// ROUND START NOTIFICATION SYSTEM
// ============================================================================

// Global round counter
new g_iRoundNumber = 0

// Event handler for round start
public event_round_start() {
	// Only active on de_dust2
	if (!g_bIsDust2)
		return
	
	// Increment round counter
	g_iRoundNumber++
	
	// Show round alert to all players
	show_round_alert()
}

// Display round start alert
public show_round_alert() {
	// Select random round message
	new msg_index = random(sizeof(g_szRoundMessages))
	
	// Format message with round number
	new message[128]
	formatex(message, charsmax(message), g_szRoundMessages[msg_index], g_iRoundNumber)
	
	// Set HUD parameters (cyan color, top center, 5 seconds)
	set_hudmessage(0, 255, 255, HUD_ROUND_X, HUD_ROUND_Y, 0, 0.0, 5.0, 0.1, 0.1, HUD_ROUND_CHANNEL)
	
	// Display to all players (0 = all)
	show_hudmessage(0, message)
}

// ============================================================================
// SPAWN BONUS SYSTEM
// ============================================================================

// Event handler for player spawn
public event_player_spawn(player_id) {
	// Only active on de_dust2
	if (!g_bIsDust2)
		return
	
	// Apply spawn bonus after a short delay (0.5 seconds)
	set_task(0.5, "apply_spawn_bonus", player_id)
}

// Apply spawn bonus to player
public apply_spawn_bonus(player_id) {
	// Multi-layer validation
	if (!is_valid_player(player_id))
		return
	
	if (!is_user_alive(player_id))
		return
	
	// Get current stats
	new health = get_user_health(player_id)
	new armor = get_user_armor(player_id)
	
	// Validate retrieved values are sane
	if (health < 0 || health > 255)
		return
	if (armor < 0 || armor > 255)
		return
	
	// Random 50/50 selection between health and armor
	new bool:apply_health = (random(2) == 0)
	
	if (apply_health && health < 100) {
		// Apply health bonus
		new new_health = health + BONUS_HEALTH_AMOUNT
		if (new_health > BONUS_HEALTH_MAX)
			new_health = BONUS_HEALTH_MAX
		
		set_user_health(player_id, new_health)
		show_bonus_notification(player_id, true)
	}
	else if (!apply_health && armor < 100) {
		// Apply armor bonus
		new new_armor = armor + BONUS_ARMOR_AMOUNT
		if (new_armor > BONUS_ARMOR_MAX)
			new_armor = BONUS_ARMOR_MAX
		
		set_user_armor(player_id, new_armor)
		show_bonus_notification(player_id, false)
	}
}

// Show bonus notification to player
public show_bonus_notification(player_id, bool:is_health) {
	// Validate player
	if (!is_valid_player(player_id))
		return
	
	// Format message based on bonus type
	new message[64]
	if (is_health) {
		formatex(message, charsmax(message), "+%d HP * Desert Blessing", BONUS_HEALTH_AMOUNT)
		// Green color for health
		set_hudmessage(0, 255, 0, -1.0, 0.65, 0, 0.0, 2.0, 0.1, 0.1, HUD_BONUS_CHANNEL)
	} else {
		formatex(message, charsmax(message), "+%d Armor * Fortified", BONUS_ARMOR_AMOUNT)
		// Blue color for armor
		set_hudmessage(0, 150, 255, -1.0, 0.65, 0, 0.0, 2.0, 0.1, 0.1, HUD_BONUS_CHANNEL)
	}
	
	// Display notification
	show_hudmessage(player_id, message)
}

// ============================================================================
// WEAPON RESTRICTION SYSTEM
// ============================================================================

// CSW weapon constants (AWP)
#define CSW_AWP 18

// Event handler for weapon purchase attempts
public cmd_say(player_id) {
	// Only active on de_dust2
	if (!g_bIsDust2)
		return PLUGIN_CONTINUE
	
	// Get what the player said
	new said[192]
	read_args(said, charsmax(said))
	remove_quotes(said)
	
	// Check for AWP purchase commands
	if (containi(said, "awp") != -1 || containi(said, "magnum") != -1) {
		// Block AWP purchase
		if (is_valid_player(player_id)) {
			show_restriction_message(player_id)
			return PLUGIN_HANDLED
		}
	}
	
	return PLUGIN_CONTINUE
}

// Show weapon restriction message
public show_restriction_message(player_id) {
	// Validate player
	if (!is_valid_player(player_id))
		return
	
	// Select random restriction message
	new msg_index = random(sizeof(g_szRestrictionMessages))
	
	// Display in center and chat
	client_print(player_id, print_center, "%s", g_szRestrictionMessages[msg_index])
	client_print(player_id, print_chat, "^x04[DUST2 ENHANCED]^x01 %s", g_szRestrictionMessages[msg_index])
}

// ============================================================================
// MESSAGE ENGINE - TIPS AND ATMOSPHERE
// ============================================================================

// Timer callback for message rotation
public timer_message_rotation() {
	// Check if plugin is active
	if (!g_bIsDust2)
		return
	
	// Alternate between tips and atmosphere
	if (g_bShowTip) {
		// Show tactical tip
		new msg_index = random(sizeof(g_szTipMessages))
		client_print(0, print_chat, "%s", g_szTipMessages[msg_index])
	} else {
		// Show atmospheric message
		new msg_index = random(sizeof(g_szAtmosphereMessages))
		client_print(0, print_chat, "%s", g_szAtmosphereMessages[msg_index])
	}
	
	// Toggle for next time
	g_bShowTip = !g_bShowTip
	
	// Schedule next message with randomized interval (45-60 seconds)
	new Float:next_interval = random_float(45.0, 60.0)
	set_task(next_interval, "timer_message_rotation", g_hMessageTimer)
}

