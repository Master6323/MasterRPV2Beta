//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_copdoors_included_
  #endinput
#endif
#define _rp_copdoors_included_

//Defines:
#define MAXCOPDOORS		200

//Police Doors:
int PoliceDoors[MAXCOPDOORS + 1] = {-1,...};

public void ResetCopDoors()
{

	//Loop:
	for(int i = 0; i <= MAXCOPDOORS; i++)
	{

		//Initulize:
		PoliceDoors[i] = -1;
	}
}

public void initPoliceDoors()
{

	//Cop Doors:
	RegAdminCmd("sm_createcopdoor", Command_CreateCopDoor, ADMFLAG_ROOT, "- <1-200> - Create a default cop door.");

	RegAdminCmd("sm_removecopdoor", Command_RemCopDoor, ADMFLAG_ROOT, "- <1-200> - Remove a default cop door.");

	RegAdminCmd("sm_listcopdoors", Command_ListCopDoors, ADMFLAG_SLAY, "- <No Args> - List the default cop doors.");

	//Beta
	RegAdminCmd("sm_wipecopdoors", Command_WipeCopDoors, ADMFLAG_ROOT, "");

	//Timer:
	CreateTimer(0.2, CreateSQLdbCopDoors);
}

//Create Database:
public Action CreateSQLdbCopDoors(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `CopDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `EntId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 75);
}

//Create Database:
public Action LoadCopDoors(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM CopDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadCopDoors, query);
}

public void T_DBLoadCopDoors(Handle owner, Handle hndl, const char[] error, any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadCopDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Cop Doors Found in DB!");

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
			PoliceDoors[X] = Ent;
		}

		//Print:
		PrintToServer("|RP| - Cop Doors Loaded!");
	}
}

//Use Handle:
public Action OnCopDoorFuncUse(int Client, int Ent)
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
public Action OnCopDoorPropShift(int Client, int Ent)
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
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - You have just Locked this door!");
	}

	//Accept:
	AcceptEntityInput(Ent, "Toggle", Client);
}

public bool NativeIsCopDoor(Ent)
{

	//Loop:
	for(int i = 0; i <= MAXCOPDOORS; i++)
	{

		//Is Cop Door:
		if(PoliceDoors[i] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action Command_CreateCopDoor(int Client, int Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Wrong Parameter Usage: sm_createcopdoor <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Var = StringToInt(Arg1);

	//Is Valid:
	if(Var > MAXCOPDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Usage: sm_createcopdoor <\x0732CD320-%i\x07FFFFFF>", MAXCOPDOORS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	bool alreadyadded = false;

	//Loop:
	for(int i = 0; i <= MAXCOPDOORS; i++)
	{

		//Is Cop Door:
		if(PoliceDoors[i] == Entdoor)
		{

			//Initulize:
			alreadyadded = true;
		}
	}

	//Check:
	if(alreadyadded)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Spawn Already Created:
	if(PoliceDoors[Var] > -1)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE CopDoors SET EntId = %i WHERE Map = '%s' AND DoorId = %i;", Entdoor, ServerMap(), Var);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO CopDoors (`Map`,`DoorId`,`EntId`) VALUES ('%s',%i,%i);", ServerMap(), Var, Entdoor);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 76);

	//Initialize:
	PoliceDoors[Var] = Entdoor;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default cop door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemCopDoor(int Client, int Args)
{

	//Is Valid:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removecopdoor <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Var = StringToInt(Arg1);

	//Is Valid:
	if(Var > MAXCOPDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removecopdoor <\x0732CD320-%i\x07FFFFFF>", 200);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(PoliceDoors[Var] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Door #%i isn't a Cop door!", Var);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	PoliceDoors[Var] = -1;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM CopDoors WHERE DoorId = %i AND Map = '%s';", Var, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 77);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default cop door database", Var);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListCopDoors(Client, Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Cop Door List:");

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM CopDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintPoliceDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeCopDoors(int Client, int Args)
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
	for(int X = 1; X < MAXCOPDOORS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM CopDoors WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 78);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintPoliceDoors(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintPoliceDoors: Query failed! %s", error);
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
