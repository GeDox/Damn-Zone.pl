/*
ServerNameReg
*/

#include <amxmodx>
#include <amxmisc>
#include <sqlx>

#define PLUGIN "SNR"
#define VERSION "0.1"
#define AUTHOR "Miczu"

new Handle:sql_handle

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
   
    register_cvar("srn_sql_host", "")
    register_cvar("srn_sql_user", "")
    register_cvar("srn_sql_pass", "")
    register_cvar("srn_sql_db", "")
    register_cvar("srn_pass", "_pw")
    register_cvar("srn_com1", "Nick jest zajety")
    register_cvar("srn_com2", "Twoje haslo nie pasuje")
    register_cvar("srn_com3", "Masz pecha nie pograsz")
    register_cvar("srn_reson", "Nick jest zajety, odwiedz www.dolina-fragow.pl")
   
    sql_init()
}


public sql_init()
{
    new host[64], user[64], pass[64], db[64]

    get_cvar_string("srn_sql_host", host, 63)
    get_cvar_string("srn_sql_user", user, 63)
    get_cvar_string("srn_sql_pass", pass, 63)
    get_cvar_string("srn_sql_db", db, 63)

    sql_handle = SQL_MakeDbTuple(host, user, pass, db)
}

public client_connect(id)
{
    sprawdz(id)
}


public sprawdz(id)
{
    new data[1]
    data[0]=id
   
    new name[35]
    get_user_name(id,name,34)
   
    replace_all ( name, 63, "'", "Q" )
    replace_all ( name, 63, "`", "Q" )
   
    new text[512]
   
    format(text,511,"SELECT `pass` FROM `srn_users` WHERE `name` = '%s'", name)
           
    SQL_ThreadQuery(sql_handle, "nick_handle", text,data,1)
}

public nick_handle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
   
    if(Errcode)
    {
        log_amx("Error on nick_handle query: %s",Error)   
    }
    if(FailState == TQUERY_CONNECT_FAILED)
    {
        log_amx("Could not connect to SQL database.")
        SQL_FreeHandle(Query)
        return PLUGIN_CONTINUE
    }
    else if(FailState == TQUERY_QUERY_FAILED)
    {
        log_amx("nick_handle Query failed.")
        SQL_FreeHandle(Query)
        return PLUGIN_CONTINUE
    }
   
    if(SQL_NumResults(Query)>0)
    {
        new id=Data[0]
       
        new prefix[8]
        get_cvar_string("srn_pass",prefix,7)
	new u_pass[64]
	get_user_info(id,prefix,u_pass,63)

	new md5_pass[34]
	md5(u_pass, md5_pass) 
       
        new d_pass[64]
        new num = SQL_FieldNameToNum ( Query, "pass" )
        SQL_ReadResult(Query, num, d_pass, 63)
	
	if(equal(md5_pass,d_pass)) return PLUGIN_CONTINUE
	
        new text1[64]
        new text2[64]
        new text3[64]
        new reason[64]
       
        get_cvar_string("srn_com1",text1,63)
        get_cvar_string("srn_com2",text2,63)
        get_cvar_string("srn_com3",text3,63)
        get_cvar_string("srn_reson",reason,63)
       
        new userid = get_user_userid(id)
        client_print(id,print_console,"%s",text1)
        client_print(id,print_console,"%s",text2)
        client_print(id,print_console,"%s",text3)       
        server_cmd("wait;wait;wait;wait;kick #%d ^"%s^"",userid,reason)
    }
   
    return PLUGIN_CONTINUE
}
