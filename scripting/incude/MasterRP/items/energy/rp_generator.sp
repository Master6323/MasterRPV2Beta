//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_generator_included_
  #endinput
#endif
#define _rp_generator_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Generator:
int GeneratorEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int GeneratorLevel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int GeneratorHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float GeneratorFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
float GeneratorEnergy[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
bool GeneratorIsRunning[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
//char GeneratorModel[256] = "models/props_wasteland/laundry_washer003.mdl";
char GeneratorModel[256] = "models/generator/generator_base.mdl";

public void initGenerator()
{

	//Commands:
	RegAdminCmd("sm_testgenerator", Command_TestGenerator, ADMFLAG_ROOT, "<Id> <Time> - Creates a Generator");
}

public void initDefaultGenerator(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		GeneratorEnt[Client][X] = -1;

		GeneratorHealth[Client][X] = 0;

		GeneratorFuel[Client][X] = 0.0;

		GeneratorEnergy[Client][X] = 0.0;

		GeneratorIsRunning[Client][X] = false;

		GeneratorLevel[Client][X] = 0;
	}
}

public int GetGeneratorIdFromEnt(int Ent)
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
				if(GeneratorEnt[i][X] == Ent)
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

public int HasClientGenerator(int Client, int Id)
{

	//Is Valid:
	if(GeneratorEnt[Client][Id] > 0)
	{

		//Return:
		return GeneratorEnt[Client][Id];
	}

	//Return:
	return -1;
}

public float GetGeneratorEnergy(int Client, int Id)
{

	//Return:
	return GeneratorEnergy[Client][Id];
}

public void SetGeneratorEnergy(int Client, int Id, float Amount)
{

	//Initulize:
	GeneratorEnergy[Client][Id] = Amount;
}

public int GetGeneratorHealth(int Client, int Id)
{

	//Return:
	return GeneratorHealth[Client][Id];
}

public void SetGeneratorHealth(int Client, int Id, int Amount)
{

	//Initulize:
	GeneratorHealth[Client][Id] = Amount;
}

public float GetGeneratorFuel(int Client, int Id)
{

	//Return:
	return GeneratorFuel[Client][Id];
}

public void SetGeneratorFuel(int Client, int Id, float Amount)
{

	//Initulize:
	GeneratorFuel[Client][Id] = Amount;
}

public int GetGeneratorLevel(int Client, int Id)
{

	//Return:
	return GeneratorLevel[Client][Id];
}

public void OnGeneratorUse(int Client, int Ent)
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
						if(GeneratorEnt[i][X] == Ent)
						{

							//Check:
							if(GeneratorIsRunning[i][X])
							{

								//Initulize:
								GeneratorIsRunning[i][X] = false;
							}

							//Override:
							else
							{

								//Initulize:
								GeneratorIsRunning[i][X] = true;
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

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Generator!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public void OnGeneratorShift(int Client, int Ent)
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
						if(GeneratorEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You have to damage the Generator in order to distroy it!");

							}

							//Is Valid:
							else
							{

								//Check:
								if(GeneratorEnergy[i][X] - 20.0 > 0 && GetEnergy(Client) < 100)
								{

									//Initulize:
									GeneratorEnergy[i][X] -= 20.0;

									//Check
									if(GetEnergy(Client) + 20 < 100)
									{

										//Initulize:
										SetEnergy(Client, (GetEnergy(Client) + 20));
									}

									//Override
									else
									{

										//Initulize:
										SetEnergy(Client, 100);
									}

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You have recharged yourself with 20 Energy!");
								}

								//Check:
								if(GetEnergy(Client) >= 100)
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You already have full energy!");
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You depleted this Generator cell otherwise it will explode!");
								}
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
			CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF To Use Generator!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public void initGeneratorTime(int Timer)
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
				if(IsValidEdict(GeneratorEnt[i][X]))
				{

					//Check Is Generator Running:
					if(GeneratorIsRunning[i][X])
					{

						//Declare:
						int Level = (GeneratorLevel[i][X] * 1250);

						//Check:
						if(Timer == 0 || Timer == 3 || Timer == 6 || Timer == 9)
						{

							//Check:
							if(GeneratorEnergy[i][X] < float(Level) && GeneratorFuel[i][X] > 0.0 && GeneratorHealth[i][X] > 100)
							{

								//Declare:
								float Random = (GetRandomFloat(1.20, 0.80) + float(GeneratorLevel[i][X] / 3));

								//Check:
								if(GeneratorEnergy[i][X] + Random > float(Level))
								{

									//Initulize:
									GeneratorEnergy[i][X] = float(Level);
								}

								//Override:
								else
								{

									//Initulize:
									GeneratorEnergy[i][X] += Random;
								}

								//Check:
								if(GeneratorFuel[i][X] - (Random / 4.0) < 0)
								{

									//Initulize:
									GeneratorFuel[i][X] = 0.0;
								}

								//Override:
								else
								{

									//Initulize:
									GeneratorFuel[i][X] -= (Random / 4.0);
								}

								//Override:
								if(Timer == 3 || Timer == 6 || Timer == 9)
								{

									//Declare:
									int TempEnt = GetEntAttatchedEffect(GeneratorEnt[i][X], 0);

									//Check:
									if(IsValidEdict(TempEnt))
									{

										//Accept:
										AcceptEntityInput(TempEnt, "TurnOn");

										AcceptEntityInput(TempEnt, "DoSpark");
									}
								}
							}
						}

						//Check:
						if(Timer == 0)
						{

							//Check:
							if(GeneratorEnergy[i][X] == Level && GeneratorFuel[i][X] > 0.0 && GeneratorHealth[i][X] > 100)
							{


								//Declare:
								float Random = GetRandomFloat(0.01, 0.005);

								//Check:
								if(GeneratorFuel[i][X] - (Random / 3.0) < 0)
								{

									//Initulize:
									GeneratorFuel[i][X] = 0.0;
								}

								//Override:
								else
								{

									//Initulize:
									GeneratorFuel[i][X] -= (Random / 3.0);
								}

								//Declare:
								int TempEnt = GetEntAttatchedEffect(GeneratorEnt[i][X], 0);

								//Check:
								if(IsValidEdict(TempEnt))
								{

									//Accept:
									AcceptEntityInput(TempEnt, "TurnOn");

									AcceptEntityInput(TempEnt, "DoSpark");
								}
							}
						}
					}

					//Check:
					if(GeneratorHealth[i][X] > 0 && GeneratorHealth[i][X] <= 100)
					{

						//Declare:
						float EntOrigin[3];

						//Initulize:
						GetEntPropVector(GeneratorEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

						//CreateDamage:
						ExplosionDamage(i, GeneratorEnt[i][X], EntOrigin, DMG_BURN);

						//Declare:
						int Random = GetRandomInt(1, 5);

						//Check:
						if(Random <= 2)
						{

							//Initulize:
							GeneratorHealth[i][X] -= Random;
						}
					}

					//Check:
					if(GeneratorHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 12, X);

						//Remove:
						RemoveGenerator(i, X, true);
					}
				}
			}
		}
	}
}

//Spawn Timer:
public Action ReSparkGenerator(Handle Timer, any Ent)
{

	//Declare:
	int TempEnt = GetEntAttatchedEffect(Ent, 0);

	//Check:
	if(IsValidEdict(TempEnt))
	{

		//Accept:
		AcceptEntityInput(TempEnt, "TurnOn");

		AcceptEntityInput(TempEnt, "DoSpark");
	}
}

public void GeneratorHud(int Client, int Ent)
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
				if(GeneratorEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Generator Basic:
					if(GeneratorLevel[i][X] == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Generator (Basic):\nEnergy: %.0fWz\nFuel: %0.2fL\nHealth: %i", GeneratorEnergy[i][X], GeneratorFuel[i][X], GeneratorHealth[i][X]);
					}

					//Generator Advanced:
					if(GeneratorLevel[i][X] == 2)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Generator (Advanced):\nEnergy: %.0fWz\nFuel: %0.2fL\nHealth: %i", GeneratorEnergy[i][X], GeneratorFuel[i][X], GeneratorHealth[i][X]);
					}

					//Generator Basic:
					if(GeneratorLevel[i][X] == 3)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Generator (Master):\nEnergy: %.0fWz\nFuel: %0.2fL\nHealth: %i", GeneratorEnergy[i][X], GeneratorFuel[i][X], GeneratorHealth[i][X]);
					}

					//Generator Basic:
					if(GeneratorLevel[i][X] == 4)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Generator (Ultimate):\nEnergy: %.0fWz\nFuel: %0.2fL\nHealth: %i", GeneratorEnergy[i][X], GeneratorFuel[i][X], GeneratorHealth[i][X]);
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

public void RemoveGenerator(int Client, int X, bool Result)
{

	//Initulize:
	GeneratorEnergy[Client][X] = 0.0;

	GeneratorHealth[Client][X] = 0;

	GeneratorLevel[Client][X] = 0;

	GeneratorFuel[Client][X] = 0.0;

	GeneratorIsRunning[Client][X] = false;

	//EntCheck:
	if(CheckMapEntityCount() < 2047 && Result)
	{

		//Declare:
		float GeneratorOrigin[3];

		//Get Prop Data:
		GetEntPropVector(GeneratorEnt[Client][X], Prop_Send, "m_vecOrigin", GeneratorOrigin);

		//Temp Ent:
		TE_SetupSparks(GeneratorOrigin, NULL_VECTOR, 5, 5);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(GeneratorOrigin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();
	}

	//Check:
	if(IsValidAttachedEffect(GeneratorEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(GeneratorEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(GeneratorEnt[Client][X], "kill");

	//Inituze:
	GeneratorEnt[Client][X] = -1;
}

public bool CreateGenerator(int Client, int Id, float fEnergy, float Fuel, int Level, int Health, float Position[3], float Angle[3], bool IsConnected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - Unable to spawn Generator due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		char AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%i", Level);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 12, Id, RoundFloat(fEnergy), RoundFloat(Fuel), Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You have just spawned a Generator!");
	}

	//Initulize:
	GeneratorEnergy[Client][Id] = fEnergy;

	GeneratorFuel[Client][Id] = Fuel;

	GeneratorLevel[Client][Id] = Level;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	GeneratorHealth[Client][Id] = Health;

	GeneratorIsRunning[Client][Id] = true;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", GeneratorModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	GeneratorEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientGenerator);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Generator");

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (GeneratorHealth[Client][Id] / 2), (GeneratorHealth[Client][Id] / 2), 255);

	//Initulize Effects:
	int Effect = CreatePointTesla(Ent, "null", "255 120 51");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Check:
	if(GeneratorHealth[Client][Id] > 0 && GeneratorHealth[Client][Id] <= 100)
	{

		//Initulize Effects:
		Effect = CreateEnvFire(GeneratorEnt[Client][Id], "null", "200", "700", "0", "Natural");

		SetEntAttatchedEffect(GeneratorEnt[Client][Id], 1, Effect);
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestGenerator(int Client, int Args)
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
	if(Args < 5)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testGenerator <Id> <Energy> <Fuel> <Level> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	char sEnergy[32];
	char sFuel[32];
	char sLevel[32];
	char sHealth[32];
	int Id = 0;
	float fEnergy = 0.0;
	float Fuel = 0.0;
	int Level = 0;
	int Health = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sEnergy, sizeof(sEnergy));

	//Initialize:
	GetCmdArg(3, sFuel, sizeof(sFuel));

	//Initialize:
	GetCmdArg(4, sLevel, sizeof(sLevel));

	//Initialize:
	GetCmdArg(5, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	fEnergy = StringToFloat(sEnergy);

	Fuel = StringToFloat(sFuel);

	Level = StringToInt(sLevel);

	Health = StringToInt(sHealth);

	if(GeneratorEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Generator with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Generator %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];

	float Ang[3];

	//Create Generator:
	CreateGenerator(Client, Id, fEnergy, Fuel, Level, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsGeneratorUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		float Var = StringToFloat(GetItemVar(ItemId));

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
			Ent = HasClientGenerator(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateGenerator
				if(CreateGenerator(Client, Y, (Var * 500), (Var * 100), RoundFloat(Var), 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Generator|\x07FFFFFF - You already have too many Generator, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action OnDamageClientGenerator(int Ent, int &Ent2, int &inflictor, float &Damage, int &damageType)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(int X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(GeneratorEnt[i][X] == Ent)
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
							if(GeneratorHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								GeneratorHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								GeneratorHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (GeneratorHealth[i][X] / 2), (GeneratorHealth[i][X] / 2), 255);

							//Check:
							if(GeneratorHealth[i][X] > 100)
							{

								//Declare:
								int TempEnt = GetEntAttatchedEffect(GeneratorEnt[i][X], 1);

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
							DamageClientGenerator(GeneratorEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientGenerator(GeneratorEnt[i][X], Damage, Ent2);
					}
				}

				//Check:
				if(GeneratorHealth[i][X] > 100)
				{

					//Declare:
					int TempEnt = GetEntAttatchedEffect(GeneratorEnt[i][X], 1);

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

public Action DamageClientGenerator(int Ent, float &Damage, int &Attacker)
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
				if(GeneratorEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) GeneratorHealth[i][X] -= RoundFloat(Damage);

					//Check:
					if(GeneratorHealth[i][X] > 0 && GeneratorHealth[i][X] <= 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(GeneratorEnt[i][X], 1);

						//Check:
						if(!IsValidEdict(TempEnt))
						{

							//Explode:
							CreateExplosion(Attacker, GeneratorEnt[i][X]);

							//Check:
							if(GeneratorEnt[i][X] > 0)
							{

								//Initulize Effects:
								int Effect = CreateEnvFire(GeneratorEnt[i][X], "null", "200", "700", "0", "Natural");

								SetEntAttatchedEffect(GeneratorEnt[i][X], 1, Effect);
							}
						}
					}

					//Check:
					if(GeneratorHealth[i][X] > 100)
					{

						//Declare:
						int TempEnt = GetEntAttatchedEffect(GeneratorEnt[i][X], 1);

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
					SetEntityRenderColor(Ent, 255, (GeneratorHealth[i][X] / 2), (GeneratorHealth[i][X] / 2), 255);

					//Check:
					if(GeneratorHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 12, X);

						//Remove:
						RemoveGenerator(i, X, true);
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

public bool IsGeneratorInDistance(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(GeneratorEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, GeneratorEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}