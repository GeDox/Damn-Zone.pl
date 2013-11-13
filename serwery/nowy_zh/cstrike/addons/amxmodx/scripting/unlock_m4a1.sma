#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <gunxpmod>
#include <engine>
#include <cstrike>

new PLUGIN_NAME[] 	= "UNLOCK : M16"
new PLUGIN_AUTHOR[] 	= "xbatista"
new PLUGIN_VERSION[] 	= "1.0"

new const WEAPON_V_MDL[] = "models/gunxpmod/v_m4a1.mdl";
new const g_w_blast[] = "models/umbrella/w_heseek.mdl";
#define WEAPON_CSW CSW_M4A1
new const weapon_n[] = "weapon_m4a1";

const m_pPlayer	= 41;
const m_flNextSecondaryAttack = 47;
const m_flNextPrimaryAttack	= 46;

#define IsPlayer(%1)  ( 1 <= %1 <= g_maxplayers )
#define DMG_HEGRENADE (1<<24)

new g_hasZoom[33];

new damage_weapon, weapon_recoil, weapon_explo_distance, weapon_m203_damage,
weapon_m203_ammo;
new g_maxplayers;	
new bool:g_Weapon[33]; 
new Float:cl_pushangle[33][3];
new Float: g_LastThrow[33];
new g_spriteBlast;
new g_iM4A1;
new g_M203ammo[33];
new szClip, szAmmo;

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_gxm_item("M4A1 Eotech", "+Aim +Power ( M4a1 )", 350)

	damage_weapon = register_cvar("gxm_damage_m4","1.3"); // damage multiplier
	weapon_recoil = register_cvar( "m4_recoil", "0.7" ); // weapon recoil

	weapon_explo_distance = register_cvar("gxm_distance_m2_m4","200"); // Distance of exploding M203
	weapon_m203_damage = register_cvar("gxm_damage_m2_m4","400"); // damage of M203
	weapon_m203_ammo = register_cvar("gxm_ammo_m2_m4","7"); // M203 ammo

	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1");
	
	RegisterHam( Ham_Weapon_PrimaryAttack, weapon_n, "Fwd_AttackSpeedPost" , 1 );
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_n, "Fwd_AttackSpeedPre");

	RegisterHam( Ham_Item_Deploy , weapon_n, "Fwd_AttackSpeedPost", 1);

	RegisterHam(Ham_TakeDamage, "player", "Ham_DamageWeapon");

	RegisterHam(Ham_Spawn, "player", "fwd_PlayerSpawn", 1)

	register_forward( FM_CmdStart, "Fwd_CmdStart" );
	register_forward(FM_Touch, "Entity_Touched");

	g_maxplayers = get_maxplayers();

	g_iM4A1 = create_entity("grenade")
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
	engfunc(EngFunc_PrecacheModel, g_w_blast);
	g_spriteBlast = engfunc(EngFunc_PrecacheModel, "sprites/dexplo.spr");
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
		set_pdata_float( Entity , m_flNextSecondaryAttack , 9999.0, 4 );

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
public fwd_PlayerSpawn(id)
{
	if ( !is_user_alive(id) )
		return;

	g_M203ammo[id] = get_pcvar_num( weapon_m203_ammo );
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
public Fwd_CmdStart( id, uc_handle, seed )
{
	if( !is_user_alive( id ) || !g_Weapon[id] ) 
		return FMRES_IGNORED;

	static Float:Time;
	Time = get_gametime();

	if( ( get_uc( uc_handle, UC_Buttons ) & IN_USE ) && !( pev( id, pev_oldbuttons ) & IN_USE ) )
	{
		new szWeapID = get_user_weapon( id, szClip, szAmmo )

		if( szWeapID == WEAPON_CSW && !g_hasZoom[ id ])
		{
			g_hasZoom[ id ] = true
			cs_set_user_zoom( id, CS_SET_AUGSG552_ZOOM, 1 )
		}

		else 
		{	if( g_hasZoom[ id ] )
			{
				g_hasZoom[ id ] = false
				cs_set_user_zoom( id,  CS_RESET_ZOOM, 0 )
			}
		}

		return FMRES_HANDLED;
	}

	if( ( get_uc( uc_handle, UC_Buttons ) & IN_ATTACK2 ) && !( pev( id, pev_oldbuttons ) & IN_ATTACK2 ) && get_user_weapon(id) == WEAPON_CSW )
	{
		if (Time - 2.0 > g_LastThrow[id])
		{
			Throw_FireBlast(id);			

			g_LastThrow[id] = Time; 
		}
	}

	return FMRES_IGNORED;
}
public Entity_Touched(ent, victim)
{
	if ( !pev_valid(ent) )
		return;

	new classname[32]
	pev( ent, pev_classname, classname, 31)

	new attacker = entity_get_edict(ent, EV_ENT_owner);

	if ( equal(classname,"M203") )
	{
		new Float: Torigin[3], Float: Distance, Float: Damage;

		new Float:fOrigin[3], iOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin)	
		iOrigin[0] = floatround(fOrigin[0])
		iOrigin[1] = floatround(fOrigin[1])
		iOrigin[2] = floatround(fOrigin[2])	

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		engfunc( EngFunc_WriteCoord,fOrigin[0]);
		engfunc( EngFunc_WriteCoord,fOrigin[1]);
		engfunc( EngFunc_WriteCoord,fOrigin[2]);
		write_short(g_spriteBlast);
		write_byte(32); // scale
		write_byte(20); // framerate
		write_byte(0); // flags
		message_end();

		for(new enemy = 1; enemy <= g_maxplayers; enemy++) 
		{
			if ( is_user_alive(enemy) && get_user_team(enemy) != get_user_team(attacker) )
			{
				entity_get_vector( enemy, EV_VEC_origin, Torigin)

				Distance = get_distance_f(fOrigin, Torigin);

				if ( Distance <= get_pcvar_float( weapon_explo_distance ) && get_user_team(attacker) != get_user_team(enemy) )
				{
					Damage = (((Distance / get_pcvar_float( weapon_explo_distance )) * get_pcvar_float( weapon_m203_damage )) - get_pcvar_float( weapon_m203_damage )) * -1.0;

					if (Damage > 0.0)
					{
						ExecuteHam(Ham_TakeDamage, enemy, g_iM4A1, attacker, Damage, DMG_HEGRENADE);
					}
				}
			}
		}

		set_pev( ent, pev_flags, FL_KILLME);
	}
}

public Throw_FireBlast(id)
{
	if ( !is_user_alive(id) || g_M203ammo[id] < 1 )
		return;

	g_M203ammo[id]--;

	client_printcolor(id, "/yM203 ammo left: /g%d", g_M203ammo[id])

	new Float: fOrigin[3], Float:fAngle[3],Float: fVelocity[3];

	entity_get_vector( id, EV_VEC_origin, fOrigin);
	entity_get_vector( id, EV_VEC_view_ofs, fAngle);

	fOrigin[0] += fAngle[0];
	fOrigin[1] += fAngle[1];
	fOrigin[2] += fAngle[2];
	
	fm_velocity_by_aim(id, 1.0, fVelocity, fAngle);
	fAngle[0] *= -1.0;

	new sprite_ent = create_entity("info_target");

	entity_set_string( sprite_ent, EV_SZ_classname, "M203");
	entity_set_model( sprite_ent, g_w_blast);

	entity_set_edict( sprite_ent, EV_ENT_owner, id);

	entity_set_size( sprite_ent, Float:{-2.1, -2.1, -2.1}, Float:{2.1, 2.1, 2.1});

	entity_set_vector( sprite_ent, EV_VEC_origin, fOrigin);

	fOrigin[0] += fVelocity[0] - 30.0;
	fOrigin[1] += fVelocity[1];
	fOrigin[2] += fVelocity[2];

	entity_set_int( sprite_ent, EV_INT_movetype, MOVETYPE_BOUNCE);
	entity_set_int( sprite_ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_float( sprite_ent, EV_FL_gravity, 0.55);
	
	fVelocity[0] *= 1000.0;
	fVelocity[1] *= 1000.0;
	fVelocity[2] *= 1000.0;

	entity_set_vector( sprite_ent, EV_VEC_velocity, fVelocity);
	entity_set_vector( sprite_ent, EV_VEC_angles, fAngle);

}

stock fm_velocity_by_aim(iIndex, Float:fDistance, Float:fVelocity[3], Float:fViewAngle[3])
{
	//new Float:fViewAngle[3]
	pev(iIndex, pev_v_angle, fViewAngle)
	fVelocity[0] = floatcos(fViewAngle[1], degrees) * fDistance
	fVelocity[1] = floatsin(fViewAngle[1], degrees) * fDistance
	fVelocity[2] = floatcos(fViewAngle[0]+90.0, degrees) * fDistance
	return 1
}