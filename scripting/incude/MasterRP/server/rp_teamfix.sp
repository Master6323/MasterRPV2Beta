//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_teamfix_included_
  #endinput
#endif
#define _rp_teamfix_included_

//ManageTeams:
public void OnManageClientTeam(int Client)
{

	//Change Team:
	ChangeClientTeamInt(Client);

	//Set Model:
	SetClientModelInt(Client);
}

public void ChangeClientTeamInt(int Client)
{

	//Declare:
	int LifeState = GetEntProp(Client, Prop_Send, "m_lifeState");

	//Send:
	SetEntProp(Client, Prop_Send, "m_lifeState", 2);

	//Check:
	if(GetGame() == 1)
	{

		//Check: // unsure if this works in other games extra teams, as team 1 is normally used for spectator
		if(!IsCop(Client) && (IsAdmin(Client) || GetDonator(Client) > 0)) 
		{

			//Initulize:
			ChangeClientTeamEx(Client, 3);

			ChangeClientTeam(Client, 3);

			ChangeClientTeamEx(Client, 1);
		}

		//Is Client Cop: //dont remove the else or causes bug!
		else if(IsCop(Client))
		{

			//Initulize:
			ChangeClientTeamEx(Client, 2);

			ChangeClientTeam(Client, 2);
		}

		//Override:
		else
		{

			//Initulize:
			ChangeClientTeamEx(Client, 3);

			ChangeClientTeam(Client, 3);
		}
	}

	//Override: // Multi game includes:
	else
	{

		//Is Client Cop:
		if(IsCop(Client))
		{

			//Initulize:
			ChangeClientTeamEx(Client, 2);
#if defined DEFAULT
			ChangeClientTeam(Client, 2);
#endif
#if defined CSS
			CS_SwitchTeam(Client, 2);
#endif
#if defined CSGO
			CS_SwitchTeam(Client, 2);
#endif
#if defined TF2
			TF2_ChangeClientTeam(Client, 2);
#endif
#if defined TF2BETA
			TF2_ChangeClientTeam(Client, 2);
#endif
#if defined L4D
			ChangeClientTeam(Client, 2);
#endif
#if defined L4D2
			ChangeClientTeam(Client, 2);
#endif
		}

		//Override:
		else
		{

			//Initulize:
			ChangeClientTeamEx(Client, 3);
#if defined DEFAULT
			ChangeClientTeam(Client, 3);
#endif
#if defined CSS
			CS_SwitchTeam(Client, 3);
#endif
#if defined CSGO
			CS_SwitchTeam(Client, 3);
#endif
#if defined TF2
			TF2_ChangeClientTeam(Client, 3);
#endif
#if defined TF2BETA
			TF2_ChangeClientTeam(Client, 3);
#endif
#if defined L4D
			ChangeClientTeam(Client, 3);
#endif
#if defined L4D2
			ChangeClientTeam(Client, 3);
#endif
		}
	}

	//Send:
	SetEntProp(Client, Prop_Send, "m_lifeState", LifeState);
}

public void SetClientModelInt(Client)
{

	//Declare:
	char ModelName[256];

	//Initialize:
	GetEntPropString(Client, Prop_Data, "m_ModelName", ModelName, 128);

	//Check:
	if(!StrEqual(GetModel(Client), ModelName) && !StrEqual(GetModel(Client), "null"))
	{

		//Is PreCached:
		if(!IsModelPrecached(GetModel(Client)))
		{

			//PreCache:
			PrecacheModel(GetModel(Client));
		}

		//Initialize:
		SetEntityModel(Client, GetModel(Client));
	}
}