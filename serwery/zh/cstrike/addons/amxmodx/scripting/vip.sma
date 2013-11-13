#include <amxmodx>
#include <colorchat>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

forward amxbans_admin_connect(id);

new Array:g_Array, CsArmorType:armortype, bool:g_Vip[33], skoki[33], weapon_id;

new const g_Langcmd[][]={"say /vips","say_team /vips","say /vipy","say_team /vipy"};
new Rounds[33];
new Round;
new menu_weapon;

public plugin_init(){
	register_plugin("VIP Ultimate", "12.3.0.2", "benio101 & speedkill & GeDox");
	register_forward(FM_CmdStart, "CmdStartPre");
	RegisterHam(Ham_Spawn, "player", "SpawnedEventPre", 1);
	register_event("DeathMsg", "DeathMsg", "a");
	register_event("HLTV", "event_RoundStart", "a", "1=0", "2=0"); 
	register_message(get_user_msgid("ScoreAttrib"), "VipStatus");
	g_Array=ArrayCreate(64,32);
	for(new i;i<sizeof g_Langcmd;i++){
		register_clcmd(g_Langcmd[i], "ShowVips");
	}
	register_clcmd("say /vip", "ShowMotd");
	register_clcmd("say /bronie", "ShowBronie");

	menu_weapon = menu_create("Bronie", "handler_bronie");
	menu_additem(menu_weapon, "AWP + DGL");
	menu_additem(menu_weapon, "M4A1 + DGL");
	menu_additem(menu_weapon, "AK47 + DGL"); 
	menu_additem(menu_weapon, "MP5 + DGL");
	menu_setprop(menu_weapon, MPROP_EXIT, MEXIT_ALL);
}

public handler_bronie( id, menu, item )
{
	switch( item )
	{
		case 0: { give_item(id, "weapon_awp"); cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_awp", id), 10); cs_set_user_bpammo(id, CSW_AWP, 30);}
		case 1: { give_item(id, "weapon_m4a1"); cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_m4a1", id), 30); cs_set_user_bpammo(id, CSW_M4A1, 90);}
		case 2: { give_item(id, "weapon_ak47"); cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_ak47", id), 30); cs_set_user_bpammo(id, CSW_AK47, 90);}
		case 3: { give_item(id, "weapon_mp5navy"); cs_set_weapon_ammo(find_ent_by_owner(-1, "weapon_mp5navy", id), 25); cs_set_user_bpammo(id, CSW_MP5NAVY, 120);}
	}

	return PLUGIN_HANDLED;
}
 
public ShowBronie(id)
{
	if(Round > 1 && Rounds[id] != Round)
	{
		menu_display(id, menu_weapon);
		Rounds[id] = Round;
	}
}

public event_RoundStart()
	Round++;

public client_authorized(id)
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		client_authorized_vip(id);
	

public client_authorized_vip(id){
	g_Vip[id]=true;
	new g_Name[64];
	get_user_name(id,g_Name,charsmax(g_Name));
	
	new g_Size = ArraySize(g_Array);
	new szName[64];
	
	for(new i = 0; i < g_Size; i++){
		ArrayGetString(g_Array, i, szName, charsmax(szName));
		
		if(equal(g_Name, szName)){
			return 0;
		}
	}
	ArrayPushString(g_Array,g_Name);
	
	new str[90];
	format(str, charsmax(str), "VIP %s wszedl na serwer!", g_Name);
	set_hudmessage(36, 218, 30, 0.29, 0.17, 0, 6.0, 12.0)
	show_hudmessage(id, str)
	
	
	return PLUGIN_CONTINUE;
}
public client_disconnect(id){
	if(g_Vip[id]){
		client_disconnect_vip(id);
	}
}
public client_disconnect_vip(id){
	g_Vip[id]=false;
	new Name[64];
	get_user_name(id,Name,charsmax(Name));
	
	new g_Size = ArraySize(g_Array);
	new g_Name[64];
	
	for(new i = 0; i < g_Size; i++){
		ArrayGetString(g_Array, i, g_Name, charsmax(g_Name));
		
		if(equal(g_Name,Name)){
			ArrayDeleteItem(g_Array,i);
			break;
		}
	}
}
public CmdStartPre(id, uc_handle){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			CmdStartPreVip(id, uc_handle);
		}
	}
}
public CmdStartPreVip(id, uc_handle){
	new flags = pev(id, pev_flags);
	if((get_uc(uc_handle, UC_Buttons) & IN_JUMP) && !(flags & FL_ONGROUND) && !(pev(id, pev_oldbuttons) & IN_JUMP) && skoki[id]>0){
		--skoki[id];
		new Float:velocity[3];
		pev(id, pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id,pev_velocity,velocity);
	} else if(flags & FL_ONGROUND && skoki[id]!=-1){
		skoki[id] = 1;
	}
}
public SpawnedEventPre(id){
	if(g_Vip[id]){
		if(is_user_alive(id)){
			SpawnedEventPreVip(id);
		}
	}
}
public SpawnedEventPreVip(id){
	skoki[id]=1;
	set_user_health(id, get_user_health(id)+30);
	cs_set_user_armor(id, min(cs_get_user_armor(id,armortype)+100, 300), armortype);
	new henum=(user_has_weapon(id,CSW_HEGRENADE)?cs_get_user_bpammo(id,CSW_HEGRENADE):0);
	give_item(id, "weapon_hegrenade");
	++henum;
	cs_set_user_bpammo(id, CSW_HEGRENADE, 2);
	new fbnum=(user_has_weapon(id,CSW_FLASHBANG)?cs_get_user_bpammo(id,CSW_FLASHBANG):0);
	give_item(id, "weapon_flashbang");
	++fbnum;
	cs_set_user_bpammo(id, CSW_FLASHBANG, 2);
	new sgnum=(user_has_weapon(id,CSW_SMOKEGRENADE)?cs_get_user_bpammo(id,CSW_SMOKEGRENADE):0);
	give_item(id, "weapon_smokegrenade");
	++sgnum;
	give_item(id, "weapon_deagle");
	give_item(id, "ammo_50ae");
	weapon_id=find_ent_by_owner(-1, "weapon_deagle", id);
	if(weapon_id)
		cs_set_weapon_ammo(weapon_id, 7);
	
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	
	if(get_user_team(id)==2)
		give_item(id, "item_thighpack");
}
public DeathMsg(){
	new killer=read_data(1);
	new victim=read_data(2);
	
	if(is_user_alive(killer) && g_Vip[killer] && get_user_team(killer) != get_user_team(victim))
		DeathMsgVip(killer,victim,read_data(3));
}
public DeathMsgVip(kid,vid,hs)
	set_user_health(kid, min(get_user_health(kid)+(hs?10:5),130));

public VipStatus(){
	new id=get_msg_arg_int(1);
	
	if(is_user_alive(id) && g_Vip[id])
		set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2)|4);
	
}
public ShowVips(id){
	new g_Name[64],g_Message[192];
	
	new g_Size=ArraySize(g_Array);
	
	for(new i = 0; i < g_Size; i++){
		ArrayGetString(g_Array, i, g_Name, charsmax(g_Name));
		
		add(g_Message, charsmax(g_Message), g_Name);
		
		if(i == g_Size - 1){
			add(g_Message, charsmax(g_Message), ".");
		}
		else{
			add(g_Message, charsmax(g_Message), ", ");
		}
	}
	ColorChat(id,GREEN,"^x03Vipy ^x04na ^x03serwerze: ^x04%s", g_Message);
	return PLUGIN_CONTINUE;
}
public client_infochanged(id){
	if(g_Vip[id]){
		new szName[64];
		get_user_info(id,"name",szName,charsmax(szName));
		
		new Name[64];
		get_user_name(id,Name,charsmax(Name));
		
		if(!equal(szName,Name)){
			ArrayPushString(g_Array,szName);
			
			new g_Size=ArraySize(g_Array);
			new g_Name[64];
			for(new i = 0; i < g_Size; i++){
				ArrayGetString(g_Array, i, g_Name, charsmax(g_Name));
				
				if(equal(g_Name,Name)){
					ArrayDeleteItem(g_Array,i);
					break;
				}
			}
		}
	}
}

public plugin_end()
	ArrayDestroy(g_Array);

public ShowMotd(id)
	show_motd(id, "vip.txt", "Informacje o vipie");

public amxbans_admin_connect(id)
	client_authorized(id);
