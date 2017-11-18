//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bans_included_
  #endinput
#endif
#define _rp_bans_included_
#if defined BANS
//Database Sql:
Handle hBanDB = INVALID_HANDLE;

//Global Variables:
int BanTarget[MAXPLAYERS + 1];
int BanTargetTime[MAXPLAYERS + 1];

//Add Unban menu with everyones steamid and name
//Add extra commands to alter player ban, sm_increaseban <steamnumberid> <time in total>
//Add sm_changebanreason
//add command to see player steamnumberid
//add another table to ban players ip adress

//Add Gag and Ungag
//Add Mute and Unmute

//Initation:
public void initBans()
{

	//Print Server If Plugin Start:
	PrintToConsole(0, "|RolePlay| Bans Successfully Loaded!");

	//Start SQL Connection:
	InitSQLBans();

	RegAdminCmd("sm_ban", Command_Ban, ADMFLAG_BAN, "sm_ban <Name> <Length> <Reason>");

	RegAdminCmd("sm_addban", Command_AddBan, ADMFLAG_BAN, "sm_addban <SteaamNumberId>");

	RegAdminCmd("sm_unban", Command_UnBan, ADMFLAG_BAN, "sm_ban <SteaamNumberId>");

	RegAdminCmd("sm_banlist", Command_BanList, ADMFLAG_SLAY, "sm_ban <SteaamNumberId>");

	RegAdminCmd("sm_banmenu", Command_BanMenu, ADMFLAG_SLAY, "sm_banmenu");

	RegAdminCmd("sm_status", Command_Status, ADMFLAG_SLAY, "sm_banmenu");

	//Bans:
	CreateTimer(0.2, CreateSQLdbBansTable);
}

//On Config:
public void OnBansExecuted()
{

	//Declare:
	char filename[512];

	//Build:
	BuildPath(Path_SM, filename, sizeof(filename), "plugins/basebans.smx");

	//Check:
	if(FileExists(filename))
	{

		//Declare:
		char newfilename[200];

		//Build:
		BuildPath(Path_SM, newfilename, sizeof(newfilename), "plugins/disabled/basebans.smx");

		//Command:
		ServerCommand("sm plugins unload basebans");

		//Check:
		if(FileExists(newfilename))
		{

			//Delete:
			DeleteFile(newfilename);
		}

		//Rename:
		RenameFile(newfilename, filename);

		//Print:
		PrintToConsole(0,"|RP-Bans| - plugins/basebans.smx was unloaded and moved to plugins/disabled/basebans.smx");
	}
}

//On Client sent SteamId To Server:
public void OnClientAuthorized(int Client, const char[] auth)
{

	//Initialize:
	BanTarget[Client] = -1;

	BanTargetTime[Client] = -1;

	//Do not check bots nor check player with lan steamid.
	if(auth[0] != 'B' && auth[9] != 'L' && hBanDB != INVALID_HANDLE)
	{

		//Load:
		DBLoadBans(Client);
	}
}

//Setup Sql Connection:
public void InitSQLBans()
{

	//find Configeration:
	if(SQL_CheckConfig("RoleplayDB_Bans"))
	{

		//Print:
	     	PrintToServer("|Bans| : Initial (CONNECTED)");

		//Sql Connect:
		SQL_TConnect(DBConnectBans, "RoleplayDB_Bans");
	}

	//Override:
	else
	{
#if defined DEBUG
		//Logging:
		LogError("|Bans| : %s", "Invalid Configeration.");
#endif
	}
}

public int DBConnectBans(Handle owner, Handle hndl, const char[] error, any:data)
{

	//Is Valid Handle:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("|DataBase| : %s", error);
#endif
		//Return:
		return false;
	}

	//Override:
	else
	{

		//Copy Handle:
		hBanDB = hndl;

		//Declare:
		char SQLDriver[32];

		bool iSqlite = true;

		//Read SQL Driver
		SQL_ReadDriver(hndl, SQLDriver, sizeof(SQLDriver));

		//MYSQL
		if(strcmp(SQLDriver, "mysql", false)==0)
		{

			//Thread Query:
			SQL_TQuery(hBanDB, SQLBansErrorCheckCallback, "SET NAMES \"UTF8\"");

			//Initulize:
			iSqlite = false;
		}

		//Is Sqlite:
		if(iSqlite)
		{

			//Print:
			PrintToServer("|DataBase| Connected to SQLite Database. ");
		}

		//Override:
		else
		{

			//Print:
			PrintToServer("|DataBase| Connected to MySQL Database I.e External Config.");
		}
	}

	//Return:
	return true;
}

//Load:
public void DBLoadBans(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(hBanDB, T_DBLoadBansCallback, query, conuserid);
}

public int T_DBLoadBansCallback(Handle owner, Handle hndl, const char[] error, any:data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Bans_Player] T_DBLoadCallback: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			int banlength = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			int timeofban = SQL_FetchInt(hndl, 3);

			//decl
			if(timeofban + banlength > GetTime())
			{

			}

			//Kick Player:
			else
			{

				//Declare:
				char Reason[255];

				//Database Field Loading String:
				SQL_FetchString(hndl, 4, Reason, sizeof(Reason));

				//Kick Player
				KickClient(Client, "You have banned from this server\nReason: %s", Reason);
			}
		}
	}

}

//Create Database:
public Action CreateSQLdbBansTable(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Player`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) PRIMARY KEY, `NAME` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `lENGTH` int(12) NULL, `POINTOFBAN` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `REASON` `NAME` varchar(64) NOT NULL);");

	//Thread query:
	SQL_TQuery(hBanDB, SQLBansErrorCheckCallback, query);
}

public Action Command_Ban(int Client, int Args)
{


	//No Valid Charictors:
	if(Args < 3 || Args > 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Usage: sm_ban <Name> <Length> <Reason>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char PlayerName[32];
	char Name[32];
	int Player = -1;

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientConnected(i)) continue;

		//Initialize:
		GetClientName(i, Name, sizeof(Name));

		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = i; break;
	}
	
	//Invalid Name:
	if(Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Could not find client \x0732CD32%s", PlayerName);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SteamId[32];
	char Length[32];
	char Reason[255];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	GetCmdArg(2, Length, sizeof(Length));

	GetCmdArg(3, Reason, sizeof(Reason));

	//Declare:
	char buffer[512];

	//Format:
	Format(buffer, sizeof(buffer), "INSERT INTO Player (`STEAMID`,`NAME`,`LENGTH`,`POINTOFBAN`,`REASON`) VALUES (%i,'%s',%i,%i,'%s');", SteamIdToInt(Player), Name, StringToInt(Length), GetTime(), Reason);

	//Override:
	//Not Created Tables:
	SQL_TQuery(hBanDB, SQLBansErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32#%N\x07FFFFFF has been banned from this server!", Player);

	//Log:
	LogAction(Client, Player, "\"%L\" banned \"%L\" (minutes \"%d\") (reason \"%s\")", Client, Player, Length, Reason);

	//Return:
	return Plugin_Handled;
}

public Action Command_AddBan(int Client, int Args)
{

	//No Valid Charictors:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Usage: sm_addban <SteamNumberId>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SteamId[32];
	char Length[32];
	char Reason[255];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	GetCmdArg(2, Length, sizeof(Length));

	GetCmdArg(3, Reason, sizeof(Reason));

	//Declare:
	char buffer[512];

	//Format:
	Format(buffer, sizeof(buffer), "INSERT INTO Player (`STEAMID`,`NAME`,`LENGTH`,`POINTOFBAN`,`REASON`) VALUES (%i,'Name Not Available',%i,%i,'%s');", StringToInt(SteamId), StringToInt(Length), GetTime(), Reason);

	//Override:
	//Not Created Tables:
	SQL_TQuery(hBanDB, SQLBansErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32#%i\x07FFFFFF SteamNumberId has been added to the server!", SteamId);

	//Log:
	LogAction(Client, Client, "\"%L\" added ban (minutes \"%d\") (reason \"%s\")", Client, Length, Reason);

	//Return:
	return Plugin_Handled;
}

public Action Command_UnBan(int Client, int Args)
{

	//No Valid Charictors:
	if(Args > 1 && Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Usage: sm_unban <SteamNumberId>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char SteamId[32];
	char query[255];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", StringToInt(SteamId));

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		int conuserid = GetClientUserId(Client);

		//Not Created Tables:
		SQL_TQuery(hBanDB, T_UnBanCallback, query, conuserid);
	}

	//Override:
	else
	{

		//Not Created Tables:
		SQL_TQuery(hBanDB, T_UnBanCallback, query, 12345678);
	}

	//Return:
	return Plugin_Handled;
}

public T_UnBanCallback(Handle owner, Handle hndl, const char[] error, any:data)
{

	//Declare:
	int Client;

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Bans] T_UnBanCallback: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			if(data != 12345678)
				CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Invalid SteamId Found In SQL Ban List!");
			else
				PrintToConsole(Client, "|RP-Bans| - Invalid SteamId Found In SQL Ban List!");

			//Return:
			return;
		}

		//Declare:
		int SteamId;
		char Name[32];
		char buffer[255];

		//Override:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Name, 32);

			//Sql String:
			Format(buffer, sizeof(buffer), "DELETE FROM Player WHERE STEAMID = %i;", SteamId);

			//Print:
			if(data != 12345678)
				CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32%s\x07FFFFFF has been unbanned from the server!", Name);
			else
				PrintToConsole(Client, "|RP-Bans| - %s has been unbanned from the server!", Name);

			//Override:
			//Not Created Tables:
			SQL_TQuery(hBanDB, SQLBansErrorCheckCallback, buffer);

			//Log:
			LogAction(Client, Client, "\"%L\" Unbanned (Name \"%s\")", Client, Name);
		}
	}
}

public Action Command_BanList(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Ban List:");

	//Declare:
	char query[512];

	//Forat:
	Format(query, sizeof(query), "SELECT * FROM Player;");

	//Not Created Tables:
	SQL_TQuery(hBanDB, T_DBPrintBannedPlayers, query, conuserid);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Press \x0732CD32'Escape'\x07FFFFFF For a menu!");

	//Return:
	return Plugin_Handled;
}

public T_DBPrintBannedPlayers(Handle owner, Handle hndl, const char[] error, any data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Bans] T_DBPrintBannedPlayers: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - There are no players on the SQL Ban list!");

			//Return:
			return;
		}

		//Declare:
		int Length;
		int BannedPlayer;
		char FormatMessage[2048];
		char Name[32];
		char Reason[255];

		//Declare:
		int i = 0;
		int len = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Roleplay SQL Ban List:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			BannedPlayer = SQL_FetchInt(hndl, 0);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Name, 32);

			//Database Field Loading Intiger:
			Length = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 4, Reason, 32);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, " %s Steamid (%i) Reason: %s Length: %i\n", Name, BannedPlayer, Reason, Length);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);

	}
}

public Action Command_BanMenu(int Client, int Args)
{
	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP-Bans| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Show Menu:
	DisplayBanMenu(Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Press \x0732CD32'Escape'\x07FFFFFF For a menu!");

	//Return:
	return Plugin_Handled;
}

public void DisplayBanMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerBanMenu);

	//Menu Title:
	menu.SetTitle("Who would you like to Ban?");

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientInGame(i))
		{

			//Initialize:
			continue;
		}

		//Declare:
		char name[65];
		char ID[25];

		//Initialize:
		GetClientName(i, name, sizeof(name));

		//Convert:
		IntToString(i, ID, sizeof(ID));

		//Menu Button:
		menu.AddItem(ID, name);
	}

	//Allow Back Track:
	menu.ExitBackButton = false;

	//Set Exit Button:
	menu.ExitButton =true;

	//Show Menu:
	menu.Display(Client, 20);

}

//PlayerMenu Handle:
public int HandlePlayerBanMenu(Menu menu, MenuAction HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Player = StringToInt(info);

		if(Client == Player)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - You cannot ban yourself!");
		}

		//Override:
		else
		{

			BanTarget[Client] = Player;

			//Show Menu:
			DisplayBanTimeMenu(Client);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

public void DisplayBanTimeMenu(Client)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerBanTime);

	//Declare:
	char Title[255];

	//Format:
	Format(Title, sizeof(Title), "How long would you like to ban %N for?", BanTarget[Client]);

	//Menu Title:
	menu.SetTitle(Title);

	//Menu Button:
	menu.AddItem("0", "Permanent");

	menu.AddItem("10", "10 Minutes");

	menu.AddItem("30", "30 Minutes");

	menu.AddItem("60", "1 Hour");

	menu.AddItem("240", "4 Hours");

	menu.AddItem("1440", "1 Day");

	menu.AddItem("10080", "1 Week");

	menu.AddItem("69", "Back");

	//Set Exit Button:
	menu.ExitButton = true;

	//Show Menu:
	menu.Display(Client, 20);
}

//PlayerMenu Handle:
public int HandlePlayerBanTime(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[255];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Time = StringToInt(info);

		if(Time == 69)
		{

			//Show Menu:
			DisplayBanMenu(Client);

			//Close:
			CloseHandle(menu);
		}

		//Override:
		else
		{

			//Initialize:
			BanTargetTime[Client] = Time;

			//Show Menu:
			DisplayBanReasonMenu(Client);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

public void DisplayBanReasonMenu(Client)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerBanReason);

	//Declare:
	char Title[255];

	//Format:
	Format(Title, sizeof(Title), "What Reason Does %N have to be banned\nTime:%i", BanTarget[Client], BanTargetTime[Client]);

	//Menu Title:
	menu.SetTitle(Title);

	//Allow Back Track:
	menu.ExitBackButton = true;

	//Menu Button:
	menu.AddItem("Abusive", "Abusive");

	menu.AddItem("Racism", "Racism");

	menu.AddItem("General cheating/exploits", "General cheating/exploits");

	menu.AddItem("Wallhack", "Wallhack");

	menu.AddItem("Aimbot", "Aimbot");

	menu.AddItem("Speedhacking", "Speedhacking");

	menu.AddItem("Mic spamming", "Mic spamming");

	menu.AddItem("Admin disrespect", "Admin disrespect");

	menu.AddItem("Camping", "Camping");

	menu.AddItem("Team killing", "Team killing");

	menu.AddItem("Unacceptable Spray", "Unacceptable Spray");

	menu.AddItem("Breaking Server Rules", "Breaking Server Rules");

	menu.AddItem("Other", "Other");

	menu.AddItem("69", "Back");

	//Set Exit Button:
	menu.ExitButton = true;

	//Show Menu:
	menu.Display(Client, 20);
}

//PlayerMenu Handle:
public int HandlePlayerBanReason(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char buffer[512];
		char Reason[255];

		//Get Menu Info:
		menu.GetItem(Parameter, Reason, 255);

		//Initialize:
		int Result = StringToInt(Reason);

		if(Result == 69)
		{

			//Show Menu:
			DisplayBanTimeMenu(Client);

			//Close:
			CloseHandle(menu);
		}

		//Override
		else
		{

			//Format:
			Format(buffer, sizeof(buffer), "INSERT INTO Player (`STEAMID`,`NAME`,`LENGTH`,`POINTOFBAN`,`REASON`) VALUES (%i,'%N',%i,%i,'%s');", SteamIdToInt(BanTarget[Client]), BanTarget[Client], BanTargetTime[Client], GetTime(), Reason);

			//Override:
			//Not Created Tables:
			SQL_TQuery(hBanDB, SQLBansErrorCheckCallback, buffer);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32#%N\x07FFFFFF has been banned from this server!", BanTarget[Client]);

			//Log:
			LogAction(Client, BanTarget[Client], "\"%L\" banned \"%L\" (minutes \"%d\") (reason \"%s\")", Client, BanTarget[Client], BanTargetTime[Client], Reason);

			//Kick Player
			KickClient(BanTarget[Client], "You have banned from this server\nReason: %s", Reason);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

public Action Command_Status(int Client, int  Args)
{

	//Is Colsole:
	if(Client != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

		//Return:
		return Plugin_Handled;
	}

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientInGame(i))
		{

			//Initialize:
			continue;
		}

		//Print:
		PrintToConsole(Client, "|RP-Bans| - %N SteamNumberId (%i)!", i, SteamIdToInt(i));
	}

	//Return:
	return Plugin_Handled;
}

public void SQLBansErrorCheckCallback(Handle owner, Handle hndl, const char[] error, any:data)
{

	//Is Error:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("RP_Core] SQLBansErrorCheckCallback: Query failed! %s", error);
#endif
	}
}
#endif