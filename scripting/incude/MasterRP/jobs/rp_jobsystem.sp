//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jobsystem_included_
  #endinput
#endif
#define _rp_jobsystem_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Defines:
#define SALARY_TIME 		120
#define DEFAULTJOB 		"Citizan"

//Job system:
int JobExperience[MAXPLAYERS + 1] = {0,...};
int Energy[MAXPLAYERS + 1] = {0,...};
int NextJobRase[MAXPLAYERS + 1] = {0,...}; //loaded from rp_player.sp
int JobSalary[MAXPLAYERS + 1] = {4,...}; //loaded from rp_player.sp

//Job Strings:
char Job[MAXPLAYERS + 1][255];
char OrgJob[MAXPLAYERS + 1][255];

//Job system:
int CopExperience[MAXPLAYERS + 1] = {0,...};
int CopCuffs[MAXPLAYERS + 1] = {0,...};
int CopMinutes[MAXPLAYERS + 1] = {0,...};

//Hunger:
float Hunger[MAXPLAYERS + 1] = {100.0,...};

//Map Manager:
int SalaryCheck = SALARY_TIME;

public void initJobSytem()
{

	//Commands
	RegAdminCmd("sm_setjobsalary", Command_SetJobSalary, ADMFLAG_ROOT, "- <Name> <Amount> - Sets the Job Salary of the Client");

	RegAdminCmd("sm_sethunger", Command_SetHunger, ADMFLAG_SLAY, "<Name> <Hunger #> - Sets Hunger");

	RegAdminCmd("sm_setjobexperience", Command_SetJobExperience, ADMFLAG_ROOT, "- <Name> <Experience #> - Sets the Job Experience of the Client");

	RegAdminCmd("sm_setenergy", Command_SetEnergy, ADMFLAG_ROOT, "- <Name> <Energy #> - Sets the Energy of the Client");

	RegAdminCmd("sm_setnextjobrase", Command_SetNextJobRase, ADMFLAG_ROOT, "- <Name> <Minutes Online #> - Sets the NextJobRase of the Client");

	RegAdminCmd("sm_setcopexperience", Command_SetCopExperience, ADMFLAG_ROOT, "- <Name> <Experience #> - Sets the Cop Experience of the Client");

	RegAdminCmd("sm_setcopcuffs", Command_SetCopCuffs, ADMFLAG_ROOT, "- <Name> <Cuffs #> - Sets the Cop Cuffs of the Client");

	RegAdminCmd("sm_setcopminutes", Command_SetCopMinutes, ADMFLAG_ROOT, "- <Name> <Minutes #> - Sets the Cop Minutes of the Client");

	//Timer:
	CreateTimer(0.4, CreateSQLdbDynamicJobs);
}

//Create Database:
public Action CreateSQLdbDynamicJobs(Handle Timer)
{

	//Declare:
	new len = 0;
	decl String:query[2560];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Jobs`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL PRIMARY KEY, `CopMinutes` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `CopCuffs` int(12) NULL, `CopExperience` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Experience` int(12) NOT NULL DEFAULT 0, `Energy` int(12) NOT NULL DEFAULT 100,");

	len += Format(query[len], sizeof(query)-len, " `Hunger` float(12) NOT NULL DEFAULT '100.0', `Harvest` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Meth` int(12) NOT NULL DEFAULT 0, `Pills` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Cocain` int(12) NOT NULL DEFAULT 0, `Rice` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Resources` int(12) NOT NULL DEFAULT 0);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action DBLoadJobs(int Client)
{

	//Declare:
	char query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Jobs` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadJobsCallBack, query, conuserid);
}

public void T_LoadJobsCallBack(Handle owner, Handle hndl, const char[] error, any data)
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
	if(hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Jobs] T_LoadJobsCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player Job system...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Declare:
			InsertJobs(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			CopMinutes[Client] = SQL_FetchInt(hndl, 1);

			//Database Field Loading INTEGER:
			CopCuffs[Client] = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			CopExperience[Client] = SQL_FetchInt(hndl, 3);

			//Database Field Loading INTEGER:
			JobExperience[Client] = SQL_FetchInt(hndl, 4);

			//Database Field Loading INTEGER:
			Energy[Client] = SQL_FetchInt(hndl, 5);

			//Database Field Loading FLOAT:
			Hunger[Client] = SQL_FetchFloat(hndl, 6);

			//Print:
			PrintToConsole(Client, "|RP| player Job system loaded.");
		}
	}
}

public Action InsertJobs(int Client)
{

	//Declare:
	char buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Jobs (`STEAMID`) VALUES (%i);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Jobs.");
}

public void SetDefaultJob(Client)
{

	//Format:
	Job[Client] = DEFAULTJOB;

	OrgJob[Client] = DEFAULTJOB;

	JobSalary[Client] = 4;

	NextJobRase[Client] = 0;
}

public void initSalaryTimer()
{

	//Initialize:
	SalaryCheck -= 1;

	//Is Job Salary Due:
	if(SalaryCheck == 1 || SalaryCheck == 60)
	{

		//Loop:
		for(int Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(IsClientConnected(Client) && IsClientInGame(Client))
			{

				//Initulize:
				SetCash(Client, (GetCash(Client) + GetJobSalary(Client)));

				//Set Menu State:
				CashState(Client, GetJobSalary(Client));

				//Initialize:
				SetNextJobRase(Client, (GetNextJobRase(Client) + 1));

				//Wages:
				if(NextJobRase[Client] >= Pow(float(GetJobSalary(Client)), 3.0))
				{

					//Add:
					SetJobSalary(Client, (GetJobSalary(Client) + 1));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - You have recieved a raise for spending a total of \x0732CD32%i\x0732CD32\x07FFFFFF minutes in the server\x0732CD32\x07FFFFFF.", NextJobRase[Client]);
				}

				//Take Hunger:
				initHunger(Client);

				//Save:
				DBSave(Client);

				//Save Spawned Items:
				SaveSpawnedItemForward(Client, false);

				//Update Last Stats:
				UpdateLastStats(Client);

				//Recover Energy:
				initEnergy(Client);

				//Remove Drug
				initDrugTick(Client);

				//Cop Minutes:
				initCopMinutes(Client);
			}
		}

		//Special NPC Events
		InitNpcEvents();

		//Clean Map Entities:
		initPropSpawnedTime();
	}

	//Check Timer:
	if(SalaryCheck < 1)
	{

		//Spawn Server Trash:
		initGarbage();

		//Initialize:
		SalaryCheck = SALARY_TIME;
	}
}

public void initHunger(int Client)
{

	//Is Client Cuffed:
	if(!IsCuffed(Client) && IsHungerDisabled() == 0)
	{

		//Declare
		float Amount = GetHunger(Client);

		//Less Hunger:
		if(IsSleeping(Client) > 0.0)
		{

			//Initialize:
			SetHunger(Client, (Amount - GetRandomFloat(0.05, 0.20)));
		}

		//Override:
		else
		{

			//Initialize:
			SetHunger(Client, (Amount - GetRandomFloat(0.40, 0.70)));
		}

		//No Hunger:
		if(Amount <= 0.0)
		{

			//Slay Client:
			ForcePlayerSuicide(Client);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You starved to death!");

			//Initialize:
			SetHunger(Client, 35.0);

			//Has Cash:
			if(GetBank(Client) - 50 > 0)
			{

				//Bank State:
				BankState(Client, -50);

				//Initialize:
				SetBank(Client, (GetBank(Client) - 50));
			}
		}
	}
}

public Action Command_SetJobSalary(int Client, int Args)
{

	//Error:
	if(Args != 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setjobsalary <Name> <wage #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int iAmount = StringToInt(Arg2);

	//Initialize:
	SetJobSalary(Player, iAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set the JobSalary for \x0732CD32%N\x07FFFFFF to \x0732CD32â‚¬%i", Player, iAmount);

	CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Your JobSalary has been set to \x0732CD32â‚¬%i\x07FFFFFF by \x0732CD32%N", iAmount, Client);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set %s's JobSalary to \"€%L\"", Client, Player, iAmount); 
#endif

	//Return:
	return Plugin_Handled; 
}

public Action:Command_SetHunger(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_sethunger <Name> <Hunger #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	float fAmount = StringToFloat(Arg2);

	//Action:
	SetHunger(Player, fAmount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's hunger to \x0732CD32%f", Player, fAmount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your hunger to \x0732CD32%f", Client, fAmount);
	}

#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the hunger of \"%N\" to %f", Client, Player, fAmount);
#endif
	//Return:
	return Plugin_Handled;
}

public Action:Command_SetJobExperience(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setjobexperience <Name> <Experience #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetJobExperience(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Job Experience to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Job Experience to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Job Experience of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

public Action:Command_SetEnergy(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setenergy <Name> <Energy #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetEnergy(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Job Energy to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Energy to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Energy of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

public Action:Command_SetNextJobRase(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setnextjobrase <Name> <Minutes Online #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetNextJobRase(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Minutes Online to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set Minutes Online to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Next Job Rase of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

public Action:Command_SetCopExperience(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcopexperience <Name> <Experience #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetCopExperience(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Cop Experience to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Cop Experience to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Cop Experience of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

public Action:Command_SetCopCuffs(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcopcuffs <Name> <Cuffs #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetCopCuffs(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Cop Cuffs to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Cop Cuffs to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Cop Cuffs of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

public Action:Command_SetCopMinutes(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcopminutes <Name> <Minutes #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg1[32];

	//Initialize:
	GetCmdArg(1, Arg1, sizeof(Arg1));

	//Deckare:
	int Player = GetPlayerIdFromString(Arg1);

	//Valid Player:
	if(Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char Arg2[32];

	//Initialize:
	GetCmdArg(2, Arg2, sizeof(Arg2));

	//Initialize:
	int Amount = StringToInt(Arg2);

	//Action:
	SetCopMinutes(Player, Amount);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's Cop Minutes to \x0732CD32%i", Player, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your Cop Minutes to \x0732CD32%i", Client, Amount);
	}
#if defined DEBUG
	//Logging:
	LogMessage("\"%N\" set the Cop Minutes of \"%N\" to %i", Client, Player, Amount);
#endif
	//Return:
	return Plugin_Handled;
}

//Return Wages:
public int GetCopWages(int Client)
{

	//Initulize:
	int Wage = CopMinutes[Client] / 600;

	//Is Valid:
	if(Wage < 3)
	{

		//Initulize:
		Wage = 3;
	}

	//Initulize:
	int AddedWage = CopCuffs[Client] / 200;

	//Is Valid:
	if(AddedWage < 2)
	{

		//Initulize:
		AddedWage = 2;
	}

	//Initulize:
	Wage += AddedWage;

	//Return:
	return Wage;
}

public int GetSalaryCheck()
{

	//Return:
	return SalaryCheck;
}

public int GetEnergy(int Client)
{

	//Return:
	return Energy[Client];
}

public void SetEnergy(int Client, int Amount)
{

	//Initulize:
	Energy[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Energy = %i WHERE STEAMID = %i;", Energy[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetNextJobRase(int Client)
{

	//Return:
	return NextJobRase[Client];
}

public void SetNextJobRase(int Client, int Amount)
{

	//Initulize:
	NextJobRase[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE player SET Rase = %i WHERE STEAMID = %i;", NextJobRase[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetJobSalary(int Client)
{

	//Return:
	return JobSalary[Client];
}

public void SetJobSalary(int Client, int Amount)
{

	//Initulize:
	JobSalary[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET JobSalary = %i WHERE STEAMID = %i;", JobSalary[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetJobExperience(int Client)
{

	//Return:
	return JobExperience[Client];
}

public void SetJobExperience(int Client, int Amount)
{

	//Initulize:
	JobExperience[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Experience = %i WHERE STEAMID = %i;", JobExperience[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public void SetJob(int Client, const char[] Str)
{

	//Format:
	Format(Job[Client], sizeof(Job[]), "%s", Str);
}

char GetJob(int Client)
{

	//return:
	return Job[Client];
}

public void  SetOrgJob(int Client, const char[] Str)
{

	//Format:
	Format(OrgJob[Client], sizeof(OrgJob[]), "%s", Str);

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Job = '%s' WHERE STEAMID = %i;", OrgJob[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

char GetOrgJob(int Client)
{

	//return:
	return OrgJob[Client];
}

//Cop or Admin Check:
public bool IsCop(int Client)
{

	//Connected:
	if(Client < 1 || !IsClientConnected(Client) || !IsClientInGame(Client))
	{

		//Return:
		return false;
	}

	//Is Police:
	if(StrContains(GetJob(Client), "Police", false) != -1)
	{

		//Return:
		return true;
	}

	//Is Swat:
	if(StrContains(GetJob(Client), "SWAT", false) != -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

//Cop or Admin Check:
public bool IsCopOrgJob(int Client)
{

	//Connected:
	if(Client < 1 || !IsClientConnected(Client) || !IsClientInGame(Client))
	{

		//Return:
		return false;
	}

	//Is Police:
	if(StrContains(GetOrgJob(Client), "Police", false) != -1)
 	{

		//Return:
		return true;
	}

	//Is Swat:
	if(StrContains(GetOrgJob(Client), "SWAT", false) != -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public float GetHunger(int Client)
{

	//Return:
	return Hunger[Client];
}

public void SetHunger(int Client, float Amount)
{

	//Initulize:
	Hunger[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Hunger = %f WHERE STEAMID = %i;", Hunger[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

char GetHungerString(Client)
{

	//Declare:
	char ShowHunger[32] = "null";
	float Amount = GetHunger(Client);

	//Not Hungry:
	if(Amount > 100.0)
	{

		//Initialize:
		ShowHunger = "Very Full";

		//Return:
		return ShowHunger;
	}

	//Not Hungry:
	if(Amount >= 70.0)
	{

		//Initialize:
		ShowHunger = "Not Hungry";
	}

	//A Little Hungry:
	else if(Amount >= 60.0)
	{

		//Initialize:
		ShowHunger = "A Little Hungry";

		//Return:
		return ShowHunger;
	}

	//Fairly Hungry:
	else if(Amount >= 45.0)
	{

		//Initialize:
		ShowHunger = "Fairly Hungry";

		//Return:
		return ShowHunger;
	}

	//Very Hungry:
	else if(Amount >= 30.0)
	{

		//Initialize:
		ShowHunger = "Very Hungry";

		//Return:
		return ShowHunger;
	}

	//Starving:
	else if(Amount >= 10.0)
	{

		//Initialize:
		ShowHunger = "Starving";

		//Return:
		return ShowHunger;
	}

	//Dieing of Hunger:
	else if(Amount < 10.0)
	{

		//Initialize:
		ShowHunger = "Dieing of Hunger";

		//Return:
		return ShowHunger;
	}

	//Return:
	return ShowHunger;
}

public int GetCopCuffs(int Client)
{

	//Return:
	return CopCuffs[Client];
}

public void SetCopCuffs(int Client, int Amount)
{

	//Initulize:
	CopCuffs[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE job SET CopCuffs = %i WHERE STEAMID = %i;", CopCuffs[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetCopMinutes(int Client)
{

	//Return:
	return CopMinutes[Client];
}

public void SetCopMinutes(int Client, int Amount)
{

	//Initulize:
	CopMinutes[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE jobs SET CopMinutes = %i WHERE STEAMID = %i;", CopMinutes[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetCopExperience(int Client)
{

	//Return:
	return CopExperience[Client];
}

public void SetCopExperience(int Client, int Amount)
{

	//Initulize:
	CopExperience[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE jobs SET CopExperience = %i WHERE STEAMID = %i;", CopExperience[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public void initEnergy(int Client)
{

	//Full Energy:
	if(GetEnergy(Client) < 100)
	{

		//Too Much Energy:
		if(GetEnergy(Client) + 25 > 100)
		{

			//Initulize:
			SetEnergy(Client, 100);
		}

		//Override:
		else
		{

			//Initulize:
			SetEnergy(Client, (GetEnergy(Client) + 25));
		}
	}
}

public void initDrugTick(int Client)
{

	//Check:
	if(GetDrugTick(Client) == 1)
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Timer:
		CreateTimer(0.0, backspeed, Client);
	}

	//Check:
	if(GetDrugTick(Client) > 0)
	{

		//Initulize:
		SetDrugTick(Client, (GetDrugTick(Client) - 1));
	}

	//Declare:
	int Random = GetRandomInt(1, 5);

	//Check:
	if(Random == 1)
	{

		//Check:
		if(GetDrugHealth(Client) > 1)
		{

			//Initulize:
			SetDrugHealth(Client, (GetDrugHealth(Client) - 1));
		}
	}
}

public void initCopMinutes(int Client)
{

	//Check:
	if(IsPlayerAlive(Client) && (IsCop(Client) || IsAdmin(Client)))
	{

		//Initulize:
		SetCopMinutes(Client, (GetCopMinutes(Client) + 1));
	}
}
