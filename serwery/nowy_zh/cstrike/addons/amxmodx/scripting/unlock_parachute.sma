#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <gunxpmod>

new PLUGIN_NAME[] 	= "Unlock : Parachute"
new PLUGIN_AUTHOR[] 	= "xbatista"
new PLUGIN_VERSION[] 	= "1.0"

new const parachute_model[] = "models/parachute.mdl"

new bool:has_parachute[33]
new para_ent[33]
new g_parachute_FallSpeed, g_parachute_Detach
public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_gxm_item("Parachute", "Gives you parachute", 30)

	g_parachute_FallSpeed = register_cvar("gxm_parachute_fallspeed", "30")
	g_parachute_Detach = register_cvar("gxm_parachute_detach", "1")

	register_forward(FM_PlayerPreThink,"PlayerPree_Think");
}
public plugin_precache()
	engfunc(EngFunc_PrecacheModel, parachute_model)
public gxm_item_enabled(id) {
	has_parachute[id] = true
}
public client_connect(id) 
{
	parachute_reset(id)
	has_parachute[id] = false
}
parachute_reset(id)
{
	if (para_ent[id] > 0) 
	{
		if ( pev_valid(para_ent[id]) ) 
			engfunc(EngFunc_RemoveEntity, para_ent[id])
	}

	has_parachute[id] = false
	para_ent[id] = 0
}
public PlayerPree_Think(id)
{
	//parachute.mdl animation information
	//0 - deploy - 84 frames
	//1 - idle - 39 frames
	//2 - detach - 29 frames
	
	if (!is_user_alive(id) || !has_parachute[id] )
		return

	new Float:fallspeed = get_pcvar_float(g_parachute_FallSpeed) * -1.0
	new Float:frame

	new button = pev(id, pev_button)
	new oldbutton = pev(id, pev_oldbuttons)
	new flags = pev(id, pev_flags)

	if (para_ent[id] > 0 && (flags & FL_ONGROUND)) 
	{
		set_view(id, CAMERA_NONE)
		
		if (get_pcvar_num(g_parachute_Detach)) 
		{
			if ( pev(para_ent[id],pev_sequence) != 2 ) 
			{
				set_pev(para_ent[id], pev_sequence, 2)
				set_pev(para_ent[id], pev_gaitsequence, 1)
				set_pev(para_ent[id], pev_frame, 0.0)
				set_pev(para_ent[id], pev_fuser1, 0.0)
				set_pev(para_ent[id], pev_animtime, 0.0)
				return
			}
			
			pev(para_ent[id],pev_fuser1, frame)
			frame += 2.0
			set_pev(para_ent[id],pev_fuser1,frame)
			set_pev(para_ent[id],pev_frame,frame)
			
			if ( frame > 254.0 )
			{
				engfunc(EngFunc_RemoveEntity, para_ent[id])
				para_ent[id] = 0
			}
		}
		else 
		{
			engfunc(EngFunc_RemoveEntity, para_ent[id])
			para_ent[id] = 0
		}
		return
	}

	if (button & IN_USE && get_user_team(id) == 2) 
	{
		new Float:velocity[3]
		pev(id, pev_velocity, velocity)
		
		if (velocity[2] < 0.0) 
		{
			if(para_ent[id] <= 0) 
			{
				para_ent[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
				
				if(para_ent[id] > 0) 
				{
					set_pev(para_ent[id],pev_classname,"parachute")
					set_pev(para_ent[id], pev_aiment, id)
					set_pev(para_ent[id], pev_owner, id)
					set_pev(para_ent[id], pev_movetype, MOVETYPE_FOLLOW)
					engfunc(EngFunc_SetModel, para_ent[id], parachute_model)
					set_pev(para_ent[id], pev_sequence, 0)
					set_pev(para_ent[id], pev_gaitsequence, 1)
					set_pev(para_ent[id], pev_frame, 0.0)
					set_pev(para_ent[id], pev_fuser1, 0.0)
				}
			}
			
			if (para_ent[id] > 0) 
			{
				set_pev(id, pev_sequence, 3)
				set_pev(id, pev_gaitsequence, 1)
				set_pev(id, pev_frame, 1.0)
				set_pev(id, pev_framerate, 1.0)
			
				velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
				set_pev(id, pev_velocity, velocity)
				
				if (pev(para_ent[id],pev_sequence) == 0) 
				{
					pev(para_ent[id],pev_fuser1, frame)
					frame += 1.0
					set_pev(para_ent[id],pev_fuser1,frame)
					set_pev(para_ent[id],pev_frame,frame)
					
					if (frame > 100.0) 
					{
						set_pev(para_ent[id], pev_animtime, 0.0)
						set_pev(para_ent[id], pev_framerate, 0.4)
						set_pev(para_ent[id], pev_sequence, 1)
						set_pev(para_ent[id], pev_gaitsequence, 1)
						set_pev(para_ent[id], pev_frame, 0.0)
						set_pev(para_ent[id], pev_fuser1, 0.0)
					}
				}
			}
		}
		
		else if (para_ent[id] > 0) 
		{
			engfunc(EngFunc_RemoveEntity, para_ent[id])
			para_ent[id] = 0
		}
	}
	
	else if ((oldbutton & IN_USE) && para_ent[id] > 0 ) 
	{
		engfunc(EngFunc_RemoveEntity, para_ent[id])
		para_ent[id] = 0
	}
}