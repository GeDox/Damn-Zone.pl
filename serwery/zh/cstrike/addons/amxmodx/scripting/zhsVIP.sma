#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <ColorChat>

#define VIPS
#define SCOREATTRIB_NONE        0
#define SCOREATTRIB_DEAD        (1<<0)
#define SCOREATTRIB_BOMB        (1<<1)
#define SCOREATTRIB_VIP         (1<<2)

#if defined VIPS

new maxplayers
#endif

new const PLUGIN[] = "Dolina-Fragow.pl ZH VIP";
new const VERSION[] = "1.4";
new const AUTHOR[] = "Jakemajster";
new gbUsed[33];
new static FLAGA = ADMIN_LEVEL_E;

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_event("DeathMsg", "Death", "ade");
	#if defined VIPS
	maxplayers = get_maxplayers()
	register_clcmd("say /vips", "print_vips", 0);
	register_clcmd("say /vipy", "print_vips", 0);
	#endif
	register_clcmd("say /vip", "Info", 0);
	
	register_message(get_user_msgid("ScoreAttrib"), "MessageScoreAttrib");
	register_logevent("round_start", 2, "0=World triggered", "1=Round_Start")
	
	register_forward(FM_CmdStart, "CmdStart");
	
	RegisterHam(Ham_Spawn, "player", "user_spawn", 1);
	RegisterHam(Ham_Killed, "player", "user_killed", 1)
	
}

public plugin_precache() {
		precache_model("models/player/dfvip/dfvip.mdl")
	}
//Odrodzenie

public client_authorized(id)
	gbUsed[id] = false;

public Death(id) 
{ 
	
	new id = read_data(2); 
	if(get_user_flags(id) & FLAGA) 
		MenuOdrodzenia(id) 
	
} 

public MenuOdrodzenia(id) 
{ 
	if(gbUsed[id])
		return PLUGIN_HANDLED;
	new menu = menu_create("Chcesz sie odrodzic?","Menu_Handle") 
	menu_additem(menu,"Tak") 
	menu_additem(menu,"Nie") 
	menu_display(id,menu) 
	gbUsed[id] = true;
	return PLUGIN_HANDLED;
} 

public round_start()
{
	for(new i = 1; i < 33; i++)
	{
		gbUsed[i] = false;
	}
}

public Menu_Handle(id,menu,item) 
{ 
	menu_destroy(menu) 
	
	if(item == 0){
		ExecuteHamB(Ham_CS_RoundRespawn, id);
		ColorChat(id, GREEN, "[Damn-Zone.pl] ^x01Odrodziles sie!")
	}
	else if(item){
		ColorChat(id, GREEN, "[Damn-Zone.pl] ^x01Pamietaj, ze tylko raz na runde mozesz sie odrodzic!")
	}
}

//Kevlar i model

public user_spawn(id)
{
	if(!is_user_connected(id) || !(get_user_flags(id) & ADMIN_LEVEL_E))
		return PLUGIN_CONTINUE;
	
	cs_set_user_armor(id, 100, CS_ARMOR_KEVLAR);
	cs_set_user_model(id, "dfvip");
	
	return PLUGIN_CONTINUE;
}
//15HP za kill'a

public user_killed(victim, attacker, shouldgib)
{
	if(get_user_flags(attacker) & ADMIN_LEVEL_E)
	{
		if((get_user_health(attacker) + 15) > 245)
			set_user_health(attacker, 245);
		else
			set_user_health(attacker, get_user_health(attacker)+15);
	}
}
//Podwojny skok

public CmdStart(id, uc_handle)
{	
	static moze_skoczyc;
	
	if(!is_user_alive(id) || !(get_user_flags(id) & ADMIN_LEVEL_E))
		
	return FMRES_IGNORED;
	
	new button = get_uc(uc_handle, UC_Buttons);
	
	new oldbutton = pev(id, pev_oldbuttons);
	
	new flags = pev(id, pev_flags);
	
	if((button & IN_JUMP) && !(flags & FL_ONGROUND) && !(oldbutton & IN_JUMP) && moze_skoczyc & (1<<id))
	{
		moze_skoczyc &=  ~(1<<id)  
		
		new Float:velocity[3];
		
		pev(id, pev_velocity, velocity);
		
		velocity[2] = random_float(265.0,285.0);
		
		set_pev(id, pev_velocity, velocity);
	}
	else if(flags & FL_ONGROUND){
		moze_skoczyc |= (1<<id)
	}	
	return FMRES_IGNORED;
}
//VIP przy nicku

public MessageScoreAttrib(iMsgID, iDest, iReceiver)
{   
	new iPlayer = get_msg_arg_int(1);
	if( is_user_connected( iPlayer )   && ( get_user_flags( iPlayer ) & ADMIN_LEVEL_E ) )
	{
		set_msg_arg_int( 2, ARG_BYTE, is_user_alive( iPlayer ) ? SCOREATTRIB_VIP : SCOREATTRIB_DEAD );  
	}
}
//Powitanie w HUD

public client_putinserver(id)
{
	if(get_user_flags(id) & ADMIN_LEVEL_E)
	{
		new name[32]
		get_user_name(id,name,31)               
		
		set_hudmessage(227, 14, 14, 0.2, 0.2, 0, 6.0, 6.0)
		show_hudmessage(0, "[VIP] Przychodzi %s", name)     
		
		client_cmd(0,"spk misc/vip")
	}
}
//Przywileje VIPa

public Info(id)
{
	show_motd(id, "vip.txt"); 
}
//Lista VIPow online

#if defined VIPS
public print_vips(user) 
{
	new adminnames[33][32]
	new message[256]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
		if(get_user_flags(id) & FLAGA)
		get_user_name(id, adminnames[count++], 31)
	
	len = format(message, 255, "[Damn-Zone.pl ^x01 VIP'y online: ")
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				ColorChat(user, GREEN, "%s", message);
				len = format(message, 255, "^x04 ")
			}
		}
		ColorChat(user, GREEN, "%s", message);
	}
	else {
		len += format(message[len], 255-len, "^x01 Brak VIP'ow online")
		
		ColorChat(user, GREEN, "%s", message);
	}
	
	
}
#endif
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
