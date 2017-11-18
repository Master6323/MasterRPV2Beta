//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_forwards_included_
  #endinput
#endif
#define _rp_forwards_included_

//Definitions:
#define MAINVERSION		"5.00.01"
#if defined HL2DM
//Sprint Bit Device:
#define SUIT_SPRINT_DEVICE	0x00000001
#endif
forward Action OnClientChat(int Client, bool IsTeamOnly, const char[] Text, int maxlength);

forward Action OnCvarChange(const char[] CvarName, const char[] CvarValue);

//MasterRP Forwards:
Handle ChatForward = INVALID_HANDLE;
Handle CvarForward = INVALID_HANDLE;

//Anti Spam:
int PrethinkBuffer[MAXPLAYERS + 1] = {0,...};

//Double - Jump:
#define MAXJUMP			1
int PrethinkJump[MAXPLAYERS + 1] = {0,...};
int Jump[MAXPLAYERS + 1] = {0,...};

//Map Running
bool MapRunning = false;

//Plugin Info:
public Plugin myinfo =
{
	name = "Realistic Roleplay mod",
	author = "Master(D)",
	description = "Main Plugin",
	version = MAINVERSION,
	url = ""
};

char MainVersion()
{

	//Declare:
	char info[64];

	//Format:
	Format(info, sizeof(info), "%s", MAINVERSION);

	//Return:
	return info;
}

//Initation:
public void OnPluginStart()
{

	//Print Server If Plugin Start:
	PrintToConsole(0, "|RolePlay| Core Successfully Loaded (v%s)!", MainVersion());

	//Setup Sql Connection:
	initSQL();

	//Check What game we are running!
	initGameFolder();

	//DHooks Init
	initDHooks();

	//SDK Init
	initSDKTools();
#if defined BANS
	//Setup Ban SQL Connection:
	initBans();
#endif
	initWeaponMod();

	//Spawn Plugin:
	initSpawn();

	initCvar();

	initStock();

	initMoneySafe();

	initNoKillZone();

	initForwards();

	initRandomCrate();

	initPoliceDoors();

	initVipDoors();

	initAdminDoors();

	initFireFighterDoors();

	initJail();

	initBank();

	initCrime();

	initDonator();

	initLight();

	initHudTicker();

	initJobList();

	initGarbageZone();

	initJobSetup();

	initJobSytem();

	initPlayer();

	initTalkSounds();

	initSleeping();

	initnpc();

	initVendorBuy();

	initPrinters();

	initPlants();

	initMeths();

	initPills();

	initCocain();

	initRice();

	initBomb();

	initGunLab();

	initMicrowave();

	initShield();

	initFireBomb();

	initGenerator();

	initBitCoinMine();

	initPropaneTank();

	initPhosphoruTank();

	initSodiumTub();

	initHcAcidTub();

	initAcetoneCan();

	initSeeds();

	initLamp();

	initErythroxylum();

	initBenzocaine();

	initBattery();

	initToulene();

	initSAcidTub();

	initAmmonia();

	initBong();

	initSmokeBomb();

	initWaterBomb();

	initPlasmaBomb();

	initFireExtinguisher();

	initItems();

	initItemList();

	initSpawnedItems();

	initDoors();

	initDoorSystem();

	initNotice();

	initSaveDrugs();

	initCarMod();

	initPrisionPod();

	initJeep();

	initApc();

	initProps();

	initHats();

	intJetPack();

	initPlayerTrails();

	initSettings();

	initLastStats();

	initGlobalBomb();

	initGlobalFire();

	initGlobalAnomaly();

	initLockdown();
#if defined HL2DM
	//Setup Gameplay:
	IntHL2MP();

	initThumpers();

//hl2 npcs
	initNpcAntLionGuard();

	initNpcichthyosaur();

	initNpcHelicopter();

	initNpcDynamic();

	initNpcVortigaunt();

	initNpcDog();

	initNpcStrider();

	initNpcMetroPolice();

	initNpcZombie();

	initNpcPoisonZombie();

	initNpcHeadCrab();

	initNpcHeadCrabFast();

	initNpcHeadCrabBlack();

	initNpcTurretFloor();

	initNpcAdvisor();

	initNpcCrabSynth();

	initNpcManHack();
#endif
}

//Initation:
public void initForwards()
{

	//Handle Forwards:
	ChatForward = CreateGlobalForward("OnClientChat", ET_Event, Param_Cell, Param_Cell, Param_String, Param_Cell);

	CvarForward = CreateGlobalForward("OnCvarChange", ET_Event, Param_String, Param_String, Param_Cell);

	//Command Listener:
	AddCommandListener(CommandSay, "say_team"); //rp_talkzone.sp

	AddCommandListener(CommandSay, "say"); //rp_talkzone.sp

	//Event Hooking:
	HookEvent("player_team", StopEventTeam_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_death", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_spawn", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_disconnect", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_connect", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("server_cvar", ServerCvarEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_changename", EventChangeName_Forward, EventHookMode_Pre);

	//Loop:
	for(int Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Client Hooking:
			DHooksCallBack(Client); //rp_dhooksplayer.sp
		}
	}
}

//Initation:
public void OnMapStart()
{

	//Initulize:
	MapRunning = true;

	//Server DHooks:
	HookGameRules();
#if defined HL2DM
	//Change Team Name:
	ReplaceTeamName();
#endif
	//Precache:
	initStockCache();

	initGarbageReset();

	initMapFix();

	ResetDropped();

	ResetAllCritical();

	ResetEffects();

	ResetCopDoors();

	ResetAdminDoors();

	ResetVipDoors();

	ResetFireFighterDoors();

	ResetEntNotice();

	ResetSpawns();

	ResetIndexNumbAfterMapStart();

	ResetGarbage();

	initMapGarbageCans();

	//Precache:
	PrecacheItems();

	//SQL Load:
	CreateTimer(0.6, LoadSpawnPoints);

	CreateTimer(0.7, LoadNoKillZone);

	CreateTimer(0.9, LoadRandomCrateZone);

	CreateTimer(1.0, LoadCopDoors);

	CreateTimer(1.1, LoadJail);

	CreateTimer(1.2, LoadGarbageZone);

	CreateTimer(1.3, LoadNpcs);

	CreateTimer(1.4, LoadItemlist);

	CreateTimer(1.5, LoadNpcSpawns);

	CreateTimer(1.6, LoadDoorMainOwners);

	CreateTimer(1.7, LoadDoorLocks);

	CreateTimer(1.8, LoadDoorPrices);

	CreateTimer(1.9, LoadNotice);

	CreateTimer(2.0, LoadNoticeName);

	CreateTimer(2.1, LoadNoticeDesc);

	CreateTimer(2.2, LoadMainDoors);

	CreateTimer(2.3, LoadMoneySafe);

	CreateTimer(2.4, LoadDoorLocked);

	CreateTimer(2.5, LoadGarbageCans);

	CreateTimer(2.6, LoadRemoveMapProps);

	CreateTimer(2.7, LoadVipDoors);

	CreateTimer(2.8, LoadAdminDoors);

	CreateTimer(2.9, LoadFireFighterDoors);

	CreateTimer(3.0, LoadBombZones);

	CreateTimer(3.1, LoadFireZones);

	CreateTimer(3.2, LoadAnomalyZones);

	CreateTimer(3.3, LoadLockdownNPCSpawnZones);
#if defined HL2DM
	CreateTimer(0.8, LoadThumper);
#endif
}

//Initation:
public void OnMapEnd()
{

	//Initulize:
	MapRunning = false;
}

//Remove any unwanted weapns:
public void initMapFix()
{

	//Declare:
	char ClassName[32];

	//Loop:
	for(int Ent = 1; Ent < 2047; Ent++)
	{

		//Valid:
		if(Ent > GetMaxClients() && IsValidEdict(Ent))
		{

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Roleplay Map:
			if(StrContains(ClassName, "weapon_", false) == 0)
			{

				//Kill:
				AcceptEntityInput(Ent, "kill");
			}
		}
	}
}

public Action OnPlayerRunCmd(int Client, int &Buttons, int &impulse, float vel[3], float angles[3], int &Weapon)
{

	//Is Alive:
	if(IsPlayerAlive(Client))
	{
#if defined HL2DM
		//Third Person View Fix:
		HL2dmThirdPersonViewFix(Client); 

		//Fix Shotgun:
		HL2dmButtonFix(Client, Buttons, impulse, vel, angles, Weapon);
#endif
		//Is Client Cuffed:
		if(IsCuffed(Client) || IsSleeping(Client) > -1)
		{

			//Button Preventsion:
			Buttons &= ~IN_ATTACK;

			Buttons &= ~IN_ATTACK2;

			//Is Client Cuffed:
			if(IsSleeping(Client) > -1)
			{

				//Button Preventsion:
				Buttons &= ~IN_USE;

				Buttons &= ~IN_JUMP;

				Buttons &= ~IN_DUCK;
			}
		}

		//Is Blocking
		else if(GetBlockE(Client) == 1)
		{

			//Prevent Action:
			Buttons &= ~IN_USE;

			//Can Unblock:
			if(GetUnBlockE(Client) == 0)
			{

				//Timer:
				CreateTimer(10.0, UnLockUse, Client);

				//Initialize:
				SetUnBlockE(Client, 1);
			}
		}

		//Button Used:
		else if(IsClientPressingJump(Buttons) > 0) // rp_stocks.sp
		{

			//Buffer:
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Use:
				OnClientJump(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Button Used:
		else if(Buttons & IN_USE)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Use:
				OnClientUse(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Button Used:
		else if(Buttons & IN_SPEED)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Shift:
				OnClientShift(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
#if defined HL2DM
			//Is Admin Or Cop:
			if(IsCop(Client) || IsAdmin(Client))
			{

				//Check IsClient Using Suit:
				if(GetClientActiveDevices(Client) & SUIT_SPRINT_DEVICE) 
				{

					//Send:
					SetEntPropFloat(Client, Prop_Data, "m_flSuitPowerLoad", 0.0);

					RemoveClientActiveDevices(Client, SUIT_SPRINT_DEVICE);
				}
			}
#endif
		}

		//Button Used:
		else if(Buttons & IN_ATTACK2)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Shift:
				OnClientAttack2(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Override:
		else
		{

			//Initialize:
			PrethinkBuffer[Client] = 0;
		}

		//Return:
		return (impulse == 100 && IsCuffed(Client)) ? Plugin_Handled : Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}

//Handle Chat:
public Action CommandSay(Client, const char[] Command, Argc)
{

	//Declare:
	char Text[256];
	bool IsTeamOnly = false;

	//Not Police Officer:
	if(StrEqual(Command, "say_team"))
	{

		IsTeamOnly = true;
	}

	//Get Args
	GetCmdArgString(Text, sizeof(Text));

	//Strip All Quoats:
	StripQuotes(Text);

	//Trip String:
	TrimString(Text);

	//Is Admin Command:
	if(Text[0] == '/')
	{

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	Action result;

	//Start Forward:
	Call_StartForward(ChatForward);

	//Get Users:
	Call_PushCell(Client);

	//Get Headshot:
	Call_PushCell(IsTeamOnly);

	//Get Weapon:
	Call_PushString(Text);

	//Get Users:
	Call_PushCell(sizeof(Text));

	//Finnish Forward:
	Call_Finish(_:result);

	//Return:
	return Plugin_Handled;
}

//EventDeath Farward:
public Action EventChangeName_Forward(Event event, const  char[] name, bool dontBroadcast)
{

	//Declare:
	char NewName[32];
	char OldName[32];

	//Initialize:
	event.GetString("newname", NewName, sizeof(NewName));

	event.GetString("oldname", OldName, sizeof(OldName));

	//Anti Spam
	if(!StrEqual(NewName, OldName))
	{

		//Get Users:
		int Client = GetClientOfUserId(event.GetInt("userid"));

		//Is Admin:
		if(IsAdmin(Client))
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Admin {olive}%s\x07FFFFFF changed there name to {olive}%s\x07FFFFFF.", OldName, NewName);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Player \x0732CD32%s\x07FFFFFF changed there name to \x0732CD32%s\x07FFFFFF.", OldName, NewName);
		}

		//Declare:
		char query[255];
		char ClientName[32];

		//Remove Harmfull Strings:
		SQL_EscapeString(GetGlobalSQL(), NewName, ClientName, sizeof(ClientName));

		//Format:
		Format(query, sizeof(query), "UPDATE Player SET NAME = '%s' WHERE STEAMID = %i;", ClientName, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	CloseHandle(event);

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action:StopEvent_Forward(Event event, const char[] name, bool dontBroadcast)
{

	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	CloseHandle(event);

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action:StopEventTeam_Forward(Event event, const char[] name, bool dontBroadcast)
{
#if defined HL2DM
	//Get Users:
	int Client = GetClientOfUserId(event.GetInt("userid"));

	//Initulize:
	initGravGunSwitchFix(Client);
#endif
	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	CloseHandle(event);

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action ServerCvarEvent_Forward(Event event, const char[] name, bool dontBroadcast)
{

	//Start Forward:
	Call_StartForward(CvarForward);

	//Declare:
	Action result;
	char CvarName[255];
	char CvarValue[255];

	//Initialize:
	event.GetString("cvarname", CvarName, sizeof(CvarName));

	event.GetString("cvarvalue", CvarValue, sizeof(CvarValue));

	//Get NewName:
	Call_PushString(CvarName);

	//Get OldName:
	Call_PushString(CvarValue);

	//Finnish Forward:
	Call_Finish(_:result);

	//Set Broadcast:
	SetEventBroadcast(event, true);

	//Close:
	CloseHandle(event);

	//Return:
	return result;
}

public Action OnClientUse(int Client)
{

	//Vehicle Check:
	OnVehicleUse(Client);

	//Declare:
	int Ent = GetClientAimTarget(Client, false); 

	//Not Valid Ent:
	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Not Valid Ent:
		if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent))
		{

			//Handle Player:
			DrawPlayerMenu(Client, Ent);

			//Check:
			if((IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
			{

				//Handle Grab:
				OnPlayerGrab(Client, Ent);

				//Return:
				return Plugin_Handled;
			}
		}

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Is Cop With Admin Override:
		if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Door:
				OnCopDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Handled;
			}
		}

		//Is Client Owner of door or has key:
		if(GetMainDoorOwner(Ent) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Door:
				OnClientDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Handled;
			}
		}

		//Vip Doors:
		if((GetDonator(Client) > 0) && NativeIsVipDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Door:
				OnVipDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Handled;
			}
		}

		//Admin Doors:
		if((IsAdmin(Client)) && NativeIsAdminDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Crate:
				OnAdminDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Handled;
			}
		}

		//Admin Doors:
		if((StrEqual(GetJob(Client), "Fire Fighter")) && NativeIsFireFighterDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Crate:
				OnFireFighterDoorFuncUse(Client, Ent);

				//Return:
				return Plugin_Handled;
			}
		}

		//Is Prop Door:
		if(StrEqual(ClassName, "prop_door_rotating"))
		{

			//Check:
			OnClientCheckDoorSpam(Client, Ent);

			//Return:
			return Plugin_Handled;
		}
#if defined HL2DM
		//Prop Thumper:
		if(StrEqual(ClassName, "prop_Thumper"))
		{

			//Handle Thumper:
			OnThumperUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}
#endif
		//Prop Random Crate:
		if(StrEqual(ClassName, "prop_Random_Crate"))
		{

			//Handle Crate:
			OnCrateUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Garbage Can:
		if(StrEqual(ClassName, "prop_Garbage_Can"))
		{

			//Handle Trash Can:
			OnGarbageCanUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Is Valid Sleeping Couch:
		if(IsValidCouch(Ent, ClassName))
		{

			//Handle Couch:
			OnCouchUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Money Printer:
		if(StrEqual(ClassName, "prop_Money_Printer"))
		{

			//Handle Printer:
			OnPrinterUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Plant Drug:
		if(StrEqual(ClassName, "prop_Plant_Drug"))
		{

			//Handle Plant:
			OnPlantUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Kitchen Meth:
		if(StrEqual(ClassName, "prop_Kitchen_Meth"))
		{

			//Handle Plant:
			OnMethUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Kitchen Meth:
		if(StrEqual(ClassName, "prop_Kitchen_Pills"))
		{

			//Handle Plant:
			OnPillsUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Kitchen Meth:
		if(StrEqual(ClassName, "prop_Kitchen_Cocain"))
		{

			//Handle Plant:
			OnCocainUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Plant Rice:
		if(StrEqual(ClassName, "prop_Plant_Rice"))
		{

			//Handle Plant:
			OnRiceUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Bomb:
		if(StrEqual(ClassName, "prop_Bomb"))
		{

			//Handle Plant:
			OnBombUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Gun Lab:
		if(StrEqual(ClassName, "prop_Gun_Lab"))
		{

			//Handle Plant:
			OnGunLabUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Microwave:
		if(StrEqual(ClassName, "prop_Microwave"))
		{

			//Handle Plant:
			OnMicrowaveUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Shield:
		if(StrEqual(ClassName, "prop_Shield"))
		{

			//Handle Plant:
			OnShieldUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Fire Bomb:
		if(StrEqual(ClassName, "prop_Fire_Bomb"))
		{

			//Handle Plant:
			OnFireBombUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Generator:
		if(StrEqual(ClassName, "prop_Generator"))
		{

			//Handle Plant:
			OnGeneratorUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop BitCoin Mine:
		if(StrEqual(ClassName, "prop_BitCoin_Mine"))
		{

			//Handle Plant:
			OnBitCoinMineUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Propane Tank:
		if(StrEqual(ClassName, "prop_Propane_Tank"))
		{

			//Handle Plant:
			OnPropaneTankUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Phosphoru Tank:
		if(StrEqual(ClassName, "prop_Phosphoru_Tank"))
		{

			//Handle Phosphoru Tank:
			OnPhosphoruTankUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Drug Lamp:
		if(StrEqual(ClassName, "prop_Drug_Lamp"))
		{

			//Handle Light:
			OnLampUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//prop Drug Bong:
		if(StrEqual(ClassName, "prop_Drug_Bong"))
		{

			//Handle Light:
			OnBongUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//prop Smoke Bomb:
		if(StrEqual(ClassName, "prop_Smoke_Bomb"))
		{

			//Handle Light:
			OnSmokeBombUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//prop Water Bomb:
		if(StrEqual(ClassName, "prop_Water_Bomb"))
		{

			//Handle Light:
			OnWaterBombUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//prop Plasma Bomb:
		if(StrEqual(ClassName, "prop_Plasma_Bomb"))
		{

			//Handle Light:
			OnPlasmaBombUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//prop Fire Extinguisher:
		if(StrEqual(ClassName, "prop_Fire_Extinguisher"))
		{

			//Handle Light:
			OnFireExtinguisherUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		//Prop Weapon:
		if(StrContains(ClassName, "weapon_", false) == 0)
		{

			//Handle Weapon:
			OnWeaponUse(Client, Ent, ClassName);

			//Return:
			return Plugin_Handled;
		}

		//prop Money Safe:
		if(StrEqual(ClassName, "prop_Money_Safe"))
		{

			//Handle Money Safe:
			OnMoneySafeUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		if(IsEntityGlobalBomb(Ent))
		{

			//Handle Global Bomb:
			OnGlobalBombUse(Client, Ent);

			//Return:
			return Plugin_Handled;
		}

		if(IsValidNpc(Ent))
		{

			//Declare:
			int Id = GetNpcId(Ent);

			int Type = GetNpcType(Ent);

			//Empoyer NPC:
			if(Type == 0)
			{

				//Show Menu
				JobMenu(Client, 0);

				//Return:
				return Plugin_Handled;
			}

			//Banker NPC:
			else if(Type == 1)
			{

				//Show Menu:
				DrawBankMenu(Client, Ent);

				//Return:
				return Plugin_Handled;
			}

			//Vendor NPC:
			else if(Type == 2)
			{

				//Show Menu:
				VendorMenuBuy(Client, Id, Ent);

				//Return:
				return Plugin_Handled;
			}

			//Cop Employer NPC:
			else if(Type == 3)
			{

				//Show Menu:
				CopRankingMenu(Client);

				//Return:
				return Plugin_Handled;
			}

			//Drug Buyer NPC:
			else if(Type == 4)
			{

				//Show Menu:
				VendorDrugSell(Client);

				//Return:
				return Plugin_Handled;
			}

			//Exp Trade NPC:
			else if(Type == 5)
			{

				//Show Menu:
				ExperienceMenu(Client);

				//Return:
				return Plugin_Handled;
			}

			//Hardware Store NPC:
			else if(Type == 6)
			{

				//Show Menu: rp_vendorhardware.sp

				//Return:
				return Plugin_Handled;
			}
		}

		if(GetDroppedDrugValue(Ent) > 0)
		{

			//Handle Dropped Drug:
			OnClientPickUpWeedBag(Client, Ent); //rp_dropped.sp

			//Return:
			return Plugin_Handled;
		}

		if(GetDroppedMethValue(Ent) > 0)
		{

			//Handle Dropped Meth:
			OnClientPickUpMeth(Client, Ent); //rp_dropped.sp

			//Return:
			return Plugin_Handled;
		}

		if(GetDroppedPillsValue(Ent) > 0)
		{

			//Handle Dropped Meth:
			OnClientPickUpPills(Client, Ent); //rp_dropped.sp

			//Return:
			return Plugin_Handled;
		}

		if(GetDroppedCocainValue(Ent) > 0)
		{

			//Handle Dropped Meth:
			OnClientPickUpCocain(Client, Ent); //rp_dropped.sp

			//Return:
			return Plugin_Handled;
		}

		if(GetDroppedMoneyValue(Ent) > 0)
		{

			//Handle Money:
			OnClientPickUpMoney(Client, Ent); //rp_dropped.sp

			//Return:
			return Plugin_Handled;
		}

		//prop Dropped Item:
		if(StrEqual(ClassName, "prop_Dropped_Item"))
		{

			//Handle Dropped Item:
			OnClientPickUpItem(Client, Ent); //rp_items.sp

			//Return:
			return Plugin_Handled;
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action OnClientShift(int Client)
{

	//Declare:
	int Ent = GetClientAimTarget(Client, false); 

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Is Admin Or Cop:
		if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnCopDoorPropShift(Client, Ent); //rp_copdoors.sp

				//Return:
				return Plugin_Handled;
			}
		}

		//Is Client Owner of door or has key:
		if(GetMainDoorOwner(Ent) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnClientDoorPropShift(Client, Ent); //rp_doorsystem.sp

				//Return:
				return Plugin_Handled;
			}
		}

		//Is Donator:
		if((GetDonator(Client) > 0) && NativeIsVipDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnVipDoorPropShift(Client, Ent); //rp_vipdoors.sp

				//Return:
				return Plugin_Handled;
			}
		}

		//Admin Doors:
		if((StrEqual(GetJob(Client), "Fire Fighter")) && NativeIsFireFighterDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnFireFighterDoorPropShift(Client, Ent); //rp_firefighterdoors.sp

				//Return:
				return Plugin_Handled;
			}
		}

		//Is Donator:
		if((IsAdmin(Client)) && NativeIsAdminDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnAdminDoorPropShift(Client, Ent); //rp_admindoors.sp

				//Return:
				return Plugin_Handled;
			}
		}

		//prop Money Safe:
		if(StrEqual(ClassName, "prop_Money_Safe"))
		{

			//Handle Money Safe:
			OnMoneySafeRob(Client, Ent); //rp_moneysafe.sp

			//Return:
			return Plugin_Handled;
		}

		//Prop Generator:
		if(StrEqual(ClassName, "prop_Generator"))
		{

			//Handle Plant:
			OnGeneratorShift(Client, Ent); //rp_generator.sp

			//Return:
			return Plugin_Handled;
		}

		if(IsValidNpc(Ent))
		{

			//Declare:
			int Id = GetNpcId(Ent);

			//Declare:
			int Type = GetNpcType(Ent);

			//Empoyer NPC:
			if(Type == 1)
			{

				//Begin Bank Rob:
				BeginBankRob(Client, "Banker", 500, Id); //rp_bankrobbing.sp

				//Return:
				return Plugin_Handled;
			}

			//Empoyer NPC:
			if(Type == 2)
			{

				//Begin Bank Rob:
				BeginVendorRob(Client, "Vendor", 400, Id); //rp_vendorrobbing.sp

				//Return:
				return Plugin_Handled;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action OnClientAttack2(int Client)
{

	//Declare:
	char ClassName[32];

	//Get Client Weapon:
	GetClientWeapon(Client, ClassName, sizeof(ClassName));

	//Is Prop Door:
	if(StrEqual(ClassName, GetRepareWeapon()) || StrEqual(ClassName, GetArrestWeapon()))
	{

		//Declare:
		int Ent = GetClientAimTarget(Client, false); 

		//Not Valid Ent:
		if(Ent <= GetMaxClients() && Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
		{

			//Handle Push Player:
			OnClientPushPlayer(Client, Ent); //rp_jail.sp

			//Return:
			return Plugin_Handled;
		}

		//Not Valid Ent:
		if(Ent > GetMaxClients() && IsValidEdict(Ent))
		{

			//Is Prop Door:
			if(IsValidDoor(Ent) && IsInDistance(Client, Ent))
			{

				//Handle Door Knock:
				OnClientKnockPropDoor(Ent); //rp_doormisc.sp

				//Return:
				return Plugin_Handled;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public void OnClientJump(int Client)
{

	//Declare:
	int OnGround = GetEntityFlags(Client);

	//Check:
	if(OnGround & FL_ONGROUND)
	{

		//Initulize:
		PrethinkJump[Client]++;
	}

	//Check:
	if(PrethinkJump[Client] > 0 && !(OnGround & FL_ONGROUND) && Jump[Client] < MAXJUMP)
	{

		//Initulize:
		Jump[Client]++;

		//Declare:
		float Origin[3];

		//Initulize:
		GetEntPropVector(Client, Prop_Data, "m_vecVelocity", Origin);

		//Boost Client:
		Origin[2] = 250.0;

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, NULL_VECTOR, Origin);
	}
}

//Public Void OnClientPutInServer(Client)
public void OnClientPostAdminCheck(Client)
{

	//LoadItems:
	CreateTimer(0.2, PreLoad, Client);

	//Set Defaults:
	OnClientConnectSetDefaults(Client); //rp_defaults.sp

	//Server DHooks:
	DHooksCallBack(Client); //rp_dhooksplayer.sp
}

//Create SQLite Database:
public Action PreLoad(Handle Timer, any Client)
{

	//Connected:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Connect Message:
		OnClientConnectMessage(Client); //rp_forwardmessages.sp

		//Load Player Stats:
		DBLoad(Client); //rp_player.sp

		//Load Player Inventory:
		LoadItems(Client); // rp_items.sp

		//Load Door Keys;
		DBLoadKeys(Client); //rp_doorsystem.sp

		//Load Player Drugs:
		DBLoadDrugs(Client); //rp_savedrugs.sp

		//Load Spawned Items:
		DBLoadSpawnedItems(Client); //rp_spawneditems.sp

		//Load Settings:
		LoadPlayerSettings(Client); //rp_settings.sp

		//Root Admin Connected:
		OnRootAdminConnect(Client); //rp_stocks.sp
#if defined BANS
		//Load Bans:
		DBLoadBans(Client); //rp_bans.sp
#endif
	}

	//Connected:
	else if(IsClientConnected(Client))
	{

		//LoadItems:
		CreateTimer(0.1, PreLoad, Client);
	}
}

public bool:IsMapRunning()
{

	//Return:
	return MapRunning;
}