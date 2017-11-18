//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_rice_included_
  #endinput
#endif
#define _rp_rice_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Rice:
int RiceTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int RiceEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int RiceGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char RiceModel[256] = "models/props_lab/cactus.mdl";

public void initRice()
{

	//Commands:
	RegAdminCmd("sm_testrice", Command_TestRice, ADMFLAG_ROOT, "<Id> <Time> - Creates a Rice");
}

public void initDefaultRice(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		RiceEnt[Client][X] = -1;

		RiceGrams[Client][X] = 0;

		RiceTime[Client][X] = 0;
	}
}

public int HasClientRice(int Client, int Id)
{

	//Is Valid:
	if(RiceEnt[Client][Id] > 0)
	{

		//Return:
		return RiceEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetRiceTime(int Client, int Id)
{

	//Return:
	return RiceTime[Client][Id];
}

public int GetRiceValue(Client, int Id)
{

	//Return:
	return RiceGrams[Client][Id];
}

public void OnRiceUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
		{

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Loop:
					for(int X = 1; X < MAXITEMSPAWN; X++)
					{

						//Is Valid:
						if(RiceEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You can't take rice!");
							}

							//Is Valid:
							else if(RiceTime[i][X] == 0 && Client == i)
							{
	
								//Declare:
								int Earns = RiceGrams[i][X];

								//Initulize:
								SetRice(Client, (GetRice(Client) + Earns));

								RiceGrams[i][X] = 0;
	
								//Remove From DB:
								RemoveSpawnedItem(i, 6, X);

								//Remove:
								RemoveRice(i, X);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You have collected â‚¬\x0732CD32%ig\x07FFFFFF from your Rice Plant!", Earns);
	
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Rice not ready to harvest. (\x0732CD32%i\x07FFFFFF) Seconds left!", RiceTime[i][X]);
							}
						}
					}
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Rice!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public void initRiceTime()
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(IsValidEdict(RiceEnt[i][X]))
				{

					//Declare:
					float EntOrigin[3];

					//Initialize:
					GetEntPropVector(RiceEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Check:
					if(RiceTime[i][X] > 0)
					{

						//Initulize:
						RiceTime[i][X] -= 1;

						//Declare:
						int Random = GetRandomInt(1, 10);

						//Valid:
						if(Random == 1)
						{

							//Initulize:
							Random = GetRandomInt(1, 2);

							//Max Drugs:
							if(RiceGrams[i][X] + Random < 200)
							{

								//Initulize:
								RiceGrams[i][X] += Random;
							}
						}
					}

					//Show CrimeHud:
					ShowItemToAll(EntOrigin);
				}
			}
		}
	}
}

public void RiceHud(int Client, int Ent)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(int X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(RiceEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Is Rice Finished:
					if(RiceTime[i][X] == 0)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Rice:\nHas Finished Growing!\nGrams (%ig)", RiceGrams[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Rice:\nFinishes Growing in %i Sec\nGrams (%ig)", RiceTime[i][X], RiceGrams[i][X]);
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
					if(GetGame() == 2 || GetGame() == 3)
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
			}
		}
	}
}

public void RemoveRice(int Client, int X)
{

	//Initulize:
	RiceTime[Client][X] = 0;

	RiceGrams[Client][X] = 0;

	//Accept:
	AcceptEntityInput(RiceEnt[Client][X], "kill");

	//Inituze:
	RiceEnt[Client][X] = -1;
}

public bool CreateRice(int Client, int Id, int Time, int Value, float Position[3], float Angle[3], bool IsConnected)
{

	//Check:
	if(IsConnected == false)
	{

		//Declare:
		float ClientOrigin[3];
		float EyeAngles[3];

		//Initialize:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

		//Initialize:
  		GetClientEyeAngles(Client, EyeAngles);

		//Initialize:
		Position[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 100);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Unable to spawn Rice Plant due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 5, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You have just spawned a Rice Kitchen!");
	}

	//Initulize:
	RiceTime[Client][Id] = Time;

	RiceGrams[Client][Id] = 0;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", RiceModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	RiceEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Plant_Rice");

	//Is Valid:
	if(StrContains(GetJob(Client), "Rice Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action Command_TestRice(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testrice <Id> <Time>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sTime[32];
	int Id = 0;
	int Time = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sTime, sizeof(sTime));

	Id = StringToInt(sId);

	Time = StringToInt(sTime);

	if(RiceEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Rice with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Rice %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//CreateRice
	CreateRice(Client, Id, Time, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsRiceUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

		//Valid Job:
		if(StrContains(GetJob(Client), "Drug Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 1;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 2;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "God Father", false) != -1)
		{

			//Initulize:
			MaxSlots = 3;
		}

		//Valid Job:
		if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Initulize:
			MaxSlots = 5;
		}

		//Declare:
		float ClientOrigin[3];
		float EyeAngles[3];

		//Initulize:
		GetClientAbsOrigin(Client, ClientOrigin);

		GetClientEyeAngles(Client, EyeAngles);

		//Declare:
		int Ent = -1;
		float Position[3];

		//Loop:
		for(int Y = 1; Y <= MaxSlots; Y++)
		{

			//Initulize:
			Ent = HasClientRice(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Rice:
				if(CreateRice(Client, Y, StringToInt(GetItemVar(ItemId)), 0, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You already have too many Rice Plants, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}