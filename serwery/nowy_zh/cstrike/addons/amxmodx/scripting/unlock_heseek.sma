#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <gunxpmod>

#define fm_is_valid_ent(%1) pev_valid(%1)

new cvar_maxdis
new sprite_trail,g_trail;

new const g_he_model[] = "models/umbrella/w_heseek.mdl"
new const HE_MDL[] = 	"models/umbrella/v_heseek2.mdl"

new PLUGIN_NAME[] 	= "Unlock : Grenade Seeker"
new PLUGIN_AUTHOR[] 	= "xbatista"
new PLUGIN_VERSION[] 	= "1.0"

new bool:g_NadeSeek[33] 
public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_gxm_item("Zombie Seeker", "Heat seeking grenade", 90)

	cvar_maxdis = register_cvar("heatseekhe_max_dis", "500.0")
	register_forward(FM_Think, 	"fwd_think")
	register_forward(FM_Touch, 	"fwd_touch")
	register_forward(FM_SetModel, 	"fwd_setmodel")
	register_event("CurWeapon",	"Event_CurWeapon7", "be", "1=1")

}
public plugin_precache()
{
	sprite_trail = precache_model("sprites/laserbeam.spr")
	g_trail = precache_model("sprites/smoke.spr");
	precache_model(g_he_model)
	precache_model(HE_MDL)
}
public gxm_item_enabled(id) {
	g_NadeSeek[id] = true
}
public client_connect(id) 
{
	g_NadeSeek[id] = false
}
public Event_CurWeapon7(id) 
{
	if (!g_NadeSeek[id])
	return PLUGIN_CONTINUE;

	new Gun = read_data(2) 
	
	if( Gun == CSW_HEGRENADE)
	{
		set_pev(id, pev_viewmodel2, HE_MDL)
	}
	return PLUGIN_CONTINUE;
}
public grenade_throw(id,gid,wid)
{
	if(wid != CSW_HEGRENADE || !g_NadeSeek[id])
		return PLUGIN_CONTINUE;
		
	Follow(gid,g_trail,10,12,255,0,0,195);
	return PLUGIN_CONTINUE;
}
Follow(entity,index,life,width,red,green,blue,alpha)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(entity);
	write_short(index);
	write_byte(life);
	write_byte(width);
	write_byte(red);
	write_byte(green);
	write_byte(blue);
	write_byte(alpha);
	message_end();
}
public fwd_setmodel(ent, model[])
{
	if(!fm_is_valid_ent(ent))
		return FMRES_IGNORED
		
	static classname[32]; pev(ent, pev_classname, classname, 31)
	if(equali(model, "models/w_hegrenade.mdl") && pev(ent, pev_iuser1) == 0)
	{
		new id = pev(ent, pev_owner)
		if(g_NadeSeek[id])
		{
			engfunc(EngFunc_SetModel, ent, g_he_model)
			set_pev(ent, pev_iuser1, 1)
			set_pev(ent, pev_iuser2, get_user_team(id))
			set_pev(ent, pev_iuser3, 0)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED
}

public fwd_touch(ent, id)
{
	if(!fm_is_valid_ent(ent) || !is_user_alive(id))
		return FMRES_IGNORED
		
	new classname[32]
	pev(ent, pev_classname, classname, (32-1))

	if(equali(classname, "grenade"))
	{
		if((pev(ent, pev_iuser1) != 1))
			return FMRES_IGNORED
			
		if(get_user_team(id) == pev(ent, pev_iuser2))
			return FMRES_IGNORED
			
		set_pev(ent, pev_iuser1, 0)
		set_pev(ent, pev_iuser2, 0)
		set_pev(ent, pev_iuser3, 0)
		
		set_pev(ent, pev_dmgtime, 0.0)
		//set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
		//set_pev(ent, pev_sequence, 0)
	}
	return FMRES_IGNORED
}

public fwd_think(ent)
{
	if(!fm_is_valid_ent(ent))
		return FMRES_IGNORED
	
	new classname[32]
	pev(ent, pev_classname, classname, (32-1))
    
	if(equali(classname, "grenade"))
	{
		if(pev(ent, pev_iuser1) != 1)
			return FMRES_IGNORED
		   
		static Float:nadeorigin[3]
		pev(ent, pev_origin, nadeorigin)
        
		new target = pev(ent, pev_iuser3)
		
		if(!is_user_alive(target))
		{
			static players[32], num
			get_players(players, num, "a")
		
			for(new i = 0; i < num; ++i)    
			{
				new id = players[i]
		
				if(get_user_team(id) == pev(ent, pev_iuser2))
					continue
				
				if(!fm_is_ent_visible(ent, id))
					continue
		
				static Float:origin[3]
				pev(id, pev_origin, origin)
			    
				new Float:maxdistance = get_pcvar_float(cvar_maxdis)
				new Float:distance = get_distance_f(origin, nadeorigin)
			    
				if(distance < maxdistance)
				{
					set_pev(ent, pev_iuser3, id)
		
					message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
					write_byte(TE_BEAMFOLLOW)
					write_short(ent)
					write_short(sprite_trail)
					write_byte(30)
					write_byte(10)
					write_byte(255)
					write_byte(0)
					write_byte(0)
					write_byte(100)
					message_end()
					
					break
				}
			}
		}
		else
			entity_set_follow(ent, target, float(fm_get_speed(ent)))
	}
	return FMRES_IGNORED
}

stock entity_set_follow(entity, target, Float:speed) 
{
	if(!fm_is_valid_ent(entity) || !fm_is_valid_ent(target)) 
		return 0

	new Float:entity_origin[3], Float:target_origin[3]
	pev(entity, pev_origin, entity_origin)
	pev(target, pev_origin, target_origin)

	new Float:diff[3]
	diff[0] = target_origin[0] - entity_origin[0]
	diff[1] = target_origin[1] - entity_origin[1]
	diff[2] = target_origin[2] - entity_origin[2]

	new Float:length = floatsqroot(floatpower(diff[0], 2.0) + floatpower(diff[1], 2.0) + floatpower(diff[2], 2.0))

	new Float:velocity[3]
	velocity[0] = diff[0] * (speed / length)
	velocity[1] = diff[1] * (speed / length)
	velocity[2] = diff[2] * (speed / length)

	set_pev(entity, pev_velocity, velocity)

	return 1
}
stock fm_get_speed(entity) {
	new Float:Vel[3]
	pev(entity, pev_velocity, Vel)

	return floatround(vector_length(Vel))
}
stock bool:fm_is_ent_visible(index, entity, ignoremonsters = 0) {
	new Float:start[3], Float:dest[3]
	pev(index, pev_origin, start)
	pev(index, pev_view_ofs, dest)
	xs_vec_add(start, dest, start)

	pev(entity, pev_origin, dest)
	engfunc(EngFunc_TraceLine, start, dest, ignoremonsters, index, 0)

	new Float:fraction
	get_tr2(0, TR_flFraction, fraction)
	if (fraction == 1.0 || get_tr2(0, TR_pHit) == entity)
		return true

	return false
}