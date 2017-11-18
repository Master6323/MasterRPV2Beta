//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hud_included_
  #endinput
#endif
#define _rp_hud_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Show Player Hud
public void ShowClientHud(int Client)
{

	//Declare:
	char FormatMessage[1024];

	//Declare:
	int len = 0;

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N]\nCash: %s %s\nBank: %s %s\nJob: %s\nJob Salary: €%i in %is", Client, IntToMoney(GetCash(Client)), GetCashState(Client), IntToMoney(GetBank(Client)), GetCashState(Client), GetJob(Client), GetJobSalary(Client), GetSalaryCheck());

	//Declare
	int More = GetMoreHud(Client);

	//More Hud Enabled
	if(More == 1)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nNext raise in %i Min", (RoundToCeil(Pow(float(GetJobSalary(Client)), 3.0)) - GetNextJobRase(Client)));

		//Is Critical:
		if(GetIsCritical(Client))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nIn Critical Condition");
		}

		//Is Hunger Enabled:
		if(IsHungerDisabled() == 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHunger: %s", GetHungerString(Client));
		}

		//Has Harvest:
		if(GetHarvest(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHarvest: %ig", GetHarvest(Client));
		}

		//Has Meth:
		if(GetMeth(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nMeth: %ig", GetMeth(Client));
		}

		//Has Pills:
		if(GetPills(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPills: %ig", GetPills(Client));
		}

		//Has Cocain:
		if(GetCocain(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCocain: %ig", GetCocain(Client));
		}

		//Has Cocain:
		if(GetRice(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nRice: %ig", GetRice(Client));
		}

		//Has Resources:
		if(GetResources(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nResources: %ig", GetResources(Client));
		}

		//Has Resources:
		if(GetBitCoin(Client) != 0.0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBTC: %f", GetBitCoin(Client));
		}
	}

	//Is In Jail:
	if(IsCuffed(Client))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nJailtime: %i/%i", GetJailTime(Client), GetMaxJailTime(Client));
	}

	//Declare:
	float pos[2] = {0.005, 0.005};
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 0, pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 0, pos, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}
}

//Show Player Hud
public void ShowPlayerNotice(int Client, int Player)
{

	//Declare:
	float ClientOrigin[3];
	float EntOrigin[3];
	char FormatMessage[255];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	int len = 0;

	//Connected:
	if(Player > 0 && IsClientConnected(Player) && IsClientInGame(Player) && Player < GetMaxClients())
	{

		//Initialize:
		GetClientAbsOrigin(Player, EntOrigin);

		//Declare:
		float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

		//Declare:
		int PlayerHP = GetClientHealth(Player);

		//In Distance:
		if(Dist <= 350 && !(GetClientButtons(Client) & IN_SCORE))
		{

			//Declare:
			int Salary = GetJobSalary(Player);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N] \nHealth: %i% \nJob: %s\nJobSalary: €%i\nEnergy: %i", Player, PlayerHP, GetJob(Player), Salary, GetEnergy(Player));

			//Is Same Team:
			if(IsCop(Client) || IsAdmin(Client))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCash: %s\nBank: %s", IntToMoney(GetCash(Player)), IntToMoney(GetBank(Player)));

				//Is In Jail:
				if(IsCuffed(Player))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nJailtime: %i/%i", GetJailTime(Player), GetMaxJailTime(Player));
				}

				//Has Player Got Crime:
				if(GetCrime(Player) > 500)
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCrime: %i", (GetCrime(Player) / 1000));
				}
			}

			//Has Player Got Bounty:
			if(!IsCop(Client) && GetBounty(Player) > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBounty: €%i", GetBounty(Player));
			}

			//IsCuffed:
			if(IsCuffed(Player))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCUFFED!");
			}

			//Declare:
			float Pos[2] = {0.005, 0.005};
			int Color[4];

			//Initulize:
			Color[0] = GetPlayerHudColor(Client, 0);
			Color[1] = GetPlayerHudColor(Client, 1);
			Color[2] = GetPlayerHudColor(Client, 2);
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 1, Pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 1, Pos, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
			}
		}

		//Override
		else if((Dist > 350 && Dist < 1000))
		{

			//Show Hud Text:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N] \nHealth: %i% ",Player, PlayerHP);

			//Has Player Got Bounty:
			if(GetBounty(Player) > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBounty: %i", GetBounty(Player));
			}

			//IsCuffed:
			if(IsCuffed(Player))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCUFFED!");
			}

			//Declare:
			float Pos[2] = {0.005, 0.005};
			int Color[4];

			//Initulize:
			Color[0] = GetPlayerHudColor(Client, 0);
			Color[1] = GetPlayerHudColor(Client, 1);
			Color[2] = GetPlayerHudColor(Client, 2);
			Color[3] = 255;

			//Check:
			if(GetGame() == 2 || GetGame() == 3)
			{

				//Show Hud Text:
				CSGOShowHudTextEx(Client, 1, Pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
			}

			//Override:
			else
			{

				//Show Hud Text:
				ShowHudTextEx(Client, 1, Pos, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
			}
		}
	}
}

//Show Player Hud
public void showAdminStats(int Client)
{

	//Declare:
	char FormatMessage[1024];

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "\nEnergy: %i\nCop Cuffs: %i\nCop Minutes : %i\nExperience: %i", GetEnergy(Client), GetCopCuffs(Client), GetCopMinutes(Client), GetJobExperience(Client));

	//Declare:
	float Pos[2] = {-1.0, 1.0};
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, Pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, Pos, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}
}

//Show Player Hud
public void showCopStats(int Client)
{

	//Declare:
	char FormatMessage[1024];

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "Energy\nCuffs: %i\nCop Minutes: %i", GetEnergy(Client), GetCopCuffs(Client), GetCopMinutes(Client));

	//Declare:
	float Pos[2] = {-1.0, 1.0};
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, Pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, Pos, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}
}

//Show Player Hud
public void showAddedStats(Client)
{

	//Declare:
	char FormatMessage[1024];

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "\nEnergy: %i\nExperience: %i", GetEnergy(Client), GetJobExperience(Client));

	//Declare:
	float Pos[2] = {-1.0, 1.0};
	int Color[4];

	//Initulize:
	Color[0] = GetClientHudColor(Client, 0);
	Color[1] = GetClientHudColor(Client, 1);
	Color[2] = GetClientHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() == 2 || GetGame() == 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 3, Pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 3, Pos, Color, 1.0, 0, 6.0, 0.1, 0.2, FormatMessage);
	}
}

//Crime Hud:
public void ShowCrimeHud(int Client)
{

	//Declare:
	char Message[512];

	int ClientCount = 0;

	//Initulize:
	int len = 0;

	//Start Hud Message:
	len += Format(Message[len], sizeof(Message)-len,"\nCrime Level:");

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//To Many Clients:
			if(GetCrime(i) > 500 && ClientCount < 7)
			{

				//Initialize:
				ClientCount++;

				//Has Bounty:
				if(GetBounty(i) > 0)
				{

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetBounty(i));
				}

				//Is Alive:
				else if(IsPlayerAlive(i) && GetCrime(i) > 500)
				{

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", i, RoundToNearest(GetCrime(i) / 1000.0));
				}

				//Override:
				else
				{

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (%i) (Dead)", i, RoundToNearest(GetCrime(i) / 1000.0));
				}
			}
		}
	}

	//Has Player Got Crime/Bounty:
	if((ClientCount > 0 && GetCrime(Client) > 500) || (ClientCount > 0 && (IsCop(Client) || IsAdmin(Client))))
	{

		//Declare:
		float Pos[2] = {0.950, 0.015};
		int Color[4];

		//Initulize:
		Color[0] = 255;
		Color[1] = 50;
		Color[2] = 50;
		Color[3] = 255;

		//Check:
		if(GetGame() == 2 || GetGame() == 3)
		{

			//Show Hud Text:
			CSGOShowHudTextEx(Client, 2, Pos, Color, Color, 1.0, 0, 6.0, 0.1, 0.2, Message);
		}

		//Override:
		else
		{

			//Show Hud Text:
			ShowHudTextEx(Client, 2, Pos, Color, 1.0, 0, 6.0, 0.1, 0.2, Message);
		}
	}
}

public void ShowEntityNotice(int Client, int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Valid Sleeping Couch:
	if(IsValidCouch(Ent, ClassName))
	{

		//Show Hud:
		CouchHud(Client, Ent);
	}

	//Prop Money Printer:
	if(StrEqual(ClassName, "prop_Money_Printer"))
	{

		//Show Hud:
		PrinterHud(Client, Ent);
	}

	//Prop Plant Drug:
	if(StrEqual(ClassName, "prop_Plant_Drug"))
	{

		//Show Hud:
		PlantHud(Client, Ent);
	}

	//Prop Kitchen Meth:
	if(StrEqual(ClassName, "prop_Kitchen_Meth"))
	{
	
		//Show Hud:
		MethHud(Client, Ent);
	}

	//Prop Kitchen Meth:
	if(StrEqual(ClassName, "prop_Kitchen_Pills"))
	{

		//Show Hud:
		PillsHud(Client, Ent);
	}

	//Prop Kitchen Meth:
	if(StrEqual(ClassName, "prop_Kitchen_Cocain"))
	{

		//Show Hud:
		CocainHud(Client, Ent);
	}

	//Prop Plant Rice:
	if(StrEqual(ClassName, "prop_Plant_Rice"))
	{

		//Show Hud:
		RiceHud(Client, Ent);
	}

	//Prop Bomb:
	if(StrEqual(ClassName, "prop_Bomb"))
	{

		//Show Hud:
		BombHud(Client, Ent);
	}

	//Prop Gun Lab:
	if(StrEqual(ClassName, "prop_Gun_Lab"))
	{

		//Show Hud:
		GunLabHud(Client, Ent);
	}

	//Prop Microwave:
	if(StrEqual(ClassName, "prop_Microwave"))
	{

		//Show Hud:
		MicrowaveHud(Client, Ent);
	}

	//Prop Shield:
	if(StrEqual(ClassName, "prop_Shield"))
	{

		//Show Hud:
		ShieldHud(Client, Ent);
	}

	//Prop Fire Bomb:
	if(StrEqual(ClassName, "prop_Fire_Bomb"))
	{

		//Show Hud:
		FireBombHud(Client, Ent);
	}

	//Prop Generator:
	if(StrEqual(ClassName, "prop_Generator"))
	{

		//Show Hud:
		GeneratorHud(Client, Ent);
	}

	//Prop BitCoin Mine:
	if(StrEqual(ClassName, "prop_BitCoin_Mine"))
	{

		//Show Hud:
		BitCoinMineHud(Client, Ent);
	}

	//Prop Propane Tank:
	if(StrEqual(ClassName, "prop_Propane_Tank"))
	{

		//Show Hud:
		PropaneTankHud(Client, Ent);
	}

	//Prop Phosphoru Tank:
	if(StrEqual(ClassName, "prop_Phosphoru_Tank"))
	{

		//Show Hud:
		PhosphoruTankHud(Client, Ent);
	}

	//Prop Sodium Tub:
	if(StrEqual(ClassName, "prop_Sodium_Tub"))
	{

		//Show Hud:
		SodiumTubHud(Client, Ent);
	}

	//Prop HcAcid Tub:
	if(StrEqual(ClassName, "prop_HcAcid_Tub"))
	{

		//Show Hud:
		HcAcidTubHud(Client, Ent);
	}

	//Prop Acetone Can:
	if(StrEqual(ClassName, "prop_Acetone_Can"))
	{

		//Show Hud:
		AcetoneCanHud(Client, Ent);
	}

	//Prop Drug Seeds:
	if(StrEqual(ClassName, "prop_Drug_Seeds"))
	{

		//Show Hud:
		SeedsHud(Client, Ent);
	}

	//Prop Drug Lamp:
	if(StrEqual(ClassName, "prop_Drug_Lamp"))
	{

		//Show Hud:
		LampHud(Client, Ent);
	}

	//Prop Erythroxylum:
	if(StrEqual(ClassName, "prop_Erythroxylum"))
	{

		//Show Hud:
		ErythroxylumHud(Client, Ent);
	}

	//Prop Benzocaine:
	if(StrEqual(ClassName, "prop_Benzocaine"))
	{

		//Show Hud:
		BenzocaineHud(Client, Ent);
	}

	//Prop Battery:
	if(StrEqual(ClassName, "prop_Battery"))
	{

		//Show Hud:
		BatteryHud(Client, Ent);
	}

	//Prop Toulene:
	if(StrEqual(ClassName, "prop_Toulene"))
	{

		//Show Hud:
		TouleneHud(Client, Ent);
	}

	//Prop SAcid Tub:
	if(StrEqual(ClassName, "prop_SAcid_Tub"))
	{

		//Show Hud:
		SAcidTubHud(Client, Ent);
	}

	//Prop Ammonia:
	if(StrEqual(ClassName, "prop_Ammonia"))
	{

		//Show Hud:
		AmmoniaHud(Client, Ent);
	}

	//Prop Drug Bong:
	if(StrEqual(ClassName, "prop_Drug_Bong"))
	{

		//Show Hud:
		BongHud(Client, Ent);
	}

	//Prop Smoke Bomb:
	if(StrEqual(ClassName, "prop_Smoke_Bomb"))
	{

		//Show Hud:
		SmokeBombHud(Client, Ent);
	}

	//Prop Water Bomb:
	if(StrEqual(ClassName, "prop_Water_Bomb"))
	{

		//Show Hud:
		WaterBombHud(Client, Ent);
	}

	//Prop Plasma Bomb:
	if(StrEqual(ClassName, "prop_Plasma_Bomb"))
	{

		//Show Hud:
		PlasmaBombHud(Client, Ent);
	}

	//Prop Fire Extinguisher:
	if(StrEqual(ClassName, "prop_Fire_Extinguisher"))
	{

		//Show Hud:
		FireExtinguisherHud(Client, Ent);
	}
#if defined HL2DM
	//Prop Thumper:
	if(StrEqual(ClassName, "prop_Thumper"))
	{

		//Show Hud:
		ThumperHud(Client, Ent);
	}
#endif
	//Is NPC Thunper:
	if(!IsValidNpc(Ent) && IsValidDymamicNpc(Ent) && !StrEqual(ClassName, "prop_slam") && !StrEqual(ClassName, "prop_grenade"))
	{

		//Show Hud:
		NpcHealthHud(Client, Ent);
	}

	//Valid Door:
	if(IsValidDoor(Ent))
	{

		//Show Hud:
		DoorHud(Client, Ent);
	}

	//Prop Money Safe:
	if(StrEqual(ClassName, "prop_Money_Safe"))
	{

		//ShowHud:
		MoneySafeHud(Client, Ent);
	}
}
