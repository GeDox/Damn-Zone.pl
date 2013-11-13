#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "Blokada Granatow TT"
#define VERSION "1.0"
#define AUTHOR "Benio101"

public plugin_init() 
{
        register_plugin(PLUGIN, VERSION, AUTHOR)

        RegisterHam(Ham_Touch, "weapon_hegrenade", "ZablokujGranaty",0);
        RegisterHam(Ham_Touch, "weapon_flashbang", "ZablokujGranaty",0);
        RegisterHam(Ham_Touch, "weapon_smokegrenade", "ZablokujGranaty",0);
}
public ZablokujGranaty(grenade,id)
{
        if(!pev_valid(grenade))
                return HAM_IGNORED;

        if(!(1<=id<=get_maxplayers()) || !is_user_alive(id))
                return HAM_IGNORED;

        if(get_user_team(id)==1)
                return HAM_SUPERCEDE;
        return HAM_IGNORED;
}