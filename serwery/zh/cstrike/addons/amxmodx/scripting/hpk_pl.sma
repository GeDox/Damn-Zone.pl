/* AMX Mod script
* 
* (c) 2002-2003, DynAstY translated by Adrix
* This file is provided as is (no warranties).
*  Opis i instalacja na www.cs.bitmar.net 
* Players with immunity won't be checked
*/

#include <amxmodx>

new HIGHPING_MAX = 120 // Maksymalny dopuszczalny ping u gracza.
new HIGHPING_TIME = 10  // Czas po którym osoba z wysokim pingiem jest wyrzucana.
new HIGHPING_TESTS = 3  // Ilosc sprawdzen zanim cos zrobi.

new iNumTests[33]

public plugin_init() {
	register_plugin("High Ping Kicker PL","1.2.0","DynAstY translated by Adrix")
	if (HIGHPING_TIME < 15) HIGHPING_TIME = 15
	if (HIGHPING_TESTS < 4) HIGHPING_TESTS = 4
	return PLUGIN_CONTINUE
}

public client_disconnect(id) {
	remove_task(id)
	return PLUGIN_CONTINUE
}
	
public client_putinserver(id) {
	iNumTests[id] = 0
	if (!is_user_bot(id)) {
		new param[1]
		param[0] = id
		set_task(30.0, "showWarn", id, param, 1)
	}
	return PLUGIN_CONTINUE
}

kickPlayer(id) {
	new name[32]
	get_user_name(id, name, 31)
	new uID = get_user_userid(id)
	server_cmd("banid 1 #%d", uID)
	client_cmd(id, "echo ^"[HPK] Przykro mi, masz zbyt wysoki ping. Sprobuj pozniej...^"; disconnect")
	client_print(0, print_chat, "[HPK] %s zostal rozlaczony za wysoki ping!", name)
	return PLUGIN_CONTINUE
} 

public checkPing(param[]) {
	new id = param[0]
	if ((get_user_flags(id) & ADMIN_IMMUNITY) || (get_user_flags(id) & ADMIN_RESERVATION)) {
		remove_task(id)
		client_print(id, print_chat, "[HPK] Sprawdzanie pingu wylaczone, poniewaz masz immunited...")
		return PLUGIN_CONTINUE
	}
	new p, l
	get_user_ping(id, p, l)
	if (p > HIGHPING_MAX)
		++iNumTests[id]
	else
		if (iNumTests[id] > 0) --iNumTests[id]
	if (iNumTests[id] > HIGHPING_TESTS)
		kickPlayer(id)
	return PLUGIN_CONTINUE
}

public showWarn(param[]) {
	client_print(param[0], print_chat, "[HPK] Gracz %dms zostal wyrzucony z powodu wysokiego pingu !", HIGHPING_MAX)
	set_task(float(HIGHPING_TIME), "checkPing", param[0], param, 1, "b")
	return PLUGIN_CONTINUE
}

