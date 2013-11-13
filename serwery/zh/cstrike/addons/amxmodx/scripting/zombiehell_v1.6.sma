///////////////////////////////////////////////////////////
// ZombieHell 1.6 - www.zombiehell.co.cc                //
/////////////////////////////////////////////////////////
// Developer: Hector Carvalho (hectorz0r)             //
///////////////////////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

///////////////////////////////////////////////////////////////////
// Cvars                                                        //
/////////////////////////////////////////////////////////////////

new zombie_knife, zombie_maxslots, zombie_effect, zombie_level, zombie_respawns, zombie_bot, zombie_scores, survivor_classes,
level1_name, level1_respawns, level1_health, level1_maxspeed, level1_bosshp, level1_bossmaxspeed, level2_name, level2_respawns, 
level2_health, level2_maxspeed, level2_bosshp, level2_bossmaxspeed, level3_name, level3_respawns, level3_health, level3_maxspeed, 
level3_bosshp, level3_bossmaxspeed, level4_name, level4_respawns, level4_health, level4_maxspeed, level4_bosshp, level4_bossmaxspeed,
level5_name, level5_respawns, level5_health, level5_maxspeed, level5_bosshp, level5_bossmaxspeed, level6_name, level6_respawns, 
level6_health, level6_maxspeed, level6_bosshp, level6_bossmaxspeed, level7_name, level7_respawns, level7_health, level7_maxspeed, 
level7_bosshp, level7_bossmaxspeed, level8_name, level8_respawns, level8_health, level8_maxspeed, level8_bosshp, level8_bossmaxspeed,
level9_name, level9_respawns, level9_health, level9_maxspeed, level9_bosshp, level9_bossmaxspeed, level10_name, level10_respawns, 
level10_health, level10_maxspeed, level10_bosshp, level10_bossmaxspeed;

///////////////////////////////////////////////////////////////////
// Models                                                       //
/////////////////////////////////////////////////////////////////

new const ZOMBIE_MODEL1[] = "zh_corpse" 
new const ZOMBIE_MODEL2[] = "zh_crispy2"
new const ZOMBIE_MODEL3[] = "zh_classic" 

///////////////////////////////////////////////////////////////////
// Variables                                                    //
/////////////////////////////////////////////////////////////////

new level1_desc[64], level2_desc[64], level3_desc[64], level4_desc[64], level5_desc[64], 
level6_desc[64], level7_desc[64], level8_desc[64], level9_desc[64], level10_desc[64], 
g_has_custom_model[33], g_player_model[33][32], g_zombie[33], g_user_kill[33], g_respawn_count[33], 
g_burning[33], g_player_class[33], g_zombie_class[33], g_boss_class[33], g_maxplayers, g_damage, g_fire, g_boss_sprite;

new Float:g_last_origin[32+1][3]
new Float:g_models_target_time
new Float:g_roundstart_time
new Float:g_spawn_vec[60][3]
new Float:g_spawn_angle[60][3]
new Float:g_spawn_v_angle[60][3]

new bool:g_first_spawn[33]

new g_total_spawn = 0
new g_beacon_sound[] = "zombiehell/zh_beacon.wav"

///////////////////////////////////////////////////////////////////
// Downloads                                                    //
/////////////////////////////////////////////////////////////////

public plugin_precache() 
{	
	precache_sound("zombiehell/zh_beacon.wav")
	precache_sound("zombiehell/zh_brain.wav")
	precache_sound("zombiehell/zh_boss.wav")
	precache_sound("zombiehell/zh_intro.mp3")
	precache_generic("gfx/env/zombiehellbk.tga")
	precache_generic("gfx/env/zombiehelldn.tga")
	precache_generic("gfx/env/zombiehellft.tga")
	precache_generic("gfx/env/zombiehelllf.tga")
	precache_generic("gfx/env/zombiehellrt.tga")
	precache_generic("gfx/env/zombiehellup.tga")
	precache_model("models/player/zh_corpse/zh_corpse.mdl")
	precache_model("models/player/zh_crispy2/zh_crispy2.mdl")
	precache_model("models/player/zh_classic/zh_classic.mdl")
	g_fire = precache_model("sprites/zh_fire.spr")
	g_boss_sprite = precache_model("sprites/zh_beacon.spr")
	
	new fog = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))
	DispatchKeyValue(fog, "density", "0.001")
	DispatchKeyValue(fog, "rendercolor", "0 0 0")
}

///////////////////////////////////////////////////////////////////
// Plugin Start                                                 //
/////////////////////////////////////////////////////////////////

public plugin_init() 
{
	register_plugin("ZombieHell", "1.6", "hectorz0r")
	register_cvar("ZombieHell", "1.6", FCVAR_SERVER|FCVAR_SPONLY)
	
	register_clcmd("jointeam", "force_team")	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("ResetHUD", "event_set_power", "be")
	register_event("DeathMsg", "event_eat_brain", "a", "1>0")
	register_event("DeathMsg", "event_death_msg", "a")
	register_event("Damage", "event_damage", "be", "2!0", "3=0")
	register_event("CurWeapon", "event_check_speed", "be", "1=1")
	register_event("AmmoX", "event_free_ammo", "be", "1=1", "1=2", "1=3", "1=4", "1=5", "1=6", "1=7", "1=8", "1=9", "1=10")
	
	RegisterHam(Ham_Touch, "weaponbox", "ham_weapon_cleaner", 1)
	RegisterHam(Ham_TakeDamage, "player", "ham_zombie_knife")
	RegisterHam(Ham_Spawn, "player", "ham_player_spawn", 1)
	RegisterHam(Ham_Killed, "player", "ham_player_killed")
	
	register_forward(FM_GetGameDescription, "fm_game_description")
	register_forward(FM_SetClientKeyValue, "fm_client_key")
	register_forward(FM_ClientUserInfoChanged, "fm_client_info")
	register_forward(FM_SetModel, "fm_set_model")	
	register_forward(FM_Think, "fm_think")
	
	zombie_knife = register_cvar("zombie_knife", "0")
	zombie_maxslots = register_cvar("zombie_maxslots", "10")
	zombie_effect = register_cvar("zombie_effect", "1")
	zombie_level = register_cvar("zombie_level", "1")
	zombie_respawns = register_cvar("zombie_respawns", "1")
	zombie_bot = register_cvar("zombie_bot", "1")
	zombie_scores = register_cvar("zombie_scores", "1")
	survivor_classes = register_cvar("survivor_classes", "1")
	level1_name = register_cvar("level1_name", "")
	level1_respawns = register_cvar("level1_respawns", "")
	level1_health = register_cvar("level1_health", "")
	level1_maxspeed = register_cvar("level1_maxspeed", "")
	level1_bosshp = register_cvar("level1_bosshp", "")
	level1_bossmaxspeed = register_cvar("level1_bossmaxspeed", "")
	level2_name = register_cvar("level2_name", "")
	level2_respawns = register_cvar("level2_respawns", "")
	level2_health = register_cvar("level2_health", "")
	level2_maxspeed = register_cvar("level2_maxspeed", "")
	level2_bosshp = register_cvar("level2_bosshp", "")
	level2_bossmaxspeed = register_cvar("level2_bossmaxspeed", "")
	level3_name = register_cvar("level3_name", "")
	level3_respawns = register_cvar("level3_respawns", "")
	level3_health = register_cvar("level3_health", "")
	level3_maxspeed = register_cvar("level3_maxspeed", "")
	level3_bosshp = register_cvar("level3_bosshp", "")
	level3_bossmaxspeed = register_cvar("level3_bossmaxspeed", "")
	level4_name = register_cvar("level4_name", "")
	level4_respawns = register_cvar("level4_respawns", "")
	level4_health = register_cvar("level4_health", "")
	level4_maxspeed = register_cvar("level4_maxspeed", "")
	level4_bosshp = register_cvar("level4_bosshp", "")
	level4_bossmaxspeed = register_cvar("level4_bossmaxspeed", "")
	level5_name = register_cvar("level5_name", "")
	level5_respawns = register_cvar("level5_respawns", "")
	level5_health = register_cvar("level5_health", "")
	level5_maxspeed = register_cvar("level5_maxspeed", "")
	level5_bosshp = register_cvar("level5_bosshp", "")
	level5_bossmaxspeed = register_cvar("level5_bossmaxspeed", "")
	level6_name = register_cvar("level6_name", "")
	level6_respawns = register_cvar("level6_respawns", "")
	level6_health = register_cvar("level6_health", "")
	level6_maxspeed = register_cvar("level6_maxspeed", "")
	level6_bosshp = register_cvar("level6_bosshp", "")
	level6_bossmaxspeed = register_cvar("level6_bossmaxspeed", "")
	level7_name = register_cvar("level7_name", "")
	level7_respawns = register_cvar("level7_respawns", "")
	level7_health = register_cvar("level7_health", "")
	level7_maxspeed = register_cvar("level7_maxspeed", "")
	level7_bosshp = register_cvar("level7_bosshp", "")
	level7_bossmaxspeed = register_cvar("level7_bossmaxspeed", "")
	level8_name = register_cvar("level8_name", "")
	level8_respawns = register_cvar("level8_respawns", "")
	level8_health = register_cvar("level8_health", "")
	level8_maxspeed = register_cvar("level8_maxspeed", "")
	level8_bosshp = register_cvar("level8_bosshp", "")
	level8_bossmaxspeed = register_cvar("level8_bossmaxspeed", "")
	level9_name = register_cvar("level9_name", "")
	level9_respawns = register_cvar("level9_respawns", "")
	level9_health = register_cvar("level9_health", "")
	level9_maxspeed = register_cvar("level9_maxspeed", "")
	level9_bosshp = register_cvar("level9_bosshp", "")
	level9_bossmaxspeed = register_cvar("level9_bossmaxspeed", "")
	level10_name = register_cvar("level10_name", "")
	level10_respawns = register_cvar("level10_respawns", "")
	level10_health = register_cvar("level10_health", "")
	level10_maxspeed = register_cvar("level10_maxspeed", "")
	level10_bosshp = register_cvar("level10_bosshp", "")
	level10_bossmaxspeed = register_cvar("level10_bossmaxspeed", "")
	
	server_cmd("zombie_level 1")
	server_cmd("sv_skyname zombiehell")
	server_cmd("mp_roundtime 9.0")
	server_cmd("mp_limitteams 0")
	server_cmd("mp_autoteambalance 0")
	server_cmd("mp_flashlight 0")
	server_cmd("mp_startmoney 2800")
	server_cmd("mp_timelimit 0")
	server_cmd("mp_freezetime 0")
	server_cmd("sv_maxspeed 999")
	server_cmd("exec addons/amxmodx/configs/zombiehell.cfg")
	server_cmd("exec addons/amxmodx/configs/zombiehell_levels.cfg")
	
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
	
	g_maxplayers = get_maxplayers()
	csdm_respawn()
	g_damage = get_user_msgid("Damage")
}

///////////////////////////////////////////////////////////////////
// Mod Name                                                     //
/////////////////////////////////////////////////////////////////

public fm_game_description() 
{ 
	forward_return(FMV_STRING, "ZombieHell 1.6") 
	return FMRES_SUPERCEDE
}

///////////////////////////////////////////////////////////////////
// Zombie Extra Health                                          //
/////////////////////////////////////////////////////////////////

public event_eat_brain()
{
	new client = read_data(1)
	new client2 = read_data(2)
	new name[32]
	new name2[32]
	get_user_name(client, name, 31)
	get_user_name(client2, name2, 31)
	if(cs_get_user_team(client) == CS_TEAM_T && is_user_alive(client))
	{
		new brain_health = get_user_health(client) + 100
		set_user_health(client, brain_health)
		set_hudmessage(255, 255, 255, -1.0, 0.30, 0, 6.0, 6.0, 0.1, 0.2, 3)
		show_hudmessage(0, "%s IS EATING %s BRAIN!", name, name2)
		client_cmd(0, "spk zombiehell/zh_brain.wav")
	}
}

///////////////////////////////////////////////////////////////////
// Remove Weapon Entities                                       //
/////////////////////////////////////////////////////////////////

public ham_weapon_cleaner(iEntity)
{
	call_think(iEntity)
}

///////////////////////////////////////////////////////////////////
// Extra Knife Damage                                           //
/////////////////////////////////////////////////////////////////

public ham_zombie_knife(id, ent, idattacker, Float:damage, damagebits)
{
	if(ent == idattacker && is_user_alive(ent) && get_user_weapon(ent) == CSW_KNIFE && cs_get_user_team(id) == CS_TEAM_CT && get_pcvar_num(zombie_knife) == 1)
	{
		new Float:flHealth
		pev(id, pev_health, flHealth)
		SetHamParamFloat(4, flHealth * 5)
		return HAM_HANDLED
	}
	return HAM_IGNORED
}

///////////////////////////////////////////////////////////////////
// Round Start                                                  //
/////////////////////////////////////////////////////////////////

public event_round_start()
{
	for(new i = 1; i <= g_maxplayers; i++)
	{
		g_respawn_count[i] = 0
		remove_task(i)
	}
	set_task(0.1, "kill_hostages")
	set_task(2.0, "zombie_game_start")
	if(get_pcvar_num(zombie_bot))
	{
		switch(get_pcvar_num(zombie_level))
		{
			case 1:
			{ 
				set_lights("d")
			}
			case 2:
			{ 
				set_lights("d")
			}
			case 3:
			{ 
				set_lights("d")
			}
			case 4:
			{ 
				set_lights("c")
			}
			case 5:
			{ 
				set_lights("c")
			}
			case 6:
			{ 
				set_lights("c")
			}
			case 7:
			{ 
				set_lights("c")
			}
			case 8:
			{ 
				set_lights("b")
			}
			case 9:
			{ 
				set_lights("b")
			}
			case 10:
			{ 
				set_lights("a")
			}
		}
	}
	g_roundstart_time = get_gametime()
}

public zombie_game_start()
{
	client_cmd(0, "mp3 play sound/zombiehell/zh_intro.mp3")
	set_task(1.0, "zombie_bots")
	set_task(1.0, "zombie_slots")
	set_hudmessage(255, 255, 255, -1.0, 0.0, 0, 6.0, 999.0, 0.1, 0.2, -1)
	show_hudmessage(0, "ZombieHell 1.6 - www.zombiehell.co.cc")
	if(get_pcvar_num(zombie_level))
	{
		switch(get_pcvar_num(zombie_level))
		{
			case 1:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level1_name, level1_desc, sizeof level1_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level1_desc, get_pcvar_num(level1_bosshp), get_pcvar_num(level1_bossmaxspeed), get_pcvar_num(level1_health), get_pcvar_num(level1_maxspeed), get_pcvar_num(level1_respawns))
			}
			case 2:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level2_name, level2_desc, sizeof level2_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level2_desc, get_pcvar_num(level2_bosshp), get_pcvar_num(level2_bossmaxspeed), get_pcvar_num(level2_health), get_pcvar_num(level2_maxspeed), get_pcvar_num(level2_respawns))
			}
			case 3:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level3_name, level3_desc, sizeof level3_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level3_desc, get_pcvar_num(level3_bosshp), get_pcvar_num(level3_bossmaxspeed), get_pcvar_num(level3_health), get_pcvar_num(level3_maxspeed), get_pcvar_num(level3_respawns))
			}
			case 4:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level4_name, level4_desc, sizeof level4_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level4_desc, get_pcvar_num(level4_bosshp), get_pcvar_num(level4_bossmaxspeed), get_pcvar_num(level4_health), get_pcvar_num(level4_maxspeed), get_pcvar_num(level4_respawns))
			}
			case 5:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level5_name, level5_desc, sizeof level5_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level5_desc, get_pcvar_num(level5_bosshp), get_pcvar_num(level5_bossmaxspeed), get_pcvar_num(level5_health), get_pcvar_num(level5_maxspeed), get_pcvar_num(level5_respawns))
			}
			case 6:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level6_name, level6_desc, sizeof level6_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level6_desc, get_pcvar_num(level6_bosshp), get_pcvar_num(level6_bossmaxspeed), get_pcvar_num(level6_health), get_pcvar_num(level6_maxspeed), get_pcvar_num(level6_respawns))
			}
			case 7:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level7_name, level7_desc, sizeof level7_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level7_desc, get_pcvar_num(level7_bosshp), get_pcvar_num(level7_bossmaxspeed), get_pcvar_num(level7_health), get_pcvar_num(level7_maxspeed), get_pcvar_num(level7_respawns))
			}
			case 8:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level8_name, level8_desc, sizeof level8_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level8_desc, get_pcvar_num(level8_bosshp), get_pcvar_num(level8_bossmaxspeed), get_pcvar_num(level8_health), get_pcvar_num(level8_maxspeed), get_pcvar_num(level8_respawns))
			}
			case 9:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level9_name, level9_desc, sizeof level9_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level9_desc, get_pcvar_num(level9_bosshp), get_pcvar_num(level9_bossmaxspeed), get_pcvar_num(level9_health), get_pcvar_num(level9_maxspeed), get_pcvar_num(level9_respawns))
			}
			case 10:
			{ 
				server_cmd("zombie_knife 0")
				get_pcvar_string(level10_name, level10_desc, sizeof level10_desc -1)
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 999.0, 0.1, 0.2, 4)
				show_hudmessage(0, "Night %d %s^nBoss: %d Health / %d Velocity^nZombies: %d Health / %d Velocity / %d Respawns", get_pcvar_num(zombie_level), level10_desc, get_pcvar_num(level10_bosshp), get_pcvar_num(level10_bossmaxspeed), get_pcvar_num(level10_health), get_pcvar_num(level10_maxspeed), get_pcvar_num(level10_respawns))
			}
		}
	}
}

///////////////////////////////////////////////////////////////////
// Bot Limit                                                    //
/////////////////////////////////////////////////////////////////

public zombie_slots()
{
	if(get_pcvar_num(zombie_bot))
	{
		switch(get_pcvar_num(zombie_bot))
		{
			case 1:
			{ 
				server_cmd("pb_minbots %d", get_pcvar_num(zombie_maxslots))
				server_cmd("pb_maxbots %d", get_pcvar_num(zombie_maxslots))
				server_cmd("pb fillserver 100 2 1")
				server_cmd("pb_bot_quota_match 0")
			}
			case 2:
			{
				server_cmd("bot_quota %d", get_pcvar_num(zombie_maxslots))
				server_cmd("bot_quota_mode fill")
				server_cmd("bot_auto_vacate 0")
			}
		}
	}
}

///////////////////////////////////////////////////////////////////
// Bot Configuration                                            //
/////////////////////////////////////////////////////////////////

public zombie_bots()
{
	if(get_pcvar_num(zombie_bot))
	{
		switch(get_pcvar_num(zombie_bot))
		{
			case 1:
			{
				server_cmd("pb_mapstartbotdelay 1.0")
				server_cmd("pb_bot_join_team T")
				server_cmd("pb_minbotskill 100")
				server_cmd("pb_maxbotskill 100")
				server_cmd("pb_jasonmode 1")
				server_cmd("pb_detailnames 0")
				server_cmd("pb_chat 0")
				server_cmd("pb_radio 1")
				server_cmd("pb_aim_type 1")
			}
			case 2:
			{ 
				server_cmd("bot_difficulty 4")
				server_cmd("bot_chatter off")
				server_cmd("bot_auto_follow 0")
				server_cmd("bot_join_after_player 0")
				server_cmd("bot_defer_to_human 1")
				server_cmd("bot_prefix -[zombie]-")
				server_cmd("bot_allow_rogues 0")
				server_cmd("bot_walk 0")
				server_cmd("bot_join_team T")
				server_cmd("bot_eco_limit 800")
				server_cmd("bot_allow_grenades 0")
				server_cmd("bot_knives_only")
				server_cmd("bot_allow_grenades 0")
				server_cmd("bot_allow_pistols 0")
				server_cmd("bot_allow_sub_machine_guns 0")
				server_cmd("bot_allow_shotguns 0")
				server_cmd("bot_allow_rifles 0")
				server_cmd("bot_allow_snipers 0")
				server_cmd("bot_allow_machine_guns 0")
			}
		}
	}
}

///////////////////////////////////////////////////////////////////
// Set Zombie/Survivor Values                                   //
/////////////////////////////////////////////////////////////////

public event_set_power(id)
{
	set_task(0.5, "team_scanner", id)
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		set_task(0.1, "survivor_power1", id)
	}
	if(cs_get_user_team(id) == CS_TEAM_T)
	{
		switch(get_pcvar_num(zombie_level))
		{
			case 1:
			{ 
				set_task(0.1, "zombie_power_1", id)
			}
			case 2:
			{ 
				set_task(0.1, "zombie_power_2", id)
			}
			case 3:
			{ 
				set_task(0.1, "zombie_power_3", id)
			}
			case 4:
			{ 
				set_task(0.1, "zombie_power_4", id)
			}
			case 5:
			{ 
				set_task(0.1, "zombie_power_5", id)
			}
			case 6:
			{ 
				set_task(0.1, "zombie_power_6", id)
			}
			case 7:
			{ 
				set_task(0.1, "zombie_power_7", id)
			}
			case 8:
			{ 
				set_task(0.1, "zombie_power_8", id)
			}
			case 9:
			{ 
				set_task(0.1, "zombie_power_9", id)
			}
			case 10:
			{ 
				set_task(0.1, "zombie_power_10", id)
			}
		}
	}
}

public zombie_power_1(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 1
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level1_health))
	set_user_maxspeed(id, get_pcvar_float(level1_maxspeed))
}

public zombie_power_2(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 2
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level2_health))
	set_user_maxspeed(id, get_pcvar_float(level2_maxspeed))
}

public zombie_power_3(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 3
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level3_health))
	set_user_maxspeed(id, get_pcvar_float(level3_maxspeed))
}

public zombie_power_4(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 4
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level4_health))
	set_user_maxspeed(id, get_pcvar_float(level4_maxspeed))
}

public zombie_power_5(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 5
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level5_health))
	set_user_maxspeed(id, get_pcvar_float(level5_maxspeed))
}

public zombie_power_6(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 6
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level6_health))
	set_user_maxspeed(id, get_pcvar_float(level6_maxspeed))
}

public zombie_power_7(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 7
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level7_health))
	set_user_maxspeed(id, get_pcvar_float(level7_maxspeed))
}

public zombie_power_8(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 8
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level8_health))
	set_user_maxspeed(id, get_pcvar_float(level8_maxspeed))
}

public zombie_power_9(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 9
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level9_health))
	set_user_maxspeed(id, get_pcvar_float(level9_maxspeed))
}

public zombie_power_10(id)
{
	cs_set_user_money(id, 0)
	g_boss_class[id] = 0
	g_player_class[id] = 0
	g_zombie_class[id] = 10
	cs_set_user_nvg(id, 1)
	engclient_cmd(id, "nightvision")
	set_user_health(id, get_pcvar_num(level10_health))
	set_user_maxspeed(id, get_pcvar_float(level10_maxspeed))
}

public survivor_power1(id) {
	g_player_class[id] = 0
	g_zombie_class[id] = 0
	g_boss_class[id] = 0
	if(get_pcvar_num(survivor_classes) == 1)
	{
		set_task(1.0, "survivor_class_menu", id)
	}
}

///////////////////////////////////////////////////////////////////
// Set Zombie Model                                             //
/////////////////////////////////////////////////////////////////

public ham_player_spawn(id)
{
	if(!is_user_alive(id) || !cs_get_user_team(id))
		return
	g_zombie[id] = cs_get_user_team(id) == CS_TEAM_T ? true : false
	remove_task(id + 100)
	if(g_zombie[id])
	{
		switch (random_num(1, 3))
		{
			case 1: copy(g_player_model[id], charsmax( g_player_model[] ), ZOMBIE_MODEL1)
			case 2: copy(g_player_model[id], charsmax( g_player_model[] ), ZOMBIE_MODEL2)
			case 3: copy(g_player_model[id], charsmax( g_player_model[] ), ZOMBIE_MODEL3)
		}
		new currentmodel[32]
		fm_get_user_model(id, currentmodel, charsmax(currentmodel))
		if(!equal(currentmodel, g_player_model[id]))
		{
			if(get_gametime() - g_roundstart_time < 5.0)
				set_task(5.0 * 0.5, "fm_user_model_update", id + 100)
			else
				fm_user_model_update(id + 100)
		}
	}
	else if(g_has_custom_model[id])
	{
		fm_reset_user_model(id)
	}
}

public fm_client_key(id, const infobuffer[], const key[])
{   
	if(g_has_custom_model[id] && equal(key, "model"))
		return FMRES_SUPERCEDE
	return FMRES_IGNORED
}

public fm_client_info(id)
{
	if(!g_has_custom_model[id])
		return FMRES_IGNORED
	static currentmodel[32]
	fm_get_user_model(id, currentmodel, charsmax(currentmodel))
	if(!equal(currentmodel, g_player_model[id]) && !task_exists(id + 100))
		fm_set_user_model(id + 100)
	return FMRES_IGNORED
}

public fm_user_model_update(taskid)
{
	static Float:current_time
	current_time = get_gametime()
	
	if(current_time - g_models_target_time >= 0.5)
	{
		fm_set_user_model(taskid)
		g_models_target_time = current_time
	}
	else
	{
		set_task((g_models_target_time + 0.5) - current_time, "fm_set_user_model", taskid)
		g_models_target_time = g_models_target_time + 0.5
	}
}

public fm_set_user_model(player)
{
	player -= 100
	engfunc(EngFunc_SetClientKeyValue, player, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", g_player_model[player])
	g_has_custom_model[player] = true
}

///////////////////////////////////////////////////////////////////
// Player Connected                                             //
/////////////////////////////////////////////////////////////////

public client_connect(id)
{
	g_first_spawn[id] = true
}

///////////////////////////////////////////////////////////////////
// Player Disconnected                                          //
/////////////////////////////////////////////////////////////////

public client_disconnect(id)
{
	remove_task(id)
	g_respawn_count[id] = 0
}

///////////////////////////////////////////////////////////////////
// Death Event                                                  //
/////////////////////////////////////////////////////////////////

public ham_player_killed(victim, attacker, shouldgib)
{
	new cts[32], ts[32], ctsnum, tsnum
	new CsTeams:team
	
	for(new i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_alive(i))
		{
			continue
		}
		team = cs_get_user_team(i)
		if(team == CS_TEAM_T)
		{
			ts[tsnum++] = i
		} else if(team == CS_TEAM_CT) {
			cts[ctsnum++] = i
		}
	}
	if(ctsnum == 0)
	{
		switch(get_pcvar_num(zombie_level))
		{
			case 1:
			{
				server_cmd("zombie_level 1")
				server_cmd("zombie_respawns %d", get_pcvar_num(level1_respawns))
			}
			case 2:
			{
				server_cmd("zombie_level 1")
				server_cmd("zombie_respawns %d", get_pcvar_num(level1_respawns))
			}
			case 3:
			{
				server_cmd("zombie_level 2")
				server_cmd("zombie_respawns %d", get_pcvar_num(level2_respawns))
			}
			case 4:
			{
				server_cmd("zombie_level 3")
				server_cmd("zombie_respawns %d", get_pcvar_num(level3_respawns))
			}
			case 5:
			{
				server_cmd("zombie_level 4")
				server_cmd("zombie_respawns %d", get_pcvar_num(level4_respawns))
			}
			case 6:
			{
				server_cmd("zombie_level 5")
				server_cmd("zombie_respawns %d", get_pcvar_num(level5_respawns))
			}
			case 7:
			{
				server_cmd("zombie_level 6")
				server_cmd("zombie_respawns %d", get_pcvar_num(level6_respawns))
			}
			case 8:
			{
				server_cmd("zombie_level 7")
				server_cmd("zombie_respawns %d", get_pcvar_num(level7_respawns))
			}
			case 9:
			{
				server_cmd("zombie_level 8")
				server_cmd("zombie_respawns %d", get_pcvar_num(level8_respawns))
			}
			case 10:
			{
				server_cmd("zombie_level 9")
				server_cmd("zombie_respawns %d", get_pcvar_num(level9_respawns))
			}
		}
	}
	if(tsnum == 0)
	{
		switch(get_pcvar_num(zombie_level))
		{
			case 1:
			{
				server_cmd("zombie_level 2")
				server_cmd("zombie_respawns %d", get_pcvar_num(level2_respawns))
			}
			case 2:
			{ 
				server_cmd("zombie_level 3")
				server_cmd("zombie_respawns %d", get_pcvar_num(level3_respawns))
			}
			case 3:
			{ 
				server_cmd("zombie_level 4")
				server_cmd("zombie_respawns %d", get_pcvar_num(level4_respawns))
			}
			case 4:
			{
				server_cmd("zombie_level 5")
				server_cmd("zombie_respawns %d", get_pcvar_num(level5_respawns))
			}
			case 5:
			{ 
				server_cmd("zombie_level 6")
				server_cmd("zombie_respawns %d", get_pcvar_num(level6_respawns))
			}
			case 6:
			{ 
				server_cmd("zombie_level 7")
				server_cmd("zombie_respawns %d", get_pcvar_num(level7_respawns))
			}
			case 7:
			{
				server_cmd("zombie_level 8")
				server_cmd("zombie_respawns %d", get_pcvar_num(level8_respawns))
			}
			case 8:
			{ 
				server_cmd("zombie_level 9")
				server_cmd("zombie_respawns %d", get_pcvar_num(level9_respawns))
			}
			case 9:
			{ 
				server_cmd("zombie_level 10")
				server_cmd("zombie_respawns %d", get_pcvar_num(level10_respawns))
			}
			case 10:
			{
				set_task(3.0, "new_map")
				server_cmd("zombie_level 1")
				server_cmd("zombie_respawns %d", get_pcvar_num(level1_respawns))
			}
		}
	}  
	if(tsnum == 1 && g_boss_class[ts[0]] < 1)
	{
		switch(get_pcvar_num(zombie_level))
		{
			case 1:
			{
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 1
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level1_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level1_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 2:
			{
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 2
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level2_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level2_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 3:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 3
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level3_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level3_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 4:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 4
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level4_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level4_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 5:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 5
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level5_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level5_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 6:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 6
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level6_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level6_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 7:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 7
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level7_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level7_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 8:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 8
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level8_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level8_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 9:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 9
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level9_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level9_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
			case 10:
			{ 
				g_player_class[ts[0]] = 0
				g_zombie_class[ts[0]] = 0
				g_boss_class[ts[0]] = 10
				new tname[32]
				get_user_name(ts[0], tname, 31)
				set_hudmessage(255, 255, 255, -1.0, 0.20, 0, 6.0, 999.0, 0.1, 0.2, 2)
				show_hudmessage(0, "%s is the Boss!!!", tname)
				client_cmd(0, "spk zombiehell/zh_boss.wav")
				set_user_health(ts[0], get_pcvar_num(level10_bosshp))
				set_user_maxspeed(ts[0], get_pcvar_float(level10_bossmaxspeed))
				server_cmd("zombie_knife 1")
				set_task(1.0, "boss_beacon", ts[0])
			}
		}
	}  
	if(cs_get_user_team(victim) == CS_TEAM_T && get_pcvar_num(zombie_effect) == 1)
	{
		static Float:FOrigin2[3]
		pev(victim, pev_origin, FOrigin2)
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin2, 0)
		write_byte(TE_PARTICLEBURST)
		engfunc(EngFunc_WriteCoord, FOrigin2[0])
		engfunc(EngFunc_WriteCoord, FOrigin2[1])
		engfunc(EngFunc_WriteCoord, FOrigin2[2])
		write_short(50)
		write_byte(72)
		write_byte(10)
		message_end()
	}
}  

public new_map()
{
	new nextmap[32]
	get_cvar_string("amx_nextmap", nextmap, 31)
	server_cmd("changelevel %s", nextmap)
}

///////////////////////////////////////////////////////////////////
// Death Event 2                                                //
/////////////////////////////////////////////////////////////////

public event_death_msg()
{
	new killzor = read_data(1)
	new zrespawn = read_data(2)
	set_pev(zrespawn, pev_effects, EF_NODRAW)
	pev(zrespawn, pev_origin, g_last_origin[zrespawn])
	if(cs_get_user_team(zrespawn) == CS_TEAM_T && !is_user_bot(zrespawn))
	{
		g_respawn_count[zrespawn] = 0
		cs_set_user_team(zrespawn, CS_TEAM_CT)
	}
	if(get_user_team(zrespawn) == 1)
	{
		if(++g_respawn_count[zrespawn] > get_pcvar_num(zombie_respawns))
		{
			return
		}        
		set_task(5.0, "zombie_respawner", zrespawn)
	}
	g_user_kill[zrespawn] = 0
	g_user_kill[killzor]++
	new team2 = get_user_team(killzor)
	static name3[33]
	get_user_name(killzor,name3,32)
	set_hudmessage(255, 255, 255, -1.0, 0.30, 0, 6.0, 6.0, 0.1, 0.2, 3)
	if(get_pcvar_num(zombie_scores) == 1)
	{
		switch(g_user_kill[killzor])
		{
			case 5:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s NEEDS MORE SURVIVORS FOR HIS BURGUER!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s SEEMS TO BE A ZOMBIE KILLER!", name3)
					}
				}
			}
			case 10:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s NEEDS MORE FRESH MEAT!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s IS A CRAZY ZOMBIE HEADHUNTER!", name3)
					}
				}
			}
			case 15:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s IS HUNGRY AND MUST EAT MORE BRAINS!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s CANNOT STOP BLOW ZOMBIE HEADS OFF!", name3)
					}
				}
			}
			case 20:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s IS AN ASSASSIN ZOMBIE!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s IS A BRAVE SOLDIER!", name3)
					}
				}
			}
			case 25:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s IS A LUNATIC ZOMBIEEE!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s IS DEADLY, BETTER YOU RUN ZOMBIES!", name3)
					}
				}
			}
			case 30:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s IS A SURVIVOR SLAYER!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s IS A ZOMBIE SLAYER!", name3)
					}
				}
			}
			case 35:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s IS THE KING OF ZOMBIES!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s IS THE KING OF SURVIVORS!", name3)
					}
				}
			}
			case 50:
			{
				switch(team2)
				{
					case 1:
					{
						show_hudmessage(0, "%s IS THE GOD OF ZOMBIES!", name3)
					}
					case 2:
					{
						show_hudmessage(0, "%s IS THE GOD OF SURVIVORS!", name3)
					}
				}
			}
		}
	}
}

///////////////////////////////////////////////////////////////////
// CSDM Respawn                                                 //
/////////////////////////////////////////////////////////////////

public zombie_respawner(zrespawn)
{
	new cts[32], ts[32], ctsnum, tsnum
	new CsTeams:team
	
	for(new i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_alive(i))
		{
			continue
		}
		team = cs_get_user_team(i)
		if(team == CS_TEAM_T)
		{
			ts[tsnum++] = i
		} else if(team == CS_TEAM_CT) {
			cts[ctsnum++] = i
		}
	}
	if(tsnum > 1)
	{
		ExecuteHamB(Ham_CS_RoundRespawn, zrespawn)
		set_task(0.1, "respawn_effect", zrespawn)
		strip_user_weapons(zrespawn)
		give_item(zrespawn, "")
		set_user_godmode(zrespawn, 1) 
		set_task(5.0, "remove_protection", zrespawn)
	}
}

csdm_respawn()
{   
	new map[32], config[32],  mapfile[64]
	
	get_mapname(map, 31)
	get_configsdir(config, 31)
	format(mapfile, 63, "%s\csdm\%s.spawns.cfg", config, map)
	g_total_spawn = 0
	
	if (file_exists(mapfile)) 
	{
		new new_data[124], len
		new line = 0
		new pos[12][8]
		
		while(g_total_spawn < 60 && (line = read_file(mapfile , line , new_data , 123 , len) ) != 0 ) 
		{
			if (strlen(new_data)<2 || new_data[0] == '[')
				continue
			
			parse(new_data, pos[1], 7, pos[2], 7, pos[3], 7, pos[4], 7, pos[5], 7, pos[6], 7, pos[7], 7, pos[8], 7, pos[9], 7, pos[10], 7)
			
			g_spawn_vec[g_total_spawn][0] = str_to_float(pos[1])
			g_spawn_vec[g_total_spawn][1] = str_to_float(pos[2])
			g_spawn_vec[g_total_spawn][2] = str_to_float(pos[3])
			
			g_spawn_angle[g_total_spawn][0] = str_to_float(pos[4])
			g_spawn_angle[g_total_spawn][1] = str_to_float(pos[5])
			g_spawn_angle[g_total_spawn][2] = str_to_float(pos[6])
			
			g_spawn_v_angle[g_total_spawn][0] = str_to_float(pos[8])
			g_spawn_v_angle[g_total_spawn][1] = str_to_float(pos[9])
			g_spawn_v_angle[g_total_spawn][2] = str_to_float(pos[10])
			
			g_total_spawn++
		}
		
		if (g_total_spawn >= 2)
		{
			RegisterHam(Ham_Spawn, "player", "csdm_player_spawn", 1)
		}
	}
	return 1
}

public csdm_player_spawn(id)
{
	if (!is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_CT)
		return
	
	if (g_first_spawn[id])
	{
		g_first_spawn[id] = false
		return
	}
	
	new list[60]
	new num = 0
	new final = -1
	new total=0
	new players[32], n, x = 0
	new Float:loc[32][3], locnum
	
	get_players(players, num)
	for (new i=0; i<num; i++)
	{
		if (is_user_alive(players[i]) && players[i] != id)
		{
			pev(players[i], pev_origin, loc[locnum])
			locnum++
		}
	}
	
	num = 0
	while (num <= g_total_spawn)
	{
		if (num == g_total_spawn)
			break
		n = random_num(0, g_total_spawn-1)
		if (!list[n])
		{
			list[n] = 1
			num++
		} 
		else 
		{
			total++
			if (total > 100)
				break
			continue  
		}
		
		if (locnum < 1)
		{
			final = n
			break
		}
		
		final = n
		for (x = 0; x < locnum; x++)
		{
			new Float:distance = get_distance_f(g_spawn_vec[n], loc[x])
			if (distance < 250.0)
			{
				final = -1
				break
			}
		}
		
		if (final != -1)
			break
	}
	
	if (final != -1)
	{
		new Float:mins[3], Float:maxs[3]
		pev(id, pev_mins, mins)
		pev(id, pev_maxs, maxs)
		engfunc(EngFunc_SetSize, id, mins, maxs)
		engfunc(EngFunc_SetOrigin, id, g_spawn_vec[final])
		set_pev(id, pev_fixangle, 1)
		set_pev(id, pev_angles, g_spawn_angle[final])
		set_pev(id, pev_v_angle, g_spawn_v_angle[final])
		set_pev(id, pev_fixangle, 1)
	}
}  

///////////////////////////////////////////////////////////////////
// Respawn Effect                                               //
/////////////////////////////////////////////////////////////////

public respawn_effect(id)
{
	if(get_pcvar_num(zombie_effect) == 1)
	{
		static Float:FOrigin3[3] 
		pev(id, pev_origin, FOrigin3)
		
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, FOrigin3, 0)
		write_byte(TE_IMPLOSION) 
		engfunc(EngFunc_WriteCoord, FOrigin3[0])
		engfunc(EngFunc_WriteCoord, FOrigin3[1]) 
		engfunc(EngFunc_WriteCoord, FOrigin3[2]) 
		write_byte(255)
		write_byte(255)
		write_byte(5)  
		message_end()
	}
}

///////////////////////////////////////////////////////////////////
// Respawn Protection                                           //
/////////////////////////////////////////////////////////////////

public remove_protection(id)
{
	give_item(id, "weapon_knife")
	set_user_godmode(id, 0)
}

///////////////////////////////////////////////////////////////////
// Light Grenade                                                //
/////////////////////////////////////////////////////////////////

public fm_set_model(ent, model[]) 
{
	if(!pev_valid(ent) || !is_user_alive(pev(ent, pev_owner)))
		return FMRES_IGNORED
	
	new Float: duration = 999.0
	
	if(equali(model,"models/w_smokegrenade.mdl"))
	{
		new className[33]
		pev(ent, pev_classname, className, 32)
		
		set_pev(ent, pev_nextthink, get_gametime() + duration)
		set_pev(ent,pev_effects,EF_BRIGHTLIGHT)
	}
	
	return FMRES_IGNORED
}

public fm_think(ent) 
{
	if(!pev_valid(ent) || !is_user_alive(pev(ent, pev_owner)))
		return FMRES_IGNORED
	
	static classname[33]
	pev(ent, pev_classname, classname, sizeof classname - 1)
	static model[33]
	pev(ent, pev_model, model, sizeof model - 1)
	
	if(equal(model, "models/w_smokegrenade.mdl") && equal(classname, "grenade"))
		engfunc(EngFunc_RemoveEntity, ent)
	
	return FMRES_IGNORED
}

///////////////////////////////////////////////////////////////////
// Fire Grenade                                                 //
/////////////////////////////////////////////////////////////////

public event_damage(id)
{
	new bodypart, weapon
	new enemy = get_user_attacker(id, weapon, bodypart)
	if(weapon == CSW_HEGRENADE && cs_get_user_team(id) == CS_TEAM_T && is_user_alive(id)) 
	{
		new Name[33]
		get_user_name(id,Name,32)
		g_burning[id] = 1
		ignite_player(id)
		ignite_effects(id)
		client_print(id, print_chat, "You are burning, lol!")
		client_print(enemy, print_chat, "You caught %s on fire!", Name)
		set_task(10.0, "water_timer", id)
	}
}

public water_timer(id)
{
	if(is_user_alive(id))
	{
		g_burning[id] = 0
	}
}

public ignite_effects(skIndex)
{
	new kIndex = skIndex
	
	if(is_user_alive(kIndex) && g_burning[kIndex])
	{
		new korigin[3]
		get_user_origin(kIndex,korigin)
		
		message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(17)
		write_coord(korigin[0])
		write_coord(korigin[1])
		write_coord(korigin[2])
		write_short(g_fire)
		write_byte(10)
		write_byte(200)
		message_end()
		
		set_task(0.2, "ignite_effects" ,skIndex)
	}
	else {
		if(g_burning[kIndex])
		{
			g_burning[kIndex] = 0
		}
	}
	return PLUGIN_CONTINUE
}

public ignite_player(skIndex)
{
	new kIndex = skIndex
	
	if(is_user_alive(kIndex) && g_burning[kIndex])
	{
		new korigin[3]
		new players[32]
		new pOrigin[3]
		new kHeath = get_user_health(kIndex)
		get_user_origin(kIndex,korigin)
		
		set_user_health(kIndex,kHeath - 10)
		message_begin(MSG_ONE, g_damage, {0,0,0}, kIndex)
		write_byte(30)
		write_byte(30)
		write_long(1<<21) 
		write_coord(korigin[0]) 
		write_coord(korigin[1]) 
		write_coord(korigin[2])
		message_end()
		
		players[0] = 0                
		korigin[0] = 0 
		pOrigin[0] = 0 
	}
	set_task(2.0, "ignite_player" , skIndex) 
}

///////////////////////////////////////////////////////////////////
// Survivor Classes                                             //
/////////////////////////////////////////////////////////////////

public survivor_class_menu(id)
{
	if(cs_get_user_team(id) == CS_TEAM_CT) 
	{
		new menu = menu_create("\rSurvivor Classes:", "survivor_menu_handler")
		menu_additem(menu, "\wUrban", "1", 0)
		menu_additem(menu, "\wGIGN", "2", 0)
		menu_additem(menu, "\wSAS", "3", 0)
		menu_additem(menu, "\wGSG9", "4", 0)
		menu_additem(menu, "\wGuerilla", "5", 0)
		menu_additem(menu, "\wPhoenix", "6", 0)
		menu_additem(menu, "\wLeet", "7", 0)
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
		menu_display(id, menu, 0)
	}
}

public survivor_menu_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback)
	new key = str_to_num(data)
	switch(key)
	{
		case 1:
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 1
			set_user_health(id, 145)
			set_user_maxspeed(id, 230.0)
		}
		case 2:
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 2
			set_user_health(id, 130)
			set_user_maxspeed(id, 240.0)
		}
		case 3: 
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 3
			set_user_health(id, 115)
			set_user_maxspeed(id, 250.0)
		}
		case 4: 
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 4
			set_user_health(id, 90)
			set_user_maxspeed(id, 275.0)
		}
		case 5: 
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 5
			set_user_health(id, 140)
			set_user_maxspeed(id, 220.0)
		}
		case 6: 
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 6
			set_user_health(id, 100)
			set_user_maxspeed(id, 270.0)
		}
		case 7: 
		{
			g_zombie_class[id] = 0
			g_boss_class[id] = 0
			g_player_class[id] = 7
			set_user_health(id, 80)
			set_user_maxspeed(id, 280.0)
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

///////////////////////////////////////////////////////////////////
// Weapon Switch Event                                          //
/////////////////////////////////////////////////////////////////

public event_check_speed(id)
{
	if(g_player_class[id])
	{
		switch(g_player_class[id])
		{
			case 1:
			{ 
				set_user_maxspeed(id, 230.0)
			}
			case 2:
			{ 
				set_user_maxspeed(id, 240.0)
			}
			case 3:
			{ 
				set_user_maxspeed(id, 250.0)
			}
			case 4:
			{ 
				set_user_maxspeed(id, 275.0)
			}
			case 5:
			{ 
				set_user_maxspeed(id, 220.0)
			}
			case 6:
			{ 
				set_user_maxspeed(id, 270.0)
			}
			case 7:
			{ 
				set_user_maxspeed(id, 280.0)
			}
		}
	}
	if(g_zombie_class[id])
	{
		switch(g_zombie_class[id])
		{
			case 1:
			{
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level1_maxspeed))
			}
			case 2:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level2_maxspeed))
			}
			case 3:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level3_maxspeed))
			}
			case 4:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level4_maxspeed))
			}
			case 5:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level5_maxspeed))
			}
			case 6:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level6_maxspeed))
			}
			case 7:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level7_maxspeed))
			}
			case 9:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level8_maxspeed))
			}
			case 8:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level9_maxspeed))
			}
			case 10:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level10_maxspeed))
			}
		}
	}
	if(g_boss_class[id])
	{
		switch(g_boss_class[id])
		{
			case 1:
			{
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level1_bossmaxspeed))
			}
			case 2:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level2_bossmaxspeed))
			}
			case 3:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level3_bossmaxspeed))
			}
			case 4:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level4_bossmaxspeed))
			}
			case 5:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level5_bossmaxspeed))
			}
			case 6:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level6_bossmaxspeed))
			}
			case 7:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level7_bossmaxspeed))
			}
			case 9:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level8_bossmaxspeed))
			}
			case 8:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level9_bossmaxspeed))
			}
			case 10:
			{ 
				engclient_cmd(id, "weapon_knife")
				set_user_maxspeed(id, get_pcvar_float(level10_bossmaxspeed))
			}
		}
	}
}

///////////////////////////////////////////////////////////////////
// Lock Zombie Team                                             //
/////////////////////////////////////////////////////////////////

public force_team(id)
{
	engclient_cmd(id, "jointeam", "2", "3")
}

public team_scanner(id)
{
	if(cs_get_user_team(id) == CS_TEAM_T && !is_user_bot(id))
	{
		user_kill(id)
		cs_set_user_team(id, CS_TEAM_CT)
		ExecuteHamB(Ham_CS_RoundRespawn, id)
		client_print(id, print_chat, "Dont try to become a zombie, asshole!")
	}
}

///////////////////////////////////////////////////////////////////
// Unlimited Ammo                                               //
/////////////////////////////////////////////////////////////////

public event_free_ammo(id)
{
	set_pdata_int(id, 376 + read_data(1), 200, 5)
}

///////////////////////////////////////////////////////////////////
// Kill Hostages                                                //
/////////////////////////////////////////////////////////////////

public kill_hostages()
{
	new hostages = create_entity("trigger_hurt")
	
	if(!hostages)
		return
	
	DispatchKeyValue(hostages, "dmg", "200")
	DispatchSpawn(hostages)
	
	new iHostage = -1
	
	while((iHostage = find_ent_by_class(iHostage, "hostage_entity")) > 0)
		fake_touch(hostages, iHostage)
	
	remove_entity(hostages)
}

///////////////////////////////////////////////////////////////////
// Stocks                                                       //
/////////////////////////////////////////////////////////////////

stock fm_get_user_model(player, model[], len)
{
	engfunc(EngFunc_InfoKeyValue, engfunc(EngFunc_GetInfoKeyBuffer, player), "model", model, len)
}

stock fm_reset_user_model(player)
{
	g_has_custom_model[player] = false
	dllfunc(DLLFunc_ClientUserInfoChanged, player, engfunc(EngFunc_GetInfoKeyBuffer, player))
}

public boss_beacon(id)
{
	if(g_boss_class[id] >= 1)
	{
		static origin[3]
		emit_sound(id, CHAN_ITEM, g_beacon_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
		get_user_origin(id, origin)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMCYLINDER)
		write_coord(origin[0])
		write_coord(origin[1])
		write_coord(origin[2]-20)
		write_coord(origin[0])    
		write_coord(origin[1])    
		write_coord(origin[2]+200)
		write_short(g_boss_sprite)
		write_byte(0)       
		write_byte(1)        
		write_byte(6)
		write_byte(2)        
		write_byte(1)        
		write_byte(50)      
		write_byte(50)      
		write_byte(255)
		write_byte(200)
		write_byte(6)
		message_end()
		set_task(1.0, "boss_beacon", id)
	}
}  

///////////////////////////////////////////////////////////////////
// EOF                                                          //
/////////////////////////////////////////////////////////////////