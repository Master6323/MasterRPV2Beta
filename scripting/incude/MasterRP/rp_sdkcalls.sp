//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_sdkcalls_included_
  #endinput
#endif
#define _rp_sdkcalls_included_

Handle hLeaveVehicle = INVALID_HANDLE;
Handle hGetInVehicle = INVALID_HANDLE;
Handle hSetObserverMode = INVALID_HANDLE;
Handle hSetAnimation = INVALID_HANDLE;
Handle hRespawn = INVALID_HANDLE;

enum PlayerObserver
{
	OBS_MODE_NONE = 0,	// not in spectator mode
	OBS_MODE_DEATHCAM,	// special mode for death cam animation
	OBS_MODE_FREEZECAM,	// zooms to a target, and freeze-frames on them
	OBS_MODE_FIXED,		// view from a fixed camera position
	OBS_MODE_IN_EYE,	// follow a player in first person view
	OBS_MODE_CHASE,		// follow a player in third person view
	OBS_MODE_ROAMING,	// free roaming
};

enum PlayerAnim
{
    PLAYER_IDLE = 0,
    PLAYER_WALK,
    PLAYER_JUMP,
    PLAYER_SUPERJUMP,
    PLAYER_DIE,
    PLAYER_ATTACK1,
    PLAYER_IN_VEHICLE,
    PLAYER_RELOAD,
    PLAYER_START_AIMING,
    PLAYER_LEAVE_AIMING
}

public void initSDKTools()
{

	//Test
	RegAdminCmd("sm_setobservermode", CommandSetObserverMode, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	//Declare:
	Handle GameData = LoadGameConfigFile("MasterRP");



	//Has Failed:
	if(GameData == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset File! 'sourcemod/gamedata/MasterRP.txt'");
	}

        // SDK Call
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(GameData, SDKConf_Virtual, "LeaveVehicle");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	hLeaveVehicle = EndPrepSDKCall();

	//Check:
	if(hLeaveVehicle == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'bool CBasePlayer::GetInVehicle( IServerVehicle *pVehicle, int nRole )'");
	}

        // SDK Call
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(GameData, SDKConf_Virtual, "GetInVehicle");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hGetInVehicle = EndPrepSDKCall();

	//Check:
	if(hGetInVehicle == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'bool CBasePlayer::GetInVehicle( IServerVehicle *pVehicle, int nRole )'");
	}

        // SDK Call:
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(GameData, SDKConf_Virtual, "SetObserverMode");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	hSetObserverMode = EndPrepSDKCall();

	//Check:
	if(hSetObserverMode == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'bool CBasePlayer::SetObserverMode( int )'");
	}

        // SDK Call:
	StartPrepSDKCall(SDKCall_Player);

	PrepSDKCall_SetFromConf(GameData, SDKConf_Virtual, "SetAnimation");

	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

	hSetAnimation = EndPrepSDKCall();

	//Check:
	if(hSetAnimation == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CHL2MP_Player::SetAnimation( PLAYER_ANIM playerAnim )'");
	}

        // SDK Call:
	StartPrepSDKCall(SDKCall_Player);

	PrepSDKCall_SetFromConf(GameData, SDKConf_Virtual, "Respawn");

	hRespawn = EndPrepSDKCall();

	//Check:
	if(hRespawn == INVALID_HANDLE)
	{

		//Fail State:
		SetFailState("[SM] ERROR: Missing offset 'void CBaseEntity::Respawn( void )'");
	}

	//Close:
	CloseHandle(GameData);

	//Fail State:
	PrintToServer("|RP| - SDKCall Successfully Loaded");
}

public void SetPlayerLeaveVehicle(int Client, float Origin[3], float ExitAngles[3])

{


	if(hLeaveVehicle == INVALID_HANDLE)
	{

		//Print:
		PrintToConsole(Client, "|RP| - Invalid");
	}

	//Initulize:
	SDKCall(hLeaveVehicle, Client, Origin, ExitAngles);


	//Print:
	PrintToConsole(Client, "|RP| - Leave Vehicle");
}

public bool ForceClientEnterVehicle(int Client, int Vehicle, int Role)

{


	if(hGetInVehicle == INVALID_HANDLE)
	{

		//Print:
		PrintToConsole(Client, "|RP| - Invalid");
	}

	//Print:
	PrintToConsole(Client, "|RP| - Force Enter Vehicle");

	//Initulize:
	return SDKCall(hGetInVehicle, Client, Vehicle, Role);

}

public void SetPlayerObserverMode(int Client, PlayerObserver Mode)

{


	if(hSetObserverMode == INVALID_HANDLE)
	{

		//Print:
		PrintToConsole(Client, "|RP| - Invalid");
	}

	//Initulize:
	SDKCall(hSetObserverMode, Client, Mode);


	//Declare:
	int ModeInt = IntToIntObserverType(Mode);

	//Print:
	PrintToConsole(Client, "|RP| - SetObserverMode %i", ModeInt);
}

public void SetPlayerAnimation(int Client, PlayerAnim Animation)

{


	//Initulize:
	SDKCall(hSetAnimation, Client, Animation);

}

public void ForceClientRespawn(int Client)

{


	//Initulize:
	SDKCall(hRespawn, Client);

}

public Action CommandSetObserverMode(int Client, int Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_setobservermode <0-6 Mode>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	char ObserverMode[32];

	//Initialize:
	GetCmdArg(1, ObserverMode, sizeof(ObserverMode));

	//Declare:
	PlayerObserver Mode = ObserverTypeToInt(StringToInt(ObserverMode));

	//SetOberverMode
	SetPlayerObserverMode(Client, Mode);

	//Return:
	return Plugin_Handled;
}

public PlayerObserver ObserverTypeToInt(int Mode)
{

	//Sort Through
	switch(Mode)
	{

		//OBS_MODE_NONE
		case 0:
		{
			return OBS_MODE_NONE;
		}
		case 1:
		{
			return OBS_MODE_DEATHCAM;
		}
		case 2:
		{
			return OBS_MODE_FREEZECAM;
		}
		case 3:
		{
			return OBS_MODE_FIXED;
		}
		case 4:
		{
			return OBS_MODE_IN_EYE;
		}
		case 5:
		{
			return OBS_MODE_CHASE;
		}
		case 6:
		{
			return OBS_MODE_ROAMING;
		}
	}

	//Return:
	return OBS_MODE_NONE;
}

public int IntToIntObserverType(PlayerObserver Mode)
{

	//Sort Through
	switch(Mode)
	{

		//OBS_MODE_NONE
		case OBS_MODE_NONE:
		{
			return 0;
		}
		case OBS_MODE_DEATHCAM:
		{
			return 1;
		}
		case OBS_MODE_FREEZECAM:
		{
			return 2;
		}
		case OBS_MODE_FIXED:
		{
			return 3;
		}
		case OBS_MODE_IN_EYE:
		{
			return 4;
		}
		case OBS_MODE_CHASE:
		{
			return 5;
		}
		case OBS_MODE_ROAMING:
		{
			return 6;
		}
	}

	//Return:
	return 0;
}
