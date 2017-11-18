//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_lockdown_included_
  #endinput
#endif
#define _rp_lockdown_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define MAXLOCKDOWNSPAWNS	10

char JudgementWaver[256] = "city8/city8-jw.wav";
//char CityInspection[256] = "city8/city8-inspection.wav";
char CityAlarm[256] = "ambient/alarms/citadel_alert_loop2.wav";
float LockdownNPCSpawnZones[MAXLOCKDOWNSPAWNS + 1][3];

int LockdownTime = 0;
Handle hLockdownTimer = INVALID_HANDLE;

public void initLockdown()
{

	//Commands:
	RegAdminCmd("sm_createlockdownnpcspawn", Command_CreateLockdownZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removelockdownnpcspawn", Command_RemoveLockdownZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listLockdownnpcpawns", Command_ListLockdownNPCSpawnZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipeLockdownnpcspawn", Command_WipeLockdownZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testlockdownnpcspawn", Command_TestLockdownZone, ADMFLAG_ROOT, "<id> - Test lockdown Spawn");

	//Public Commands:
	RegConsoleCmd("sm_lockdown", Command_Lockdown);

	//Timers:
	CreateTimer(0.2, CreateSQLdbLockdownNPCSpawnZones);

	//Loop:
	for(int Z = 0; Z <= MAXLOCKDOWNSPAWNS; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		LockdownNPCSpawnZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbLockdownNPCSpawnZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `LockdownNPCSpawnZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadLockdownNPCSpawnZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= 10; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		LockdownNPCSpawnZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM LockdownNPCSpawnZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLockdownNPCSpawnZones, query);
}

public void T_DBLoadLockdownNPCSpawnZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadLockdownNPCSpawnZones: Query failed! %s", error);
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
			LockdownNPCSpawnZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Fire Zones Zones Found!");
	}
}

public void T_DBPrintLockdownNPCSpawnZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintLockdownNPCSpawnZones: Query failed! %s", error);
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

public void initLockdownTimer()
{

	//Check:
	if(LockdownTime > 0)
	{

		//Initulize:
		LockdownTime -= 1;

		//Switch:
		switch(LockdownTime)
		{

			//Activate Lockdown:
			case 1:
			{

				//Deactivate:
				DeactivateLockdown();
			}

			//Activate Lockdown:
			case 80:
			{

				//Print:
				PrintLockDownMessage();
			}


			//Activate Lockdown:
			case 160:
			{

				//Print:
				PrintLockDownMessage();

				//Declare:
				float Origin[3] = {0.0, 0.0, 500.0};

				//Play Sound:
				EmitAmbientSound(JudgementWaver, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
			}


			//Activate Lockdown:
			case 220:
			{

				//Print:
				PrintLockDownMessage();
			}

			//Activate Lockdown:
			case 300:
			{

				//Activate:
				ActivateLockdown();
			}
		}
	}
}

public void StartLockdown(Client)
{

	//Initulize:
	LockdownTime = 360;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N has activated a Lockdown in 60 seconds!", Client);
}

public void ActivateLockdown()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Lockdown has now been Activated!");

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(JudgementWaver, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);

	//Timer:
	hLockdownTimer = CreateTimer(30.0, ActiveAlarmShakeTimer, _, TIMER_REPEAT);

	//Spawn:
	initLockdownSpawns();

	//Shake:
	ShakeGlobal();
}

public Action ActiveAlarmShakeTimer(Handle Timer)
{

	//Shake:
	ShakeGlobal();

	//Alarm Sound:
	LockdownAlarmSound();
}

public void PrintLockDownMessage()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - All citizens not inside a building can be shot on sight!");
}

public void DeactivateLockdown()
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Lockdown has now been Deactivated!");

	//Check:
	if(hLockdownTimer != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(hLockdownTimer);

		//Initulize:
		hLockdownTimer = INVALID_HANDLE;
	}
}

public void LockdownAlarmSound()
{

	//Declare:
	float Origin[3] = {0.0, 0.0, 500.0};

	//Play Sound:
	EmitAmbientSound(CityAlarm, Origin, 0, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
}

public void ShakeGlobal()
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Shake:
			ShakeClient(i, 10.0, 1.3);
		}
	}
}

public void initLockdownSpawns()
{
#if defined HL2DM
	//Loop:
	for(int X = 0; X <= MAXLOCKDOWNSPAWNS; X++)
	{

		//Check:
		if(LockdownNPCSpawnZones[X][0] != 69.0)
		{

			//Create NPCS!
			CreateLockdownNPCs(X);
		}
	}
#endif
}

public int CreateLockdownNPCs(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(LockdownNPCSpawnZones[Var]))
	{

		//Print:
		PrintToServer("|RP| - Unable to Spawn manhack on lockdown due to outside of world");

		//Return:
		return -1;
	}

	//Declare:
	int Ent = CreateNpcManHack("null", LockdownNPCSpawnZones[Var], Angles, 250);

	//Set Fire Color:
	//SetEntityRenderColor(Ent, 250, 250, 250, 0);

	//Sent Ent Render:
	//SetEntityRenderMode(Ent, RENDER_GLOW);

	//Return:
	return Ent;

}

public Action Command_Lockdown(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsAdmin(Client) && !IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you don't have access to this command.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(LockdownTime > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate another lockdown whilst we're still in one!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(GetGlobalCrime() > 20000 && !IsAdmin(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you can't activate a lockdown without the required crime on the server !");

		//Return:
		return Plugin_Handled;
	}

	//Start:
	StartLockdown(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateLockdownZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createlockdownnpcspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createlockdownnpcspawn <0-10>");

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
	if(LockdownNPCSpawnZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE LockdownNPCSpawnZones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO LockdownNPCSpawnZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	LockdownNPCSpawnZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Lockdown npc spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemoveLockdownZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removelockdownnpcspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removelockdownnpcspawn <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(LockdownNPCSpawnZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	LockdownNPCSpawnZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM LockdownNPCSpawnZones WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Lockdown npc Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_ListLockdownNPCSpawnZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Fire Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXLOCKDOWNSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM LockdownNPCSpawnZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintLockdownNPCSpawnZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeLockdownZones(int Client, int Args)
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
	for(int  X = 0; X <= MAXLOCKDOWNSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM LockdownNPCSpawnZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_TestLockdownZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testlockdownnpcspawn <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testlockdownnpcspawn <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	SpawnGlobalFire(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, LockdownNPCSpawnZones[Id][0], LockdownNPCSpawnZones[Id][1], LockdownNPCSpawnZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

public bool IsLockdownActive()
{

	//Check:
	if(LockdownTime > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}