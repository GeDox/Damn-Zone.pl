#include <amxmodx>
#include <gunxpmod>

#define PLUGIN	"Gun Xp Mod Shop"
#define AUTHOR	"xbatista"
#define VERSION	"1.4"

#define MAX_UNLOCKS 25
#define MAX_UNLOCKS_NAME_SIZE 64
#define MAX_UNLOCKS_DESC_SIZE 128

new g_numberofitems
new g_menuPosition[33]
new bool:g_PlayerItem[33][MAX_UNLOCKS+1]
new g_itemindex[MAX_UNLOCKS+1]
new g_itemcost[MAX_UNLOCKS+1]
new g_itemname[MAX_UNLOCKS+1][MAX_UNLOCKS_NAME_SIZE+1]
new g_itemdesc[MAX_UNLOCKS+1][MAX_UNLOCKS_DESC_SIZE+1]


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_dictionary("gunxpmod.txt");
	
	register_clcmd("say /unlocks", "item_upgrades")
	register_clcmd("say unlocks", "item_upgrades")
	register_clcmd("say /ul", "item_upgrades")
	register_clcmd("say ul", "item_upgrades")
	register_clcmd("say /items", "display_items")
	register_clcmd("say items", "display_items")

	register_menucmd(register_menuid("Unlocks Shop"), 1023, "action_item_upgrades")
}
public client_connect(id)
{
	for(new i = 1; i <= MAX_UNLOCKS; ++i) 
	{
		g_PlayerItem[id][i] = false
	}
}
public display_items(id)
{
	new szMotd[2048], szTitle[64], iPos = 0
	format(szTitle, 63, "Items List")
	iPos += format(szMotd[iPos], 2047-iPos, "<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><pre><body>")
	iPos += format(szMotd[iPos], 2047-iPos, "^n^n<b>%s</b>^n^n", szTitle)
	iPos += format(szMotd[iPos], 2047-iPos, "# Item Name | Item Description | Item Cost^n")
	
	for(new i = 1; i <= g_numberofitems; i++) 
	{
		iPos += format(szMotd[iPos], 2047-iPos, "%d. %s | %s | %d^n", i, g_itemname[i], g_itemdesc[i], g_itemcost[i])
	}
	show_motd(id, szMotd, szTitle)
	return PLUGIN_HANDLED;
}
public item_upgrades(id)
{
	display_item_upgrades(id, g_menuPosition[id] = 0);
	return PLUGIN_HANDLED;
}
public display_item_upgrades(id, pos)
{	
	if(!is_user_alive(id)) 
		return;

	static menuBody[510], len;
	len = 0

	if(pos < 0) 
	{
		return;
	}
	
	new start = pos * 8
	if(start >= g_numberofitems) 
	{
		start = pos = g_menuPosition[id]
	}

	len += formatex(menuBody[len], sizeof menuBody - 1 - len, "%L", LANG_SERVER, "TITLE_MENU_SHOP", get_user_xp(id), get_user_max_level(id))
	
	new end = start + 8
	new keys = MENU_KEY_0

	if(end > g_numberofitems) 
	{
		end = g_numberofitems
	}
	
	new b = 0
	for(new a = start; a < end; ++a) 
	{
		new i = a + 1
		new money

		money = get_user_xp(id)

		if( money < g_itemcost[i] ) 

		{

			if( g_PlayerItem[id][i] ) 

			{

				len += formatex(menuBody[len], sizeof menuBody - 1 - len,"%L", id, "INACTIVE_MENU_SHOP_BOUGHT", ++b, g_itemname[i], g_itemcost[i])

			}

			else

			{

				len += formatex(menuBody[len], sizeof menuBody - 1 - len,"%L", id, "INACTIVE_MENU_SHOP", ++b, g_itemname[i], g_itemcost[i])

			}

		} 

		else if( g_PlayerItem[id][i] ) 

		{
			keys |= (1<<b)
			

			len += formatex(menuBody[len], sizeof menuBody - 1 - len,"%L", id, "INACTIVE_MENU_SHOP_BOUGHT", ++b, g_itemname[i], g_itemcost[i])

		} 

		else 

		{

			keys |= (1<<b)



			len += formatex(menuBody[len], sizeof menuBody - 1 - len,"%L", id, "ACTIVE_MENU_SHOP", ++b, g_itemname[i], g_itemcost[i])

		}

	}

	if(end != g_numberofitems)
	{
		len += formatex(menuBody[len], sizeof menuBody - 1 - len, "^n\r9. \w%L\r^n0. \w%L", id, "NEXT_MENU", id, pos ? "BACK_MENU" : "EXIT_MENU")
		keys |= MENU_KEY_9
	}
	else
	{
		len += formatex(menuBody[len], sizeof menuBody - 1 - len, "^n\r0. \w%L", id, pos ? "BACK_MENU" : "EXIT_MENU")
	}
	
	show_menu(id, keys, menuBody, -1, "Unlocks Shop")
}
public action_item_upgrades(id, key)
{
	switch(key) 
	{
		case 8: display_item_upgrades(id, ++g_menuPosition[id]);
		case 9: display_item_upgrades(id, --g_menuPosition[id]);
		default:
		{
			if(!is_user_alive(id)) 
			{
				return PLUGIN_HANDLED;
			}
			
			++key
			new money
			new plugin_id = g_itemindex[g_menuPosition[id] * 8 + key]
			new item_id = g_menuPosition[id] * 8 + key
			new func = get_func_id("gxm_item_enabled", plugin_id)

			money = get_user_xp(id)
			new cost = g_itemcost[item_id]

			if(money >= cost)
			{
				callfunc_begin_i(func, plugin_id)
				callfunc_push_int(id)
				callfunc_end()

				g_PlayerItem[id][item_id] = true

				new overall = money - cost
				set_user_xp(id, overall)

				client_printcolor(id, "/yItem Bought Successfully, Item: /g%s.", g_itemname[item_id])
				client_printcolor(id, "/yDescription:/g%s.", g_itemdesc[item_id])
				display_item_upgrades(id, g_menuPosition[id]);
			}
		}
	}
	return PLUGIN_HANDLED;
}

public register_item_gxm(item_index, item_name[], item_desc[], item_cost)
{
	if(g_numberofitems == MAX_UNLOCKS)
	{
		return -2
	}
	
	g_numberofitems++
	g_itemindex[g_numberofitems] = item_index
	format(g_itemname[g_numberofitems], MAX_UNLOCKS_NAME_SIZE, item_name)
	format(g_itemdesc[g_numberofitems], MAX_UNLOCKS_DESC_SIZE, item_desc)
	g_itemcost[g_numberofitems] = item_cost
	
	return g_numberofitems
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
