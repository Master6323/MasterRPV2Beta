//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_firezone_included_
  #endinput
#endif
#define _rp_firezone_included_

//Defines:
#define MAXFIREZONES		10

//Euro - € dont remove this!
//€ = �

//Random Fire Zones!
float FireZones[MAXFIREZONES + 1][3];
int FireZoneTimer = 0;
int FireExplodeTimer = -1;
int GlobalFireEnt = -1;

public void initGlobalFire()
{

	//Commands:
	RegAdminCmd("sm_createfirezone", Command_CreateFireZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removefirezone", Command_RemoveFireZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listfirezones", Command_ListFireZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipefirezones", Command_WipeFireZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testFirezone", Command_TestFireZone, ADMFLAG_ROOT, "<id> - Test Fire Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbFireZones);

	//Loop:
	for(int Z = 0; Z <= MAXFIREZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		FireZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbFireZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `FireZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadFireZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= 10; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		FireZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM FireZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadFireZones, query);
}

public void T_DBLoadFireZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadFireZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Random Fire Zones Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			FireZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Fire Zones Zones Found!");
	}
}

public void T_DBPrintFireZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintFireZones: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ZoneId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

// remove players from Vehicles before they are destroyed or the server will crash!
public void OnFireDestroyed(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the Fire!:
		if(GlobalFireEnt == Entity)
		{

			//Initulize:
			GlobalFireEnt = -1;

			//Check:
			if(IsValidAttachedEffect(GlobalFireEnt))
			{

				//Remove:
				RemoveAttachedEffect(GlobalFireEnt);
			}
		}
	}
}

//Client Hud:
public void initGlobalFireTick()
{

	//Is Global Fire!
	if(GlobalFireEnt != -1)
	{

		//Check:
		if(FireExplodeTimer == 0)
		{

			//Create Fire Explosion:
			ExplodeGlobalFire(GlobalFireEnt);
		}

		//Spread Fire:
		if(FireExplodeTimer == 10 || FireExplodeTimer == 20 || FireExplodeTimer == 30 || FireExplodeTimer == 40 || FireExplodeTimer == 50 || FireExplodeTimer == 60 || FireExplodeTimer == 70 || FireExplodeTimer == 80 || FireExplodeTimer == 90)
		{

			//Create More Fire:
			GlobalExtendFire(GlobalFireEnt);
		}

		//Check:
		if(FireExplodeTimer > -1)
		{

			//Initulize:
			FireExplodeTimer += 1;
		}

		//Check:
		if(FireExplodeTimer == 180)
		{

			//Remove Fire:
			RemoveGlobalFire(GlobalFireEnt);
		}
	}

	//Initulize:
	FireZoneTimer++;

	//TimerCheck
	if(FireZoneTimer >= 600)
	{

		//Initulize:
		FireZoneTimer = 0;

		//Invalid Check:
		if(GlobalFireEnt == -1)
		{

			//Declare:
			int Var = GetRandomInt(0, 10);

			//Spawn:
			SpawnGlobalFire(Var);

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(IsAdmin(i) || IsCop(i) || StrEqual(GetJob(i), "Fire Fighter"))
					{

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - A Fire has been started!");
					}
				}
			}
		}

		//Override!:
		else
		{

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(IsAdmin(i) || IsCop(i) || StrEqual(GetJob(i), "Fire Fighter"))
					{

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - There is already a Fire spawned on the map!");
					}
				}
			}
		}
	}
}

public void ExplodeGlobalFire(int Ent)
{

	//Explode:
	CreateExplosion(Ent, Ent);

	//Initulize Effects:
	int Effect = CreateEnvFire(Ent, "null", "200", "700", "0", "Natural");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Initulize Effects:
	Effect = CreateLight(Ent, 1, 255, 120, 120, "null");

	SetEntAttatchedEffect(Ent, 1, Effect);
}


public void GlobalExtendFire(int Ent)
{

	//Loop:
	for(int Y = 2; Y <= 10; Y++)
	{

		//Declare:
		int EntSlot = GetEntAttatchedEffect(Ent, Y);

		//Check:
		if(!IsValidEntity(EntSlot))
		{

			//Initulize Effects:
			int Effect = CreateEnvFire(Ent, "null", "200", "700", "0", "Natural");

			SetEntAttatchedEffect(Ent, Y, Effect);

			//Accept:
			AcceptEntityInput(Effect, "ClearParent");

			//Teleport:
			TeleportFireAwayFromSource(Ent, Effect);

			//Stop:
			break;
		}
	}
}

//Loop till we find a suitable origin to spawn new fire!
public void TeleportFireAwayFromSource(int Ent, int FireEnt)
{

	//Declare:
	float Origin[3];
	float FireOrigin[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	FireOrigin[0] = Origin[0] + GetRandomFloat(-100.0, 100.0);
	FireOrigin[1] = Origin[1] + GetRandomFloat(-100.0, 100.0);
	FireOrigin[2] = Origin[2];

	//Check:
	if(!TR_PointOutsideWorld(FireOrigin))
	{

		//Declare:
		float Dist = GetVectorDistance(Origin, FireOrigin);

		//Check Distance:
		if(Dist > 50)
		{

			//Declare:
			bool Result = true;

			//Loop:
			for(int Y = 2; Y <= 10; Y++)
			{

				//Declare:
				int EntSlot = GetEntAttatchedEffect(Ent, Y);

				//Check:
				if(IsValidEntity(EntSlot))
				{

					//Initulize:
					GetEntPropVector(EntSlot, Prop_Data, "m_vecOrigin", Origin);

					//Declare:
					Dist = GetVectorDistance(Origin, FireOrigin);

					//Check Distance:
					if(Dist < 40)
					{

						//Initulize:
						Result = false;
					}
				}
			}

			//Not in distance of other fire!
			if(Result == true)
			{

				//Teleport:
				TeleportEntity(FireEnt, FireOrigin, NULL_VECTOR, NULL_VECTOR);
			}

			//Override:
			else
			{

				//Retry:
				TeleportFireAwayFromSource(Ent, FireEnt);
			}
		}

		//Override:
		else
		{

			//Retry:
			TeleportFireAwayFromSource(Ent, FireEnt);
		}
	}

	//Override:
	else
	{

		//Retry:
		TeleportFireAwayFromSource(Ent, FireEnt);
	}
}

public void RemoveGlobalFire(int Ent)
{

	//Check:
	if(IsValidAttachedEffect(GlobalFireEnt))
	{

		//Remove:
		RemoveAttachedEffect(GlobalFireEnt);
	}

	//Accept:
	AcceptEntityInput(GlobalFireEnt, "kill");

	//Initulize:
	GlobalFireEnt = -1;

	//Initulize:
	FireExplodeTimer = -1;
}

public int SpawnGlobalFire(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Check:
	if(GlobalFireEnt > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a Fire spawned on the map!");

		PrintToServer("|RP| - There is already a Fire spawned on the map!");

		//Return:
		return -1;
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(FireZones[Var]))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Fire Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Fire Due to outside of world");

		//Return:
		return -1;
	}

	//Declare:
	int Ent = CreateProp(FireZones[Var], Angles, "models/Items/item_item_crate.mdl", true, true, false);

	//Set Damage:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Fire Color:
	SetEntityRenderColor(Ent, 250, 250, 250, 0);

	//Sent Ent Render:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Initulize:
	GlobalFireEnt = Ent;

	FireExplodeTimer = 0;

	//Return:
	return Ent;
}

//Create Garbage Zone:
public Action Command_CreateFireZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createfirezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createfirezone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(FireZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE FireZones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO FireZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	FireZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Fire Zones spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveFireZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removefirezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removefirezone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(FireZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	FireZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM FireZones WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Fire Zones Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListFireZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Fire Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXFIREZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM FireZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintFireZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeFireZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Fire Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXFIREZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM FireZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_TestFireZone(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testfirezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testfirezone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	SpawnGlobalFire(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, FireZones[Id][0], FireZones[Id][1], FireZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool IsEntityGlobalFire(int Ent)
{

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Found Fire!
		if(GlobalFireEnt == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public int GetGlobalFireEnt()
{

	//Return:
	return GlobalFireEnt;
}

public void SetGlobalFireEnt(int Ent)
{

	//Initulize:
	GlobalFireEnt = Ent;
}