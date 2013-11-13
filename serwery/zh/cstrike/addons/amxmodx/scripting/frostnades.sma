
 /*-------------------
  INCLUDES AND DEFINES
 --------------------*/

 #include <amxmodx>
 #include <fun>
 #include <engine>
 #include <fakemeta>
 #include <cstrike>

 new hasFrostNade[33];
 new isChilled[33];
 new isFrozen[33];

 new novaDisplay[33];
 new Float:oldSpeed[33];

 new glassGibs;
 new trailSpr;
 new smokeSpr;
 new exploSpr;

 #define FROST_RADIUS	240.0
 #define FROST_R	0
 #define FROST_G	206
 #define FROST_B	209

 #define TASK_REMOVE_CHILL	200
 #define TASK_REMOVE_FREEZE	250

 /*----------------
  LOADING FUNCTIONS
 -----------------*/

 // 3, 2, 1: blastoff!
 public plugin_init()
 {
	register_plugin("FrostNades","0.12b","Avalanche");

	register_cvar("fn_on","1");
	register_cvar("fn_hitself","1");
	register_cvar("fn_los","0");

	register_cvar("fn_maxdamage","20.0");
	register_cvar("fn_mindamage","1.0");

	register_cvar("fn_override","1");
	register_cvar("fn_price","300");

	register_cvar("fn_chill_maxchance","100");
	register_cvar("fn_chill_minchance","100");
	register_cvar("fn_chill_duration","8");
	register_cvar("fn_chill_speed","60");

	register_cvar("fn_freeze_maxchance","100");
	register_cvar("fn_freeze_minchance","40");
	register_cvar("fn_freeze_duration","4");

	register_clcmd("say /fn","buy_frostnade",-1);
	register_clcmd("say_team /fn","buy_frostnade",-1);
	register_clcmd("say /frostnade","buy_frostnade",-1);
	register_clcmd("say_team /frostnade","buy_frostnade",-1);

	register_event("DeathMsg","event_deathmsg","a");
	register_event("CurWeapon","event_curweapon","b","1=1");
	register_forward(FM_SetModel,"fw_setmodel");
	register_think("grenade","think_grenade");

	register_logevent("event_roundend",2,"0=World triggered","1=Round_End");
 }

 // get in the cache and be quiet!!
 public plugin_precache() {
	precache_model("models/frostnova.mdl");
	glassGibs = precache_model("models/glassgibs.mdl");

	precache_sound("warcraft3/frostnova.wav"); // grenade explodes
	precache_sound("warcraft3/impalehit.wav"); // player is frozen
	precache_sound("warcraft3/impalelaunch1.wav"); // frozen wears off
	precache_sound("player/pl_duct2.wav"); // player is chilled

	trailSpr = precache_model("sprites/laserbeam.spr");
	smokeSpr = precache_model("sprites/steam1.spr");
	exploSpr = precache_model("sprites/shockwave.spr");
 }

 /*------------
  HOOK HANDLERS
 -------------*/

 // player wants to buy a grenade
 public buy_frostnade(id)
 {
	if(!get_cvar_num("fn_on"))
		return PLUGIN_CONTINUE;

	// can't buy while dead
	if(!is_user_alive(id))
		return PLUGIN_HANDLED;

	// no custom buy needed
	if(get_cvar_num("fn_override"))
		return PLUGIN_HANDLED;

	// not in a buyzone
	if(!cs_get_user_buyzone(id))
		return PLUGIN_HANDLED;

	// not enough money
	new money = cs_get_user_money(id);

	if(money < get_cvar_num("fn_price"))
	{
		client_print(id,print_center,"#Not_Enough_Money");
		return PLUGIN_HANDLED;
	}

	// already have a frost grenade
	if(hasFrostNade[id])
	{
		client_print(id,print_center,"#Cstrike_Already_Own_Weapon");
		return PLUGIN_HANDLED;
	}

	// already have a smoke grenade
	new weapons[32], num, i;
	get_user_weapons(id,weapons,num);

	for(i=0;i<num;i++)
	{
		if(weapons[i] == CSW_FLASHBANG)
		{
			client_print(id,print_center,"You already own a smoke grenade.");
			return PLUGIN_HANDLED;
		}
	}

	// gimme gimme
	hasFrostNade[id] = 1;
	give_item(id,"weapon_flashbang");
	cs_set_user_money(id,money - get_cvar_num("fn_price"));

	// display icon
	message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id);
	write_byte(1); // status (0=hide, 1=show, 2=flash)
	write_string("dmg_cold"); // sprite name
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	message_end();

	return PLUGIN_HANDLED;
 }

 // prethinking
 public client_PreThink(id)
 {
	if(!get_cvar_num("fn_on"))
		return;
	
	new CsTeams:userTeam = cs_get_user_team(id)
	if(userTeam == CS_TEAM_CT && !is_user_bot(id))
		return;

	// if they are frozen, make sure they don't move at all
	if(isFrozen[id])
	{
		// stop motion
		entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});

		new button = get_user_button(id), oldbuttons = entity_get_int(id,EV_INT_oldbuttons);
		new flags = entity_get_int(id,EV_INT_flags);

		// if are on the ground and about to jump, set the gravity too high to really do so
		if((button & IN_JUMP) && !(oldbuttons & IN_JUMP) && (flags & FL_ONGROUND))
			entity_set_float(id,EV_FL_gravity,999999.9); // I CAN'T STAND THE PRESSURE

		// otherwise, set the gravity so low that they don't fall
		else
			entity_set_float(id,EV_FL_gravity,0.000001); // 0.0 doesn't work
	}
 }

 // someone dies
 public event_deathmsg()
 {
	if(!get_cvar_num("fn_on"))
		return;

	new id = read_data(2);

	if(hasFrostNade[id])
	{
		hasFrostNade[id] = 0;
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id);
		write_byte(0); // status (0=hide, 1=show, 2=flash)
		write_string("dmg_cold"); // sprite name
		write_byte(FROST_R); // red
		write_byte(FROST_G); // green
		write_byte(FROST_B); // blue
		message_end();
	}

	if(isChilled[id])
		remove_chill(TASK_REMOVE_CHILL+id);

	if(isFrozen[id])
		remove_freeze(TASK_REMOVE_FREEZE+id);
 }

 // a player changes weapons 
 public event_curweapon(id)
 {
	if(!get_cvar_num("fn_on"))
		return;

	// flash icon if frost grenade is out
	if(hasFrostNade[id] && read_data(2) == CSW_FLASHBANG)
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id);
		write_byte(2); // status (0=hide, 1=show, 2=flash)
		write_string("dmg_cold"); // sprite name
		write_byte(FROST_R); // red
		write_byte(FROST_G); // green
		write_byte(FROST_B); // blue
		message_end();
	}
	else if(hasFrostNade[id])
	{
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},id);
		write_byte(1); // status (0=hide, 1=show, 2=flash)
		write_string("dmg_cold"); // sprite name
		write_byte(FROST_R); // red
		write_byte(FROST_G); // green
		write_byte(FROST_B); // blue
		message_end();
	}

	if(isChilled[id])
		chill_player(id);

	if(isFrozen[id])
		freeze_player(id);
 }

 // when a model is set
 public fw_setmodel(ent,model[])
 {
	if(get_cvar_num("fn_on") < 1 || !is_valid_ent(ent))
		return FMRES_IGNORED;

	// not a smoke grenade
	if(!equali(model,"models/w_flashbang.mdl"))
		return FMRES_IGNORED;

	// not yet thrown
	if(entity_get_float(ent,EV_FL_gravity) == 0.0)
		return FMRES_IGNORED;

	new owner = entity_get_edict(ent,EV_ENT_owner);

	// check to see if this isn't a frost grenade
	if(!get_cvar_num("fn_override") && !hasFrostNade[owner])
		return FMRES_IGNORED;

	// store team in the grenade
	entity_set_int(ent,EV_INT_team,get_user_team(owner));

	// hide icon
	if(hasFrostNade[owner])
	{
		hasFrostNade[owner] = 0;
		message_begin(MSG_ONE,get_user_msgid("StatusIcon"),{0,0,0},owner);
		write_byte(0); // status (0=hide, 1=show, 2=flash)
		write_string("dmg_cold"); // sprite name
		write_byte(FROST_R); // red
		write_byte(FROST_G); // green
		write_byte(FROST_B); // blue
		message_end();
	}

	// give it a blue glow and a blue trail
	set_rendering(ent,kRenderFxGlowShell,FROST_R,FROST_G,FROST_B);
	set_beamfollow(ent,10,10,FROST_R,FROST_G,FROST_B,100);

	// hack? flag to remember to track this grenade's think
	entity_set_int(ent,EV_INT_bInDuck,1);

	// track for when it will explode
	set_task(1.6,"grenade_explode",ent);

	return FMRES_IGNORED;
 }

 // think, grenade. think, damnit!
 public think_grenade(ent)
 {
	if(get_cvar_num("fn_on") < 1 || !is_valid_ent(ent))
		return PLUGIN_CONTINUE;

	// hack? not a smoke grenade, or at least not a popular one
	if(!entity_get_int(ent,EV_INT_bInDuck))
		return PLUGIN_CONTINUE;

	// stop it from exploding
	return PLUGIN_HANDLED;
 }

 // the round ends
 public event_roundend()
 {
	new i;
	for(i=1;i<=32;i++)
	{
		if(isChilled[i])
			remove_chill(TASK_REMOVE_CHILL+i);

		if(isFrozen[i])
			remove_freeze(TASK_REMOVE_FREEZE+i);
	}
 }

 /*-------------------
  OTHER MAIN FUNCTIONS
 --------------------*/

 // and boom goes the dynamite
 public grenade_explode(ent)
 {
	if(get_cvar_num("fn_on") < 1 || !is_valid_ent(ent))
		return;

	// make the smoke
	new origin[3], Float:originF[3];
	entity_get_vector(ent,EV_VEC_origin,originF);
	FVecIVec(originF,origin);

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(5); // TE_SMOKE
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_short(smokeSpr); // sprite
	write_byte(random_num(35,45)); // scale
	write_byte(5); // framerate
	message_end();

	// debug
	//show_xyz(origin,floatround(FROST_RADIUS));

	// explosion
	create_blast(origin);
	emit_sound(ent,CHAN_WEAPON,"warcraft3/frostnova.wav",1.0,ATTN_NORM,0,PITCH_NORM);

	// get grenade's owner
	new owner = entity_get_edict(ent,EV_ENT_owner);

	// get grenades team
	new nadeTeam = entity_get_int(ent,EV_INT_team);

	// collisions
	new player;
	while((player = find_ent_in_sphere(player,originF,FROST_RADIUS)) != 0)
	{
		// not a player, or a dead one
		if(!is_user_alive(player))
			continue;

		// don't hit teammates if friendlyfire is off, but don't count self as teammate
		if((!get_cvar_num("mp_friendlyfire") && nadeTeam == get_user_team(player)) && owner != player)
			continue;

		// don't hit self if the cvar is set
		if(owner == player && !get_cvar_num("fn_hitself"))
			continue;

		// if user was frozen this check
		new wasFrozen;

		// get this player's origin for calculations
		new Float:playerOrigin[3];
		entity_get_vector(player,EV_VEC_origin,playerOrigin);

		// check for line of sight
		if(get_cvar_num("fn_los"))
		{
			new Float:endPos[3];
			trace_line(ent,originF,playerOrigin,endPos);

			// no line of sight (end point not at player's origin)
			if(endPos[0] != playerOrigin[0] && endPos[1] != playerOrigin[1] && endPos[2] != playerOrigin[2])
				continue;
		}

		// calculate our odds
		new Float:chillChance = radius_calucation(playerOrigin,originF,FROST_RADIUS,get_cvar_float("fn_chill_maxchance"),get_cvar_float("fn_chill_minchance"));
		new Float:freezeChance = radius_calucation(playerOrigin,originF,FROST_RADIUS,get_cvar_float("fn_freeze_maxchance"),get_cvar_float("fn_freeze_minchance"));

		// deal damage
		if(get_cvar_float("fn_maxdamage") > 0.0)
		{
			new Float:damage = radius_calucation(playerOrigin,originF,FROST_RADIUS,get_cvar_float("fn_maxdamage"),get_cvar_float("fn_mindamage"));

			// half damage for friendlyfire
			if(nadeTeam == get_user_team(player))
				damage *= 0.5;

			// see if this will kill player
			if(floatround(entity_get_float(player,EV_FL_health)) - damage <= 0)
			{
				user_silentkill(player);
				make_deathmsg(owner,player,0,"frostgrenade");

				// update score
				if(nadeTeam == get_user_team(player))
				{
					set_user_frags(owner,get_user_frags(owner)-1);

					if(get_cvar_num("mp_tkpunish"))
						cs_set_user_tked(owner,1,0);
				}
				else
					set_user_frags(owner,get_user_frags(owner)+1);

				// update scoreboard
				message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
				write_byte(owner);
				write_short(get_user_frags(owner));
				write_short(cs_get_user_deaths(owner));
				write_short(0);
				write_short(get_user_team(owner));
				message_end();

				message_begin(MSG_BROADCAST,get_user_msgid("ScoreInfo"));
				write_byte(player);
				write_short(get_user_frags(player));
				write_short(cs_get_user_deaths(player));
				write_short(0);
				write_short(get_user_team(player));
				message_end();

				continue;
			}

			fakedamage(player,"frostgrenade",damage,3);
		}

		// check for freeze
		if(random_num(1,100) <= floatround(freezeChance) && !isFrozen[player])
		{
			wasFrozen = 1;
			freeze_player(player);
			isFrozen[player] = 1;

			emit_sound(player,CHAN_BODY,"warcraft3/impalehit.wav",1.0,ATTN_NORM,0,PITCH_HIGH);
			set_task(get_cvar_float("fn_freeze_duration"),"remove_freeze",TASK_REMOVE_FREEZE+player);

			// if they don't already have a frostnova
			if(!is_valid_ent(novaDisplay[player]))
			{
				// create the entity
				new nova = create_entity("info_target");

				// give it a size
				new Float:maxs[3], Float:mins[3];
				maxs = Float:{ 8.0, 8.0, 4.0 };
				mins = Float:{ -8.0, -8.0, -4.0 };
				entity_set_size(nova,mins,maxs);

				// random orientation
				new Float:angles[3];
				angles[1] = float(random_num(0,359));
				entity_set_vector(nova,EV_VEC_angles,angles);

				// put it at their feet
				new Float:playerMins[3], Float:novaOrigin[3];
				entity_get_vector(player,EV_VEC_mins,playerMins);
				entity_get_vector(player,EV_VEC_origin,novaOrigin);
				novaOrigin[2] += playerMins[2];
				entity_set_vector(nova,EV_VEC_origin,novaOrigin);

				// mess with the model
				entity_set_model(nova,"models/frostnova.mdl");
				entity_set_float(nova,EV_FL_animtime,1.0)
				entity_set_float(nova,EV_FL_framerate,1.0)
				entity_set_int(nova,EV_INT_sequence,0);
				set_rendering(nova,kRenderFxNone,FROST_R,FROST_G,FROST_B,kRenderTransColor,100);

				// remember this
				novaDisplay[player] = nova;
			}
		}

		// check for chill
		if(random_num(1,100) <= floatround(chillChance) && !isChilled[player])
		{
			chill_player(player);
			isChilled[player] = 1;

			// don't play sound if player just got frozen,
			// reason being it will be overriden and I like the other sound better
			if(!wasFrozen)
				emit_sound(player,CHAN_BODY,"player/pl_duct2.wav",1.0,ATTN_NORM,0,PITCH_LOW);

			set_task(get_cvar_float("fn_chill_duration"),"remove_chill",TASK_REMOVE_CHILL+player);
		}
	}

	// get rid of the old grenade
	remove_entity(ent);
 }

 // apply the effects of being chilled
 public chill_player(id)
 {
	// don't mess with their speed if they are frozen
	if(isFrozen[id])
		set_user_maxspeed(id,1.0); // 0.0 doesn't work
	else
	{
		new speed = floatround(get_user_maxspeed(id) * (get_cvar_float("fn_chill_speed") / 100.0));
		set_user_maxspeed(id,float(speed));
	}

	// add a blue tint to their screen
	message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
	write_short(~0); // duration
	write_short(~0); // hold time
	write_short(0x0004); // flags: FFADE_STAYOUT, ignores the duration, stays faded out until new ScreenFade message received
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // alpha
	message_end();

	// make them glow and have a trail
	set_user_rendering(id,kRenderFxGlowShell,FROST_R,FROST_G,FROST_B,kRenderNormal,1);

	// bug fix
	if(!isFrozen[id])
		set_beamfollow(id,30,8,FROST_R,FROST_G,FROST_B,100);
 }

 // apply the effects of being frozen
 public freeze_player(id)
 {
	new Float:speed = get_user_maxspeed(id);

	// remember their old speed for when they get unfrozen,
	// but don't accidentally save their frozen speed
	if(speed > 1.0 && speed != oldSpeed[id])
	{
		// save their unchilled speed
		if(isChilled[id])
		{
			new speed = floatround(get_user_maxspeed(id) / (get_cvar_float("fn_chill_speed") / 100.0));
			oldSpeed[id] = float(speed);
		}
		else
			oldSpeed[id] = speed;
	}

	// stop them from moving
	set_user_maxspeed(id,1.0); // 0.0 doesn't work
	entity_set_vector(id,EV_VEC_velocity,Float:{0.0,0.0,0.0});
	entity_set_float(id,EV_FL_gravity,0.000001); // 0.0 doesn't work
 }

 // a player's chill runs out
 public remove_chill(taskid)
 {
	remove_task(taskid);
	new id = taskid - TASK_REMOVE_CHILL;

	// no longer chilled
	if(!isChilled[id])
		return;

	isChilled[id] = 0;

	// only apply effects to this player if they are still connected
	if(is_user_connected(id))
	{
		// clear screen fade
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id);
		write_short(0); // duration
		write_short(0); // hold time
		write_short(0); // flags
		write_byte(0); // red
		write_byte(0); // green
		write_byte(0); // blue
		write_byte(0); // alpha
		message_end();

		// restore speed and remove glow
		new speed = floatround(get_user_maxspeed(id) / (get_cvar_float("fn_chill_speed") / 100.0));
		set_user_maxspeed(id,float(speed));
		set_user_rendering(id);

		// kill their trail
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(99); // TE_KILLBEAM
		write_short(id);
		message_end();
	}
 }

 // a player's freeze runs out
 public remove_freeze(taskid)
 {
	remove_task(taskid);
	new id = taskid - TASK_REMOVE_FREEZE;

	// no longer frozen
	if(!isFrozen[id])
		return;

	// if nothing happened to the model
	if(is_valid_ent(novaDisplay[id]))
	{
		// get origin of their frost nova
		new origin[3], Float:originF[3];
		entity_get_vector(novaDisplay[id],EV_VEC_origin,originF);
		FVecIVec(originF,origin);

		// add some tracers
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(14); // TE_IMPLOSION
		write_coord(origin[0]); // x
		write_coord(origin[1]); // y
		write_coord(origin[2] + 8); // z
		write_byte(64); // radius
		write_byte(10); // count
		write_byte(3); // duration
		message_end();

		// add some sparks
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(9); // TE_SPARKS
		write_coord(origin[0]); // x
		write_coord(origin[1]); // y
		write_coord(origin[2]); // z
		message_end();

		// add the shatter
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
		write_byte(108); // TE_BREAKMODEL
		write_coord(origin[0]); // x
		write_coord(origin[1]); // y
		write_coord(origin[2] + 24); // z
		write_coord(16); // size x
		write_coord(16); // size y
		write_coord(16); // size z
		write_coord(random_num(-50,50)); // velocity x
		write_coord(random_num(-50,50)); // velocity y
		write_coord(25); // velocity z
		write_byte(10); // random velocity
		write_short(glassGibs); // model
		write_byte(10); // count
		write_byte(25); // life
		write_byte(0x01); // flags: BREAK_GLASS
		message_end();

		// play a sound and remove the model
		emit_sound(novaDisplay[id],CHAN_BODY,"warcraft3/impalelaunch1.wav",1.0,ATTN_NORM,0,PITCH_LOW);
		remove_entity(novaDisplay[id]);
	}

	isFrozen[id] = 0;
	novaDisplay[id] = 0;

	// only apply effects to this player if they are still connected
	if(is_user_connected(id))
	{
		// restore gravity
		entity_set_float(id,EV_FL_gravity,1.0);

		// if they are still chilled, set the speed rightly so. otherwise, restore it to complete regular.
		if(isChilled[id])
		{
			set_beamfollow(id,30,8,FROST_R,FROST_G,FROST_B,100); // bug fix

			new speed = floatround(oldSpeed[id] * (get_cvar_float("fn_chill_speed") / 100.0));
			set_user_maxspeed(id,float(speed));
		}
		else
			set_user_maxspeed(id,oldSpeed[id]);
	}

	oldSpeed[id] = 0.0;
 }

 /*----------------
  UTILITY FUNCTIONS
 -----------------*/

 // my own radius calculations...
 //
 // 1. figure out how far a player is from a center point
 // 2. figure the percentage this distance is of the overall radius
 // 3. find a value between maxVal and minVal based on this percentage
 //
 // example: origin1 is 96 units away from origin2, and radius is 240.
 // this player is then 60% towards the center from the edge of the sphere.
 // let us say maxVal is 100.0 and minVal is 25.0. 60% progression from minimum
 // to maximum becomes 70.0. tada!
 public Float:radius_calucation(Float:origin1[3],Float:origin2[3],Float:radius,Float:maxVal,Float:minVal)
 {
	if(maxVal <= 0.0)
		return 0.0;

	if(minVal >= maxVal)
		return minVal;

	new Float:percent;

	// figure out how far away the points are
	new Float:distance = vector_distance(origin1,origin2);

	// if we are close enough, assume we are at the center
	if(distance < 40.0)
		return maxVal;

	// otherwise, calculate the distance range
	else
		percent = 1.0 - (distance / radius);

	// we have the technology...
	return minVal + (percent * (maxVal - minVal));
 }

 // displays x y z axis
 public show_xyz(origin[3],radius)
 {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(0); // TE_BEAMPOINTS
	write_coord(origin[0]); // start x
	write_coord(origin[1]); // starty
	write_coord(origin[2] + 1); // start z
	write_coord(origin[0] + radius); // end x
	write_coord(origin[1]); // end y
	write_coord(origin[2] + 1); // end z
	write_short(trailSpr); // sprite
	write_byte(0); // starting frame
	write_byte(0); // framerate
	write_byte(100); // life
	write_byte(8); // line width
	write_byte(0); // noise
	write_byte(255); // r
	write_byte(0); // g
	write_byte(0); // b
	write_byte(200); // brightness
	write_byte(0); // scroll speed
	message_end();

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(0); // TE_BEAMPOINTS
	write_coord(origin[0]); // start x
	write_coord(origin[1]); // starty
	write_coord(origin[2] + 1); // start z
	write_coord(origin[0]); // end x
	write_coord(origin[1] + radius); // end y
	write_coord(origin[2] + 1); // end z
	write_short(trailSpr); // sprite
	write_byte(0); // starting frame
	write_byte(0); // framerate
	write_byte(100); // life
	write_byte(8); // line width
	write_byte(0); // noise
	write_byte(0); // r
	write_byte(255); // g
	write_byte(0); // b
	write_byte(200); // brightness
	write_byte(0); // scroll speed
	message_end();

	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(0); // TE_BEAMPOINTS
	write_coord(origin[0]); // start x
	write_coord(origin[1]); // starty
	write_coord(origin[2]); // start z
	write_coord(origin[0]); // end x
	write_coord(origin[1]); // end y
	write_coord(origin[2] + radius); // end z
	write_short(trailSpr); // sprite
	write_byte(0); // starting frame
	write_byte(0); // framerate
	write_byte(100); // life
	write_byte(8); // line width
	write_byte(0); // noise
	write_byte(0); // r
	write_byte(0); // g
	write_byte(255); // b
	write_byte(200); // brightness
	write_byte(0); // scroll speed
	message_end();
 }

 // give an entity a trail
 public set_beamfollow(ent,life,width,r,g,b,brightness)
 {
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(22); // TE_BEAMFOLLOW
	write_short(ent); // ball
	write_short(trailSpr); // sprite
	write_byte(life); // life
	write_byte(width); // width
	write_byte(r); // r
	write_byte(g); // g
	write_byte(b); // b
	write_byte(brightness); // brightness
	message_end();
 }

 // blue blast
 public create_blast(origin[3])
 {
	// smallest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(21); // TE_BEAMCYLINDER
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 385); // something Z
	write_short(exploSpr); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// medium ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(21); // TE_BEAMCYLINDER
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 470); // something Z
	write_short(exploSpr); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// largest ring
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(21); // TE_BEAMCYLINDER
	write_coord(origin[0]); // start X
	write_coord(origin[1]); // start Y
	write_coord(origin[2]); // start Z
	write_coord(origin[0]); // something X
	write_coord(origin[1]); // something Y
	write_coord(origin[2] + 555); // something Z
	write_short(exploSpr); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(4); // life
	write_byte(60); // width
	write_byte(0); // noise
	write_byte(FROST_R); // red
	write_byte(FROST_G); // green
	write_byte(FROST_B); // blue
	write_byte(100); // brightness
	write_byte(0); // speed
	message_end();

	// light effect
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY);
	write_byte(27); // TE_DLIGHT
	write_coord(origin[0]); // x
	write_coord(origin[1]); // y
	write_coord(origin[2]); // z
	write_byte(floatround(FROST_RADIUS/5.0)); // radius
	write_byte(FROST_R); // r
	write_byte(FROST_G); // g
	write_byte(FROST_B); // b
	write_byte(8); // life
	write_byte(60); // decay rate
	message_end();
 }
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
