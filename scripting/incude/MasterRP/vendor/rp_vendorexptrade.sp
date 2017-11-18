//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorexptrade_included_
  #endinput
#endif
#define _rp_vendorexptrade_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Job Experience Menu:
public void ExperienceMenu(int Client)
{

	//Declare:
	char FormatTitle[50];

	//Format:
	Format(FormatTitle, 50, "Job Experience (%i)", GetJobExperience(Client));

	//Handle:
	Menu menu = CreateMenu(HandleJobExp);

	//Menu Title:
	menu.SetTitle(FormatTitle);

	//Add Menu Item:
	menu.AddItem("0", "Trade Job Exp");

	menu.AddItem("1", "View Exchange Rate");

	menu.AddItem("2", "Buy Items...");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Custom Job Items:
public void JobItemsMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleJobExpBuy);
	
	//Declare:
	bool ShowMenu = false;

	//Loop:
	for(int X = 0; X < 400; X++)
	{

		//Selected Group:
		if(GetItemGroup(X) == 14)
		{

			//No Item
			if(GetItemAmount(Client, X) == 0)
			{

				//Declare:
				char ActionItemId[255];
				char MenuItemName[32];
				char ItemId[255];

				//Declare:
        	      		int Price = (GetItemCost(X) / 1000);

				//Format:
				Format(MenuItemName, 32, "[%iK] %s", Price, GetItemName(X));

				//Convert:
				IntToString(X, ItemId, 255);

				//Format:
				Format(ActionItemId, 255, "%s 0", ItemId);

				//Add Menu Item:
				menu.AddItem(ActionItemId, MenuItemName);

				//Initialize:
				ShowMenu = true;
			}
		}
	}

	//Show:
	if(ShowMenu == true)
	{

		//Declare:
		decl String:Title[255];

		//Format:
		Format(Title, 255, "This menu allows you to buy\nspecial items with the job\nexperience you've earned\nYou have %i Experience", GetJobExperience(Client));

		//Menu Title:
		menu.SetTitle(Title);

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Override:
	else
	{

		//Close:
		delete menu;
	}
}

//Trade Experience Menu:
public void TradeExperienceMenu(int Client)
{

	//Declare:
	char AllBank[32];
	char bAllBank[32];

	//Format:
	Format(AllBank, 32, "All (%i)", GetJobExperience(Client));

	Format(bAllBank, 32, "%i", GetJobExperience(Client));

	//Handle:
	Menu menu = CreateMenu(HandleTraderEx);

	//Menu Title:
	menu.SetTitle("How Much to Trade:");

	//Menu Button:
	menu.AddItem(bAllBank, AllBank);

	menu.AddItem("1", "1");

	menu.AddItem("5", "5");

	menu.AddItem("10", "10");

	menu.AddItem("20", "20");

	menu.AddItem("50", "50");

	menu.AddItem("100", "100");

	menu.AddItem("200", "200");

	menu.AddItem("500", "500");

	menu.AddItem("1000", "1000");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 20);
}

//BankMenu Handle:
public int HandleJobExp(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Declare:
		int Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Show Menu:
			TradeExperienceMenu(Client);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD321.0XP\x07FFFFFF|€\x0732CD32%0.1f\x07FFFFFF Exchange Rate For Money.", 5.0);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			JobItemsMenu(Client);
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

public int HandleTraderEx(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[64];

		//Get Menu Info::
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int Amount = StringToInt(info);

		//Is Valid:
		if((GetJobExperience(Client) - Amount > 0) && GetJobExperience(Client) != 0)
		{

			//Initialize:
			int TradedXp = RoundToNearest(Amount*5.0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have traded \x0732CD32%i\x07FFFFFF xp for \x0732CD32€%i", Amount , TradedXp);

			//Initialize:
			SetBank(Client, (GetBank(Client) + TradedXp));

			//Initialize:
			SetJobExperience(Client, (GetJobExperience(Client) - Amount));

			//Set Menu State:
			BankState(Client, TradedXp);

			//Play Sound:
			EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much experience.");
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

public int HandleJobExpBuy(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		char info[32];

		//Get Menu Info:
		menu.GetItem(Parameter, info, sizeof(info));

		//Initialize:
		int ItemId = StringToInt(info);
		int SItemCost = GetItemCost(ItemId);

		//Has Enoug Money
		if(GetJobExperience(Client) >= SItemCost)
		{

			//Initialize:
			SetJobExperience(Client, (GetJobExperience(Client) - SItemCost));

			//Save:
			SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) + 1));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%s\x07FFFFFF for \x0732CD32€%%i\x07FFFFFF Job Experience.", GetItemName(ItemId), SItemCost);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Job Experience for this item");
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
