//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_Battery_included_
  #endinput
#endif
#define _rp_Battery_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Battery:
int BatteryEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int BatteryHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float BatteryEnergy[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char BatteryModel[256] = "models/Items/car_battery01.mdl";

public void initBattery()
{

	//Commands:
	RegAdminCmd("sm_testbattery", Command_TestBattery, ADMFLAG_ROOT, "<Id> <Time> - Creates a Battery");
}

public void initDefaultBattery(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BatteryEnt[Client][X] = -1;

		BatteryHealth[Client][X] = 0;

		BatteryEnergy[Client][X] = 0.0;
	}
}

public int GetBatteryIdFromEnt(int Ent)
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
				if(BatteryEnt[i][X] == Ent)
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
public int GetBatteryOwnerFromEnt(int Ent)
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
				if(BatteryEnt[i][X] == Ent)
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

public int HasClientBattery(int Client, int Id)
{

	//Is Valid:
	if(BatteryEnt[Client][Id] > 0)
	{

		//Return:
		return BatteryEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetBatteryHealth(int Client, int Id)
{

	//Return:
	return BatteryHealth[Client][Id];
}

public void SetBatteryHealth(int Client, int Id, int Amount)
{

	//Initulize:
	BatteryHealth[Client][Id] = Amount;
}

public float GetBatteryEnergy(int Client, int Id)
{

	//Return:
	return BatteryEnergy[Client][Id];
}

public void SetBatteryEnergy(int Client, int Id, float Amount)
{

	//Initulize:
	BatteryEnergy[Client][Id] = Amount;
}

public void initBatteryTime()
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
				if(IsValidEdict(BatteryEnt[i][X]))
				{

					//Check:
					CheckGeneratorToBattery(i, X);

					//Check:
					if(BatteryHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 23, X);

						//Remove:
						RemoveBattery(i, X, true);
					}
				}
			}
		}
	}
}

//Check to see if the generator is in distance
public void CheckGeneratorToBattery(int Client, int Y)
{

	//Loop:
	for(int X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(X, ClassName, sizeof(ClassName));

			//Prop Battery:
			if(StrEqual(ClassName, "prop_Generator"))
			{

				//Check:
				if(IsInDistance(BatteryEnt[Client][Y], X))
				{

					//Declare:
					int Id = GetGeneratorIdFromEnt(X);

					//Check:
					if(GetGeneratorEnergy(Client, Id) - 0.10 > 0)
					{

						//Initulize:
						SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - 0.05));

						//Check:
						if(BatteryEnergy[Client][Y] < 500)
						{

							//Declare:
							float AddEnergy = GetRandomFloat(0.25, 0.35);

							//Initulize:
							SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - AddEnergy));

							BatteryEnergy[Client][Y] += AddEnergy;

							//Check:
							if(AddEnergy > 500)
							{

								//Initulize:
								BatteryEnergy[Client][Y] = 500.0;
							}
						}
					}

					//Stop:
					break;
				}
			}
		}
	}
}

public void BatteryHud(int Client, int Ent)
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
				if(BatteryEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Battery:\nEnergy: %0.2fWz\nHealth: %i", BatteryEnergy[i][X], BatteryHealth[i][X]);

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

public void RemoveBattery(int Client, int X, bool Result)
{

	//Initulize:
	BatteryHealth[Client][X] = 0;

	BatteryEnergy[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(BatteryEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(BatteryEnt[Client][X]);
	}

	//Check:
	if(Result == true)
	{

		//Explode:
		CreateExplosion(Client, BatteryEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(BatteryEnt[Client][X], "kill");

	//Inituze:
	BatteryEnt[Client][X] = -1;
}

public bool CreateBattery(int Client, int Id, float fEnergy, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - Unable to spawn Acetone Can due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", fEnergy);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 23, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You have just spawned a Acetone Can!");
	}

	//Initulize:
	BatteryEnergy[Client][Id] = fEnergy;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	BatteryHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BatteryModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BatteryEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientBattery);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Battery");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (BatteryHealth[Client][Id] / 2), (BatteryHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestBattery(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testBattery <Id> <Energy> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sEnergy[32];
	char sHealth[32];
	int Id = 0;
	int Health = 0;
	float fEnergy = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sEnergy, sizeof(sEnergy));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	fEnergy = StringToFloat(sEnergy);

	Health = StringToInt(sHealth);

	if(BatteryEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Acetone Can with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Acetone Can %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Battery:
	CreateBattery(Client, Id, fEnergy, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsBatteryUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int MaxSlots = 1;

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
			Ent = HasClientBattery(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float fEnergy = 0.0;

				//CreateBattery
				if(CreateBattery(Client, Y, fEnergy, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You already have too many Acetone Can, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientBattery(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(BatteryEnt[i][X] == Ent)
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
							if(BatteryHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								BatteryHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								BatteryHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (BatteryHealth[i][X] / 2), (BatteryHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientBattery(BatteryEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientBattery(BatteryEnt[i][X], Damage, Ent2);
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

public Action DamageClientBattery(int Ent, float &Damage, int &Attacker)
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
				if(BatteryEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) BatteryHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (BatteryHealth[i][X] / 2), (BatteryHealth[i][X] / 2), 255);

					//Check:
					if(BatteryHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 23, X);

						//Remove:
						RemoveBattery(i, X, true);
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

public bool IsBatteryInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(BatteryEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, BatteryEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}