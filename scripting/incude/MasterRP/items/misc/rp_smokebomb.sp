//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_SmokeBomb_included_
  #endinput
#endif
#define _rp_SmokeBomb_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//SmokeBomb:
int SmokeBombUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int SmokeBombEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
int SmokeBombExplode[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
char SmokeBombModel[256] = "models/props_junk/cardboard_box004a.mdl";

public void initSmokeBomb()
{

	//Commands:
	RegAdminCmd("sm_testsmokebomb", Command_TestSmokeBomb, ADMFLAG_ROOT, "<Id> <Time> - Creates a SmokeBomb");
}

public int initDefaultSmokeBomb(int Client)
{

	//Loop:
	for(int X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		SmokeBombEnt[Client][X] = -1;

		SmokeBombExplode[Client][X] = 0;

		SmokeBombUse[Client][X] = 0;
	}
}

public int HasClientSmokeBomb(int Client, int Id)
{

	//Is Valid:
	if(SmokeBombEnt[Client][Id] > 0)
	{

		//Return:
		return SmokeBombEnt[Client][Id];
	}

	//Return:
	return -1;
}

public int GetSmokeBombUse(int Client, int Id)
{

	//Return:
	return SmokeBombUse[Client][Id];
}

public int GetSmokeBombExplode(int Client,int  Id)
{

	//Return:
	return SmokeBombExplode[Client][Id];
}

public void OnSmokeBombUse(int Client, int Ent)
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
						if(SmokeBombEnt[i][X] == Ent)
						{


							//Is Valid:
							if(SmokeBombUse[i][X] == 0 && SmokeBombExplode[i][X] == 0 && Client == i)
							{

								//Initulize:
								SmokeBombExplode[i][X] = 30;

								SmokeBombUse[i][X] = 1;

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - You have just armed your SmokeBomb. it will explode in \x0732CD3230\x07FFFFFF seconds!");
							}

							//Is Valid:
							else if(SmokeBombUse[i][X] == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - This SmokeBomb is going to explode in %i Sec", SmokeBombExplode[i][X]);
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - You can't use this explosive SmokeBomb!");
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
			CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use SmokeBomb!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public void initSmokeBombTime()
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
				if(IsValidEdict(SmokeBombEnt[i][X]))
				{

					//Declare:
					float EntOrigin[3];

					//Initialize:
					GetEntPropVector(SmokeBombEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Enabled:
					if(SmokeBombUse[i][X] == 1)
					{

						//Initulize:
						SmokeBombExplode[i][X] -=1;

						//Explode:
						if(SmokeBombExplode[i][X] == 0)
						{

							//Temp Ent:
							TE_SetupExplosion(EntOrigin, Explode(), 5.0, 1, 0, 600, 5000);

							//Send:
							TE_SendToAll();

							//Emit Sound:
							EmitAmbientSound("ambient/explosions/explode_5.wav", EntOrigin, SNDLEVEL_RAIDSIREN);

							//Declare:
							int Effect = CreateEnvSmokeTrail(SmokeBombEnt[i][X], "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "500", "300", "50", "100", "0", "200 200 200", "5");

							SetEntAttatchedEffect(SmokeBombEnt[i][X], 0, Effect);

							//Set Bomb Color:
							SetEntityRenderColor(SmokeBombEnt[i][X], 255, 50, 50, 255);
						}
					}

					//Remove After 2 Minutes!
					if(SmokeBombExplode[i][X] == -30)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 28, X);

						//Explode:
						RemoveSmokeBomb(i, X, false);
					}

					//Show CrimeHud:
					ShowSmokeBombToAll(EntOrigin, i, X);
				}
			}
		}
	}
}

public void SmokeBombHud(int Client, int Ent)
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
				if(SmokeBombEnt[i][X] == Ent)
				{

					//Declare:
					char FormatMessage[512];

					//Bomb Already Armed:
					if(SmokeBombExplode[i][X] > 0 && SmokeBombExplode[i][X] <= 30)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "SmokeBomb:\nSmokeBomb will explode in\n(%i) Seconds", SmokeBombExplode[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "SmokeBomb:\nThis SmokeBomb belongs to:\n%N!", i);
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

//Crime Hud:
public void ShowSmokeBombToAll(float SmokeBombOrigin[3], int Client, int X)
{

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	//Initialize:
	float Dist = GetVectorDistance(ClientOrigin, SmokeBombOrigin);

	//In Distance:
	if(Dist <= 800)
	{

		//Initulize:
		SmokeBombOrigin[2] += 1.0;

		//Declare:
		int ColorSmokeBomb[4] = {50, 250, 50, 250};

		//Check:
		if(SmokeBombExplode[Client][X] > 20 && SmokeBombExplode[Client][X] < 30)
		{

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", SmokeBombOrigin, SmokeBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		if(SmokeBombExplode[Client][X] > 10 && SmokeBombExplode[Client][X] < 21)
		{

			//Initulize:
			ColorSmokeBomb[0] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", SmokeBombOrigin, SmokeBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		else if(SmokeBombExplode[Client][X] > 0 && SmokeBombExplode[Client][X] < 11)
		{

			//Initulize:
			ColorSmokeBomb[0] = 255;
			ColorSmokeBomb[1] = 50;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", SmokeBombOrigin, SmokeBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Show To Client:
		TE_SetupBeamRingPoint(SmokeBombOrigin, 1.0, 100.0, Laser(), Sprite(), 0, 10, 0.7, 5.0, 0.5, ColorSmokeBomb, 10, 0);

		//End Temp:
		TE_SendToAll();
	}
}

public void RemoveSmokeBomb(int Client, int X, bool Explode)
{

	//Can Explode:
	if(Explode)
	{

		//Explode:
		CreateExplosion(Client, SmokeBombEnt[Client][X]);
	}

	//Initulize:
	SmokeBombUse[Client][X] = 0;

	SmokeBombExplode[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(SmokeBombEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(SmokeBombEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(SmokeBombEnt[Client][X], "kill");

	//Inituze:
	SmokeBombEnt[Client][X] = -1;
}

public bool CreateSmokeBomb(int Client, int Id, int Time, int Value, float Position[3], float Angle[3], bool IsConnected)
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
		if(TR_PointOutsideWorld(ClientOrigin))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - Unable to spawn Bomb due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 28, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - You have just spawned a SmokeBomb!");
	}

	//Initulize:
	SmokeBombUse[Client][Id] = Time;

	SmokeBombExplode[Client][Id] = 0;

	//Declare:
	int Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", SmokeBombModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	SmokeBombEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Set Prop ClassName
	SetEntityClassName(Ent, "prop_Smoke_Bomb");

	//Is Valid:
	if(StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action Command_TestSmokeBomb(int Client, int Args)
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
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testSmokeBomb <Id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char sId[32];
	int Id = 0;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	Id = StringToInt(sId);

	if(SmokeBombEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money SmokeBomb with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid SmokeBomb %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float Pos[3];
	float Ang[3];

	//CreateSmokeBomb
	CreateSmokeBomb(Client, Id, 0, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public void OnItemsSmokeBombUse(int Client, int ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
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
			Ent = HasClientSmokeBomb(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn SmokeBomb:
				if(CreateSmokeBomb(Client, Y, 0, 0, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + 500));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-SmokeBomb|\x07FFFFFF - You already have too many Fire Bombs, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}