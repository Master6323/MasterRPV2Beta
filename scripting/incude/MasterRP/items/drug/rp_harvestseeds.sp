//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_harvestseeds_included_
  #endinput
#endif
#define _rp_harvestseeds_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Seeds:
int SeedsEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int SeedsType[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int SeedsHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char SeedsModel[256] = "models/katharsmodels/contraband/zak_wiet/zak_seed.mdl";

public void initSeeds()
{

	//Commands:
	RegAdminCmd("sm_testseeds", Command_TestSeeds, ADMFLAG_ROOT, "<Id> - Creates a Seeds");
}

public void initDefaultSeeds(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		SeedsEnt[Client][X] = -1;

		SeedsHealth[Client][X] = 0;

		SeedsType[Client][X] = 0;
	}
}

public bool IsValidSeeds(Ent)
{

	//Declare:
	bool Result = false;

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
				if(SeedsEnt[i][X] == Ent)
				{

					//Initulize:
					Result = true;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public int GetSeedsIdFromEnt(int Ent)
{

	//Declare:
	int Result = -1;

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
				if(SeedsEnt[i][X] == Ent)
				{

					//Initulize:
					Result = X;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public int GetSeedsOwnerFromEnt(int Ent)
{

	//Declare:
	int Result = -1;

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
				if(SeedsEnt[i][X] == Ent)
				{

					//Initulize:
					Result = i;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public int HasClientSeeds(int Client, int Id)
{

	//Is Valid:
	if(SeedsEnt[Client][Id] > 0)
	{

		//Return:
		return SeedsEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetSeedsHealth(int Client, int Id)
{

	//Return:
	return SeedsHealth[Client][Id];
}

public void SetSeedsHealth(int Client, int Id, int Amount)
{

	//Initulize:
	SeedsHealth[Client][Id] = Amount;
}

public int GetSeedsType(int Client, int Id)
{

	//Return:
	return SeedsType[Client][Id];
}

public void SetSeedsType(int Client, int Id, int Type)
{

	//Initulize:
	SeedsType[Client][Id] = Type;
}

public void initSeedsTime()
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
				if(IsValidEdict(SeedsEnt[i][X]))
				{

					//Check:
					if(SeedsHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 19, X);

						//Remove:
						RemoveSeeds(i, X);
					}
				}
			}
		}
	}
}

public void SeedsHud(Client, Ent)
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
				if(SeedsEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Normal Seeds:
					if(SeedsType[i][X] == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Drug Seeds:\nHealth: %i", SeedsHealth[i][X]);
					}

					//GMO Seeds
					if(SeedsType[i][X] == 2)
					{

						//Format:

						Format(FormatMessage, sizeof(FormatMessage), "GMO Drug Seeds:\nHealth: %i", SeedsHealth[i][X]);
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

public void RemoveSeeds(Client, X)
{

	//Initulize:
	SeedsHealth[Client][X] = 0;

	SeedsType[Client][X] = 0;

	//Accept:
	AcceptEntityInput(SeedsEnt[Client][X], "kill");

	//Inituze:
	SeedsEnt[Client][X] = -1;
}

public bool CreateSeeds(int Client, int Id, int Type, int Health, float Position[3], float Angle[3], bool IsConnected)
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
		Position[0] = (ClientOrigin[0] + (FloatMul(100.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(100.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 100);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - Unable to spawn Seeds due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 19, Id, 0, Type, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - You have just spawned a Seeds!");
	}

	//Initulize:
	SeedsType[Client][Id] = Type;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	SeedsHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", SeedsModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	SeedsEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientSeeds);

	//Touch Hook:
	SDKHook(Ent, SDKHook_StartTouch, OnSeedsStartTouch);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Drug_Seeds");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (SeedsHealth[Client][Id] / 2), (SeedsHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestSeeds(int Client, int Args)
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
	if(Args < 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testSeeds <Id> <type> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sType[32];
	char sHealth[32];
	int Id = 0;
	int Type = 0;
	int Health = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sType, sizeof(sType));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Type = StringToInt(sType);

	Health = StringToInt(sHealth);

	if(SeedsEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Seeds with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Seeds %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Seeds:
	CreateSeeds(Client, Id, Type, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsSeedsUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

		//Declare:
		int Var = StringToInt(GetItemVar(ItemId));

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
			Ent = HasClientSeeds(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateSeeds
				if(CreateSeeds(Client, Y, Var, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - You already have too many Seeds, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientSeeds(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(SeedsEnt[i][X] == Ent)
			{

				//Check:
				if(Ent2 > 0 && Ent2 <= GetMaxClients() && IsClientConnected(Ent2))
				{

					//Check:
					if(Ent2 == i)
					{

						//Declare:
						char WeaponName[32];

						//Initulize;
						GetClientWeapon(Ent2, WeaponName, sizeof(WeaponName));

						//Check:
						if(StrContains(WeaponName, GetRepareWeapon(), false) == 0)
						{

							//Initulize:
							if(SeedsHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								SeedsHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								SeedsHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (SeedsHealth[i][X] / 2), (SeedsHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientSeeds(SeedsEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientSeeds(SeedsEnt[i][X], Damage, Ent2);
					}
				}

				//stop:
				break;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action DamageClientSeeds(int Ent, float &Damage, int &Attacker)
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
				if(SeedsEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) SeedsHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (SeedsHealth[i][X] / 2), (SeedsHealth[i][X] / 2), 255);

					//Check:
					if(SeedsHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 17, X);

						//Remove:
						RemoveSeeds(i, X);
					}

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool IsSeedsInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(SeedsEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, SeedsEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

//On Entity Touch:
public void OnSeedsStartTouch(int Ent, int OtherEnt)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(OtherEnt, ClassName, sizeof(ClassName));

	//Prop Plant Drug:
	if(StrEqual(ClassName, "prop_Plant_Drug"))
	{

		//Declare:
		int Client = GetPlantOwnerFromEnt(OtherEnt);

		int Id = GetPlantIdFromEnt(OtherEnt);

		//Check:
		if(GetIsPlanted(Client, Id) == 0)
		{

			//Declare:
			int Client2 = GetSeedsOwnerFromEnt(Ent);

			int Id2 = GetSeedsIdFromEnt(Ent);

			//Initulize:
			SetIsPlanted(Client, Id, 1);

			SetPlantTime(Client, Id, 800);

			SetPlantType(Client, Id, SeedsType[Client2][Id2]);

			//Remove From DB:
			RemoveSpawnedItem(Client2, 19, Id2);

			//Remove:
			RemoveSeeds(Client2, Id2);

			//Set Crime:
			SetCrime(Client, (GetCrime(Client) + 1000));
		}
	}
}