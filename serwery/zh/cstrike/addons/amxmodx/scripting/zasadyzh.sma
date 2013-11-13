#include <amxmodx>
#include <amxmisc>
#include <colorchat>

#define PLUGIN "zasady"
#define VERSION "1.0.0"
#define AUTHOR "Endru"


public plugin_init()

{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /zasady", "motd1")
	register_clcmd("say_team zasady", "motd1")
	set_task(45.0, "reklama", _, _, _, "b");
}

public motd1(id)

{
	show_motd( id,"zasady.txt","Zasady")
}

public reklama()

{
	ColorChat(0,GREEN,"[INFO]^x01 Aby zobaczyæ zasady serwera wpisz /zasady")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
