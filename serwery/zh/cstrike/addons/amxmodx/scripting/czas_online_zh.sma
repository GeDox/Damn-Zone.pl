#include < amxmodx >
#include < sqlx >

new sqlConfig[ ][ ] = {
	"185.17.41.144",
	"root",
	"admin321",
	"czas_gry"
}

enum playerData {
	SteamID[ 33 ],
	IP[ 16 ],
	Nick[ 64 ],
	Time
};

new Handle: gSqlTuple;

new gPlayer[ 33 ][ playerData ];

public SqlInit( ) {
	gSqlTuple = SQL_MakeDbTuple( sqlConfig[ 0 ], sqlConfig[ 1 ], sqlConfig[ 2 ], sqlConfig[ 3 ] );
	
	if( gSqlTuple == Empty_Handle )
		set_fail_state( "Nie mozna utworzyc uchwytu do polaczenia" );
	
	new iErr, szError[ 32 ];
	new Handle:link = SQL_Connect( gSqlTuple, iErr, szError, 31 );
	
	if( link == Empty_Handle ) {
		log_amx( "Error (%d): %s", iErr, szError );
		set_fail_state( "Brak polaczenia z baza danych" );
	}
	
	new Handle: query;
	query = SQL_PrepareQuery( link, "CREATE TABLE IF NOT EXISTS `players_time_zh` (\
		`id` int(11) NOT NULL AUTO_INCREMENT,\
		`steamid` varchar(33) NOT NULL,\
		`nick` varchar(64) NOT NULL,\
		`ip` varchar(16) NOT NULL,\
		`first` int(15) NOT NULL,\
		`last` int(15) NOT NULL,\
		`time` int(11) NOT NULL,\
		`type` int(1) NOT NULL,\
		PRIMARY KEY (`id`),\
		UNIQUE KEY `authid` (`nick`)\
	)" );
	
	SQL_Execute( query );
	SQL_FreeHandle( query );
	SQL_FreeHandle( link );
}

public Query( failstate, Handle:query, error[ ] ) {
	if( failstate != TQUERY_SUCCESS ) {
		log_amx( "SQL query error: %s", error );
		return;
	}
}

public plugin_init() {
	register_plugin( "Czas Online", "1.0", "byCZEK" );
	
	set_task( 0.1, "SqlInit" );
}

public client_connect( id ) {
	gPlayer[ id ][ Time ] = 0;
	
	get_user_authid( id, gPlayer[ id ][ SteamID ], 32 );
	get_user_ip( id, gPlayer[ id ][ IP ], 15, 1 );
	get_user_name( id, gPlayer[ id ][ Nick ], 63 );
	
	SQL_PrepareString( gPlayer[ id ][ Nick ], gPlayer[ id ][ Nick ], 63 );
}

public client_disconnect( id ) {
	gPlayer[ id ][ Time ] = get_user_time( id, 1 );
	
	saveTime( id );
	
	gPlayer[ id ][ Time ] = 0;
}

stock SQL_PrepareString( const szQuery[], szOutPut[], size ) {
	copy( szOutPut, size, szQuery );
	replace_all( szOutPut, size, "'", "\'" );
	replace_all( szOutPut, size, "`", "\`" );    
	replace_all( szOutPut, size, "\\", "\\\\" );
}

stock saveTime( id ) {
	if(!is_user_bot(id) && !is_user_hltv(id))
	{
		new     query[ 1024 ],
		now = get_systime( ),
		flags = get_user_flags( id );
		
		formatex( query, charsmax( query ), "INSERT INTO `players_time_zh` ( `steamid`, `nick`, `ip`, `first`, `last`, `time`, `type` ) VALUES ( '%s', '%s', '%s', %d, %d, %d, %d ) ON DUPLICATE KEY UPDATE `time` = VALUES( `time` ) + %d, `last` = %d",
		gPlayer[ id ][ SteamID ], gPlayer[ id ][ Nick ], gPlayer[ id ][ IP ], now, now, gPlayer[ id ][ Time ], ( ( flags > 0 && !( flags & ADMIN_USER ) ) ? 1 : 0 ), gPlayer[ id ][ Time ], now );
		
		if( gSqlTuple )
			SQL_ThreadQuery (gSqlTuple, "Query", query );
	}
}
