#include <amxmodx>
#include <orpheu>
#define PLUGIN "Anti flood"
#define VERSION "1.0"
#define AUTHOR "kanagava"

new time_last_conn
new ip_old[256]
new ip_warn[256]
new Msg[256]
new OrpheuHook:handlePrintf
new warn
new old_time
new registered
public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    server_cmd("sv_logecho 1")
    server_cmd("log on")
    set_task(5.0, "regfunctions")  
} 

public regfunctions()
{
    OrpheuRegisterHook(OrpheuGetFunction("SV_ConnectClient"),"OnSV_ConnectClientPre", OrpheuHookPre)
    OrpheuRegisterHook(OrpheuGetFunction("SV_ConnectClient"),"OnSV_ConnectClientPost", OrpheuHookPost)
}

public OrpheuHookReturn:OnSV_ConnectClientPre()
{
	registered=0
	if(get_systime()-old_time <= 2)
   {
		handlePrintf = OrpheuRegisterHook( OrpheuGetFunction( "Con_Printf" ), "Con_Printf" , OrpheuHookPre);
		registered=1
   }
   old_time=get_systime()
   return OrpheuIgnored;
}


public OrpheuHookReturn:OnSV_ConnectClientPost()
{
   if(registered)
   {
		OrpheuUnregisterHook(handlePrintf)
	}
   return OrpheuIgnored;
}



public OrpheuHookReturn:Con_Printf(const a[], const message[] )
{
	registered=1
    if (containi(message,"^" connected, address ^"")!=-1)
    {
        new len=255
        new temp_right[256],temp_left[256],conn_ip[256]
        formatex( Msg,charsmax( Msg ),"%s", message );
        split(Msg, temp_left, len, temp_right, len, "^" connected, address ^"")
        strtok(temp_right, conn_ip, len, temp_right, len, ':')
        if (equal(conn_ip,ip_old) && !equal(conn_ip,"") && ((get_systime()-time_last_conn)<2))
        {
            warn=warn+1
            if(warn>2 && equal(conn_ip,ip_warn))
            {
                log_amx("[NOFLOOD] Connection flood detected from ip %s",ip_old)
                server_cmd("addip 120.0 %s",ip_old)
            }
            ip_warn=conn_ip
        }
        else
        {
            warn=0
        }
        ip_old=conn_ip
        time_last_conn=get_systime()
    }
    return OrpheuIgnored;
} 