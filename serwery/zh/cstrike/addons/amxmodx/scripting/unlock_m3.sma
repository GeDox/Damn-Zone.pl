#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <gunxpmod>

new PLUGIN_NAME[] 	= "Unlock : M16A1"
new PLUGIN_AUTHOR[] 	= "xbatista"
new PLUGIN_VERSION[] 	= "1.0"

new damage_m3
new g_maxplayers
new const M3_MDL[] = 	"models/umbrella/v_m3new.mdl";	
new bool:g_M3[33] 
public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_gxm_item("Hunting Pump", "Aim, Power", 50)

	damage_m3 = register_cvar("gxm_damage_m3","1.7"); // damage multiplier
	register_event("CurWeapon",	"Event_CurWeapon9", "be", "1=1")
	
	RegisterHam(Ham_TakeDamage, "player", "Ham_Damage7");
	register_forward(FM_PlayerPreThink,"PlayerPreeThink");
	g_maxplayers = get_maxplayers();
}
public gxm_item_enabled(id) {
	g_M3[id] = true
}
public client_connect(id) 
{
	g_M3[id] = false
}
public plugin_precache()  
{
	engfunc(EngFunc_PrecacheModel, M3_MDL);
}
public Ham_Damage7(id, inflictor, attacker, Float:damage, damagebits) 
{
	if ( !(1 <= attacker <= g_maxplayers) || !g_M3[attacker])
        return HAM_IGNORED; 

	new weapon2 = get_user_weapon(attacker, _, _);
	if( weapon2 == CSW_M3)
	{
		SetHamParamFloat(4, damage * get_pcvar_float(damage_m3)); //m3 damage
		return HAM_HANDLED;
	}
	return HAM_IGNORED;
}
public Event_CurWeapon9(id) 
{
	if (!g_M3[id])
	return PLUGIN_CONTINUE;

	new Gun = read_data(2) 
	
	if( Gun == CSW_M3)
	{
		set_pev(id, pev_viewmodel2, M3_MDL)
	}
	return PLUGIN_CONTINUE;
}
public PlayerPreeThink(id)
{
	if (!g_M3[id])
		return FMRES_IGNORED;
	new weapon = get_user_weapon(id, _, _);
	if (weapon == CSW_M3)
	{
		set_pev(id, pev_punchangle, Float:{0.0, 0.0, 0.0});
	}

	return FMRES_IGNORED;
}
//Frome Fakemeta utility
stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0)
{
	new strtype[11] = "classname", ent = index
	switch (jghgtype) 
	{
		case 1: strtype = "target"
		case 2: strtype = "targetname"
	}
	
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}
	
	return ent
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
