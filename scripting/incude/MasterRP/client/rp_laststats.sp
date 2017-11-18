//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_laststats_included_
  #endinput
#endif
#define _rp_laststats_included_

public void initLastStats()
{

	//Timer:
	CreateTimer(0.2, CreateSQLdbLastStats);
}

//Create Database:
public Action CreateSQLdbLastStats(Handle Timer)
{

	//Declare:
	int len = 0;
	char query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `LastStats`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` init(11) NOT NULL, `LastPosition` varchar(64) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Health` int(5) NULL, `Armor` int(5) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `Model` varchar(128) NULL, `Hat` varchar(128) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 18);
}

public Action DBLoadLastStats(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `LastStats` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	int conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLastStats, query, conuserid);
}

public void T_DBLoadLastStats(Handle:owner, Handle:hndl, const char[] error, any data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_settings] T_DBLoadPosition: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player Last Stats...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Add Player To DB:
			InsertLastStats(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{


			//Declare:
			char Dump[255];
			char Buffer[6][32];
			float LastPosition[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Dump, sizeof(Dump));

			//Convert:
			ExplodeString(Dump, "^", Buffer, 3, 32);

			//Loop:
			for(int X = 0; X <= 2; X++)
			{

				//Initulize:
				LastPosition[X] = StringToFloat(Buffer[X]);
			}

			//Teleport:
    			TeleportEntity(Client, LastPosition, NULL_VECTOR, NULL_VECTOR);

			//Database Field Loading INTEGER:
			int Health = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			int Armor = SQL_FetchInt(hndl, 3);

			//Set Health:
			SetEntityHealth(Client, Health);

			//Set Armor:
			SetEntityArmor(Client, Armor);

			//Database Field Loading String:
			//SQL_FetchString(hndl, 4, Dump, sizeof(Dump)); // Model

			//Database Field Loading String:
			SQL_FetchString(hndl, 5, Dump, sizeof(Dump)); // rp_Hat.sp

			//Set Hat:
			SetHatModelFx(Client, Dump);

			//Added Spawn Effect:
			InitSpawnEffect(Client);

			//Initulize:
			SetJetPackOn(Client, false);

			//Remove Web Panel:
			RemoveWebPanel(Client);

			//Check:
			if(!StrEqual(GetHatModel(Client), "null"))
			{

				//Create Hat:
				CreateHat(Client, GetHatModel(Client));
			}

			//Create Player Trail Effects:
			CreatePlayerTrails(Client);

			//Print:
			PrintToConsole(Client, "|RP| Player Last Stats Loaded");
		}
	}
}

public Action InsertLastStats(int Client)
{

	//Declare:
	char buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO LastStats (`STEAMID`,`LastPosition`,`Health`,`Armor`,`Model`,`Hat`) VALUES (%i,'%s',100,0,'%s','%s');", SteamIdToInt(Client), "0.0^0.0^0.0", "null", "null");

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer, 19);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Last Stats.");

	//Respawn to prevent non spawn:
	InitSpawnPos(Client, 1);
}

public Action UpdateLastStats(int Client)
{

	//Spam Check:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		float Position[3];

		//Initialize:
		GetClientAbsOrigin(Client, Position);

		//Declare:
		char FormatOrg[255];
		char query[255];

		//Format:
		Format(FormatOrg, sizeof(FormatOrg), "%f^%f^%f", Position[0], Position[1], Position[2]);

		//Format:
		Format(query, sizeof(query), "UPDATE LastStats SET LastPosition = '%s' WHERE STEAMID = %i;", FormatOrg, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 20);

		//Is Alive:
		if(IsPlayerAlive(Client))
		{

			//Format:
			Format(query, sizeof(query), "UPDATE LastStats SET Health = %i, Armor = %i WHERE STEAMID = %i;", GetClientHealth(Client), GetClientArmor(Client), SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 21);
		}
	}
}