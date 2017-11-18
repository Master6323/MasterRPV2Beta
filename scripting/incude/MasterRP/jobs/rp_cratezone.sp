//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cratezone_included_
  #endinput
#endif
#define _rp_cratezone_included_

//Defines:
#define MAXCRATEZONES		10

//Euro - € dont remove this!
//€ = �

//Random Supply Crate!
float CrateZones[MAXCRATEZONES + 1][3];
int SupplyCrateTimer = 0;
int CrateEnt = -1;

public void initRandomCrate()
{

	//Random Supply Crates
	RegAdminCmd("sm_createrandomcrate", CommandCreateRandomCrateZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removerandomcrate", CommandRemoveRandomCrateZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listrandomcrates", CommandListRandomCrates, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipecratezones", Command_WipeCrateZone, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testcrate", CommandTestCrateZone, ADMFLAG_ROOT, "<id> - Test Crate Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbRandomCrateZone);

	//PreCache Model
	PrecacheModel("models/Items/item_item_crate.mdl");

	//Loop:
	for(int Z = 0; Z <= MAXCRATEZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		CrateZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbRandomCrateZone(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `RandomCrate`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadRandomCrateZone(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= 10; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		CrateZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM RandomCrate WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadRandomCrateZones, query);
}

public void T_DBLoadRandomCrateZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadRandomCrateZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Random Crates Zones Found in DB!");

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
			CrateZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Random Crate Zones Found!");
	}
}

public void T_DBPrintCrateZones(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintCrateZones: Query failed! %s", error);
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
public void OnCrateDestroyed(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the RandomCrate:
		if(CrateEnt == Entity)
		{

			//Initulize:
			CrateEnt = -1;
		}
	}
}

//Client Hud:
public void initCrateTick()
{

	//Crates!
	if(CrateEnt != -1)
	{

		//EntCheck:
		if(CheckMapEntityCount() < 1900)
		{

			//Declare:
			float CrateOrigin[3];

			//Initulize:
			GetEntPropVector(CrateEnt, Prop_Data, "m_vecOrigin", CrateOrigin);

			//Declare:
			int Color[4] = {255, 255, 50, 255};

			//Show To Client:
			TE_SetupBeamRingPoint(CrateOrigin, 1.0, 50.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, Color, 10, 0);

			//Show To Client:
			TE_SendToAll();
		}
	}

	//Initulize:
	SupplyCrateTimer++;

	//TimerCheck
	if(SupplyCrateTimer >= 900)
	{

		//Initulize:
		SupplyCrateTimer = 0;

		//Invalid Check:
		if(CrateEnt == -1)
		{

			//Declare:
			int Var = GetRandomInt(0, 10);

			//Spawn:
			SpawnCrate(Var);

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - A supply crate has been dropped!");
		}

		//Override:
		else
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - There is already a crate spawned on the map!");
		}
	}
}

//Use Handle:
public Action OnCrateUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Remove Ent:
		AcceptEntityInput(CrateEnt, "Kill", Client);

		//Initulize:
		CrateEnt = -1;

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected
			if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
			{

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - The Supply Crate has been found by \x0732CD32%N\x07FFFFFF!", Client);
			}
		}

		//Random:
		int Random = GetRandomInt(0, 100);
		int R = 0;

		if(Random >= 0 && Random < 5)
		{

			//Declare:
			R = GetRandomInt(500, 2000);

			SetBank(Client, (GetBank(Client) + R));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found \x0732CD32€%i!", R);
		}

		if(Random >= 5 && Random < 10)
		{

			//Declare:
			R = GetRandomInt(234, 258);

			//Save:
			SaveItem(Client, R, (GetItemAmount(Client, R) + 2));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found 2x of %s!", GetItemName(189));
		}

		if(Random >= 10 && Random < 20)
		{

			//Declare:
			int AddValue = 500;

			//Initulize:
			SetResources(Client, (GetResources(Client) + AddValue));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found 500g of combine Resources!");
		}

		if(Random >= 20 && Random < 30)
		{

			//Declare:
			int AddValue = 500;

			//Initulize:
			SetHarvest(Client, (GetHarvest(Client) + AddValue));

			//Initulize:
			SetCrime(Client, (GetCrime(Client) + AddValue));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found 500g of Harvest!");
		}

		if(Random >= 20 && Random < 25)
		{

			//Declare:
			int AddValue = 50;

			//Initulize:
			SetCocain(Client, (GetCocain(Client) + AddValue));

			//Initulize:
			SetCrime(Client, (GetCrime(Client) + (AddValue * 30)));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found 50g of Cocain!");
		}

		if(Random >= 30 && Random < 40)
		{

			//Save:
			SaveItem(Client, 224, (GetItemAmount(Client, 224) + 5));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found 5x of %s!", GetItemName(224));
		}

		if(Random >= 50 && Random < 60)
		{

			//Declare:
			R = GetRandomInt(1, 10);

			if(R == 7) R = 1;

			//Save
			SaveItem(Client, R, (GetItemAmount(Client, R) + 5));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found 5x of %s!", GetItemName(R));
		}

		if(Random >= 60 && Random < 70)
		{

			//Slay Client:
			ForcePlayerSuicide(Client);

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been slayed!");
		}

		if(Random >= 70 && Random <= 100)
		{

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found nothing in the supply crate!");
		}
	}
}

public int SpawnCrate(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Check:
	if(CrateEnt > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a random crate spawned on the map!");

		PrintToServer("|RP| - There is already a random crate spawned on the map!");

		//Return:
		return -1;
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(CrateZones[Var]))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Supply Crate Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Supply Crate Due to outside of world");

		//Return:
		return -1;
	}

	//Declare:
	int Ent = CreateProp(CrateZones[Var], Angles, "models/Items/item_item_crate.mdl", true, false, false);

	//Set Damage:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Random_Crate");

	//Initulize:
	CrateEnt = Ent;

	//Return:
	return -1;
}

//Create Garbage Zone:
public Action CommandCreateRandomCrateZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createrandomcrate <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createrandomcrate <0-10>");

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
	if(CrateZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE RandomCrate SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO RandomCrate (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	CrateZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created random crate spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action CommandRemoveRandomCrateZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removerandomcrate <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removerandomcrate <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(CrateZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	CrateZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM RandomCrate WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Random Crate Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action CommandListRandomCrates(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Random Crate Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXCRATEZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM RandomCrate WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintCrateZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeCrateZone(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Random Crate Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXCRATEZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM RandomCrate WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action CommandTestCrateZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testcrate <id>");

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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testcrate <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	SpawnCrate(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, CrateZones[Id][0], CrateZones[Id][1], CrateZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool IsRandomCrate(int Ent)
{

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Found Crate!
		if(CrateEnt == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public int GetCrateEnt()
{

	//Return:
	return CrateEnt;
}

public void SetCrateEnt(int Ent)
{

	//Initulize:
	CrateEnt = Ent;
}