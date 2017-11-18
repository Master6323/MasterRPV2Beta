//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_erythroxylum_included_
  #endinput
#endif
#define _rp_erythroxylum_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Erythroxylum:
int ErythroxylumEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int ErythroxylumHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float ErythroxylumFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char ErythroxylumModel[256] = "models/props_junk/glassjug01.mdl";

public void initErythroxylum()
{

	//Commands:
	RegAdminCmd("sm_testerythroxylum", Command_TestErythroxylum, ADMFLAG_ROOT, "<Id> <Time> - Creates a Erythroxylum");
}

public void initDefaultErythroxylum(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		ErythroxylumEnt[Client][X] = -1;

		ErythroxylumHealth[Client][X] = 0;

		ErythroxylumFuel[Client][X] = 0.0;
	}
}

public int GetErythroxylumIdFromEnt(int Ent)
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
				if(ErythroxylumEnt[i][X] == Ent)
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

public int HasClientErythroxylum(int Client, int Id)
{

	//Is Valid:
	if(ErythroxylumEnt[Client][Id] > 0)
	{

		//Return:
		return ErythroxylumEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetErythroxylumHealth(int Client, int Id)
{

	//Return:
	return ErythroxylumHealth[Client][Id];
}

public voidSetErythroxylumHealth(int Client, int Id, int Amount)
{

	//Initulize:
	ErythroxylumHealth[Client][Id] = Amount;
}

public float GetErythroxylumFuel(int Client, int Id)
{

	//Return:
	return ErythroxylumFuel[Client][Id];
}

public void SetErythroxylumFuel(int Client, int Id, float Amount)
{

	//Initulize:
	ErythroxylumFuel[Client][Id] = Amount;
}

public void initErythroxylumTime()
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
				if(IsValidEdict(ErythroxylumEnt[i][X]))
				{

					//Check:
					if(ErythroxylumHealth[i][X] <= 0 || ErythroxylumFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 21, X);

						//Remove:
						RemoveErythroxylum(i, X);
					}
				}
			}
		}
	}
}

public void ErythroxylumHud(int Client, int Ent)
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
				if(ErythroxylumEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Bottle:\nErythroxylum Solution: %0.2fmL\nHealth: %i", ErythroxylumFuel[i][X], ErythroxylumHealth[i][X]);

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

public void RemoveErythroxylum(int Client, int X)
{

	//Initulize:
	ErythroxylumHealth[Client][X] = 0;

	ErythroxylumFuel[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(ErythroxylumEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(ErythroxylumEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(ErythroxylumEnt[Client][X], "kill");

	//Inituze:
	ErythroxylumEnt[Client][X] = -1;
}

public bool CreateErythroxylum(int Client, int Id, float Fuel, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - Unable to spawn Erythroxylum due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 21, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - You have just spawned a Erythroxylum!");
	}

	//Initulize:
	ErythroxylumFuel[Client][Id] = Fuel;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	ErythroxylumHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", ErythroxylumModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	ErythroxylumEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientErythroxylum);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Erythroxylum");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (ErythroxylumHealth[Client][Id] / 2), (ErythroxylumHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestErythroxylum(int Client,int  Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testerythroxylum <Id> <Fuel> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sFuel[32];
	char sHealth[32];
	int Id = 0;
	float Fuel = 0.0;
	int Health = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sFuel, sizeof(sFuel));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Fuel = StringToFloat(sFuel);

	Health = StringToInt(sHealth);

	if(ErythroxylumEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Erythroxylum with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Erythroxylum %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Erythroxylum:
	CreateErythroxylum(Client, Id, Fuel, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsErythroxylumUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientErythroxylum(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float Fuel = 1500.0;

				//CreateErythroxylum
				if(CreateErythroxylum(Client, Y, Fuel, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - You already have too many Erythroxylum, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientErythroxylum(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(ErythroxylumEnt[i][X] == Ent)
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
							if(ErythroxylumHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								ErythroxylumHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								ErythroxylumHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (ErythroxylumHealth[i][X] / 2), (ErythroxylumHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientErythroxylum(ErythroxylumEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientErythroxylum(ErythroxylumEnt[i][X], Damage, Ent2);
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

public Action DamageClientErythroxylum(int Ent, float &Damage, int &Attacker)
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
				if(ErythroxylumEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) ErythroxylumHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (ErythroxylumHealth[i][X] / 2), (ErythroxylumHealth[i][X] / 2), 255);

					//Check:
					if(ErythroxylumHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 21, X);

						//Remove:
						RemoveErythroxylum(i, X);
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

public bool IsErythroxylumInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(ErythroxylumEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, ErythroxylumEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}