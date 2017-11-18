//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_sleeping_included_
  #endinput
#endif
#define _rp_sleeping_included_

//Sleeping:
int Sleeping[MAXPLAYERS + 1] = {0,...};

//Couch Models:
char Couch01[255] = "models/props_c17/FurnitureCouch001a.mdl";

public void initSleeping()
{

	//Commands:
	RegConsoleCmd("sm_wakeup", Command_Wakeup);
}

public void OnCouchUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
		{

			//Declare:
			bool Result = false;

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(Sleeping[i] == Ent)
					{

						//Initulize:
						Result = true;
					}
				}
			}

			//Check:
			if(Result == false)
			{

				//Sleeping:
				Sleeping[Client] = Ent;

				//Declare:
				float CouchOrigin[3];

				//Get Prop Data:
				GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", CouchOrigin);

				//Initulize:
				CouchOrigin[2] -= 15;

				//Teleport:
				TeleportEntity(Client, CouchOrigin, NULL_VECTOR, NULL_VECTOR);

				//Set Speed:
				SetEntitySpeed(Client, 0.0);

				//Set Screen:
				PerformBlind(Client, 250);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - type '!wakeup' to get off the couch!");

				// Noblock active ie: Players can walk thru each other
				SetEntData(Client, GetCollisionOffset(), 2, 4, true);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - A player is already sleeping on this couch!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Couch!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public void CouchHud(int Client, int Ent)
{

	//Declare:
	char FormatMessage[255];
	bool Result = false;
	int Player = 0;
	int len = 0;

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Check:
			if(Sleeping[i] == Ent && Sleeping[i] != -1 && i != 33)
			{

				//Initulize:
				Result = true;

				Player = i;

				//Break:
				break;
			}
		}
	}

	//Check:
	if(Result == true)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Sleeping:\n%N is sleeping on this couch!", Player);
	}

	//Override:
	else
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Sleeping:\nPress <<Use>> to go to sleep on the couch!");
	}

	//Declare:
	float Pos[2] = {-1.0, -0.805};
	int Color[4];

	//Initulize:
	Color[0] = GetEntityHudColor(Client, 0);
	Color[1] = GetEntityHudColor(Client, 1);
	Color[2] = GetEntityHudColor(Client, 2);
	Color[3] = 255;

	//Check:
	if(GetGame() != 2 && GetGame() != 3)
	{

		//Show Hud Text:
		CSGOShowHudTextEx(Client, 1, Pos, Color, Color, 0.5, 0, 6.0, 0.1, 0.2, FormatMessage);
	}

	//Override:
	else
	{

		//Show Hud Text:
		ShowHudTextEx(Client, 1, Pos, Color, 0.5, 0, 6.0, 0.1, 0.2, FormatMessage);
	}
}

public Action Command_Wakeup(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - this command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Sleeping[Client] != -1)
	{

		//Declare:
		int Ent = Sleeping[Client];

		//Declare:
		float CouchOrigin[3];

		//Get Prop Data:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", CouchOrigin);

		//Initulize:
		CouchOrigin[2] += 18;

		//Teleport:
		TeleportEntity(Client, CouchOrigin, NULL_VECTOR, NULL_VECTOR);

		//Set Speed:
		SetEntitySpeed(Client, 1.0);

		//Set Screen:
		PerformUnBlind(Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have woke up from sleep!");

		//Initulize:
		Sleeping[Client] = -1;

		// CAN NOT PASS THRU ie: Players can jump on each other
		SetEntData(Client, GetCollisionOffset(), 5, 4, true);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not asleep you can't wakeup!");
	}

	//Return:
	return Plugin_Handled;
}

public int IsSleeping(int Client)
{

	//Return:
	return Sleeping[Client];
}

//Disconnect:
public void ResetSleeping(int Client)
{

	//Initulize:
	Sleeping[Client] = -1;
}

public bool IsValidCouch(int Ent, const char[] ClassName)
{

	//Is Valid:
	if(StrContains(ClassName, "Prop", false) != -1)
	{

		//Declare:
		char ModelName[128];

		//Initialize:
		GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, 128);

		//Is Valid:
		if(StrContains(ModelName, Couch01, false) != -1)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}
