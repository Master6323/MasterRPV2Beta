//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cvar_included_
  #endinput
#endif
#define _rp_cvar_included_

//ConVars Handles:
ConVar CV_ROBTIME;
ConVar CV_CRIMEBOUNTY;
ConVar CV_COPDROP;
ConVar CV_CUFFDAMAGE;
ConVar CV_COPKILL;
ConVar CV_ALLCOPUNCUFF;
ConVar CV_PHYSDAMAGE;
ConVar CV_PROTECT;
ConVar CV_HUNGER;
ConVar CV_DEPOSIT;
ConVar SV_CHEATS;
ConVar MP_FORCECAMERA;

//ConVars Values:
enum CVarValues
{
	ROBTIME = 1,
	CRIMEBOUNTY = 2,
	COPDROP = 3,
	CUFFDAMAGE = 4,
	COPKILL = 5,
	ALLCOPUNCUFF = 6,
	PHYSDAMAGE = 7,
	PROTECT = 8,
	HUNGER = 9,
	DEPOSIT = 10,
	CHEATS = 11,
};

//CVar Handle:
int CVarValue[CVarValues];

public void initCvar()
{

	//ConVar:
	CV_CRIMEBOUNTY = CreateConVar("sm_setbounty_start", "20000","Set crime to bounty start limitdefault (5000)");

	CV_ROBTIME = CreateConVar("sm_robtime", "600", "Npc Robbing interval default (900)");

	CV_COPDROP = CreateConVar("sm_disable_copdrop", "0", "disable/enableDo cops drop money on death default (0)");

	CV_CUFFDAMAGE = CreateConVar("sm_disable_cuff_damage", "1", "disable/enable damage while a player is default (1)");

	CV_COPKILL = CreateConVar("sm_disable_cop_kill", "0", "Disable/Enable teamkilling for cops default (0)");

	CV_ALLCOPUNCUFF = CreateConVar("sm_disable_copcuff", "1", "disable/enable cops uncuff default (0)");

	CV_PHYSDAMAGE = CreateConVar("sm_disable_physdamage", "1", "disable/enable physdamage from props default (1)");

	CV_PROTECT = CreateConVar("sm_protect_time", "5.0", "set the spawn protection time default (10.0)");

	CV_HUNGER = CreateConVar("sm_disable_hunger", "0", "Disable/Enable  default (1)");

	CV_DEPOSIT = CreateConVar("sm_quickdepsoit", "1", "default 1");

	SV_CHEATS = FindConVar("sv_cheats");

	MP_FORCECAMERA = FindConVar("mp_forcecamera");

	//ConVar Hooks:
	CV_CRIMEBOUNTY.AddChangeHook(OnConVarChange);

	CV_ROBTIME.AddChangeHook(OnConVarChange);

	CV_COPDROP.AddChangeHook(OnConVarChange);

	CV_CUFFDAMAGE.AddChangeHook(OnConVarChange);

	CV_COPKILL.AddChangeHook(OnConVarChange);

	CV_ALLCOPUNCUFF.AddChangeHook(OnConVarChange);

	CV_PHYSDAMAGE.AddChangeHook(OnConVarChange);

	CV_PROTECT.AddChangeHook(OnConVarChange);

	CV_HUNGER.AddChangeHook(OnConVarChange);

	CV_DEPOSIT.AddChangeHook(OnConVarChange);

	SV_CHEATS.AddChangeHook(OnConVarChange);
}

public void OnConfigsExecuted()
{

	//Get Values:
	CVarValue[ROBTIME] = GetConVarInt(CV_ROBTIME);

	CVarValue[CRIMEBOUNTY] = GetConVarInt(CV_CRIMEBOUNTY);

	CVarValue[COPDROP] = GetConVarInt(CV_COPDROP);

	CVarValue[CUFFDAMAGE] = GetConVarInt(CV_CUFFDAMAGE);

	CVarValue[COPKILL] = GetConVarInt(CV_COPKILL);

	CVarValue[ALLCOPUNCUFF] = GetConVarInt(CV_ALLCOPUNCUFF);

	CVarValue[PHYSDAMAGE] = GetConVarInt(CV_PHYSDAMAGE);

	CVarValue[PROTECT] = GetConVarInt(CV_PROTECT);

	CVarValue[HUNGER] = GetConVarInt(CV_HUNGER);

	CVarValue[DEPOSIT] = GetConVarInt(CV_DEPOSIT);

	CVarValue[CHEATS] = GetConVarInt(SV_CHEATS);
#if defined BANS
	//Bans Cfg:
	OnBansExecuted();
#endif
}

public void OnConVarChange(ConVar hCVar, char[] oldValue, char[] newValue) 
{

	//Check Handle:
	if(hCVar == CV_ROBTIME)
	{

		//Initulize:
		CVarValue[ROBTIME] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_CRIMEBOUNTY)
	{

		//Initulize:
		CVarValue[CRIMEBOUNTY] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_COPDROP)
	{

		//Initulize:
		CVarValue[COPDROP] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_CUFFDAMAGE)
	{

		//Initulize:
		CVarValue[CUFFDAMAGE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_COPKILL)
	{

		//Initulize:
		CVarValue[COPKILL] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_ALLCOPUNCUFF)
	{

		//Initulize:
		CVarValue[ALLCOPUNCUFF] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_PHYSDAMAGE)
	{

		//Initulize:
		CVarValue[PHYSDAMAGE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_PROTECT)
	{

		//Initulize:
		CVarValue[PROTECT] = StringToInt(newValue) * 2;
	}

	//Check Handle:
	if(hCVar == CV_HUNGER)
	{

		//Initulize:
		CVarValue[HUNGER] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CV_DEPOSIT)
	{

		//Initulize:
		CVarValue[DEPOSIT] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == SV_CHEATS)
	{

		//Initulize:
		CVarValue[CHEATS] = StringToInt(newValue);
	}
}

public int GetRobTime()
{

	return CVarValue[ROBTIME];
}

public int GetCrimeToBounty()
{

	return CVarValue[CRIMEBOUNTY];
}

public int IsCopDropDisabled()
{

	return CVarValue[COPDROP];
}

public int IsCuffDamageDisabled()
{

	return CVarValue[CUFFDAMAGE];
}

public int IsCopKillDisabled()
{

	return CVarValue[COPKILL];
}

public int IsPhysDamageDisabled()
{

	return CVarValue[PHYSDAMAGE];
}

public int IsCopUnCuffEnabled()
{

	return CVarValue[ALLCOPUNCUFF];
}


public int IsHungerDisabled()
{

	return CVarValue[HUNGER];
}

public int IsQuickDepositDisabled()
{

	return CVarValue[DEPOSIT];
}

public int GetSpawnProtectTime()
{

	return CVarValue[PROTECT];
}

public bool GetCheatsEnabled()
{

	return intTobool(CVarValue[CHEATS]);
}

public ConVar GetCheatsConVar()
{

	return SV_CHEATS;
}
public ConVar GetForceCameraConVar()
{

	return MP_FORCECAMERA;
}