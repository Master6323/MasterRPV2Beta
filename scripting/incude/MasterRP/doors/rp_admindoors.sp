//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_admindoors_included_
  #endinput
#endif
#define _rp_admindoors_included_

//Defines:
#define MAXADMINDOORS		50

//Police Doors:
int AdminDoors[MAXADMINDOORS + 1] = {-1,...};

public void ResetAdminDoors()
{

	//Loop:
	for(int i = 0; i <= MAXADMINDOORS; i++)
	{

		//Initulize:
		AdminDoors[i] = -1;
	}
}

public void initAdminDoors()
{

	//Admin Doors:
	RegAdminCmd("sm_createadmindoor", Command_CreateAdminDoor, ADMFLAG_ROOT, "- <1-50> - Create a default Admin door.");

	RegAdminCmd("sm_removeadmindoor", Command_RemAdminDoor, ADMFLAG_ROOT, "- <1-50> - Remove a default Admin door.");

	RegAdminCmd("sm_listadmindoors", Command_ListAdminDoors, ADMFLAG_SLAY, "- <No Args> - List the default Admin doors.");

	//Beta
	RegAdminCmd("sm_wipeadmindoors", Command_WipeAdminDoors, ADMFLAG_ROOT, "<No Args> - Remove All SQL Data");

	//Timer:
	CreateTimer(0.2, CreateSQLdbAdminDoors);
}

//Create Database:
public Action CreateSQLdbAdminDoors(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `AdminDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `EntId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 70);
}

//Create Database:
public Action LoadAdminDoors(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM AdminDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadAdminDoors, query, 71);
}

public void T_DBLoadAdminDoors(Handle owner, Handle hndl, const char[] error, any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadAdminDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Admin Doors Found in DB!");

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
			AdminDoors[X] = Ent;
		}

		//Print:
		PrintToServer("|RP| - Admin Doors Loaded!");
	}
}

//Use Handle:
public void OnAdminDoorFuncUse(int Client, int Ent)
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
public void OnAdminDoorPropShift(int Client, int Ent)
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
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - You have just Locked this door!");
	}

	//Accept:
	AcceptEntityInput(Ent, "Toggle", Client);
}

public bool NativeIsAdminDoor(int Ent)
{

	//Loop:
	for(int i = 0; i <= MAXADMINDOORS; i++)
	{

		//Is Admin Door:
		if(AdminDoors[i] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action Command_CreateAdminDoor(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Wrong Parameter Usage: sm_createadmindoor <ID>");

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
	if(Var > MAXADMINDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Usage: sm_createadmindoor <\x0732CD320-%i\x07FFFFFF>", MAXADMINDOORS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	bool alreadyadded = false;

	//Loop:
	for(int i = 0; i <= MAXADMINDOORS; i++)
	{

		//Is Admin Door:
		if(AdminDoors[i] == Entdoor)
		{

			//Initulize:
			alreadyadded = true;
		}
	}

	//Check:
	if(alreadyadded)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	char query[512];

	//Spawn Already Created:
	if(AdminDoors[Var] > -1)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE AdminDoors SET EntId = %i WHERE Map = '%s' AND DoorId = %i;", Entdoor, ServerMap(), Var);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO AdminDoors (`Map`,`DoorId`,`EntId`) VALUES ('%s',%i,%i);", ServerMap(), Var, Entdoor);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 72);

	//Initialize:
	AdminDoors[Var] = Entdoor;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default Admin door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action Command_RemAdminDoor(int Client, int Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removeadmindoor <ID>");

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
	if(Var > MAXADMINDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removeadmindoor <\x0732CD320-%i\x07FFFFFF>", 200);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(AdminDoors[Var] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Door #%i isn't a Admin door!", Var);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	AdminDoors[Var] = -1;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM AdminDoors WHERE DoorId = %i AND Map = '%s';", Var, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 73);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-AdminDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default Admin door database", Var);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListAdminDoors(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Admin Door List:");

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM AdminDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintAdminDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeAdminDoors(int Client, int Args)
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
	for(new X = 1; X < MAXADMINDOORS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM AdminDoors WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 74);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintAdminDoors(Handle owner, Handle hndl, const char[] error, any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintAdminDoors: Query failed! %s", error);
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
