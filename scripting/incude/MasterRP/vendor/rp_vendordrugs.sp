//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendordrugs_included_
  #endinput
#endif
#define _rp_vendordrugs_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

public void VendorDrugSell(int Client)
{

	//Is In Time:
	if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && (GetHarvest(Client) > 0 || GetMeth(Client) > 0 || GetCocain(Client) > 0 || GetPills(Client) > 0 || GetRice(Client) > 0 || GetResources(Client) > 0))
	{

		//Initulize:
		int  AddCash = RoundFloat(float(GetHarvest(Client)) * 2.9);

		AddCash += RoundFloat(float(GetMeth(Client)) * 9.5);

		AddCash += RoundFloat(float(GetPills(Client)) * 30);

		AddCash += RoundFloat(float(GetCocain(Client)) * 100);

		AddCash += RoundFloat(float(GetRice(Client)) * 2.5);

		AddCash += GetResources(Client);

		int OldHarvest = GetHarvest(Client);

		OldHarvest += GetMeth(Client);

		OldHarvest += GetCocain(Client);

		OldHarvest += GetPills(Client);

		OldHarvest += GetRice(Client);

		OldHarvest += GetResources(Client);

		SetCash(Client, (GetCash(Client) + AddCash));

		//Set Menu State:
		CashState(Client, AddCash);

		//Initulize:
		SetCrime(Client, (GetCrime(Client) + GetHarvest(Client) + (GetMeth(Client) * 5) + (GetPills(Client) * 10) + (GetResources(Client) / 2) + (GetCocain(Client) * 20)));

		//Initulize:
		SetHarvest(Client, 0);

		SetMeth(Client, 0);

		SetCocain(Client, 0);

		SetPills(Client, 0);

		SetRice(Client, 0);

		SetResources(Client, 0);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFF Grams and made \x0732CD32€%i\x07FFFFFF!", OldHarvest, AddCash);
	}

	//Override:
	else if((GetHarvest(Client) > 0 || GetMeth(Client) > 0 || GetPills(Client) > 0 || GetRice(Client) > 0 || GetResources(Client) > 0 || GetCocain(Client) > 0))
	{


		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - Press \x0732CD32'use'\x07FFFFFF to quick sell!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Declare:
	char display[32];

	//Handle:
	Menu menu = CreateMenu(HandleDrugMenu);

	//Menu Title:
	menu.SetTitle("This Npc Can exchange your\nbuy and sell drugs here");

	//Check:
	if(GetHarvest(Client) != 0 || GetMeth(Client) != 0 || GetPills(Client) != 0 || GetRice(Client) != 0 || GetResources(Client) != 0 || GetCocain(Client) != 0)
	{

		//Format:
		Format(display, sizeof(display), "Sell all (€%i)", RoundFloat(float(GetHarvest(Client)) * 2.9) + RoundFloat(float(GetMeth(Client)) * 10.0) + RoundFloat(float(GetCocain(Client)) * 100.0) + RoundFloat(float(GetPills(Client)) * 30.0) + RoundFloat(float(GetRice(Client)) * 2.5) + GetResources(Client));

		//Menu Button:
		menu.AddItem("0", display);
	}

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public int HandleDrugMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
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

				//Has Harvest:
				if(GetHarvest(Client) != 0 || GetMeth(Client) != 0 || GetCocain(Client) != 0 || GetPills(Client) != 0 || GetRice(Client) != 0 || GetResources(Client) != 0)
				{

					//Initulize:
					int AddCash = RoundFloat(float(GetHarvest(Client)) * 2.9);

					AddCash += RoundFloat(float(GetMeth(Client)) * 9.5);

					AddCash += RoundFloat(float(GetCocain(Client)) * 100);

					AddCash += RoundFloat(float(GetPills(Client)) * 30);

					AddCash += RoundFloat(float(GetRice(Client)) * 2.5);

					AddCash += GetResources(Client);

					int OldHarvest = GetHarvest(Client);

					OldHarvest += GetCocain(Client);

					OldHarvest += GetMeth(Client);

					OldHarvest += GetPills(Client);

					OldHarvest += GetRice(Client);

					OldHarvest += GetResources(Client);

					SetCash(Client, (GetCash(Client) + AddCash));

					//Set Menu State:
					CashState(Client, AddCash);

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + (GetHarvest(Client) * 2 + (GetMeth(Client) * 10) + (GetPills(Client) * 100) + (GetResources(Client) / 2) + (GetPills(Client) * 200))));

					//Initulize:
					SetHarvest(Client, 0);

					SetMeth(Client, 0);

					SetCocain(Client, 0);

					SetPills(Client, 0);

					SetRice(Client, 0);

					SetResources(Client, 0);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFF Grams and made \x0732CD32€%i\x07FFFFFF!", OldHarvest, AddCash);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You do not have any Drugs harvested!");
				}
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
