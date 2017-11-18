//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_propanetank_included_
  #endinput
#endif
#define _rp_propanetank_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//PropaneTank:
int PropaneTankEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PropaneTankLevel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int PropaneTankHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float PropaneTankFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
bool PropaneTankIsRunning[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
//char PropaneTankModel[256] = "models/props_wasteland/laundry_washer003.mdl";

public void initPropaneTank()
{

	//Commands:
	RegAdminCmd("sm_testpropanetank", Command_TestPropaneTank, ADMFLAG_ROOT, "<Id> <Time> - Creates a PropaneTank");
}

public void initDefaultPropaneTank(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PropaneTankEnt[Client][X] = -1;

		PropaneTankHealth[Client][X] = 0;

		PropaneTankFuel[Client][X] = 0.0;

		PropaneTankIsRunning[Client][X] = false;

		PropaneTankLevel[Client][X] = 0;
	}
}

public int GetPropaneTankIdFromEnt(int Ent)
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
				if(PropaneTankEnt[i][X] == Ent)
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

public int HasClientPropaneTank(int Client, int Id)
{

	//Is Valid:
	if(PropaneTankEnt[Client][Id] > 0)
	{

		//Return:
		return PropaneTankEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetPropaneTankHealth(int Client,int  Id)
{

	//Return:
	return PropaneTankHealth[Client][Id];
}

public void SetPropaneTankHealth(int Client, int Id, int Amount)
{

	//Initulize:
	PropaneTankHealth[Client][Id] = Amount;
}

public float GetPropaneTankFuel(int Client, int Id)
{

	//Return:
	return PropaneTankFuel[Client][Id];
}

public void SetPropaneTankFuel(int Client, int Id, float Amount)
{

	//Initulize:
	PropaneTankFuel[Client][Id] = Amount;
}
public int GetPropaneTankLevel(int Client, int Id)
{

	//Return:
	return PropaneTankLevel[Client][Id];
}

public void OnPropaneTankUse(int Client, int Ent)
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
						if(PropaneTankEnt[i][X] == Ent)
						{

							//Check:
							if(PropaneTankIsRunning[i][X])
							{

								//Initulize:
								PropaneTankIsRunning[i][X] = false;
							}

							//Override:
							else
							{

								//Initulize:
								PropaneTankIsRunning[i][X] = true;
							}

							//Emit Sound:
							EmitSoundToClient(Client, "buttons/lightswitch2.wav");
						}
					}
				}
			}
		}

		//Override:
		else
		{

			//Print :
			CPrintToChat(Client, "\x07FF4040|RP-PropaneTank|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use PropaneTank!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public void initPropaneTankTime()
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
				if(IsValidEdict(PropaneTankEnt[i][X]))
				{

					//Check:
					if(PropaneTankHealth[i][X] > 0 && PropaneTankHealth[i][X] <= 100)
					{

						//Declare:
						float EntOrigin[3];

						//Initulize:
						GetEntPropVector(PropaneTankEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

						//CreateDamage:
						ExplosionDamage(i, PropaneTankEnt[i][X], EntOrigin, DMG_BURN);

						//Declare:
						int Random = GetRandomInt(1, 5);

						//Check:
						if(Random <= 2)
						{

							//Initulize:
							PropaneTankHealth[i][X] -= Random;
						}
					}

					//Check:
					if(PropaneTankHealth[i][X] <= 0 || PropaneTankFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 14, X);

						//Remove:
						RemovePropaneTank(i, X, true);
					}

					//Check:
					if(PropaneTankFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 14, X);

						//Remove:
						RemovePropaneTank(i, X, false);
					}
				}
			}
		}
	}
}

public void PropaneTankHud(int Client, int Ent)
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
				if(PropaneTankEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//PropaneTank Basic:
					if(PropaneTankLevel[i][X] == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "PropaneTank (Small):\nFuel: %0.2fL\nHealth: %i", PropaneTankFuel[i][X], PropaneTankHealth[i][X]);
					}

					//PropaneTank Advanced:
					if(PropaneTankLevel[i][X] == 2)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "PropaneTank (Big):\nFuel: %0.2fL\nHealth: %i", PropaneTankFuel[i][X], PropaneTankHealth[i][X]);
					}

					//PropaneTank Advanced:
					if(PropaneTankLevel[i][X] == 3)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "PropaneTank (Master):\nFuel: %0.2fL\nHealth: %i", PropaneTankFuel[i][X], PropaneTankHealth[i][X]);
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

public void RemovePropaneTank(int Client, int X, bool Result)
{

	//Initulize:
	PropaneTankHealth[Client][X] = 0;

	PropaneTankLevel[Client][X] = 0;

	PropaneTankFuel[Client][X] = 0.0;

	//EntCheck:
	if(CheckMapEntityCount() < 2047 && Result)
	{

		//Declare:
		float PropaneTankOrigin[3];

		//Get Prop Data:
		GetEntPropVector(PropaneTankEnt[Client][X], Prop_Send, "m_vecOrigin", PropaneTankOrigin);

		//Temp Ent:
		TE_SetupSparks(PropaneTankOrigin, NULL_VECTOR, 5, 5);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(PropaneTankOrigin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();
	}

	//Check:
	if(IsValidAttachedEffect(PropaneTankEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(PropaneTankEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(PropaneTankEnt[Client][X], "kill");

	//Inituze:
	PropaneTankEnt[Client][X] = -1;
}

public bool CreatePropaneTank(int Client, int Id, float Fuel, int Level, int Health, float Position[3], float Angle[3], bool IsConnected)
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

			//Print :
			CPrintToChat(Client, "\x07FF4040|RP-PropaneTank|\x07FFFFFF - Unable to spawn PropaneTank due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 14, Id, 0, Level, Health, AddedData, Position, Angle);

		//Print :
		CPrintToChat(Client, "\x07FF4040|RP-PropaneTank|\x07FFFFFF - You have just spawned a PropaneTank!");
	}

	//Initulize:
	PropaneTankFuel[Client][Id] = Fuel;

	PropaneTankLevel[Client][Id] = Level;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	PropaneTankHealth[Client][Id] = Health;

	PropaneTankIsRunning[Client][Id] = true;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	if(Level == 3)
		DispatchKeyValue(Ent, "model", "models/props_citizen_tech/firetrap_propanecanister01a.mdl");
	if(Level == 2)
		DispatchKeyValue(Ent, "model", "models/props_industrial/gascanister02.mdl");
	else
		DispatchKeyValue(Ent, "model", "models/props_industrial/gascanister01.mdl");

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	PropaneTankEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPropaneTank);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Propane_Tank");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (PropaneTankHealth[Client][Id] / 2), (PropaneTankHealth[Client][Id] / 2), 255);

	//Check:
	if(PropaneTankHealth[Client][Id] > 0 && PropaneTankHealth[Client][Id] <= 100)
	{

		//Initulize Effects:
		int Effect = CreateEnvFire(PropaneTankEnt[Client][Id], "null", "200", "700", "0", "Natural");

		SetEntAttatchedEffect(PropaneTankEnt[Client][Id], 1, Effect);
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestPropaneTank(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print :
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 4)
	{

		//Print :
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpropanetank <Id> <Fuel> <level> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sFuel[32];
	char sLevel[32];
	char sHealth[32];
	int Id = 0;
	int Level = 0;
	int Health = 0;
	float Fuel = 0.0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sFuel, sizeof(sFuel));

	//Initialize:
	GetCmdArg(3, sLevel, sizeof(sLevel));

	//Initialize:
	GetCmdArg(4, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Fuel = StringToFloat(sFuel);

	Level = StringToInt(sLevel);

	Health = StringToInt(sHealth);

	if(PropaneTankEnt[Client][Id] > 0)
	{

		//Print :
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money PropaneTank with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print :
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid PropaneTank %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//Create PropaneTank:
	CreatePropaneTank(Client, Id, Fuel, Level, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsPropaneTankUse(int Client, int  ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print :
		CPrintToChat(Client, "\x07FF4040|RP-PropaneTank|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print :
		CPrintToChat(Client, "\x07FF4040|RP-PropaneTank|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		int Var = StringToInt(GetItemVar(ItemId));

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
			Ent = HasClientPropaneTank(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				float Fuel;

				if(Var == 2) Fuel = 2500.0;
				else Fuel = 500.0;

				//CreatePropaneTank
				if(CreatePropaneTank(Client, Y, Fuel, Var, 500, Position, EyeAngles, false))
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

					//Print :
					CPrintToChat(Client, "\x07FF4040|RP-PropaneTank|\x07FFFFFF - You already have too many PropaneTank, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientPropaneTank(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PropaneTankEnt[i][X] == Ent)
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

						//Is Crowbar:
						if(StrContains(WeaponName, "weapon_crowbar", false) == 0)
						{

							//Initulize:
							if(PropaneTankHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PropaneTankHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PropaneTankHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PropaneTankHealth[i][X] / 2), (PropaneTankHealth[i][X] / 2), 255);

							//Check:
							if(PropaneTankHealth[i][X] > 100)
							{

								//Declare:
								int TempEnt = GetEntAttatchedEffect(PropaneTankEnt[i][X], 1);

								//Check:
								if(IsValidEdict(TempEnt))
								{

									//Kill:
									AcceptEntityInput(TempEnt, "kill");

									//Initulize:
									SetEntAttatchedEffect(TempEnt, 1, -1);
								}
							}
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPropaneTank(PropaneTankEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPropaneTank(PropaneTankEnt[i][X], Damage, Ent2);
					}
				}

				//Check:
				if(PropaneTankHealth[i][X] > 100)
				{

					//Declare:
					int TempEnt = GetEntAttatchedEffect(PropaneTankEnt[i][X], 1);

					//Check:
					if(IsValidEdict(TempEnt))
					{

						//Kill:
						AcceptEntityInput(TempEnt, "kill");

						//Initulize:
						SetEntAttatchedEffect(TempEnt, 1, -1);
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

public Action DamageClientPropaneTank(int Ent, float &Damage, int &Attacker)
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
				if(PropaneTankEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PropaneTankHealth[i][X] -= RoundFloat(Damage);

					//Check:
					if(PropaneTankHealth[i][X] > 0 && PropaneTankHealth[i][X] <= 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(PropaneTankEnt[i][X], 1);

						//Check:
						if(!IsValidEdict(TempEnt))
						{

							//Explode:
							CreateExplosion(Attacker, PropaneTankEnt[i][X]);

							//Check:
							if(PropaneTankEnt[i][X] > 0)
							{

								//Initulize Effects:
								int Effect = CreateEnvFire(PropaneTankEnt[i][X], "null", "200", "700", "0", "Natural");

								SetEntAttatchedEffect(PropaneTankEnt[i][X], 1, Effect);
							}
						}
					}

					//Check:
					if(PropaneTankHealth[i][X] > 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(PropaneTankEnt[i][X], 1);

						//Check:
						if(IsValidEdict(TempEnt))
						{

							//Kill:
							AcceptEntityInput(TempEnt, "kill");

							//Initulize:
							SetEntAttatchedEffect(TempEnt, 1, -1);
						}
					}

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PropaneTankHealth[i][X] / 2), (PropaneTankHealth[i][X] / 2), 255);

					//Check:
					if(PropaneTankHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 14, X);

						//Remove:
						RemovePropaneTank(i, X, true);
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

public bool IsPropaneTankInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(PropaneTankEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, PropaneTankEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}