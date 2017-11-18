//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_init_included_
  #endinput
#endif
#define _rp_init_included_

//Server int
int HudTimer = -1;
int TeamTimer = -1;

//Server Timer Handle:
Handle hTimer = INVALID_HANDLE;

//Server RunTime
int RunTime = 0;

public void initHudTicker()
{

	//Draw Player Hud:
	hTimer = CreateTimer(0.1, initMainModTicker, _, TIMER_REPEAT);
}

public void StopHudTicker()
{

	//Kill:
	KillTimer(hTimer);

	//Initulize:
	hTimer = INVALID_HANDLE;
}

//Client Hud:
public Action initMainModTicker(Handle Timer)
{

	//Initulize:
	HudTimer += 1;

	TeamTimer += 1;

	RunTime += 1;

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Int JetPack:
			initJetPackTimer(Client, HudTimer);

			//Player Trail Effects:
			initPlayerTrailEffects(Client, HudTimer);
		}
	}

	//Init Effect:
	intAnomalyEffectTimer(TeamTimer);

	//Create Generator Timer Init:
	initGeneratorTime(HudTimer);

	//Switch:
	switch(HudTimer)
	{

		case 0:
		{

			//Create Erythroxylum Timer Init:
			initErythroxylumTime();

			//Create Benzocaine Timer Init:
			initBenzocaineTime();

			//Create SmokeBomb Timer Init:
			initSmokeBombTime();
		}

		case 1:
		{

			//Create Water Bomb Timer Init:
			initWaterBombTime();

			//Create Plasma Bomb Timer Init:
			initPlasmaBombTime();

			//Create Fire Extinguisher Timer Init:
			initFireExtinguisherTime();
		}

		case 2:
		{

			//Create Printer Timer Init:
			initPrintTime();

			//Create Meth Timer Init:
			initMethTime();

			//Create Pills Timer Init:
			initPillsTime();
		}

		case 3:
		{

			//Create Plant Timer Init:
			initPlantTime();

			//Create Cocain Timer Init:
			initCocainTime();

			//Create Rice Timer Init:
			initRiceTime();

			//AnomalyTick:
			initGlobalAnomalyTick();
		}

		case 4:
		{

			//Create Bomb Timer Init:
			initBombTime();

			//Create Gun Lab Timer Init:
			initGunLabTime();

			//Create Battery Timer Init:
			initBatteryTime();

			//FireTick:
			initGlobalFireTick();
		}

		case 5:
		{

			//Create Microwave Timer Init:
			initMicrowaveTime();

			//Create Shield Timer Init:
			initShieldTime();

			//Create Toulene Timer Init:
			initTouleneTime();

			//BombTick:
			initGlobalBombTick();

			//Entity Notice: Dont Remove!
			initClientEntityNotice();
		}

		case 6:
		{

			//Create Fire Bomb Timer Init:
			initFireBombTime();

			//Create SAcidTub Timer Init:
			initSAcidTubTime();

			//Money Safe Rob Timer:
			iRobTimer();

			//Lockdown Timer:
			initLockdownTimer();
		}

		case 7:
		{

			//Create BitCoin Mine Timer Init:
			initBitCoinMineTime();

			//Create Propane Tank Timer Init:
			initPropaneTankTime();

			//Create Ammonia Timer Init:
			initAmmoniaTime();

			//Vendor NPC Rob Timer:
			initVendorRobbing();
		}

		case 8:
		{

			//Create Phosphoru Tank Timer Init:
			initPhosphoruTankTime();

			//Create Sodium Tub Timer Init:
			initSodiumTubTime();

			//Create SAcid Tub Timer Init:
			initSAcidTubTime();

			//Banking NPC Rob Timer:
			initBankRobbing();
		}

		case 9:
		{

			//Create HcAcid Tub Timer Init:
			initHcAcidTubTime();

			//Create Acetone Can Timer Init:
			initAcetoneCanTime();

			//Create Toulene Timer Init:
			initTouleneTime();

			//Crate Timer Init:
			initCrateTick();
		}

		case 10:
		{

			//Create Seeds Timer Init:
			initSeedsTime();

			//Create Lamp Timer Init:
			initLampTime();

			//Create Bong Timer Init:
			initBongTime();

			//Init Job System Timer
			initSalaryTimer();

			//Main Mod Ticker:
			initClientTick();

			//Entity Notice: Dont Remove!
			initClientEntityNotice();

			//Initulize:
			HudTimer = -1;
		}
	}

	if(TeamTimer >= 50)
	{

		//Initulize:
		TeamTimer = -1;

		//HL2DM TeamFix:
		initManageClientTeam();
	}
}

public void initClientEntityNotice()
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Check:
			if(IsPlayerAlive(Client))
			{

				//Declare:
				int Ent = GetClientAimTarget(Client, false);

				//Connected:
				if(Ent > GetMaxClients() + 1 && IsValidEntity(Ent) && !LookingAtWall(Client))
				{

					//Show Hud:
					ShowEntityNotice(Client, Ent);
				}

				//Override:
				if(Ent > 0 && Ent < GetMaxClients() && IsClientConnected(Ent) && !LookingAtWall(Client))
				{

					//Show Hud:
					ShowPlayerNotice(Client, Ent);
				}
			}
		}
	}
}

public void initClientTick()
{

	//Loop:
	for(new Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
		{

			//Show Client Hud
			ShowClientHud(Client);

			//Draw Hud:
			ShowCrimeHud(Client);

			//Added Hud Info:
			if(GetHudInfo(Client) == 1 && IsSleeping(Client) == -1)
			{

				//Is Admin:
				if(IsAdmin(Client))
				{

					//Draw Hud:
					showAdminStats(Client);
				}

				//Is Cop:
				else if(IsCop(Client))
				{

					//Draw Hud:
					showCopStats(Client);
				}

				//Override:
				else
				{

					//Draw Hud:
					showAddedStats(Client);
				}
			}

			//Show Tracers:
			OnClientShowTracers(Client);

			//ManageNoKillZone:
			NokillZone(Client);

			//Init Jail Timer:
			IntJailTimer(Client);

			//Quick Check:
			ClientCriticalOverride(Client);

			//Init Drugs:
			OnDrugTick(Client);

			//Init Crime Removal and Bounty Check:
			initCrimeTimer(Client);
		}
	}
}

//ManageTeams:
public void initManageClientTeam()
{

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
		{

			//Client Team Fix Plugin:
			OnManageClientTeam(Client);

			//Check Health
			initCriticalHealth(Client);

			//Init Random Cough Sound:
			initCough(Client);
		}
	}
}

public int GetRunTime()
{

	//Return:
	return RunTime;
}