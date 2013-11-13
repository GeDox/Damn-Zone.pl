#define PLUGIN_NAME "No Objectives"
#define PLUGIN_VERSION "0.3"
#define PLUGIN_AUTHOR "VEN, GeDox"

#include <amxmodx>
#include <fakemeta>

new const g_objective_ents[][] = 
{
	"info_bomb_target",
	"info_hostage_rescue",
	"info_vip_start"
}

#define HIDE_ROUND_TIMER (1<<4)

new g_msgid_hideweapon

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_forward(FM_Spawn, "forward_spawn")
	g_msgid_hideweapon = get_user_msgid("HideWeapon")
	register_message(g_msgid_hideweapon, "message_hide_weapon")
	register_event("ResetHUD", "event_hud_reset", "b")
	set_msg_block(get_user_msgid("RoundTime"), BLOCK_SET)
}

public forward_spawn(ent) {
	if (!pev_valid(ent))
		return FMRES_IGNORED

	static classname[32], i
	pev(ent, pev_classname, classname, sizeof classname - 1)
	for (i = 0; i < sizeof g_objective_ents; ++i) {
		if (equal(classname, g_objective_ents[i])) {
			engfunc(EngFunc_RemoveEntity, ent)
			return FMRES_SUPERCEDE
		}
	}

	return FMRES_IGNORED
}

public message_hide_weapon() {
	set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | HIDE_ROUND_TIMER)
}