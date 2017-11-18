//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dhooksplayer_included_
  #endinput
#endif
#define _rp_dhooksplayer_included_

//Global Forward:
public void DHooksCallBack(int Client)
{

	//Pre Hook Types:
	//Client Hooking:
 	DHookEntity(hPreChangeTeam, false, Client);

	//Client Hooking:
 	DHookEntity(hPreEventKilled, false, Client);

	//Client Hooking:
 	DHookEntity(hPreSpawn, false, Client);

	//Client Hooking:
 	DHookEntity(hPreOnTakeDamage, false, Client);

	//Client Hooking:
 	DHookEntity(hPreGiveNamedItem, false, Client);

	//Client Hooking:
 	DHookEntity(hPreWeaponEquip, false, Client);

	//Client Hooking:
 	DHookEntity(hPreWeaponDrop, false, Client);

	//Client Hooking:
 	DHookEntity(hPreDeathSound, false, Client);

	//Client Hooking:
 	DHookEntity(hPreThink, false, Client);

	//Client Hooking:
 	DHookEntity(hPreStartObserverMode, false, Client);

	//Post Hook Types:
	//Client Hooking:
 	DHookEntity(hPostSpawn, true, Client);

	//Client Hooking:
 	DHookEntity(hPostThinkPost, true, Client);

	//Client Hooking:
 	DHookEntity(hPostOnTakeDamage, true, Client);

	//Client Hooking:
 	DHookEntity(hPostWeaponEquip, true, Client);
}

// bool CMultiplayRules::ClientConnected(edict_t * pEntity, char const*, char const*, int)
public MRESReturn OnPreClientConnected(Handle hReturn, Handle hParams)
{

	//Declare:
	//int Client = DHookGetParam(hParams, 1);

	//Return:
        return MRES_Ignored;
}

// void CHL2MPRules::ClientDisconnected(edict_t * pClient)
public MRESReturn OnPreClientDisconnected(Handle hParams)
{

	//Declare:
	int Client = DHookGetParam(hParams, 1);

	//Disconnect Message:
	OnClientDisconnectMessage(Client);

	//Save:
	DBSave(Client);

	//Disconnect Talkzone:
	initdisconnectphone(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Remove Sleeping:
	ResetCritical(Client);

	//SaveSpawnedItems:
	SaveSpawnedItemForward(Client, true);

	//Update Last Stats:
	UpdateLastStats(Client);

	//Reset Jetpack:
	StopJetPack(Client);

	//Return:
        return MRES_Ignored;
}

public MRESReturn OnClientPreSpawn(int Client, Handle hParams)
{

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}

	//Reset Critical:
	ResetCritical(Client);

	//Start Protecting:
	StartSpawnProtect(Client);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnClientPreEventKilled(int Client, Handle hParams, int &Attacker, int &Inflictor, int &Weapon, float &fDamage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Is Player:
	if(Client != 0 && Attacker != 0 && Client > 0 && Client < MaxClients && Attacker > 0 && Attacker < MaxClients)
	{

		//Print:
		PrintToConsole(Client, "|RP| - %N was Killed by %N!", Client, Attacker);
	}

	//Clear Drug Tick:
	ResetDrugs(Client);

	//Check Player Bounty:
	OnClientDiedCheckBounty(Client, Attacker);

	//Hangup Phone:
	OnCliedDiedHangUp(Client);

	//Reset Critical:
	ResetCritical(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Reset Protection to prevent bugs:
	RemoveProtectTimer(Client);

	//Remove Player Hat:
	OnClientDiedThrowPhysHat(Client, GetPlayerHatEnt(Client));

	//Check:
	if(IsLoaded(Client) == true)
	{

		//Drop All Drugs:
		OnClientDropAllDrugs(Client);

		//Drop Money:
		OnClientDropMoney(Client);
	}

	//Command:
	CheatCommand(Client, "r_screenoverlay", "debug/yuv.vmt");

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnClientPreChangeTeam(int Client, Handle hParams, int Team)
{

	//Check:
	if(!IsCop(Client) && (IsAdmin(Client) || GetDonator(Client) > 0) && Team != 3) 
	{

		//Initulize:
		ChangeClientTeamEx(Client, 3);

		DHookSetParam(hParams, 1, 3);
	}

	//Is Client Cop:
	else if(IsCop(Client) && Team != 2)
	{

		//Initulize:
		DHookSetParam(hParams, 1, 2);
	}

	//Override:
	else if(Team != 3)
	{

		//Initulize:
		DHookSetParam(hParams, 1, 3);
	}

	//Return:
	return MRES_Override;
}

public MRESReturn OnClientOnTakeDamage(int Client, Handle hParams, Handle hReturn, int &Attacker, int &Inflictor, int &Weapon, float &Damage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Check:
	if(Attacker > GetMaxClients() && IsValidEntity(Attacker))
	{

		//Declare:
		char ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Attacker, ClassName, sizeof(ClassName));
#if defined HL2DM
		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_antlionguard", false) == 0)
		{

			//Forward SDKHOOK:
			OnAntLionGuardDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_helicopter", false) == 0)
		{

			//Forward SDKHOOK:
			OnHelicopterDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_vortigaunt", false) == 0)
		{

			//Forward SDKHOOK:
			OnVortigauntDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_strider", false) == 0)
		{

			//Forward SDKHOOK:
			OnStriderDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_metropolice", false) == 0)
		{

			//Forward SDKHOOK:
			OnMetroPoliceDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_zombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnZombieDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_poisonzombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnPoisonZombieDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_headcrab", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_headcrab_fast", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabFastDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_headcrab_black", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabBlackDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_advisor", false) == 0)
		{

			//Forward SDKHOOK:
			OnAdvisorDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}

		//Is Man Hack:
		if(StrContains(ClassName, "npc_manhack", false) == 0)
		{

			//Forward SDKHOOK:
			OnManHackDamageClient(Client, Attacker, Inflictor, Damage, DamageType);
		}
#endif
		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);


		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Int, DamageType);
	}

	//Convert if Player Has Suit:
	if(DamageType == DMG_FALL || DamageType == DMG_DROWN)
	{

		//Declare:
		float Armor = float(GetClientArmor(Client));

		//Has No Armor:
		if(Armor == 0.0)
		{

			//Initialize:
			Damage = FloatMul(Damage, GetRandomFloat(0.50, 1.50));
		}

		//Has Armor:
		else if((Armor - Damage) < 1 && (Armor != 0.0))
		{

			//Set Armor:
			SetEntityArmor(Client, 0);

			//Initialize:
			Damage = FloatMul(Damage, GetRandomFloat(0.25, 0.75));
		}

		//Has Armor With Right Damage to armor value:
		else if((Armor - Damage) > 1.0)
		{

			//Set Armor:
			SetEntityArmor(Client, RoundToNearest((Armor - Damage)));

			//Initialize:
			Damage = FloatMul(Damage, GetRandomFloat(0.25, 0.75));
		}

		//Override:
		else
		{
			//Set Armor:
			SetEntityArmor(Client, 0);
		}

		//Shake Client:
		ShakeClient(Client, 2.5, (Damage/4.0));

		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);


	}

	//Check:
	if(DamageType & DMG_VEHICLE)
	{

		//Declare:
		char ClassName[30];

		//Initulize:
		GetEdictClassname(Inflictor, ClassName, sizeof(ClassName));

		//Is Vehicle:
		if (StrEqual("prop_vehicle_driveable", ClassName, false))
		{

			//Declare
			int Driver = GetEntPropEnt(Inflictor, Prop_Send, "m_hPlayer");

			//Check:
			if(Driver != -1)
			{

				//Initulize:
				Damage *= 2.0;
				
				Attacker = Driver;

				//Set Param:
				DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);


				//Set Param:
				DHookSetParamObjectPtrVar(hParams, 1, 40, ObjectValueType_Int, Attacker);


			}
		}
	}

	//Is Player:
	if(Attacker != Client && Client != 0 && Attacker != 0 && Client > 0 && Client < MaxClients && Attacker > 0 && Attacker < MaxClients)
	{

		//Handle Player Cuff:
		OnClientCuffCheck(Client, hParams, Attacker, Damage);

		//Cop Kill:
		if(IsCop(Client) && IsCop(Attacker) && IsCopKillDisabled() == 1)
		{

			//Initialize:
			Damage = 0.0;

			//Damage:
			DamageType = 0;

			//Set Param:
			DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);


			//Set Param:
			DHookSetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Int, DamageType);


		}
	}

	//Is Damage Coming From Kitchen?:
	if(DamageType == DMG_BURN)
	{

		//Declare:
		int Ent = FindAttachedPropFromEnt(Inflictor);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Prop Kitchen:
			if(StrEqual(ClassName, "prop_Kitchen_Meth") || StrEqual(ClassName, "prop_Kitchen_Pills") || StrEqual(ClassName, "prop_Kitchen_Cocain"))
			{

				//Initialize:
				Damage = 0.0;
			}

			//Override
			else
			{

				//Initialize:
				Damage = GetRandomFloat(1.0, 5.0);
			}

			//Set Param:
			DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);

			//Return:
			return MRES_Override;
		}

		//Initialize:
		Damage = GetRandomFloat(1.0, 5.0);
	}

	//GodeMode:
	if(GetIsNokill(Client) || IsProtected(Client) || GetGodMode(Client))
	{

		//Initialize:
		Damage = 0.0;

		//Damage:
		DamageType = 0;

		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);


		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Int, DamageType);
	}

	//Has Shield Near By:
	if(IsShieldInDistance(Client))
	{

		//Shield Forward:
		OnClientShieldDamage(Client, Damage);

		//Initialize:
		Damage = 0.0;

		//Damage:
		DamageType = 0;

		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 48, ObjectValueType_Float, Damage);


		//Set Param:
		DHookSetParamObjectPtrVar(hParams, 1, 60, ObjectValueType_Int, DamageType);
	}

	//Declare:
	int Result = DHookGetReturn(hReturn);

	//Set Return:
	DHookSetReturn(hReturn, Result);

	//Return:
	return MRES_Override;
}

public MRESReturn OnPreClientGiveNamedItem(int Client, Handle hReturn, Handle hParams, const char[] WeaponName, int Weapon, int Unknown)
{

	//Check:
	if(CanClientWeaponEquip(Client) == false)
	{

		//Set Return:
		DHookSetReturn(hReturn, 0);

		//Return:
		return MRES_Supercede;
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientWeaponEquip(int Client, Handle hParams, int Weapon)
{

	//Print:
	//PrintToConsole(Client, "|RP| - %N Weapon = %i!", Client, Weapon);

	//Check:
	if(CanClientWeaponEquip(Client) == false)
	{

		//Remove Clean:
		RemoveWeapon(Weapon);

		//Return:
		return MRES_Supercede;
	}

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

	//Valid Check:
	if(StrContains(ClassName, "weapon_physcannon", false) != -1)
	{

		//Add Extra Slots:
		if(GetItemAmount(Client, 306) > 0)
		{

			//Set Color:
			SetEntityRenderColor(Weapon, 100, 100, 255, 255);

			//Set Effect:
			SetEntityRenderMode(Weapon, RENDER_GLOW);
		}
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientWeaponDrop(int Client, Handle hParams)
{

	//Not Cop:
	if(!IsCop(Client))
	{

		//Declare:
		char ClientWeapon[32];

		//Get Entity Info:
		GetClientWeapon(Client, ClientWeapon, sizeof(ClientWeapon));

		//Loose Weapon:
		//int Weapon = WeaponDrop(Client, ClientWeapon, 2);
		WeaponDrop(Client, ClientWeapon, 2);

		//Print:
		//PrintToServer("|RP| - %N Weapon %s = Index = %i!", Client, ClientWeapon, Weapon);
	}

	//Return:
	return MRES_Supercede;
}

public MRESReturn OnClientPreDeathSound(int Client, Handle hParams, int &Attacker, int &Inflictor, int &Weapon, float &fDamage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Check:
	if(IsLoaded(Client) == false)
	{

		//Return:
		return MRES_Supercede;
	}

	//Declare:
	char DeathSound[128] = "Null";

	int Random = -1;

	//IsCop:
	if(IsCop(Client))
	{

		//Is Elite Combine!
		if(StrContains(GetModel(Client), "combine", false) != -1)
		{

			//Declare:
			Random = GetRandomInt(1, 4);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "npc/combine_soldier/die%i.wav", Random);

		}

		//Override:
		else
		{

			//Declare:
			Random = GetRandomInt(1, 4);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "npc/metropolice/die%i.wav", Random);
		}
	}

	//Override:
	else
	{

		//Is Female:
		if(StrContains(GetModel(Client), "female", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(1, 2);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/female01/ow0%i.wav", Random);
		}

		//Is Female:
		if(StrContains(GetModel(Client), "male", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(1, 2);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/male01/ow0%i.wav", Random);
		}

		//Is Alyx!
		if(StrContains(GetModel(Client), "alyx", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(4, 8);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/alyx/hurt0%i.wav", Random);
		}

		//Is Barney!
		if(StrContains(GetModel(Client), "barney", false) != -1)
		{

			//Initialize:
			Random = GetRandomInt(1, 9);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/barney/ba_pain0%i.wav", Random);
		}

		//Is Monk!
		if(StrContains(GetModel(Client), "monk", false) != -1)
		{

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/ravenholm/monk_death07.wav");
		}

		//Is Gman!
		if(StrContains(GetModel(Client), "gman", false) != -1)
		{

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/citadel/gman_exit10.wav");
		}

		//Override:
		else if(StrEqual(DeathSound, "Null"))
		{

			//Initialize:
			Random = GetRandomInt(1, 2);

			//Format:
			Format(DeathSound, sizeof(DeathSound), "vo/npc/male01/ow0%i.wav", Random);
		}
	}

	//Check:
	if(DamageType == DMG_FALL)
	{

		//Initialize:
		Random = GetRandomInt(1, 3); if(Random == 2) Random = 3;

		//Format:
		Format(DeathSound, sizeof(DeathSound), "Player/pl_fallpain%i.wav", Random);
	}

	//Check:
	if(DamageType == DMG_DROWN)
	{

		//Initialize:
		Random = GetRandomInt(1, 3);

		//Format:
		Format(DeathSound, sizeof(DeathSound), "Player/pl_drown%i.wav", Random);
	}

	//Check:
	if(DamageType == DMG_DROWN)
	{

		//Initialize:
		Random = GetRandomInt(1, 3);

		//Format:
		Format(DeathSound, sizeof(DeathSound), "Player/pl_drown%i.wav", Random);
	}

	//Print:
	//PrintToServer("|RP| - %N DeathSound %s !", Client, DeathSound);

	//Check:
	if(!StrEqual(DeathSound, "Null"))
	{

		//Declare
		float vecPos[3];

		//Initulize:
		GetClientAbsOrigin(Client, vecPos);

		//Is Precached:
		if(IsSoundPrecached(DeathSound)) PrecacheSound(DeathSound);

		//Emit Sound:
		EmitSoundToAll(DeathSound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);
	}

	//Check:
	if(DamageType == DMG_DISSOLVE)
	{

		//Declare
		float vecPos[3];

		//Initulize:
		GetClientAbsOrigin(Client, vecPos);

		//Initialize:
		Random = GetRandomInt(5, 9);

		//Format:
		Format(DeathSound, sizeof(DeathSound), "ambient/energy/zap%i.wav", Random);

		//Is Precached:
		if(IsSoundPrecached(DeathSound)) PrecacheSound(DeathSound);

		//Emit Sound:
		EmitSoundToAll(DeathSound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);
	}

	//Return:
	return MRES_Supercede;
}

public MRESReturn OnPreClientStartTouch(int Client, Handle hParams, int OtherEntity)
{

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientTouch(int Client, Handle hParams, int OtherEntity)
{


	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientEndTouch(int Client, Handle hParams, int OtherEntity)
{


	//Return:
	return MRES_Ignored;
}

public MRESReturn OnClientPreThinkPre(int Client, Handle hParams)
{

	//Fix Client View:
	OnClientPreThinkVehicleViewFix(Client);

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPreClientStartObserverMode(int Client, Handle hReturn, Handle hParams, int Mode, bool Result)
{

	//Set Return:
	DHookSetReturn(hReturn, Result);

	//Return:
	return MRES_Supercede;
}

public MRESReturn OnClientPostSpawn(int Client, Handle hParams)
{

	//Check:
	if(IsLoaded(Client))
	{

		//Is Cuffed:
		if(IsCuffed(Client))
		{

			//Cuff:
			Cuff(Client);

			//Jail:
			JailClient(Client, Client);
		}

		//Override:
		else
		{

			//Spawn Client:
			InitSpawnPos(Client, 1);

			//Setup Roleplay Job:
			SetupRoleplayJob(Client);
		}
	}

	//Timer
	CreateTimer(0.1, PostClientSpawned, Client);

	//Reset Overlay:
	ResetClientOverlay(Client);

	//Return:
	return MRES_Ignored;
}

public Action PostClientSpawned(Handle Timer, any Client)
{

	//Check:
	if(!StrEqual(GetHatModel(Client), "null"))
	{

		//Create Hat:
		CreateHat(Client, GetHatModel(Client));
	}

	//Create Player Trail Effects:
	CreatePlayerTrails(Client);
}

public MRESReturn OnClientOnTakeDamagePost(int Client, Handle hParams, Handle hReturn, int &Attacker, int &Inflictor, int &Weapon, float &Damage, int &DamageType, const float DamageForce[3], const float DamagePosition[3])
{

	//Check Ciritical:
	OnDamageCriticalCheck(Client);

	//Return:
	return MRES_Ignored; 
}

public MRESReturn OnClientPostThinkPost(int Client, Handle hParams)
{

	//Is Client Cuffed:
	if(IsCuffed(Client) || GetIsCritical(Client) || IsSleeping(Client) > 0)
	{

		//Set Suit:
		SetEntPropFloat(Client, Prop_Send, "m_flSuitPower", 0.0);

		SetEntPropFloat(Client, Prop_Data, "m_flSuitPowerLoad", 0.0);
	}

	//Declare:
	int OnGround = GetEntityFlags(Client);

	//Check Has Jumped!
	if(OnGround & FL_ONGROUND && PrethinkJump[Client] != 0)
	{

		//Initulize:
		PrethinkJump[Client] = 0;

		Jump[Client] = 0;
	}

	//Return:
	return MRES_Ignored; 
}

public MRESReturn OnPostClientWeaponEquip(int Client, Handle hParams, int Weapon)
{

	//Set Ammo!
	SetEquipAmmo(Client, Weapon);

	//Return:
	return MRES_Ignored;
}
