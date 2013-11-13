#tryinclude "gunxpmod.cfg"

#if defined ZOMBIE_BIOHAZARD
#include <biohazard>
#endif
#if defined ZOMBIE_PLAGUE
#include <zombieplague>
#endif

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fun>
#include <cstrike>
#include <nvault>
#include <sqlx>
#include <hamsandwich>

#define PLUGIN	"Gun Xp Mod"
#define AUTHOR	"xbatista"
#define VERSION	"2.0"


#define OFFSET_PRIMARYWEAPON 116
#define TASK_SHOW_LEVEL 10113
#define fm_cs_set_user_nobuy(%1) set_pdata_int(%1, 235, get_pdata_int(%1, 235) & ~(1<<0) ) //no weapon buy

new PlayerXp[33];
new PlayerLevel[33];

new g_Vault;
new g_remember_selection[33], g_kills[33], g_remember_selection_pistol[33];
new g_maxplayers, g_msgHudSync1, SayTxT, enable_grenades;
new levelspr, levelspr2, show_level_text, show_rank;
new savexp, save_type, xp_kill, xp_triple, enable_triple, triple_kills, xp_ultra, ultra_kills, enable_ultra, p_Enabled, level_style;
new enable_admin_xp, admin_xp;

/*================================================================================
						[MySQLx Vars, other]
=================================================================================*/
new Handle:g_hTuple;
new g_szAuthID[33][35];
new g_szAuthIP[33][35];
new mysqlx_host, mysqlx_user, mysqlx_db, mysqlx_pass;

new const szTables[][] = 
{
	"CREATE TABLE IF NOT EXISTS `mytable` ( `player_id` varchar(32) NOT NULL,`player_level` int(8) default NULL,`player_xp` int(16) default NULL,PRIMARY KEY (`player_id`) ) TYPE=MyISAM;"
}

new const WEAPONCONST[MAXLEVEL][] = { "weapon_glock18", "weapon_usp", "weapon_p228", "weapon_fiveseven", "weapon_deagle", "weapon_elite", "weapon_tmp", 
	"weapon_mac10", "weapon_ump45", "weapon_mp5navy", "weapon_p90", "weapon_scout", "weapon_awp", "weapon_famas", "weapon_galil", "weapon_m3", "weapon_xm1014", 
	"weapon_ak47", "weapon_m4a1", "weapon_aug", "weapon_sg552", "weapon_sg550", "weapon_g3sg1", "weapon_m249", "_" 
}; // Give Weapons

new const WEAPONMDL[MAXLEVEL][] = { "models/w_glock18.mdl", "models/w_usp.mdl", "models/w_p228.mdl", "models/w_fiveseven.mdl", "models/w_deagle.mdl", "models/w_elite.mdl", "models/w_tmp.mdl", 
	"models/w_mac10.mdl", "models/w_ump45.mdl", "models/w_mp5.mdl", "models/w_p90.mdl", "models/w_scout.mdl", "models/w_awp.mdl", "models/w_famas.mdl", "models/w_galil.mdl", "models/w_m3.mdl", "models/w_xm1014.mdl", 
	"models/w_ak47.mdl", "models/w_m4a1.mdl", "models/w_aug.mdl", "models/w_sg552.mdl", "models/w_sg550.mdl", "models/w_g3sg1.mdl", "models/w_m249.mdl", "_"
}; // Blocks pick up weapon, don't change!

new const AMMOCONST[MAXLEVEL] = { 17, 16, 1, 11, 26, 10, 23, 7, 12, 19, 30, 3, 18, 
	15, 14, 21, 5, 28, 22, 8, 27, 13, 24, 20 
}; // Weapons ID(CSW) don't change!

/*================================================================================
						[Plugin natives,precache,init]
=================================================================================*/
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_cvar("gxm_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER)
	set_cvar_string("gxm_version", VERSION)
	
	register_concmd("set_level", "cmd_give_level", ADMIN_RCON, "set_level <name> <amount>" );
	register_clcmd("say level", "showlevel");
	register_clcmd("say /level", "showlevel");
	register_clcmd("say /top20","showtop20");
	register_clcmd("say /menu","show_main_menu_info");
	register_clcmd("say menu","show_main_menu_info");
	
	p_Enabled = register_cvar( "gxm_enable", "1" ); // Plugin enabled? 1 = Yes, 0 = No.
	save_type = register_cvar("gxm_savetype","1"); // Save Xp to : 1 = MySQL, 0 = NVault.
	savexp = register_cvar("gxm_save","0"); // Save Xp by : 1 = SteamID, 0 = IP.
	xp_kill = register_cvar("gxm_xp","10"); // How much xp gain if you killed someone?
	show_level_text = register_cvar("gxm_level_text","0"); // Show your level by : 1 = HUD message, 0 = Simple colored text message.
	show_rank = register_cvar("gxm_show_rank","1"); // Show rank in /top20? 1 = Yes, 0 = No.
	level_style = register_cvar("gxm_level_style","0"); // You will gain each level new gun : 1 = Yes, 0 = No,select your gun by menu.
	enable_grenades = register_cvar("gxm_grenades","1"); // Give to player grenades? 1 = Yes, 0 = No.
	
	enable_triple = register_cvar("gxm_triple","1"); // Enable Triple Kill bonus xp? 1 = Yes, 0 = No.
	xp_triple = register_cvar("gxm_triple_xp","3"); // How much bonus xp give for Triple Kill?
	triple_kills = register_cvar("gxm_triple_kills","3"); // How much kills needed to give bonus xp?
	enable_ultra = register_cvar("gxm_ultra","1"); // Enable Ultra Kill bonus xp? 1 = Yes, 0 = No.
	xp_ultra = register_cvar("gxm_ultra_xp","5"); // How much bonus xp give for Ultra Kill?
	ultra_kills = register_cvar("gxm_ultra_kills","6"); // How much kills needed to give bonus xp?
	
	enable_admin_xp = register_cvar("gxm_admin_xp","1"); // Enable Extra xp for killing? 1 = Yes, 0 = No.
	admin_xp = register_cvar("gxm_extra_xp","10"); // How much extra xp give to admins?
	
	// SQLx cvars
	mysqlx_host = register_cvar ("gxm_host", ""); // The host from the db
	mysqlx_user = register_cvar ("gxm_user", ""); // The username from the db login
	mysqlx_pass = register_cvar ("gxm_pass", ""); // The password from the db login
	mysqlx_db = register_cvar ("gxm_dbname", ""); // The database name 
	
	// Events //
	register_event("DeathMsg", "event_deathmsg", "a");
	register_event("StatusValue", "Event_StatusValue", "bd", "1=2")
	
	// Forwards //
	RegisterHam(Ham_Spawn, "player", "fwd_PlayerSpawn", 1);
	
	register_forward(FM_Touch, "fwd_Touch");
	
	// Messages //
	#if defined NORMAL_MOD || defined ZOMBIE_SWARM
	register_message(get_user_msgid("StatusIcon"),	"Message_StatusIcon")
	#endif
	
	// Other //	
	register_menucmd(register_menuid("Main Menu"), 1023, "main_menu_info")
	
	register_dictionary("gunxpmod.txt");
	MySQLx_Init()
	
	SayTxT = get_user_msgid("SayText");
	
	g_msgHudSync1 = CreateHudSyncObj()
	g_maxplayers = get_maxplayers();
}
public plugin_natives()
{
	// Player natives //
	register_native("get_user_xp", "native_get_user_xp", 1);
	register_native("set_user_xp", "native_set_user_xp", 1);
	register_native("get_user_level", "native_get_user_level", 1);
	register_native("set_user_level", "native_set_user_level", 1);
	register_native("get_user_max_level", "native_get_user_max_level", 1);
}
public plugin_precache()
{
	levelspr = engfunc(EngFunc_PrecacheModel, "sprites/xfire.spr");
	levelspr2 = engfunc(EngFunc_PrecacheModel, "sprites/xfire2.spr");
	
	engfunc(EngFunc_PrecacheSound, LevelUp);
}
public plugin_cfg()
{
	new ConfDir[32], File[192];
	
	get_configsdir( ConfDir, charsmax( ConfDir ) );
	formatex( File, charsmax( File ), "%s/gunxpmod.cfg", ConfDir );
	
	if( !file_exists( File ) )
	{
		server_print( "File %s doesn't exist!", File );
		write_file( File, " ", -1 );
	}
	else
	{	
		server_print( "%s successfully loaded.", File );
		server_cmd( "exec %s", File );
	}
	
	//Open our vault and have g_Vault store the handle.
	g_Vault = nvault_open( "gunxpmod" );

	//Make the plugin error if vault did not successfully open
	if ( g_Vault == INVALID_HANDLE )
	set_fail_state( "Error opening GunXpMod nVault, file does not exist!" );
}
public plugin_end()
{
	//Close the vault when the plugin ends (map change\server shutdown\restart)
	nvault_close( g_Vault );
}
public client_connect(id)
{
	g_remember_selection[id] = MAX_PISTOLS_MENU;
	g_remember_selection_pistol[id] = 0;
	
	get_user_authid( id , g_szAuthID[id] , 34 );
	get_user_ip(id, g_szAuthIP[id] , 34, 1);
	
	LoadLevel(id)
}
public client_disconnect(id)
{
	SaveLevel(id)
}
public Message_StatusIcon(iMsgId, MSG_DEST, id) 
{ 
	if( !get_pcvar_num(p_Enabled) )
	return PLUGIN_HANDLED;
	
	static szIcon[5] 
	get_msg_arg_string(2, szIcon, 4) 
	if( szIcon[0] == 'b' && szIcon[2] == 'y' && szIcon[3] == 'z' ) 
	{ 
		if( get_msg_arg_int(1)) 
		{ 
			fm_cs_set_user_nobuy(id) 
			return PLUGIN_HANDLED;
		} 
	}  
	
	return PLUGIN_CONTINUE;
}
public fwd_Touch(ent, id)
{
	if (!is_user_alive(id) || !pev_valid( ent ) )
	return FMRES_IGNORED;

	static szEntModel[32]; 
	pev( ent , pev_model , szEntModel , 31 ); 
	
	for (new level_equip_id = PlayerLevel[id] + 1; level_equip_id < MAXLEVEL; level_equip_id++) 
	{ 
		if ( equali( szEntModel , WEAPONMDL[level_equip_id] ) ) 
		{ 
			return FMRES_SUPERCEDE; 
		}  
	} 

	return FMRES_IGNORED;
}
public fwd_PlayerSpawn(id)
{
	if( !get_pcvar_num(p_Enabled) || !is_user_alive(id) )
	return;
	
	g_kills[id] = 0
	
	#if defined ZOMBIE_SWARM
	if ( PlayerLevel[id] == MAXLEVEL - 1 && cs_get_user_team(id) == CS_TEAM_CT )
	{
		StripPlayerWeapons(id);
		
		set_task(2.0, "show_main_menu_level", id)
	}
	#endif
	
	#if defined NORMAL_MOD || defined ZOMBIE_INFECTION
	if ( PlayerLevel[id] == MAXLEVEL - 1)
	{
		StripPlayerWeapons(id);
		
		set_task(2.0, "show_main_menu_level", id)
	}
	#endif
	
	if(!task_exists(TASK_SHOW_LEVEL + id) && get_pcvar_num(show_level_text))
	{
		set_task(0.1, "task_show_level", TASK_SHOW_LEVEL + id)
	}
	
	#if defined ZOMBIE_SWARM	
	if ( get_pcvar_num(level_style) && cs_get_user_team(id) == CS_TEAM_CT )
	{
		set_task(0.3, "give_weapon", id);
	}
	#endif

	#if defined NORMAL_MOD || defined ZOMBIE_INFECTION
	if ( get_pcvar_num(level_style) )
	{
		set_task(0.3, "give_weapon", id);
	}
	#endif

}

#if defined ZOMBIE_BIOHAZARD
public event_infect(g_victim, g_attacker)
{
	if( !get_pcvar_num(p_Enabled) )
	return;
	
	new counted_triple = get_pcvar_num(xp_kill) + get_pcvar_num(xp_triple) + get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0
	new counted_ultra = get_pcvar_num(xp_kill) + get_pcvar_num(xp_ultra) + get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0
	
	if((1 <= g_attacker <= g_maxplayers))
	{
		if(g_victim != g_attacker)
		{
			g_kills[g_attacker]++;
			if(PlayerLevel[g_attacker] < MAXLEVEL) 
			{
				if ( get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA)
				{
					PlayerXp[g_attacker] += get_pcvar_num(admin_xp)
				}
				
				if ( g_kills[g_attacker] == get_pcvar_num(triple_kills) && get_pcvar_num(enable_triple) )
				{
					PlayerXp[g_attacker] += counted_triple
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "%L", LANG_SERVER, "TRIPLE_XP", counted_triple + (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0))
				}
				else if ( g_kills[g_attacker] == get_pcvar_num(ultra_kills) && get_pcvar_num(enable_ultra) )
				{
					PlayerXp[g_attacker] += counted_ultra
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "%L", LANG_SERVER, "ULTRA_XP", counted_ultra + (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0))
				}
				else
				{
					PlayerXp[g_attacker] += get_pcvar_num(xp_kill)
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "+%i", (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0) + get_pcvar_num(xp_kill) )
				}
				
				check_level(g_attacker)
			}
		}
	}
}
#endif

#if defined ZOMBIE_PLAGUE
public zp_user_infected_post(g_victim, g_attacker)
{
	if( !get_pcvar_num(p_Enabled) )
	return;
	
	new counted_triple = get_pcvar_num(xp_kill) + get_pcvar_num(xp_triple)
	new counted_ultra = get_pcvar_num(xp_kill) + get_pcvar_num(xp_ultra)
	
	if((1 <= g_attacker <= g_maxplayers))
	{
		if(g_victim != g_attacker)
		{
			g_kills[g_attacker]++;
			if(PlayerLevel[g_attacker] < MAXLEVEL-1) 
			{
				if ( get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA)
				{
					PlayerXp[g_attacker] += get_pcvar_num(admin_xp)
				}
				
				if ( g_kills[g_attacker] == get_pcvar_num(triple_kills) && get_pcvar_num(enable_triple) )
				{
					PlayerXp[g_attacker] += counted_triple
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "%L", LANG_SERVER, "TRIPLE_XP", counted_triple + (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0))
				}
				else if ( g_kills[g_attacker] == get_pcvar_num(ultra_kills) && get_pcvar_num(enable_ultra) )
				{
					PlayerXp[g_attacker] += counted_ultra
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "%L", LANG_SERVER, "ULTRA_XP", counted_ultra + (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0))
				}
				else
				{
					PlayerXp[g_attacker] += get_pcvar_num(xp_kill)
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "+%i", (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0) + get_pcvar_num(xp_kill) )
				}
				
				check_level(g_attacker)
			}
		}
	}
}
#endif

public event_deathmsg()
{	
	if( !get_pcvar_num(p_Enabled) )
	return;
	
	new g_attacker = read_data(1);
	new g_victim = read_data(2);
	
	new counted_triple = get_pcvar_num(xp_kill) + get_pcvar_num(xp_triple)
	new counted_ultra = get_pcvar_num(xp_kill) + get_pcvar_num(xp_ultra)
	
	if((1 <= g_attacker <= g_maxplayers))
	{
		if(g_victim != g_attacker)
		{
			g_kills[g_attacker]++;
			if(PlayerLevel[g_attacker] < MAXLEVEL - 1) 
			{
				if ( get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA)
				{
					PlayerXp[g_attacker] += get_pcvar_num(admin_xp)
				}
				
				if ( g_kills[g_attacker] == get_pcvar_num(triple_kills) && get_pcvar_num(enable_triple) )
				{
					PlayerXp[g_attacker] += counted_triple
					
					set_hudmessage(0, 40, 255, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "%L", LANG_SERVER, "TRIPLE_XP", counted_triple + (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0))
				}
				else if ( g_kills[g_attacker] == get_pcvar_num(ultra_kills) && get_pcvar_num(enable_ultra) )
				{
					PlayerXp[g_attacker] += counted_ultra
					
					set_hudmessage(255, 30, 0, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "%L", LANG_SERVER, "ULTRA_XP", counted_ultra + (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0))
				}
				else
				{
					PlayerXp[g_attacker] += get_pcvar_num(xp_kill)
					
					set_hudmessage(0, 255, 50, 0.50, 0.33, 1, 2.0, 2.0)
					show_hudmessage(g_attacker, "+%i", (get_pcvar_num(enable_admin_xp) && get_user_flags(g_attacker) & ADMIN_EXTRA ? get_pcvar_num(admin_xp) : 0) + get_pcvar_num(xp_kill) )
				}
				
				check_level(g_attacker)
			}
		}
	}
}
public Event_StatusValue(id)
{
	new target = read_data(2)
	if(target != id && target != 0 && get_pcvar_num(p_Enabled))
	{
		static sName[32];
		get_user_name(target, sName, 31)

		set_hudmessage(255, 255, 255, 0.6, -1.0, 0, 0.0, 6.0, 0.0, 0.0, 2)
		ShowSyncHudMsg(id, g_msgHudSync1, "%L", LANG_SERVER, "LEVEL_TEXT", sName, PlayerLevel[target], RANKLEVELS[PlayerLevel[target]])
	}
}
public task_show_level(task)
{
	new id = task - TASK_SHOW_LEVEL
	
	if(!is_user_alive(id) || !get_pcvar_num(show_level_text) || !get_pcvar_num(p_Enabled) )
	return;
	
	set_hudmessage(255, 0, 0, 0.02, 0.33, 0, 0.0, 0.3, 0.0, 0.0)
	ShowSyncHudMsg(id, g_msgHudSync1 , "%L", LANG_SERVER, "LEVEL_HUD_TEXT", PlayerLevel[id], PlayerXp[id], LEVELS[PlayerLevel[id]], RANK[PlayerLevel[id]], RANKLEVELS[PlayerLevel[id]])
	
	set_task(0.1, "task_show_level", TASK_SHOW_LEVEL + id)		
}
public showlevel(id)
{
	if ( !get_pcvar_num(p_Enabled) || get_pcvar_num(show_level_text) )
	return PLUGIN_HANDLED;
	
	client_printcolor(id, "%L", LANG_SERVER, "LEVEL_TEXT2", PlayerLevel[id] , PlayerXp[id], LEVELS[PlayerLevel[id]]);
	client_printcolor(id, "%L", LANG_SERVER, "LEVEL_TEXT3", RANK[PlayerLevel[id]], RANKLEVELS[PlayerLevel[id]]);
	
	return PLUGIN_HANDLED;
}
public descriptionx(id)
{
	new szMotd[2048], szTitle[64], iPos = 0
	format(szTitle, 63, "Info")
	iPos += format(szMotd[iPos], 2047-iPos, "<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><pre><body>")
	iPos += format(szMotd[iPos], 2047-iPos, "^n^n<b>%s</b>^n^n", szTitle)
	iPos += format(szMotd[iPos], 2047-iPos, "%L^n", LANG_SERVER, "DESCRIPTION")
	
	iPos += format(szMotd[iPos], 2047-iPos, "%L", LANG_SERVER, "DESCRIPTION2")
	
	show_motd(id, szMotd, szTitle)
	return PLUGIN_HANDLED;
}
public check_level(id)
{
	if(PlayerLevel[id] < MAXLEVEL && get_pcvar_num(p_Enabled))
	{
		while(PlayerXp[id] >= LEVELS[PlayerLevel[id]])
		{
			PlayerLevel[id]++;
			
			if(is_user_alive(id))
			{	
				if ( get_pcvar_num(level_style) )
				{
					give_weapon(id);
				}
				
				new p_origin[3];
				get_user_origin(id, p_origin, 0);
				
				set_sprite(p_origin, levelspr, 30)
				set_sprite(p_origin, levelspr2, 30)
			}
			emit_sound(id, CHAN_ITEM, LevelUp, 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			static name[32] ; get_user_name(id, name, charsmax(name));
			client_printcolor(0, "%L", LANG_SERVER, "LEVEL_UP", name, PlayerLevel[id]);
		}
	} 
}
// Main Menu Info
public show_main_menu_info(id)
{
	if ( !get_pcvar_num(p_Enabled) )
	return;
	
	static menu[510], len;
	len = 0;
	
	new xKeys3 = MENU_KEY_0|MENU_KEY_1;

	// Title
	len += formatex(menu[len], sizeof menu - 1 - len, "%L", LANG_SERVER, "TITLE_MENU_INFO")
	
	len += formatex(menu[len], sizeof menu - 1 - len, "\r1. \w%L", id, "INFO")
	if ( get_pcvar_num(show_rank) )
	{
		xKeys3 |= (MENU_KEY_2)
		
		len += formatex(menu[len], sizeof menu - 1 - len, "^n\r2. \wTop 20^n")
	}
	else
	{
		len += formatex(menu[len], sizeof menu - 1 - len, "^n\d2. Top 20^n")
	}
	
	if(find_plugin_byfile("gunxpmod_shop.amxx") != INVALID_PLUGIN_ID)
	{
		xKeys3 |= (MENU_KEY_3)
		
		len += formatex(menu[len], sizeof menu - 1 - len, "\r3. \w%L^n", id, "ITEM_LIST")
		if ( is_user_alive(id) )
		{
			xKeys3 |= (MENU_KEY_4)
			
			len += formatex(menu[len], sizeof menu - 1 - len, "\r4. \w%L^n", id, "UNLOCKS_SHOP_TEXT")
		}
	}
	
	len += formatex(menu[len], sizeof menu - 1 - len, "^n^n\r0.\w %L", id, "EXIT_MENU")

	show_menu(id, xKeys3, menu, -1, "Main Menu")
} 
public main_menu_info(id, key)
{
	switch (key)
	{
	case 0:
		{
			show_main_menu_info(id)
			
			descriptionx(id)
		}
	case 1:
		{
			showtop20(id)
			
			show_main_menu_info(id)
		}
	case 2:
		{
			show_main_menu_info(id)
			
			if(callfunc_begin( "display_items","gunxpmod_shop.amxx") == 1)
			{
				callfunc_push_int( id ); 
				callfunc_end();
			}
		}
	case 3:
		{
			if(callfunc_begin("item_upgrades","gunxpmod_shop.amxx") == 1)
			{
				callfunc_push_int( id ); 
				callfunc_end();
			}
		}
	case 9:
		{
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_HANDLED;
}
// Main Menu Level Style
public show_main_menu_level(id)
{
	if ( !is_user_alive(id) )
	return;
	
	new szInfo[60], szChooseT[40], szLastG[40];
	formatex(szInfo, charsmax(szInfo), "%L", LANG_SERVER, "TITLE_MENU", PlayerLevel[id], PlayerXp[id], LEVELS[PlayerLevel[id]] );
	
	new menu = menu_create(szInfo , "main_menu_level");
	
	formatex(szChooseT, charsmax(szChooseT), "%L", LANG_SERVER, "CHOOSE_TEXT");
	menu_additem(menu, szChooseT, "1", 0);
	
	formatex(szLastG, charsmax(szLastG), "%L", LANG_SERVER, "LAST_GUNS");
	menu_additem(menu, szLastG, "2", 0);
	
	new szExit[15];
	formatex(szExit, charsmax(szExit), "%L", LANG_SERVER, "EXIT_MENU");
	
	menu_setprop(menu, MPROP_EXITNAME, szExit);
	
	menu_display(id , menu , 0);
} 
public main_menu_level(id , menu , item) 
{ 
	if ( !is_user_alive(id) )
	{
		return PLUGIN_HANDLED;
	}
	
	#if defined ZOMBIE_PLAGUE
	if ( zp_has_round_started() && cs_get_user_team(id) == CS_TEAM_T )
	return PLUGIN_HANDLED;
	#endif
	
	if(item == MENU_EXIT) 
	{ 
		menu_destroy(menu); 
		return PLUGIN_HANDLED;
	} 
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new item_id = str_to_num(data);
	
	switch (item_id)
	{
	case 1: // show pistols
		{
			show_menu_level_pistol(id);
		}
	case 2: // last weapons
		{
			if ( PlayerLevel[id] > MAX_PISTOLS_MENU - 1 )
			{
				give_weapon_menu(id, g_remember_selection[id], 1, 1);
				give_weapon_menu(id, g_remember_selection_pistol[id], 0, 0);
			}
			else if ( PlayerLevel[id] < MAX_PISTOLS_MENU )
			{
				give_weapon_menu(id, g_remember_selection_pistol[id], 1, 1);
			}
		}
	}

	menu_destroy(menu); 
	return PLUGIN_HANDLED;
}
// Menu Level Style Pistols
public show_menu_level_pistol(id)
{
	if ( !is_user_alive(id) )
	return;
	
	new szInfo[60];
	formatex(szInfo, charsmax(szInfo), "%L", LANG_SERVER, "TITLE_MENU", PlayerLevel[id], PlayerXp[id], LEVELS[PlayerLevel[id]] );
	
	new menu = menu_create(szInfo , "pistol_menu");
	
	for (new item_id = 0; item_id < MAX_PISTOLS_MENU; item_id++)
	{
		new szItems[60], szTempid[32];
		
		if ( PlayerLevel[id] >= GUN_LEVELS[item_id] )
		{
			formatex(szItems, charsmax(szItems), "%L", LANG_SERVER, "ACTIVE_MENU", RANK[item_id], GUN_LEVELS[item_id] )

			num_to_str(item_id, szTempid, charsmax(szTempid) );

			menu_additem(menu, szItems, szTempid, 0);
		}
		
		else
		{
			formatex(szItems, charsmax(szItems), "%L", LANG_SERVER, "INACTIVE_MENU", RANK[item_id], GUN_LEVELS[item_id] )
			menu_additem(menu, szItems, "999", 0, menu_makecallback("CallbackMenu"));
		}
	}
	
	new szNext[15], szBack[15], szExit[15];
	formatex(szBack, charsmax(szBack), "%L", LANG_SERVER, "BACK_MENU");
	formatex(szNext, charsmax(szNext), "%L", LANG_SERVER, "NEXT_MENU");
	formatex(szExit, charsmax(szExit), "%L", LANG_SERVER, "EXIT_MENU");
	
	menu_setprop(menu, MPROP_BACKNAME, szBack) 
	menu_setprop(menu, MPROP_NEXTNAME, szNext) 
	menu_setprop(menu, MPROP_EXITNAME, szExit) 
	
	menu_display(id , menu , 0); 
}
public pistol_menu(id , menu , item) 
{ 
	if ( !is_user_alive(id) )
	{
		return PLUGIN_HANDLED;
	}
	
	#if defined ZOMBIE_PLAGUE
	if ( zp_has_round_started() && cs_get_user_team(id) == CS_TEAM_T )
	return PLUGIN_HANDLED;
	#endif
	
	if(item == MENU_EXIT) 
	{ 
		menu_destroy(menu); 
		return PLUGIN_HANDLED;
	} 
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new item_id = str_to_num(data);

	g_remember_selection_pistol[id] = item_id;
	
	give_weapon_menu(id, item_id, 1, 1);
	
	if ( PlayerLevel[id] > MAX_PISTOLS_MENU - 1 )
	{
		show_menu_level(id);
	}

	menu_destroy(menu); 
	return PLUGIN_HANDLED;
}
// Menu Level Style Primary
public show_menu_level(id)
{
	if ( !is_user_alive(id) || PlayerLevel[id] < MAX_PISTOLS_MENU )
	return;
	
	new szInfo[100];
	formatex(szInfo, charsmax(szInfo), "%L", LANG_SERVER, "TITLE_MENU", PlayerLevel[id], PlayerXp[id], LEVELS[PlayerLevel[id]] );
	
	new menu = menu_create(szInfo , "level_menu");
	
	for (new item_id = MAX_PISTOLS_MENU; item_id < MAXLEVEL; item_id++)
	{
		new szItems[512], szTempid[32];
		
		if ( PlayerLevel[id] >= GUN_LEVELS[item_id] )
		{
			formatex(szItems, charsmax(szItems), "%L", LANG_SERVER, "ACTIVE_MENU", RANK[item_id], GUN_LEVELS[item_id] )

			num_to_str(item_id, szTempid, charsmax(szTempid) );

			menu_additem(menu, szItems, szTempid, 0);
		}
		else
		{
			formatex(szItems, charsmax(szItems), "%L", LANG_SERVER, "INACTIVE_MENU", RANK[item_id], GUN_LEVELS[item_id] )
			menu_additem(menu, szItems, "999", 0, menu_makecallback("CallbackMenu"));
		}
	}
	
	new szNext[15], szBack[15], szExit[15];
	formatex(szBack, charsmax(szBack), "%L", LANG_SERVER, "BACK_MENU");
	formatex(szNext, charsmax(szNext), "%L", LANG_SERVER, "NEXT_MENU");
	formatex(szExit, charsmax(szExit), "%L", LANG_SERVER, "EXIT_MENU");
	
	menu_setprop(menu, MPROP_BACKNAME, szBack) 
	menu_setprop(menu, MPROP_NEXTNAME, szNext) 
	menu_setprop(menu, MPROP_EXITNAME, szExit) 
	
	menu_display(id , menu , 0); 
}
public level_menu(id , menu , item) 
{ 
	if ( !is_user_alive(id) || PlayerLevel[id] < MAX_PISTOLS_MENU )
	{
		return PLUGIN_HANDLED;
	}
	
	#if defined ZOMBIE_PLAGUE
	if ( zp_has_round_started() && cs_get_user_team(id) == CS_TEAM_T )
	return PLUGIN_HANDLED;
	#endif
	
	if(item == MENU_EXIT) 
	{ 
		menu_destroy(menu); 
		return PLUGIN_HANDLED;
	} 
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new item_id = str_to_num(data);

	g_remember_selection[id] = item_id;
	
	give_weapon_menu(id, item_id, 0, 0);
	
	menu_destroy(menu); 
	return PLUGIN_HANDLED;
}
public CallbackMenu(id, menu, item) 
{ 
	return ITEM_DISABLED; 
}

// Selected by menu or remember selection and give item
public give_weapon_menu(id, selection, strip, givegren)
{
	#if defined ZOMBIE_SWARM
	if( is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT && get_pcvar_num(p_Enabled) ) 
	{
		if ( strip )
		{
			StripPlayerWeapons(id);
		}
		
		if ( get_pcvar_num(enable_grenades) && givegren )
		{
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, HEGRENADE_LEVEL[PlayerLevel[id]]);
			give_item(id, SMOKEGRENADE_LEVEL[PlayerLevel[id]]);
		}
		
		give_item(id, WEAPONCONST[selection]);

		if(AMMOCONST[selection])
			cs_set_user_bpammo(id, AMMOCONST[selection], AMMO2CONST[selection])
	}
	#endif
	
	#if defined ZOMBIE_INFECTION || defined NORMAL_MOD
	if(is_user_alive(id) && get_pcvar_num(p_Enabled)) 
	{
		if ( strip )
		{
			StripPlayerWeapons(id);
		}
		
		if ( get_pcvar_num(enable_grenades) && givegren )
		{
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, HEGRENADE_LEVEL[PlayerLevel[id]]);
			give_item(id, SMOKEGRENADE_LEVEL[PlayerLevel[id]]);
		}
		
		give_item(id, WEAPONCONST[selection]);

		if(AMMOCONST[selection])
			cs_set_user_bpammo(id, AMMOCONST[selection], AMMO2CONST[selection])
	}
	#endif
}
public give_weapon(id)
{
	#if defined ZOMBIE_SWARM
	if( is_user_alive(id) && cs_get_user_team(id) == CS_TEAM_CT && get_pcvar_num(p_Enabled)) 
	{
		StripPlayerWeapons(id);
		
		if ( get_pcvar_num(enable_grenades) && get_pcvar_num(level_style) )
		{
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, HEGRENADE_LEVEL[PlayerLevel[id]]);
			give_item(id, SMOKEGRENADE_LEVEL[PlayerLevel[id]]);
		}
		
		give_item(id, WEAPONCONST[PlayerLevel[id]]);
		
		if(PlayerLevel[id] > 5)
		give_item(id, "weapon_usp");
		
		if(AMMOCONST[PlayerLevel[id]])
			cs_set_user_bpammo(id, AMMOCONST[PlayerLevel[id]], AMMO2CONST[PlayerLevel[id]])
	}
	#endif
	
	#if defined ZOMBIE_INFECTION || defined NORMAL_MOD
	if(is_user_alive(id) && get_pcvar_num(p_Enabled)) 
	{
		StripPlayerWeapons(id);
		
		if ( get_pcvar_num(enable_grenades) && get_pcvar_num(level_style) )
		{
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, FLASHBANG_LEVEL[PlayerLevel[id]]);
			give_item(id, HEGRENADE_LEVEL[PlayerLevel[id]]);
			give_item(id, SMOKEGRENADE_LEVEL[PlayerLevel[id]]);
		}

		give_item(id, WEAPONCONST[PlayerLevel[id]]);

		if(PlayerLevel[id] > 5)
		give_item(id, "weapon_usp");
		
		if(AMMOCONST[PlayerLevel[id]])
			cs_set_user_bpammo(id, AMMOCONST[PlayerLevel[id]], AMMO2CONST[PlayerLevel[id]])
	}
	#endif
}
public set_sprite(p_origin[3], sprite, radius)
{
	// Explosion
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, p_origin)
	write_byte(TE_EXPLOSION)
	write_coord(p_origin[0])
	write_coord(p_origin[1])
	write_coord(p_origin[2])
	write_short(sprite)
	write_byte(radius)
	write_byte(15)
	write_byte(4)
	message_end()
}
//Shows Top 20
public showtop20(id)
{
	if( !get_pcvar_num(p_Enabled) && !get_pcvar_num(show_rank) )
	return;
	
	static Sort[33][2];
	new players[32],num,count,index;
	get_players(players,num);
	
	for(new i = 0; i < num; i++)
	{
		index = players[i];
		Sort[count][0] = index;
		Sort[count][1] = PlayerXp[index];
		count++;
	}
	
	SortCustom2D(Sort,count,"CompareXp");
	new motd[1501],iLen;
	iLen = formatex(motd, sizeof motd - 1,"<body bgcolor=#000000><font color=#98f5ff><pre>");
	iLen += formatex(motd[iLen], (sizeof motd - 1) - iLen,"%s %-22.22s %3s^n", "#", "Name", "# Experience");
	
	new y = clamp(count,0,20);
	new name[32],kindex;
	
	for(new x = 0; x < y; x++)
	{
		kindex = Sort[x][0];
		get_user_name(kindex,name,sizeof name - 1);
		iLen += formatex(motd[iLen], (sizeof motd - 1) - iLen,"%d %-22.22s %d^n", x + 1, name, Sort[x][1]);
	}
	iLen += formatex(motd[iLen], (sizeof motd - 1) - iLen,"</body></font></pre>");
	show_motd(id,motd, "GunXpMod Top 20");
}
public CompareXp(elem1[], elem2[])
{
	if(elem1[1] > elem2[1])
	return -1;
	else if(elem1[1] < elem2[1])
	return 1;
	
	return 0;
} 
// Command to set player Level
public cmd_give_level(id, level, cid) 
{
	if( !cmd_access(id, level, cid, 3) || !get_pcvar_num(p_Enabled) )
	{
		return PLUGIN_HANDLED;
	}
	
	new Arg1[64], Target
	read_argv(1, Arg1, 63)
	Target = cmd_target(id, Arg1, 0)
	
	new iLevel[32], Value
	read_argv(2, iLevel, 31)
	Value = str_to_num(iLevel)
	
	if(iLevel[0] == '-') 
	{
		console_print(id, "You can't have a '-' in the value!")
		return PLUGIN_HANDLED;
	}
	
	if(!Target) 
	{
		console_print(id, "Target not found!")
		return PLUGIN_HANDLED;
	}
	
	if(Value > MAXLEVEL)
	{
		console_print(id, "You can't set a more than %d!", MAXLEVEL)
		return PLUGIN_HANDLED;
	}
	
	if(Value < 1)
	{
		console_print(id, "You can't set less than 1!")
		return PLUGIN_HANDLED;
	}
	
	new AdminName[32]
	get_user_name(id, AdminName, 31)
	
	new TargetName[32]
	get_user_name(Target, TargetName, 31)
	
	PlayerLevel[Target] = Value - 1
	PlayerXp[Target] = LEVELS[PlayerLevel[Target]]
	check_level(Target)
	
	client_printcolor(Target, "/gADMIN: /ctr%s /yhas set your level to /g%d", AdminName, Value)

	return PLUGIN_HANDLED;
}

// ============================================================//
//                          [~ Saving datas ~]			       //
// ============================================================//
public MySQLx_Init()
{
	if ( !get_pcvar_num(p_Enabled) || !get_pcvar_num(save_type) )
	return;
	
	new szHost[64], szUser[32], szPass[32], szDB[128];
	
	get_pcvar_string( mysqlx_host, szHost, charsmax( szHost ) );
	get_pcvar_string( mysqlx_user, szUser, charsmax( szUser ) );
	get_pcvar_string( mysqlx_pass, szPass, charsmax( szPass ) );
	get_pcvar_string( mysqlx_db, szDB, charsmax( szDB ) );
	
	g_hTuple = SQL_MakeDbTuple( szHost, szUser, szPass, szDB );
	
	for ( new i = 0; i < sizeof szTables; i++ )
	{
		SQL_ThreadQuery( g_hTuple, "QueryCreateTable", szTables[i])
	}
}
public QueryCreateTable( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime ) 
{ 
	if( iFailState == TQUERY_CONNECT_FAILED 
			|| iFailState == TQUERY_QUERY_FAILED ) 
	{ 
		log_amx( "%s", szError ); 
		
		return;
	} 
}

SaveLevel(id)
{ 
	if ( get_pcvar_num(savexp) == 1)
	{
		if ( !get_pcvar_num(save_type) )
		{
			new szData[256];
			new szKey[64];
			
			formatex( szKey , 63 , "%s-ID" , g_szAuthID[id]);
			formatex( szData , 255 , "%i#%i#" , PlayerLevel[id], PlayerXp[id] );
			
			nvault_set( g_Vault , szKey , szData );
		}
		else
		{	
			static szQuery[ 128 ]; 

			formatex( szQuery, 127, "REPLACE INTO `mytable` (`player_id`, `player_level`, `player_xp`) VALUES ('%s', '%d', '%d');", g_szAuthID[id] , PlayerLevel[id], PlayerXp[id] );
			
			SQL_ThreadQuery( g_hTuple, "QuerySetData", szQuery);
		}
	}
	else if ( get_pcvar_num(savexp) == 0)
	{
		if ( !get_pcvar_num(save_type) )
		{
			new szData[256];
			new szKey[64];
			
			formatex( szKey , 63 , "%s-IP" , g_szAuthIP[id] );
			formatex( szData , 255 , "%i#%i#" , PlayerLevel[id], PlayerXp[id] );
			
			nvault_set( g_Vault , szKey , szData );
		}
		else
		{
			static szQuery[ 128 ]; 

			formatex( szQuery, 127, "REPLACE INTO `mytable` (`player_id`, `player_level`, `player_xp`) VALUES ('%s', '%d', '%d');", g_szAuthIP[id] , PlayerLevel[id], PlayerXp[id] );
			
			SQL_ThreadQuery( g_hTuple, "QuerySetData", szQuery);
		}
	}
	else if ( get_pcvar_num(savexp) == 2)
	{
		new name[32];
		get_user_name(id, name, 32);
		
		if ( !get_pcvar_num(save_type) )
		{
			new szData[256];
			new szKey[64];
			
			formatex( szKey , 63 , "%s-NAME" , name);
			formatex( szData , 255 , "%i#%i#" , PlayerLevel[id], PlayerXp[id] );
			
			nvault_set( g_Vault , szKey , szData );
		}
		else
		{
			static szQuery[ 128 ]; 

			formatex( szQuery, 127, "REPLACE INTO `mytable` (`player_name`, `player_level`, `player_xp`) VALUES ('%s', '%d', '%d');", name , PlayerLevel[id], PlayerXp[id] );
			
			SQL_ThreadQuery( g_hTuple, "QuerySetData", szQuery);
		}
	}
}

LoadLevel(id)
{
	if ( get_pcvar_num(savexp) == 1)
	{
		if ( !get_pcvar_num(save_type) )
		{
			new szData[256];
			new szKey[40];

			formatex( szKey , 39 , "%s-ID" , g_szAuthID[id] );

			formatex(szData , 255, "%i#%i#", PlayerLevel[id], PlayerXp[id]) 
			
			nvault_get(g_Vault, szKey, szData, 255) 

			replace_all(szData , 255, "#", " ")
			new xp[32], level[32] 
			parse(szData, level, 31, xp, 31) 
			PlayerLevel[id] = str_to_num(level)
			PlayerXp[id] = str_to_num(xp)  
		}
		else
		{
			static szQuery[ 128 ], iData[ 1 ]; 
			formatex( szQuery, 127, "SELECT `player_level`, `player_xp` FROM `mytable` WHERE ( `player_id` = '%s' );", g_szAuthID[id] ); 
			
			iData[ 0 ] = id;
			SQL_ThreadQuery( g_hTuple, "QuerySelectData", szQuery, iData, 1 );
		}
	}
	else if (get_pcvar_num(savexp) == 0)
	{
		if ( !get_pcvar_num(save_type) )
		{
			new szData[256];
			new szKey[40];

			formatex( szKey , 39 , "%s-IP" , g_szAuthIP[id] );

			formatex(szData , 255, "%i#%i#", PlayerLevel[id], PlayerXp[id]) 
			
			nvault_get(g_Vault, szKey, szData, 255) 

			replace_all(szData , 255, "#", " ")
			new xp[32], level[32] 
			parse(szData, level, 31, xp, 31) 
			PlayerLevel[id] = str_to_num(level)
			PlayerXp[id] = str_to_num(xp) 
		}
		else
		{
			static szQuery[ 128 ], iData[ 1 ]; 
			formatex( szQuery, 127, "SELECT `player_level`, `player_xp` FROM `mytable` WHERE ( `player_id` = '%s' );", g_szAuthIP[id] ); 
			
			iData[ 0 ] = id;
			SQL_ThreadQuery( g_hTuple, "QuerySelectData", szQuery, iData, 1 );
		}
	}
	else if(get_pcvar_num(savexp) == 2)
	{
		new name[32];
		get_user_name(id, name, 32);
		
		if ( !get_pcvar_num(save_type) )
		{
			new szData[256];
			new szKey[40];			
			formatex( szKey , 39 , "%s-NAME" ,name);

			formatex(szData , 255, "%i#%i#", PlayerLevel[id], PlayerXp[id]) 
			
			nvault_get(g_Vault, szKey, szData, 255) 

			replace_all(szData , 255, "#", " ")
			new xp[32], level[32] 
			parse(szData, level, 31, xp, 31) 
			PlayerLevel[id] = str_to_num(level)
			PlayerXp[id] = str_to_num(xp) 
		}
		else
		{
			static szQuery[ 128 ], iData[ 1 ]; 
			formatex( szQuery, 127, "SELECT `player_level`, `player_xp` FROM `mytable` WHERE ( `player_name` = '%s' );", name ); 
			
			iData[ 0 ] = id;
			SQL_ThreadQuery( g_hTuple, "QuerySelectData", szQuery, iData, 1 );
		}
	}
}
public QuerySelectData( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime ) 
{ 
	if( iFailState == TQUERY_CONNECT_FAILED 
			|| iFailState == TQUERY_QUERY_FAILED ) 
	{ 
		log_amx( "%s", szError );
		
		return;
	} 
	else 
	{ 
		new id = iData[ 0 ];
		
		new ColLevel = SQL_FieldNameToNum(hQuery, "player_level") 
		new ColXp = SQL_FieldNameToNum(hQuery, "player_xp")
		
		while (SQL_MoreResults(hQuery)) 
		{
			PlayerLevel[id] = SQL_ReadResult(hQuery, ColLevel);
			PlayerXp[id] = SQL_ReadResult(hQuery, ColXp);
			
			SQL_NextRow(hQuery)
		}
	} 
}
public QuerySetData( iFailState, Handle:hQuery, szError[ ], iError, iData[ ], iDataSize, Float:fQueueTime ) 
{ 
	if( iFailState == TQUERY_CONNECT_FAILED 
			|| iFailState == TQUERY_QUERY_FAILED ) 
	{ 
		log_amx( "%s", szError ); 
		
		return;
	} 
} 
// ============================================================//
//                          [~ Natives ~]			       	   //
// ============================================================//
// Native: get_user_xp
public native_get_user_xp(id)
{
	return PlayerXp[id];
}
// Native: set_user_xp
public native_set_user_xp(id, amount)
{
	PlayerXp[id] = amount;
}
// Native: get_user_level
public native_get_user_level(id)
{
	return PlayerLevel[id];
}
// Native: set_user_xp
public native_set_user_level(id, amount)
{
	PlayerLevel[id] = amount;
}
// Native: Gets user level by Xp
public native_get_user_max_level(id)
{
	return LEVELS[PlayerLevel[id]];
}
// ============================================================//
//                          [~ Stocks ~]			       	   //
// ============================================================//
stock client_printcolor(const id, const input[], any:...)
{
	new count = 1, players[32];
	static msg[191];
	vformat(msg,190,input,3);
	replace_all(msg,190,"/g","^4");// green txt
	replace_all(msg,190,"/y","^1");// orange txt
	replace_all(msg,190,"/ctr","^3");// team txt
	replace_all(msg,190,"/w","^0");// team txt
	if (id) players[0] = id; else get_players(players,count,"ch");
	for (new i = 0; i < count; i++)
	if (is_user_connected(players[i]))
	{
		message_begin(MSG_ONE_UNRELIABLE, SayTxT, _, players[i]);
		write_byte(players[i]);
		write_string(msg);
		message_end();
	}
}	
public StripPlayerWeapons(id) 
{ 
	strip_user_weapons(id) 
	set_pdata_int(id, OFFSET_PRIMARYWEAPON, 0) 
	give_item(id, "weapon_knife");
} 
