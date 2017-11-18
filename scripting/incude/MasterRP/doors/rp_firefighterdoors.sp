//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_firefighterDoors_included_
  #endinput
#endif
#define _rp_firefighterDoors_included_

//Defines:
#define MAXFIREDOORS		50

//Police Doors:
int FireFighterDoors[MAXFIREDOORS + 1] = {-1,...};

public void ResetFireFighterDoors()
{

	//Loop:
	for(int i = 0; i <= MAXFIREDOORS; i++)
	{

		//Initulize:
		FireFighterDoors[i] = -1;
	}
}

public void initFireFighterDoors()
{

	//FireFighter Doors:
	RegAdminCmd("sm_firefighterdoor", Command_CreateFireFighterDoor, ADMFLAG_ROOT, "- <1-50> - Create a default Fire Fighter door.");

	RegAdminCmd("sm_removefirefighterdoor", Command_RemFireFighterDoor, ADMFLAG_ROOT, "- <1-50> - Remove a default Fire Fighter door.");

	RegAdminCmd("sm_listfirefighterDoors", Command_ListFireFighterDoors, ADMFLAG_SLAY, "- <No Args> - List the default Fire Fighter doors.");

	//Beta
	RegAdminCmd("sm_wipeFireFighterDoors", Command_WipeFireFighterDoors, ADMFLAG_ROOT, "<No Args> - Remove All SQL Data");

	//Timer:
	CreateTimer(0.2, CreateSQLdbFireFighterDoors);
}

//Create Database:
public Action CreateSQLdbFireFighterDoors(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `FireFighterDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `EntId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 107);
}

//Create Database:
public Action LoadFireFighterDoors(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM FireFighterDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadFireFighterDoors, query);
}

public void T_DBLoadFireFighterDoors(Handle owner, Handle hndl, const char[] error, any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadFireFighterDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Fire Fighter Doors Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		int Ent = 0;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 2);

			//Initulize:
			FireFighterDoors[X] = Ent;
		}

		//Print:
		PrintToServer("|RP| - Fire Fighter Loaded!");
	}
}

//Use Handle:
public void OnFireFighterDoorFuncUse(int Client, int Ent)
{

	//Check To Prevent Spam:
	if(!IsDoorOpening(Ent))
	{

		//Set:
		SetIsDoorOpening(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Unlock", Client);

		//Accept:
		AcceptEntityInput(Ent, "Toggle", Client);
/*
		//Declare:
		float Origin[3];
		char Sound[128];

		//Format:
		Format(Sound, sizeof(Sound), "buttons/button3.wav");

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_vecVelocity", Origin);

		//Play Sound:
		EmitAmbientSound(Sound, Origin, Ent, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
*/
	}
}

//Use Handle:
public void OnFireFighterDoorPropShift(int Client, int Ent)
{

	//Set:
	SetIsDoorOpening(Ent, true);

	//Is Door Locked:
	if(GetDoorLocked(Ent))
	{

		//Initulize:
		SetDoorLocked(Ent, false);

		//Accept:
		AcceptEntityInput(Ent, "Unlock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - You have just Locked this door!");
	}

	//Accept:
	AcceptEntityInput(Ent, "Toggle", Client);
}

public bool NativeIsFireFighterDoor(int Ent)
{

	//Loop:
	for(int i = 0; i <= MAXFIREDOORS; i++)
	{

		//Is FireFighter Door:
		if(FireFighterDoors[i] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action Command_CreateFireFighterDoor(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Wrong Parameter Usage: sm_createfirefighter <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	int Var = StringToInt(Arg);

	//Is Valid:
	if(Var > MAXFIREDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Usage: sm_createfirefighter <\x0732CD320-%i\x07FFFFFF>", MAXFIREDOORS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	bool alreadyadded = false;

	//Loop:
	for(int i = 0; i <= MAXFIREDOORS; i++)
	{

		//Is FireFighter Door:
		if(FireFighterDoors[i] == Entdoor)
		{

			//Initulize:
			alreadyadded = true;
		}
	}

	//Check:
	if(alreadyadded)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Spawn Already Created:
	if(FireFighterDoors[Var] > -1)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE FireFighterDoors SET EntId = %i WHERE Map = '%s' AND DoorId = %i;", Entdoor, ServerMap(), Var);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO FireFighterDoors (`Map`,`DoorId`,`EntId`) VALUES ('%s',%i,%i);", ServerMap(), Var, Entdoor);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 108);

	//Initialize:
	FireFighterDoors[Var] = Entdoor;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default Fire Fighter door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemFireFighterDoor(int Client, int Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Wrong Parameter Usage: sm_removefirefighter <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	int Var = StringToInt(Arg);

	//Is Valid:
	if(Var > MAXFIREDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Wrong Parameter Usage: sm_removefirefighter <\x0732CD320-%i\x07FFFFFF>", 200);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(FireFighterDoors[Var] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Door #%i isn't a Fire Fighter door!", Var);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	FireFighterDoors[Var] = -1;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM FireFighterDoors WHERE DoorId = %i AND Map = '%s';", Var, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 109);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-FireFighterDoors|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default Fire Fighter door database", Var);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListFireFighterDoors(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Fire Fighter Door List:");

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM FireFighterDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintFireFighterDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeFireFighterDoors(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Loop:
	for(new X = 1; X < MAXFIREDOORS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM FireFighterDoors WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 110);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintFireFighterDoors(Handle owner, Handle hndl, const char[] error, any:data)
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
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintFireFighterDoors: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int DoorId = 0;
		int EntId = 0;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			DoorId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			EntId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: <%i>", DoorId, EntId);
		}
	}
}
