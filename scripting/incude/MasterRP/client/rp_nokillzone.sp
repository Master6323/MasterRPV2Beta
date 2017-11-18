//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_nokillzone_included_
  #endinput
#endif
#define _rp_nozkillzone_included_

//Max HL2 Spawns:
#define MAXAREAS		10

//NoKillZone:
float ProtectOrigin[10 + 1][3];
int Area[MAXAREAS + 1] = {0,...};
bool IsNokill[MAXPLAYERS + 1] = {false,...};

public void initNoKillZone()
{

	//Commands
	RegAdminCmd("sm_createnokillzone", Command_CreateNoKillZone, ADMFLAG_ROOT,"<id> <dist> Create a nokill zone");

	RegAdminCmd("sm_removenokillzone", Command_RemoveNoKillZone, ADMFLAG_ROOT,"<id> <dist> remove a nokillzone");

	RegAdminCmd("sm_nokilllist", CommandListNoKillZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	CreateTimer(0.4, CreateSQLdbNoKillZone);

	//Loop:
	for(int Z = 0; Z < MAXAREAS; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		ProtectOrigin[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbNoKillZone(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `NoKillZone`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `Dist` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ZoneId` int(12) NULL, `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 48);
}

//Create Database:
public Action LoadNoKillZone(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM NoKillZone WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadNoKillZone, query, 49);
}

public void T_DBLoadNoKillZone(Handle owner, Handle hndl, const char[] error, anydata)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNoKillZone: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Kill Zone Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int Dist = 0;
		int X = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Dist = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(int Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			ProtectOrigin[X] = Position;

			Area[X] = Dist;
		}

		//Print:
		PrintToServer("|RP| - No Kill Zones Loaded!");
	}
}

public Action Command_RemoveNoKillZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removenokillzone <id>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//No Spawn:
	if((ProtectOrigin[StringToInt(ZoneId)][0] == 69.0))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM NoKillZone WHERE SpawnId = %i AND Map = '%s';", StringToInt(ZoneId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 50);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

public Action Command_CreateNoKillZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createnokillzone <id> <area>");
		
		//Return:
		return Plugin_Handled;
	}
	

	//Declare:
	float ClientOrigin[3];
	char ZoneId[32];
	char Dist[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	GetCmdArg(2, Dist, sizeof(Dist));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Spawn Already Created:
	if(ProtectOrigin[StringToInt(ZoneId)][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE NoKillZones SET Position = '%s', Dist = %i WHERE Map = '%s' AND ZoneId = %i;", Position, StringToInt(Dist), ServerMap(), StringToInt(ZoneId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO NoKillZone (`Map`,`Dist`,`ZoneId`,`Position`) VALUES ('%s',%i,%i,'%s');", ServerMap(), StringToInt(Dist), StringToInt(ZoneId), Position);
	}

	//Initulize:
	ProtectOrigin[StringToInt(ZoneId)] = ClientOrigin;

	Area[StringToInt(ZoneId)] = StringToInt(Dist);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 51);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Zone \x0732CD32#%s\x07FFFFFF \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", ZoneId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListNoKillZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "No Kill Zones:");

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM NoKillZone WHERE Map = '%s';", ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintNoKillZoneList, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintNoKillZoneList(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_NoKillZones] T_DBPrintNoKillZoneList: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		int Dist = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Dist = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s> dist <%i>", SpawnId, Buffer, Dist);
		}
	}
}

//Show Enity Hud
public Action NokillZone(int Client)
{

	//Declare:
	bool InSecure = false;
	float ClientOrigin[3];

	//Initulize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Loop:
	for(int X = 0; X < MAXAREAS; X++)
	{

		//Initialize:
		float Dist = GetVectorDistance(ClientOrigin, ProtectOrigin[X]);

		//Check:
		if(Dist <= Area[X])
		{

			//Has Crime:
			if(GetCrime(Client) == 0)
			{

				//Initulize:
				IsNokill[Client] = true;

				InSecure = true;
			} 

			//Override:
			else
			{

				//Initulize:
				IsNokill[Client] = false;
			}
		}
	}

	//Tick:
	if(!InSecure)
	{

		//Initulize:
		IsNokill[Client] = false;
	}
}

public bool GetIsNokill(int Client)
{

	//Return:
	return IsNokill[Client];
}