//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bombzone_included_
  #endinput
#endif
#define _rp_bombzone_included_

//Defines:
#define MAXBOMBZONES		10

//Euro - € dont remove this!
//€ = �

//Random Bomb Zones!
float BombZones[MAXBOMBZONES + 1][3];
int BombZoneTimer = 0;
int BombExplodeTimer = 0;
int GlobalBombEnt = -1;

public void initGlobalBomb()
{

	//Commands:
	RegAdminCmd("sm_createbombzone", Command_CreateBombZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removebombzone", Command_RemoveBombZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listbombzones", Command_ListBombZones, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipebombzones", Command_WipeBombZones, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_testbombzone", Command_TestBombZone, ADMFLAG_ROOT, "<id> - Test Bomb Spawn");

	//Timers:
	CreateTimer(0.2, CreateSQLdbBombZones);

	//Loop:
	for(int Z = 0; Z <= MAXBOMBZONES; Z++)  for(int i = 0; i < 3; i++)
	{

		//Initulize:
		BombZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action CreateSQLdbBombZones(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `BombZones`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 144);
}

//Create Database:
public Action LoadBombZones(Handle Timer)
{

	//Loop:
	for(int Z = 0; Z <= 10; Z++) for(int i = 0; i < 3; i++)
	{

		//Initulize:
		BombZones[Z][i] = 69.0;
	}

	//Declare:
	char query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM BombZones WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadBombZones, query);
}

public void T_DBLoadBombZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Invalid Query:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadBombZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Random Bomb Zones Found in DB!");

			//Return:
			return;
		}

		//Declare:
		int X = 0; 
		char Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			char Dump[3][64];
			float Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			BombZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Bomb Zones Zones Found!");
	}
}

public void T_DBPrintBombZones(Handle owner, Handle hndl, const char[] error, any data)
{

	//Declare:
	int Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBPrintBombZones: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		int ZoneId = 0;
		char Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

// remove players from Vehicles before they are destroyed or the server will crash!
public void OnBombDestroyed(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the Bomb!:
		if(GlobalBombEnt == Entity)
		{

			//Initulize:
			GlobalBombEnt = -1;

			//Check:
			if(IsValidAttachedEffect(GlobalBombEnt))
			{

				//Remove:
				RemoveAttachedEffect(GlobalBombEnt);
			}
		}
	}
}

//Client Hud:
public void initGlobalBombTick()
{

	//Is Global Bomb!
	if(GlobalBombEnt != -1)
	{

		//EntCheck:
		if(CheckMapEntityCount() < 1900)
		{

			//Declare:
			float BombOrigin[3];

			//Initulize:
			GetEntPropVector(GlobalBombEnt, Prop_Data, "m_vecOrigin", BombOrigin);

			//Declare:
			int Color[4] = {255, 255, 50, 255};

			//Show To Client:
			TE_SetupBeamRingPoint(BombOrigin, 1.0, 50.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, Color, 10, 0);

			//Show To Client:
			TE_SendToAll();
		}

		//Check:
		if(BombExplodeTimer == 0)
		{

			//Create Bomb Explosion:
			ExplodeGlobalBomb(GlobalBombEnt);
		}

		//Check:
		if(BombExplodeTimer > -30)
		{

			//Initulize:
			BombExplodeTimer -= 1;
		}

		//Check:
		if(BombExplodeTimer == -30)
		{

			//Remove Bomb:
			RemoveGlobalBomb(GlobalBombEnt);
		}
	}

	//Initulize:
	BombZoneTimer++;

	//TimerCheck
	if(BombZoneTimer >= 600)
	{

		//Initulize:
		BombZoneTimer = 0;

		//Invalid Check:
		if(GlobalBombEnt == -1)
		{

			//Declare:
			int Var = GetRandomInt(0, 10);

			//Spawn:
			SpawnGlobalBomb(Var);

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(IsAdmin(i) || IsCop(i) || StrEqual(GetJob(i), "Fire Fighter"))
					{

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - A Bomb has been dropped!");
					}
				}
			}
		}

		//Override!:
		else
		{

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(IsAdmin(i) || IsCop(i) || StrEqual(GetJob(i), "Fire Fighter"))
					{

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - There is already a Bomb spawned on the map!");
					}
				}
			}
		}
	}
}

public void ExplodeGlobalBomb(int Ent)
{

	//Explode:
	CreateExplosion(GlobalBombEnt, GlobalBombEnt);

	//Initulize Effects:
	int Effect = CreateEnvFire(GlobalBombEnt, "null", "200", "700", "0", "Natural");

	SetEntAttatchedEffect(GlobalBombEnt, 0, Effect);

	//Initulize Effects:
	Effect = CreateLight(GlobalBombEnt, 1, 255, 120, 120, "null");

	SetEntAttatchedEffect(GlobalBombEnt, 1, Effect);

	//Set Bomb Color:
	SetEntityRenderColor(GlobalBombEnt, 255, 50, 50, 255);

	//Initulize:
	BombExplodeTimer = -1;
}

public void RemoveGlobalBomb(int Ent)
{

	//Check:
	if(IsValidAttachedEffect(GlobalBombEnt))
	{

		//Remove:
		RemoveAttachedEffect(GlobalBombEnt);
	}

	//Accept:
	AcceptEntityInput(GlobalBombEnt, "kill");

	//Initulize:
	GlobalBombEnt = -1;

	//Initulize:
	BombExplodeTimer = -1;
}

//Use Handle:
public void OnGlobalBombUse(int Client, int Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Check:
		if(IsCop(Client) || IsAdmin(Client) || StrEqual(GetJob(Client), "Fire Fighter"))
		{

			//Is In Time:
			if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
			{

				//Bomb Has not detonated yet:
				if(BombExplodeTimer > 0)
				{

					//Declare:
					int Random = GetRandomInt(0, 10);

					//Check:
					if(Random >= 5)
					{

						//Explode Bomb:
						ExplodeGlobalBomb(Ent);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - You have Detonated the bomb!");
					}

					//Override:
					else
					{

						//Remove FireBomb:
						RemoveGlobalBomb(Ent);

						//Loop:
						for(int i = 1; i <= GetMaxClients(); i++)
						{

							//Connected
							if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
							{

								//Print:
								CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF has Disarmed the bomb!", Client);
							}
						}

						//Declare:
						int Amount = 2000;

						//Initialize:
						SetBank(Client, (GetBank(Client) + Amount));

						//Set Menu State:
						BankState(Client, Amount);

						//Play Sound:
						EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - You have Disarmed the bomb and rewarded \x0732CD32%s!", IntToMoney(Amount));
					}
				}

				//Override:
				else
				{

					//Remove FireBomb:
					RemoveGlobalBomb(Ent);

					//Declare:
					int Amount = 500;

					//Initialize:
					SetBank(Client, (GetBank(Client) + Amount));

					//Set Menu State:
					BankState(Client, Amount);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - You have Removed the bomb and earned \x0732CD32%s!", IntToMoney(Amount));
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Disarm the bomb!");

				//Initulize:
				SetLastPressedE(Client, GetGameTime());
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you Cannot disarm the bomb!");
		}
	}
}

public int SpawnGlobalBomb(int Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Check:
	if(GlobalBombEnt > 0)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - There is already a Bomb spawned on the map!");

		PrintToServer("|RP| - There is already a Bomb spawned on the map!");

		//Return:
		return -1;
	}

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);

	//Check:
	if(TR_PointOutsideWorld(BombZones[Var]))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Bomb Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Bomb Due to outside of world");

		//Return:
		return -1;
	}

	//Declare:
	int Ent = CreateProp(BombZones[Var], Angles, "models/Items/item_item_crate.mdl", true, false, false);

	//Set Damage:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Initulize:
	GlobalBombEnt = Ent;

	BombExplodeTimer = 120;

	//Return:
	return Ent;
}

//Create Garbage Zone:
public Action Command_CreateBombZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createbombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createbombzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	float ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	char query[512];
	char Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(BombZones[Id][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE BombZones SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), Id);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO BombZones (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	BombZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 145);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Bomb Zones spawn \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action Command_RemoveBombZone(int Client, int Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removebombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removebombzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//No Zone:
	if(BombZones[Id][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%i\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	BombZones[Id][0] = 69.0;

	//Declare:
	char query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM BombZones WHERE ZoneId = %i  AND Map = '%s';", Id, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 146);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Bomb Zones Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action Command_ListBombZones(int Client, int Args)
{

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Bomb Zones Spawns: %s", ServerMap());

	//Declare:
	char query[512];

	//Loop:
	for(int X = 0; X <= MAXBOMBZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM BombZones WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintBombZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action Command_WipeBombZones(int Client, int Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Bomb Zones Spawns Wiped: %s", ServerMap());

	//Declare:
	char query[255];

	//Loop:
	for(int  X = 0; X <= MAXBOMBZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM BombZones WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 147);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action Command_TestBombZone(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testbombzone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	int Id = StringToInt(ZoneId);

	//Check:
	if(Id < 0 || Id > 10)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testbombzone <0-10>");

		//Return:
		return Plugin_Handled;
	}

	//Spawn:
	SpawnGlobalBomb(Id);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Test \x0732CD32#%i\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, BombZones[Id][0], BombZones[Id][1], BombZones[Id][2]);

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool IsEntityGlobalBomb(int Ent)
{

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Found Bomb!
		if(GlobalBombEnt == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public int GetGlobalBombEnt()
{

	//Return:
	return GlobalBombEnt;
}

public void SetGlobalBombEnt(int Ent)
{

	//Initulize:
	GlobalBombEnt = Ent;
}