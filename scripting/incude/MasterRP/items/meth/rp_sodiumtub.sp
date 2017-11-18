//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_sodiumtub_included_
  #endinput
#endif
#define _rp_sodiumtub_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//SodiumTub:
int SodiumTubEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int SodiumTubHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float SodiumTubGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char SodiumTubModel[256] = "models/winningrook/gtav/meth/sodium/sodium.mdl";

public void initSodiumTub()
{

	//Commands:
	RegAdminCmd("sm_testsodiumtub", Command_TestSodiumTub, ADMFLAG_ROOT, "<Id> <Time> - Creates a SodiumTub");
}

public void initDefaultSodiumTub(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		SodiumTubEnt[Client][X] = -1;

		SodiumTubHealth[Client][X] = 0;

		SodiumTubGrams[Client][X] = 0.0;
	}
}

public int GetSodiumTubIdFromEnt(int Ent)
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
				if(SodiumTubEnt[i][X] == Ent)
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

public int HasClientSodiumTub(int Client, int Id)
{

	//Is Valid:
	if(SodiumTubEnt[Client][Id] > 0)
	{

		//Return:
		return SodiumTubEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetSodiumTubHealth(int Client, int Id)
{

	//Return:
	return SodiumTubHealth[Client][Id];
}

public void SetSodiumTubHealth(int Client, int Id, int Amount)
{

	//Initulize:
	SodiumTubHealth[Client][Id] = Amount;
}

public float GetSodiumTubGrams(int Client, int Id)
{

	//Return:
	return SodiumTubGrams[Client][Id];
}

public void SetSodiumTubGrams(int Client, int Id, float Amount)
{

	//Initulize:
	SodiumTubGrams[Client][Id] = Amount;
}

public void initSodiumTubTime()
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
				if(IsValidEdict(SodiumTubEnt[i][X]))
				{

					//Check:
					if(SodiumTubHealth[i][X] <= 0 || SodiumTubGrams[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 16, X);

						//Remove:
						RemoveSodiumTub(i, X);
					}
				}
			}
		}
	}
}

public void SodiumTubHud(Client, Ent)
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
				if(SodiumTubEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nSodium: %0.2fg\nHealth: %i", SodiumTubGrams[i][X], SodiumTubHealth[i][X]);

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

public void RemoveSodiumTub(int Client, int X)
{

	//Initulize:
	SodiumTubHealth[Client][X] = 0;

	SodiumTubGrams[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(SodiumTubEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(SodiumTubEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(SodiumTubEnt[Client][X], "kill");

	//Inituze:
	SodiumTubEnt[Client][X] = -1;
}

public bool CreateSodiumTub(int Client, int Id, float fGrams, Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-SodiumTub|\x07FFFFFF - Unable to spawn SodiumTub due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", fGrams);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 16, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-SodiumTub|\x07FFFFFF - You have just spawned a SodiumTub!");
	}

	//Initulize:
	SodiumTubGrams[Client][Id] = fGrams;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	SodiumTubHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", SodiumTubModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	SodiumTubEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientSodiumTub);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Sodium_Tub");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (SodiumTubHealth[Client][Id] / 2), (SodiumTubHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestSodiumTub(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testSodiumTub <Id> <Grams> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sGrams[32];
	char sHealth[32];
	int Id = 0;
	int Health = 0;
	float fGrams = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sGrams, sizeof(sGrams));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	fGrams = StringToFloat(sGrams);

	Health = StringToInt(sHealth);

	if(SodiumTubEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money SodiumTub with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid SodiumTub %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create SodiumTub:
	CreateSodiumTub(Client, Id, fGrams, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsSodiumTubUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-SodiumTub|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-SodiumTub|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientSodiumTub(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float Grams = 100.0;

				//CreateSodiumTub
				if(CreateSodiumTub(Client, Y, Grams, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-SodiumTub|\x07FFFFFF - You already have too many SodiumTub, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientSodiumTub(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(SodiumTubEnt[i][X] == Ent)
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
							if(SodiumTubHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								SodiumTubHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								SodiumTubHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (SodiumTubHealth[i][X] / 2), (SodiumTubHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientSodiumTub(SodiumTubEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientSodiumTub(SodiumTubEnt[i][X], Damage, Ent2);
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

public Action DamageClientSodiumTub(int Ent, float &Damage, int &Attacker)
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
				if(SodiumTubEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) SodiumTubHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (SodiumTubHealth[i][X] / 2), (SodiumTubHealth[i][X] / 2), 255);

					//Check:
					if(SodiumTubHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 16, X);

						//Remove:
						RemoveSodiumTub(i, X);
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

public bool IsSodiumTubInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(SodiumTubEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, SodiumTubEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}