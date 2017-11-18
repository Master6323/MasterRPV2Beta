//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hl2dmfixes_included_
  #endinput
#endif
#define _rp_hl2dmfixes_included_
#if defined HL2DM
float g_fBlockTime[MAXPLAYERS + 1];
bool g_bHasCrossbow[MAXPLAYERS + 1];

//Set Team Play:
public void IntHL2MP()
{

	//Declare:
	int Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "hl2mp_gamerules")) != -1)
	{

		//Set Ent Data:
		SetEntData(Ent, FindSendPropInfo("CHL2MPGameRulesProxy", "m_bTeamPlayEnabled"), 1, 1, true);
	}

	// Hooks:
	AddTempEntHook("Shotgun Shot", EventFireBullets);
}

//Fix:
public Action HL2dmButtonFix(int Client, int &Buttons, int &impulse, float vel[3], float angles[3], int &Weapon)
{

	// Detecting a crossbow shot.
	if((Buttons & IN_ATTACK) && g_bHasCrossbow[Client])
	{

		//Declare:
		int iWeapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

		//Check:
		if (IsValidEdict(iWeapon) && GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime())
		{

			//Initulize:
			g_fBlockTime[Client] = GetGameTime() + 0.1;
		}
	}
	
	// Don't let the player crouch if they are in the process of standing up.
	if((Buttons & IN_DUCK) && GetEntProp(Client, Prop_Send, "m_bDucked", 1) && GetEntProp(Client, Prop_Send, "m_bDucking", 1))
	{

		//Initulize:
		Buttons ^= IN_DUCK;
	}
	
	// Only allow sprint if the player is alive.
	if((Buttons & IN_SPEED) && !IsPlayerAlive(Client))
	{

		//Initulize:
		Buttons ^= IN_SPEED;
	}
	
	// Block flashlight/weapon toggle after a bullet has fired.
	if((impulse == 51) || (impulse == 100 && g_fBlockTime[Client] > GetGameTime()))
	{

		//Initulize:
		impulse = 0;
	}

	//Check:
	if(Weapon && IsValidEdict(Weapon) && g_fBlockTime[Client] > GetGameTime())
	{

		//Declare:
		char ClassName[32];

		//Initulize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		if(StrEqual(ClassName, "weapon_physcannon"))
		{

			//Initulize:
			Weapon = 0;
		}
	}

	//Is Alive:
	if(IsProtected(Client))
	{

		//Button Preventsion:
		Buttons &= ~IN_ATTACK;

		//Button Preventsion:
		Buttons &= ~IN_ATTACK2;
	}

	//Initulize:
	int CurrentWeapon = GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon");

	if(CurrentWeapon != -1)
	{

		//Declare:
		char ClassName[32];

		//Initulize:
		GetEdictClassname(CurrentWeapon, ClassName, sizeof(ClassName));

		//Check:
		if(!strcmp(ClassName, "weapon_shotgun") && (Buttons & IN_ATTACK2) == IN_ATTACK2)
		{

			//Initulize:
			Buttons |= IN_ATTACK;
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action EventFireBullets(const char[] te_name, const int[] Players, int numClients, float delay)
{

	//Declare:
	int Ent = TE_ReadNum("m_iPlayer");

	//Check:
	if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent))
	{

		//Initulize:
		g_fBlockTime[Ent] = GetGameTime() + 0.1;
	}

	//Check:
	if(Ent > GetMaxClients())
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Check:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Is In Line Of Sight!
				if(IsTargetInLineOfSight(Ent, i))
				{

					//SDKHooks Forward:
					SDKHooks_TakeDamage(i, Ent, Ent, 15.0, DMG_BUCKSHOT);
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public void initGravGunSwitchFix(int Client)
{

	//Initulize:
	int weapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

	//Is Valid:
	if(IsValidEdict(weapon))
	{

		//Declare:
		char ClassName[32];

		//Initulize:
		GetEdictClassname(weapon, ClassName, sizeof(ClassName));

		//Check If Player is using Glitch:
		if(StrEqual(ClassName, "weapon_physcannon") && GetEntProp(weapon, Prop_Send, "m_bActive", 1))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been slayed due to Exploit!");

			//Kill Player:
			ForcePlayerSuicide(Client);
		}
	}
}
/*
public Action OnClientWeaponCanSwitchTo(int Client, int Weapon)
{

	//Check:
	if(IsValidEdict(Weapon))
	{

		//Declare
		char ClassName[32];

		//Initulize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		//Check:
		if (g_fBlockTime[Client] > GetGameTime() && StrEqual(ClassName, "weapon_physcannon"))
		{

			//Return:
			return Plugin_Handled;
		}
	}

	//Return:
	return Plugin_Continue;
}

public void OnClientWeaponSwitchPost(int Client, int Weapon)
{

	//Check:
	if(IsValidEdict(Weapon))
	{

		//Declare
		char ClassName[32];

		//Initulize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		//Check:
		if(StrEqual(ClassName, "weapon_crossbow"))
		{

			//Initulize:
			g_bHasCrossbow[Client] = true;
		}
	}

	//Initulize:
	g_bHasCrossbow[Client] = false;
}
*/
#endif