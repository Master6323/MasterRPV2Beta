//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_ammonia_included_
  #endinput
#endif
#define _rp_ammonia_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Ammonia:
int AmmoniaEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int AmmoniaHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float AmmoniaGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char AmmoniaModel[256] = "models/winningrook/gtav/meth/ammonia/ammonia.mdl";

public void initAmmonia()
{

	//Commands:
	RegAdminCmd("sm_testammonia", Command_TestAmmonia, ADMFLAG_ROOT, "<Id> <Time> - Creates a Ammonia");
}

public void initDefaultAmmonia(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		AmmoniaEnt[Client][X] = -1;

		AmmoniaHealth[Client][X] = 0;

		AmmoniaGrams[Client][X] = 0.0;
	}
}

public int GetAmmoniaIdFromEnt(int Ent)
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
				if(AmmoniaEnt[i][X] == Ent)
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

public int HasClientAmmonia(int Client, int Id)
{

	//Is Valid:
	if(AmmoniaEnt[Client][Id] > 0)
	{

		//Return:
		return AmmoniaEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetAmmoniaHealth(int Client, int Id)
{

	//Return:
	return AmmoniaHealth[Client][Id];
}

public void SetAmmoniaHealth(int Client, int Id, int Amount)
{

	//Initulize:
	AmmoniaHealth[Client][Id] = Amount;
}

public float GetAmmoniaGrams(int Client, int Id)
{

	//Return:
	return AmmoniaGrams[Client][Id];
}

public void SetAmmoniaGrams(int Client, int Id, float Amount)
{

	//Initulize:
	AmmoniaGrams[Client][Id] = Amount;
}

public void initAmmoniaTime()
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
				if(IsValidEdict(AmmoniaEnt[i][X]))
				{

					//Check:
					if(AmmoniaHealth[i][X] <= 0 || AmmoniaGrams[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 24, X);

						//Remove:
						RemoveAmmonia(i, X);
					}
				}
			}
		}
	}
}

public void AmmoniaHud(int Client, int Ent)
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
				if(AmmoniaEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nAmmonia: %0.2fg\nHealth: %i", AmmoniaGrams[i][X], AmmoniaHealth[i][X]);

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

public void RemoveAmmonia(int Client, int X)
{

	//Initulize:
	AmmoniaHealth[Client][X] = 0;

	AmmoniaGrams[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(AmmoniaEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(AmmoniaEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(AmmoniaEnt[Client][X], "kill");

	//Inituze:
	AmmoniaEnt[Client][X] = -1;
}

public bool CreateAmmonia(int Client,int Id, float fGrams, Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Ammonia|\x07FFFFFF - Unable to spawn Ammonia due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", fGrams);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 24, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Ammonia|\x07FFFFFF - You have just spawned a Ammonia!");
	}

	//Initulize:
	AmmoniaGrams[Client][Id] = fGrams;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	AmmoniaHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", AmmoniaModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	AmmoniaEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientAmmonia);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Ammonia");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (AmmoniaHealth[Client][Id] / 2), (AmmoniaHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestAmmonia(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testAmmonia <Id> <Grams> <Health>");

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

	if(AmmoniaEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Ammonia with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Ammonia %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Ammonia:
	CreateAmmonia(Client, Id, fGrams, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action OnItemsAmmoniaUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Ammonia|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Ammonia|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientAmmonia(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float fGrams = 100.0;

				//CreateAmmonia
				if(CreateAmmonia(Client, Y, fGrams, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Ammonia|\x07FFFFFF - You already have too many Ammonia, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientAmmonia(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(AmmoniaEnt[i][X] == Ent)
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
							if(AmmoniaHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								AmmoniaHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								AmmoniaHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (AmmoniaHealth[i][X] / 2), (AmmoniaHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientAmmonia(AmmoniaEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientAmmonia(AmmoniaEnt[i][X], Damage, Ent2);
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

public Action DamageClientAmmonia(int Ent, float &Damage, int &Attacker)
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
				if(AmmoniaEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) AmmoniaHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (AmmoniaHealth[i][X] / 2), (AmmoniaHealth[i][X] / 2), 255);

					//Check:
					if(AmmoniaHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 24, X);

						//Remove:
						RemoveAmmonia(i, X);
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

public bool IsAmmoniaInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(AmmoniaEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, AmmoniaEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}