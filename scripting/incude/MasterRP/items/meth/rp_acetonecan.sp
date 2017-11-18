//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_acetonecan_included_
  #endinput
#endif
#define _rp_acetonecan_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//AcetoneCan:
int AcetoneCanEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int AcetoneCanHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float AcetoneCanGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char AcetoneCanModel[256] = "models/winningrook/gtav/meth/acetone/acetone.mdl";

public void initAcetoneCan()
{

	//Commands:
	RegAdminCmd("sm_testacetonecan", Command_TestAcetoneCan, ADMFLAG_ROOT, "<Id> <Time> - Creates a HcAcidTub");
}

public void initDefaultAcetoneCan(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		AcetoneCanEnt[Client][X] = -1;

		AcetoneCanHealth[Client][X] = 0;

		AcetoneCanGrams[Client][X] = 0.0;
	}
}

public int GetAcetoneCanIdFromEnt(int Ent)
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
				if(AcetoneCanEnt[i][X] == Ent)
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

public int HasClientAcetoneCan(int Client, int Id)
{

	//Is Valid:
	if(AcetoneCanEnt[Client][Id] > 0)
	{

		//Return:
		return AcetoneCanEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetAcetoneCanHealth(int Client, int Id)
{

	//Return:
	return AcetoneCanHealth[Client][Id];
}

public void SetAcetoneCanHealth(int Client, int Id, int Amount)
{

	//Initulize:
	AcetoneCanHealth[Client][Id] = Amount;
}

public float GetAcetoneCanGrams(int Client, int Id)
{

	//Return:
	return AcetoneCanGrams[Client][Id];
}

public void SetAcetoneCanGrams(int Client, int Id, float Amount)
{

	//Initulize:
	AcetoneCanGrams[Client][Id] = Amount;
}

public void initAcetoneCanTime()
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
				if(IsValidEdict(AcetoneCanEnt[i][X]))
				{

					//Check:
					if(AcetoneCanHealth[i][X] <= 0 || AcetoneCanGrams[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 18, X);

						//Remove:
						RemoveAcetoneCan(i, X);
					}
				}
			}
		}
	}
}

public void AcetoneCanHud(int Client, int Ent)
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
				if(AcetoneCanEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nAcetone: %0.2fg\nHealth: %i", AcetoneCanGrams[i][X], AcetoneCanHealth[i][X]);

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

public void RemoveAcetoneCan(int Client, int X)
{

	//Initulize:
	AcetoneCanHealth[Client][X] = 0;

	AcetoneCanGrams[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(AcetoneCanEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(AcetoneCanEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(AcetoneCanEnt[Client][X], "kill");

	//Inituze:
	AcetoneCanEnt[Client][X] = -1;
}

public bool CreateAcetoneCan(int Client, int Id, float fGrams, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - Unable to spawn Acetone Can due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", fGrams);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 18, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - You have just spawned a Acetone Can!");
	}

	//Initulize:
	AcetoneCanGrams[Client][Id] = fGrams;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	AcetoneCanHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", AcetoneCanModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	AcetoneCanEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientAcetoneCan);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Acetone_Can");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (AcetoneCanHealth[Client][Id] / 2), (AcetoneCanHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestAcetoneCan(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testacetonecan <Id> <Grams> <Health>");

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

	if(AcetoneCanEnt[Client][Id] > 0)
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

	//Create AcetoneCan:
	CreateAcetoneCan(Client, Id, fGrams, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsAcetoneCanUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientAcetoneCan(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float fGrams = 50.0;

				//CreateAcetoneCan
				if(CreateAcetoneCan(Client, Y, fGrams, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - You already have too many Acetone Can, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientAcetoneCan(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(AcetoneCanEnt[i][X] == Ent)
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
							if(AcetoneCanHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								AcetoneCanHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								AcetoneCanHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (AcetoneCanHealth[i][X] / 2), (AcetoneCanHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientAcetoneCan(AcetoneCanEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientAcetoneCan(AcetoneCanEnt[i][X], Damage, Ent2);
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

public Action DamageClientAcetoneCan(int Ent, float &Damage, int &Attacker)
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
				if(AcetoneCanEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) AcetoneCanHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (AcetoneCanHealth[i][X] / 2), (AcetoneCanHealth[i][X] / 2), 255);

					//Check:
					if(AcetoneCanHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 18, X);

						//Remove:
						RemoveAcetoneCan(i, X);
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

public bool IsAcetoneCanInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(AcetoneCanEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, AcetoneCanEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}