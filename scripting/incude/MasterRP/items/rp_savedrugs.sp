//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_savedruggs_included_
  #endinput
#endif
#define _rp_savedruggs_included_

int Harvest[MAXPLAYERS + 1] = {0,...};
int Meth[MAXPLAYERS + 1] = {0,...};
int Pills[MAXPLAYERS + 1] = {0,...};
int Cocain[MAXPLAYERS + 1] = {0,...};
int Rice[MAXPLAYERS + 1] = {0,...};
int Resources[MAXPLAYERS + 1] = {0,...};
float BTC[MAXPLAYERS + 1] = {0.0,...};

public void initSaveDrugs()
{

	//Timer:
	CreateTimer(0.2, CreateSQLdbDynamicDrugs);

	//Commands:
	RegAdminCmd("sm_setharvest", Command_SetHarvest, ADMFLAG_ROOT, "<Name> <Amount #> - Sets Harvest");

	RegAdminCmd("sm_setmeth", Command_SetMeth, ADMFLAG_ROOT, "<Name> <Amount #> - Sets Meth");

	RegAdminCmd("sm_setpills", Command_SetPills, ADMFLAG_ROOT, "<Name> <Amount #> - Sets Pills");

	RegAdminCmd("sm_setcocain", Command_SetCocain, ADMFLAG_ROOT, "<Name> <Amount #> - Sets Cocain");

	RegAdminCmd("sm_setrice", Command_SetRice, ADMFLAG_ROOT, "<Name> <Amount #> - Sets Rice");

	RegAdminCmd("sm_setresources", Command_SetResources, ADMFLAG_ROOT, "<Name> <Amount #> - Sets Resources");

	RegAdminCmd("sm_setbitcoin", Command_SetBitCoin, ADMFLAG_ROOT, "<Name> <Amount #> - Sets BTC");
}

public void initDefaultPlayerDrugs(int Client)
{

	//Initulize:
	Harvest[Client] = 0;

	Meth[Client] = 0;

	Pills[Client] = 0;

	Cocain[Client] = 0;

	Rice[Client] = 0;

	Resources[Client] = 0;

	BTC[Client] = 0.0;
}

//Create Database:
public Action CreateSQLdbDynamicDrugs(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[2560];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Drugs`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL PRIMARY KEY, `Harvest` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Meth` int(12) NOT NULL DEFAULT 0, `Pills` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Cocain` int(12) NOT NULL DEFAULT 0, `Rice` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Resources` int(12) NOT NULL DEFAULT 0, `BitCoin` float(12) NOT NULL DEFAULT 0.0);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 127);
}

public void DBLoadDrugs(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Drugs` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadDrugsCallBack, query, conuserid);
}

public void T_LoadDrugsCallBack(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Jobs] T_LoadDrugsCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player Job system...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Declare:
			InsertDrugs(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			Harvest[Client] = SQL_FetchInt(hndl, 1);

			//Database Field Loading INTEGER:
			Meth[Client] = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			Pills[Client] = SQL_FetchInt(hndl, 3);

			//Database Field Loading INTEGER:
			Cocain[Client] = SQL_FetchInt(hndl, 4);

			//Database Field Loading INTEGER:
			Rice[Client] = SQL_FetchInt(hndl, 5);

			//Database Field Loading INTEGER:
			Resources[Client] = SQL_FetchInt(hndl, 6);

			//Database Field Loading INTEGER:
			BTC[Client] = SQL_FetchFloat(hndl, 7);

			//Print:
			PrintToConsole(Client, "|RP| player Job system loaded.");
		}
	}
}

public void InsertDrugs(int Client)
{

	//Declare:
	char buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Drugs (`STEAMID`) VALUES (%i);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 128);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Drugs.");
}

public int GetHarvest(int Client)
{

	//Return:
	return Harvest[Client];
}

public void SetHarvest(int Client, int Amount)
{

	//Initulize:
	Harvest[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Harvest = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 129);
	}
}

public int GetMeth(int Client)
{

	//Return:
	return Meth[Client];
}

public void SetMeth(int Client, int Amount)
{

	//Initulize:
	Meth[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Meth = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 130);
	}
}

public int GetPills(int Client)
{

	//Return:
	return Pills[Client];
}

public void SetPills(int Client, int Amount)
{

	//Initulize:
	Pills[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Pills = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 130);
	}
}

public int GetCocain(int Client)
{

	//Return:
	return Cocain[Client];
}

public void SetCocain(int Client, int Amount)
{

	//Initulize:
	Cocain[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Cocain = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 132);
	}
}

public int GetRice(Client)
{

	//Return:
	return Rice[Client];
}

public void SetRice(int Client, int Amount)
{

	//Initulize:
	Rice[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Rice = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 133);
	}
}

public int GetResources(Client)
{

	//Return:
	return Resources[Client];
}

public void SetResources(int Client, int Amount)
{

	//Initulize:
	Resources[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Resources = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 134);
	}
}

public float GetBitCoin(int Client)
{

	//Return:
	return BTC[Client];
}

public void SetBitCoin(int Client, float Amount)
{

	//Initulize:
	BTC[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET BitCoin = %f WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 135);
	}
}

//Set Harvest:
public Action Command_SetHarvest(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setharvest <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Action:
	SetHarvest(Player, iAmount);

	//Is Valid:
	if(Crime[Client] > 500) SetClientScore(Client, RoundToNearest(Crime[Client] / 1000.0));

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Harvest to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the Harvest of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Set Meth:
public Action Command_SetMeth(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setmeth <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Action:
	SetMeth(Player, iAmount);

	//Is Valid:
	if(Crime[Client] > 500) SetClientScore(Client, RoundToNearest(Crime[Client] / 1000.0));

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Meth to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the Meth of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Set Pills:
public Action Command_SetPills(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setpills <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Action:
	SetPills(Player, iAmount);

	//Is Valid:
	if(Crime[Client] > 500) SetClientScore(Client, RoundToNearest(Crime[Client] / 1000.0));

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Pills to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the Pills of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Set Cocain:
public Action Command_SetCocain(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcocain <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Action:
	SetCocain(Player, iAmount);

	//Is Valid:
	if(Crime[Client] > 500) SetClientScore(Client, RoundToNearest(Crime[Client] / 1000.0));

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Cocain to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the Cocain of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Set Rice:
public Action Command_SetRice(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setrice <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Action:
	SetRice(Player, iAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Rice to \x0732CD32%i", Player, iAmount);

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Rice to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the Rice of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Set Rice:
public Action Command_SetResources(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setresources <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Action:
	SetResources(Player, iAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Resources to \x0732CD32%i", Player, iAmount);

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Resources to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the Resources of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Set BitCoin:
public Action Command_SetBitCoin(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setbitcoin <Name> <Amount #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	float iAmount = StringToFloat(Arg2);

	//Action:
	SetBitCoin(Player, iAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's BitCoin to \x0732CD32%i", Player, iAmount);

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your BitCoin to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the BitCoin of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}