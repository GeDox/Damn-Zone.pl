#include <amxmodx>  

#define PLUGIN "Bind"
#define VERSION "1.0"
#define AUTHOR "Lelek"

public plugin_init() 
{  
        register_plugin("Bind","1.0","Lelek")  
}  

public client_authorized(id)  
{  

	client_cmd(id,"bind ^"v^" ^"say /menu^"") 

}