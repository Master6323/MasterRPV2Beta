//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_settings_included_
  #endinput
#endif
#define _rp_settings_included_

//Job system:
bool CallEnable[MAXPLAYERS + 1] = {true,...};
bool RingEnable[MAXPLAYERS + 1] = {true,...};
int PingOn[MAXPLAYERS + 1] = {1,...};
int TrashTracer[MAXPLAYERS + 1] = {1,...};
int MoreHud[MAXPLAYERS + 1] = {1,...};

//Hud System
int ClientHudColor[MAXPLAYERS + 1][3];
int PlayerHudColor[MAXPLAYERS + 1][3];
int EntityHudColor[MAXPLAYERS + 1][3];
int HudEnable[MAXPLAYERS + 1] = {1,...};
int HudInfo[MAXPLAYERS + 1] = {1,...};

//Crime System:
int CrimeTracer[MAXPLAYERS + 1] = {1,...};
int BountyTracer[MAXPLAYERS + 1] = {1,...};

public void initSettings()
{

	//Commands:
	RegConsoleCmd("sm_settings", Command_Settings);

	//Timer:
	CreateTimer(0.2, CreateSQLdbsettings);
}

//Create Database:
public Action CreateSQLdbsettings(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[5120];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Settings`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) PRIMARY KEY,");

	len += Format(query[len], sizeof(query)-len, " `ClientHud` varchar(16) NOT NULL DEFAULT '50 120 255',");

	len += Format(query[len], sizeof(query)-len, " `PlayerHud` varchar(16) NOT NULL DEFAULT '50 255 120',");

	len += Format(query[len], sizeof(query)-len, " `EntityHud` varchar(16) NOT NULL DEFAULT '50 255 120',");

	len += Format(query[len], sizeof(query)-len, " `CrimeTracer` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `MoreHud` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `HudEnable` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `HudInfo` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `CallEnable` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `RingEnable` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `DrugPing` int(5) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `TrashTracer` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `BountyTracer` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Jetpack` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `JetPackEffect` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `Trails` char(32) NOT NULL DEFAULT '0^0^0');");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 55);
}

public Action LoadPlayerSettings(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Settings` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSettingsCallback, query, conuserid);
}

public void InsertSettings(int Client)
{

	//Declare:
	char buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Settings (`STEAMID`,`ClientHud`,`PlayerHud`,`CrimeTracer`,`MoreHud`,`HudEnable`,`HudInfo`,`CallEnable`,`RingEnable`,`DrugPing`,`TrashTracer`,`BountyTracer`) VALUES (%i,'120 120 255', '120 120 255', 1, 1, 1, 1, 1, 1, 0, 0, 1);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 56);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player settings.");
}

public void T_DBLoadSettingsCallback(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_settings] T_DBLoadSettingsCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player settings...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Insert Player:
			InsertSettings(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Declare:
			char Buffer[64];
			char Dump[3][64];

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, " ", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				ClientHudColor[Client][X] = StringToInt(Dump[X]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, " ", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				PlayerHudColor[Client][X] = StringToInt(Dump[X]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, " ", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				EntityHudColor[Client][X] = StringToInt(Dump[X]);
			}

			//Database Field Loading INTEGER:
			CrimeTracer[Client] = SQL_FetchInt(hndl, 4);

			//Database Field Loading INTEGER:
			MoreHud[Client] = SQL_FetchInt(hndl, 5);

			//Database Field Loading INTEGER:
			HudEnable[Client] = SQL_FetchInt(hndl, 6);

			//Database Field Loading INTEGER:
			HudInfo[Client] = SQL_FetchInt(hndl, 7);

			//Database Field Loading INTEGER:
			CallEnable[Client] = intTobool(SQL_FetchInt(hndl, 8));

			//Database Field Loading INTEGER:
			RingEnable[Client] = intTobool(SQL_FetchInt(hndl, 9));

			//Database Field Loading INTEGER:
			PingOn[Client] = SQL_FetchInt(hndl, 10);

			//Database Field Loading INTEGER:
			TrashTracer[Client] = SQL_FetchInt(hndl, 11);

			//Database Field Loading INTEGER:
			BountyTracer[Client] = SQL_FetchInt(hndl, 12);

			//Database Field Loading INTEGER:
			SetJetPackEnabled(Client, intTobool(SQL_FetchInt(hndl, 13)));

			//Database Field Loading INTEGER:
			SetJetPackEffect(Client, SQL_FetchInt(hndl, 14));

			//Database Field Loading String:
			SQL_FetchString(hndl, 15, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Database Field Loading INTEGER:
				SetPlayerTrail(Client, X, StringToInt(Dump[X]));
			}

			//Print:
			PrintToConsole(Client, "|RP| player settings loaded.");
		}
	}
}

public Action Command_Settings(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Handle:
	Menu menu = CreateMenu(HandleSettings);

	//Title:
	menu.SetTitle("You can change your settings\n of a variation of properties\n\nSome settings will not be avaiable\ndue to you don't have the item\n or you do not have permissions.");

	//Menu Button:
	menu.AddItem("0", "Hud");

	menu.AddItem("1", "Tracers");

	menu.AddItem("2", "Phone");

	menu.AddItem("3", "Model");

	menu.AddItem("4", "Hats");

	menu.AddItem("5", "JetPack");

	menu.AddItem("6", "Drug Ping");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Return:
	return Plugin_Handled;
}

//Item Handle:
public int HandleSettings(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Handle:
			menu = CreateMenu(HandleHud);

			//Title:
			menu.SetTitle("you can change the properties\nof the main hud and all the\nnotice colours of the hud:");

			//Declare:
			char State[128];

			//Format:
			Format(State, sizeof(State), "Hud is %s", HudEnable[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("0", State);

			//Format:
			Format(State, sizeof(State), "More Hud is %s", MoreHud[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("1", State);

			//Format:
			Format(State, sizeof(State), "Hud Info is %s", HudInfo[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("2", State);

			//Menu Button:
			menu.AddItem("3", "Change Hud color");

			menu.AddItem("4", "Change Player Color");

			menu.AddItem("5", "Change Entity Color");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(HandleTracer);

			//Title:
			menu.SetTitle("Here you can change the settings of\nyour tracers and items:");

			//Declare:
			char State[128];

			//Format:
			Format(State, sizeof(State), "Crime tracer is %s", CrimeTracer[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("0", State);

			//Format:
			Format(State, sizeof(State), "Bounty tracer is %s", BountyTracer[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("1", State);

			//Format:
			Format(State, sizeof(State), "Trash tracer is %s", TrashTracer[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("2", State);

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Handle:
			menu = CreateMenu(HandlePhone);

			//Title:
			menu.SetTitle("Here you can change the settings of\nyour game phone:");

			//Declare:
			char State[128];

			//Format:
			Format(State, sizeof(State), "Phone is %s", CallEnable[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("0", State);

			//Format:
			Format(State, sizeof(State), "Phone Ring is %s", RingEnable[Client] ? "on" : "off");

			//Menu Button:
			menu.AddItem("1", State);

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Handle:
			menu = CreateMenu(HandleModelMenu);

			//Menu Title:
			menu.SetTitle("Here you can change your\nplayer model:");

			//Is Donator:
			if(GetDonator(Client) == 1)
			{

				//Menu Button:
				menu.AddItem("1", "Student Skins");
			}

			//Is Donator:
			if(GetDonator(Client) == 2)
			{

				//Menu Button:
				menu.AddItem("2", "Special Skins");
			}

			//Is Admin:
			if(IsAdmin(Client))
			{

				//Menu Button:
				menu.AddItem("3", "Admin Models");
			}

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		if(Result == 5)
		{

			//Valid Job:
			if(IsAdmin(Client) || GetDonator(Client) > 0)
			{

				//Show Menu:
				JetPackMenu(Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have access this this menu!");
			}
		}

		//Button Selected:
		if(Result == 4)
		{

			//Valid Job:
			if(IsAdmin(Client) || GetDonator(Client) > 0)
			{

				//Show Menu:
				DrawHatMenu(Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have access this this menu!");
			}
		}

		//Button Selected:
		if(Result == 6)
		{

			//Valid Job:
			if(PingOn[Client] == 0)
			{

				//Initulize:
				PingOn[Client] = 1;
			}

			//Override:
			else
			{

				//Initulize:
				PingOn[Client] = 0;
			}

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET DrugPing = %i WHERE STEAMID = %i;", PingOn[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 57);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have toggled Drug Ping Detector!");
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

//Item Handle:
public int HandleHud(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Is Valid:
			if(HudEnable[Client] == 0)
			{

				//Set Phone Status:
				HudEnable[Client] = 1;
			}

			//Override:
			else
			{

				//Set Phone Status:
				HudEnable[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Hud has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET HudEnable = %i WHERE STEAMID = %i;", HudEnable[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 58);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Is Valid:
			if(MoreHud[Client] == 0)
			{

				//Set Phone Status:
				MoreHud[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				MoreHud[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - More Hud has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET MoreHud = %i WHERE STEAMID = %i;", MoreHud[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 59);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Is Valid:
			if(HudInfo[Client] == 0)
			{

				//Set Phone Status:
				HudInfo[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				HudInfo[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Hud has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET HudInfo = %i WHERE STEAMID = %i;", HudEnable[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 60);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Handle:
			menu = CreateMenu(HandleColourChange);

			//Title:
			menu.SetTitle("Change main hud colour:");

			//Menu Button:
			menu.AddItem("0 50 120 250", "Blue");

			menu.AddItem("0 250 220 10", "Yellow");

			menu.AddItem("0 250 50 50", "Red");

			menu.AddItem("0 50 250 50", "Green");

			menu.AddItem("0 250 250 250", "White");

			menu.AddItem("0 240 25 140", "Pink");

			menu.AddItem("0 181 5 250", "Purple");

			menu.AddItem("0 250 130 10", "Orange");

			menu.AddItem("0 50 250 250", "Light blue");

			menu.AddItem("0 135 220 40", "Light Green");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		else if(Result == 4)
		{

			//Handle:
			menu = CreateMenu(HandleColourChange);

			//Title:
			menu.SetTitle("Change Player hud colour:");

			//Menu Button:
			menu.AddItem("1 50 50 250", "Blue");

			menu.AddItem("1 250 220 10", "Yellow");

			menu.AddItem("1 250 50 50", "Red");

			menu.AddItem("1 50 250 50", "Green");

			menu.AddItem("1 250 250 250", "White");

			menu.AddItem("1 240 25 140", "Pink");

			menu.AddItem("1 181 5 250", "Purple");

			menu.AddItem("1 250 130 10", "Orange");

			menu.AddItem("1 50 250 250", "Light blue");

			menu.AddItem("1 135 220 250", "Light Green");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Button Selected:
		else if(Result == 5)
		{

			//Handle:
			menu = CreateMenu(HandleColourChange);

			//Title:
			menu.SetTitle("Change Entity hud colour:");

			//Menu Button:
			menu.AddItem("2 50 50 250", "Blue");

			menu.AddItem("2 250 220 10", "Yellow");

			menu.AddItem("2 250 50 50", "Red");

			menu.AddItem("2 50 250 50", "Green");

			menu.AddItem("2 250 250 250", "White");

			menu.AddItem("2 240 25 140", "Pink");

			menu.AddItem("2 181 5 250", "Purple");

			menu.AddItem("2 250 130 10", "Orange");

			menu.AddItem("2 50 250 250", "Light blue");

			menu.AddItem("2 135 220 250", "Light Green");

			//Set Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
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

//Item Handle:
public int HandleColourChange(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char query[512];
		char info[64];
		char buffer[4][64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Explode:
		ExplodeString(info, " ", buffer, 4, sizeof(buffer));

		//Declare:
		int HudType = RoundFloat(StringToFloat(buffer[0]));

		if(HudType == 0)
		{

			//Change Hud Color:
			ClientHudColor[Client][0] = StringToInt(buffer[1]);

			ClientHudColor[Client][1] = StringToInt(buffer[2]);

			ClientHudColor[Client][2] = StringToInt(buffer[3]);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed your hud color to (\x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF)", buffer[1], buffer[2], buffer[3]);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET ClientHud = '%i %i %i' WHERE STEAMID = %i", ClientHudColor[Client][0], ClientHudColor[Client][1], ClientHudColor[Client][2], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 61);
		}

		if(HudType == 1)
		{

			//Change Hud Color:
			PlayerHudColor[Client][0] = StringToInt(buffer[1]);

			PlayerHudColor[Client][1] = StringToInt(buffer[2]);

			PlayerHudColor[Client][2] = StringToInt(buffer[3]);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed your hud color to (\x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF)", buffer[1], buffer[2], buffer[3]);

			//Sql Strings:
			Format(query,sizeof(query), "UPDATE Settings SET PlayerHud = '%i %i %i' WHERE STEAMID = %i", PlayerHudColor[Client][0], PlayerHudColor[Client][1], PlayerHudColor[Client][2], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 62);
		}

		if(HudType == 2)
		{

			//Change Hud Color:
			EntityHudColor[Client][0] = StringToInt(buffer[1]);

			EntityHudColor[Client][1] = StringToInt(buffer[2]);

			EntityHudColor[Client][2] = StringToInt(buffer[3]);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed your hud color to (\x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF)", buffer[1], buffer[2], buffer[3]);

			//Sql Strings:
			Format(query,sizeof(query), "UPDATE Settings SET EntityHud = '%i %i %i' WHERE STEAMID = %i", EntityHudColor[Client][0], EntityHudColor[Client][1], EntityHudColor[Client][2], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 63);
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

//Item Handle:
public int HandleTracer(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Is Valid:
			if(CrimeTracer[Client] == 0)
			{

				//Set Phone Status:
				CrimeTracer[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				CrimeTracer[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Crime tracer has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET CrimeTracer = %i WHERE STEAMID = %i;", CrimeTracer[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 64);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Is Valid:
			if(BountyTracer[Client] == 0)
			{

				//Set Phone Status:
				BountyTracer[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				BountyTracer[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Bounty tracer has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET BountyTracer = %i WHERE STEAMID = %i;", BountyTracer[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 65);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Is Valid:
			if(TrashTracer[Client] == 0)
			{

				//Set Phone Status:
				TrashTracer[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				TrashTracer[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - trash tracer has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET TrashTracer = %i WHERE STEAMID = %i;", TrashTracer[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 66);
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

//Item Handle:
public int HandlePhone(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Is Valid:
			if(!CallEnable[Client])
			{

				//Set Phone Status:
				CallEnable[Client] = true;
			}

			//Override:
			else
			{
				//Set Phone Status:
				CallEnable[Client] = false;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Phone has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET CallEnable = %i WHERE STEAMID = %i;", boolToint(CallEnable[Client]), SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 67);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Is Valid:
			if(!RingEnable[Client])
			{

				//Set Phone Status:
				RingEnable[Client] = true;
			}

			//Override:
			else
			{
				//Set Phone Status:
				RingEnable[Client] = false;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Phone Ring has been toggled.");

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET RingEnable = %i WHERE STEAMID = %i;", boolToint(RingEnable[Client]), SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 68);
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

//Menu Handle:
public int HandleModelMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 1)
		{

			//Is Donator:
			if(GetDonator(Client) == 1)
			{

				//Handle:
				menu = CreateMenu(HandleModel);

				//Menu Title:
				menu.SetTitle("Pick A Model to Change to:");

				 //Menu Button:
				menu.AddItem("models/alyx.mdl", "Alyx");

				menu.AddItem("models/barney.mdl", "Barney");

				menu.AddItem("models/eli.mdl", "Eli");

				menu.AddItem("models/kleiner.mdl", "Kleiner");

				menu.AddItem("models/monk.mdl", "Monk");

				menu.AddItem("models/mossman.mdl", "Mossman");

				//Set Exit Button:
				menu.ExitButton = false;

				//Show Menu:
				menu.Display(Client, 30);

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have access to this Menu");
			}
		}

		//Button Selected:
		if(Result == 2)
		{

			//Is Donator:
			if(GetDonator(Client) == 2)
			{

				//Handle:
				menu = CreateMenu(HandleModel);

				//Menu Title:
				menu.SetTitle("Pick A Model to Change to:");

				 //Menu Button:
				menu.AddItem("models/alyx.mdl", "Alyx");

				menu.AddItem("models/barney.mdl", "Barney");

				menu.AddItem("models/eli.mdl", "Eli");

				menu.AddItem("models/kleiner.mdl", "Kleiner");

				menu.AddItem("models/monk.mdl", "Monk");

				menu.AddItem("models/mossman.mdl", "Mossman");

				menu.AddItem("models/combine_soldier_prisonguard.mdl", "Prison Guard");

				menu.AddItem("models/combine_soldier.mdl", "Soldier");

				menu.AddItem("models/combine_super_soldier.mdl", "Super Soldier");

				//Set Exit Button:
				menu.ExitButton = false;

				//Show Menu:
				menu.Display(Client, 30);

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have access to this Menu");
			}
		}

		//Button Selected:
		if(Result == 3)
		{

			//Is Valid:
			if(IsAdmin(Client))
			{

				//Handle:
				menu = CreateMenu(HandleModel);

				//Menu Title:
				menu.SetTitle("Pick A Model to Change to:");

				 //Menu Button:
				menu.AddItem("models/alyx.mdl", "Alyx");

				menu.AddItem("models/barney.mdl", "Barney");

				menu.AddItem("models/eli.mdl", "Eli");

				menu.AddItem("models/gman.mdl", "Gman");

				menu.AddItem("models/kleiner.mdl", "Kleiner");

				menu.AddItem("models/monk.mdl", "Monk");

				menu.AddItem("models/mossman.mdl", "Mossman");

				menu.AddItem("models/headcrabblack.mdl", "Facehugger");

				menu.AddItem("models/police.mdl", "Police");

				menu.AddItem("models/combine_soldier_prisonguard.mdl", "Prison Guard");

				menu.AddItem("models/combine_soldier.mdl", "Soldier");

				menu.AddItem("models/combine_super_soldier.mdl", "Super Soldier");

				//Set Exit Button:
				menu.ExitButton = false;

				//Show Menu:
				menu.Display(Client, 30);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have access to this Menu");
			}
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

//Model Menu Handle:
public int HandleModel(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			char info[255];
			char display[255];
			char Model[128];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Get Model:
			GetClientModel(Client, Model, sizeof(Model));

			//Is Valid:
			if(!StrEqual(Model, info, false) && !IsCop(Client))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your Model has Changed tp %s.", display);

				//Declare:
				SetModel(Client, info);
			}

			//Is Police:
			else if(IsCop(Client))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are a cop you cannot change your skin");
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already have this skin on");
			}
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

public void SetTalkZone(Client)
{

	//Initialize:
	CallEnable[Client] = true;

	RingEnable[Client] = true;

	MoreHud[Client] = 1;
}

public bool GetCallEnable(Client)
{

	//Return:
	return CallEnable[Client];
}

public void SetCallEnable(int Client, bool Result)
{

	//Initulize:
	CallEnable[Client] = Result;
}

public bool GetRingEnable(int Client)
{

	//Return:
	return RingEnable[Client];
}

public void SetRingEnable(int Client, bool Result)
{

	//Initulize:
	RingEnable[Client] = Result;
}

public int GetMoreHud(int Client)
{

	//Return:
	return MoreHud[Client];
}

public int GetHudInfo(int Client)
{

	//Return:
	return HudInfo[Client];
}

public int GetPing(int Client)
{

	//Return:
	return PingOn[Client];
}

public int GetTrashTracer(int Client)
{

	//Return:
	return TrashTracer[Client];
}

public int GetCrimeTracer(int Client)
{

	//Return:
	return CrimeTracer[Client];
}

public int GetBountyTracer(int Client)
{

	//Return:
	return BountyTracer[Client];
}

public void SetMoreHud(int Client, Amount)
{

	//Initulize:
	MoreHud[Client] = Amount;
}

public int GetClientHudColor(int Client, int Id)
{

	//Return:
	return ClientHudColor[Client][Id];
}

public int GetPlayerHudColor(int Client, int Id)
{

	//Return:
	return PlayerHudColor[Client][Id];
}

public int GetEntityHudColor(int Client, int Id)
{

	//Return:
	return EntityHudColor[Client][Id];
}


public void initHudColor(Client)
{

	//Loop:
	for(new X = 0; X < 3; X++)
	{

		//Initulize:
		ClientHudColor[Client][X] = 255;

		PlayerHudColor[Client][X] = 255;

		EntityHudColor[Client][X] = 255;
	}
}
