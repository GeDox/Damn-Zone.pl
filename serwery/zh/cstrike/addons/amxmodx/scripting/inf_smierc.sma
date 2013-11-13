#include <amxmodx>
#include <colorchat>
#include <fakemeta>

#define PLUGIN "Info po smierci"
#define VERSION "1.0"
#define AUTHOR "DarkGL"

#define MAX 32
#define IsPlayer(%1) (1<=%1<=32)

new bool:bCan[MAX+1]
new pTime

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	pTime = register_cvar("info_smierci_czas","5");
	
	register_event("DeathMsg", "DeathMsg", "a")
	
	//register_clcmd("say","sayHandle")
	register_clcmd("say_team","sayHandle")
	
	register_forward(FM_Voice_SetClientListening, "Forward_SetClientListening");
}

public sayHandle(id){
	if(!bCan[id]){
		return PLUGIN_CONTINUE;
	}
	new szTmp[128],szPrint[190],szName[64];
	
	read_argv(1,szTmp,charsmax(szTmp));
	trim(szTmp)
	
	get_user_name(id,szName,charsmax(szName));
	
	formatex(szPrint,charsmax(szPrint),"[Info od %s] ^x01 %s",szName,szTmp);
	
	ColorChat(id,GREEN,szPrint);
	
	for(new i = 1;i<=MAX;i++){
		if(!is_user_alive(i) || get_user_team(i) != get_user_team(id)){
			continue;
		}
		ColorChat(i,GREEN,szPrint);
	}
	bCan[id] = false;
	return PLUGIN_HANDLED;
}

public DeathMsg()
{	
	new vid = read_data(2)
	
	if(IsPlayer(vid) && !is_user_alive(vid)){
		bCan[vid] = true;
		remove_task(vid);
		set_task(float(get_pcvar_num(pTime)),"stopInfo",vid)
	}
}

public client_connect(id){
	bCan[id] = false;
}

public stopInfo(id){
	if(is_user_connected(id)){
		client_cmd(id,"-voicerecord")
	}
	bCan[id] = false;
}

public Forward_SetClientListening( iReceiver, iSender, bool:bListen ) {
	if(!is_user_connected(iSender) || !bCan[iSender] || get_user_team(iSender) != get_user_team(iReceiver) ){
		return FMRES_IGNORED;
	}
	
	engfunc(EngFunc_SetClientListening, iReceiver, iSender, true);
	forward_return(FMV_CELL, true)
	return FMRES_SUPERCEDE
}
