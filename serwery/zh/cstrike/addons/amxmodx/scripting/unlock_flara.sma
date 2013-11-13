#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <gunxpmod>
#include <engine>
#include <cstrike>
#include <weapon>

new PLUGIN_NAME[] 	= "Flara"
new PLUGIN_AUTHOR[] 	= "Jakemajster"
new PLUGIN_VERSION[] 	= "1.0"

new bool:g_Weapon[33]; 

const m_pPlayer	= 41;
 

public plugin_init() 
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	register_gxm_item("Flara", " Rozswietla obszar w promieniu 5m", 9)
}
public gxm_item_enabled(id) 
{
	g_Weapon[id] = false;
	give_item(id, "weapon_smokegrenade")
}

public client_connect(id){
	
         g_Weapon[id] = true;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
