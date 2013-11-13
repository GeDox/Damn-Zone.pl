  
    #include <amxmodx>
    #include <orpheu>

    new OrpheuFunction:HandleFuncNETQueuePacket;
    new OrpheuFunction:HandleFuncConPrintf;

    new OrpheuHook:HandleHookConPrintf;

    public plugin_init()
    {
        register_plugin( "Ban NET Packet Spammer", "1.0.0", "Arkshine" );
        
        HandleFuncNETQueuePacket = OrpheuGetFunction( "NET_QueuePacket" );
        HandleFuncConPrintf      = OrpheuGetFunction( "Con_Printf" );
        
        OrpheuRegisterHook( HandleFuncNETQueuePacket, "NET_QueuePacket_Pre", OrpheuHookPre );
        OrpheuRegisterHook( HandleFuncNETQueuePacket, "NET_QueuePacket_Post", OrpheuHookPost );
    }   

    public NET_QueuePacket_Pre()
    {
        HandleHookConPrintf = OrpheuRegisterHook( HandleFuncConPrintf, "Con_Printf" );
    }

    public Con_Printf( const fmt[], const arg[] )
    {
        static const message[] = "Oversize packet from";
        
        if( contain( fmt, message ) > 0 )
        {
            new ip[ 16 ];
            copyc( ip, charsmax( ip ), arg, ':' );
            
            server_cmd( "addip 0 ^"%s^"", ip );
            server_exec();
        }
    }

    public NET_QueuePacket_Post()
    {
        OrpheuUnregisterHook( HandleHookConPrintf );
    }