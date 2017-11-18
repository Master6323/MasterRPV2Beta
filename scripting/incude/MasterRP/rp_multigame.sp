//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_multigame_included_
  #endinput
#endif
#define _rp_multigame_included_

/*This will seperate game functions*/
//#if defined HL2DM
//#endif

int Game = 0;
/*
//Valid Games:
enum GameType
{
	hDEFAULT = 0,
	hHL2DM = 1,
	hCSS = 2,
	hCSGO = 3,
	hTF2 = 4,
	hTF2BETA = 5,
	hL4D = 6,
	hL4D2 = 7,
}
*/
public initGameFolder()
{

	//Declare:
	decl String:GameDir[64];

	//Initulize:
	GetGameFolderName(GameDir, sizeof(GameDir));

	//Check:
	if(strcmp(GameDir, "hl2mp") == 0)
	{

		//Initulize:
		Game = 1;

		GameDir = "Half - Life 2: DeathMatch";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Check:
	else if(strcmp(GameDir, "cstrike") == 0)
	{

		//Initulize:
		Game = 2;

		GameDir = "Counter Strike: Source";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Check:
	else if(strcmp(GameDir, "csgo") == 0)
	{

		//Initulize:
		Game = 3;

		GameDir = "Counter Strike: Global Offence";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Check:
	else if(strcmp(GameDir, "tf") == 0)
	{

		//Initulize:
		Game = 4;

		GameDir = "Team Fordtress: 2";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Check:
	else if(strcmp(GameDir, "tf_beta") == 0)
	{

		//Initulize:
		Game = 5;

		GameDir = "Team Fordtress: 2 Beta";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Check:
	else if(strcmp(GameDir, "left4dead") == 0)
	{

		//Initulize:
		Game = 6;

		GameDir = "Left 4 Dead";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Check:
	else if(strcmp(GameDir, "left4dead2") == 0)
	{

		//Initulize:
		Game = 7;

		GameDir = "Left 4 Dead: 2";

		//Print:
		PrintToServer("|RP| - %s Roleplay Mod", GameDir);
	}

	//Override: // Default Game:
	else
	{

		//Initulize:
		Game = 0;

		//Print:
		PrintToServer("|RP| - Invalid Game Detected %s", GameDir);
	}
}

public int CheckL4DGameMode()
{

	//Declare:
	decl String:GameName[16];
	int GameMode = 0;

	//Initulize:
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));

	//Check:
	if (StrEqual(GameName, "survival", false))
	{

		//Initulize:
		GameMode = 3;
	}

	//Check:
	else if(StrEqual(GameName, "versus", false) || StrEqual(GameName, "teamversus", false) || StrEqual(GameName, "scavenge", false) || StrEqual(GameName, "teamscavenge", false))
	{

		//Initulize:
		GameMode = 2;
	}

	//Check:
	else if(StrEqual(GameName, "coop", false) || StrEqual(GameName, "realism", false))
	{

		//Initulize:
		GameMode = 1;
	}

	//Override:
	else
	{

		//Initulize:
		GameMode = 0;
 	}

	//Return:
	return GameMode;
}
public int GetGame()
{

	//Return:
	return Game;
}