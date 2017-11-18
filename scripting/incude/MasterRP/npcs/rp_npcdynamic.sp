//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcdynamic_included_
  #endinput
#endif
#define _rp_npcdynamic_included_

#define MAXNPCSPAWNS		10
#define MAXNPCTYPES		10

float DynamicSpawns[MAXNPCSPAWNS + 1][MAXNPCTYPES + 1][3];

//Track Client Damage
float ClientDamage[MAXPLAYERS + 1];
int NpcsOnMap = 0;

public void initNpcDynamic()
{

	//Commands
	RegAdminCmd("sm_createnpcspawn", Command_CreateNpcSpawn, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removenpcspawn", Command_RemoveNpcSpawn, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listnpcspawn", Command_ListNpcSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_wipenpcspawns", Command_WipeNpcSpawn, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbNpcSpawns);

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Initialize:
		ClientDamage[i] = 0.0;
	}

	//Loop:
	for(int X = 0; X <= MAXNPCSPAWNS; X++) for(int Y = 0; Y <= MAXNPCTYPES; Y++) for(int Z = 0; Z < 3; Z++)
	{

		//Initulize:
		DynamicSpawns[X][Y][Z] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbNpcSpawns(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `NpcSpawns`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `SpawnId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `NpcType` int(12) NULL, `Position` varchar(64) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action LoadNpcSpawns(Handle Timer)
{

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM NpcSpawns WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLoadNpcSpawns, query);
}

public void T_DBLoadLoadNpcSpawns(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNpcSpawns: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Dynamic Npc Spawns Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0;
		int Type = 0;
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 2);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			DynamicSpawns[X][Type] = Position;
		}

		//Print:
		PrintToServer("|RP| - Dynamic Npc Spawns Loaded!");
	}
}

//Create Npc Spawn:
public Action Command_CreateNpcSpawn(int Client, int Args)
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
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createnpcspawns <id> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int Id = 0;
	int Type = 0;
	float ClientOrigin[3];
	char sId[32];
	char sType[32];

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	GetCmdArg(2, sType, sizeof(sType));

	GetClientAbsOrigin(Client, ClientOrigin);

	Id = StringToInt(sId);

	Type = StringToInt(sType);

	//Declare:
	char query[512];
	char Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Spawn Already Created:
	if(DynamicSpawns[Id][Type][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE NpcSpawns SET Position = '%s' WHERE Map = '%s' AND SpawnId = %i AND NpcType = %i;", Position, ServerMap(), Id, Type);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO NpcSpawns (`Map`,`SpawnId`,`NpcType`,`Position`) VALUES ('%s',%i,%i,'%s');", ServerMap(), Id, Type, Position);
	}

	//Initulize:
	DynamicSpawns[Id][Type] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Npc Spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Npc Spawn:
public Action Command_RemoveNpcSpawn(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removenpcspawn <id> <type>");

		//Return:
		return Plugin_Handled;
	}


	//Declare:
	int Id = 0;
	int Type = 0;
	char sId[32];
	char sType[32];

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	GetCmdArg(2, sType, sizeof(sType));

	Id = StringToInt(sId);

	Type = StringToInt(sType);

	//Spawn Already Created:
	if(DynamicSpawns[Id][Type][0] != 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM NpcSpawns WHERE SpawnId = %i AND NpcType = %i AND Map = '%s';", Id, Type, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed NpcSpawn (ID #\x0732CD32%s\x07FFFFFF)", Id);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListNpcSpawn(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Npc Spawn List: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXNPCSPAWNS; X++)
	{

		//Loop:
		for(int Y = 0; Y <= MAXNPCTYPES; Y++)
		{

			//Format:
			Format(query, sizeof(query), "SELECT * FROM NpcSpawns WHERE Map = '%s' AND SpawnId = %i AND NpcType = %i;", ServerMap(), X, Y);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBPrintNpcSpawn, query, conuserid);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_WipeNpcSpawn(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Npc Spawn List Wiped: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 1; X < MAXNPCSPAWNS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM NpcSpawns WHERE SpawnId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintNpcSpawn(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintNpcSpawn: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int SpawnId = 0;
		int Type = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: Type %i <%s>", SpawnId, Type, Buffer);
		}
	}
}

public Action NpcHealthHud(int Client, int Ent)
{

	//Declare:
	char FormatMessage[255];

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "NPC:\nHealth: %i!", GetEntHealth(Ent));

	//Declare:
	float Pos[2] = {-1.0, -0.805};
	int Color[4];

	//Initulize:
	Color[0] = GetEntityHudColor(Client, 0);
	Color[1] = GetEntityHudColor(Client, 1);
	Color[2] = GetEntityHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 1, Pos, Color, Color, 0.5, 0, 6.0, 0.1, 0.2, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 1, Pos, Color, 0.5, 0, 6.0, 0.1, 0.2, FormatMessage);
	}
}

public void SetNPCRelationShipStatus(int Entity, bool Admin, bool Police, bool Citizen)
{

	if(Admin == true)
		SetAdminLikeRelationshipStatus(Entity);
	else
		SetAdminHateRelationshipStatus(Entity);
	if(Police == true)
		SetPoliceLikeRelationshipStatus(Entity);
	else
		SetPoliceHateRelationshipStatus(Entity);
	if(Admin == true)
		SetCitizenLikeRelationshipStatus(Entity);
	else
		SetCitizenHateRelationshipStatus(Entity);
}

public void SetAdminLikeRelationshipStatus(int Entity)
{

	//Declare:
	char ClientIndex[32];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Admin%i D_LI", i);

		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(Entity, "setrelationship");
	}
}

public void SetAdminHateRelationshipStatus(int Entity)
{

	//Declare:
	char ClientIndex[32];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Admin%i D_HT", i);

		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(Entity, "setrelationship");
	}
}

public void SetPoliceLikeRelationshipStatus(int Entity)
{

	//Declare:
	char ClientIndex[32];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Police%i D_LI", i);

		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(Entity, "setrelationship");
	}
}

public void SetPoliceHateRelationshipStatus(Entity)
{

	//Declare:
	char ClientIndex[32];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Police%i D_HT", i);

		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(Entity, "setrelationship");
	}
}

public void SetCitizenLikeRelationshipStatus(int Entity)
{

	//Declare:
	char ClientIndex[32];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Police%i D_LI", i);

		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(Entity, "setrelationship");
	}
}

public void SetCitizenHateRelationshipStatus(Entity)
{

	//Declare:
	char ClientIndex[32];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Police%i D_HT", i);

		//Set Hate Status
		SetVariantString(ClientIndex);

		//Accept:
		AcceptEntityInput(Entity, "setrelationship");
	}
}

public void SetClientClass(Client)
{

	//Declare:
	char ClientIndex[32];

	//Check:
	if(IsCop(Client))
	{

		//Set Police ClassName:
		SetEntityClassName(Client, "Police");

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Police%i", Client);

		//Dispatch:
		DispatchKeyValue(Client, "TargetName", ClientIndex);
	}

	//Check:
	else if(IsAdmin(Client))
	{

		//Set Police ClassName:
		SetEntityClassName(Client, "Admin");

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Admin%i", Client);

		//Dispatch:
		DispatchKeyValue(Client, "TargetName", ClientIndex);
	}

	//Override:
	else
	{

		//Set Police ClassName:
		SetEntityClassName(Client, "Citizen");

		//Format:
		Format(ClientIndex, sizeof(ClientIndex), "Citizen%i", Client);

		//Dispatch:
		DispatchKeyValue(Client, "TargetName", ClientIndex);
	}
}

public void SetLikeAntLionRelationshipStatus(int Entity)
{

	//Set Hate Status
	SetVariantString("npc_antlion D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_antlionguard D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");
}

public void SetHateAntLionRelationshipStatus(int Entity)
{

	//Set Hate Status
	SetVariantString("npc_antlion D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_antlionguard D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");
}

public void SetLikeCombineRelationshipStatus(int Entity)
{

	//Set Hate Status
	SetVariantString("npc_advisor D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_manhack D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");
}

public void SetHateCombineRelationshipStatus(int Entity)
{

	//Set Hate Status
	SetVariantString("npc_advisor D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_manhack D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");
}

public void SetLikeZombieRelationshipStatus(int Entity)
{

	//Set Hate Status
	SetVariantString("npc_zombie D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_poisenzombie D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_headcrab D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_headcrabblack D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_headcrabfast D_LI");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");
}


public void SetHateZombieRelationshipStatus(int Entity)
{

	//Set Hate Status
	SetVariantString("npc_zombie D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_poisenzombie D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_headcrab D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_headcrabblack D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");

	//Set Hate Status
	SetVariantString("npc_headcrabfast D_HT");

	//Accept:
	AcceptEntityInput(Entity, "setrelationship");
}
public bool IsValidDymamicNpc(int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Valid NPC:
	if(StrContains(ClassName, "npc_", false) == 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public int GetNpcsOnMap()
{

	//Return:
	return NpcsOnMap;
}

public void SetNpcsOnMap(int Amount)
{

	//Initulize:
	NpcsOnMap = Amount;
}

public float GetDamage(int Client)
{

	//Return:
	return ClientDamage[Client];
}

public void SetDamage(int Client, float Amount)
{

	//Initulize:
	ClientDamage[Client] = Amount;
}

public void AddDamage(int Client, float Amount)
{

	//Initulize:
	ClientDamage[Client] += Amount;
}

public void GetDynamicNpcSpawn(int Id, int Type, float Origin[3])
{

	//Initulize:
	Origin = DynamicSpawns[Id][Type];
}