//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorbuy_included_
  #endinput
#endif
#define _rp_vendorbuy_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

public void initVendorBuy()
{

	//Commands:
	RegAdminCmd("sm_addvendoritem", Command_AddVendorItem, ADMFLAG_ROOT, "<Vendor Id> <Item Id> - Add's Item to a vendor");

	RegAdminCmd("sm_removevendoritem", Command_RemoveVendorItem, ADMFLAG_ROOT, "<Vendor Id> <Item Id> - Remove's Item from a vendor");

	RegAdminCmd("sm_viewvendorlist", Command_ViewVendorList, ADMFLAG_SLAY, "<Vendor Id> - View's vendors sql item db");

	//Timer:
	CreateTimer(0.2, CreateSQLdbVendorBuy);
}

//Create Database:
public Action CreateSQLdbVendorBuy(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VendorBuy`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `NpcId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Vendor Menus:
public void VendorMenuBuy(int Client, int VendorId, int Ent)
{

	//Has Crime
	if(GetBounty(Client) > 5000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Vendors will not speak with criminals!");

		//Return:
		return;
	}

	//Initulize:
	SetMenuTarget(Client, Ent);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i;", ServerMap(), VendorId);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVendorBuy, query, conuserid);

	//Return:
	return;
}

public void T_DBLoadVendorBuy(Handle owner, Handle hndl, const char[] error, any data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVendorBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vendor Buy Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int ItemId; 

		//Handle:
		Menu menu = CreateMenu(HandleBuy);

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 2);

			//Declare:
        	      	int Price = GetItemCost(ItemId);

			//Declare:
			char DisplayItem[64];

			//Less Char
			if(Price > 9999)
			{

				//New Price
				Price = Price / 1000;

				//Format:
				Format(DisplayItem, sizeof(DisplayItem), "[€k%i] %s", Price, GetItemName(ItemId));
			}

			//Override:
			else
			{

				//Format:
				Format(DisplayItem, sizeof(DisplayItem), "[€%i] %s", Price, GetItemName(ItemId));
			}

			//Declare:
			char ItemIndex[32];

			//Format:
			Format(ItemIndex, sizeof(ItemIndex), "%i", ItemId);

			//Menu Buttons:
			menu.AddItem(ItemIndex, DisplayItem);
		}

		//Title:
		menu.SetTitle("Hello, do you want to buy\nsome items for your inventory?");

		//Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF NPC is selling items");
	}
}

//Vendor Handle:
public int HandleBuy(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		char MuchItem[255];

		//Initulize:
		SetSelectedItem(Client, StringToInt(info));

		int ItemId = GetSelectedItem(Client);

		//Handle:
		menu = CreateMenu(HandleBuyCashOrBank);

		//Title:
		menu.SetTitle("[%s] Select if you want to pay \n by Cash or by Card! (5% fee)", GetItemName(ItemId));

		//Format:
		Format(MuchItem, 255, "Cash [€%i]", GetItemCost(ItemId));

		//Menu Button:
		menu.AddItem("0", MuchItem);

		//Format:
		Format(MuchItem, 255, "Bank [€%i]", RoundFloat(GetItemCost(ItemId)*1.05));

		//Menu Button:
		menu.AddItem("1", MuchItem);

		//Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
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

//Vendor Handle:
public int HandleBuyCashOrBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];
		int ItemId = GetSelectedItem(Client);

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int Result = StringToInt(info);

		//Declare:
		char bMax[64];
		char MuchItem[255];
		int Cost = GetItemCost(ItemId);

		if(Result == 0)
		{

			//Handle:
			menu = CreateMenu(MoreItemMenuCash);

			//Title:
			menu.SetTitle("[%s] Select amount:", GetItemName(ItemId));

			//Declare:
			int SaveMoney = GetCash(Client);
			int iMax = 0;

			//Has Enough Money:
			if(SaveMoney == Cost )
			{

				//Initialize:
				iMax = 1;
			}

			//dont Have Enough Money:
			if(SaveMoney < Cost)
			{

				//Initialize:
				iMax = 0;
			}

			//Override:
			else
			{

				//Loop:
				for(int Max = 0; SaveMoney >= Cost; Max++)
				{

					//Initialize:
					if(SaveMoney < Cost) break;

					SaveMoney -= Cost;

					iMax = Max + 1;

					if(SaveMoney < Cost) break;
				}
			}

			//Format:
			Format(MuchItem, 255, "All %i x [€%i]", iMax, Cost * iMax);

			Format(bMax, 64, "%i", iMax);

			//Menu Button:
			menu.AddItem(bMax, MuchItem);

			//Format:
			Format(MuchItem, 255, "1 x [€%i]", Cost);

			//Menu Button:
			menu.AddItem("1", MuchItem);

			//Format:
			Format(MuchItem, 255, "5 x [€%i]", Cost * 5);

			//Menu Button:
			menu.AddItem("5", MuchItem);

			//Format:
			Format(MuchItem, 255, "10 x [€%i]", Cost * 10);

			//Menu Button:
			menu.AddItem("10", MuchItem);

			//Format:
			Format(MuchItem, 255, "20 x [€%i]", Cost * 20);

			//Menu Button:
			menu.AddItem("20", MuchItem);

			//Format:
			Format(MuchItem, 255, "50 x [€%i]", Cost * 50);

			//Menu Button:
			menu.AddItem("50", MuchItem);

			//Format:
			Format(MuchItem, 255, "100 x [€%i]", Cost * 100);

			//Menu Button:
			menu.AddItem("100", MuchItem);

			//Exit Button:
			menu.ExitButton = false;

			//Show Menu:
			menu.Display(Client, 30);
		}

		//Pay By Bank!
		if(Result == 1)
		{

			//Handle:
			menu = CreateMenu(MoreItemMenuBank);

			//Title:
			menu.SetTitle("[%s] Select amount:", GetItemName(ItemId));

			//Format:
			Format(MuchItem, 255, "1 x [€%i]", RoundFloat(Cost * 1.05));

			//Menu Button:
			menu.AddItem("1", MuchItem);

			//Format:
			Format(MuchItem, 255, "5 x [€%i]", RoundFloat((Cost * 5) * 1.05));

			//Menu Button:
			menu.AddItem("5", MuchItem);

			//Format:
			Format(MuchItem, 255, "10 x [€%i]", RoundFloat((Cost * 10) * 1.05));

			//Menu Button:
			menu.AddItem("10", MuchItem);

			//Format:
			Format(MuchItem, 255, "20 x [€%i]", RoundFloat((Cost * 20) * 1.05));

			//Menu Button:
			menu.AddItem("20", MuchItem);

			//Format:
			Format(MuchItem, 255, "50 x [€%i]", RoundFloat((Cost * 50) * 1.05));

			//Menu Button:
			menu.AddItem("50", MuchItem);

			//Format:
			Format(MuchItem, 255, "100 x [€%i]", RoundFloat((Cost * 100) * 1.05));

			//Menu Button:
			menu.AddItem("100", MuchItem);

			//Exit Button:
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

public int MoreItemMenuCash(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, GetMenuTarget(Client)))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int Amount = StringToInt(info);
			int ItemId = GetSelectedItem(Client);
			int SItemCost = (GetItemCost(ItemId) * Amount);

			//Has Enoug Money
			if(GetCash(Client) >= SItemCost && GetCash(Client) >= GetItemCost(ItemId) && GetCash(Client) != 0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) - SItemCost));

				//Set Menu State:
				CashState(Client, (SItemCost));

				//Initialize:
				SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) + Amount));

				//Save:
				SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF for \x0732CD32€%i\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Cash for this item");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't talk to this NPC anymore, because you too far away!");
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

public int MoreItemMenuBank(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, GetMenuTarget(Client)))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int Amount = StringToInt(info);
			int ItemId = GetSelectedItem(Client);
			int SItemCost = RoundFloat((GetItemCost(ItemId) * Amount) * 1.05);

			//Has Enoug Money
			if(GetBank(Client) >= SItemCost && GetBank(Client) >= GetItemCost(ItemId) && GetBank(Client) != 0)
			{

				//Initialize:
				SetBank(Client, (GetBank(Client) - SItemCost));

				//Set Menu State:
				BankState(Client, (SItemCost));

				//Initialize:
				SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) + Amount));

				//Save:
				SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", GetBank(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%i\x0732CD32\x07FFFFFF x \x0732CD32%s\x0732CD32\x07FFFFFF for \x0732CD32€%i\x0732CD32\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Cash for this item");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't talk to this NPC anymore, because you too far away!");
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

//Add Vendor Item:
public Action Command_AddVendorItem(int Client, int Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_addvendoritem <vendor id> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sVendorId[255];
	char sItemId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	GetCmdArg(2, sItemId, sizeof(sItemId));

	//Declare:
	int VendorId = StringToInt(sVendorId);
	int ItemId = StringToInt(sItemId);
	char query[512];

	//Format:
	Format(query, sizeof(query), "INSERT INTO VendorBuy (`Map`,`NpcId`,`ItemId`) VALUES ('%s',%i,%i);", ServerMap(), VendorId, ItemId);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Vedndor #%s", GetItemName(ItemId), VendorId);

	//Return:
	return Plugin_Handled;
}

//Remove Vendor Item:
public Action Command_RemoveVendorItem(int Client, int Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removevendoritem <npc id> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sVendorId[255];
	char sItemId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	GetCmdArg(2, sItemId, sizeof(sItemId));

	//Declare:
	int VendorId = StringToInt(sVendorId);
	int  ItemId = StringToInt(sItemId);
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i AND ItemId = %i", ServerMap(), VendorId, ItemId);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBSearchVendorBuy, query, conuserid);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Vedndor #%s", GetItemName(ItemId), VendorId);

	//Return:
	return Plugin_Handled;
}

public void T_DBSearchVendorBuy(Handle owner, Handle hndl, const char[] error, any data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVendorBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Failed to remove Item from the DB!");

			//Return:
			return;
		}

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			int Id = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			int ItemId = SQL_FetchInt(hndl, 2);

			//Declare:
			char query[512];

			//Format:
			Format(query, sizeof(query), "DELETE FROM VendorBuy WHERE Map = '%s' AND NpcId = %i AND ItemId = %i", ServerMap(), Id, ItemId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Item %s from vendor #%s", ItemId, Id);
		}
	}
}

//List Spawns:
public Action Command_ViewVendorList(int Client, int Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_viewvendorlist <npc id>");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Vendor Buy List: %s", ServerMap());

	//Declare:
	char sVendorId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	//Declare:
	int VendorId = StringToInt(sVendorId);

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i", ServerMap(), VendorId);

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintVendorBuy, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public void T_DBPrintVendorBuy(Handle owner, Handle hndl, const char[] error, any data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVendorBuy: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ItemId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: %s", ItemId, GetItemName(ItemId));
		}
	}
}