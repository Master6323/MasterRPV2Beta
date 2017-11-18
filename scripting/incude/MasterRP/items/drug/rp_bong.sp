//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bong_included_
  #endinput
#endif
#define _rp_bong_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Bong:
int BongEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int BongHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char BongModel[256] = "models/striker/nicebongstriker.mdl";

public void initBong()
{

	//Commands:
	RegAdminCmd("sm_testbong", Command_TestBong, ADMFLAG_ROOT, "<Id> - Creates a Bong");
}

public void initDefaultBong(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BongEnt[Client][X] = -1;

		BongHealth[Client][X] = 0;
	}
}

public int GetBongIdFromEnt(int Ent)
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
				if(BongEnt[i][X] == Ent)
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

public int HasClientBong(int Client, int Id)
{

	//Is Valid:
	if(BongEnt[Client][Id] > 0)
	{

		//Return:
		return BongEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetBongHealth(int Client, int Id)
{

	//Return:
	return BongHealth[Client][Id];
}

public void SetBongHealth(int Client, int Id, int Amount)
{

	//Initulize:
	BongHealth[Client][Id] = Amount;
}

public void OnBongUse(int Client, int Ent)
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
						if(BongEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 27, X);

								//Remove:
								RemoveBong(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Bong|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Bong!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 500));

								//Set Menu State:
								BankState(Client, 500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You have just destroyed a Bong. reseaved â‚¬\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(GetHarvest(Client) > 10)
							{

								//Check:
								if(GetDrugTick(Client) == -1 && GetDrugHealth(Client) == 0)
								{

									//Initulize:
									SetCrime(Client, (GetCrime(Client) + 200));

									//Command:
									CheatCommand(Client, "r_screenoverlay", "debug/yuv.vmt");

									//Set Speed:
									SetEntitySpeed(Client, 1.2);

									//Declare:
									int ClientHealth = GetClientHealth(Client);

									//Set Health:
									SetEntityHealth(Client, ClientHealth + 50);

									//Initulize:
									SetDrugHealth(Client, 50);

									//Initulize:
									SetDrugTick(Client, 90);

									//Shake:
									ShakeClient(Client, 300.0, (10.0));

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You have just smoked \x0732CD3210g\x07FFFFFF worth of drugs!");
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You are already on drugs!");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You dont have any drugs to smoke!");
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
			CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Bong!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public void initBongTime()
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
				if(IsValidEdict(BongEnt[i][X]))
				{

					//Check:
					if(BongHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 27, X);

						//Remove:
						RemoveBong(i, X);
					}
				}
			}
		}
	}
}

public void BongHud(int Client, int Ent)
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
				if(BongEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Bong:\nHealth: %i", BongHealth[i][X]);

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

public void RemoveBong(int Client, int X)
{

	//Initulize:
	BongHealth[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(BongEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(BongEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(BongEnt[Client][X], "kill");

	//Inituze:
	BongEnt[Client][X] = -1;
}

public bool CreateBong(int Client, int Id, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - Unable to spawn Bong due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 27, Id, 0, 0, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You have just spawned a Bong!");
	}

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	BongHealth[Client][Id] = Health;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BongModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BongEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientBong);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Drug_Bong");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (BongHealth[Client][Id] / 2), (BongHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestBong(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testBong <Id> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sHealth[32];
	int Id = 0;
	int Health = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Health = StringToInt(sHealth);

	if(BongEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Bong with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bong %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create Bong:
	CreateBong(Client, Id, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsBongUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientBong(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateBong
				if(CreateBong(Client, Y, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You already have too many Bong, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientBong(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(BongEnt[i][X] == Ent)
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
							if(BongHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								BongHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								BongHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (BongHealth[i][X] / 2), (BongHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientBong(BongEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientBong(BongEnt[i][X], Damage, Ent2);
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

public Action DamageClientBong(int Ent, float &Damage, int &Attacker)
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
				if(BongEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) BongHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (BongHealth[i][X] / 2), (BongHealth[i][X] / 2), 255);

					//Check:
					if(BongHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 27, X);

						//Remove:
						RemoveBong(i, X);
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

public bool IsBongInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(BongEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, BongEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}