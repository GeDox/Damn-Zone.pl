#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <gunxpmod>
#include <engine>
#include <cstrike>

new PLUGIN_NAME[] 	= "Elite"
new PLUGIN_AUTHOR[] 	= "Jakemajster"
new PLUGIN_VERSION[] 	= "1.0"

new const WEAPON_V_MDL[] = "models/gunxpmod/v_elite.mdl";
#define WEAPON_CSW CSW_ELITE
new const weapon_n[] = "weapon_elite";

const m_pPlayer	= 41;
const m_flPrimaryAttack = 46;

#define IsPlayer(%1)  ( 1 <= %1 <= g_maxplayers )

new damage_weapon, weapon_recoil;
new g_maxplayers;	
new bool:g_Weapon[33]; 
new Float:cl_pushangle[33][3];

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_gxm_item("Welrod Strikers (Elite)", "+Aim -Rate +Power ( Elite )", 30)
	
	damage_weapon = register_cvar("gxm_damage_dg","3.0"); // damage multiplier
	weapon_recoil = register_cvar( "el_recoil", "0.9" ); // weapon recoil
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1");
	
	RegisterHam( Ham_Weapon_PrimaryAttack, weapon_n, "Fwd_AttackSpeedPost" , 1 );
	RegisterHam( Ham_Weapon_PrimaryAttack, weapon_n, "Fwd_AttackSpeedPre");
	
	RegisterHam( Ham_Item_Deploy , weapon_n, "Fwd_AttackSpeedPost", 1 );
	
	RegisterHam(Ham_TakeDamage, "player", "Ham_DamageWeapon");
	
	
	g_maxplayers = get_maxplayers();
}
public gxm_item_enabled(id) 
{
	g_Weapon[id] = true;
}
public client_connect(id) 
{
	g_Weapon[id] = false;
}
public plugin_precache()  
{
	engfunc(EngFunc_PrecacheModel, WEAPON_V_MDL);
}

public Fwd_AttackSpeedPre(Ent)
{
	new id = pev(Ent,pev_owner);
	entity_get_vector( id, EV_VEC_punchangle, cl_pushangle[id]);
}
public Fwd_AttackSpeedPost( const Entity )
{
	static id ; id = get_pdata_cbase(Entity, m_pPlayer, 4)
	if (g_Weapon[id] && IsPlayer(id) )
	{
		
		new Float:push[3];
		entity_get_vector( id, EV_VEC_punchangle, cl_pushangle[id]);
		xs_vec_sub( push, cl_pushangle[id], push);
		xs_vec_mul_scalar( push, get_pcvar_float( weapon_recoil ), push);
		xs_vec_add( push, cl_pushangle[id], push);
		entity_set_vector( id, EV_VEC_punchangle, push);
	}
}

public Ham_DamageWeapon(id, inflictor, attacker, Float:damage, damagebits) 
{
	if ( !IsPlayer(attacker) || !g_Weapon[attacker] )
		return HAM_IGNORED; 
	
	new weapon2 = get_user_weapon(attacker, _, _);
	if( weapon2 == WEAPON_CSW)
	{
		SetHamParamFloat(4, damage * get_pcvar_float(damage_weapon));
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}
public Event_CurWeapon(id) 
{
	if ( !g_Weapon[id] || !is_user_alive(id) )
		return PLUGIN_CONTINUE;
	
	new Gun = read_data(2) 
	
	if( Gun == WEAPON_CSW)
	{
		entity_set_string(id, EV_SZ_viewmodel, WEAPON_V_MDL)
	}
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
