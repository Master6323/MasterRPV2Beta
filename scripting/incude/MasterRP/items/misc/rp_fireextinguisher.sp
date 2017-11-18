//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_fireextinguisher_included_
  #endinput
#endif
#define _rp_fireextinguisher_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//FireExtinguisher:
int FireExtinguisherEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float FireExtinguisherGas[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char FireExtinguisherModel[256] = "models/props/cs_office/fire_extinguisher.mdl";

public void initFireExtinguisher()
{

	//Commands:
	RegAdminCmd("sm_testfireextinguisher", Command_TestFireExtinguisher, ADMFLAG_ROOT, "<Id> <Time> - Creates a FireExtinguisher");

	//Entity Event Hook:
	HookEntityOutput("prop_Fire_Extinguisher", "OnPhysGunOnlyPickup", OnClientPickupFireExtinguisher);
}

public void initDefaultFireExtinguisher(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		FireExtinguisherEnt[Client][X] = -1;

		FireExtinguisherGas[Client][X] = 0.0;
	}
}

public int HasClientFireExtinguisher(int Client, int Id)
{

	//Is Valid:
	if(FireExtinguisherEnt[Client][Id] > 0)
	{

		//Return:
		return FireExtinguisherEnt[Client][Id];
	}

	//Return:
	return -1;
}

public float GetFireExtinguisherGas(int Client, int Id)
{

	//Return:
	return FireExtinguisherGas[Client][Id];
}

public void OnFireExtinguisherUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Declare:
		int EntSlot = GetEntAttatchedEffect(Ent, 1);

		//Check:
		if(!IsValidEntity(EntSlot))
		{

			//Declare:
			float Angles[3] = {0.0, 0.0, 0.0};

			GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

			Angles[1] -= 95.0;

			int Effect = CreateEnvFireExtinguisher(Ent, "null", Angles);

			SetEntAttatchedEffect(Ent, 1, Effect);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-FireExtinguisher|\x07FFFFFF - You have turned on your Fire Extinguisher!");
		}

		//Is Valid:
		else
		{

			//Check:
			if(IsValidAttachedEffect(Ent))
			{

				//Remove:
				RemoveAttachedEffect(Ent);
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-FireExtinguisher|\x07FFFFFF - You have turned off your Fire Extinguisher!");
		}
	}
}

public void initFireExtinguisherTime()
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
				if(IsValidEdict(FireExtinguisherEnt[i][X]))
				{

					//Declare:
					int EntSlot = GetEntAttatchedEffect(FireExtinguisherEnt[i][X], 1);

					//Check:
					if(IsValidEntity(EntSlot))
					{

						//Initulize:
						FireExtinguisherGas[i][X] -= GetRandomFloat(0.25, 0.75);

						//Make Fire Extinguisher Put Put Fire!
						CheckIsPuttingOutFire(i, FireExtinguisherEnt[i][X]);

						//Is Valid:
						if(FireExtinguisherGas[i][X] < 0.0)
						{

							//Initulize:
							FireExtinguisherGas[i][X] = 0.0;

							//Check:
							if(IsValidAttachedEffect(FireExtinguisherEnt[i][X]))
							{

								//Remove:
								RemoveAttachedEffect(FireExtinguisherEnt[i][X]);
							}

							//Remove From DB:
							RemoveSpawnedItem(i, 31, X);

							//Remove:
							RemoveFireExtinguisher(i, X);
						}
					}
				}
			}
		}
	}
}

public void CheckIsPuttingOutFire(int Client, int Ent)
{

	//Declare:
	float Position[3] = {0.0, 0.0, 0.0};

	//Declare:
	float Angles[3] = {0.0, -95.0, 0.0};

	//Initulize:
	GetInFrontEntities(Ent, 200.0, Angles, Position);

	//Declare:
	int Color[4] = {255, 255, 50, 255};

	//Temp Ent:
	TE_SetupBeamRingPoint(Position, 1.0, 50.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, Color, 10, 0);

	//Show To Client:
	TE_SendToAll();

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Check:
		if(IsValidEntity(X) && IsEntityGlobalFire(X))
		{

			//Declare:
			float FireOrigin[3] = {0.0, 0.0, 0.0};

			//Initulize:
			GetEntPropVector(X, Prop_Data, "m_vecOrigin", FireOrigin);

			//Declare:
			float Dist = GetVectorDistance(Position, FireOrigin);

			//Check Distance:
			if(Dist < 100)
			{

				//Declare:
				bool Result = true;

				//Loop:
				for(int Y = 2; Y <= 10; Y++)
				{

					//Declare:
					int EntSlot = GetEntAttatchedEffect(X, Y);

					//Check:
					if(IsValidEntity(EntSlot))
					{

						//Accept:
						AcceptEntityInput(EntSlot, "kill");

						SetEntAttatchedEffect(Ent, Y, -1);

						//Initulize:
						Result = false;

						//Declare:
						int Amount = 300;

						//Initialize:
						SetBank(Client, (GetBank(Client) + Amount));

						//Set Menu State:
						BankState(Client, Amount);

						//Stop:
						break;
					}
				}

				//Check:
				if(Result == true)
				{

					//Remove:
					RemoveGlobalFire(Ent);

					//Loop:
					for(int i = 1; i <= GetMaxClients(); i++)
					{

						//Connected
						if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
						{

							//Print:
							CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Has put out the Fire!", Client);
						}
					}

					//Declare:
					int Amount = 2000;

					//Initialize:
					SetBank(Client, (GetBank(Client) + Amount));

					//Set Menu State:
					BankState(Client, Amount);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - You have put out the Fire and earned \x0732CD32%s!", IntToMoney(Amount));
				}
			}
		}
	}
}

public void FireExtinguisherHud(int Client, int Ent)
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
				if(FireExtinguisherEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Fire Extinguisher:\nGas (%.2f) Percent", FireExtinguisherGas[i][X]);

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

public void RemoveFireExtinguisher(int Client, int X)
{

	//Initulize:
	FireExtinguisherGas[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(FireExtinguisherEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(FireExtinguisherEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(FireExtinguisherEnt[Client][X], "kill");

	//Inituze:
	FireExtinguisherEnt[Client][X] = -1;
}

public bool CreateFireExtinguisher(int Client, int Id, float Value, float Position[3], float Angle[3], bool IsConnected)
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
		if(TR_PointOutsideWorld(ClientOrigin))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-FireExtinguisher|\x07FFFFFF - Unable to spawn-Fire Extinguisher due to outside of world");

			//Return:
			return false;
		}

		//Declare
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Value);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 31, 0, 0, 0, 0, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireExtinguisher|\x07FFFFFF - You have just spawned a FireExtinguisher!");
	}

	//Initulize:
	FireExtinguisherGas[Client][Id] = Value;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", FireExtinguisherModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	FireExtinguisherEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Fire_Extinguisher");

	//Is Valid:
	if(StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}

//OnPhysGunOnlyPickup Event:
public void OnClientPickupFireExtinguisher(const char[] Output, int Caller, int Activator, float Delay)
{

	//Is Valid:
	if(IsValidEdict(Caller))
	{

		//Declare:
		float Angles[3] = {0.0, 0.0, 0.0};

		//Initialize:
		GetEntPropVector(Activator, Prop_Data, "m_angRotation", Angles);

		//Do Math:
		Angles[0] = 0.0;
		Angles[1] += 95.0;
		Angles[2] = 0.0;

		//TelePort:
		TeleportEntity(Caller, NULL_VECTOR, Angles, NULL_VECTOR);
	}
}
//Create Garbage Zone:
public Action Command_TestFireExtinguisher(int Client, int Args)
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
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testfireextinguisher <Id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	int Id = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	Id = StringToInt(sId);

	if(FireExtinguisherEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money FireExtinguisher with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid FireExtinguisher %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//CreateFireExtinguisher
	CreateFireExtinguisher(Client, Id, 100.0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsFireExtinguisherUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireExtinguisher|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
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
			Ent = HasClientFireExtinguisher(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn FireExtinguisher:
				if(CreateFireExtinguisher(Client, Y, 100.0, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + 500));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-FireExtinguisher|\x07FFFFFF - You already have too many Fire Bombs, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}