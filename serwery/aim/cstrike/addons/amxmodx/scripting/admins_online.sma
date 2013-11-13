#include <amxmodx>

/*---------------EDIT ME------------------*/
#define ADMIN_CHECK ADMIN_KICK

static const COLOR[] = "^x04" //green
/*----------------------------------------*/

new gmsgSayText

public plugin_init() {
    register_plugin("Admin Check", "1.51", "OneEyed")
    gmsgSayText = get_user_msgid("SayText")
    register_clcmd("say", "handle_say")
}

public handle_say(id) {
    new said[192]
    read_args(said,192)
    if( ( containi(said, "jest") != -1 && containi(said, "admin") != -1 ) || contain(said, "/admin") != -1 )
        set_task(0.2,"print_msg",id)
    if( containi(said, "cziter") != -1 || containi(said, "cheater") != -1 )
        set_task(0.2,"print_msg1",id)
    return PLUGIN_CONTINUE
}

public print_msg(user) 
{
    new message[256], len
    len += format(message[len], 255-len, "%s Jestes obserwowany! Mamy twoje IP oraz SteamID!", COLOR)
    print_message(user, message)    
}
public print_msg1(user) 
{
    new message[256], len
    len += format(message[len], 255-len, "%s Zauwazyles Cheatera? Nagraj mu demko i zapisz jego IP (uzyj w konsoli amx_ip)", COLOR)
    print_message(user, message)    
}
print_message(id, msg[]) {
    message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
    write_byte(id)
    write_string(msg)
    message_end()
}  
