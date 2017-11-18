//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_shield_included_
  #endinput
#endif
#define _rp_shield_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Shield:
int ShieldTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int ShieldEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int ShieldHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char ShieldModel[256] = "models/Combine_Helicopter/helicopter_bomb01.mdl";

public void initShield()
{

	//Commands:
	RegAdminCmd("sm_testshield", Command_TestShield, ADMFLAG_ROOT, "<Id> <Time> - Creates a Shield");
}

public void initDefaultShield(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		ShieldEnt[Client][X] = -1;

		ShieldHealth[Client][X] = 0;

		ShieldTime[Client][X] = 0;
	}
}

public int HasClientShield(int Client, int Id)
{

	//Is Valid:
	if(ShieldEnt[Client][Id] > 0)
	{

		//Return:
		return ShieldEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetShieldTime(int Client, int Id)
{

	//Return:
	return ShieldTime[Client][Id];
}

public int GetShieldValue(int Client, int Id)
{

	//Return:
	return ShieldHealth[Client][Id];
}

public void OnShieldUse(int Client, int Ent)
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
						if(ShieldEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 10, X);

								//Remove:
								RemoveShield(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Shield|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Shield!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 500));

								//Set Menu State:
								BankState(Client, 500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You have just destroyed a Shield. reseaved â‚¬\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else
							{
								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You cannot use a Shield");
	
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
			CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Shield!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public void initShieldTime()
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
				if(IsValidEdict(ShieldEnt[i][X]))
				{

					//Declare:
					float EntOrigin[3];

					//Initialize:
					GetEntPropVector(ShieldEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Check:
					if(ShieldTime[i][X] > 0)
					{

						//Initulize:
						ShieldTime[i][X] -= 1;

					}

					//Remove Check:
					if(ShieldTime[i][X] == 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 10, X);

						//Remove:
						RemoveShield(i, X);
					}

					//Show CrimeHud:
					ShowItemToAll(EntOrigin);
				}
			}
		}
	}
}

public void ShieldHud(int Client, int Ent)
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
				if(ShieldEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Shield:\nEnds in %i Sec\nHealth: %i", ShieldTime[i][X], ShieldHealth[i][X]);

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

public void RemoveShield(int Client, int X)
{

	//Initulize:
	ShieldTime[Client][X] = 0;

	ShieldHealth[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(ShieldEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(ShieldEnt[Client][X]);
	}

	//Accept:
	EntityDissolve(ShieldEnt[Client][X], 3);

	//Inituze:
	ShieldEnt[Client][X] = -1;
}

public bool CreateShield(int Client, int Id, int Time, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - Unable to spawn Shield due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 10, Id, Time, 0, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You have just spawned a Shield!");
	}

	//Initulize:
	ShieldTime[Client][Id] = Time;

	ShieldHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", ShieldModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	ShieldEnt[Client][Id] = Ent;

	//Initulize Effects:
	int Effect = CreatePointTesla(Ent, "null", "120 120 255");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientShield);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Shield");

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestShield(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testshield <Id> <Time> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sTime[32];
	char sHealth[32];
	int Id = 0;
	int Time = 0;
	int Health = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sTime, sizeof(sTime));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Time = StringToInt(sTime);

	Health = StringToInt(sTime);

	if(ShieldEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Shield with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Shield %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Shield:
	CreateShield(Client, Id, Time, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsShieldUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientShield(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateShield
				if(CreateShield(Client, Y, 1800, StringToInt(GetItemVar(ItemId)), Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You already have too many Shield Plants, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

public Action OnClientShieldDamage(int Client, float Damage)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(ShieldEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, ShieldEnt[Client][X]))
			{

				//Initulize:
				if(Damage > 0.0) ShieldHealth[Client][X] -= RoundFloat(Damage);

				//Declare:
				int TempEnt = GetEntAttatchedEffect(ShieldEnt[Client][X], 0);

				//Check & Is Alive::
				if(IsValidEdict(TempEnt))
				{

					//Accept:
					AcceptEntityInput(TempEnt, "TurnOn");

					AcceptEntityInput(TempEnt, "DoSpark");
				}

				//Check:
				if(ShieldHealth[Client][X] < 1)
				{

					//Remove From DB:
					RemoveSpawnedItem(Client, 10, X);

					//Remove:
					RemoveShield(Client, X);
				}

				//stop:
				break;
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientShield(int Ent, int &Client, int &inflictor, float &Damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(ShieldEnt[Client][X] == Ent)
			{

				//Initulize:
				if(Damage > 0.0) ShieldHealth[Client][X] -= RoundFloat(Damage);

				//Declare:
				int TempEnt = GetEntAttatchedEffect(ShieldEnt[Client][X], 0);

				//Check & Is Alive::
				if(IsValidEdict(TempEnt))
				{

					//Accept:
					AcceptEntityInput(TempEnt, "TurnOn");

					AcceptEntityInput(TempEnt, "DoSpark");
				}

				//Check:
				if(ShieldHealth[Client][X] < 1)
				{

					//Remove From DB:
					RemoveSpawnedItem(Client, 10, X);

					//Remove:
					RemoveShield(Client, X);
				}

				//stop:
				break;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool IsShieldInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(ShieldEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, ShieldEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}