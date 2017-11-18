//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hcacidtub_included_
  #endinput
#endif
#define _rp_hcacidtub_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//HcAcidTub:
int HcAcidTubEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int HcAcidTubHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float HcAcidTubFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char HcAcidTubModel[256] = "models/winningrook/gtav/meth/hcacid/hcacid.mdl";

public void initHcAcidTub()
{

	//Commands:
	RegAdminCmd("sm_testhcacidtub", Command_TestHcAcidTub, ADMFLAG_ROOT, "<Id> <Time> - Creates a HcAcidTub");
}

public void  initDefaultHcAcidTub(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		HcAcidTubEnt[Client][X] = -1;

		HcAcidTubHealth[Client][X] = 0;

		HcAcidTubFuel[Client][X] = 0.0;
	}
}

public int GetHcAcidTubIdFromEnt(int Ent)
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
				if(HcAcidTubEnt[i][X] == Ent)
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

public int HasClientHcAcidTub(int Client, int Id)
{

	//Is Valid:
	if(HcAcidTubEnt[Client][Id] > 0)
	{

		//Return:
		return HcAcidTubEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetHcAcidTubHealth(int Client, int Id)
{

	//Return:
	return HcAcidTubHealth[Client][Id];
}

public void SetHcAcidTubHealth(int Client, int Id, int Amount)
{

	//Initulize:
	HcAcidTubHealth[Client][Id] = Amount;
}

public float GetHcAcidTubFuel(int Client, int Id)
{

	//Return:
	return HcAcidTubFuel[Client][Id];
}

public void SetHcAcidTubFuel(int Client, int Id, float Amount)
{

	//Initulize:
	HcAcidTubFuel[Client][Id] = Amount;
}

public void initHcAcidTubTime()
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
				if(IsValidEdict(HcAcidTubEnt[i][X]))
				{

					//Check:
					if(HcAcidTubHealth[i][X] <= 0 || HcAcidTubFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 17, X);

						//Remove:
						RemoveHcAcidTub(i, X);
					}
				}
			}
		}
	}
}

public void HcAcidTubHud(int Client, int Ent)
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
				if(HcAcidTubEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nBismoth Acid: %0.2fmL\nHealth: %i", HcAcidTubFuel[i][X], HcAcidTubHealth[i][X]);

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

public void RemoveHcAcidTub(int Client,int  X)
{

	//Initulize:
	HcAcidTubHealth[Client][X] = 0;

	HcAcidTubFuel[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(HcAcidTubEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(HcAcidTubEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(HcAcidTubEnt[Client][X], "kill");

	//Inituze:
	HcAcidTubEnt[Client][X] = -1;
}

public bool CreateHcAcidTub(int Client, int Id, float Fuel, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - Unable to spawn HcAcidTub due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 17, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - You have just spawned a HcAcidTub!");
	}

	//Initulize:
	HcAcidTubFuel[Client][Id] = Fuel;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	HcAcidTubHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", HcAcidTubModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	HcAcidTubEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientHcAcidTub);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_HcAcid_Tub");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (HcAcidTubHealth[Client][Id] / 2), (HcAcidTubHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestHcAcidTub(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testHcAcidTub <Id> <Fuel> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sFuel[32];
	char sHealth[32];
	int Id = 0;
	int Health = 0;
	float Fuel = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sFuel, sizeof(sFuel));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Fuel = StringToFloat(sFuel);

	Health = StringToInt(sHealth);

	if(HcAcidTubEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money HcAcidTub with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid HcAcidTub %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create HcAcidTub:
	CreateHcAcidTub(Client, Id, Fuel, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsHcAcidTubUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientHcAcidTub(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float Fuel = 1500.0;

				//CreateHcAcidTub
				if(CreateHcAcidTub(Client, Y, Fuel, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - You already have too many HcAcidTub, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientHcAcidTub(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(HcAcidTubEnt[i][X] == Ent)
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
							if(HcAcidTubHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								HcAcidTubHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								HcAcidTubHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (HcAcidTubHealth[i][X] / 2), (HcAcidTubHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientHcAcidTub(HcAcidTubEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientHcAcidTub(HcAcidTubEnt[i][X], Damage, Ent2);
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

public Action DamageClientHcAcidTub(int Ent, float &Damage, int &Attacker)
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
				if(HcAcidTubEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) HcAcidTubHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (HcAcidTubHealth[i][X] / 2), (HcAcidTubHealth[i][X] / 2), 255);

					//Check:
					if(HcAcidTubHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 17, X);

						//Remove:
						RemoveHcAcidTub(i, X);
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

public bool IsHcAcidTubInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(HcAcidTubEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, HcAcidTubEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}