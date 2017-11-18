//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_trail_included_
  #endinput
#endif
#define _rp_trail_included_

#define MAXTRAILS	3

int PlayerTrail[MAXPLAYERS + 1][MAXTRAILS];

public void initPlayerTrails()
{

	//Commands:
	RegConsoleCmd("sm_trails", Command_PlayerTrails);

	RegAdminCmd("sm_settrail", Command_SetTrail, ADMFLAG_ROOT, "<Slot> <Trail>- set the a player a status!");
}

public void initPlayerTrailEffects(int Client, int Timer)
{

	//Limit Timer to hud!
	if(Timer == 1 || Timer == 3 || Timer == 5 || Timer == 7 || Timer == 9)
	{

		//Is Player Alive:
		if(IsPlayerAlive(Client))
		{

			//Loop:
			for(int i = 0; i < MAXTRAILS; i++)
			{

				//Declare:
				int EntSlot = GetEntAttatchedEffect(Client, i);

				//Check:
				if(IsValidEntity(EntSlot))
				{

					//Check:
					if(PlayerTrail[Client][i] >= 15 && PlayerTrail[Client][i] <= 21)
					{

						//Accept:
						AcceptEntityInput(EntSlot, "DoSpark");
					}

					//Check:
					if(PlayerTrail[Client][i] == 22)
					{

						//Accept:
						AcceptEntityInput(EntSlot, "EmitBlood");
					}
				}
			}
		}
	}
}

public void CreatePlayerTrails(int Client)
{

	//Declare:
	int Effect = -1;

	//Loop:
	for(int i = 0; i < MAXTRAILS; i++)
	{

		//Switch:
		switch(PlayerTrail[Client][i])
		{

			//Fire On Face:
			case 1:
			{

				//Initulize:
				Effect = CreateFireSmoke(Client, "Eyes", "200", "700", "0", "Natural");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Red Smoke Effect:
			case 2:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 50 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Blue Smoke Effect:
			case 3:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "50 50 255", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Green Smoke Effect:
			case 4:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "50 255 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Yellow Smoke Effect:
			case 5:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 255 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Gray Smoke Effect:
			case 6:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 255 255", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Black Smoke Effect:
			case 7:
			{

				//Initulize:
				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "50 50 50", "5");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Red Light:
			case 8:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 255, 120, 120, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Blue Light:
			case 9:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 120, 120, 255, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Green Light:
			case 10:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 120, 255, 120, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Yellow Light:
			case 11:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 240, 230, 50, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Purple Light:
			case 12:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 240, 20, 230, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//White Light:
			case 13:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 240, 230, 240, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Black Light:
			case 14:
			{

				//Initulize:
				Effect = CreateLight(Client, 1, 120, 130, 120, "null");

				SetEntAttatchedEffect(Client, i, Effect);
			}

			//Red Tesla:
			case 15:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "250 50 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Blue Tesla:
			case 16:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "50 50 250");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Green Tesla:
			case 17:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "120 250 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Yellow Tesla:
			case 18:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "240 230 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Purple Tesla:
			case 19:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "250 50 250");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Orange Tesla:
			case 20:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "240 200 50");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//White Tesla:
			case 21:
			{

				//Initulize:
				Effect = CreatePointTeslaNoSound(Client, "chest", "250 255 250");

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Blood:
			case 22:
			{

				//Declare:
				float Direction[3] = {0.0, 0.0, 0.0};

				//Initulize:
				Effect = CreateEnvBlood(Client, "null", Direction, 0.0);

				SetEntAttatchedEffect(Client, i, Effect);

				//SDKHOOK:
				SDKHook(Effect, SDKHook_SetTransmit, OnPlayerTrailTransmit);
			}

			//Fire Of Plasma:
			case 23:
			{

				//Initulize:
				Effect = CreatePlasmaSmoke(Client, "Eyes");

				SetEntAttatchedEffect(Client, i, Effect);
			}

		}
	}
}

public Action Command_PlayerTrails(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//Override:
	else
	{

		//Show Menu:
		PlayerTrailMenu(Client);
	}

	//Return:
	return Plugin_Handled;
}

public void PlayerTrailMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandlePlayerTrailMenu);

	//Menu Title:
	menu.SetTitle("Player Trail Menu");

	//Declare:
	char State[128];
	char Index[32];

	//Loop:
	for(int i = 0; i < MAXTRAILS; i++)
	{

		//Format:
		Format(State, sizeof(State), "Slot (%i) has %i", i, PlayerTrail[Client][i]);

		//Initulize:
		IntToString(i, Index, sizeof(Index));

		//Menu Button:
		menu.AddItem(Index, State);
	}

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Trail|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Handle:
public int HandlePlayerTrailMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int IndexSlot = StringToInt(info);

			//Initulize:
			SetMenuTarget(Client, IndexSlot);

			//Show Menu:
			SelectTrailTypeMenu(Client);
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

public void SelectTrailTypeMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleSelectTrailTypeMenu);

	//Menu Title:
	menu.SetTitle("What Effect type would you like to put on?");

	//Menu Button:
	menu.AddItem("1", "Misc Trails!");

	//Menu Button:
	menu.AddItem("2", "Smoke Trails!");

	//Menu Button:
	menu.AddItem("3", "Light Trails!");

	//Menu Button:
	menu.AddItem("4", "Tesla Trails!");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);
}

//Handle:
public int HandleSelectTrailTypeMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info));

			//Declare:
			int SelectedType = StringToInt(info);

			//Show Menu:
			SelectTrailMenu(Client, SelectedType);
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

public void SelectTrailMenu(int Client, int SelectedType)
{

	//Handle:
	Menu menu = CreateMenu(HandleSelectTrailMenu);

	//Menu Title:
	menu.SetTitle("What Effect would you like to put on?");

	//Declare:
	bool ShowMenu = false;

	//Check:
	if(IsAdmin(Client) || GetDonator(Client))
	{

		//Switch:
		switch(SelectedType)
		{

			//Misc Trails:
			case 1:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				menu.AddItem("1", "Face of Fire!");

				//Menu Button:
				menu.AddItem("22", "Blood Trail!");

				//Menu Button:
				menu.AddItem("23", "Face of Plasma!");
			}

			//Smoke Trails:
			case 2:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				menu.AddItem("2", "Red Smoke Trail!");

				//Menu Button:
				menu.AddItem("3", "Blue Smoke Trail!");

				//Menu Button:
				menu.AddItem("4", "Green Smoke Trail!");

				//Menu Button:
				menu.AddItem("5", "Gray Smoke Trail!");

				//Menu Button:
				menu.AddItem("6", "Yellow Smoke Trail!");

				//Menu Button:
				menu.AddItem("7", "Black Smoke Trail!");
			}

			//Light Trails:
			case 3:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				menu.AddItem("8", "Red Light Trail!");

				//Menu Button:
				menu.AddItem("9", "Blue Light Trail!");

				//Menu Button:
				menu.AddItem("10", "Green Light Trail!");

				//Menu Button:
				menu.AddItem("11", "Yellow Light Trail!");

				//Menu Button:
				menu.AddItem("12", "Purple Light Trail!");

				//Menu Button:
				menu.AddItem("13", "White Light Trail!");

				//Menu Button:
				menu.AddItem("14", "Black Light Trail!");
			}

			//Tesla Trails:
			case 4:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				menu.AddItem("15", "Red Tesla Trail!");

				//Menu Button:
				menu.AddItem("16", "Blue Tesla Trail!");

				//Menu Button:
				menu.AddItem("17", "Green Tesla Trail!");

				//Menu Button:
				menu.AddItem("18", "Yellow Tesla Trail!");

				//Menu Button:
				menu.AddItem("19", "Purple Tesla Trail!");

				//Menu Button:
				menu.AddItem("20", "Orange Tesla Trail!");

				//Menu Button:
				menu.AddItem("21", "White Tesla Trail!");
			}
		}

		//Initulize:
		ShowMenu = true;
	}

	//Has JetPack In Inventory:
	if(!HasItemTypeInInventory(Client, 61))
	{

		//Switch:
		switch(SelectedType)
		{

			//Misc Trails:
			case 1:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 388) > 0) menu.AddItem("1", "Face of Fire!");

				//Menu Button:
				if(GetItemAmount(Client, 389) > 0) menu.AddItem("22", "Blood Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 410) > 0) menu.AddItem("23", "Face Of Plasma!");
			}

			//Smoke Trails:
			case 2:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 390) > 0) menu.AddItem("2", "Red Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 391) > 0) menu.AddItem("3", "Blue Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 392) > 0) menu.AddItem("4", "Green Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 393) > 0) menu.AddItem("5", "Gray Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 394) > 0) menu.AddItem("6", "Yellow Smoke Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 395) > 0) menu.AddItem("7", "Black Smoke Trail!");
			}

			//Light Trails:
			case 3:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 396) > 0) menu.AddItem("8", "Red Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 397) > 0) menu.AddItem("9", "Blue Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 398) > 0) menu.AddItem("10", "Green Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 399) > 0) menu.AddItem("11", "Yellow Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 400) > 0) menu.AddItem("12", "Purple Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 401) > 0) menu.AddItem("13", "White Light Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 402) > 0) menu.AddItem("14", "Black Light Trail!");
			}

			//Tesla Trails:
			case 4:
			{

				//Menu Button:
				menu.AddItem("0", "Default:0");

				//Menu Button:
				if(GetItemAmount(Client, 403) > 0) menu.AddItem("15", "Red Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 404) > 0) menu.AddItem("16", "Blue Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 405) > 0) menu.AddItem("17", "Green Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 406) > 0) menu.AddItem("18", "Yellow Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 407) > 0) menu.AddItem("19", "Purple Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 408) > 0) menu.AddItem("20", "Orange Tesla Trail!");

				//Menu Button:
				if(GetItemAmount(Client, 409) > 0) menu.AddItem("21", "White Tesla Trail!");
			}
		}

		//Initulize:
		ShowMenu = true;
	}

	//Check:
	if(ShowMenu)
	{

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Has JetPack In Inventory:
	else if(!HasItemTypeInInventory(Client, 61))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have any Trail items!");
	}

	//Override:
	else
	{

		//Close:
		delete menu;
	}
}

//Handle:
public int HandleSelectTrailMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[64];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Declare:
			int SelectedTrail = StringToInt(info);

			//Check:
			if(!HasPlayerAlreadyAttachedTrail(Client, SelectedTrail))
			{

				//Declare:
				int IndexSlot = GetMenuTarget(Client);

				//Initulize:
				PlayerTrail[Client][IndexSlot] = SelectedTrail;

				//Check:
				if(IsValidAttachedEffect(Client))
				{

					//Remove:
					RemoveAttachedEffect(Client);
				}

				//Create Trail:
				CreatePlayerTrails(Client);

				//Save:
				SavePlayerTrail(Client);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your new Trail is a \x0732CD32%s\x07FFFFFF Index (#%i) Slot(#%i)!", display, IndexSlot, SelectedTrail);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF -You already have this Trail attached!");
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

public Action Command_SetTrail(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_settrail <Slot> <Trail>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Declare:
	int Slot = StringToInt(Arg1);

	//Check:
	if(Slot < 0 || Slot > MAXTRAILS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_settrail <0-%i> <Trail>", MAXTRAILS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Declare:
	int SelectedTrail = StringToInt(Arg2);

	//Initulize:
	PlayerTrail[Client][Slot] = SelectedTrail;

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}

	//Create Trail:
	CreatePlayerTrails(Client);

	//Save:
	SavePlayerTrail(Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - New Trail selected Index (#%i) Slot(#%i)!", SelectedTrail, Slot);

	//Return:
	return Plugin_Handled;
}

public Action OnPlayerTrailTransmit(int Ent, int Client)
{

	//Connected:
	if(Ent > 0 && IsValidEdict(Ent) && IsClientConnected(Client) && IsClientInGame(Client))
	{

		if(GetObserverMode(Client) == 5 || GetViewWearables(Client))
		{

			//Return:
			return Plugin_Continue;
		}

		//Check Observer Mode:
		if(GetObserverMode(Client) == 4 && GetObserverTarget(Client) >= 0)
		{

			//Declare:
			int Owner = FindClientFromAttachedEnt(Ent);

			//Check:
			if(Owner == Client)
			{

				//Declare:
				int Slot = FindEntitySlot(Ent);

				//Check:
				if(GetEntAttatchedEffect(Owner, Slot) == Ent)
				{

					//Return:
					return Plugin_Handled;
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool HasPlayerAlreadyAttachedTrail(int Client, int Trail)
{

	//Declare:
	bool Result = false;

	//Loop:
	for(int i = 0; i < MAXTRAILS; i++)
	{

		//Check:
		if(PlayerTrail[Client][i] == Trail || Trail == 0)
		{

			//Initulize:
			Result = true;

			//Stop:
			break;
		}
	}

	//Return:
	return Result;
}

public void SetPlayerTrail(int Client, int Type, int Trail)
{

	//Initulize:
	PlayerTrail[Client][Type] = Trail;
}

public void SavePlayerTrail(int Client)
{

	//Declare:
	char query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE Settings SET Trails = '%i^%i^%i' WHERE STEAMID = %i;", PlayerTrail[Client][0], PlayerTrail[Client][1], PlayerTrail[Client][2], SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 69);
}