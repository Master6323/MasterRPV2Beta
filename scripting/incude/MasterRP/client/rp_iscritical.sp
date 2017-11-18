//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_critical_included_
  #endinput
#endif
#define _rp_critical_included_

bool IsCritical[2047] = {false,...};

//Health Manage:
public void initCriticalHealth(int Client)
{

	//Initialize:
	int CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP <= 20)
	{

		//Declare:
		float Angles[3];

		//Initialize:
		GetClientEyeAngles(Client, Angles);

		//Effect:
		CreateEnvBlood(Client, "null", Angles, 1.0);

		//Check:
		if(CHP - 2 > 1)
		{

			//Play Hurt SOUND: forward to rp_talksounds.sp
			OnClientHurtSound(Client);

			//Set Client Health:
			SetEntityHealth(Client, (CHP - 2));
		}

		//Override:
		else
		{

			//Slay Client:
			ForcePlayerSuicide(Client);
		}
	}

	//Is Already Critical:
	if(CHP > 20 && CHP < 100)
	{

		//Enough Health:
		if((CHP + 1) > 100)
		{

			//Set Ent Health:
			SetEntityHealth(Client, 100);
		}

		//Override:
		else
		{

			//Set Ent Health:
			SetEntityHealth(Client, (CHP + 1));
		}
	}
}

//Show Player Hud
public void ClientCriticalOverride(int Client)
{

	//Initialize:
	int CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP > 20 && IsCritical[Client])
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Initulize:
		IsCritical[Client] = false;
	}
}

//Event Damage:
public void OnDamageCriticalCheck(int Client)
{

	//Initialize:
	int CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP <= 20)
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye.vmt");

		//Initulize:
		IsCritical[Client] = true;
	}
}

public bool GetIsCritical(int Client)
{

	//Return:
	return IsCritical[Client];
}

public void SetIsCritical(int Client, bool Result)
{

	//Inituluize:
	IsCritical[Client] = Result;
}

public void ResetCritical(int Client)
{

	IsCritical[Client] = false;
}

public void ResetAllCritical()
{

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Inituluize:
		IsCritical[X] = false;
	}
}