#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <cstrike>
#include <fun>
#include <engine>
 
#define PLUGIN "Blokada Granatow Zombie"
#define VERSION "1.0"
#define AUTHOR "Benio101"

public plugin_init() {
        register_plugin(PLUGIN, VERSION, AUTHOR)

        RegisterHam(Ham_Touch, "weapon_hegrenade", "ZablokujGranaty",0);
        RegisterHam(Ham_Touch, "weapon_flashbang", "ZablokujGranaty",0);
        RegisterHam(Ham_Touch, "weapon_smokegrenade", "ZablokujGranaty",0);
}
public ZablokujGranaty(grenade,id){
	if(!pev_valid(grenade))
                return HAM_IGNORED;

	if(!(1<=id<=get_maxplayers()) || !is_user_alive(id))
		return HAM_IGNORED;

	new CsTeams:userTeam = cs_get_user_team(id)
        //if(get_user_team(id)==2)
	if (userTeam == CS_TEAM_T && is_user_bot(id))
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
