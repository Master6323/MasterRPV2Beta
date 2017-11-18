//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_pills_included_
  #endinput
#endif
#define _rp_pills_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Pills:
int PillsEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float PillGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PillsHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char PillsModel[256] = "models/srcocainelab/portablestove.mdl";

public void initPills()
{

	//Commands:
	RegAdminCmd("sm_testpills", Command_TestPills, ADMFLAG_ROOT, "<Id> <Time> - Creates a Pills");
}

public void initDefaultPills(int Client)
{
	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PillsEnt[Client][X] = -1;

		PillsHealth[Client][X] = -1;

		PillGrams[Client][X] = 0.0;
	}
}

public int HasClientPills(int Client, int Id)
{

	//Is Valid:
	if(PillsEnt[Client][Id] > 0)
	{

		//Return:
		return PillsEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetPillsHealth(int Client, int Id)
{

	//Return:
	return PillsHealth[Client][Id];
}

public float GetPillsGrams(int Client, int Id)
{

	//Return:
	return PillGrams[Client][Id];
}

public void OnPillsUse(int Client, int Ent)
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
						if(PillsEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 3, X);

								//Remove:
								RemovePills(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Pills|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Kitchen!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have just destroyed a Kitchen. reseaved €\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(PillGrams[i][X] > 0.0)
							{
	
								//Declare:
								float Earns = PillGrams[i][X];

								//Initulize:
								SetPills(Client, RoundFloat(float(GetPills(Client)) + Earns));

								PillGrams[i][X] = 0.0;
	
								//Is Client Own:
								if(Client == i)
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have collected €\x0732CD32%0.2f\x07FFFFFF from your Kitchen!", Earns);
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Pills|\x07FFFFFF - %N has stolen from your Kitchen!", Client);

									CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have Stolen €\x0732CD32%0.2f\x07FFFFFF from this Kitchen!", Earns);
								}	
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Kitchen Hasn't cooked up any Pills yet!");
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
			CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Kitchen!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public void initPillsTime()
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
				if(IsValidEdict(PillsEnt[i][X]))
				{

					//Declare:
					float EntOrigin[3];

					//Initialize:
					GetEntPropVector(PillsEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Valid:
					if((StrContains(GetJob(i), "Pills Technician", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i)))
					{

						//Check:
						CheckPillsItemsToPillsKitchen(i, X, EntOrigin);
					}

					//Show CrimeHud:
					ShowIllegalItemToCops(EntOrigin);
				}
			}
		}
	}
}

public void PillsHud(Client, Ent)
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
				if(PillsEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Pills:\nGrams (%0.2fg)\nHealth: %i", PillGrams[i][X], PillsHealth[i][X]);

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

public void RemovePills(int Client, int X)
{

	//Initulize:
	PillGrams[Client][X] = 0.0;

	PillsHealth[Client][X] = 0;

	//Accept:
	AcceptEntityInput(PillsEnt[Client][X], "kill");

	//Inituze:
	PillsEnt[Client][X] = -1;
}

public bool CreatePills(int Client, int Id, float Value, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Unable to spawn Kitchen due to outside of world");

			//Return:
			return false;
		}

		//Declare
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Value);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 3, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have just spawned a Pills Kitchen!");
	}

	//Initulize:
	PillsHealth[Client][Id] = Health;

	PillGrams[Client][Id] = Value;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", PillsModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);

	//Initulize:
	PillsEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPills);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Kitchen_Pills");

	//Is Valid:
	if(StrContains(GetJob(Client), "Pills Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action Command_TestPills(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpills <Id> <grams>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sPillGrams[32];
	int Id = 0;
	float fGrams = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sPillGrams, sizeof(sPillGrams));

	Id = StringToInt(sId);

	fGrams = StringToFloat(sPillGrams);

	if(PillsEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Pills with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Pills %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//CreatePills
	CreatePills(Client, Id, fGrams, 500, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action OnItemsPillsUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Cops can't use any illegal items.");
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

		//Add Extra Slots:
		MaxSlots += GetItemAmount(Client, 301);

		//Check:
		if(MaxSlots > GetItemAmount(Client, 301))
		{

			//Initulize:
			MaxSlots = MAXITEMSPAWN;
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
			Ent = HasClientPills(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Pills:
				if(CreatePills(Client, Y, 0.0, 500, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + StringToInt(GetItemVar(ItemId))));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You already have too many Pills Kitchens, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Check to see if the Required Items is in distance
public void CheckPillsItemsToPillsKitchen(int Client, int Y, float EntOrigin[3])
{

	//Declare:
	int Propane = CheckPropaneTankDistanceToPillsLab(Client, Y);

	int Ammonia = CheckAmmoniaDistanceToPillsLab(Client, Y);

	int SAcidTub = CheckSAcidTubDistanceToPillsLab(Client, Y);

	int Toulene = CheckTouleneDistanceToPillsLab(Client, Y);

	//Check:
	if(Propane > 0 && Ammonia > 0 && SAcidTub > 0 && Toulene > 0)
	{

		//Declare:
		int Id = GetPropaneTankIdFromEnt(Propane);

		float UsedFuel = GetRandomFloat(0.5, 0.4);

		SetPropaneTankFuel(Client, Id, (GetPropaneTankFuel(Client, Id) - UsedFuel));

		//Declare:
		Id = GetAmmoniaIdFromEnt(Ammonia);

		float UsedGrams = GetRandomFloat(0.5, 0.4);

		SetAmmoniaGrams(Client, Id, (GetAmmoniaGrams(Client, Id) - UsedGrams));

		//Declare:
		Id = GetSAcidTubIdFromEnt(SAcidTub);

		UsedFuel = GetRandomFloat(0.01, 0.009);

		SetSAcidTubFuel(Client, Id, (GetSAcidTubFuel(Client, Id) - UsedFuel));

		//Declare:
		Id = GetTouleneIdFromEnt(Toulene);

		UsedFuel = GetRandomFloat(0.1, 0.05);

		SetTouleneFuel(Client, Id, (GetTouleneFuel(Client, Id) - UsedFuel));

		//Declare:
		int Random = GetRandomInt(1, 3);

		//Valid:
		if(Random == 1)
		{

			//Initulize:
			float AddGrams = GetRandomFloat(2.0, 4.0);

			//Initulize:
			PillGrams[Client][Y] += AddGrams;
		}

		//EntCheck:
		if(CheckMapEntityCount() < 2000)
		{

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, Smoke(), 3.0, 30);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, Smoke(), 3.0, 30);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, SmokeNew(), 2.0, 30);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, SmokeNew(), 2.0, 30);

			//Send:
			TE_SendToAll();
		}
	}
}



//Check to see if the Propane Tank is in distance
public int CheckPropaneTankDistanceToPillsLab(int Client, int Y)
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

			//Prop Propane Tank:
			if(StrEqual(ClassName, "prop_Propane_Tank"))
			{

				//Check:
				if(IsInDistance(PillsEnt[Client][Y], X))
				{

					//Return:
					return X;
				}
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the generator is in distance
public int CheckAmmoniaDistanceToPillsLab(int Client, int Y)
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

			//Prop Ammonia:
			if(StrEqual(ClassName, "prop_Ammonia"))
			{

				//Check:
				if(IsInDistance(PillsEnt[Client][Y], X))
				{

					//Return:
					return X;
				}
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the Acetone Can is in distance
public int CheckSAcidTubDistanceToPillsLab(int Client, int Y)
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

			//Prop Ammonia:
			if(StrEqual(ClassName, "prop_SAcid_Tub"))
			{

				//Check:
				if(IsInDistance(PillsEnt[Client][Y], X))
				{

					//Return:
					return X;
				}
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the HcAcid Tub is in distance
public int CheckTouleneDistanceToPillsLab(int Client, int Y)
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

			//Prop Ammonia:
			if(StrEqual(ClassName, "prop_Toulene"))
			{

				//Check:
				if(IsInDistance(PillsEnt[Client][Y], X))
				{

					//Return:
					return X;
				}
			}
		}
	}

	//Return:
	return -1;
}

//Event Damage:
public Action OnDamageClientPills(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PillsEnt[i][X] == Ent)
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
							if(PillsHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PillsHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PillsHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PillsHealth[i][X] / 2), (PillsHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPills(PillsEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPills(PillsEnt[i][X], Damage, Ent2);
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

public Action DamageClientPills(int Ent, float &Damage, int &Attacker)
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
				if(PillsEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PillsHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PillsHealth[i][X] / 2), (PillsHealth[i][X] / 2), 255);

					//Check:
					if(PillsHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 3, X);

						//Remove:
						RemovePills(i, X);
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

public bool IsPillsInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(PillsEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, PillsEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}