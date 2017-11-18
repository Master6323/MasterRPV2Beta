//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_crime_included_
  #endinput
#endif
#define _rp_crime_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define BOUNTYCRIME 		20
#define BOUNTYSTART 		20000

//Crime system:
int Crime[MAXPLAYERS + 1] = {0,...};
int Bounty[MAXPLAYERS + 1] = {0,...};
bool AutoBounty[MAXPLAYERS + 1] = {false,...};

public void initCrime()
{

	//Player Stats Manangement:
	RegAdminCmd("sm_setcrime", Command_SetCrime, ADMFLAG_SLAY, "<Name> <Crime #> - Sets crime");
}

public Action initCrimeTimer(int Client)
{

	//Enough Crime:
	if(Crime[Client] > BOUNTYSTART && !IsCop(Client))
	{

		//Declare:
		int CrimeToBounty = (Crime[Client] / BOUNTYCRIME);

		//Bounty:
		if(Bounty[Client] < CrimeToBounty)
		{

			//Add Bounty:
			AddBounty(Client, CrimeToBounty);

			//Initialize:
			AutoBounty[Client] = true;
		}
	}

	//Enough Crime For Bounty:
	else if(Crime[Client] <= BOUNTYSTART && AutoBounty[Client])
	{

		//Add Bounty:
 		AddBounty(Client, 0);
	}

	//Has Crime:
	if(Crime[Client] > 0)
	{

		//Initialize:
		Crime[Client] -= GetRandomInt(1, 4);
	}
}

public void AddBounty(int Client, int SetBounty)
{

	//Declare:
	float Pos[2] = {-1.0, 0.015};
	int Color[4];

	//Initulize:
	Color[0] = 255;
	Color[1] = 255;
	Color[2] = 255;
	Color[3] = 255;

	//Declare:
	char FormatMessage[256];

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
		{

			//Enouth Bounty: 
			if(SetBounty != 0)
			{

				//Format:
				Format(FormatMessage, sizeof(FormatMessage), "%N now has a bounty of €%i on his head", Client, SetBounty);

				//Check:
				if(GetGame() == 2 || GetGame() == 3)
				{

					//Show Hud Text:
					CSGOShowHudTextEx(Client, 4, Pos, Color, Color, 5.0, 0, 6.0, 0.1, 0.2, FormatMessage);
				}

				//Override:
				else
				{

					//Show Hud Text:
					ShowHudTextEx(Client, 4, Pos, Color, 5.0, 0, 6.0, 0.1, 0.2, FormatMessage);
				}
			}
		}
	}

	//Override:
	if(SetBounty != 0)
	{

		//Show Hud Text:
		ShowHudText(Client, 4, "A bounty of €%i is set on your head! If you die you'll go to jail!", SetBounty);

		//Check:
		if(GetGame() == 2 || GetGame() == 3)
		{

			//Show Hud Text:
			CSGOShowHudTextEx(Client, 4, Pos, Color, Color, 5.0, 0, 6.0, 0.1, 0.2, FormatMessage);
		}

		//Override:
		else
		{

			//Show Hud Text:
			ShowHudTextEx(Client, 4, Pos, Color, 5.0, 0, 6.0, 0.1, 0.2, FormatMessage);
		}
	}


	//Initialize:
	Bounty[Client] = SetBounty;
}

public void OnClientDiedCheckBounty(int Client, int Attacker)
{

	//Is Actual Player:
	if(Attacker != Client && Attacker != 0 && Attacker > 0 && Attacker < GetMaxClients())
	{

		//Has Bounty:
		if(GetBounty(Client) > 0)
		{    

			//Setup Hud:
			SetHudTextParams(-1.0, 0.015, 5.0, 250, 250, 250, 200, 0, 6.0, 0.1, 0.2);

			//Loop:
			for(int i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{ 

					//Show Hud Text:
					ShowHudText(i, 4, "%N Bounty Has Been Caught!!!", Client);
				}
			}

			//Declare:
			int AddCash = 0;

			//Is Cop:
			if(IsCop(Attacker))
			{

				//Initialize:
	            		AddCash = GetBounty(Client) / 3;
			}

			//Override:
			else
			{

				//Initialize:
	            		AddCash = GetBounty(Client);
			}

			//Cuff Client:
			Cuff(Client);

			//Get Jail Time:
			CalculateJail(Client);

			//Set Menu State:
			CashState(Attacker, AddCash);

			//Initialize:
            		SetCash(Attacker, (GetCash(Client) + AddCash));

			SetCrime(Client, 0);

			SetBounty(Client, 0);

			//Initialize:
			AutoBounty[Client] = false;
		}
	}
}

//Crime:
public Action Command_SetCrime(int Client, int Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setcrime <Name> <Crime #>");

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

	//Action:
	SetCrime(Player, iAmount);

	//Is Valid:
	if(Crime[Client] > 500) SetClientScore(Client, RoundToNearest(Crime[Client] / 1000.0));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%N\x07FFFFFF's crime to \x0732CD32%i", Player, iAmount);

	//Not Client:
	if(Client != Player) CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF set your crime to \x0732CD32%i", Client, iAmount);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the crime of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

public int GetCrime(int Client)
{

	//Return:
	return Crime[Client];
}

public void SetCrime(int Client, int Amount)
{

	//Initulize:
	Crime[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Crime = %i WHERE STEAMID = %i;", Crime[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetBounty(int Client)
{

	//Return:
	return Bounty[Client];
}

public void SetBounty(int Client, int Amount)
{

	//Initulize:
	Bounty[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		char query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Bounty = %i WHERE STEAMID = %i;", Bounty[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public int GetGlobalCrime()
{

	//Declare:
	int GlobalCrime = 0;

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Initulize:
			GlobalCrime += Crime[i];
		}
	}

	//Return:
	return GlobalCrime;
}
