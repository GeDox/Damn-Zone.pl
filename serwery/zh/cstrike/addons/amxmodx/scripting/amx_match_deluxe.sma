/* AMXMODX script.
*
*  Originally coded by Shromilder
*  Upgraded and converted to Amx Mod X by Infra
*
*   	Current version: 8.11
*
*  This file is provided as is (no warranties).
*
*
*
*  Changelog:
*  ----------
*
*     - 8.11: (minor release) - Sunday, June 24, 2007
*		fixed bug in stats_log where plugin would not compile with SQL stats disabled
*
*  ----------
*
*     - 8.10: (semi-major release) - Sunday, June 24, 2007
*
*		added multi-lingual support to menu headings
*			---
*		changed the sql functions to only log an error when they failed to connect to the sql server, rather than fail the plugin
*		changed picking of teams after a knife round to a vote, rather than say commands
*		changed pug style games to change to next map in the mapcycle rather than to a default map (i.e. only to dust2)
*			---
*		fixed hltv delay bug where second half demos were being cut off after only 30 seconds or so
*		fixed bug in knife round where users could still fire one shot with the pistol before being forced to switch to knife
*
*  ----------
*
*     - 8.02: (minor release) - Tuesday, May 22, 2007
*		fixed typo in knife round's start message: "KNIFE_ROUND_STARTED" vs. "KNIFE_ROUND_START"
*
*  ----------
*
*     - 8.01: (minor release) - Sunday, May 20, 2007
*		fixed bug where after a team had won in a knife-round only Ts could pick a team, even if CTs won
*		fixed bug where you could still type 'ready' in knife round
*		fixed bug where teams would be swapped, but the names wouldn't after a knife round
*		fixed bug where ready list would still display "None." even after the first player was ready
*			---
*		changed sequence of knife round/warmup/first half (now start->warmup->knife round->warmup->first half)
*
*  ----------
*
*     - 8.00: (major release) - Friday, May 18, 2007
*		added French translation, thanks AIA-Shogun
*		added updated German translation, thanks ToT | V!PER
*		added br translation, thanks rfrik
*		added Serbian translation, thanks iggy_bus 
*			---
*		fixed hltv bug, thanks AIA-Shogun
*		fixed hltv delay bug
*			---
*		added knife round
*		added unlimited overtime support
*		added cvar 'amx_match_otunlimited'
*		added MySQL support for recording stats
*		added PHP/MySQL web interface to display SQL stats
*			---
*		changed name of cvar: 'amx_match_overtimecfg' to 'amx_match_otcfg', to match other overtime cvar names
*		changed format of hltv demos to remove duplicate parts of the demo name
*		changed the format for logging stats to the match half file (check that file for the new format)
*
*  ----------
*
*     - 7.03: (minor release) - Monday, November 13, 2006
*		fixed runtime error when executing a match
*
*  ----------
*
*     - 7.02: (minor release) - Friday, November 10, 2006
*		added warmup configs
*		added constants for all file handles so all hardcoded file names are all variables and in one place
*		added cvar amx_match_warmupcfg
*			---
*		fixed problem where match would not end, if match played through all rounds and endtype was not 0
*			---
*		changed the format of the teams for the logging: CT -> 2, T -> 1 (instead of CT -> 1, T -> 2)
*			---
*		removed french translation due to all of the problems that the incomplete translation is causing. (Will add it back in once somebody translates it again)
*
*  ----------
*
*     - 7.01: (minor release) - Friday, July 21, 2006
*		fixed OT portion of the plugin. Overtime works correctly now...
*		fixed bug where password would be shown to all players if the server console started a match (id = 0)
*		fixed bug where first map's name was used for demos during second map in a two map match.
*			---
*		updated swedish translation for five missing translation tags, thanks TheLinx.
*		
*
*  ----------
*
*     - 7.00: (major release) - Saturday, July 15, 2006
*		added PUG type gameplay (See www.sk-gaming.com for details) turned on by cvar
*		added winlimit type matches
*		added logging to HL logs as well as AMXX logs
*		added printing to server console as well as AMXX logs
*		added two new console commands 'amx_match_addlength' and 'amx_match_addconfig' (equiv. to server commands: 'amx_match_lmenu' and 'amx_match_cmenu')
*		added two map matches (amx_match3 and amx_match4)
*		added logging of match stats
*		added new command 'say /relo3'
*		added new command 'amx_matchrelo3'
*		added ability to restart the half as well as the match
*		added ability for league files to be in the main cstrike directory as well as in '/amxmd/leagues/'
*		added file: 'defaultmaps.ini' for maps list in the menu
*		added polish translation, thanks rain.
*		added danish translation, thanks ZiP*.
*		added czech translation, thanks James.
*		added team randomizer, thanks for the idea Eklundh
*		added cvar amx_match_pugstyle
*		added cvar amx_match_randomizeteams
*		added cvar amx_match_stats
*			---
*		alphabatized the translation file (amx_match_deluxe.txt)
*			---
*		changed swap_teams to support the new cs_user_change_team functions (Swaps without killing the player)
*		changed the order of menus (removed 'match_type -> mr13'; added 'MatchType -> MR/TL/WL' and 'MatchLength -> 13'; Added a menu for Tags/No Tags between CT Tags and the main menu )
*		changed all hud message channels (except the timer and show_score functions) to -1.
*		changed the way the plugin looks for the config file list in match_start; cfglist.txt is not used anymore
*		changed the settings menu to disable the dependent settings when the independent settings are disabled  (amx_match_otlength and amx_match_otcfg, when amx_match_overtime is disabled, for instance)
*		changed the readme to html format
*		changed the defaults for some of the cvars (refer to cvar portion of the readme)
*			---
*		fixed menu settings function so it's not completely dependent on what cvars are registered (can't think of a way to completely get away from dependency)
*		fixed hltv delay, it actually delays the hltv now...
*		fixed all multilingual lines of code to use 'id' and 'LANG_PLAYER' properly
*			---
*		updated swedish translation, thanks TheLinx.
*		updated german translation, thanks pl2003
*			---
*		reformated function names
*		reformated variable names
*			---
*		removed support for NO_STEAM
*			---
*		rewrote 'new_score' and 'start_match' functions
*			- completely new layouts
*			- way easier to debug
*	   
*  ----------
*
*     - 6.01: (minor bug fix release) - Monday, August 1, 2005
*	   fixed plugin settings menu for multipule bugs, including no second page and not working with no steam. Thanks for the heads up TheRising
*	   
*  ----------
*
*     - 6.00: (major release) - Sunday, July 24, 2005
*	   fixed force-start functions. Plugin now ignores more than one (1) force-start command
*	   fixed demo menu. You can now start a match from the menu without being required to record a demo
*	   fixed restart function where if a timelimit match is restarted it would become a maxround match
*	   fixed typo in command description  ( "cl" --> "tl" )
*		---
*	   changed timelimit matches to have a timer and be on the same map for the whole match. (Major)
*	    	---
*	   added functionality to amx_match_endtype so that it pertains to timelimit matches as well
*	   added swedish translations to plugin. Thanks Sunner
*
*  ----------
*
*     - 5.00: (major release) - Saturday, April 30, 2005
*	   cleaned up code
*	    	---
*	   removed includes for 'engine' and 'cstrike', these modules are not required anymore.
*	   removed a few global variables.
*	    	---
*	   added amx_match_hltvdelay to the plugin settings menu
*	   added require_module function calls, so people won't get confused when they don't enable the regex or sockets modules
*	    	---
*	   changed format of hltv.ini to be more user-friendly (in the format of: "<command> <setting>")
*	   changed format of the menu_action_main to match display_main_menu (easier to take care of now)
*	   changed the three 'plugin settings menu' functions to one function
*	    	---
*	   fixed hltv code again to allow for disabling the Sockets module, thanks for the heads-up V!PER...
*	   fixed bug in main menu, during a half, where Swap teams would bring up the settings menu
*	   fixed and added to the readme to reflect changes
*
*  ----------
*
*     - 4.00: (major release)
*	   added multi-lingual functionality
*	   added hltv.ini config file, for the hltv admin password
*	    	---
*	   changed swap teams so that if a player had vGUIs turned on it won't make them old-style
*	    	---
*	   fixed hltv code to allow for hltv and server consoles with the same ip address, Thanks Ramm...
*
*  ----------
*
*     - 3.00: (major release)
*	   added new command: amx_matchsave, which will save your current cvar configuration to amxmd.cfg
*	   added menu item to main AMXX menu. (amxmodmenu)
*	   added support for hltv, using the sockets module. - Thanks redmist...
*	   added amxmd.cfg file - Thanks V!PER...
*	   added "Save configuration" menu option in the Plugin settings menu. (Save your current configuration to the amxmd.cfg file)
*	    	---
*	   changed the readme to be easier to understand
*	   changed behavior of menu cfg file and type adders; the adder functions will not add the cfg's or types if the cfg or type is already in the menu...
*	   changed location of config files to be <custom dir>/amxmd/[leagues]
*	   changed name of menu command from 'amx_match_menu' to 'amx_matchmenu' to match the naming convention of other commands
*	   changed name of hltv command from 'amx_match_hltv' to 'amx_matchhltv' to match the naming convention of other commands
*	    	---
*	   fixed bug in clantags finder functions; they actually find the clan tags now  ^_^.
*	   fixed bugs in voting functions, rofl: version 3  ^_^ - Thanks breaddawson...
*
*  ----------
*
*     - 2.01: fixed string bug in back_to_ffa(), where there was no '%s'  >_<.
*             added match_restart to amx_match_menu.
*
*  ----------
*
*     - 2.00: (major release)
*	   added support for restarting the match.
*	   added support for show activity, if on.
*	   added cvars that were not previously in the menu, to the menu.
*	    	---
*	   changed behavior of amx_match_password2 and amx_match_password for more fluid execution and easier to remember.
*	    	---
*	   fixed version number bug in register plugin command.
*	   fixed bug where hostname would not be changed back to original hostname after match, if changed by match plugin.
*	   fixed bug where the vote, for playout, would happen even if there were 3 or 4 (total-rounds divided by 5 minus 1) or (30/5) - 1 = 5) rounds left in the match. version 2  ^_^
*	   fixed bug where vote to play out would happen even if endtype = 0
* 	   fixed "un/passwording" of server after match, used same method as hostname fix to add/remove password at end of match.
*
* ----------
*
*     - 1.81: fixed readme file to reflect changes that will be in AMXX 0.20.
*          added amx_match_password and amx_match_password2 cvars
*          added support for "passwording" the server.
*     - 1.80: fixed bug where overtime config file was execed even in regular match time.
*     - 1.79: added support for overtime config files.
*	   added amx_match_otcfg to turn [on|off] overtime config files.
*     - 1.78: fixed typos.
*     - 1.77: better code.
*	   fixed bug where the vote, for playout, would happen even if there were 3 or 4 rounds left in the match.
*     - 1.76: added amx_match_shield2 cvar, unrestricts or (re)restricts shield after the match
*     - 1.75: added compatibility with AmxModX 0.16
*     - 1.74: added the ability to vote to play out the match. (Use amx_match_endtype)
*     - 1.73: added amx_match_screenshot2 to take end-half screenshots even if match is stopped using amx_match_stop or "say /stop"
*     - 1.72: added amx_match_hostname cvar to have the server change it's name based on who is playing.
*          added "say /stop" command in addition to amx_match_stop.
*     - 1.71: added the possibility to change match settings in the menu (it just change them, it doesn't save them anywhere so after a changelevel, all is lost).
*          added amx_match_shield cvar to allow or not the use of the shield during the match.
*
* ----------
*
*     - 1.70: trying to make it 1.6 compatible:
*             stoprecord changed to stoprecording if using 1.6
*             cancelselect used for the screenshots if using 1.6
*             changed the hud msgs for 1.6 (readylist not yet done)
*             score msg is a hud msg if using 1.6
*     - 1.69: better code.
*     - 1.68: if a player is already recording his own demo, then it's stopped to record a correct one.
*          changed the score display.
*          some bugs fixed & small changes.
*     - 1.67: the cvar amx_match_showids has been changed to amx_match_screenshot which allow you to choose if you want to take a screenshot or not.
*          added overtime support with amx_match_overtime & amx_match_otrounds cvars. To respect clantags, the team which must start the overtime as CT
*          must be the team which started the match as CT (if you don't use clantags, there's no problem).
*     - 1.66: changed showids. it now takes a screenshot of 'status' in the console
*     - 1.65: added clantag recognition in the menu
*     - 1.62: added the possibility to show score after each rounds using amx_match_showscore cvar (default is off)
*     - 1.61: added the option to see wonid using amx_match_showids cvar (default is off)
*     - 1.60: added the ability to use UDP module or not (so in fact, use hltv feature or not)
*     - 1.54: corrected demo not stopping when the match is stoped.
*          added amx_matchstart command which force the start of a match
*     - 1.52: modified the menu, added HLTV help
*     - 1.51: fixed HLTV record demo & some other bugs (thx to en3my for HLTV)
*     - 1.50: HLTV demos \o/ recdemo will record players demos. rechltv will record HLTV demos. recboth will record HLTV and players demos.
*     - 1.46: added amx_match_swaptype
*     - 1.45: added admin start with say & menu (amx_match_readytype 2)
*     - 1.44: some modifications. HLTV soon!
*     - 1.43: removed a possible bug (warmup msg during match)
*     - 1.42: corrected swapteam command: now it check if the user using it is an admin (stupid me :/)
*     - 1.41: removed an horrible bug (changing map before the match) >:[
*     - 1.40: added amx_match_menu which allow to load a match with a menu =]
*     - 1.30: added amx_match_readytype & amx_match_playerneed cvars which allow that everyone must say ready
*     - 1.21: added notready feature which allow a team or a player to remove their ready flag
*     - 1.20: added amx_match_endtype cvar & fixed some bugs like recording demos with voicecom on.
*     - 1.10: added amx_match2 and amx_swapteams command, added screenshots feature
*     - 1.02: other bugs removed, less warmup msg flood
*     - 1.01: added log commands, small bug removed
*     - 1.00: first release
*
*
*  To do: 
*  -------
*
*
*/


/* 
*
*	Variables and Defines
*
*/

#pragma dynamic 32768

// Main plugin defines
new const AMXMD_NAME[] = "AMX Match Deluxe"
new const AMXMD_CVAR[] = "amx_match_deluxe"
new const AMXMD_VERSION[] = "8.11"
new const AMXMD_AUTHOR[] = "Infra"

// Change the next line to change the default access of the plugin
#define AMXMD_ACCESS ADMIN_LEVEL_A


// COMMENT THE NEXT LINE IF YOU DON'T WANT TO USE THE SOCKETS MODULE (add '//' in front of it) AND RECOMPILE THE PLUGIN
//#define AMXMD_USE_HLTV

// UNCOMMENT THE NEXT LINE IF YOU WANT TO USE THE MYSQL MODULE (remove the '//' from in front of it) AND RECOMPILE THE PLUGIN
//#define AMXMD_USE_SQL


// Includes

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <regex>


#if defined(AMXMD_USE_HLTV)

	#include <sockets> // Using hltv?

#endif


#if defined(AMXMD_USE_SQL)

	#include <sqlx> // Using mysql?

#endif


// Task IDs:
//
// warmup_print_message			0001
// warmup_print_readylist		0002
// timer_decrement_seconds		0003
// timer_show					0004
// score_show					0005
// warmup_print_message_shouldbe	0006
// kniferound_stop_printmessage	0007

#define TASKID_WARMUP_MESSAGE 0001
#define TASKID_WARMUP_READYLIST 0002
#define TASKID_DECREMENT_SECONDS 0003
#define TASKID_TIMER_SHOW 0004
#define TASKID_SHOW_SCORE 0005
#define TASKID_MESSAGE_SHOULDBE 0006
#define TASKID_KNIFEROUND_MESSAGE 0007

// Cvars

#define NUM_CVARS 22

new cvar_names[NUM_CVARS][] = {
	"amx_match_endtype",		// 0
	"amx_match_hostname", 		// 1
	"amx_match_hltvdelay",		// 30
	"amx_match_kniferound",		// 0
	"amx_match_overtime",		// 1
	"amx_match_otcfg",			// 1
	"amx_match_otlength",		// 3
	"amx_match_otunlimited",		// 0
	"amx_match_password",		// 1
	"amx_match_password2",		// scrim
	"amx_match_playerneed",		// 10
	"amx_match_pugstyle",		// 0
	"amx_match_randomizeteams",	// 0
	"amx_match_readytype",		// 1
	"amx_match_swaptype",		// 1
	"amx_match_screenshot",		// 1
	"amx_match_screenshot2",		// 1
	"amx_match_shield",			// 1
	"amx_match_shield2",		// 1
	"amx_match_showscore",		// 1
	"amx_match_stats",			// 0
	"amx_match_warmupcfg"		// 0
}

new cvar_properties[NUM_CVARS][] = {
	"0",					// amx_match_endtype
	"1",					// amx_match_hostname
	"30",				// amx_match_hltvdelay
	"0",					// amx_match_kniferound
	"1",					// amx_match_overtime
	"1",					// amx_match_otcfg
	"3",					// amx_match_otlength
	"0",					// amx_match_otunlimited
	"1",					// amx_match_password
	"scrim",				// amx_match_password2
	"10",				// amx_match_playerneed
	"0",					// amx_match_pugstyle
	"0",					// amx_match_randomizeteams	
	"1",					// amx_match_readytype
	"1",					// amx_match_swaptype
	"1",					// amx_match_screenshot
	"1",					// amx_match_screenshot2
	"1",					// amx_match_shield
	"1",					// amx_match_shield2
	"1",					// amx_match_showscore
	"0",					// amx_match_stats
	"0"					// amx_match_warmupcfg
}

new cvar_language[NUM_CVARS][] = {
	"END_TYPE", 				//	amx_match_endtype
	"CHANGE_HOSTNAME",			//	amx_match_hostname
	"HLTV_DELAY",				//	amx_match_hltvdelay
	"KNIFE_ROUND",				//	amx_match_kniferound
	"ALLOW_OVERTIME",			//	amx_match_overtime
	"OVERTIME_CONFIGS",			//	amx_match_otcfg
	"OVERTIME_LENGTH",			//	amx_match_otlength
	"OVERTIME_UNLIMITED",		//	amx_match_otunlimited
	"CHANGE_PASSWORD",			//	amx_match_password
	"PASSWORD",				//	amx_match_password2
	"NEEDED_READY_PLAYERS",		//	amx_match_playerneed
	"PUG_STYLE",				//	amx_match_pugstyle
	"RANDOMIZE_TEAMS",			//	amx_match_randomizeteams
	"READY_TYPE",				//	amx_match_readytype
	"AUTO_SWAP",				//	amx_match_swaptype
	"SCREEN_SHOT",				//	amx_match_screenshot
	"ALWAYS_SCREENSHOT",		//	amx_match_screenshot2
	"ALLOW_SHIELDS",			//	amx_match_shield
	"REALLOW_SHIELD",			//	amx_match_shield2
	"SHOW_SCORE",				//	amx_match_showscore
	"STATS",					//	amx_match_stats
	"WARMUP_CONFIGS"			//	amx_match_warmupcfg
}


// Configs

// Main global commands
new main_command_type = 0 		// 1 -> amx_match, 2 -> amx_match2, 3 -> amx_match3, 4 -> amx_match4
new main_inprogress = 0 			// 0 -> No match, 1 -> Warmup #1, 2 -> 1st half, 3 -> Warmup #2, 4 -> 2nd half
new main_command_matchtype = 0	// 1 -> maxround, 2 -> timelimit, 3 -> winlimit
new main_command_matchlength = 0	// Length of match  (mr15  <--number)
new main_command_demotype = 0		// 0 -> None, 1 -> In-eyes, 2 -> HLTV, 3 -> Both (In-eyes and HLTV)
new main_command_full[256]		// Full match command

// Maps
new main_secondmap[64]			// Name of second map (for 2 map matches)
new main_firstmap[64]			// Name of first map (for 2 map matches)


// Ready functions
new main_ready_teams = 0 		// 0 -> None, 1 -> T ready, 2 -> CT ready
new main_ready_userids[33]		// List of userids of players who are ready
new main_ready_CT[256] 			// List of CTs who are ready
new main_ready_T[256] 			// List of Ts who are ready


// Cvars
new cvar_endtype = 0			// 0 -> Match ends after all rounds played, 1 -> Match ends after mp_maxrounds+1 rounds won, 2 -> There is a vote to play out the match after mp_maxrounds+1 rounds won.


// Scores
new main_score_ct[2]			// Contains the score of the CT team; 0 -> First half, 1 -> Second half
new main_score_t[2]				// Contains the score of the T team; 0 -> First half, 1 -> Second half

new main_score_2mm_ct			// Contains the CT score from the previous map in a 2 map match
new main_score_2mm_t			// Contains the T score from the previous map in a 2 map match

new main_score_overtime = 0		// Contains the number of rounds played before overtime

// Clan names
new main_clanCT[32]				// CT clan name
new main_clanT[32]				// T clan name


// Config files
#define AMXMD_MAX_CFGFILES 25

new config_file_match[32]		// Match config file name
new config_file_plugin[64]		// Main config file name
new config_file_pug[64]			// PUG config file name
new config_file_defaultmaps[64]	// Default Maps config files

#if defined(AMXMD_USE_HLTV)

new config_file_hltv[64]			// HLTV config file

#endif


// File and Directory Constants
new const AMXMD_CONFIG_PLUGIN[] = "amxmd.cfg"
new const AMXMD_CONFIG_PUG[] = "pug.ini"
new const AMXMD_CONFIG_DEFAULTMAPS[] = "defaultmaps.ini"

new const AMXMD_CONFIG_FFA[] = "ffa.cfg"
new const AMXMD_CONFIG_DEFAULT[] = "default.cfg"
new const AMXMD_CONFIG_WARMUP[] = "warmup.cfg"

new const AMXMD_DICT_MAIN[] = "amx_match_deluxe.txt"
new const AMXMD_DICT_COMMON[] = "common.txt"

new const AMXMD_2MM_MAIN[] = "2mmmain.ini"
new const AMXMD_2MM_CVAR[] = "2mmcvar.cfg"
new const AMXMD_2MM_RESTART[] = "2mmrestart.ini"

new const AMXMD_STATS_MAIN[] = "main.dat"

new const AMXMD_DIR_MAIN[] = "amxmd"
new const AMXMD_DIR_CONFIGS[] = "leagues"
new const AMXMD_DIR_STATS[] = "match_stats"


#if defined(AMXMD_USE_HLTV)

new const AMXMD_CONFIG_HLTV[] = "hltv.ini"

#endif


// Config directories
new config_dir_main[64]			// Main plugin directory
new config_dir_leagues[64]		// League directory

// 2 map match files
new config_file_2mm_main[64]		// Main 2mm file
new config_file_2mm_restart[64]	// Restart 2mm file
new config_file_2mm_cvar[64]		// Cvar 2mm file

// 2 map match
new main_in2mapmatch = 0

// 2 map match defines
#define AMXMD_2MM_COMMAND 3		// Line in file of the command
#define AMXMD_2MM_SCORES 4		// Line in file of the scores
#define AMXMD_2MM_FIRSTMAP 5		// Line in file of the first map
#define AMXMD_2MM_OLDNAME 6		// Line in file of the old hostname
#define AMXMD_2MM_OLDPASS 7		// Line in file of the old password

// Stats files
new stats_dir_main[64]			// Main stats directory
new stats_file_main[64]			// Main stats file


// Overtime
new main_inovertime = 0 			// 0 -> no overtime, 1 -> playing overtime


// Knife round
new main_inkniferound = 0			// 0 -> not playing knife round, 1 -> playing knife round
new main_kniferound_won = 0			// Team that won the knife round: CT -> 2, T -> 1
new main_kniferound_done = 0			// Set to 1 when knife round is over


// Timer
new main_seconds				// Used for the timer for tl matches


// Reset server...
new main_serverpass_old[32]		// Old server password
new main_servername_old[64]		// Old server hostname


// Vote for playout

#define AMXMD_PLAYOUT_RATIO 5

new vote_areVoting = 0 			// This flag is to check if a vote is already happening 
new vote_option[2]				// vote_option[0] -> Yes's, vote_option[1] -> No's


// HLTV Stuff
#if defined(AMXMD_USE_HLTV)

	new hltv_id				// Player ID of the HLTV
	new hltv_ip[32]			// Ip address of the HLTV
	new hltv_port				// Port of the HLTV
	new hltv_password[64]  		// HLTV Admin Password

#endif


#if defined(AMXMD_USE_SQL)

// MySQL Stuff
new Handle:SqlTuple 			// The SQL Tuple Handle.
new Handle:SqlConnection


new const AMXMD_SQL_MAIN[] = "amx_match_main"
new const AMXMD_SQL_HALF[] = "amx_match_half"
new const AMXMD_SQL_MAP[] = "amx_match_map"
new const AMXMD_SQL_PLAYER[] = "amx_match_player"
new const AMXMD_SQL_PLAYER_NAME[] = "amx_match_player_name"
new const AMXMD_SQL_PLAYER_STATS[] = "amx_match_player_statistics"
new const AMXMD_SQL_TEAM[] = "amx_match_team"

#endif


// Variables for stopping multiple
// executions of 'start', 'relo3', and 'stop'
new is_started
new is_restarted
new is_stopped


// MENU

// Menu defines
#define MENU_MAX_VARS 512 				// Maximum variables for the menu

#define MENU_TAGS_MAX 20 				// Maximum of tags in the menu
#define MENU_TAGS_MINPLAYERS 2 			// Minimum number of players sharing a tag required to autodetect a clan

new menu_tags_CT[MENU_TAGS_MAX][32]		// CT tags from tag finder functions
new menu_tags_T[MENU_TAGS_MAX][32]			// T tags from tag finder functions
new menu_lengthlist[MENU_MAX_VARS][32]		// List of match lengths 
new menu_configlist_name[MENU_MAX_VARS][32]	// List of match configs names
new menu_configlist_file[MENU_MAX_VARS][32]	// List of match configs filenames
new menu_maplist[MENU_MAX_VARS][64]	 	// List of maps on server for two map matches

new menu_tags_CT_pos = 0					// Position of last tag in menu_tags_CT 
new menu_tags_T_pos = 0					// Position of last tag in menu_tags_T
new menu_lengthlist_pos = 0				// Position of last length in menu_lengthlist
new menu_configlist_pos = 0				// Position of last config in menu_configlist
new menu_maplist_pos = 0					// Position of last map in menu_maplist

new menu_position[33]					// Position in menu of each player
new menu_selections[33][7]				// Commands selected by users

#define MENU_SELECTION_TAG_CT 0
#define MENU_SELECTION_TAG_T 1
#define MENU_SELECTION_MATCHTYPE 2
#define MENU_SELECTION_MATCHLENGTH 3
#define MENU_SELECTION_CONFIG 4
#define MENU_SELECTION_SECONDMAP 5
#define MENU_SELECTION_DEMOTYPE 6



/* 
*
*	Main Plugin
*
*/


/*
*
*	Client commands
*
*/

public client_disconnect(id)
{	
	#if defined(AMXMD_USE_HLTV)

	if (hltv_id == id)
	{
		server_print("* %L (%s)",LANG_SERVER, "HLTV_LEFT_GAME", hltv_ip)
		log_amx("* %L (%s)",LANG_SERVER,"HLTV_LEFT_GAME",hltv_ip)
		hltv_id = 0
	}

	#endif
	
	if ((get_cvar_num("amx_match_readytype") == 1) && ((main_inprogress == 1) || (main_inprogress == 3)))
	{
		warmup_readylist_remove(id)
	}
	
	return PLUGIN_CONTINUE
}

#if defined(AMXMD_USE_HLTV)

public client_putinserver(id)
{
	new left[32]
	new right[32]
	
	new command[256]
	
	if (is_user_hltv(id))
	{
		hltv_id = id
		get_user_ip(hltv_id,hltv_ip,31)
		
		strtok (hltv_ip, left, 31, right, 31, ':')
		
		copy(hltv_ip, 31, left)
		hltv_port = str_to_num(right)

		format(command, 255, "say %L", LANG_SERVER, "HLTV_CONFIGURED_CORRECTLY")
		hltv_rcon_command(command, 0)
		
		
		format(command, 255, "delay %d", get_cvar_num("amx_match_hltvdelay"))
		hltv_rcon_command(command, 0)	
		
		
		server_print("* %L (%s:%i)",LANG_SERVER,"HLTV_ENTERED_GAME",hltv_ip,hltv_port)
		log_amx("* %L (%s:%i)",LANG_SERVER,"HLTV_ENTERED_GAME",hltv_ip,hltv_port)
	}
	
	return PLUGIN_CONTINUE
}

#endif

/* 
*
*	Demo functions
*
*/


public demo_record()
{
	new demo_name[256]
	new time_date[32]

	new map_name[32]

	new players[32]
	new playername[32]
	new nbr, i
	
	new CsTeams:team
	
	new player
		
	
	get_mapname ( map_name, 31 )


	get_time("%Y.%m.%d-%H.%M.%S",time_date,31)
	
	
	#if defined(AMXMD_USE_HLTV)
	
	if (main_command_demotype > 1)
	{ // HLTV demos
		if ( get_cvar_num("amx_match_hltvdelay") > 0)
		{
			set_task(get_cvar_float("amx_match_hltvdelay"), "demo_record_hltv")
		}
		else
		{
			demo_record_hltv()
		}
	}	
	
	#endif
	
	if ((main_command_demotype == 1)||(main_command_demotype == 3))
	{ // Player's demos
		get_players(players,nbr)
		
		for(i = 0; i < nbr; i++)
		{
			player = players[i]
			
			team = cs_get_user_team( player )
			
			get_user_name(player,playername,31)
			
			if ( team != CS_TEAM_CT )
			{
				if (main_command_type == 1 || main_command_type == 1)
				{
					format(demo_name,255,"%s(CT)_%s(T)_%s_ineyes_%s_%s.dem", (main_inprogress==1) ? main_clanCT : main_clanT, (main_inprogress==1) ? main_clanT : main_clanCT, map_name, playername, time_date)
				}
				else
				{
					format(demo_name,255,"%s_%s(CT)_%s.dem", playername, map_name, time_date)
				}
			}
			else if ( team != CS_TEAM_T )
			{		
					if (main_command_type == 1)
					{	
						format(demo_name,255,"%s(T)_%s(CT)_%s_ineyes_%s_%s.dem", (main_inprogress==1) ? main_clanT : main_clanCT,(main_inprogress==1) ? main_clanCT : main_clanT, map_name, playername, time_date)
					}
					else
					{
						format(demo_name,255,"%s_%s(T)_%s.dem", playername, map_name, time_date)
					}
			}
			
			
			if ( team != CS_TEAM_SPECTATOR )
			{
				// Remove bad strings before recording
				while(replace(demo_name,255,"/","-")) {}
				while(replace(demo_name,255,"\","-")) {}
				while(replace(demo_name,255,":","-")) {}
				while(replace(demo_name,255,"*","-")) {}
				while(replace(demo_name,255,"?","-")) {}
				while(replace(demo_name,255,">","-")) {}
				while(replace(demo_name,255,"<","-")) {}
				while(replace(demo_name,255,"|","-")) {}
				
				client_cmd(player,"stop")
				
				client_cmd(player,"record ^"%s.a^"",demo_name)
				
				client_print(player,print_chat,"* [AMX MATCH] %L : %s", player, "RECORDING_INEYE_DEMO",demo_name)
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

#if defined(AMXMD_USE_HLTV)

public demo_record_hltv()
{
	new demo_name[256]
		
	new hltv_command[512]
		
		
	// Set the hltv password before performing any commands
	hltv_set_password()
	
	// Make sure that hltv isn't recording right now
	hltv_rcon_command("stoprecording", 0)
	
	if (main_command_type == 1 || main_command_type == 3)
	{
		format(demo_name, 255, "HLTV-%s(%s)_%s(%s)", main_clanCT, (main_inprogress==1) ? "CT" : "T", main_clanT, (main_inprogress==1) ? "T" : "CT")
	}
	else
	{
		format(demo_name, 255, "HLTV-part%d", (main_inprogress==1) ? 1 : 2)
	}
	
	// Remove bad strings before recording
	while(replace(demo_name,255,"/","-")) {}
	while(replace(demo_name,255,"\","-")) {}
	while(replace(demo_name,255,":","-")) {}
	while(replace(demo_name,255,"*","-")) {}
	while(replace(demo_name,255,"?","-")) {}
	while(replace(demo_name,255,">","-")) {}
	while(replace(demo_name,255,"<","-")) {}
	while(replace(demo_name,255,"|","-")) {}
	while(replace(demo_name,255," ","-")) {}
	
	// Format the say command to send to the hltv server
	format(hltv_command, 511, "say * [AMX MATCH] %L  : %s", LANG_SERVER, "RECORDING_HLTV_DEMO", demo_name)
	
	// Send the command to the hltv server
	hltv_rcon_command(hltv_command, 0)
	
	// Make the record demo command
	format(hltv_command, 511, "record %s", demo_name)
	
	// Execute record demo command
	hltv_rcon_command(hltv_command, 0)

	return PLUGIN_CONTINUE	
}

#endif


public demo_stop()
{
	new players[32]
	new nbr,i
	
	new CsTeams:team
	
	new player

	#if defined(AMXMD_USE_HLTV)
	
	if (main_command_demotype > 1)
	{ // HLTV demos
		if ( get_cvar_num("amx_match_hltvdelay") > 0)
		{
			set_task(get_cvar_float("amx_match_hltvdelay"), "demo_stop_hltv")
		}
		else
		{
			demo_stop_hltv()
		}
	}
	
	#endif
	
	if ((main_command_demotype == 1)||(main_command_demotype == 3)) 
	{ // Player's demos
		
		get_players(players,nbr)
		
		for(i=0; i < nbr; i++) 
		{
			player = players[i]
			
			team = cs_get_user_team( player )
			
			if ( team != CS_TEAM_SPECTATOR )
			{
				client_cmd(player,"stop")
				client_print(player,print_chat,"* [AMX MATCH] %L", player, "STOP_RECORDING_DEMOS")
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

#if defined(AMXMD_USE_HLTV)

public demo_stop_hltv()
{
	new temp[64]
	
	hltv_rcon_command("stoprecording", 0)
	
	format(temp, 63, "say [AMX MATCH] %L", LANG_SERVER, "STOP_RECORDING_DEMOS")
	
	hltv_rcon_command(temp, 0)

	return PLUGIN_CONTINUE	
}

#endif


/* 
*
*		Half
*
*/

public half_live_message()
{	
	set_hudmessage(255, 255, 255, -1.0, -1.0, 0, 2.0, 6.0, 0.8, 0.8, -1)
	show_hudmessage(0,"--[ %L ]--^n--[ %L ]--^n--[ %L ]--",LANG_PLAYER,"LIVE",LANG_PLAYER,"LIVE",LANG_PLAYER,"LIVE")
	
	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER,"AMX_LIVE")
	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER,"AMX_LIVE")
	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER,"AMX_LIVE")
	
	return PLUGIN_CONTINUE
}


public half_restart(id, level)
{
	new user_name[32]
	
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}
	
	if( main_inprogress > 0 )
	{
		if( main_inprogress == 2 || main_inprogress == 4)
		{
			if(is_restarted == 0)
			{
				is_restarted = 1
				
				if( main_inprogress == 2 )
				{
					// Reset the first half's scores
					main_score_ct[0] = 0
					main_score_t[0] = 0
				}
				else if( main_inprogress == 4 )
				{
					// Reset the second half's scores
					main_score_ct[1] = 0
					main_score_t[1] = 0
				}
				
				// Decrement main_inprogress
				main_inprogress--
				
				// Get user's name
				get_user_name(id,user_name,31)
				
				// Show activity, if on
				switch(get_cvar_num("amx_show_activity")) 
				{	
						case 2: client_print(0,print_chat,"%L %s: %L",LANG_PLAYER, "ADMIN",user_name, LANG_PLAYER, "RESTARTED_HALF")
						case 1: client_print(0,print_chat,"%L %L",LANG_PLAYER, "ADMIN", LANG_PLAYER, "RESTARTED_HALF")
				}
				
				// Show half started message
				set_hudmessage(255, 0, 0, -1.0, 0.32, 0, 2.0, 6.0, 0.8, 0.8, -1)
				show_hudmessage(0,"--[ %s %L !!! ]--", user_name, LANG_PLAYER,"HUD_HALF_RESTARTED")
				
				set_task(16.0, "misc_reset_restarted")
				
				set_task(3.0, "half_start")
			}
			else
			{
				console_print(id,"* %L", id, "HALF_ALREADY_RESTARTED")
				client_print(id,print_chat,"* [AMX MATCH] %L", id, "HALF_ALREADY_RESTARTED")
			}
		}
		else
		{
			
			
		}
	}
	else
	{
		client_print(id, print_chat,"* [AMX MATCH] %L", id, "NO_MATCH_LOADED")
		console_print(id, "* %L", id, "NO_MATCH_LOADED")
	}
	
	return PLUGIN_CONTINUE
}


public half_set_rules()
{
	set_cvar_num("mp_maxrounds", 0)
	set_cvar_num("mp_winlimit", 0)
	set_cvar_num("mp_timelimit", 0)
	
	set_cvar_num("mp_limitteams", 0)
	set_cvar_num("mp_autoteambalance", 0)
	
	
	if( main_command_matchtype == 2) // If we are in a timelimit match, then set the seconds
	{
		main_seconds = ( main_command_matchlength * 60 ) + 1
	}
	
	return PLUGIN_CONTINUE
}


public half_start()
{
	main_ready_teams = 0
	
	is_stopped = 0


	// Exec configs	
	misc_exec_configs()
	
	
	// Remove warmup message
	if(task_exists(TASKID_WARMUP_MESSAGE))
	{
		remove_task(TASKID_WARMUP_MESSAGE)
	}
	
	// Remove ready list
	if (get_cvar_num("amx_match_readytype") == 1 && task_exists(TASKID_WARMUP_READYLIST))
	{
		remove_task(TASKID_WARMUP_READYLIST)
	}
	
	// Remove 'should be' message
	if(task_exists(TASKID_MESSAGE_SHOULDBE))
	{
		remove_task(TASKID_MESSAGE_SHOULDBE)
	}
	
	
	if (main_command_demotype > 0) // If we are recording demos
	{
		// Turn off VoIP
		misc_voice_enable( "0" )
		
		// Start the demo
		set_task(2.0,"demo_record")
		
		// Turn on VoIP
		set_task(4.0,"misc_voice_enable",0,"1",1)
	}
	
	
	if (main_inprogress == 1) // If we are in the first half
	{
		client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER,"FIRST_HALF_START")
	}
	else if (main_inprogress == 3) // If we are in the second half
	{
		client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "SECOND_HALF_START")
	}
	
	// Print prepare messages
	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER,"GOING_LIVE")
	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER,"GOING_LIVE")
	
	// Restart the round
	set_task(2.0,"misc_restart_round",0,"1",1)
	
	// Set the match's rules
	set_task(5.0, "half_set_rules" )
	
	// Restart the round
	set_task(6.0,"misc_restart_round",0,"1",1)
	
	// Restart the round
	set_task(9.0,"misc_restart_round",0,"3",1)
	
	// Show the live message
	set_task(13.0, "half_live_message" )
	
	if(main_command_matchtype == 2)
	{
		set_task(10.0,"timer_start")
	}
	
	// Now playing a half
	set_task(13.0, "match_increment_inprogress")
	
	return PLUGIN_CONTINUE
}

public half_start_force(id)
{
	new user_name[32]	
	
	if ((main_inprogress == 1) || (main_inprogress == 3)) // In warmup
	{
		if ( is_started == 0 ) // Has anybody already said '/start'?
		{						
			if (get_user_flags(id) & AMXMD_ACCESS)
			{
				is_started = 1 // Somebody has already said '/start'... 
					
				// Show activity, if on
				get_user_name(id,user_name,31)
				
				switch(get_cvar_num("amx_show_activity")) 
				{	
						case 2: client_print(0,print_chat,"%L %s: %L",LANG_PLAYER, "ADMIN",user_name, LANG_PLAYER, "FORCED_HALF")
						case 1: client_print(0,print_chat,"%L %L",LANG_PLAYER, "ADMIN", LANG_PLAYER, "FORCED_HALF")
				}

		
				// If there is a knife round before the first warmup session and we haven't played one already
				if( (get_cvar_num("amx_match_kniferound") == 1) && (main_kniferound_done == 0) )
				{
					misc_restart_round("2")
					
					// Now in knife round
					main_inprogress = 5
					
					set_task(4.0, "kniferound_start")
				}
				else
				{
					// Show half started message
					set_hudmessage(255, 0, 0, -1.0, 0.32, 0, 2.0, 6.0, 0.8, 0.8, -1)
					show_hudmessage(0,"--[ %s %L !!! ]--", user_name, LANG_PLAYER,"HUD_HALF_STARTED")
					
					// Show match can begin message
					set_hudmessage(255, 0, 0, -1.0, 0.36, 0, 2.0, 6.0, 0.8, 0.8, -1)
					show_hudmessage(0,"%L", LANG_PLAYER, "MATCH_CAN_BEGIN")				
					
					// Start the half
					half_start()
				}
			}
			else
			{
				client_print(id,print_console,"* [AMX MATCH] %L", id, "NEED_TO_BE_ADMIN")
			}
		}
		else
		{
			console_print(id,"* %L", id, "MATCH_ALREADY_STARTED")
			client_print(id,print_chat,"* [AMX MATCH] %L", id, "MATCH_ALREADY_STARTED")
		}
	}
	else if ((main_inprogress == 2) || (main_inprogress == 4))
	{
		console_print(id,"* %L", id, "MATCH_ALREADY_STARTED")
		client_print(id,print_chat,"* [AMX MATCH] %L", id, "MATCH_ALREADY_STARTED")
	}
	else 
	{
		console_print(id,"* %L", id, "NO_MATCH_LOADED")
		client_print(id,print_chat,"* [AMX MATCH] %L", id, "NO_MATCH_LOADED")
	}
	
	return PLUGIN_CONTINUE
}

public half_stop()
{
	new hud_message[256]
	new string_matchtype[32]
	
	new temp[32]
	
	new text[1024]
	
	new ct_score = main_score_ct[0] + main_score_ct[1] + main_score_2mm_ct + main_score_overtime
	new t_score = main_score_t[0] + main_score_t[1] + main_score_2mm_t + main_score_overtime
	
	if(is_stopped == 0)
	{
		is_stopped = 1
		
		if(main_inprogress == 2)
		{	
			// First half is finished
			format(hud_message,255,"--[ %L ]--^n%L: %s (%i) vs %s (%i)", LANG_PLAYER, "FIRST_HALF_FINISHED", LANG_PLAYER, "SCORE_IS", main_clanCT, main_score_ct[0], main_clanT, main_score_t[0])
			
			if (get_cvar_num("amx_match_screenshot") == 2) // If taking screenshots with UIDs
			{
				set_hudmessage(255, 255, 255, -1.0, 0.52, 0, 2.0, 8.0, 0.8, 0.8, -1)
			}
			else
			{
				set_hudmessage(255, 255, 255, -1.0, 0.32, 0, 2.0, 8.0, 0.8, 0.8, -1)
			}
			show_hudmessage(0,hud_message)		
			
			// Going back to warmup, (plus swap teams)
			if(get_cvar_num("amx_match_swaptype") == 1)
			{
				format(hud_message,255,"%L^n%L",LANG_PLAYER,"BACK_TO_WARMUP",LANG_PLAYER,"DONT_CHANGE_TEAM") 
			}
			else
			{ 
				format(hud_message,255,"%L",LANG_PLAYER,"BACK_TO_WARMUP")
			}
			
			if (get_cvar_num("amx_match_screenshot") == 2) // If taking screenshots with UIDs
			{
					set_hudmessage(255, 255, 255, -1.0, 0.60, 0, 2.0, 8.0, 0.8, 0.8, -1)
			}
			else
			{
					set_hudmessage(255, 255, 255, -1.0, 0.40,0, 2.0, 8.0, 0.8, 0.8, -1) 
			}
			show_hudmessage(0,hud_message)
			
			// Take screenshots
			screenshot_setup()
			
			// Stop demos
			if (main_command_demotype > 0)
			{
				demo_stop()
			}
			
			// Log stats
			if( get_cvar_num("amx_match_stats") && get_cvar_num("amx_match_otunlimited") == 0)
			{
				if( main_inovertime != 1 )
				{
#if defined(AMXMD_USE_SQL)

					stats_log_sql(1)

#else

					stats_log(1)
						
#endif						
				}
				else
				{
#if defined(AMXMD_USE_SQL)

					stats_log_sql(3)
						
#else

					stats_log(3)
#endif					
				}
			}
			
			// Swap the teams
			if (get_cvar_num("amx_match_swaptype") == 1)
			{
				set_task(1.5, "swap_teams")
			}
			
			// Swap team names as well if in a non-clan match
			if(main_command_type == 2 || main_command_type == 4)
			{
				format(main_clanCT, 31, "Terrorists")
				format(main_clanT, 31, "Counter-terrorists")			
			}
			
			vote_areVoting = 0
			
			match_increment_inprogress()	
			
			// Restart the round
			set_task(5.5, "misc_restart_round", 0, "1", 1 )
			
			// Start warmup
			set_task(7.0, "warmup_start")
		}
		else if(main_inprogress == 4)
		{
			// Delete 2mm files (Idiot-proof feature)
			if ( file_exists(config_file_2mm_main) )		// Main 2mm file
			{
				delete_file(config_file_2mm_main)
			}
			
			if ( file_exists(config_file_2mm_restart) )		// Restart 2mm file
			{
				delete_file(config_file_2mm_restart)
			}
			
			if ( file_exists(config_file_2mm_cvar) )		// Cvar 2mm file
			{
				delete_file(config_file_2mm_cvar)
			}
			
			
			// Log stats
			if( get_cvar_num("amx_match_stats") && get_cvar_num("amx_match_otunlimited") == 0)
			{
				if( main_inovertime != 1 )
				{
#if defined(AMXMD_USE_SQL)

					stats_log_sql(2)

#else

					stats_log(2)
						
#endif						
				}
				else
				{
#if defined(AMXMD_USE_SQL)

					stats_log_sql(4)
						
#else

					stats_log(4)
#endif
				}
			}
			
			if(main_command_type == 1 || main_command_type == 2 || main_in2mapmatch == 1)
			{	
				format(hud_message, 255, "--[ %L ]--^n^n%L", LANG_PLAYER, "MATCH_FINISHED", LANG_PLAYER, "WINNER_IS")
				if (get_cvar_num("amx_match_screenshot") == 2)
				{
					set_hudmessage(255, 255, 255, -1.0, 0.50, 0, 2.0, 8.0, 0.8, 0.8, -1)
				}
				else
				{
					set_hudmessage(255, 255, 255, -1.0, 0.30, 0, 2.0, 8.0, 0.8, 0.8, -1)
				}
				show_hudmessage(0,hud_message)
				
				
				if (ct_score > t_score) // CT's won
				{
					format(hud_message,255,"%s %L %i/%i", main_clanCT, LANG_PLAYER, "WITH_THE_SCORE_OF", ct_score, t_score)
					main_inovertime = 0
				}
				else if (ct_score < t_score) // Ts won
				{
					format(hud_message,255,"%s %L %i/%i ", main_clanT, LANG_PLAYER, "WITH_THE_SCORE_OF", t_score, ct_score)
					main_inovertime = 0
				}
				else if (get_cvar_num("amx_match_overtime") && (get_cvar_num("amx_match_otunlimited") || (main_inovertime != 1)) ) // Match draw and (in unlimited overtime or not in overtime)...start overtime
				{
					main_inprogress = 0
					
					// Initialize the scores
					main_score_ct[0] = 0
					main_score_ct[1] = 0
			
					main_score_t[0] = 0
					main_score_t[1] = 0
					
					// Overtime Score
					if( (main_inovertime == 1) ) // We were already in overtime
					{
						main_score_overtime += ( get_cvar_num("amx_match_otlength") * 2 )
					}
					else // We are just starting overtime
					{
						main_score_overtime = main_command_matchlength
					}
					
					main_inovertime = 1
					
					main_command_matchlength = get_cvar_num("amx_match_otlength")
					
					switch( main_command_matchtype )
					{
						case 1: // Playing maxround
						{
							format(string_matchtype, 31, "%L", LANG_PLAYER, "MAX_ROUND")
						}
						case 2: // Playing timelimit
						{
							format(string_matchtype, 31, "%L", LANG_PLAYER, "TIME_LIMIT")
						}
						case 3: // Playing winlimit
						{
							format(string_matchtype, 31, "%L", LANG_PLAYER, "WIN_LIMIT")
						}
					}
					
					format(hud_message, 255,"%L %i/%i ^n^n%L (%s %i)", LANG_PLAYER, "DRAW_MATCH_SCORE", ct_score, t_score, LANG_PLAYER, "PLAY_OVERTIME", string_matchtype, main_command_matchlength)
				}
				else	// Match draw
				{
					format(hud_message,255,"%L %i/%i", LANG_PLAYER, "DRAW_MATCH_SCORE", ct_score, t_score)
					main_inovertime = 0
				}
				
				if (get_cvar_num("amx_match_screenshot") == 2)
				{
					set_hudmessage(255, 255, 255, -1.0, 0.60, 0, 2.0, 8.0, 0.8, 0.8, -1)
				}
				else
				{
					set_hudmessage(255, 255, 255, -1.0, 0.40, 0, 2.0, 8.0, 0.8, 0.8, -1)
				}
				show_hudmessage(0,hud_message)		
				
				// Take screenshots
				screenshot_setup()
				
				vote_areVoting = 0
				
				
				if (main_inovertime == 1) // If we just started overtime
				{
					// Stop demos
					if (main_command_demotype > 0)
					{
						demo_stop()
					}
					
					// Swap teams
					if (get_cvar_num("amx_match_swaptype") == 1)
					{
						set_task(1.5, "swap_teams")
					}
					
					// Swap team names as well if in a non-clan match
					if(main_command_type == 2 || main_command_type == 4)
					{
						format(main_clanCT, 31, "Counter-terrorists")
						format(main_clanT, 31, "Terrorists")			
					}
					
					match_increment_inprogress()
					
					set_task(5.5, "misc_restart_round", 0, "1", 1 )
					
					// Start warmup
					set_task(7.0, "warmup_start")
				}
				else 
				{
					// End match and uninit 
					set_task(4.0, "uninit")
				}
			}
			else // Execute the next map in a 2 map match
			{
					
				format(hud_message,255,"%L", LANG_PLAYER, "CHANGING_TO_2ND_MAP")
				
				if (get_cvar_num("amx_match_screenshot") == 2)
				{
					set_hudmessage(255, 255, 255, -1.0, 0.60, 0, 2.0, 8.0, 0.8, 0.8, -1)
				}
				else
				{
					set_hudmessage(255, 255, 255, -1.0, 0.40, 0, 2.0, 8.0, 0.8, 0.8, -1)
				}
				
				show_hudmessage(0,hud_message)		
				
				
				// Take screenshots
				screenshot_setup()
				
				// Output main file
				write_file(config_file_2mm_main, "// Two map match main file")
				write_file(config_file_2mm_main, "// ! Do not erase this file !")
				write_file(config_file_2mm_main, "")		
				
				write_file(config_file_2mm_main, main_command_full)
				
				format(text, 1023, "%d %d", (main_score_ct[0] + main_score_ct[1]), (main_score_t[0] + main_score_t[1]))
				
				write_file(config_file_2mm_main, text)
				
				write_file(config_file_2mm_main, main_firstmap)
				
				write_file(config_file_2mm_main, main_serverpass_old)
				
				write_file(config_file_2mm_main, main_servername_old)
				
				
				// Output Cvars
				write_file(config_file_2mm_cvar, "// Two map match cvar file")
				write_file(config_file_2mm_cvar, "// ! Do not erase this file !")
				write_file(config_file_2mm_cvar, "")
				
				for(new i = 0; i < NUM_CVARS; i++)
				{
					get_cvar_string(cvar_names[i], temp, 31)
					
					format(text,1023,"%s ^"%s^"", cvar_names[i],temp)
					write_file(config_file_2mm_cvar, text)
				}
				
				set_task(4.0, "misc_changelevel", 0, main_secondmap, strlen(main_secondmap))
			}
		}
	}
	
	return PLUGIN_CONTINUE
	
}


/* 
*
*	HLTV functions
*
*/

#if defined(AMXMD_USE_HLTV)

public hltv_help(idt[])
{
	new ident = str_to_num(idt)
	
	console_print(ident,"* %L", LANG_PLAYER, "CONSOLE_HLTV_HELP")

	return PLUGIN_CONTINUE
}

public hltv_rcon_command(hltv_command[], id)
{
	// Declare variables
	new socket_address		// Contains the socket address of the hltv server 
	new socket_error = 0	// Contains the error code of the socket connection
	
	new receive[256]		// Contains the received socket command
	new send[256]			// Contains the send socket command	
	
	new hltv_challenge[13]	// Contains the hltv rcon challenge number

			
	if (hltv_id == 0) // If the hltv is not connected
	{
		client_print(id, print_console, "* %L", id, "NO_HLTV_CONNECTED")
	}
	else // If the hltv is connected
	{
		// Set hltv rcon password
		hltv_set_password()
		
		// Connect to the HLTV Proxy
		socket_address = socket_open(hltv_ip, hltv_port, SOCKET_UDP, socket_error)
		
		if (socket_error != 0)
		{
			client_print(id, print_console, "* %L - %L %i", id, "HLTV_CONNECTION_FAILED",id,"ERROR", socket_error)
			return PLUGIN_CONTINUE
		}
		
		// Send challenge rcon and receive response
		// Do NOT add spaces after the commas, you get an error about invalid function call
		setc(send, 4, 0xff)
		copy(send[4], 255, "challenge rcon")
		setc(send[18], 1, '^n')
		socket_send(socket_address, send, 255)
		socket_recv(socket_address, receive, 255)	
		
		
		// Get hltv rcon challenge number from response
		copy(hltv_challenge, 12, receive[19])
		replace(hltv_challenge, 255, "^n", "")
				
		// Set rcon command
		setc(send, 255, 0x00)
		setc(send, 4, 0xff)
		
		format(send[4],255,"rcon %s %s %s^n",hltv_challenge, hltv_password, hltv_command)
		
		// Send rcon command and close socket
		socket_send(socket_address, send, 255)
		socket_close(socket_address)
	}
	
	return PLUGIN_CONTINUE
}

public hltv_set_password()
{
	new left[64]
	new right[64]
	new hltv_rconLen
	
	if (file_exists(config_file_hltv)) 
	{	
		read_file(config_file_hltv,4,hltv_password,63,hltv_rconLen)
		
		strbreak(hltv_password,left,63,right,63)
		
		copy(hltv_password,63,right)
	}
	else
	{
		server_print("* [AMX MATCH] %L", LANG_SERVER, "HLTV_FILE_DNE")
		copy(hltv_password,63,"hltvadminpassword")
	}
	
	return PLUGIN_CONTINUE
}

public hltv_test(id, level)
{
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}

	
	server_print("* %L", LANG_SERVER, "CONSOLE_HLTV_RCON_SET", hltv_password)
	
	console_print(id,"* %L", LANG_PLAYER, "CONSOLE_HLTV_HELP")

	return PLUGIN_CONTINUE
}
#endif


/* 
*
*	Knife functions
*
*/


public kniferound_onchangeweapon(id)
{
	new weapon_name[32]
	
	if( main_inkniferound && is_user_alive(id) )
	{ 
		// Get knife's "weapon name"
		get_weaponname(CSW_KNIFE,weapon_name,31)		
		
		// Force client back to knife
		engclient_cmd(id, "weapon_knife");
	}

	return PLUGIN_CONTINUE
}

/*

public kniferound_pickteam( id )
{	
	new message[16]
	
	new CsTeams:team
	
	new player_team
	
	new temp[32]
	
	
	if( main_inkniferound == 1 && !get_cvar_num("amx_match_krvoteteam"))
	{	
		read_argv(1,message,15)
		
		team = cs_get_user_team( id )
		
		if ( team != CS_TEAM_T )
		{
			player_team = 1
		}
		else if( team != CS_TEAM_CT )
		{
			player_team = 2
		}
		
		if( player_team == main_kniferound_won ) // User is on the team that won
		{
			// No more knife round  ^_^
			main_inkniferound = 0
			main_kniferound_won = 0
			
			// We already played a knife round
			main_kniferound_done = 1
			
			// Remove 'pick a team' message
			if(task_exists(TASKID_KNIFEROUND_MESSAGE))
			{
				remove_task(TASKID_KNIFEROUND_MESSAGE)
			}
	
			
			if (equal(message, "/ct")) // User picked CT
			{	
				if( player_team == 1 ) // If user's team was not already CT
				{
					swap_teams()
					
					// Swap team names as well if in clan match
					if(main_command_type == 1 || main_command_type == 3)
					{
						copy(temp, 31, main_clanT)
						copy(main_clanT, 31, main_clanCT)
						copy(main_clanCT, 31, temp)
					}
				}
			}
			else if (equal(message, "/t")) // User picked T and user is on the team that won
			{
				if( player_team == 2 ) // If user's team was not already T
				{
					swap_teams()
					
					// Swap team names as well if in a clan match
					if(main_command_type == 1 || main_command_type == 3)
					{
						copy(temp, 31, main_clanT)
						copy(main_clanT, 31, main_clanCT)
						copy(main_clanCT, 31, temp)
					}					
				}			
			}
			
			misc_restart_round("2")
			
			main_inprogress = 0

			// Now in warmup
			set_task(2.0, "match_increment_inprogress")
			
			// Initialize the scores
			main_score_ct[0] = 0
			main_score_ct[1] = 0
	
			main_score_t[0] = 0
			main_score_t[1] = 0
	
			// Start warmup
			set_task(2.0, "warmup_start")								
		}
		else
		{
			console_print(id, "* %L", id, "KNIFE_NOT_ON_TEAM")
			client_print(id, print_chat, "* [AMX MATCH] %L", id, "KNIFE_NOT_ON_TEAM")
		}
	}
	
	return PLUGIN_CONTINUE	
}

*/

public kniferound_start()
{	
	// We are now in a knife round
	main_inkniferound = 1
	
	set_task(4.0, "kniferound_start_printmessage")
    
    	return PLUGIN_CONTINUE
}
 
public kniferound_start_printmessage()
{
	new players[32]
	new number

	// Tell players that the knife round started
	get_players(players,number)
	
	for(new i = 0; i < number ; i++)
	{
		new item = players[i]
		
		client_print(item, print_chat, "* [AMX MATCH] %L", players[i], "KNIFE_ROUND_STARTED")
		client_print(item, print_console, "* [AMX MATCH] %L", players[i], "KNIFE_ROUND_STARTED")
		
		kniferound_onchangeweapon(item)
	}
	
	return PLUGIN_CONTINUE
}

/*

public kniferound_stop( )
{	
	
	// Show the pickteams message, then show again every thirty (30) seconds after that until stopped
	set_task(4.0, "kniferound_stop_printmessage", TASKID_KNIFEROUND_MESSAGE)
	set_task(30.0, "kniferound_stop_printmessage", TASKID_KNIFEROUND_MESSAGE, "", 0, "b")
	
	// Start a vote here...or just wait for the team to say '/ct' or /t
	// Next version definitely start a vote, much much better...
	
	return PLUGIN_CONTINUE
}

public kniferound_stop_printmessage()
{
	new players[32]
	new number
	
	// Tell the team that they can say '/ct' or '/t'
	if( main_kniferound_won == 2 )
	{
		get_players(players,number,"e","CT")
	}
	else
	{
		get_players(players,number,"e","TERRORIST")
	}


	for(new i = 0; i < number ; i++)
	{
		client_print(players[i], print_chat, "* [AMX MATCH] %L", players[i], "KNIFE_SAY_CT_OR_T")
	}
	
	return PLUGIN_CONTINUE
}

*/

public kniferound_teamwin()
{
	new param[12]	
	
	if( main_inkniferound == 1 )
	{
		read_data(2,param,8)
		
		if (param[7]=='c') //%!MRAD_ctwin
		{
			main_kniferound_won = 2	// The cts won
				
			// kniferound_stop()
			
			kniferound_vote_team()
		}
		else //%!MRAD_terwin
		{
			main_kniferound_won = 1	// The ts won
				
			// kniferound_stop()
			
			kniferound_vote_team()
		}
	}
	
	return PLUGIN_CONTINUE
}

public kniferound_vote_check(id)
{
	new temp[32]

	if ((vote_option[0] > vote_option[1]) && (main_kniferound_won == 2))
	{
		swap_teams()
		
		// Swap team names as well if in clan match
		if(main_command_type == 1 || main_command_type == 3)
		{
			copy(temp, 31, main_clanT)
			copy(main_clanT, 31, main_clanCT)
			copy(main_clanCT, 31, temp)
		}
	}
	else if ((vote_option[1] > vote_option[0]) && (main_kniferound_won == 1))
	{
		swap_teams()
		
		// Swap team names as well if in clan match
		if(main_command_type == 1 || main_command_type == 3)
		{
			copy(temp, 31, main_clanT)
			copy(main_clanT, 31, main_clanCT)
			copy(main_clanCT, 31, temp)
		}
	}
	
	// No more knife round  ^_^
	main_inkniferound = 0
	main_kniferound_won = 0
			
	// We already played a knife round
	main_kniferound_done = 1
	
	
	
	misc_restart_round("2")
	
	main_inprogress = 0
	
	// Now in warmup
	set_task(2.0, "match_increment_inprogress")
	
	// Initialize the scores
	main_score_ct[0] = 0
	main_score_ct[1] = 0
	
	main_score_t[0] = 0
	main_score_t[1] = 0
	
	// Start warmup
	set_task(2.0, "warmup_start")
	
	return PLUGIN_CONTINUE
}

public kniferound_vote_count(id,key)
{
	new user_name[32]	
	
	if ( get_cvar_float("amx_vote_answers") )
	{		
		get_user_name(id, user_name, 31)
	
		client_print(0,print_chat,"* %L %L", LANG_PLAYER, "OVERTIME_VOTE", user_name, LANG_PLAYER, key ? "CT" : "TERRORIST")
	}
	
	vote_option[key]++
	
	return PLUGIN_HANDLED
}

public kniferound_vote_team()
{
	 new menu_message[256]
	 new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0
	 
	 vote_areVoting = 1
	 
	 format(menu_message, 255, "\y[AMX Match] %L\w^n^n1. %L^n2. %L", LANG_SERVER, "KNIFEROUND_QUESTION", LANG_PLAYER, "TERRORIST", LANG_PLAYER, "CT")

	 set_cvar_float("amx_last_voting",  get_gametime() + vote_time )
	 show_menu(0,(1<<0)|(1<<1), menu_message, floatround(vote_time))
 
	 set_task(vote_time,"kniferound_vote_check")
	 
	 client_print(0, print_chat, "* %L", LANG_PLAYER, "OVERTIME_VOTE_START")
	 
	 vote_option[0] = 0
	 vote_option[1] = 0
	 
	 return PLUGIN_HANDLED
}

/* 
*
*	Main Match functions
*match()  <--don't remove
*
*/


public match_increment_inprogress()
{
	main_inprogress++

	return PLUGIN_CONTINUE
}

public match_pug(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
	{	
		client_print(id,print_console,"* [AMX MATCH] %L: %L", id, "PUG_STYLE", id, (get_cvar_num("amx_match_pugstyle") == 1 ? "ON" : "OFF"))
		
		return PLUGIN_HANDLED
	}
	
	new command[16]
	new command_num
	
	read_argv(1, command, 15)
	
	command_num = str_to_num( command )
	
	if(equali(command, "on") || command_num == 1)
	{
		// Starting PUG
		client_print(id,print_console,"* [AMX MATCH] %L...",id, "PUG_START")
		client_print(id,print_chat,"* [AMX MATCH] %L...",id, "PUG_START")
		
		match_pug_start()
	}
	else if(equali(command, "off") || command_num == 0)
	{
		// Stopping PUG
		client_print(id,print_console,"* [AMX MATCH] %L...",id, "PUG_STOP")
		client_print(id,print_chat,"* [AMX MATCH] %L...",id, "PUG_STOP")
		
		match_pug_stop()
	}

	return PLUGIN_CONTINUE
}


public match_pug_start()
{	
	if( file_exists(config_file_pug) )
	{
			new command[64]
			new command_length
			
			// Read command from config file
			read_file(config_file_pug,6,command,63,command_length)	
			
			// Set the cvar so PUG continues for every map-change/server-restart
			set_cvar_num("amx_match_pugstyle", 1)
			
			save_settings(config_file_plugin)
			
			// Run the match
			server_cmd(command)
	}		
	else
	{
		server_print("* [AMX MATCH] %L", LANG_SERVER, "PUG_FILE_DNE")
	}

	return PLUGIN_CONTINUE
}


public match_pug_stop()
{
	set_cvar_num("amx_match_pugstyle", 0)

	save_settings(config_file_plugin)

	return PLUGIN_CONTINUE
}


public match_restart(id,level)
{
	// Declare variables
	new user_name[32]
	new user_authid[16]
	new user_id
	
	
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}
	
	
	if (main_inprogress > 0) // If we are in a match
	{	
		// Remove timelimit tasks
		if ( task_exists( TASKID_DECREMENT_SECONDS ) )
		{
			remove_task( TASKID_DECREMENT_SECONDS )
		}
		
		if ( task_exists( TASKID_TIMER_SHOW ) )
		{
			remove_task( TASKID_TIMER_SHOW )
		}
		
		// Remove 'pick a team' message
		if(task_exists(TASKID_KNIFEROUND_MESSAGE))
		{
			remove_task(TASKID_KNIFEROUND_MESSAGE)
		}
		
		// Get user's name
		get_user_name(id, user_name, 31)
		
		
		// Hud message for match restart
		set_hudmessage(208, 12, 2, -1.0, 0.32, 0, 2.0, 6.0, 0.8, 0.8, -1)
		show_hudmessage(0,"--[ %s %L ]--", user_name, LANG_PLAYER, "HUD_MATCH_RESTARTED")
		
		// Log
		get_user_authid(id, user_authid, 15)
		
		user_id = get_user_userid(id)
		// Log to amxx log
		log_amx("^"%s<%d><%s><>^" %L", user_name, user_id, user_authid, LANG_SERVER, "RESTARTED_MATCH")
		
		// Log to hl log
		log_message("^"%s<%d><%s><>^" %L", user_name, user_id, user_authid, LANG_SERVER, "RESTARTED_MATCH")
		
		// Server console
		server_print("^"%s<%d><%s><>^" %L", user_name, user_id, user_authid, LANG_SERVER, "RESTARTED_MATCH")
		
		// Show activity, if on
		switch(get_cvar_num("amx_show_activity")) 
		{
			case 2: client_print(0,print_chat,"%L %s: %L", LANG_PLAYER, "ADMIN",user_name, LANG_PLAYER, "RESTARTED_MATCH")
			case 1: client_print(0,print_chat,"%L %L", LANG_PLAYER, "ADMIN", LANG_PLAYER, "RESTARTED_MATCH")
		}			
		
		
		// Reset server
		uninit_resetserver()
		
		
		// Stats
		// If stats have been logged
		if( get_cvar_num("amx_match_stats") == 1 && (main_inprogress == 3 || main_inprogress == 4 || main_in2mapmatch == 1) && get_cvar_num("amx_match_otunlimited") == 0)
		{

#if defined(AMXMD_USE_SQL)
			
			stats_resetmatch_sql()
			
#else			
			stats_resetmatch()

#endif

		}
		
		if ( (main_command_type == 1) || (main_command_type == 2) ) // If the match command is amx_match or amx_match2
		{
			// Uninit the variables
			uninit_variables()
			
			// Execute the server command to restart the match
			server_cmd("%s", main_command_full)
		}
		else // If the match command is amx_match3 or amx_match4
		{
			if( main_in2mapmatch == 1 )
			{
				write_file(config_file_2mm_restart, "")
				
				set_task(4.0, "misc_changelevel", 0, main_firstmap, strlen(main_firstmap))
			}
			else
			{
				// Uninit the variables
				uninit_variables()
				
				// Execute the server command to restart the match
				server_cmd("%s", main_command_full)
			}			
		}
	}
	else
	{
		client_print(id, print_chat,"* [AMX MATCH] %L", id, "NO_MATCH_TO_RESTART")
		console_print(id, "* %L", id, "NO_MATCH_TO_RESTART")
	}
	
	return PLUGIN_CONTINUE
}


public match_start(id,level,cid)
{
	// Declare variables
	new command[16]			// Match command
	new check_type[32]	 		// Match type, used to check between mr, tl, wl
	new second_map[64]			// Name of second map for 2 map matches
	new demo_type[32]			// Demo type, used to check between recdemo, rechltv, recboth
	
	new config_file[64]			// Config file for the match	
	
	new server_pass[32]			// Match password
	
	new host_name[64]			// Match hostname	
	
	new match_type[32]			// Used for the first half of match_type: 'mr'
	
	new string_matchtype[32]		// Match type

	new left[64]
	new right[64]

	new user_name[32]			// User's name
	new user_authid[16]			// User's SteamID
	new user_id				// User's player id
	
	new hud_message[256]		// Hud messages
	
	new config_files[AMXMD_MAX_CFGFILES][64]
	new config_files_pos
	
	new leagues_dir
	
	new temp[64]
	new temp2[64]
	
#if defined(AMXMD_USE_HLTV)
	
	new hltv_console_help[64]

#endif

	// Read the command (e.g. amx_match)
	read_argv(0,command,15)
	
	// Figure out what the command was (amx_match, amx_match2, 
	if (equal(command,"amx_match"))
	{
		main_command_type = 1
	}
	else if (equal(command,"amx_match2"))
	{
		main_command_type = 2
	}
	else if (equal(command,"amx_match3"))
	{
		main_command_type = 3
	}
	else if (equal(command,"amx_match4"))
	{
		main_command_type = 4
	}
	
	
	// Make sure they have access and inputted enough arguments
	if (main_command_type == 1 && !cmd_access(id,level,cid,5)) // amx_match = 5 arguments
	{
		return PLUGIN_HANDLED
	}
	else if (main_command_type == 2 && !cmd_access(id,level,cid,3)) // amx_match2 = 3 arguments
	{
		return PLUGIN_HANDLED
	}
	else if (main_command_type == 3 && !cmd_access(id,level,cid,6)) // amx_match3 = 6 arguments
	{
		return PLUGIN_HANDLED
	}	
	else if (main_command_type == 4 && !cmd_access(id,level,cid,4)) // amx_match4 = 4 arguments
	{
		return PLUGIN_HANDLED
	}
	
	
	if (main_inprogress == 0) // If there is no match running
	{	
		// Exec AMXMD.cfg
		if (file_exists(config_file_plugin)) 
		{
			server_cmd("exec %s", config_file_plugin)
		}
	
	
	//////// Input
	
		// Read the arguments
		if (main_command_type == 1)
		{
			// Read clan names
			read_argv(1, main_clanCT, 31)
			read_argv(2, main_clanT, 31)
			
			// Read matchtype and length
			read_argv(3, check_type, 31)			

			// Read match config file
			read_argv(4, config_file_match, 31)

			// Read demo type
			read_argv(5, demo_type, 31)
		}
		else if (main_command_type == 2)
		{	
			// Read matchtype and length
			read_argv(1, check_type, 31)
			
			// Read match config file
			read_argv(2, config_file_match, 31)
			
			// Read demo type
			read_argv(3, demo_type, 31)		
		}
		else if (main_command_type == 3)
		{
			// Read clan names
			read_argv(1, main_clanCT, 31)
			read_argv(2, main_clanT, 31)
			
			// Read matchtype and length
			read_argv(3, check_type, 31)			

			// Read match config file
			read_argv(4, config_file_match, 31)

			// Read second map's name
			read_argv(5, second_map, 63)

			// Read demo type
			read_argv(6, demo_type, 31)	
		}
		else if (main_command_type == 4)
		{
			// Read matchtype and length
			read_argv(1, check_type, 31)
			
			// Read match config file
			read_argv(2,config_file_match,31)
			
			// Read second map's name
			read_argv(3, second_map, 63)
			
			// Read demo type
			read_argv(4, demo_type, 31)
		}
		
		
	//////// Processing
		
	// Clan names
		// Set the clan names if in amx_match2 or amx_match4
		if(main_command_type == 2 || main_command_type == 4)
		{
			format(main_clanCT, 31, "Counter-terrorists")
			format(main_clanT, 31, "Terrorists")			
		}
		
		
	// Match type
		// Copy the first two characters from check_type: 'mr15' -> 'mr'
		copy(match_type, 2, check_type)
		
		// Set matchtype and matchlength variables
		if(equal(match_type, "mr"))
		{
			strtok(check_type, left, 31, right, 31, 'r') // splits string into left ("m") and right ("15")
			
			main_command_matchlength = str_to_num(right)
			
			main_command_matchtype = 1
		}
		else if(equal(match_type, "tl"))
		{
			strtok(check_type, left, 31, right, 31, 'l') // splits string into left ("t") and right ("30")
			
			main_command_matchlength = str_to_num(right)			
			
			main_command_matchtype = 2
		}
		else if(equal(match_type, "wl"))
		{
			strtok(check_type, left, 31, right, 31, 'l') // splits string into left ("w") and right ("15")
			
			main_command_matchlength = str_to_num(right)				
			
			main_command_matchtype = 3
		}
		else
		{
			console_print(id,"* %L", id, "MATCHTYPE_NOT_SUPPORTED")
			
			return PLUGIN_HANDLED
		}
		
		
	// Match config file
		format(config_file,63,"%s/%s.cfg", config_dir_leagues, config_file_match)

		if (!(file_exists(config_file))) 
		{
			format(config_file, 63, "%s.cfg", config_file_match)
			
			if (!(file_exists(config_file)))
			{
				console_print(id,"* | %s |", config_file)
				console_print(id,"* %L", id, "CONFIG_FILE_DNE")
				
				leagues_dir = open_dir(config_dir_leagues, temp, 63)
				
				if( leagues_dir != 0 )
				{
					remove_filepath ( temp, temp2, 63 )
					
					strtok(temp2, left, 63, right, 63, '.')
				
					if(equali( right , ".cfg" ) && !equali( left , "default" ) && !equali( left , "ffa" ))
					{
						copy (left, 63, config_files[config_files_pos++])
					}			
					
					while( next_file(leagues_dir, temp, 63) && (config_files_pos < AMXMD_MAX_CFGFILES) )
					{
						remove_filepath ( temp, temp2, 63 )
						
						strtok(temp2, left, 63, right, 63, '.')
						
						if(equali( right , ".cfg" ) && !equali( left , "default" ) && !equali( left , "ffa" ))
						{
							copy (left, 63, config_files[config_files_pos++])
						}
					}
					
					close_dir( leagues_dir )
					
					// Search the main directory
					leagues_dir = open_dir(".", temp, 63)
				
					if( leagues_dir != 0 )
					{
						remove_filepath ( temp, temp2, 63 )
						
						strtok(temp2, left, 63, right, 63, '.')
					
						if(equali( right , ".cfg" ) && !equali( left , "default" ) && !equali( left , "ffa" ))
						{
							copy (left, 63, config_files[config_files_pos++])
						}			
						
						while( next_file(leagues_dir, temp, 63) && (config_files_pos < AMXMD_MAX_CFGFILES) )
						{
							remove_filepath ( temp, temp2, 63 )
							
							strtok(temp2, left, 63, right, 63, '.')
							
							if(equali( right , ".cfg" ) && !equali( left , "default" ) && !equali( left , "ffa" ))
							{
								copy (left, 63, config_files[config_files_pos++])
							}
						} 
	
						close_dir( leagues_dir )
	
	
	
						// Print the list to console
						console_print(id,"* %L", id, "CONFIG_FILE_LIST")
						
						for(new i = 0; i < config_files_pos; i++)
						{
							console_print(id, "*   %s", config_files[i])
						}
					}
				}
				
				return PLUGIN_HANDLED
			}
		}
	
	
	// Second map
		if(main_command_type == 3 || main_command_type == 4)
		{
			if (is_map_valid(second_map))
			{
				copy( main_secondmap, 63, second_map)
			}
			else
			{
				console_print(id,"* %L", id, "INVALID_SECOND_MAP")
				
				return PLUGIN_HANDLED
			}
		}
		
		get_mapname( main_firstmap, 63 )
		
		// Delete 2mm files (Idiot-proof feature)
		if ( file_exists(config_file_2mm_main) )		// Main 2mm file
		{
			delete_file(config_file_2mm_main)
		}
		
		if ( file_exists(config_file_2mm_restart) )		// Restart 2mm file
		{
			delete_file(config_file_2mm_restart)
		}
		
		if ( file_exists(config_file_2mm_cvar) )		// Cvar 2mm file
		{
			delete_file(config_file_2mm_cvar)
		}	
		
		
	// Demos
		if (equali(demo_type, "recdemo"))
		{
			main_command_demotype = 1
		}
		#if defined(AMXMD_USE_HLTV)
		else if (equal(demo_type,"rechltv")) 
		{
			main_command_demotype = 2
			
			num_to_str(id,temp,15)
			
			hltv_help( temp )
		}
		else if (equal(demo_type,"recboth"))
		{
			main_command_demotype = 3
			
			num_to_str(id,temp,15)
			
			hltv_help( temp )
		}
		#endif
		else if(demo_type[0] != 0)
		{
			console_print(id,"* | %s |", demo_type)
			console_print(id,"* %L", id, "INVALID_DEMO_TYPE")
			
			return PLUGIN_HANDLED
		}
		
	// Cvars
		cvar_endtype = get_cvar_num("amx_match_endtype")
		
		// Make sure endtype is correct for match
		if(main_command_matchtype == 1 && cvar_endtype == 2)
		{
			cvar_endtype = 0
		}
	
		if ( get_cvar_num("amx_match_shield") == 0)
		{
			server_cmd("amx_restrict off shield")
			client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "SHIELD_UNRESTRICTED")
		}
		else
		{
			server_cmd("amx_restrict on shield")
			client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "SHIELD_RESTRICTED")			
		}

		// Set server password
		if(get_cvar_num("amx_match_password") == 1)
		{
			// Set old server password
			get_cvar_string("sv_password", main_serverpass_old, 31)
			
			// Get match password
			get_cvar_string("amx_match_password2", server_pass, 31)

			// Set server password to match password
			set_cvar_string("sv_password", server_pass)
			
			client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "PASSWORD_SET")
			
			if( id != 0 )
			{
				client_print(id,print_chat,"* [AMX MATCH] %L : |  %s   |", id, "PASSWORD_SET_TO", server_pass)
			}
		}
		
			
		// Set hostname
		if(get_cvar_num("amx_match_hostname") == 1)
		{
			copy(config_file, 63, config_file_match)
			strtoupper(config_file)
			
			// Get old(current) hostname
			get_cvar_string("hostname", main_servername_old, 63)
			
			// Format match hostname
			if (main_command_type == 1 || main_command_type == 3)
			{
				format(host_name, 63, "%s vs. %s | %s %L", main_clanCT, main_clanT, config_file, LANG_SERVER, "CS_MATCH_IN_PROGRESS")
			}
			else
			{
				format(host_name, 63, "%s %L", config_file, LANG_SERVER, "CS_MATCH_IN_PROGRESS")	
			}
			
			// Set hostname to match hostname
			set_cvar_string("hostname", host_name)
		}				
	
	
	// Logging
		
		// Get user's name
		get_user_name(id, user_name, 31)
		
		// Get user's SteamID
		get_user_authid(id, user_authid, 15)
		
		// Get user's userid
		user_id = get_user_userid(id)
	
		// Format log messages
		if (main_command_type == 1)
		{
			format(hud_message,199,"%s vs %s %s %s.cfg %s", main_clanCT, main_clanT, check_type, config_file_match, demo_type)
		}
		else if (main_command_type == 2)
		{
			format(hud_message,199,"%s %s.cfg %s", check_type, config_file_match, demo_type)
		}
		else if (main_command_type == 3)
		{
			format(hud_message,199,"%s vs %s %s %s.cfg %s %s", main_clanCT, main_clanT, check_type, config_file_match, second_map, demo_type)
		}
		else if (main_command_type == 4)
		{
			format(hud_message,199,"%s %s.cfg %s %s", check_type, config_file_match, second_map, demo_type)
		}
		
		// Log it
		// AMXX
		log_amx("^"%s<%d><%s><>^" %L ^"%s^"", user_name, user_id, user_authid, LANG_SERVER, "STARTED_MATCH", hud_message)
		
		// HL
		log_message("^"%s<%d><%s><>^" %L ^"%s^"", user_name, user_id, user_authid, LANG_SERVER, "STARTED_MATCH", hud_message)
	
		// Server console
		server_print("^"%s<%d><%s><>^" %L ^"%s^"", user_name, user_id, user_authid, LANG_SERVER, "STARTED_MATCH", hud_message)
	
	
		// Show activity, if on
		switch(get_cvar_num("amx_show_activity")) 
		{	
				case 2: client_print(0,print_chat,"%L %s: %L ^"%s^"", LANG_PLAYER, "ADMIN", user_name, LANG_PLAYER, "STARTED_MATCH", hud_message)
				case 1: client_print(0,print_chat,"%L %L ^"%s^"", LANG_PLAYER, "ADMIN", LANG_PLAYER, "STARTED_MATCH", hud_message)
		}

	// Hud messages
	
		switch( main_command_matchtype )
		{
			case 1: // Playing maxround
			{	
				format( string_matchtype, 31, "%L", LANG_PLAYER, "MAX_ROUND")
			}
			case 2: // Playing timelimit
			{
				format( string_matchtype, 31, "%L", LANG_PLAYER, "TIME_LIMIT")
			}
			case 3: // Playing winlimit
			{
				format( string_matchtype, 31, "%L", LANG_PLAYER, "WIN_LIMIT")
			}
		}
	
		if (main_command_type == 1)
		{		
			format(hud_message,199,"--[ %L : %s(CT) vs %s(T) ]--^n^n%L %s %d (%s config)",LANG_PLAYER, "MATCH_LOADED", main_clanCT, main_clanT, LANG_PLAYER, "MATCH_TYPE", string_matchtype, main_command_matchlength, config_file_match)
		}
		else if (main_command_type == 2)
		{
			format(hud_message,199,"--[ %L ]--^n^n %L %s %d (%s config)", LANG_PLAYER, "MATCH_LOADED", LANG_PLAYER, "MATCH_TYPE", string_matchtype, main_command_matchlength, config_file_match)
		}
		else if (main_command_type == 3)
		{		
			format(hud_message,199,"--[ %L : %s(CT) vs %s(T) ]--^n^n%L %s %d (%s config) %L %s",LANG_PLAYER, "MATCH_LOADED", main_clanCT, main_clanT, LANG_PLAYER, "MATCH_TYPE", string_matchtype, main_command_matchlength, config_file_match, LANG_PLAYER, "SECOND_MAP", second_map)
		}
		else if (main_command_type == 4)
		{
			format(hud_message,199,"--[ %L ]--^n^n %L %s %d (%s config) %L %s", LANG_PLAYER, "MATCH_LOADED", LANG_PLAYER, "MATCH_TYPE", string_matchtype, main_command_matchlength, config_file_match, LANG_PLAYER, "SECOND_MAP", second_map)
		}
		
		// Set and show hud message
		set_hudmessage(0, 255, 255, -1.0, 0.30, 0, 2.0, 6.0, 0.8, 0.8, -1)
		show_hudmessage(0, hud_message)	
		
		if(main_command_demotype > 0)
		{
   			format(hud_message, 199, "%L^n %L ", LANG_PLAYER, "ENTER_WARMUP", LANG_PLAYER, "DEMOS_AUTORECORDED") 
		}
		else
		{ 
   			format(hud_message,199,"%L ",LANG_PLAYER,"ENTER_WARMUP")
   		}
   		
		set_hudmessage(0, 255, 255, -1.0, 0.40, 0, 2.0, 6.0, 0.8, 0.8, -1)
		show_hudmessage(0, hud_message)
		
	
	// HLTV Demos	
		
		#if defined(AMXMD_USE_HLTV)
		
		if (main_command_demotype > 1)
		{
			console_print(id, "* %L", id, "CONSOLE_HLTV_RCON_SET", hltv_password)
			if (hltv_id == 0)
			{
				console_print(id,"* %L", id, "NO_HLTV_CONNECTED" )
				console_print(id,"* %L", id, "CONSOLE_HLTV_NO_DEMO_RECORD" )			
			}
			else 
			{
				console_print(id,"* %L (%s:%i)...", id, "CONSOLE_HLTV_TESTING", hltv_ip,hltv_port)
				
				format( hltv_console_help, 63, "say %L =)", LANG_SERVER, "HLTV_CONFIGURED" )
				hltv_rcon_command(hltv_console_help, id)
				
				console_print(id,"* %L", id, "CONSOLE_HLTV_TESTING_HELP" )
			}
		}
		else
		{
			console_print(id,"* %L", id, "CONSOLE_HLTV_NO_DEMO_RECORD" )
		}
		#else
			console_print(id,"* %L", id, "CONSOLE_HLTV_NO_DEMO_RECORD" )
		#endif
		
		// Format the main match command
		misc_format_command()
		
		
		// If we are randomizing teams first
		if( get_cvar_num("amx_match_randomizeteams") )
		{
			randomize_teams(id, AMXMD_ACCESS)
		}


		// Now in warmup
		set_task(2.0, "match_increment_inprogress")
		
		// Initialize the scores
		main_score_ct[0] = 0
		main_score_ct[1] = 0

		main_score_t[0] = 0
		main_score_t[1] = 0

		// Start warmup
		set_task(2.0, "warmup_start")	
	
	}
	else
	{
		console_print(id, "* %L", id, "MATCH_IN_PROGRESS")
		client_print(id, print_chat, "* [AMX MATCH] %L", id, "MATCH_IN_PROGRESS")
	}

	return PLUGIN_CONTINUE
}


public match_start_2mm()
{
	new match_type[32]

	new hud_message[256]
	
	new temp[256]

	new left[256]
	new right[256]

	new left_tok[32]
	new right_tok[32]
	
	new command_length
	
#if defined(AMXMD_USE_HLTV)
	
	new hltv_console_help[64]

#endif
	
	
	// Execute cvar file
	if (file_exists(config_file_2mm_cvar)) 
	{	
		server_cmd("exec %s", config_file_2mm_cvar)
	}
	
	// Read fourth line of main file (first three lines are the file comments and a blank line)
	read_file(config_file_2mm_main, AMXMD_2MM_COMMAND, main_command_full, 255, command_length)	
	
	// Split the line apart on the space
	strbreak(main_command_full, left, 255, right, 255)
	
	// Set match command
	if (equal(left,"amx_match3"))
	{
		main_command_type = 3
	}
	else if (equal(left,"amx_match4"))
	{
		main_command_type = 4
	}

// Clan names	
	if(main_command_type == 3)
	{
		// Split the line apart on the space
		strbreak(right, left, 255, right, 255)
		
		// Copy the CT clan name
		copy(main_clanCT, 31, left)
		
		// Split the line apart on the space
		strbreak(right, left, 255, right, 255)
		
		// Copy the T clan name
		copy(main_clanT, 31, left)
	}
	else // Set the clan names if in amx_match4
	{
		format(main_clanCT, 31, "Counter-terrorists")
		format(main_clanT, 31, "Terrorists")	
	}

	// Split the line apart on the space
	strbreak(right, left, 255, right, 255)
	
	// Copy the first two characters from check_type: 'mr15' -> 'mr'
	copy(match_type, 2, left)
	
	// Set matchtype and matchlength variables
	if(equal(match_type, "mr"))
	{
		strtok(left, left_tok, 31, right_tok, 31, 'r') // splits string into left ("m") and right ("15")
		
		main_command_matchlength = str_to_num(right_tok)
		
		main_command_matchtype = 1
	}
	else if(equal(match_type, "tl"))
	{
		strtok(left, left_tok, 31, right_tok, 31, 'l') // splits string into left ("t") and right ("30")
		
		main_command_matchlength = str_to_num(right_tok)			
		
		main_command_matchtype = 2
	}
	else if(equal(match_type, "wl"))
	{
		strtok(left, left_tok, 31, left_tok, 31, 'l') // splits string into left ("w") and right ("15")
		
		main_command_matchlength = str_to_num(right_tok)				
		
		main_command_matchtype = 3
	}	

	// Split the line apart on the space
	strbreak(right, left, 255, right, 255)
	
	// Match config file
	copy(config_file_match, 63, left)

	// Split the line apart on the space
	strbreak(right, left, 255, right, 255)
	
	// Split the line apart on the space
	strbreak(right, left, 255, right, 255)
	
	if (equali(left, "recdemo"))
	{
		main_command_demotype = 1
	}
	#if defined(AMXMD_USE_HLTV)
	else if (equal(left,"rechltv")) 
	{
		main_command_demotype = 2
	}
	else if (equal(left,"recboth"))
	{
		main_command_demotype = 3
	}
	#endif


	// Show "Should Be" message, then again every 15 seconds
	warmup_print_message_shouldbe()
	
	set_task(15.0, "warmup_print_message_shouldbe", TASKID_MESSAGE_SHOULDBE, "", 0, "b")

	if(main_command_demotype > 0)
	{
		format(hud_message, 255, "%L^n %L ", LANG_PLAYER, "ENTER_WARMUP", LANG_PLAYER, "DEMOS_AUTORECORDED") 
	}
	else
	{ 
		format(hud_message,255,"%L ",LANG_PLAYER,"ENTER_WARMUP")
	}
	
	set_hudmessage(0, 255, 255, -1.0, 0.40, 0, 2.0, 6.0, 0.8, 0.8, -1)
	show_hudmessage(0, hud_message)
	

	// HLTV Demos
	#if defined(AMXMD_USE_HLTV)
	
	if (main_command_demotype > 1)
	{
			server_print("* %L", LANG_SERVER, "CONSOLE_HLTV_RCON_SET", hltv_password)
			
			if (hltv_id == 0)
			{
				server_print("* %L", LANG_SERVER, "NO_HLTV_CONNECTED" )
				server_print("* %L", LANG_SERVER, "CONSOLE_HLTV_NO_DEMO_RECORD" )			
			}
			else 
			{	
				server_print("* %L (%s:%i)...", LANG_SERVER, "CONSOLE_HLTV_TESTING", hltv_ip, hltv_port)
				
				format( hltv_console_help, 63, "say %L =)", LANG_SERVER, "HLTV_CONFIGURED" )
				hltv_rcon_command(hltv_console_help, 0)
				
				server_print("* %L", LANG_SERVER, "CONSOLE_HLTV_TESTING_HELP" )
			}
	}
	
	#endif
	
	
	// Now in warmup
	match_increment_inprogress()
	
	// Set scores	
	// Read fifth line of main file (first three lines are the file comments and a blank line)
	read_file(config_file_2mm_main, AMXMD_2MM_SCORES, temp, 255, command_length)
	
	// Split the line apart on the space
	strbreak(temp, left, 255, right, 255)			
	
	// Input into correct variables for scores
	main_score_2mm_ct = str_to_num(left)
	main_score_2mm_t = str_to_num(right)
	
	
	// Set first map variable	
	// Read sixth line of main file (first three lines are the file comments and a blank line)
	read_file(config_file_2mm_main, AMXMD_2MM_FIRSTMAP, main_firstmap, 63, command_length)
	
	
	// Set old password variable
	// Read seventh line of main file (first three lines are the file comments and a blank line)
	read_file(config_file_2mm_main, AMXMD_2MM_OLDNAME, main_serverpass_old, 63, command_length)
	
	
	// Set old hostname variable
	// Read eighth line of main file (first three lines are the file comments and a blank line)
	read_file(config_file_2mm_main, AMXMD_2MM_OLDPASS, main_servername_old, 63, command_length)
	
	// Start warmup
	warmup_start()	

	return PLUGIN_CONTINUE
}


public match_start_init()
{
	new temp[256]
	new command_length
	
	
	if (file_exists(config_file_2mm_main)) // If we are in a two map match
	{	
		if (file_exists(config_file_2mm_restart)) // If a two map match was restarted
		{	
			// Read third line (first two lines are the file comment and a blank line)
			read_file(config_file_2mm_main, AMXMD_2MM_COMMAND, temp, 255, command_length)
			
			// Delete the files
			delete_file(config_file_2mm_main)
			delete_file(config_file_2mm_cvar)
			delete_file(config_file_2mm_restart)			
			
			// Execute the match command
			server_cmd("%s", temp)
		}
		else // If this is the second map and it was not a restart
		{
			main_in2mapmatch = 1
			
			match_start_2mm()	
		}
	}
	else if( get_cvar_num("amx_match_pugstyle") == 1 )
	{
		match_pug_start()
	}
}


public match_start_menu(id)
{
	new command[256]		
	
	new match_type[32]
	new match_config[32]
	new demo_type[16]
	
	// Format the match type
	switch(menu_selections[id][MENU_SELECTION_MATCHTYPE])
	{
		case 0: format(match_type, 31, "mr%s", menu_lengthlist[menu_selections[id][MENU_SELECTION_MATCHLENGTH]])
		case 1: format(match_type, 31, "tl%s", menu_lengthlist[menu_selections[id][MENU_SELECTION_MATCHLENGTH]])
		case 2: format(match_type, 31, "wl%s", menu_lengthlist[menu_selections[id][MENU_SELECTION_MATCHLENGTH]])	
	}
	
	// Format match config
	copy(match_config, 31, menu_configlist_file[menu_selections[id][MENU_SELECTION_CONFIG]])
	
	// Format demo string
	#if defined(AMXMD_USE_HLTV)
	
	switch(menu_selections[id][MENU_SELECTION_DEMOTYPE])
	{
		case 0: format(demo_type, 15, " recdemo")
		case 1: format(demo_type, 15, " rechltv")
		case 2: format(demo_type, 15, " recboth")
		case 3: format(demo_type, 15, "")
	}
	
	#else
	
	switch(menu_selections[id][MENU_SELECTION_DEMOTYPE])
	{
		case 0: format(demo_type, 15, " recdemo")
		case 1: format(demo_type, 15, "")
	}
	
	#endif		
	
	// Format match command
	if ( menu_selections[id][MENU_SELECTION_TAG_CT] != -1 && menu_selections[id][MENU_SELECTION_SECONDMAP] == -1 ) // Playing amx_match
	{
		format(command,255,"amx_match ^"%s^" ^"%s^" %s %s%s", menu_tags_CT[menu_selections[id][MENU_SELECTION_TAG_CT]], menu_tags_T[menu_selections[id][MENU_SELECTION_TAG_T]], match_type, match_config,demo_type)
	}
	else if( menu_selections[id][MENU_SELECTION_TAG_CT] == -1 && menu_selections[id][MENU_SELECTION_SECONDMAP] == -1 ) // Playing amx_match2
	{
		format(command,255,"amx_match2 %s %s%s", match_type, match_config, demo_type)
	}
	else if ( menu_selections[id][MENU_SELECTION_TAG_CT] != -1 && menu_selections[id][MENU_SELECTION_SECONDMAP] != -1 ) // Playing amx_match3
	{
		format(command,255,"amx_match3 ^"%s^" ^"%s^" %s %s %s%s", menu_tags_CT[menu_selections[id][MENU_SELECTION_TAG_CT]], menu_tags_T[menu_selections[id][MENU_SELECTION_TAG_T]], match_type, match_config, menu_maplist[menu_selections[id][MENU_SELECTION_SECONDMAP]], demo_type)
	}
	else if( menu_selections[id][MENU_SELECTION_TAG_CT] == -1 && menu_selections[id][MENU_SELECTION_SECONDMAP] != -1 ) // Playing amx_match4
	{
		format(command,255,"amx_match4 %s %s %s%s", match_type, match_config, menu_maplist[menu_selections[id][MENU_SELECTION_SECONDMAP]], demo_type)
	}
	
	server_cmd(command)
	
	return PLUGIN_CONTINUE
}


public match_stop(id,level)
{
	// Declare variables
	new user_name[32]
	new user_authid[16]
	new user_id
		
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}
	
	
	if (main_inprogress > 0)
	{	
		// Remove timelimit tasks
		if ( task_exists( TASKID_DECREMENT_SECONDS ) )
		{
			remove_task( TASKID_DECREMENT_SECONDS )
		}
			
		if ( task_exists( TASKID_TIMER_SHOW ) )
		{
			remove_task( TASKID_TIMER_SHOW )
		}
		
		// Remove 'pick a team' message
		if(task_exists(TASKID_KNIFEROUND_MESSAGE))
		{
			remove_task(TASKID_KNIFEROUND_MESSAGE)
		}
			
		
		
		// Get user's name
		get_user_name(id, user_name, 31)
		
		
		// Take a screenshot if screenshot2 = 1
		if(get_cvar_num("amx_match_screenshot2") == 1)
		{
			set_hudmessage(208, 12, 2, 0.05, -0.25, 0, 6.0, 12.0, 0.1, 0.2, -1)
			show_hudmessage(0,"--[ %L %s ]--", LANG_PLAYER, "MATCH_WAS_ENDED_BY", user_name)
		
			screenshot_setup()
		}
		
		
		// Hud message for match stop
		set_hudmessage(208, 12, 2, -1.0, 0.32, 0, 2.0, 6.0, 0.8, 0.8, -1)
		show_hudmessage(0,"--[ %s %L ]--^n^n %L ;-)", user_name, LANG_PLAYER, "HUD_MATCH_STOPPED", LANG_PLAYER, "HUD_GO_BACK_FFA")
		
		server_print("* %L", LANG_SERVER, "MATCH_STOPPED")
		
		
		// Uninitialize
		uninit()
		
		
		// Log
		get_user_authid(id, user_authid, 15)
		
		user_id = get_user_userid(id)
		// Log to amxx log
		log_amx("^"%s<%d><%s><>^" %L", user_name, user_id, user_authid, LANG_SERVER, "STOPPED_MATCH")
		
		// Log to hl log
		log_message("^"%s<%d><%s><>^" %L", user_name, user_id, user_authid, LANG_SERVER, "STOPPED_MATCH")
		
		// Server console
		server_print("^"%s<%d><%s><>^" %L", user_name, user_id, user_authid, LANG_SERVER, "STOPPED_MATCH")
		
		// Show activity, if on
		switch(get_cvar_num("amx_show_activity")) 
		{	
				case 2: client_print(0,print_chat,"%L %s: %L", LANG_PLAYER, "ADMIN", user_name, LANG_PLAYER, "STOPPED_MATCH")
				case 1: client_print(0,print_chat,"%L %L", LANG_PLAYER, "ADMIN", LANG_PLAYER, "STOPPED_MATCH")
		}
		
	}
	else
	{
		client_print(id,print_chat,"* [AMX MATCH] %L", id, "NO_MATCH_TO_STOP")
		console_print(id,"* %L", id, "NO_MATCH_TO_STOP")
	}
	
	return PLUGIN_CONTINUE
}


/*
*
*			Menu
*
*/

public menu_get_servermaps()
{
	new temp[64]
	new temp2[64]
	
	new left[64]
	new right[64]
	
	new maps_dir
	
	new line
	new linelength

	
	// Get the default maps from the file
	if( file_exists(config_file_defaultmaps) )
	{
		while(read_file(config_file_defaultmaps, line, temp, 63, linelength) != 0)
		{
	    		if(is_map_valid(temp))
	    		{
				copy( menu_maplist[menu_maplist_pos++], 63, temp)
			}
			
			line++
		}
	}
	else
	{
		server_print("* [AMX MATCH] %L", LANG_SERVER, "MAP_FILE_DNE")
	}
	
	
	// Now add the custom maps
	
	maps_dir = open_dir("maps", temp, 63)
	
	if( maps_dir != 0 )
	{
		remove_filepath ( temp, temp2, 63 )
				
		strtok(temp2, left, 63, right, 63, '.')
			
		if ( equali( right , "bsp" ) && is_map_valid(left))
		{
			copy( menu_maplist[menu_maplist_pos++], 63, left)
		}		
		
		
		while( (menu_maplist_pos < MENU_MAX_VARS) && next_file(maps_dir, temp, 63) )
		{
			remove_filepath ( temp, temp2, 63 )
			
			strtok(temp2, left, 63, right, 63, '.')
			
			if ( equali( right , "bsp" ) && is_map_valid(left) )
 			{
				copy( menu_maplist[menu_maplist_pos++], 63, left)
			}
		}
		
		close_dir( maps_dir )
	}
	
	
	return PLUGIN_CONTINUE	
}


public menu_get_clantags_CT()
{
	new players[32]
	new number
	new player_name[32]

	new j

	new no_clantag = 1

	new matchBuf[128]

	new clan_tags[MENU_TAGS_MAX][32]
	new clan_tags_num[MENU_TAGS_MAX]

	new clan_tags_pos

	new Regex:regexid
	new retval
	new error[128]

	// Don't even try to read it
	// Just means <(optional) clan symbol> <clan name> <(optional) clan symbol>
	new pattern[] = "[^'^"^^`.,:{}/\\#<>| ?!@$%&*()-=_+\]\[]*\W*\w+\W*[^'^"^^`.,:{}/\\#<>| ?!@$%&*()-=_+\]\[]*"
	
	// Initialize positions
	menu_tags_CT_pos = 0
	clan_tags_pos = 0

	// Get players
	get_players(players,number,"e","CT")

	for(new i = 0; (i < number) && (clan_tags_pos < MENU_TAGS_MAX); i++)
	{	
		// Get user's name
		get_user_name(players[i],player_name,31)
		
		regexid = regex_match(player_name, pattern, retval, error, 127)
		
		if (regexid >= REGEX_OK) // If there was a match
		{
		
			regex_substr(regexid, 0, matchBuf, 127)
			regex_free(regexid)
			
			// Figure out if the clan name is already in the array
			for( j = 0; (j < clan_tags_pos) && !equal(clan_tags[j], matchBuf); j++) { }
		
			if( (j < clan_tags_pos) && equal(clan_tags[j], matchBuf) )
			{	
				(clan_tags_num[j])++
			}
			else
			{
				copy (clan_tags[clan_tags_pos], 31, matchBuf)
				(clan_tags_num[clan_tags_pos])++
				clan_tags_pos++
			}
		}
	}
	
	
	for(new i = 0; i < clan_tags_pos; i++)
	{
		if( clan_tags_num[i] >= MENU_TAGS_MINPLAYERS )
		{
			copy ( menu_tags_CT[menu_tags_CT_pos++], 31, clan_tags[i])
			no_clantag = 0
		}
	}
	
	if (no_clantag == 1)
	{
		return false
	}
	else
	{
		return true
	}
	
	
	// Execution won't ever get here, just so the compiler is happy
	return false
}

public menu_get_clantags_T()
{
	new players[32]
	new number
	new player_name[32]

	new j

	new no_clantag = 1

	new matchBuf[128]

	new clan_tags[MENU_TAGS_MAX][32]
	new clan_tags_num[MENU_TAGS_MAX]

	new clan_tags_pos

	new Regex:regexid
	new retval
	new error[128]

	// Don't even try to read it
	// Just means <(optional) clan symbol> <clan name> <(optional)clan symbol>
	new pattern[] = "([^'^"^^`.,:{}/\\#<>| ?!@$%&*()-=_+\]\[]*\w+[^'^"^^`.,:{}/\\#<>| ?!@$%&*()-=_+\]\[]*)"
	
	// Initialize positions
	menu_tags_T_pos = 0
	clan_tags_pos = 0

	// Get players
	get_players(players,number,"e","TERRORIST")

	for(new i = 0; (i < number) && (clan_tags_pos < MENU_TAGS_MAX); i++)
	{	
		// Get user's name
		get_user_name(players[i],player_name,31)
		
		regexid = regex_match(player_name, pattern, retval, error, 127)
		
		if (regexid >= REGEX_OK) // If there was a match
		{
		
			regex_substr(regexid, 0, matchBuf, 127)
			regex_free(regexid)
			
			// Figure out if the clan name is already in the array
			for( j = 0; (j < clan_tags_pos) && !equal(clan_tags[j], matchBuf); j++) { }
		
			if( (j < clan_tags_pos) && equal(clan_tags[j], matchBuf) )
			{	
				(clan_tags_num[j])++
			}
			else
			{
				copy (clan_tags[clan_tags_pos], 31, matchBuf)
				(clan_tags_num[clan_tags_pos])++
				clan_tags_pos++
			}
		}
	}
	
	
	for(new i = 0; i < clan_tags_pos; i++)
	{
		if( clan_tags_num[i] >= MENU_TAGS_MINPLAYERS )
		{
			copy ( menu_tags_T[menu_tags_T_pos++], 31, clan_tags[i])
			no_clantag = 0
		}
	}
	
	if (no_clantag == 1)
	{
		return false
	}
	else
	{
		return true
	}
	
	return false
}

public menu_add_length(id,level,cid)
{
	if (!cmd_access(id,level,cid,2))
	{
		return PLUGIN_HANDLED
	}

	new matched
	new arg[32]

	new argc = read_argc()

	for(new i = 1; i < argc; i++) 
	{
		if (menu_lengthlist_pos < MENU_MAX_VARS) 
		{
			read_argv(i, arg, 31)

			matched = 0

			for(new j = 0; j < menu_lengthlist_pos; j++)
			{
				if(equal(menu_lengthlist[j], arg))
				{
					matched = 1
					break
				}
			}

			if(matched == 0)
			{
				menu_lengthlist[menu_lengthlist_pos++] = arg
			}
		}
		else 
		{
			console_print(id,"* [AMX MATCH] %L",id,"TO_MANY_MATCH_TYPE")
			break
		}
	}

	return PLUGIN_CONTINUE
}

public menu_add_config(id,level,cid)
{
	if (!cmd_access(id,level,cid,3))
	{
		return PLUGIN_HANDLED
	}
	
	if (menu_configlist_pos < MENU_MAX_VARS) 
	{
		new arg[32]
		new matched = 0
		
		read_argv(1,arg,31)
		
		for(new i = 0; i < menu_configlist_pos; i++)
		{
			if(equali(menu_configlist_name[i], arg))
			{
				matched = 1
				break
			}
		}

			
		if(matched == 0)
		{
			menu_configlist_name[menu_configlist_pos] = arg
			read_argv(2,arg,31)
			menu_configlist_file[menu_configlist_pos++] = arg
		}
		
	}
	else
		console_print(id,"* [AMX MATCH] %L", id,"TO_MANY_CFG_FILE")

	return PLUGIN_CONTINUE
}

// Main Menu
public menu_console(id,level)
{
	if (!access(id,level))
	{
		return PLUGIN_HANDLED
	}
	
	// Show the menu
	menu_show_main(id)
	
	return PLUGIN_CONTINUE
}

public menu_show_main(id)
{

	new menu_body[512]		// For Multilanguage Menu format
	
	menu_position[id] = 0
	menu_selections[id][MENU_SELECTION_TAG_CT] = -1
	menu_selections[id][MENU_SELECTION_TAG_T] = -1
	menu_selections[id][MENU_SELECTION_MATCHTYPE] = -1
	menu_selections[id][MENU_SELECTION_MATCHLENGTH] = -1
	menu_selections[id][MENU_SELECTION_CONFIG] = -1
	menu_selections[id][MENU_SELECTION_SECONDMAP] = -1
	menu_selections[id][MENU_SELECTION_DEMOTYPE] = -1
	
	// Displaying console
	
	client_print(id,print_console,"* [AMX MATCH] %L", id,"DISPLAYING_MENU")
	
	// Exec AMXMD.cfg
	if (file_exists(config_file_plugin)) 
	{
		server_cmd("exec %s", config_file_plugin)
	}
	
	if ((main_inprogress == 1) || (main_inprogress == 3)) // Warmup
	{
		 format(menu_body,511,"\yAMX Match %L:\w^n^n1. %L^n2. %L^n3. %L^n4. %L^n5. %L^n^n0. %L", LANG_SERVER, "MENU_MENU", id,"STOP_MATCH",id,"FORCE_START",id,"RESTART_MATCH",id,"SWAP_TEAMS",id,"PLUGIN_SETTINGS",id,"EXIT")
		 show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9), menu_body)
	}
	else if ((main_inprogress == 2) || (main_inprogress == 4)) // Half
	{
		format(menu_body,511,"\yAMX Match %L:\w^n^n1. %L^n2. %L^n3. %L^n4. %L^n^n0. %L", LANG_SERVER, "MENU_MENU",id,"RESTART_HALF", id,"STOP_MATCH",id,"RESTART_MATCH",id,"PLUGIN_SETTINGS",id,"EXIT")
		show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9), menu_body)
	}
	else // No Match
	{
		format(menu_body,511,"\yAMX Match %L:\w^n^n1. %L^n2. %L^n3. %L^n4. %L^n5. %L^n^n0. %L", LANG_SERVER, "MENU_MENU", id,"START_MATCH", id,"PUG_STYLE", id,"SWAP_TEAMS", id,"RANDOMIZE_TEAMS", id,"PLUGIN_SETTINGS", id,"EXIT")
		show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9), menu_body)
	}

	
	return PLUGIN_CONTINUE
}

public menu_action_main(id,key)
{
	
	if ((main_inprogress == 1) || (main_inprogress == 3)) // Warmup
	{
		// 1. "STOP_MATCH"		(0)
		// 2. "FORCE_START"		(1)
		// 3. "RESTART_MATCH"	(2)
		// 4. "SWAP_TEAMS"		(3)
		// 5. "PLUGIN_SETTINGS"	(4)
		// 0. "EXIT"			(9)
		
		switch(key) 
		{
			case 0: // Stop the match
			{
				if( get_cvar_num("amx_match_pugstyle") == 1 )
				{
					menu_show_pugstyle(id)
				}
				else
				{
					match_stop(id, AMXMD_ACCESS)
				}
			}
			case 1: // Force start
			{ 
				half_start_force(id)
			}
			case 2: // Restart match
			{ 
				match_restart(id, AMXMD_ACCESS)
			}			
			case 3: // Swap teams
			{
				swap_teams_console(id, AMXMD_ACCESS)
			}
			case 4: // Show plugin settings
			{
				menu_position[id] = 0
				menu_show_settings(id)
			}		
		}
	}
	else if ((main_inprogress == 2)||(main_inprogress == 4)) // Half
	{
		// 1. "RESTART_HALF"	(0)
		// 2. "STOP_MATCH"		(1)
		// 3. "RESTART_MATCH"	(2)
		// 4. "PLUGIN_SETTINGS"	(3)
		// 0. "EXIT"			(9)
		
		
		switch(key) 
		{
			case 0: // Restart the half
			{
				half_restart(id, AMXMD_ACCESS)
			}
			case 1: // Stop the match
			{
				if( get_cvar_num("amx_match_pugstyle") == 1 )
				{
					menu_show_pugstyle(id)
				}
				else
				{
					match_stop(id, AMXMD_ACCESS)
				}
			}
			case 2: // Restart the match
			{
				match_restart(id, AMXMD_ACCESS)
			}		
			case 3: // Show plugin settings
			{
				menu_position[id] = 0
				menu_show_settings(id)
			}
		}
	}
	else // No Match
	{
		// 1. "START_MATCH"		(0)
		// 2. "PUG_STYLE"		(1)
		// 3. "SWAP_TEAMS"		(2)
		// 4. "RANDOMIZE_TEAMS"	(3)
		// 5. "PLUGIN_SETTINGS"	(4)
		// 0. "EXIT"			(0)
		
		switch(key)
		{
			case 0: // Start a match
			{
				menu_show_tags(id) // Show Clan Tag menu
			}
			case 1: // PUG Gameplay
			{			
				match_pug_start()
			}
			case 2: // Swap teams
			{			
				swap_teams_console(id, AMXMD_ACCESS)
			}
			case 3: // Randomize teams
			{
				randomize_teams(id, AMXMD_ACCESS)
			}
			case 4: // Show plugin settings
			{
				menu_position[id] = 0
				menu_show_settings(id)
			}
		}		
	}

	return PLUGIN_CONTINUE
}

public menu_show_tags(id)
{
	new menu_body[512]
	
	format(menu_body,511,"\yAMX Match %L:\w^n^n1. %L^n2. %L^n^n0. %L",LANG_SERVER, "MENU_CLANTAGS",id,"USE_TAGS",id,"DONT_USE_TAGS",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<9), menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_tags(id,key)
{
	new no_clantag = 0
	
	switch(key)
	{
		case 0:
		{
			if (!menu_get_clantags_CT())
			{
				client_print(id,print_chat,"* [AMX MATCH] %L", id,"NO_CT_CLANTAG_FOUND")
				
				no_clantag = 1
			}
			
			if (!menu_get_clantags_T())
			{
				client_print(id,print_chat,"* [AMX MATCH] %L", id,"NO_T_CLANTAG_FOUND")
				
				no_clantag = 1
			}		
			
			
			if (no_clantag == 0)
			{
				menu_position[id] = 0
				menu_show_tags_CT(id,0) // Show CT clantags
			}
			else
			{
				client_print(id,print_chat,"* [AMX MATCH] %L", id,"TRY_USE_CONSOLE_CMD")
				
				// Make sure they didn't already make selections
				menu_selections[id][MENU_SELECTION_TAG_CT] = -1
				menu_selections[id][MENU_SELECTION_TAG_T] = -1
				
				//Continue
				menu_show_type(id) // Show type choices
			}
		}
		
		case 1:
		{
			// Make sure that they didn't already make some selections
			menu_selections[id][MENU_SELECTION_TAG_CT] = -1
			menu_selections[id][MENU_SELECTION_TAG_T] = -1
			
			//Continue
			menu_show_type(id) // Show type choices
		}
		
		default:
		{
			// Go back
			menu_show_main(id)
		}
	}
	
	return PLUGIN_CONTINUE
}

// CT Tags Menu
public menu_show_tags_CT(id, pos)
{
	new menu_body[512]
	new formatPos
	new keys = (1<<9)
	
	new start = pos * 8
	new end = start + 8	
	
	formatPos = format(menu_body, 511, "\yAMX Match %L:\R%d/%d^n\w^n", LANG_SERVER, "MENU_CLANTAGS_CT",pos+1, (menu_tags_CT_pos/8)+((menu_tags_CT_pos%8)?1:0))
	
	if (end > menu_tags_CT_pos)
	{
		end = menu_tags_CT_pos
	}
	
	new j = 1
	
	for(new i = start; i < end; i++)
	{
		formatPos += format(menu_body[formatPos],511-formatPos,"%d. %s^n",j,menu_tags_CT[i])
		keys |= (1<<(j - 1))
		j++
	}
	
	if (end != menu_tags_CT_pos)
	{
		format(menu_body[formatPos],511-formatPos,"^n9. %L^n0. %L",id,"MORE",id,"BACK")
		keys |= (1<<8)
	}
	else
	{
		format(menu_body[formatPos],511-formatPos,"^n0. %L",id,"BACK")
	}
		
	show_menu(id,keys,menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_tags_CT(id,key)
{
	switch(key)
	{
		case 9: // go back
		{
			if (menu_position[id] == 0)
			{
				menu_show_tags(id)
			}
			else
			{	
				menu_show_tags_CT(id,--(menu_position[id]))
			}
		}
	
		case 8:  // show next set of clantags
		{
			menu_show_tags_CT(id,++(menu_position[id]))
		}
	
		default: 
		{	
			client_print(id,print_chat,"* %L: %s", id, "TAG_SELECTED", menu_tags_CT[key + (menu_position[id] * 8)])
			
			menu_selections[id][MENU_SELECTION_TAG_CT] = key + (menu_position[id] * 8)		
			
			menu_position[id] = 0
			menu_show_tags_T(id,0)
		}
	}
	
	return PLUGIN_CONTINUE
}

// T Tags Menu
public menu_show_tags_T(id,pos)
{
	new menu_body[512]
	new formatPos
	new keys = (1<<9)
	
	new start = pos * 8
	new end = start + 8	
	
	formatPos = format(menu_body, 511, "\yAMX Match %L:\R%d/%d^n\w^n", LANG_SERVER, "MENU_CLANTAGS_T", pos+1, (menu_tags_T_pos/8)+((menu_tags_T_pos%8)?1:0))
	
	if (end > menu_tags_T_pos)
	{
		end = menu_tags_T_pos
	}
	
	new j = 1
	
	for(new i = start; i < end; i++)
	{
		formatPos += format(menu_body[formatPos],511-formatPos,"%d. %s^n",j,menu_tags_T[i])
		keys |= (1<<(j - 1))
		j++
	}
	
	if (end != menu_tags_T_pos)
	{
		format(menu_body[formatPos],511-formatPos,"^n9. %L^n0. %L",id,"MORE",id,"BACK")
		keys |= (1<<8)
	}
	else
	{
		format(menu_body[formatPos],511-formatPos,"^n0. %L",id,"BACK")
	}
		
	show_menu(id,keys,menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_tags_T(id,key)
{
	if(key == 9 && menu_position[id] == 0) // goes back
	{
			menu_show_tags_CT(id,0)
	}
	else if(key == 9)
	{
		(menu_position[id])--
		menu_show_tags_T(id,menu_position[id])
	}
	else if(key == 8) // show next clantags
	{
			(menu_position[id])++
			menu_show_tags_T(id,menu_position[id])
	}
	else 
	{	
		client_print(id,print_chat,"* %L: %s", id, "TAG_SELECTED", menu_tags_T[key + (menu_position[id] * 8)])
		
		menu_selections[id][MENU_SELECTION_TAG_T] = key + (menu_position[id] * 8)
		
		menu_position[id] = 0
		menu_show_type(id)
	}


	return PLUGIN_CONTINUE
}

// Plugin Settings Menu
public menu_show_settings(id)
{
	
	/*	
	
		END_TYPE = End type
		CHANGE_HOSTNAME = Change hostname
		HLTV_DELAY = HLTV Delay
		KNIFE_ROUND = Knife round
		ALLOW_OVERTIME = Allow overtime
		OVERTIME_CONFIGS = Overtime configs
		OVERTIME_LENGTH = Overtime length
		CHANGE_PASSWORD = Plugin changes password
		PASSWORD = Password
		NEEDED_READY_PLAYERS = Needed ready players
		PUG_STYLE = Pick-Up-Game style
		READY_TYPE = Ready type
		AUTO_SWAP = Auto swap
		SCREEN_SHOT = Screenshot
		ALWAYS_SCREENSHOT = Always Screenshot	
		ALLOW_SHIELDS = Allow Shields
		REALLOW_SHIELD = (Re)allow Shields
		SHOW_SCORE = Show score
		STATS = Log stats
		WARMUP_CONFIGS = Warmup Configs
		
	*/
		
	new menu_body[1024]
	new keys = (1<<7)|(1<<9)
	new formatPos = 0
	
	new setting[32]
	
	new cvar_property[32]
	
	new start = menu_position[id] * 7
	new end = start + 7
	
	new cvar_name[32]
	new cvar_lang[32]
	
	
	// Format heading
	formatPos = format(menu_body, 1023, "\yAMX Match %L:\w				(%d/%d)^n", LANG_SERVER, "MENU_SETTINGS",menu_position[id] + 1, (NUM_CVARS / 7) + 1 )
	
	// Make sure we don't go off the end of the world
	if( end > NUM_CVARS)
	{
		end = NUM_CVARS
	}
	
	new j = 1
	
	for(new i = start; i < end; i++)
	{
		copy(cvar_name, 31, cvar_names[i])
		copy(cvar_lang, 31, cvar_language[i])

		get_cvar_string(cvar_name, cvar_property, 31)
		
		
		
		if(equal(cvar_name, "amx_match_readytype"))
		{
			switch(str_to_num(cvar_property))
			{
				case 0:
				{
					format(setting, 31, "%L", id, "ONE_PLAYER")
				}
				case 1:
				{
					format(setting, 31, "%L", id, "ALL_PLAYERS")
				}
				case 2:
				{
					format(setting, 31, "%L", id, "ADMIN_ONLY")
				}
			}
		}
		else if(equal(cvar_name, "amx_match_screenshot"))
		{
			switch(str_to_num(cvar_property))
			{
				case 0:
				{
					format(setting, 31, "%L", id, "NONE")
				}
				case 1:
				{
					format(setting, 31, "%L", id, "SCORES")
				}
				case 2:
				{
					format(setting, 31, "%L", id, "SCORES_STEAMIDS")
				}
			}
		}
		else if(equal(cvar_name, "amx_match_showscore"))
		{
			switch(str_to_num(cvar_property))
			{
				case 0:
				{
					format(setting, 31, "%L", id, "NEVER")
				}
				case 1:
				{
					format(setting, 31, "%L", id, "START_OF_ROUND")
				}
				case 2:
				{
					format(setting, 31, "%L", id, "ALWAYS")
				}
			}
		}
		else if(equal(cvar_name, "amx_match_endtype") || equal(cvar_name, "amx_match_hltvdelay") || equal(cvar_name, "amx_match_otlength") 
				|| equal(cvar_name, "amx_match_password2") || equal(cvar_name, "amx_match_playerneed") )
		{
			copy(setting, 31, cvar_property)
		}	
		else 
		{
			format(setting, 31, "%L", id, (str_to_num(cvar_property) == 1) ? "ON" : "OFF")
		}
		
		
		// Disable the dependent cvars if their indepedent cvar is off
		if( (equal(cvar_name, "amx_match_otlength") || equal(cvar_name, "amx_match_otcfg") || equal(cvar_name, "amx_match_otunlimited")) && get_cvar_num("amx_match_overtime") == 0)
		{
			// Format the cvar's line
			formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\d%d. %L : %s", j, id, cvar_lang, setting)
		}
		else if ( equal(cvar_name, "amx_match_password2") && get_cvar_num("amx_match_password") == 0 )
		{
			// Format the cvar's line
			formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\d%d. %L : %s", j, id, cvar_lang, setting)
		}
		else if ( equal(cvar_name, "amx_match_playerneed") && get_cvar_num("amx_match_readytype") != 1 )
		{
			// Format the cvar's line
			formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\d%d. %L : %s", j, id, cvar_lang, setting)
		}
		else if ( main_inprogress == 2 || main_inprogress == 4 )
		{
			// Format the cvar's line
			formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\d%d. %L : %s", j, id, cvar_lang, setting)
		}
		else
		{
#if !defined(AMXMD_USE_HLTV)			

			if ( equal(cvar_name, "amx_match_hltvdelay"))
			{
				// Format the cvar's line
				formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\d%d. %L : %s", j, id, cvar_lang, setting)
			}
			else
			{	
				// Format the cvar's line
				formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\w%d. \y%L :\w %s", j, id, cvar_lang, setting)
		
				keys |= (1<<(j - 1))
			}
			
#else

			// Format the cvar's line
			formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n\w%d. \y%L :\w %s", j, id, cvar_lang, setting)
	
			keys |= (1<<(j - 1))
			
#endif
	
		}
		
		j++
	}
	
	
	// Format end
	if( end == NUM_CVARS)
	{
		formatPos += format(menu_body[formatPos], 1023 - formatPos, "^n^n\w8. %L^n^n^n^n0. %L", id, "SAVE_CONFIG", id, "BACK")
	}
	else
	{
		formatPos += format(menu_body[formatPos],1023 - formatPos,"^n^n\w8. %L^n^n9. %L^n^n0. %L",id, "SAVE_CONFIG", id, "MORE", id, "BACK")
		keys |= (1<<8)
	}
	
	show_menu(id, keys, menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_settings(id,key)
{
	new server_pass[32]
	
	new cvar_number
	new cvar_name[32]

	if( key <= 6)
	{	
		cvar_number = key + (menu_position[id] * 7)

		copy(cvar_name, 31, cvar_names[cvar_number])
	}
	
	switch(key) // Main switch
	{
		case 7:  // Save settings
		{ 
			client_print(id,print_chat,"* [AMX MATCH] %L ...",id, "SETTINGS_SAVED")
			
			save_settings(config_file_plugin)
			menu_show_settings(id)
		}	
		case 8:  // Get more
		{ 
			menu_position[id]++
			menu_show_settings(id)
		}
		case 9: // Go back
		{ 
			if( menu_position[id] == 0 )
			{
				menu_show_main(id)
			}
			else
			{
				menu_position[id]--
				menu_show_settings(id)
			}
		}
		default:
		{
			if( equal(cvar_name, "amx_match_endtype") || equal(cvar_name, "amx_match_screenshot")
					|| equal(cvar_name, "amx_match_readytype") || equal(cvar_name, "amx_match_showscore") )
			{
				if (get_cvar_num(cvar_name) == 2)
				{
					set_cvar_num(cvar_name, 0)
				}
				else
				{
					set_cvar_num(cvar_name, get_cvar_num(cvar_name) + 1)
				}
			}
			else if( equal(cvar_name, "amx_match_playerneed") )
			{
				if (get_cvar_num(cvar_name) == 12)
				{
					set_cvar_num(cvar_name, 2)
				}
				else
				{
					set_cvar_num(cvar_name,get_cvar_num(cvar_name) + 2)
				}
			}
			else if( equal(cvar_name, "amx_match_password2") )
			{
				get_cvar_string(cvar_name, server_pass, 31)
				
				if (equal(server_pass, "scrim"))
				{
					set_cvar_string(cvar_name, "scrimmage")
				}
				else if (equal(server_pass, "scrimmage"))
				{
					set_cvar_string(cvar_name, "calmatch")
				}
				else if (equal(server_pass, "calmatch"))
				{
					set_cvar_string(cvar_name, "ecupmatch")
				}		
				else if (equal(server_pass, "ecupmatch"))
				{
					set_cvar_string(cvar_name, "orange")
				}
				else
				{
					set_cvar_string(cvar_name, "scrim")
				}
			}	
			else if( equal(cvar_name, "amx_match_otlength") )
			{
				if (get_cvar_num(cvar_name) == 12)
				{
					set_cvar_num(cvar_name, 1)
				}
				else
				{
					set_cvar_num(cvar_name, get_cvar_num(cvar_name) + 1)
				}
			}
			else if( equal(cvar_name, "amx_match_hltvdelay") )	
			{	
				if (get_cvar_num(cvar_name) == 180)
				{
					set_cvar_num(cvar_name, 0)
				}
				else
				{
					set_cvar_num(cvar_name, get_cvar_num(cvar_name) + 10)
				}
			}
			else 
			{	
				set_cvar_num(cvar_name,!(get_cvar_num(cvar_name)))
			}			
			
			
			menu_show_settings(id)
		
		}
	}
	
	return PLUGIN_CONTINUE
}


// Match Type Menu
public menu_show_type(id)
{
	new menu_body[512]
	
	format(menu_body,511,"\yAMX Match %L:\w^n^n1. %L^n2. %L^n3. %L^n^n0. %L",LANG_SERVER, "MENU_MATCH_TYPE", id,"MAX_ROUND",id,"TIME_LIMIT",id,"WIN_LIMIT",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<9), menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_type(id,key)
{
	switch(key)
	{	
		case 9:
		{
			if( menu_selections[id][MENU_SELECTION_TAG_CT] == -1 )
			{
				menu_show_tags(id)
			}
			else
			{
				menu_show_tags_T(id, 0)
			}
		}
		
		default:
		{
			menu_selections[id][MENU_SELECTION_MATCHTYPE] = key 
			menu_show_length(id, 0)			
		}
	}	
	
	return PLUGIN_CONTINUE
}

public menu_show_length(id, pos)
{
	new menu_body[512], formatPos
	new keys = (1<<9)
	new start = pos * 8
	new end = start + 8
	
	// Make sure the end isn't past the last type
	if (end > menu_lengthlist_pos)
	{
		end = menu_lengthlist_pos
	}
	
	formatPos = format(menu_body,511,"\yAMX Match %L:\R%d/%d^n\w^n",LANG_SERVER, "MENU_MATCH_LENGTH", pos+1,(menu_lengthlist_pos/8)+((menu_lengthlist_pos%8)?1:0))

	for(new i = start; i < end; i++) {
		formatPos += format(menu_body[formatPos],511-formatPos,"%d. %s^n",(i + 1),menu_lengthlist[i])
		
		keys |= (1<<i)
	}
	
	if (end != menu_lengthlist_pos) // If there are more types
	{
		format(menu_body[formatPos],511-formatPos,"^n9. %L^n0. %L",id,"MORE",id,"BACK")
		keys |= (1<<8)
	}
	else
	{
		format(menu_body[formatPos],511-formatPos,"^n0. %L",id,"BACK")
	}
	
	show_menu(id,keys,menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_length(id,key)
{
	if (key == 9) // go back
	{
		if (menu_position[id] == 0)
		{
			menu_show_type(id)
		}
		else 
		{
			(menu_position[id])--
			
			menu_show_length(id,menu_position[id])
		}
	}
	else if (key == 8) // shows next list of types
	{
		(menu_position[id])++
		menu_show_length(id,menu_position[id])
	}
	else 
	{
		menu_selections[id][MENU_SELECTION_MATCHLENGTH] = key + (menu_position[id] * 8)
		
		menu_position[id] = 0
		menu_show_config(id, 0)
	}
	
	return PLUGIN_CONTINUE
}

// Config File Menu
public menu_show_config(id,pos)
{
	new menu_body[512], formatPos
	new keys = (1<<9)
	new start = pos * 8
	new end = start + 8
	
	formatPos = format(menu_body,511,"\yAMX Match %L:\R%d/%d^n\w^n",LANG_SERVER, "MENU_CONFIG_FILE", pos+1,(menu_configlist_pos/8)+((menu_configlist_pos%8)?1:0))

	// If end is past the last config
	if (end > menu_configlist_pos)
	{
		end = menu_configlist_pos
	}
	
	for(new i = start; i < end; i++) 
	{
		formatPos += format(menu_body[formatPos],511-formatPos,"%d. %s^n", i + 1, menu_configlist_name[i])
		keys |=(1<<i)
	}
	
	// If there are more configs
	if (end != menu_configlist_pos) 
	{
		format(menu_body[formatPos],511-formatPos,"^n9. %L^n0. %L",id,"MORE",id,"BACK")
		keys |= (1<<8)
	}
	else
	{
		format(menu_body[formatPos],511-formatPos,"^n0. %L",id,"BACK")
	}
	
	show_menu(id,keys,menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_config(id,key)
{
	if (key == 9) // go back
	{
		if (menu_position[id] == 0)
		{
			menu_show_length(id,0)
		}
		else 
		{
			(menu_position[id])--
			menu_show_config(id,menu_position[id])
		}
	}
	else if (key == 8) // Show next list of configs
	{
		(menu_position[id])++
		menu_show_config(id,menu_position[id])
	}
	else 
	{	
		menu_selections[id][MENU_SELECTION_CONFIG] = key + (menu_position[id] * 8)
		
		menu_position[id] = 0
		menu_show_secondmap(id)
	}
	
	return PLUGIN_CONTINUE
}

// Second Map Menu
public menu_show_secondmap(id)
{
	new temp[256]
	
	format(temp, 255, "\yAMX Match %L:\w^n^n1. %L^n2. %L^n^n^n0. %L", LANG_SERVER, "MENU_SECONDMAP",id,"YES",id,"NO",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<9), temp)
	
	return PLUGIN_CONTINUE
}

public menu_action_secondmap(id, key)
{
	if (key == 9) // go back
	{
		menu_position[id] = 0
		menu_show_config(id,0)
	}
	else if (key == 0) // Yes, show map list
	{
		if( menu_maplist_pos == 0 ) // If there are no maps in the list
		{
			client_print(id,print_chat,"* [AMX MATCH] %L", id, "NO_MAPS_IN_LIST")
			
			menu_selections[id][MENU_SELECTION_SECONDMAP] = -1
			
			menu_position[id] = 0
			menu_show_demo(id)
		}
		else
		{	
			menu_position[id] = 0
			menu_show_secondmaplist(id, 0)
		}
	}
	else if (key == 1) // No
	{
		menu_selections[id][MENU_SELECTION_SECONDMAP] = -1
		
		menu_position[id] = 0
		menu_show_demo(id)
	}
	
	return PLUGIN_CONTINUE
}

// Second Map Menu
public menu_show_secondmaplist(id, pos)
{	
	new menu_body[512], formatPos
	new keys = (1<<9)
	new start = pos * 8
	new end = start + 8
	
	formatPos = format(menu_body,511,"\yAMX Match %L:\R%d/%d^n\w^n", LANG_SERVER, "MENU_SECONDMAP_LIST", pos+1,(menu_maplist_pos/8)+((menu_maplist_pos%8)?1:0))

	// If end is past the last map
	if (end > menu_maplist_pos)
	{
		end = menu_maplist_pos
	}
	
	for(new i = start, j = 0; i < end; i++, j++) 
	{
		formatPos += format(menu_body[formatPos],511-formatPos,"%d. %s^n", j + 1, menu_maplist[i])
		keys |=(1<<j)
	}
	
	// If there are more maps
	if (end != menu_maplist_pos) 
	{
		format(menu_body[formatPos],511-formatPos,"^n9. %L^n0. %L",id,"MORE",id,"BACK")
		keys |= (1<<8)
	}
	else
	{
		format(menu_body[formatPos],511-formatPos,"^n0. %L",id,"BACK")
	}
	
	show_menu(id,keys,menu_body)
	
	return PLUGIN_CONTINUE
}

public menu_action_secondmaplist(id, key)
{
	if (key == 9) // go back
	{
		if (menu_position[id] == 0)
		{
			menu_show_secondmap(id)
		}
		else 
		{
			(menu_position[id])--
			menu_show_secondmaplist(id,menu_position[id])
		}
	}
	else if (key == 8) // Show next list of configs
	{
		(menu_position[id])++
		menu_show_secondmaplist(id,menu_position[id])
	}
	else 
	{	
		menu_selections[id][MENU_SELECTION_SECONDMAP] = key + (menu_position[id] * 8)
		
		menu_position[id] = 0
		menu_show_demo(id)
	}
	
	return PLUGIN_CONTINUE
}

// Demo Menu
public menu_show_demo(id)
{   
	new temp[256]

	#if defined(AMXMD_USE_HLTV)
	
	format(temp, 255, "\yAMX Match %L:\w^n^n1. %L^n2. HLTV^n3. %L & HLTV^n4. %L^n^n0. %L",LANG_SERVER, "MENU_RECORD_DEMO",id,"AMX_MATCH_IN_EYES",id,"AMX_MATCH_IN_EYES",id,"NO",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9), temp)
	
	#else
	
	format(temp, 255, "\yAMX Match %L:\w^n^n1. %L^n2. %L^n^n0. %L",LANG_SERVER, "MENU_RECORD_DEMO",id,"YES",id,"NO",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<9), temp)
	
	#endif
	
	return PLUGIN_CONTINUE
}

public menu_action_demo(id,key)
{
	if (key == 9)  // go back
	{
		if ( menu_selections[id][MENU_SELECTION_SECONDMAP] == -1 )
		{
			menu_show_secondmap(id)
		}
		else
		{
			menu_position[id] = 0
			menu_show_secondmaplist(id, 0)
		}
	}
	else  // select demo type and execute the match
	{	
		menu_selections[id][MENU_SELECTION_DEMOTYPE] = key
		
		menu_show_confirmation( id )
	}
	return PLUGIN_CONTINUE
}


// Confirm Menu
public menu_show_confirmation(id)
{   
	new temp[256]
	
	format(temp, 255, "\y%L\w^n^n1. %L^n2. %L^n^n0. %L",LANG_SERVER, "MENU_START_MATCH", id,"YES",id,"NO",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<9), temp)
	
	return PLUGIN_CONTINUE
}

public menu_action_confirmation(id,key)
{
	if (key == 9)  // go back
	{
		menu_show_demo(id)
	}
	else if (key == 1) 
	{
		menu_show_confirmation( id )
	}
	else  // execute the match
	{	
		match_start_menu( id )
	}
	
	return PLUGIN_CONTINUE
}


public menu_show_pugstyle(id)
{
	new temp[256]
	
	format(temp, 255, "\y%L\w^n^n1. %L^n2. %L^n^n0. %L",LANG_SERVER, "MENU_PUG_STYLE", id,"YES",id,"NO",id,"BACK")
	show_menu(id,(1<<0)|(1<<1)|(1<<9), temp)
	
	return PLUGIN_CONTINUE
}


public menu_action_pugstyle(id,key)
{
	if (key == 9)  // go back
	{
		menu_show_main(id)
	}
	else if (key == 1) // Just stop the match
	{
		match_stop(id, AMXMD_ACCESS)
	}
	else  // Stop the match and PUG game-play
	{	
		// Stopping PUG
		client_print(id,print_console,"* [AMX MATCH] %L...",id, "PUG_STOP")
		client_print(id,print_chat,"* [AMX MATCH] %L...",id, "PUG_STOP")
		
		match_pug_stop()
		
		match_stop(id, AMXMD_ACCESS)
	}
	
	return PLUGIN_CONTINUE
}

/* 
*
*	Misc functions
*
*/

public misc_changelevel(map[])
{
	server_cmd("changelevel %s", map)
	
	return PLUGIN_CONTINUE
}

public misc_exec_configs()
{
	if ( main_inovertime == 0 ) // If we are not in overtime
	{	
		client_print(0,print_chat,"* [AMX MATCH] %L (%s.cfg + %s)", LANG_PLAYER, "EXECUTING_MATCH_CONF", config_file_match, AMXMD_CONFIG_DEFAULT)
		server_cmd("exec ^"%s/%s.cfg^"", config_dir_leagues, config_file_match)
	}
	else if( get_cvar_num("amx_match_otcfg") == 0 )  // If we are in overtime and there is no overtime config file
	{
		client_print(0,print_chat,"* [AMX MATCH] %L (%s.cfg + %s)", LANG_PLAYER, "EXECUTING_MATCH_CONF", config_file_match, AMXMD_CONFIG_DEFAULT)
		server_cmd("exec ^"%s/%s.cfg^"", config_dir_leagues, config_file_match)
	}
	else // If we are in overtime and there is an overtime config file
	{
		client_print(0,print_chat,"* [AMX MATCH] %L (%sot.cfg + %s)", LANG_PLAYER, "EXECUTING_OVERTIME_CONF", config_file_match, AMXMD_CONFIG_DEFAULT)
		server_cmd("exec ^"%s/%sot.cfg^"", config_dir_leagues, config_file_match)
	}
	
	server_cmd("exec ^"%s/%s^"", config_dir_leagues, AMXMD_CONFIG_DEFAULT)
	
	return PLUGIN_CONTINUE
}

public misc_format_command()
{	
	// Declare variables
	new matchtype_str[32]
	new record_str[32]
	
	
	// Format string for match restart
	
	// main_command_demotype = 0: none
	// main_command_demotype = 1: player
	// main_command_demotype = 2: hltv
	// main_command_demotype = 3: both

	switch( main_command_demotype )
	{
		case 0:  // none
		{
			record_str = ""
		}
		
		case 1:  // player
		{
			record_str = "recdemo"
		}
		
		#if defined(AMXMD_USE_HLTV)
			case 2:  // hltv
			{
				record_str = "rechltv"
			}
			
			case 3:  // both
			{
				record_str = "recboth"
			}
		#endif
	}
	
	// main_command_matchtype = 0: maxround
	// main_command_matchtype = 1: timelimit
	// main_command_matchtype = 2: winlimit
	
	// Format match_type string
	switch( main_command_matchtype ) 
	{
		case 1: // Playing maxround
		{
			format(matchtype_str, 31, "mr%d", main_command_matchlength)
		}

		case 2: // Playing timelimit
		{
			format(matchtype_str, 31, "tl%d", main_command_matchlength)
		}
		
		case 3: // Playing winlimit
		{
			format(matchtype_str, 31, "wl%d", main_command_matchlength)
		}
	}
	
	// Format the actual match command		
	switch( main_command_type ) 
	{
		case 1:  // If match command was: amx_match
		{
			// amx_match <CT's clan tag> <T's clan tag> <mrXX or tlXX or wlXX> <Config filename> [recdemo|rechltv|recboth]
			format(main_command_full, 255, "amx_match %s %s %s %s %s", main_clanCT, main_clanT, matchtype_str, config_file_match, record_str)
		}
	
		case 2:  // If match command was: amx_match2
		{
			// amx_match2 <mrXX or tlXX or wlXX> <Config filename> [recdemo|rechltv|recboth]
			format(main_command_full, 255, "amx_match2 %s %s %s", matchtype_str, config_file_match, record_str)
		}
	
		case 3:  // If match command was: amx_match3
		{
			// amx_match3 <CT's clan tag> <T's clan tag> <mrXX or tlXX or wlXX> <Config filename> <Second map> [recdemo|rechltv|recboth]
			format(main_command_full, 255, "amx_match3 %s %s %s %s %s %s", main_clanCT, main_clanT, matchtype_str, config_file_match, main_secondmap, record_str)
		}
	
		case 4:  // If match command was: amx_match4
		{
			// amx_match4 <mrXX or tlXX or wlXX> <Config filename> <Second map> [recdemo|rechltv|recboth]
			format(main_command_full, 255, "amx_match4 %s %s %s %s", matchtype_str, config_file_match, main_secondmap, record_str)
		}
	}	
		
	return PLUGIN_CONTINUE		
}

public misc_reset_restarted()
{
	is_restarted = 0
	
	return PLUGIN_CONTINUE
}

public misc_restart_round(time[])
{
	set_cvar_string("sv_restart", time)
	
	return PLUGIN_CONTINUE
}

public misc_voice_enable(enable[])
{
	set_cvar_string("sv_voiceenable", enable)
	
	return PLUGIN_CONTINUE
}


/* 
*
*	Team randomizer functions
*
*/

public randomize_teams(id, level)
{
	// Declare variables	
	new num
	new players[32]
	
	new playersT_pos
	new playersCT_pos
	
	new playersT[32]
	new playersCT[32]
	
	new random_team
	
	new difference
	
	new player
	
	
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}

	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "RANDOMIZING_TEAMS")

	// Set the arrays
	get_players(players, num)
	for(new i = 0; i < num; i++)
	{
		player = players[i]
		
		if(is_user_connected(player) && (cs_get_user_team(player) != CS_TEAM_SPECTATOR ))
		{
			random_team = random_num(1,2)
			
			if(random_team == 1) 
			{
				playersT[playersT_pos++] = player
			}
			else 
			{
				playersCT[playersCT_pos++] = player
			}
		}
	}
	
	difference = abs(playersCT_pos - playersT_pos)
	
	if(difference > 1)
	{
		if(playersCT_pos > playersT_pos)
		{
			for(new i = playersCT_pos; (i >= 0) && (playersCT_pos > playersT_pos); i--)
			{
				playersT[playersT_pos++] = playersCT[--playersCT_pos]
			}
		}
		else
		{
			for(new i = playersT_pos; (i >= 0) && (playersT_pos > playersCT_pos); i--)
			{
				playersCT[playersCT_pos++] = playersT[--playersT_pos]
			}
		}
	}
	
	
	// Set T team
	for(new i = 0; i < playersT_pos; i++)
	{
		cs_set_user_team(playersT[i], CS_TEAM_T)
		
		client_print(playersT[i],print_chat,"* [AMX MATCH] %L", playersT[i], "NOW_ON_T")
	}	

	
	// Set CT team
	for(new i = 0; i < playersCT_pos; i++)
	{	
		cs_set_user_team(playersCT[i], CS_TEAM_CT)
		
		client_print(playersCT[i],print_chat,"* [AMX MATCH] %L", playersCT[i], "NOW_ON_CT")
	}
	
	
	misc_restart_round("2")
	
	
	return PLUGIN_CONTINUE
}


/*
*
*	Save Settings
*
*/


public save_settings(filename[]) 
{
	if (file_exists(filename))
	{
		delete_file(filename)
	}
	
	/*
	
		Writing this:
	
		// Amx Match Mod Config
		
		<cvars>
		
		
		// MENU
		
		// LENGTHS
		
		<lengths> 
		
		
		// CONFIGS
		
		<configs>

	*/
	
	new temp[128]

	format(temp, 127, "// %L^n", LANG_SERVER, "AMX_MATCH_CONFIG")
	if (!write_file(filename, temp))
	{
		return 0
	}
	
	new pos
	new text[1024]
	
	// Print Cvars
	for(new i = 0; i < NUM_CVARS; i++)
	{
		get_cvar_string(cvar_names[i], temp, 31)
		
		format(text,1023,"%s ^"%s^"", cvar_names[i],temp)
		write_file(filename,text)
	}

	format(temp, 127, "^n^n// %L^n", LANG_SERVER, "MENU")
	if (!write_file(filename,temp))
	{
		return 0
	}
	
	
	// Print Types

	format(temp, 127, "// %L^n", LANG_SERVER, "LENGTHS")
	if (!write_file(filename,temp))
	{
		return 0
	}
	
	if ( menu_lengthlist_pos > 0)
	{
		pos = format(text,1023,"amx_match_lmenu ")
		
		for(new i = 0; i < menu_lengthlist_pos; i++)
		{
			pos += format(text[pos],1023 - pos,"^"%s^" ", menu_lengthlist[i])
					
			if( ((i + 1) % 8) == 7 && (i + 1) < menu_lengthlist_pos)
			{
				pos += format(text[pos],1023 - pos,"^namx_match_lmenu ")
			}
		} 

		write_file(filename,text)
	}


	// Print Configs

	format(temp, 127, "^n^n// %L^n", LANG_SERVER, "CONFIGS")
	if (!write_file(filename,temp))
	{
		return 0
	}
	
	if ( menu_configlist_pos > 0)
	{
		for(new i = 0; i < menu_configlist_pos; i++)
		{
			format(text,1023,"amx_match_cmenu ^"%s^" ^"%s^"", menu_configlist_name[i],menu_configlist_file[i])
			write_file(filename,text)
		}
	}

	return 1
}

public save_settings_console(id, level)
{
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}
	
	client_print(id,print_chat,"* [AMX MATCH] %L ...",id, "SETTINGS_SAVED")
	
	// Save plugin settings file
	save_settings(config_file_plugin)
	
	return PLUGIN_CONTINUE
}

/* 
*
*		Score
*
*/

public score_vote_playout()
{
	 new menu_message[256]
	 new Float:vote_time = get_cvar_float("amx_vote_time") + 2.0
	 
	 vote_areVoting = 1
	 
	 format(menu_message, 255, "\y[AMX Match] %L\w^n^n1. %L^n2. %L", LANG_SERVER, "OVERTIME_QUESTION", LANG_PLAYER, "YES", LANG_PLAYER, "NO")

	 set_cvar_float("amx_last_voting",  get_gametime() + vote_time )
	 show_menu(0,(1<<0)|(1<<1), menu_message, floatround(vote_time))
 
	 set_task(vote_time,"score_vote_check")
	 
	 client_print(0, print_chat, "* %L", LANG_PLAYER, "OVERTIME_VOTE_START")
	 
	 vote_option[0] = 0
	 vote_option[1] = 0
	 
	 return PLUGIN_HANDLED
}

public score_vote_count(id,key)
{
	new user_name[32]	
	
	if ( get_cvar_float("amx_vote_answers") )
	{		
		get_user_name(id, user_name, 31)
	
		client_print(0,print_chat,"* %L %s", LANG_PLAYER, "OVERTIME_VOTE", user_name, key ? "against" : "for" )
	}
	
	vote_option[key]++
	
	return PLUGIN_HANDLED
}

public score_vote_check(id)
{
	if (vote_option[0] > vote_option[1])
	{
		cvar_endtype = 0
		client_print(0, print_chat, "* %L", LANG_PLAYER, "OVERTIME_PLAYOUT", vote_option[0], vote_option[1])
	}
	else
	{
		client_print(0, print_chat, "* %L", LANG_PLAYER, "OVERTIME_NO_PLAYOUT", vote_option[0], vote_option[1])
		half_stop()
	}
	
	return PLUGIN_CONTINUE
} 


public score_show()
{
	new score_message[1024]
	
	new ct_score = main_score_ct[0] + main_score_ct[1] + main_score_2mm_ct + main_score_overtime
	new t_score = main_score_t[0] + main_score_t[1] + main_score_2mm_t + main_score_overtime
	
	
	if ((main_inprogress > 0) && (get_cvar_num("amx_match_showscore") > 0)) // If there is a match in progress and we are showing the scores
	{
		// Format the score message	
		if( ct_score > t_score ) // If the ct team is winning
		{
			format(score_message, 1023, "* [AMX MATCH] %L", LANG_PLAYER, "SCORES_IS_WINNING", main_clanCT, ct_score, t_score)
		}
		else if( ct_score < t_score ) // If the t team is winning
		{
			format(score_message, 1023, "* [AMX MATCH] %L", LANG_PLAYER, "SCORES_IS_WINNING", main_clanT, t_score, ct_score)
		}
		else // If neither team is winning
		{
			format(score_message, 1023, "* [AMX MATCH] %L", LANG_PLAYER, "SCORES_DRAW", ct_score)
		}
		
		// Set and show the hud message
		set_hudmessage(255, 255, 0, 0.0, 0.90, 0, 2.0, 5.0, 0.8, 0.8, 4)
		show_hudmessage(0, score_message)
	}
	
	return PLUGIN_CONTINUE
}

public score_new()
{
	new team[32]
	
	read_data(1, team, 31)
	
	if ( main_inprogress == 2 ) // Playing a half
	{	
		if (team[0] == 'C')
		{
			main_score_ct[0] = read_data(2)
		}
		else if (team[0] == 'T')
		{
			main_score_t[0] = read_data(2)
		}		
	}
	else if( main_inprogress == 4 )
	{	
		if (team[0] == 'C')
		{
			main_score_t[1] = read_data(2)
		}
		else if (team[0] == 'T')
		{
			main_score_ct[1] = read_data(2)
		}
	}
	
	
	if( main_inprogress == 2 || main_inprogress == 4 )
	{
		score_new_matchtype()
	}
	
	if( get_cvar_num("amx_match_showscore") == 1 )
	{
		score_show()
	}
	
	return PLUGIN_CONTINUE

}

public score_new_matchtype()
{
	switch( main_command_matchtype )
	{
		case 1: // Playing maxround
		{
			score_new_maxround()
		}
		case 2: // Playing timelimit
		{
			score_new_timelimit()
		}
		case 3: // Playing winlimit
		{
			score_new_winlimit()
		}
	}
	
	return PLUGIN_CONTINUE
}

public score_new_maxround()
{
	new rounds_played = (main_score_ct[0] + main_score_ct[1] + main_score_t[0] + main_score_t[1])
	
	if  ( (main_inprogress == 2) && ((main_score_ct[0] + main_score_t[0]) == main_command_matchlength) ) // Playing 1st half and it's finished
	{
		half_stop()
	}
	else if( main_inprogress == 4 ) // Playing 2nd half
	{
		if( rounds_played == (main_command_matchlength * 2) ) // 2nd half is finished
		{
			half_stop()
		}
		else if( ((main_score_ct[0] + main_score_ct[1]) == (main_command_matchlength + 1)) || ((main_score_t[0] + main_score_t[1]) == (main_command_matchlength + 1)) ) // 2nd half is finished
		{	
			if ( cvar_endtype == 1 )
			{
				half_stop()
			}
			else if( (cvar_endtype == 2) && (main_inovertime != 1) )
			{
				if( rounds_played < ((main_command_matchlength * 2) - ((main_command_matchlength * 2) / AMXMD_PLAYOUT_RATIO)) ) // 2nd half is finished  
				{    
					// Vote...    
					if ( vote_areVoting == 0 )  // If there is no vote        
					{
						score_vote_playout()											
					}
					else
					{
						cvar_endtype = 0
					}
				}
			}
			else if( (cvar_endtype == 2) && (main_inovertime == 1) )
			{
				half_stop()
			}	
		}
	}
		
	return PLUGIN_CONTINUE
}

public score_new_timelimit()
{		
	if( (main_inprogress == 2) && (main_seconds == 0) )
	{
		if ( task_exists( TASKID_DECREMENT_SECONDS ) )
		{
			remove_task( TASKID_DECREMENT_SECONDS )
		}
			
		if ( task_exists( TASKID_TIMER_SHOW ) )
		{
			remove_task( TASKID_TIMER_SHOW )
		}

		half_stop()
	}
	else if ( (main_inprogress == 4) && (main_seconds == 0) )
	{
		if ( task_exists( TASKID_DECREMENT_SECONDS ) )
		{
			remove_task( TASKID_DECREMENT_SECONDS )
		}
			
		if ( task_exists( TASKID_TIMER_SHOW ) )
		{
			remove_task( TASKID_TIMER_SHOW )			
		}
		
		half_stop()
	}
		
	return PLUGIN_CONTINUE
}

public score_new_winlimit()
{
	if ( (main_inprogress == 2) ) // Playing 1st half
	{
		if( ( main_score_ct[0] == main_command_matchlength) || ( main_score_t[0] == main_command_matchlength) ) // Half is finished
		{
			half_stop()
		}
	}
	else if (main_inprogress == 4) // Playing 2nd half
	{
		if( ( main_score_ct[1] == main_command_matchlength) || ( main_score_t[1] == main_command_matchlength) ) // Half is finished
		{
			half_stop()
		}
	}
		
	return PLUGIN_CONTINUE
}


/* 
*
*	Stats functions
*
*/

#if !defined(AMXMD_USE_SQL)

public stats_log(half)
{
	new stats_file_match[64]
	
	new player_authid[32]
	new player_name[32]
	new player_kills
	new player_deaths
	new player_team

	new players[32]
	new num
	
	new match_num_len
	new match_num_str[32]
	
	new stats[512]
	new stats_pos
	
	new match_number
	
	new player
	
	new CsTeams:team
	
	new map_number = 0

	
	// If the stats dir isn't there...create it
	if( !(dir_exists(stats_dir_main)) )
	{
		mkdir(stats_dir_main)
	}
	
	// Write the match number to the main file
	if( file_size(stats_file_main, 1) > 2 ) // If there are matches in the stats file
	{
		if( file_size(stats_file_main, 2) )
		{
			read_file(stats_file_main, file_size(stats_file_main, 1) - 2, match_num_str, 31, match_num_len)
		}
		else
		{
			read_file(stats_file_main, file_size(stats_file_main, 1) - 1, match_num_str, 31, match_num_len)
		}
		
		match_number = str_to_num(match_num_str) + 1
	}
	else
	{
		match_number = 0
	
		write_file(stats_file_main, "// Match stats - Main")
		write_file(stats_file_main, "// DO NOT EDIT THIS FILE")
		write_file(stats_file_main, "")
	}


	num_to_str( match_number, match_num_str, 31 )
	write_file(stats_file_main, match_num_str)


/*	
	// Get match number
	if( file_size(stats_file_main, 1) > 2 ) // If there are matches in the stats file
	{
		if( file_size(stats_file_main, 2) )
		{
			read_file(stats_file_main, file_size(stats_file_main, 1) - 2, match_num_str, 31, match_num_len)
		}
		else
		{
			read_file(stats_file_main, file_size(stats_file_main, 1) - 1, match_num_str, 31, match_num_len)
		}
		
		match_number = str_to_num(match_num_str) + 1
	}
	else
	{
		// Yes...I know it's already initialized to 0, but this is easier to read
		match_number = 0
	}		
*/

	// Change map number
	if( main_in2mapmatch == 1 )
	{
		map_number = 1
	}

	format(stats_file_match, 63, "%s\%d_0%d%d.dat", stats_dir_main, match_number, map_number, half)

	if(file_exists(stats_file_match))
	{
		delete_file(stats_file_match)
	}


	// Match file
	
	format(stats, 511, "// Match stats - Match #%d", match_number)

	write_file(stats_file_match, stats)
	write_file(stats_file_match, "// DO NOT EDIT THIS FILE")
	write_file(stats_file_match, "")

	stats_pos = format(stats, 511, "%d^n", half)
	
	// Team scores
	if( (half == 1) || (half == 3) )
	{
		// Team names
		format(stats[stats_pos], 511 - stats_pos, "%s;%s", main_clanT, main_clanCT)
		
		// Scores
		format(stats[stats_pos], 511 - stats_pos, "%d;%d^n", main_score_t[0], main_score_ct[0])
	}
	else if( half == 2 || (half == 4) )
	{
		// Team names
		format(stats[stats_pos], 511 - stats_pos, "%s;%s", main_clanCT, main_clanT)		
		
		// Scores
		format(stats[stats_pos], 511 - stats_pos, "%d;%d^n", main_score_ct[1], main_score_t[1])
	}
	
	// Team names
	format(stats[stats_pos], 511 - stats_pos, "%s;%s", main_clanT, main_clanCT)
	
	write_file(stats_file_match, stats)
	
	
	// Add players to half file
	get_players(players, num)	
	
	for(new i = 0; i < num; i++)
	{
		player = players[i]

		team = cs_get_user_team(player)

		if( team != CS_TEAM_SPECTATOR )	
		{		
			get_user_authid( player, player_authid, 31)		
			
			get_user_name( player, player_name, 31)
			
			player_kills = get_user_frags(player)
			player_deaths = get_user_deaths(player)


			if ( team == CS_TEAM_T )
			{
				player_team = 1
			}
			else if( team == CS_TEAM_CT )
			{
				player_team = 2
			}
			
			format(stats, 511, "%s;%s;%d;%d;%d", player_authid, player_name, player_kills, player_deaths, player_team)
			write_file(stats_file_match, stats)
		}
	}
	
	return PLUGIN_CONTINUE
}

#else

public stats_log_sql(half)
{
	new half_name[32]

	new Handle:Query			// The result handle, holds the query.
	new error[512]
	
	new match_id = -1
	new half_id = -1
	new map_id = -1
	new map2_id = -1
	
	new ErrorCode
	
	new create_query[512]
	
	
	SqlConnection = SQL_Connect(SqlTuple, ErrorCode, error, 511)
	
	if (SqlConnection == Empty_Handle)
	{ 
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{	
		// Log maps and get map_id's back
		map_id = stats_log_sql_map(main_firstmap)
		
		// 
		if( main_in2mapmatch == 1 )
		{
			map2_id = stats_log_sql_map(main_secondmap)
		}
		
		// If we are in the first half and not on the second map	
		if( half == 1 && main_in2mapmatch != 1 )
		{
			// Insert into the main table
			format(create_query, 511, "INSERT INTO `%s` ( `map1_id`, `map2_id`, `half1_id`, `half2_id`, `half3_id`, `half4_id`, `half5_id`, `half6_id`, `half7_id`, `half8_id` ) VALUES ( '%d', '%d', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1' );", AMXMD_SQL_MAIN, map_id, map2_id)
			SQL_SimpleQuery( SqlConnection, create_query )
		}
	
		Query = SQL_PrepareQuery(SqlConnection, "SELECT * FROM `%s` ORDER BY `match_id` DESC LIMIT 1;", AMXMD_SQL_MAIN)
		
		// run the query
		if(!SQL_Execute(Query))
		{
			// if there were any problems
			SQL_QueryError(Query, error, 511)
			log_amx("[AMXX] SQL Connection Failed: %s", error)
		}
		else
		{
			match_id = SQL_ReadResult(Query, 0)
		
			SQL_FreeHandle(Query)
		
			// Insert into the half table, team table, and player tables (inside half function)
			half_id = stats_log_sql_half( half )
			
			// Set half_name to the correct half
			if( main_in2mapmatch != 1 )
			{
				format(half_name, 31, "half%d_id", half)
			}
			else
			{	
				format(half_name, 31, "half%d_id", half+4)	
			}
			
			// Now update the main table with the half_id
			format(create_query, 511, "UPDATE `%s` SET `%s` = '%d' WHERE `match_id` = '%d';", AMXMD_SQL_MAIN, half_name, half_id, match_id)
			SQL_SimpleQuery( SqlConnection, create_query )
			
			SQL_FreeHandle(SqlConnection)
		}
	}
	
	return PLUGIN_CONTINUE
}


public stats_log_sql_half( half )
{
	new half_id = -1
	
	new team_id = -1
	new team_id2 = -1
	
	new team1_score
	new team2_score
	
	new team1_name[32]
	new team2_name[32]
	
	new Handle:Query 		// The result handle, holds the query.
	
	new error[512]
	
			
	// Setup the insert for half
	if( (half == 1) || (half == 3) )
	{
		team1_score = main_score_t[0]
		team2_score = main_score_ct[0]
	
		// Copy team names
		copy(team1_name, 31, main_clanT)
		copy(team2_name, 31, main_clanCT)
	}
	else if( half == 2 || (half == 4) )
	{
		team1_score = main_score_ct[1]
		team2_score = main_score_t[1]
		
		// Copy team names
		copy(team1_name, 31, main_clanCT)
		copy(team2_name, 31, main_clanT)
	}

	// Insert into team table and get team_id back
	team_id = stats_log_sql_team( team1_name )
	team_id2 = stats_log_sql_team( team2_name )


	// Insert into the half table
	Query = SQL_PrepareQuery(SqlConnection, "INSERT INTO `%s` ( `team1_id` , `team1_score` , `team2_id` , `team2_score` ) VALUES ( '%d', '%d', '%d', '%d' );", AMXMD_SQL_HALF, team_id, team1_score, team_id2, team2_score)
	
	// run the query
	if(!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, error, 511)
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		half_id = SQL_GetInsertId ( Query )
		
		SQL_FreeHandle(Query)
		
		stats_log_sql_player_main( half_id, team_id, team_id2 )
	}
	
	
	return half_id
}

public stats_log_sql_map( map[] )
{
	new map_id = -1
	
	new Handle:Query 		// The result handle, holds the query.
	new error[512]
	
	new num_rows


	Query = SQL_PrepareQuery(SqlConnection, "SELECT * FROM `%s` WHERE `map_name` = ^"%s^";", AMXMD_SQL_MAP, map)
	
	// run the query
	if(!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, error, 511)
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		num_rows = SQL_NumResults ( Query )
	
		// If map wasn't in the player table, then add it and get map_id
		if( num_rows == 0 )
		{
			Query = SQL_PrepareQuery(SqlConnection, "INSERT INTO `%s` ( `map_name` ) VALUES ( ^"%s^" );", AMXMD_SQL_MAP, map)
		
			// run the query
			if(!SQL_Execute(Query))
			{
				// if there were any problems
				SQL_QueryError(Query, error, 511)
				log_amx("[AMXX] SQL Connection Failed: %s", error)
			}
			else
			{
				map_id = SQL_GetInsertId ( Query )
			}
		}
		else // or just get the map_id
		{
			map_id = SQL_ReadResult(Query, 0)
		}
	
		SQL_FreeHandle(Query)
	}

	return map_id
}

public stats_log_sql_player( player[] )
{
	new player_id = -1
	
	new Handle:Query 		// The result handle, holds the query.
	new error[512]
		
	new num_rows


	Query = SQL_PrepareQuery(SqlConnection, "SELECT * FROM `%s` WHERE `player_steamid` = ^"%s^";", AMXMD_SQL_PLAYER, player)
	
	// run the query
	if(!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, error, 511)
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		num_rows = SQL_NumResults ( Query )
	
		// If player wasn't in the player table, then add it and get player_id
		if( num_rows == 0 )
		{
			Query = SQL_PrepareQuery(SqlConnection, "INSERT INTO `%s` ( `player_steamid` ) VALUES ( ^"%s^" );", AMXMD_SQL_PLAYER, player)
		
			// run the query
			if(!SQL_Execute(Query))
			{
				// if there were any problems
				SQL_QueryError(Query, error, 511)
				log_amx("[AMXX] SQL Connection Failed: %s", error)
			}
			else
			{
				player_id = SQL_GetInsertId ( Query )
			}
		
		}
		else // or just get the player_id
		{
			player_id = SQL_ReadResult(Query, 0)
		}
	
		SQL_FreeHandle(Query)
	}

	return player_id
}

public stats_log_sql_player_main( half_id, team1_id, team2_id )
{
	new player
	
	new player_authid[32]
	new player_name[32]
	new player_kills
	new player_deaths

	new players[32]
	new num
	
	new CsTeams:team
	
	new player_id = -1
	new team_id = -1
	
	new create_query[512]

	
	// Insert the players into the player table
	get_players(players, num)	
	
	for(new i = 0; i < num; i++)
	{
		player = players[i]
		
		team = cs_get_user_team(player)

		if( team != CS_TEAM_SPECTATOR )	
		{	
			get_user_authid( player, player_authid, 31)		
			
			player_id = stats_log_sql_player( player_authid )
			
			
			get_user_name( player, player_name, 31)
			
			stats_log_sql_player_name( player_id, player_name )
			

			if ( team == CS_TEAM_T )
			{
				team_id = team1_id
			}
			else if( team == CS_TEAM_CT )
			{
				team_id = team2_id
			}

			
			player_kills = get_user_frags(player)
			player_deaths = get_user_deaths(player)
		
			format(create_query, 511, "INSERT INTO `%s` ( `player_id` , `half_id` , `player_frags` , `player_deaths` , `team_id` ) VALUES ( '%d', '%d', '%d', '%d', '%d' );", AMXMD_SQL_PLAYER_STATS, player_id, half_id, player_kills, player_deaths, team_id)
			SQL_SimpleQuery( SqlConnection, create_query )
		}
	}
	
	return PLUGIN_CONTINUE
}

public stats_log_sql_player_name( player_id, player[] )
{
	new Handle:Query 		// The result handle, holds the query.
	new error[512]
	
	new num_rows

	new create_query[512]


	Query = SQL_PrepareQuery(SqlConnection, "SELECT * FROM `%s` WHERE `player_id` = '%d' AND `player_name` = ^"%s^";", AMXMD_SQL_PLAYER_NAME, player_id, player)
	
	// run the query
	if(!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, error, 511)
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		num_rows = SQL_NumResults ( Query )
	
		SQL_FreeHandle(Query)
	
		// If player wasn't in the player name table, then add it and get player_id
		if( num_rows == 0 )
		{
			format(create_query, 511, "INSERT INTO `%s` ( `player_id`, `player_name` ) VALUES ( '%d', ^"%s^" );", AMXMD_SQL_PLAYER_NAME, player_id, player)
			SQL_SimpleQuery( SqlConnection, create_query )
		}
	}
	
	return PLUGIN_CONTINUE
}

public stats_log_sql_team( team[] )
{
	new team_id = -1
	
	new Handle:Query 		// The result handle, holds the query.
	new error[512]
	
	new num_rows

	
	Query = SQL_PrepareQuery(SqlConnection, "SELECT * FROM `%s` WHERE `team_name` = ^"%s^";", AMXMD_SQL_TEAM, team)
	
	// run the query
	if(!SQL_Execute(Query))
	{
		// if there were any problems
		SQL_QueryError(Query, error, 511)
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		num_rows = SQL_NumResults ( Query )
	
		// If team wasn't in the team table, then add it and get team_id
		if( num_rows == 0 )
		{
			Query = SQL_PrepareQuery(SqlConnection, "INSERT INTO `%s` ( `team_name` ) VALUES ( ^"%s^" );", AMXMD_SQL_TEAM, team)
		
			// run the query
			if(!SQL_Execute(Query))
			{
				// if there were any problems
				SQL_QueryError(Query, error, 511)
				log_amx("[AMXX] SQL Connection Failed: %s", error)
			}
			else
			{
				team_id = SQL_GetInsertId ( Query )
			}
		}
		else // or just get the team_id
		{
			team_id = SQL_ReadResult(Query, 0)
		}
		
		SQL_FreeHandle(Query)
	}
	
	return team_id
}

#endif

public stats_resetmatch()
{
	new i
	
	new file_len
	
	new line[256]
	new line_len
	
	new stats_file_temp[64]
	
	format(stats_file_temp, 63, "%s/temp.dat", stats_dir_main)


	// Delete the match number in the match file
	if( file_size(stats_file_main, 2) )
	{
		i = 0
		
		file_len = (file_size(stats_file_main, 1) - 3)
		
		while(read_file(stats_file_main, i, line, 255, line_len) && i < file_len)
		{
			write_file (stats_file_temp, line)
			
			i++
		}
	
		delete_file ( stats_file_main )
	
		rename_file ( stats_file_temp, stats_file_main )
	}
	else
	{
		write_file( stats_file_main, "", file_size(stats_file_main, 1) - 1)
	}	
	
	
	return PLUGIN_CONTINUE
}

#if defined(AMXMD_USE_SQL)
public stats_resetmatch_sql()
{
	new Handle:Query
	new error[512]
	new ErrorCode
	
	new match_id = -1
	new half_id = -1
	
	new create_query[512]


	SqlConnection = SQL_Connect(SqlTuple, ErrorCode, error, 511)
	
	if (SqlConnection == Empty_Handle)
	{ 
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		Query = SQL_PrepareQuery(SqlConnection, "SELECT * FROM `%s` ORDER BY `match_id` DESC LIMIT 1;", AMXMD_SQL_MAIN)
		
		// run the query
		if(!SQL_Execute(Query))
		{
			// if there were any problems
			SQL_QueryError(Query, error, 511)
			log_amx("[AMXX] SQL Connection Failed: %s", error)
		}	
		else
		{
			match_id = SQL_ReadResult(Query, 0)
	
		
			for( new i = 3; i < 11; i++ )
			{
				half_id = SQL_ReadResult(Query, i)
				
				format(create_query, 511, "DELETE FROM `%s` WHERE `half_id` = '%d';", AMXMD_SQL_HALF, half_id)
				SQL_SimpleQuery( SqlConnection, create_query )
				
				format(create_query, 511, "DELETE FROM `%s` WHERE `half_id` = '%d';", AMXMD_SQL_PLAYER_STATS, half_id)
				SQL_SimpleQuery( SqlConnection, create_query )
			}	
			
			format(create_query, 511, "DELETE FROM `%s` WHERE `match_id` = '%d' LIMIT 1;", AMXMD_SQL_MAIN, match_id )
			SQL_SimpleQuery( SqlConnection, create_query )
		
			SQL_FreeHandle( Query )
			SQL_FreeHandle( SqlConnection )
		}
	}

	return PLUGIN_CONTINUE
}

#endif


/* 
*
*	Swap functions
*
*/

public swap_teams()
{
	new playersCT[32]
	new playersT[32]
	new nbrCT, nbrT
	
	client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "SWITCHING_TEAMS")
	
	get_players(playersCT,nbrCT,"e","CT")
	get_players(playersT,nbrT,"e","TERRORIST")

	for(new i = 0; i < nbrCT; i++)
	{
		cs_set_user_team(playersCT[i], CS_TEAM_T)

		client_print(playersCT[i],print_chat,"* [AMX MATCH] %L", playersCT[i], "NOW_ON_T")
	}

	for(new i = 0; i < nbrT; i++)
	{
		cs_set_user_team(playersT[i], CS_TEAM_CT)
		
		client_print(playersT[i], print_chat, "* [AMX MATCH] %L", playersT[i], "NOW_ON_CT")
	}

	return PLUGIN_CONTINUE
}

public swap_teams_console(id, level)
{
	if (!access(id,level))
	{
		console_print(id,"* [AMX MATCH] %L", id, "COMMAND_NO_AUTH")
		console_print(id,"* %L", id, "COMMAND_NO_AUTH")
		
		return PLUGIN_HANDLED
	}
	
	new name[32]
	
	get_user_name(id,name,31)
	
	switch(get_cvar_num("amx_show_activity")) 
	{	
		case 2: client_print(0,print_chat,"%L %s: %L",LANG_PLAYER, "ADMIN",name, LANG_PLAYER, "SWITCHED_TEAM")
		case 1: client_print(0,print_chat,"%L %L",LANG_PLAYER, "ADMIN", LANG_PLAYER, "SWITCHED_TEAM")
	}
	
	// Make sure that server won't stop the swap
	set_cvar_num("mp_limitteams",0)
	set_cvar_num("mp_autoteambalance",0)
	
	swap_teams()
	
	misc_restart_round("1")
	
	return PLUGIN_CONTINUE
}


/* 
*
*		Screenshot Functions
*
*/

public screenshot_take()
{
	new players[32]
	new number
	
	get_players(players, number)
	
	for(new i=0; i < number; i++)
	{
		#if defined(AMXMD_USE_HLTV)
			if (players[i] != hltv_id)
			{
				client_cmd(players[i],"snapshot")
			}
		#else
			client_cmd(players[i],"snapshot")
		#endif
	}
	
	return PLUGIN_CONTINUE
}

public screenshot_scoreboard_show()
{
	client_cmd(0, "+showscores")
	
	return PLUGIN_CONTINUE
}

public screenshot_scoreboard_remove()
{
	client_cmd(0, "-showscores")
	
	return PLUGIN_CONTINUE
}

public screenshot_setup()
{
	new screenshot = get_cvar_num("amx_match_screenshot")
	
	if (screenshot > 0) 
	{
		// Display message about taking screenshots
		client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "TAKING_SCREENSHOTS")
		
		if (screenshot == 2) // If taking a screenshot with steamids
		{	
			// Show scoreboard, take a screenshot, then remove the scoreboard
			screenshot_scoreboard_show()
			set_task(0.5, "screenshot_take")
			set_task(1.0, "screenshot_scoreboard_remove")
			
			// Show authids (steamids) and take a screenshot
			set_task(1.0, "screenshot_steamid")
			set_task(1.5, "screenshot_take")
		}
		else  // If taking a screenshot without steamids
		{	
			// Show scoreboard, take a screenshot, then remove the scoreboard
			screenshot_scoreboard_show()
			set_task(0.5, "screenshot_take")
			set_task(1.0, "screenshot_scoreboard_remove")
		}
	}
	
	return PLUGIN_CONTINUE
}

public screenshot_steamid()
{
	new player_ids[32]
	new number
	
	new player_name[64]				// Contains the player's name
	new player_authid[64]			// Contains the player's authid

	new hud_message_ct[1024]			// Contains hud message with steamids and names for the CTs	
	new hud_message_t[1024]			// Contains hud message with steamids and names for the Ts
	
	new position_ct = 0				// Contains the position of the hud_message_ct
	new position_t = 0				// Contains the position of the hud_message_terrorist
	
	new CsTeams:team
	
	new player
	
	
	// Insert the title into the hud message for the CTs
	position_ct = format( hud_message_ct, 1023, "Counter-Terrorist SteamIDs: ^n" )	

	// Insert the title into the hud message for the Ts
	position_t = format( hud_message_t, 1023, "Terrorist SteamIDs: ^n" )
	
	
	// Get players
	get_players(player_ids, number)
	
	// Set the arrays for player names and authids (steamids)
	for(new i = 0; i < number; i++) 
	{
		player = player_ids[i]
		
#if defined(AMXMD_USE_HLTV)

		if (player != hltv_id)
		{
			team = cs_get_user_team(player)
			
			// Get player's name and insert into player_name
			get_user_name(player, player_name, 63)					

			// Get the player's authid and insert it into player_authid
			get_user_authid(player, player_authid, 63)				

			if ( team == CS_TEAM_CT )
			{
				// Insert the name and steamid of player into the CT hud message
				position_ct += format( hud_message_ct[position_ct], 1023 - position_ct, "    %s  -  %s^n", player_name, player_authid)
			}
			else if( team == CS_TEAM_T )
			{
				// Insert the name and steamid of player into the T hud message
				position_t += format( hud_message_t[position_t], 1023 - position_t, "    %s  -  %s^n", player_name, player_authid)
			}
		}

#else

		team = cs_get_user_team(player)
		
		// Get player's name and insert into player_name
		get_user_name(player, player_name, 63)					

		// Get the player's authid and insert it into player_authid
		get_user_authid(player, player_authid, 63)				

		if ( team == CS_TEAM_CT )
		{
			// Insert the name and steamid of player into the CT hud message
			position_ct += format( hud_message_ct[position_ct], 1023 - position_ct, "    %s  -  %s^n", player_name, player_authid)
		}
		else if( team == CS_TEAM_T )
		{
			// Insert the name and steamid of player into the T hud message
			position_t += format( hud_message_t[position_t], 1023 - position_t, "    %s  -  %s^n", player_name, player_authid)
		}

#endif

	}
	
	
	// Set the hud message for CT names and steamids
	set_hudmessage(42, 255, 212, 0.15, 0.25, 0, 6.0, 12.0, 0.8, 0.8, -1)	
	
	// Display the hud message for the CT names and steamids
	show_hudmessage(0, hud_message_ct)
	

	// Set the hud message for T names and steamids
	set_hudmessage(42, 255, 212, 0.50, 0.25, 0, 6.0, 12.0, 0.8, 0.8, -1)	
	
	// Display the hud message for the T names and steamids
	show_hudmessage(0, hud_message_t)
	
	return PLUGIN_CONTINUE
}

/* 
*
*		SQL
*
*/

#if defined(AMXMD_USE_SQL)

public sql_init()
{
	new ErrorCode
	new Handle:SqlConnection
	
	new error[512]
	
	new host[64]
	new username[32]
	new password[32]
	new dbname[32]
	
	new create_query[1024]
	
	new query_pos
	
	get_cvar_string("amx_sql_host",host,64)
	get_cvar_string("amx_sql_user",username,32)
	get_cvar_string("amx_sql_pass",password,32)
	get_cvar_string("amx_sql_db",dbname,32)
	
	
	SqlTuple = SQL_MakeDbTuple(host, username, password, dbname)
	
	SqlConnection = SQL_Connect(SqlTuple, ErrorCode, error, 511)
	
	if (SqlConnection == Empty_Handle)
	{ 
		log_amx("[AMXX] SQL Connection Failed: %s", error)
	}
	else
	{
		// `amx_match_main`	
		// Format create query for the main match table
		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_MAIN)
		query_pos += format(create_query[query_pos],1023-query_pos,"  `match_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `map1_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `map2_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half1_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half2_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half3_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half4_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half5_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half6_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half7_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half8_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`match_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")

		// Execute create query for `amx_match_main`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))



		// `amx_match_half`
		// Format create query for the half table
		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_HALF)
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team1_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team1_score` int(4) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team2_id` int(10) NOT NULL default '-1',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team2_score` int(4) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`half_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")
		
		// Execute create query for `amx_match_half`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))



		// `amx_match_map`
		// Format create query for the map table

		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_MAP)		
		query_pos += format(create_query[query_pos],1023-query_pos,"  `map_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `map_name` varchar(64) NOT NULL default '',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`map_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")

		// Execute create query for `amx_match_map`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))
		
			
	
		// `amx_match_player`
		// Format create query for the player table
		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_PLAYER)
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_steamid` varchar(64) NOT NULL default '',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`player_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")
		
		// Execute create query for `amx_match_player`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))
		
		
		
		// `amx_match_player_name`
		// Format create query for the player name table
		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_PLAYER_NAME)
		query_pos += format(create_query[query_pos],1023-query_pos,"  `name_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_id` int(10) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_name` varchar(64) NOT NULL default '',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`name_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")
		
		// Execute create query for `amx_match_player_name`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))
		
		
		
		// `amx_match_player_statistics`
		// Format create query for the player statistics table
		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_PLAYER_STATS)
		query_pos += format(create_query[query_pos],1023-query_pos,"  `statistics_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `half_id` int(10) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_id` int(10) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_frags` int(4) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `player_deaths` int(4) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team_id` int(4) NOT NULL default '0',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`statistics_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")
		
		// Execute create query for `amx_match_player_statistics`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))
		


		// `amx_match_team`
		// Format create query for the team table
		query_pos = format(create_query,1023,"CREATE TABLE IF NOT EXISTS `%s` (", AMXMD_SQL_TEAM)
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team_id` int(10) NOT NULL auto_increment,")
		query_pos += format(create_query[query_pos],1023-query_pos,"  `team_name` varchar(64) NOT NULL default '',")
		query_pos += format(create_query[query_pos],1023-query_pos,"  PRIMARY KEY  (`team_id`)")
		query_pos += format(create_query[query_pos],1023-query_pos,") TYPE=MyISAM;")
		
		// Execute create query for `amx_match_team`
		SQL_Execute(SQL_PrepareQuery(SqlConnection, create_query))
	}
	
	SQL_FreeHandle(SqlConnection)
    
	return PLUGIN_CONTINUE
}

#endif

/* 
*
*		Timer
*
*/

public timer_show()
{
	set_hudmessage(255,255,255,0.75,0.05,0, 1.0, 1.0, 0.0, 0.0, 3) 
	show_hudmessage(0, "Time remaining: %d:%02d", main_seconds / 60, main_seconds % 60)
	
	return PLUGIN_CONTINUE
}

public timer_start()
{
	set_task(1.0, "timer_decrement_seconds", TASKID_DECREMENT_SECONDS, "", 0, "b")
	set_task(1.0, "timer_show", TASKID_TIMER_SHOW, "", 0, "b")
	
	return PLUGIN_CONTINUE
}

public timer_decrement_seconds()
{	
	if( main_seconds != 0 )
	{
		main_seconds--
	}
	else if( get_cvar_num("amx_match_endtype") == 0 )  // End match immediately when timelimit is up
	{
		score_new_timelimit()
	}
	
	return PLUGIN_CONTINUE
}


/* 
*
*		Uninit
*
*/

public uninit()
{
	new map[32]
	new map_length
	
	// Stop demos
	if (main_command_demotype > 0)
	{
		demo_stop()
	}
	
	if( (get_cvar_num("amx_match_showscore") == 2) && task_exists(TASKID_SHOW_SCORE))
	{
		remove_task(TASKID_SHOW_SCORE)
	}
	
	// Remove 'pick a team' message
	if(task_exists(TASKID_KNIFEROUND_MESSAGE))
	{
		remove_task(TASKID_KNIFEROUND_MESSAGE)
	}
	
	
	// Delete 2mm files (Idiot-proof feature)
	if ( file_exists(config_file_2mm_main) )		// Main 2mm file
	{
		delete_file(config_file_2mm_main)
	}
		
	if ( file_exists(config_file_2mm_restart) )		// Restart 2mm file
	{
		delete_file(config_file_2mm_restart)
	}
		
	if ( file_exists(config_file_2mm_cvar) )		// Cvar 2mm file
	{
		delete_file(config_file_2mm_cvar)
	}
	
	// Unit variables
	uninit_variables()
	
	// Reset hostname and pass
	uninit_resetserver()
	
	
	// (Re|Un)restrict Shield
	if ( get_cvar_num("amx_match_shield2") == 0) 
	{
		server_cmd("amx_restrict off shield")
		client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "SHIELD_UNRESTRICTED")
	}
	else
	{
		server_cmd("amx_restrict on shield")
		client_print(0,print_chat,"* [AMX MATCH] %L", LANG_PLAYER, "SHIELD_RESTRICTED")
	}
	
	// Execute FFA
	client_print(0,print_chat,"* [AMX MATCH] %L (%s)", LANG_PLAYER, "EXECUTING_FFA_CONF", AMXMD_CONFIG_FFA)
	
	server_cmd("exec ^"%s/%s^"", config_dir_leagues, AMXMD_CONFIG_FFA)
	
	// If we *are* playing pug games change to next map, otherwise just restart the round
	
	if( get_cvar_num("amx_match_pugstyle") == 1 )
	{
		/*
		
		if( file_exists(config_file_pug) )
		{
			// New code for next release
			
				new map2
				new map2_length
			
				// Read maps from config file
				for(new i = 7; i < filesize( config_file_pug ) ; i++ )
				{
					get_mapname (map2, map2_length)
					
					read_file(config_file_pug,7,map,32,map_length)
					
					if( equal( map, map2 ) )
					{
						
					}
				}
			
			
			// Read map from config file
			read_file(config_file_pug,7,map,32,map_length)
			
			if( is_map_valid(map) )
			{
				set_task(4.0, "misc_changelevel", 0, map, map_length)
			}
			else
			{
				server_print("%L: $s", LANG_SERVER, "MAP_NOT_FOUND", map)
			}
		}		
		else
		{
			server_print("* [AMX MATCH] %L", LANG_SERVER, "PUG_FILE_DNE")
		}
		
		*/
		
		get_cvar_string("amx_nextmap", map, 31)
		
		set_task(4.0, "misc_changelevel", 0, map, map_length)

	}
	else
	{
		misc_restart_round("2")
	}
	
	return PLUGIN_CONTINUE	
}


public uninit_variables()
{
	main_inprogress = 0
	main_inovertime = 0
	
	main_ready_userids[0] = 0
	main_ready_teams = 0
	
	main_clanCT[0] = 0
	main_clanT[0] = 0
	
	config_file_match[0] = 0
	
	main_command_matchtype = 0
	main_command_matchlength = 0
	main_command_demotype = 0
	
	main_score_ct[0] = 0
	main_score_ct[1] = 0
	main_score_t[0] = 0
	main_score_t[1] = 0	
	main_score_overtime = 0
	
	main_in2mapmatch = 0
	
	is_restarted = 0
	is_started = 0
	is_stopped = 0

	main_inkniferound = 0
	main_kniferound_won = 0
	main_kniferound_done = 0


	return PLUGIN_CONTINUE
}


public uninit_resetserver()
{
	// (Re)set Hostname
	if(get_cvar_num("amx_match_hostname") == 1)
	{
		set_cvar_string("hostname", main_servername_old)
	}
	
	
	// (Re)set Password
	if(get_cvar_num("amx_match_password") == 1)
	{
		set_cvar_string("sv_password", main_serverpass_old)
	}
	
	return PLUGIN_CONTINUE
}


/* 
*
*	Warmup functions
*
*/

public warmup_print_message()
{
	// Declare variables
	new message_demos[128]		// Contains the demo message
	new message_time[128]		// Contains the time message
	new message_screenshots[128]	// Contains the screenshots message
	new message_swapteams[128]	// Contains the swap type message
	
	if ((main_inprogress == 1) || (main_inprogress == 3))  // If we are in a warmup period
	{	
		// Init variables		
		format(message_time,127, "%L", LANG_PLAYER, "WARMUP_TIME")
		format(message_screenshots,127, "%L", LANG_PLAYER, "WARMUP_SCREENSHOTS")
		format(message_swapteams,127, "^n%L", LANG_PLAYER, "WARMUP_SWAPTEAMS")

		if ((main_command_demotype == 1) || (main_command_demotype == 3)) // If we are recording player demos 
		{
			format (message_demos, 127, "--[ %s ]--^n%L", message_time, LANG_PLAYER, "WARMUP_DEMOS1")
		}
		else
		{
			format (message_demos, 127, "--[ %s ]--^n%L", message_time, LANG_PLAYER, "WARMUP_DEMOS2")
		}

		// Set and show hud message for demos
		set_hudmessage(255, 255, 255, -1.0, 0.01, 0, 2.0, 10.0, 0.8, 0.8, -1)
		show_hudmessage(0, message_demos)

		// Set and show hud message for screenshots and swap type
		set_hudmessage(255, 255, 255, -1.0, 0.08, 0, 2.0, 10.0, 0.8, 0.8, -1)
		show_hudmessage(0, "%s %s", (get_cvar_num("amx_match_screenshot") > 0) ? message_screenshots : "", (get_cvar_num("amx_match_swaptype") == 1) ? message_swapteams : "") 

		// Print clans for match in the chat area
		if (main_command_type == 1 || main_command_type == 3) // If the match command is amx_match or amx_match3
		{
			client_print(0, print_chat, "* [AMX MATCH] %s(CT) vs %s(T)", (main_inprogress == 1) ? main_clanCT : main_clanT, (main_inprogress == 1) ? main_clanT : main_clanCT)
		}
		
		
		// Print warmup in chat area
		client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "WARMUP_TIME")
		
		if (get_cvar_num("amx_match_readytype") == 0) // If every player has to say '/ready' for the match to begin
		{
			if (main_ready_teams == 0) // If both teams aren't ready
			{
				client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "BOTH_TEAMS_ARENT_READY")
			}
			else if (main_ready_teams == 2) // If the CT team is ready
			{
				if (main_command_type == 1 || main_command_type == 3) // If the match command is amx_match or amx_match3
				{
					client_print(0, print_chat, "* [AMX MATCH] %s %L %s %L", (main_inprogress == 1) ? main_clanCT : main_clanT, LANG_PLAYER, "ARE_READY_WAITING_FOR", (main_inprogress == 1) ? main_clanT : main_clanCT, LANG_PLAYER, "TO_BE_READY")
				}
				else // If the match command is amx_match2 or amx_match4
				{
					client_print(0, print_chat, "* [AMX MATCH] CT %L T %L", LANG_PLAYER, "ARE_READY_WAITING_FOR", LANG_PLAYER, "TO_BE_READY")
				}
			}
			else if (main_ready_teams == 1) // If the T team is ready
			{
				if (main_command_type == 1 || main_command_type == 3) // If the match command is amx_match or amx_match3
				{
					client_print(0, print_chat, "* [AMX MATCH] %s %L %s %L", (main_inprogress == 1) ? main_clanT : main_clanCT, LANG_PLAYER, "ARE_READY_WAITING_FOR", (main_inprogress == 1) ? main_clanCT : main_clanT, LANG_PLAYER, "TO_BE_READY")
				}
				else // If the match command is amx_match2 or amx_match4
				{
					client_print(0, print_chat, "* [AMX MATCH] T %L CT %L", LANG_PLAYER, "ARE_READY_WAITING_FOR", LANG_PLAYER, "TO_BE_READY")
				}
			}
			
			client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "WHEN_TEAM_READY_SAY_READY")
			client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "IF_TEAM_NOTREADY_SAY_NOTREADY")
		}
		else if (get_cvar_num("amx_match_readytype") == 1) // If one player from each team has to say '/ready' for the match to begin
		{
			client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "WHEN_READY_SAY_READY")
			client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "IF_NOTREADY_SAY_NOTREADY")
			client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "MATCH_STARTS_WHEN_ALL_READY")
		}
		else // If only an admin can start a match
		{
			client_print(0, print_chat, "* [AMX MATCH] %L", LANG_PLAYER, "ADMIN_STARTS_MATCH")
		}
	}
	
	return PLUGIN_CONTINUE
}

public warmup_print_message_shouldbe()
{
	new hud_message[256]
	
	// Format and show correct teams message
	format(hud_message,255,"--[ %s %L CT ]--^n --[ %s %L T ]--", main_clanCT, LANG_PLAYER, "SHOULD_BE", main_clanT, LANG_PLAYER, "SHOULD_BE")
		
	// Set and show hud message
	set_hudmessage(0, 255, 255, -1.0, 0.30, 0, 2.0, 6.0, 0.8, 0.8, -1)
	show_hudmessage(0, hud_message)

	// Show in chat, as well, for no confusion
	client_print(0,print_chat,"* [AMX MATCH] %s %L CT", main_clanCT, LANG_PLAYER, "SHOULD_BE")	
	client_print(0,print_chat,"* [AMX MATCH] %s %L T", main_clanT, LANG_PLAYER, "SHOULD_BE")
	
	return PLUGIN_CONTINUE
}

public warmup_start()
{		
	// Reset 'is_started' so we can force the start in this warmup
	is_started = 0
	
	// Start showing the score if we are always showing
	if( get_cvar_num("amx_match_showscore") == 2)
	{
		set_task(5.0, "score_show", TASKID_SHOW_SCORE, "", 0, "b")
	}
	
	
	// Are there warmup configs?
	if(get_cvar_num("amx_match_warmupcfg") == 1)
	{
		// Exec the warmup config
		server_cmd("exec ^"%s/%s^"", config_dir_leagues, AMXMD_CONFIG_WARMUP)
	}
	else
	{
		misc_exec_configs()
	}
	
	
	warmup_readylist_reset()
	
	// Show the warmup message, then show again every thirty (30) seconds after that until stopped
	set_task(4.0, "warmup_print_message", TASKID_WARMUP_MESSAGE)
	set_task(30.0, "warmup_print_message", TASKID_WARMUP_MESSAGE, "", 0, "b")
	
	
	
	
	// Print the ready list
	if (get_cvar_num("amx_match_readytype") == 1)
	{
		// Show the ready list, then again every six (6) seconds after that until stopped
		set_task(1.0, "warmup_print_readylist")
		set_task(6.0, "warmup_print_readylist", TASKID_WARMUP_READYLIST, "", 0, "b")
	}
	
	return PLUGIN_CONTINUE
}

public warmup_print_readylist()
{
	if ((main_inprogress == 1) || (main_inprogress == 3)) 
	{
		new hudmessage[550]
		
		// Format the ready list hud message
		format(hudmessage, 549, "CT %L: %s^nT %L: %s", LANG_PLAYER, "READY", main_ready_CT, LANG_PLAYER, "READY", main_ready_T)
		
		// Set and show the ready list hud message
		set_hudmessage(0, 255, 0, 0.01, 0.17, 0, 0.5, 5.0, 0.8, 0.8, -1)
		show_hudmessage(0, hudmessage)
	}
	
	return PLUGIN_CONTINUE
}


public warmup_readylist_add(player_id)
{
	// Declare variables
	new readylist_length = strlen(main_ready_userids)
	
	new player_name[32]
	
	new i = 0
	
	new temp[32]
	new temp2[32]
	
	new CsTeams:team
	
	
	// Search the ready list to make the player isn't ready
	for(i = 0; (i < readylist_length) && (!(main_ready_userids[i] == player_id)); i++)  {  }
	
	if (i == readylist_length)
	{
		// Add playerid to ready lsit
		main_ready_userids[readylist_length] = player_id
		
		// Init next
		main_ready_userids[readylist_length+1] = 0
		
		// Get user's name
		get_user_name(player_id, player_name, 31)
		
		// Get user's team
		team = cs_get_user_team(player_id)
		
		
		// Init "NONE" string
		format(temp2, 31, "%L.", LANG_PLAYER, "NONE")
		
		
		if ( team == CS_TEAM_CT ) 
		{
			if (equal(main_ready_CT, temp2)) // If nobody is ready yet on the CTs
			{
				format(main_ready_CT, 255, "%s", player_name)
			}
			else // If there are people already ready on the CTs
			{
				format(temp, 39, ", %s", player_name)
				add(main_ready_CT, 255, temp)
			}
		}
		else if ( team == CS_TEAM_T )
		{
			if (equal(main_ready_T, temp2))  // If nobody is ready yet on the Ts
			{
				format(main_ready_T, 255, "%s", player_name)
			}
			else // If there are people already readyon the Ts
			{
				format(temp, 39, ", %s", player_name)
				add(main_ready_T, 255, temp)
			}
		}
		
		// We added the person successfully
		return true
	}
	else
	{
		// We did not add the person successfully, most likely person was already ready?
		return false
	}
	
	// Execution will never reach here, just so the compiler won't complain
	return false
}

public warmup_readylist_remove(player_id)
{
	// Declare variables
	new readylist_length = strlen(main_ready_userids)
	new i = 0

	new temp[32]
	new temp2[32]

	new player_name[32]
	
	new CsTeams:team
	
	
	// Make sure that the player is in fact in the ready_list
	for(i = 0; (i < readylist_length) && (!(main_ready_userids[i] == player_id)); i++)  {  }
	
	if (i != readylist_length) // If player is not in the ready list
	{
		// Delete player_id from readylist and reformat readylist array
		while(i < (readylist_length - 1))
		{
			main_ready_userids[i] = main_ready_userids[i+1]
			i++
		}
		
		main_ready_userids[i] = 0
		
		// Get user's name
		get_user_name(player_id, player_name, 31)
		
		// Get user's team
		team = cs_get_user_team(player_id)
		
		
		// Init "NONE" string
		format(temp2, 31, "%L.", LANG_PLAYER, "NONE")
		
		
		if ( team == CS_TEAM_CT ) 
		{
			// Not the first name on the list
			format(temp, 31, ", %s", player_name)
			replace(main_ready_CT, 255, temp, "")
			
			// First name with more players after
			format(temp, 31, "%s, ", player_name)
			replace(main_ready_CT, 255, temp, "")
			
			// Only person on the list
			format(temp, 31, "%s", player_name)
			replace(main_ready_CT, 255, temp, temp2)
		}
		else if ( team == CS_TEAM_T )
		{
			// Not the first name on the list
			format(temp, 31, ", %s", player_name)
			replace(main_ready_T, 255, temp, "")
			
			// First name with more players after
			format(temp, 31, "%s, ", player_name)
			replace(main_ready_T, 255, temp, "")
			
			// Only person on the list
			format(temp, 31, "%s", player_name)
			replace(main_ready_T, 255, temp, temp2)
		}
		
		// We did removed the person successfully
		return true
	}
	else
	{
		// We did not remove the person successfully, most likely person was not already ready?
		return false
	}
	
	// Execution will never reach here, just so the compiler won't complain
	return false
}


public warmup_readylist_reset()
{
	// Declare variables
	new readylist_length = strlen(main_ready_userids)
	
	for(new i = 0; i < readylist_length; i++)
	{
		main_ready_userids[i] = 0
	}
	
	// Set the ready list strings
	format(main_ready_CT,31,"%L.", LANG_SERVER, "NONE")
	format(main_ready_T,31,"%L.", LANG_SERVER, "NONE")
	
	
	return PLUGIN_CONTINUE
}


public warmup_readylist_checkready(id)
{
	// Declare variables
	new player_name[32]
	new CsTeams:team
	new players_need = get_cvar_num("amx_match_playerneed")
			

	if (get_cvar_num("amx_match_readytype") == 2) // If only an admin can start a match
	{
		return PLUGIN_CONTINUE
	}

	// Get the user's team
	team = cs_get_user_team(id)
	
	if ((main_inprogress == 1) || (main_inprogress == 3)) // If we are in a warmup period
	{
		if (get_cvar_num("amx_match_readytype") == 0) // If only one ready needed
		{
			if ( team == CS_TEAM_CT && (main_ready_teams == 1)) // If T was already ready and player's team is CT
			{
				// Start the match
				warmup_readylist_ready(0)
			}
			else if ( team == CS_TEAM_T && (main_ready_teams == 2))  // If CT was already ready and player's team is T
			{
				// Start the match
				warmup_readylist_ready(0)
			}
			else if ( team == CS_TEAM_CT && (main_ready_teams == 0)) // CT team is now ready
			{
				// Make the CT team ready
				warmup_readylist_ready(2)
			}
			else if ( team == CS_TEAM_T && (main_ready_teams == 0)) // T team is now ready
			{
				// Make the T team ready
				warmup_readylist_ready(1)
			}
			else // Team was already ready
			{
				client_print(id,print_chat,"* [AMX MATCH] %L", id,"TEAM_ALREADY_READY")
			}
		}
		else if ( team != CS_TEAM_SPECTATOR ) // If every player must say ready, and player isn't in SPEC
		{
			if (warmup_readylist_add(id)) // Added user to the ready list and user wasn't ready
			{
				// Get the user's name
				get_user_name(id, player_name, 31)
				
				// Set and show the "is ready" message
				set_hudmessage(0, 255, 255, -1.0, 0.35, 1, 2.0, 6.0, 0.8, 0.8, -1)
				show_hudmessage(0, "%s %L", player_name, LANG_PLAYER, "IS_NOW_READY")
				
				// Print to the client that they are ready
				client_print(id, print_chat, "* [AMX MATCH] %L", id, "YOU_ARE_READY")
				
				if (players_need == strlen(main_ready_userids)) // If all players are ready
				{	
					// Start the match
					warmup_readylist_ready(0)
				}
			}
			else // User was already ready
			{
				client_print(id,print_chat,"* [AMX MATCH] %L", id,"YOU_WERE_READY")
			}
		}
	}
	else if ((main_inprogress == 2) || (main_inprogress == 4))
	{
		if ( team != CS_TEAM_SPECTATOR )
		{
			client_print(id, print_chat, "* [AMX MATCH] %L", id, "MATCH_ALREADY_STARTED")
		}
	}
	
	return PLUGIN_CONTINUE
}

public warmup_readylist_ready( ready )
{
	if( ready == 0 ) // Both teams or all players are now ready
	{
		// Set and show "Both teams are ready" message
		set_hudmessage(255, 0, 0, -1.0, 0.32, 0, 2.0, 6.0, 0.8, 0.8, -1)
		show_hudmessage(0, "--[ %L !!! ]--", LANG_PLAYER, "BOTH_TEAMS_READY")
		
		// Set "match can now begin" message
		set_hudmessage(255, 0, 0, -1.0, 0.35, 0, 2.0, 6.0, 0.8, 0.8, -1)

		
		// If there is a knife round before the first warmup session and we haven't played one already
		if( (get_cvar_num("amx_match_kniferound") == 1) && (main_kniferound_done == 0) )
		{
			misc_restart_round("2")
			
			// Now in knife round
			main_inprogress = 5
			
			set_task(4.0, "kniferound_start")
		}
		else
		{
			if (main_command_type == 1 || main_command_type == 3) // If command was amx_match or amx_match3
			{
				show_hudmessage(0, "%s vs %s %L", main_clanCT, main_clanT, LANG_PLAYER, "VSMATCH_CAN_BEGIN")
			}
			else // If command was amx_match2 or amx_match4
			{
				show_hudmessage(0, "%L", LANG_PLAYER, "MATCH_CAN_BEGIN")
			}
			
			// Start the half
			half_start()
		}		
	}
	else // CT or T team is now ready
	{
		// Make the team ready (2 = CT, 1 = T)
		main_ready_teams = ready
		
		// Set and show the "ready" message
		set_hudmessage(0, 255, 255, -1.0, 0.35, 1, 2.0, 6.0, 0.8, 0.8, -1)
		
		if ( ready == 2 ) // If we are making the CT team ready
		{
			if (main_command_type == 1 || main_command_type == 3) // If command was amx_match or amx_match3
			{
				show_hudmessage(0, "--[ %s %L ]--^n%L", (main_inprogress == 1) ? main_clanCT : main_clanT, LANG_PLAYER, "ARE_NOW_READY", LANG_PLAYER, "WAITING_F0R_TO_BE_READY", (main_inprogress == 1) ? main_clanT : main_clanCT)
			}
			else // If command was amx_match2 or amx_match4
			{
				show_hudmessage(0,"--[ CT %L ]--^n%L", LANG_PLAYER,"ARE_NOW_READY",LANG_PLAYER,"WAITING_FOR_T_TOBE_READY")
			}
		}
		else // If we are making the T team ready
		{
			if (main_command_type == 1 || main_command_type == 3) // If command was amx_match or amx_match3
			{
				show_hudmessage(0,"--[ %s %L ]--^n%L",(main_inprogress == 1) ? main_clanT : main_clanCT, LANG_PLAYER,"ARE_NOW_READY", LANG_PLAYER,"WAITING_F0R_TO_BE_READY" ,(main_inprogress == 1) ? main_clanCT : main_clanT)
			}
			else // If command was amx_match2 or amx_match4
			{
				show_hudmessage(0,"--[ T %L ]--^n%L", LANG_PLAYER,"ARE_NOW_READY",LANG_PLAYER,"WAITING_FOR_CT_TOBE_READY")
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

public warmup_readylist_checknotready(id)
{
	// Declare variables
	new player_name[32]
	new CsTeams:team


	if (get_cvar_num("amx_match_readytype") == 2) // If only an admin can start a match
	{
		return PLUGIN_CONTINUE
	}

	// Get the user's team
	team = cs_get_user_team( id )
	
	if ((main_inprogress == 1) || (main_inprogress == 3)) // If we are in a warmup period
	{
		if (get_cvar_num("amx_match_readytype") == 0) // only one ready needed
		{
			if ( team == CS_TEAM_CT && (main_ready_teams == 2)) // If the CT team was ready and user's team is CT
			{
				warmup_readylist_notready(2)
			}
			else if ( team == CS_TEAM_T && (main_ready_teams == 1)) // If the T team was ready and user's team is T
			{
				warmup_readylist_notready(1)
			}
			else // If the the client's team wasn't ready
			{
				client_print(id, print_chat, "* [AMX MATCH] %L", id, "TEAM_WASNT_READY")
			}
		}
		else if ( team != CS_TEAM_SPECTATOR ) // If every player must say ready, and player isn't in SPEC
		{
			if (warmup_readylist_remove(id)) // user was ready
			{
				// Get the player's name
				get_user_name(id, player_name, 31)
	
				// Set and show the "not ready" message
				set_hudmessage(0, 255, 255, -1.0, 0.35, 1, 2.0, 6.0, 0.8, 0.8, -1)
				show_hudmessage(0, "%s %L", player_name, LANG_PLAYER, "ISNT_READY")
				
				// Print to the client that they are ready
				client_print(id, print_chat, "* [AMX MATCH] %L", id, "YOU_ARE_NOTREADY")
			}
			else // If the user wasn't ready
			{
				client_print(id, print_chat, "* [AMX MATCH] %L", id,"YOU_WERE_N0TREADY")
			}
		}
	}
	else if ((main_inprogress == 2) || (main_inprogress == 4))
	{
		if ( team != CS_TEAM_SPECTATOR )
		{
			client_print(id, print_chat, "* [AMX MATCH] %L", id, "MATCH_ALREADY_STARTED")
		}
	}
	
	return PLUGIN_CONTINUE

}

public warmup_readylist_notready(notready)
{
	// Set the hud message
	set_hudmessage(0, 255, 255, -1.0, 0.35, 1, 2.0, 6.0, 0.8, 0.8, -1)

	main_ready_teams = 0

	if( notready == 2 ) // If CT was ready
	{	
		if (main_command_type == 1 || main_command_type == 3) // If command was amx_match or amx_match3
		{
			show_hudmessage(0,"--[ %s %L ]--^n%L",(main_inprogress == 1) ? main_clanCT : main_clanT, LANG_PLAYER,"ARENT_READY", LANG_PLAYER,"WAITING_FOR_BOTH_TEAMS_TOBE_READY")
		}
		else // If command was amx_match2 or amx_match4
		{
			show_hudmessage(0,"--[ CT %L ]--^n%L",LANG_PLAYER,"ARENT_READY", LANG_PLAYER,"WAITING_FOR_BOTH_TEAMS_TOBE_READY")
		}
	}
	else // If T was ready
	{
		if (main_command_type == 1 || main_command_type == 3) // If command was amx_match or amx_match3
		{
			show_hudmessage(0,"--[ %s %L ]--^n%L",(main_inprogress == 1) ? main_clanT : main_clanCT, LANG_PLAYER,"ARENT_READY", LANG_PLAYER,"WAITING_FOR_BOTH_TEAMS_TOBE_READY")
		}
		else // If command was amx_match2 or amx_match4
		{
			show_hudmessage(0,"--[ T %L ]--^n%L", LANG_PLAYER,"ARENT_READY", LANG_PLAYER,"WAITING_FOR_BOTH_TEAMS_TOBE_READY")
		}
	}
	
	return PLUGIN_CONTINUE
}


/*
*
*	Plugin
*
*/


public plugin_init()
{
	new customdir[64]
	new datadir[64]
	
	new temp[256]

	// Register plugin
	///////////////////////////////
	
	register_plugin(AMXMD_NAME, AMXMD_VERSION, AMXMD_AUTHOR)
	register_cvar(AMXMD_CVAR, AMXMD_VERSION, FCVAR_SERVER)

	
	// Language files
	///////////////////////////////
	
	register_dictionary(AMXMD_DICT_MAIN)
	register_dictionary(AMXMD_DICT_COMMON)


	// Commands
	///////////////////////////////

	// Console commands
	#if defined(AMXMD_USE_HLTV)
	register_concmd("amx_match","match_start",AMXMD_ACCESS,"<CT's clan tag> <T's clan tag> <mrXX or tlXX> <Config filename> [recdemo|rechltv|recboth]")
	register_concmd("amx_match2","match_start",AMXMD_ACCESS,"<mrXX or tlXX> <Config filename> [recdemo|rechltv|recboth]")
	register_concmd("amx_match3","match_start",AMXMD_ACCESS,"<CT's clan tag> <T's clan tag> <mrXX or tlXX> <Config filename> <Second map> [recdemo|rechltv|recboth]")
	register_concmd("amx_match4","match_start",AMXMD_ACCESS,"<mrXX or tlXX> <Config filename> <Second map> [recdemo|rechltv|recboth]")
	#else
	register_concmd("amx_match","match_start",AMXMD_ACCESS,"<CT's clan tag> <T's clan tag> <mrXX or tlXX> <Config filename> [recdemo]")
	register_concmd("amx_match2","match_start",AMXMD_ACCESS,"<mrXX or tlXX> <Config filename> [recdemo]")
	register_concmd("amx_match3","match_start",AMXMD_ACCESS,"<CT's clan tag> <T's clan tag> <mrXX or tlXX> <Config filename> <Second map> [recdemo]")
	register_concmd("amx_match4","match_start",AMXMD_ACCESS,"<mrXX or tlXX> <Config filename> <Second map> [recdemo]")
	#endif
	
	// Start...Stop...Restart
	register_concmd("amx_matchrestart","match_restart",AMXMD_ACCESS," - Restart a match")
	register_concmd("amx_matchrelo3","half_restart",AMXMD_ACCESS," - Restart the current half")
	register_concmd("amx_matchstart","half_start_force",AMXMD_ACCESS," - Force a match to start")
	register_concmd("amx_matchstop","match_stop",AMXMD_ACCESS," - Stop a match")
	
	// Swap teams
	register_concmd("amx_swapteams","swap_teams_console",AMXMD_ACCESS," - Swap teams")
	
	// Randomize teams
	register_concmd("amx_randomizeteams","randomize_teams",AMXMD_ACCESS," - Randomize teams")	
	
	// Save current cvar config
	register_concmd("amx_matchsave","save_settings_console",AMXMD_ACCESS," - Save your current match cvar config")
	
	// PUG style gameplay
	register_concmd("amx_matchpug","match_pug",AMXMD_ACCESS,"<on|1|off|0>")

#if defined(AMXMD_USE_HLTV)
	register_concmd("amx_match_testhltv","hltv_test",AMXMD_ACCESS," - Test HLTV")
#endif
	
	// Client commands
	register_clcmd("say /ready","warmup_readylist_checkready")
	register_clcmd("say /notready","warmup_readylist_checknotready")
	register_clcmd("say ready","warmup_readylist_checkready")
	register_clcmd("say notready","warmup_readylist_checknotready")

/*
	register_clcmd("say /ct","kniferound_pickteam")
	register_clcmd("say /t","kniferound_pickteam")
*/

	register_clcmd("say /restart","match_restart", AMXMD_ACCESS, "match_restart")
	register_clcmd("say /relo3","half_restart", AMXMD_ACCESS, "half_restart")
	register_clcmd("say /start","half_start_force", AMXMD_ACCESS, "half_start_force")
	register_clcmd("say /stop","match_stop", AMXMD_ACCESS, "match_stop")
	
	// Menu
	register_concmd("amx_matchmenu", "menu_console", AMXMD_ACCESS, " - AMX Match Menu")
	
	// Server commands
	register_concmd("amx_match_addlength", "menu_add_length", AMXMD_ACCESS, "<match length> [<match length> ...]")
	register_concmd("amx_match_addconfig", "menu_add_config", AMXMD_ACCESS, "<config name> <config file>")

	register_srvcmd("amx_match_lmenu", "menu_add_length")
	register_srvcmd("amx_match_cmenu", "menu_add_config")
	
	
		
	// Events
	///////////////////////////////
	
	register_event("TeamScore", "score_new", "a")
	register_event("ResetHUD", "score_show", "b")

	register_event("CurWeapon", "kniferound_onchangeweapon", "b" )
	register_event("SendAudio","kniferound_teamwin","a","2=%!MRAD_terwin","2=%!MRAD_ctwin")

	
	
	// Cvars
	///////////////////////////////
	for (new i = 0; i < NUM_CVARS; i++)
	{
		register_cvar(cvar_names[i], cvar_properties[i])
	}
	
	
	// Configs
	///////////////////////////////
	
	// Init Custom Directory string
	get_configsdir(customdir, 63)

	// Init 'amxmd' directory
	format(config_dir_main,63,"%s/%s", customdir, AMXMD_DIR_MAIN)

	// Init 'leagues' directory
	format(config_dir_leagues,63,"%s/%s", config_dir_main, AMXMD_DIR_CONFIGS)

#if defined(AMXMD_USE_HLTV)

	// Init HLTV file string
	format(config_file_hltv,63,"%s/%s", config_dir_main, AMXMD_CONFIG_HLTV)
	
	// Set the hltv password
	hltv_set_password()

#endif
	
	// For PUG (Pick-up Game) style gameplay
	format(config_file_pug,63,"%s/%s", config_dir_main, AMXMD_CONFIG_PUG)	

	// For two map matches
	// Main file string
	format(config_file_2mm_main, 63, "%s/%s", config_dir_main, AMXMD_2MM_MAIN)
	
	// Cvar file string
	format(config_file_2mm_cvar, 63, "%s/%s", config_dir_main, AMXMD_2MM_CVAR)
	
	// Restart file string
	format(config_file_2mm_restart, 63, "%s/%s", config_dir_main, AMXMD_2MM_RESTART)
	
	// Init variable and exec AMXMD.cfg
	format(config_file_plugin,63,"%s/%s", config_dir_main, AMXMD_CONFIG_PLUGIN)
	if (file_exists(config_file_plugin)) 
	{
		server_cmd("exec %s", config_file_plugin)
	}

	// Default Maps file
	format(config_file_defaultmaps, 63, "%s/%s", config_dir_main, AMXMD_CONFIG_DEFAULTMAPS)

	// Stats
	///////////////////////////////

#if defined(AMXMD_USE_SQL)
		
	set_task(0.1,"sql_init")
		
#endif
		
	// Init Custom Directory string
	get_datadir(datadir, 63)
	
	// Format the main directory
	format(stats_dir_main, 63, "%s/%s", datadir, AMXMD_DIR_STATS)
	
	// Main stats file string
	format(stats_file_main, 63, "%s/%s", stats_dir_main, AMXMD_STATS_MAIN)
	
	if( !(dir_exists ( stats_dir_main )) ) // Make sure the stats directory is there...
	{
		mkdir ( stats_dir_main )
	}

	// Menus
	///////////////////////////////

	// Playout vote
	format(temp, 256, "[AMX Match] %L", LANG_SERVER, "OVERTIME_QUESTION")
	register_menucmd(register_menuid(temp) ,(1<<0)|(1<<1),"score_vote_count") 

	// Kniferound Team vote
	format(temp, 256, "[AMX Match] %L", LANG_SERVER, "KNIFEROUND_QUESTION")
	register_menucmd(register_menuid(temp) ,(1<<0)|(1<<1),"kniferound_vote_count")

	// Add menu item to main menu
	AddMenuItem("AMX Match Deluxe", "amx_matchmenu", AMXMD_ACCESS, "AMX Match Deluxe")

	// MENU
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_MENU")
	register_menucmd(register_menuid(temp),1023,"menu_action_main")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_CLANTAGS")
	register_menucmd(register_menuid(temp),1023,"menu_action_tags")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_CLANTAGS_CT")
	register_menucmd(register_menuid(temp),1023,"menu_action_tags_CT")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_CLANTAGS_T")
	register_menucmd(register_menuid(temp),1023,"menu_action_tags_T")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_SETTINGS")
	register_menucmd(register_menuid(temp),1023,"menu_action_settings")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_MATCH_TYPE")
	register_menucmd(register_menuid(temp),1023,"menu_action_type")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_MATCH_LENGTH")
	register_menucmd(register_menuid(temp),1023,"menu_action_length")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_CONFIG_FILE")
	register_menucmd(register_menuid(temp),1023,"menu_action_config")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_SECONDMAP")
	register_menucmd(register_menuid(temp),1023,"menu_action_secondmap")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_SECONDMAP_LIST")
	register_menucmd(register_menuid(temp),1023,"menu_action_secondmaplist")
	
	format(temp, 256, "AMX Match %L:", LANG_SERVER, "MENU_RECORD_DEMO")
	register_menucmd(register_menuid(temp),1023,"menu_action_demo")
	
	format(temp, 256, "%L", LANG_SERVER, "MENU_START_MATCH")
	register_menucmd(register_menuid(temp),1023,"menu_action_confirmation")
	
	format(temp, 256, "%L:", LANG_SERVER, "MENU_PUG_STYLE")
	register_menucmd(register_menuid(temp),1023,"menu_action_pugstyle")

	
	// Get list of maps for Second Map List Menu
	menu_get_servermaps()
	
	
	// For two map matches and pug game play	
	///////////////////////////////	

	set_task(10.0, "match_start_init")

	return PLUGIN_CONTINUE
}

public plugin_end()
{
	if( get_cvar_num("amx_match_pugstyle") == 1)
	{
		server_cmd("amx_matchstop")
	}
	
#if defined(AMXMD_USE_SQL)	
	
	SQL_FreeHandle(SqlTuple)
	
#endif

}