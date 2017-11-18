//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/* Double-include prevention */
#if defined _rp_stock_included_
  #endinput
#endif
#define _rp_stock_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Variable:
float GameTime[MAXPLAYERS + 1] = {0.0,...};
float lastKilled[MAXPLAYERS + 1] = {0.0,...};
float LastPressedE[MAXPLAYERS + 1] = {0.0,...};
float LastPressedSH[MAXPLAYERS + 1] = {0.0,...};
bool Wearables[MAXPLAYERS + 1] = {false,...};
bool ThirdPerson[MAXPLAYERS + 1] = {false,...};
bool CommandOverride[MAXPLAYERS + 1] = {false,...};
int MenuTarget[MAXPLAYERS + 1] = {0,...};

int ClientFrom;
int WaterCache;
int LaserCache;
int SpriteCache;
int ExplodeCache1;
int ExplodeCache2;
int SmokeCache1;
int SmokeCache2;
int GlowBlueCache;
int CollisionOffset;
int BloodCache;
int BloodDropCache;

UserMsg FadeID;
UserMsg ShakeID;

public void initStock()
{
#if defined HL2DM
	//Chat Hooks: used to block team chat message
	HookUserMessage(GetUserMessageId("SayText2"), UserMessageHook, true);

	HookUserMessage(GetUserMessageId("SayText"), UserMessageHook, true);

	HookUserMessage(GetUserMessageId("TextMsg"), UserMessageHook, true);
#endif
	//Command Listener:
	AddCommandListener(DisableCommand, "cl_playermodel");

	AddCommandListener(DisableCommand, "cl_spec_mode");

	AddCommandListener(DisableCommand, "spectate");

	AddCommandListener(DisableCommand, "jointeam");

	AddCommandListener(DisableCommand, "cl_class");

	AddCommandListener(DisableCommand, "cl_team");

	AddCommandListener(DisableCommand, "explode");

	AddCommandListener(HandleKill, "kill");

	AddCommandListener(HandleCommand, "attack");

	AddCommandListener(HandleCommand, "speed");

	AddCommandListener(HandleCommand, "use");

	RegConsoleCmd("sm_hidewearables", Command_HideWearables);

	RegConsoleCmd("sm_viewwearables", Command_ShowWearables);

	RegConsoleCmd("sm_firstperson", Command_FirstPerson);

	RegConsoleCmd("sm_thirdperson", Command_ThirdPerson);

	RegConsoleCmd("sm_resetview", Command_ResetView);

	RegConsoleCmd("sm_runtime", Command_RunTime);

	RegConsoleCmd("runtime", Command_RunTime);

	RegConsoleCmd("sm_admins", Command_ViewOnlineAdmins);

	//User Messages:
	FadeID = GetUserMessageId("Fade");

	ShakeID = GetUserMessageId("Shake");
}

public void initStockCache()
{

	//Precache Material:
	LaserCache = PrecacheModel("materials/sprites/laserbeam.vmt", true);

	SpriteCache = PrecacheModel("materials/sprites/halo01.vmt", true);

	ExplodeCache1 = PrecacheModel("sprites/sprite_fire01.vmt", true);

	ExplodeCache2 = PrecacheModel("materials/sprites/sprite_fire01.vmt");

	SmokeCache1 = PrecacheModel("materials/effects/fire_cloud1.vmt",true);

	SmokeCache2 = PrecacheModel("materials/effects/fire_cloud2.vmt",true);

	GlowBlueCache = PrecacheModel("materials/sprites/blueglow2.vmt", true);

	WaterCache = PrecacheModel("materials/sprites/blueglow2.vmt", true);

	BloodCache = PrecacheModel("materials/blood_zombie_split_spray.vmt", true);

	BloodDropCache = PrecacheModel("materials/blood_impact_red_01_droplets.vmt", true);

	//Find Offsets:
	CollisionOffset = FindSendPropInfo("CBasePlayer", "m_CollisionGroup");
}

public void OnRootAdminConnect(Client)
{

	//Define:
	int Flags = GetUserFlagBits(Client);

	//Has Root:
	if(Flags == ADMFLAG_ROOT)
	{

		//Declare:
		int Effect = CreateEnvStarField(Client, "null", 2.0);

		//Timer:
		CreateTimer(5.0, RemoveStarFieldAdminConnect, Effect);
	}	
}

public Action RemoveStarFieldAdminConnect(Handle Timer, any Ent)
{

	//Connected:
	if(IsValidEdict(Ent))
	{

		//Accept:
		AcceptEntityInput(Ent, "kill");
	}
}

public void OverflowMessage(int Client, const char[] Contents)
{

	//Is In Time:
	if(GameTime[Client] <= (GetGameTime() - 5))
	{

		//Print:
		CPrintToChat(Client, Contents);

		//Initialize:
		GameTime[Client] = GetGameTime();
	}
}

public bool IsAdmin(Client)
{

	//Declare:
	AdminId adminId = GetUserAdmin(Client);

	//Is Valid Admin:
	if(adminId == INVALID_ADMIN_ID)
	{

		//Return:
		return false;
	}

	//Return:
	return GetAdminFlag(adminId, Admin_Generic);
}

public void SetEntityClassName(int Entity, const char[] ClassName)
{

	//Set Prop ClassName
	SetEntPropString(Entity, Prop_Data, "m_iClassname", ClassName);
}

public bool IsInDistance(int Ent1, int Ent2)
{

	//Declare:
	float ClientOrigin[3];
	float EntOrigin[3];

	//Initialize:
	GetEntPropVector(Ent1, Prop_Send, "m_vecOrigin", ClientOrigin);

	GetEntPropVector(Ent2, Prop_Send, "m_vecOrigin", EntOrigin);

	//Declare:
	float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

	//In Distance:
	if(Dist <= 150)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public void PrintEscapeText(int Client, const char[] text, any:...)
{

	//Declare:
	char message[1024];

	//Format:
	VFormat(message, sizeof(message), text, 3);

	//Handle:
	Handle kv = CreateKeyValues("Message", "Title", message);

	//Set Color:
	KvSetColor(kv, "color", 50, 250, 50, 255);

	//Set Number:
	KvSetNum(kv, "level", 1);

	//Set Float:
	KvSetFloat(kv, "time", 1.5);

	//Show Menu:
	CreateDialog(Client, kv, DialogType_Text);

	//Close:
	CloseHandle(kv);
}

//Covert To String:
public int SteamIdToInt(int Client)
{

	//Check:
	if(!IsClientConnected(Client)) return -1;

	//Declare:
	char SteamId[32];

	//Initulize:
	GetClientAuthId(Client, AuthId_Steam3, SteamId, 32);

	//Declare:
	char subinfo[3][16];

	//Explode:
	ExplodeString(SteamId, ":", subinfo, sizeof(subinfo), sizeof(subinfo[]));

	//Initulize:
	int Intiger = StringToInt(subinfo[2], 10);

	if(StrEqual(subinfo[1], "1"))
	{

		//Initulize:
		Intiger *= -1;
	}

	//Return:
	return Intiger;
}

//Return Money:
char IntToMoney(int Intiger)
{

	//Declare:
	int slen;
	int Pointer;
	bool negative;
	char IntStr[32];
	char Result[128];

	//Initulize:
	negative = Intiger < 0;

	//Is Valid:
	if(negative)
	{

		//Initulize:
		Intiger *= -1;
	}

	//Convert:
	IntToString(Intiger, IntStr, sizeof(IntStr));

	//Initulize:
	slen = strlen(IntStr);
	Intiger = slen % 3;

	//Is Valid:
	if(Intiger == 0)
	{

		//Initulize:
		Intiger = 3;
	}

	//Format:
	Format(Result, Intiger + 1, "%s", IntStr);

	//Initulize:
	slen -= Intiger;
	Pointer = Intiger + 1;

	//Loop:
	for(new i = Intiger; i <= slen ; i += 3)
	{

		//Initulize:
		Pointer += 4;

		//Format:
		Format(Result, Pointer, "%s,%s",Result, IntStr[i]);
	}

	//Is Valid:
	if(negative)
	{

		//Initulize:
		Format(Result, sizeof(Result), "â‚¬-%s", Result);
	}

	//Override:
	else
	{

		//Initulize:
		Format(Result, sizeof(Result), "â‚¬%s", Result);
	}

	//Return:
	return Result;
}

//Bipass Cheats:
public void CheatCommand(int Client, char command[255], char arguments[255])
{

	//Define:
	int admindata = GetUserFlagBits(Client);

	//Set Client Flag Bits:
	SetUserFlagBits(Client, ADMFLAG_ROOT);

	//Define:
	int flags = GetCommandFlags(command);

	//Set Client Flags:
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);

	//Command:
	ClientCommand(Client, "\"%s\" \"%s\"", command, arguments);

	//Set Client Flags:
	SetCommandFlags(command, flags);

	//Set Client Flag Bits:
	SetUserFlagBits(Client, admindata);
}

public Action DisableCommand(int Client, const char[] Command, int Argc)
{

	//Is Override:
	if(CommandOverride[Client] == true)
	{

		//Return:
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}
#if defined HL2DM
public Action UserMessageHook(UserMsg MsgId, Handle hBitBuffer, const iPlayers[], int iNumPlayers, bool bReliable, bool bInit)
{

	//Get Info:
	BfReadByte(hBitBuffer);

	BfReadByte(hBitBuffer);

	//Declare:
	char strMessage[1024];

	//Read UserMessage
	BfReadString(hBitBuffer, strMessage, sizeof(strMessage));

	//Check:
	if(StrContains(strMessage, "before trying to switch", false) != -1)
	{

		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}
#endif
public Action HandleKill(int Client, const char[] Command, int Argc)
{

	//Is In Time::
	if(lastKilled[Client] < (GetGameTime() - 60))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you will die in 10 seconds!");

		//Timer:
		CreateTimer(10.0, KillPlayer, Client);

		//Initulize:
		lastKilled[Client] = GetGameTime();
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use this command too often!");
	}

	//Return:
	return Plugin_Handled;
}

//Spawn Timer:
public Action KillPlayer(Handle Timer, any Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Slay Client:
		ForcePlayerSuicide(Client);
	}
}

public Action HandleCommand(int Client, const char[] Command, int Argc)
{

	//Is Valid:
	if(!IsCuffed(Client))
	{

		//Return::
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}

public int CheckMapEntityCount()
{

	//Declare:
	int Amount = 0;

	//Loop:
	for(int i = 0; i <= 2047; i++)
	{

		//Is Valid:
		if(IsValidEdict(i) || IsValidEntity(i) || i == 0)
		{

			//Initialize:
			Amount++;
		}
	}

	//Return:
	return Amount;
}

public bool TraceEntityFilterPlayer(int Entity, int ContentsMask)
{

	//Return:
	return Entity != ClientFrom;
}

public bool TraceEntityFilterEntity(int Entity, int ContentsMask, any Data)
{

	//Return:
	return Entity > 0 && Entity != ClientFrom && Data != Entity;
}

public bool TraceEntityFilterWall(int Entity, int ContentsMask)
{

	//Return:
	return !Entity;
}

public bool LookingAtWall(int Client)
{

	//Declare:
	float Origin[3];
	float Angles[3];
	float EndPos[3];

	//Initialize:
	GetClientEyePosition(Client, Origin);

	GetClientEyeAngles(Client, Angles);

	//Declare:
	float dist1 = 0.0;
	float dist2 = 0.0;

	ClientFrom = Client;

	//Handle:
	Handle Trace1 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterEntity, Client);

	//Is Tracer
	if(TR_DidHit(Trace1))
	{

		//Get Vector:
		TR_GetEndPosition(EndPos, Trace1);

		//Initialize:
		dist1 = GetVectorDistance(Origin, EndPos);
	}

	//Override:
	else
	{

		//Initialize:
		dist1 = -1.0;
	}

	//Close:
	CloseHandle(Trace1);

	//Handle:
	Handle Trace2 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterWall);
   	 	
	//Is Tracer
	if(TR_DidHit(Trace2))
	{

		//Get Vector:
		TR_GetEndPosition(EndPos, Trace2);

		//Initialize:
		dist2 = GetVectorDistance(Origin, EndPos);
	}

	//Override:
	else
	{

		//Initialize:
		dist2 = -1.0;
	}

	//Close:
	CloseHandle(Trace2);

	//Initialize:
	ClientFrom = -1;

	//Initialize:
	if(dist1 >= dist2)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public bool IsTargetInLineOfSight(int Subject, int Target)
{

	//Declare:
	float Position[3];
	float TargetPos[3];
	float EndPos[3];

	//Initulize:
	GetEntPropVector(Subject, Prop_Send, "m_vecOrigin", Position);
	GetEntPropVector(Target, Prop_Send, "m_vecOrigin", TargetPos);

	Position[2] + 20.0;
	TargetPos[2] + 20.0;

	ClientFrom = Subject;

	//Declare:
	float dist1 = 0.0;

	//Set Up Trace:
	Handle Trace = TR_TraceRayFilterEx(Position, TargetPos, MASK_SHOT, RayType_EndPoint, TraceEntityFilterEntity, Target);

	//Is Tracer
	if(TR_DidHit(Trace))
	{

		//Get Vector:
		TR_GetEndPosition(EndPos, Trace);

		//Initialize:
		dist1 = GetVectorDistance(TargetPos, EndPos);
	}

	//Override
	else
	{

		//Initialize:
		dist1 = -1.0;
	}

	//Close:
	CloseHandle(Trace);

	//Initialize:
	ClientFrom = -1;

	//Initialize:
	if(dist1 > 0)
	{

		//Return:
		return false;
	}

	//Return:
	return true;
}

public bool GetCollisionPoint(int Client, float Pos[3])
{

	//Declare:
	float vOrigin[3];
	float vAngles[3];

	//Initulize:
	GetClientEyePosition(Client, vOrigin);

	GetClientEyeAngles(Client, vAngles);

	ClientFrom = Client;

	//Handle:
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Get Ent:
		TR_GetEndPosition(Pos, trace);

		//Close:
		CloseHandle(trace);

		//Return:
		return true;
	}

	//Close:
	CloseHandle(trace);

	//Return:
	return false;
}

public void GetAngleBetweenEntities(int Ent, int OtherEnt, float Angles[3])
{

	//Declare:
	float Origin[3];
	float OtherOrigin[3];
	float Buffer[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

	GetEntPropVector(OtherEnt, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Loop:
	for(int X = 0; X <= 2; X++)
	{

		//Initulize:
		Buffer[X] = FloatSub(Origin[X], OtherOrigin[X]);
	}

	//Normal:
	NormalizeVector(Buffer, Buffer);

	//Get Angles:
	GetVectorAngles(Buffer, Angles);
}


public void GetPullBetweenEntities(int Ent, int OtherEnt, float Scale, float Pull[3])
{

	//Declare:
	float Origin[3];
	float OtherOrigin[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

	GetEntPropVector(OtherEnt, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Caclulate:
	Pull[0] = (FloatMul(Scale, (FloatSub(Origin[0], OtherOrigin[0]))));

    	Pull[1] = (FloatMul(Scale, (FloatSub(Origin[1], OtherOrigin[1]))));

    	Pull[2] = -25.0;
}

public void GetPushBetweenEntities(int Ent, float Scale, float Push[3])
{

	//Declare:
	float EyeAngles[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", EyeAngles);

	//Caclulate:
	Push[0] = (FloatMul(Scale, Cosine(DegToRad(EyeAngles[1]))));

    	Push[1] = (FloatMul(Scale, Sine(DegToRad(EyeAngles[1]))));

    	Push[2] = (FloatMul((Scale / 10.0), Sine(DegToRad(EyeAngles[0]))));
}

public void GetInFrontEntities(int Ent, float Scale, float AngleOffset[3], float NewPosition[3])
{

	//Declare:
	float Angles[3] = {0.0, 0.0, 0.0};
	float Offset[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	Angles[0] += AngleOffset[0];
	Angles[1] += AngleOffset[1];
	Angles[2] += AngleOffset[2];

	//Caclulate:
	Offset[0] = (FloatMul(Scale, Cosine(DegToRad(Angles[1]))));

	Offset[1] = (FloatMul(Scale, Sine(DegToRad(Angles[1]))));

	Offset[2] = (FloatMul((Scale / 10), Sine(DegToRad(Angles[0]))));

	//Initulize:
	float Origin[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	//Add Vectors Safely
	AddVectors(Origin, Offset, NewPosition);
}

public void LoadString(Handle Vault, char Key[32], char SaveKey[255], char DefaultValue[255], char Reference[255])
{

	//Skip:
	KvJumpToKey(Vault, Key, false);

	//Get KV:
	KvGetString(Vault, SaveKey, Reference, sizeof(Reference), DefaultValue);

	//Restart KV:
	KvRewind(Vault);
}

public void SaveString(Handle Vault, const char[] Key, const char[] SaveKey, const char[] Variable)
{

	//Skip:
	KvJumpToKey(Vault, Key, true);

	//Set KV:
	KvSetString(Vault, SaveKey, Variable);

	//Restart KV:
	KvRewind(Vault);
}

public int LoadInteger(Handle Vault, const char[] Key, const char[] SaveKey, int DefaultValue)
{

	//Skip:
	KvJumpToKey(Vault, Key, false);

	//Get KV:
	int Variable = KvGetNum(Vault, SaveKey, DefaultValue);

	//Restart KV:
	KvRewind(Vault);

	//Return:
	return Variable;
}

public void PerformBlind(Client, int Amount)
{

	//Declare
	int SendClient[2];

	SendClient[0] = Client;

	//Handle:
	Handle Message = StartMessageEx(FadeID, SendClient, 1);

	//Declare:
	int Color[4] = {0, 0, 0, 255};

	//Initulize:
	Color[3] = Amount;

	//Multi-Game:
	if (GetUserMessageType() == UM_Protobuf)
	{

		//Set:
		PbSetInt(Message, "duration", 9000);
		PbSetInt(Message, "hold_time", 9000);

		//Check:
		if(Amount == 0)
		{

			//Set:
			PbSetInt(Message, "flags", (0x0001 | 0x0010));
		}

		//Override:
		else
		{

			//Set:
			PbSetInt(Message, "flags", (0x0002 | 0x0008));
		}

		//Set:
		PbSetColor(Message, "clr", Color);
	}

	//Override:
	else
	{

		//Set:
		BfWriteShort(Message, 9000);

		BfWriteShort(Message, 9000);

		//Check:
		if(Amount == 0)
		{

			//Out and Stayout
			BfWriteShort(Message, (0x0001 | 0x0010));
		}

		//Override:
		else
		{

			//Out and Stayout
			BfWriteShort(Message, (0x0002 | 0x0008));
		}

			//Write Handle:
		BfWriteByte(Message, 0);

		BfWriteByte(Message, 0);

		BfWriteByte(Message, 0);

		//Alpha
		BfWriteByte(Message, Amount);
	}

	//Cloose:
	EndMessage();
}

public void PerformUnBlind(int Client)
{

	//Declare
	int SendClient[2];

	SendClient[0] = Client;

	//Handle:
	Handle Message = StartMessageEx(FadeID, SendClient, 1);

	//Declare:
	int Color[4] = {0, 0, 0, 0};

	//Multi-Game:
	if(GetUserMessageType() == UM_Protobuf)
	{

		//Set:
		PbSetInt(Message, "duration", 15);
		PbSetInt(Message, "hold_time", 0);

		//Set:
		PbSetInt(Message, "flags", (0x0001 | 0x0010));

		//Set:
		PbSetColor(Message, "clr", Color);
	}

	//Override:
	else
	{

		//Set:
		BfWriteShort(Message, 9000);

		BfWriteShort(Message, 9000);

		//Out and Stayout
		BfWriteShort(Message, (0x0001 | 0x0010));

		//Set:
		BfWriteByte(Message, Color[0]);

		BfWriteByte(Message, Color[1]);

		BfWriteByte(Message, Color[2]);

		BfWriteByte(Message, Color[3]);
	}

	//Cloose:
	EndMessage();
}

//shake effect
public Action ShakeClient(int Client, float Length, float Severity)
{

	//Conntected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		int SendClient[2];
		SendClient[0] = Client;

		//Handle:
		Handle Message = StartMessageEx(ShakeID, SendClient, 1);

		//Multi-Game:
		if(GetUserMessageType() == UM_Protobuf)
		{

			//Set:
			PbSetInt(Message, "command", 0);

			PbSetFloat(Message, "local_amplitude", Severity);

			PbSetFloat(Message, "frequency", 10.0);

			PbSetFloat(Message, "duration", Length);
		}

		//Override:
		else
		{

			//Set:
			BfWriteByte(Message, 0);

			BfWriteFloat(Message, Severity);

			BfWriteFloat(Message, 10.0);

			BfWriteFloat(Message, Length);
		}

		//Close:
		EndMessage();
	}
}

public float GetBlastDamage(float Dist)
{

	//Declare:
	float Damage = 0.0;

	//Get Damage:
	if(Dist >= 0.0 <= 25.0) Damage = 250.0;
	if(Dist >= 26.0 <= 50.0) Damage = 200.0;
	if(Dist >= 51.0 <= 75.0) Damage = 175.0;
	if(Dist >= 76.0 <= 100.0) Damage = 122.0;
	if(Dist >= 101.0 <= 150.0) Damage = 71.0;
	if(Dist >= 151.0 <= 200.0) Damage = 45.0;
	if(Dist >= 201.0 <= 250.0) Damage = 10.0;

	//Return:
	return Damage;
}

//Show Player Hud
public void ResetClientOverlay(int Client)
{

	//Command:
	CheatCommand(Client, "r_screenoverlay", "0");
}

public int GetCollisionOffset()
{

	//Return:
	return CollisionOffset;
}

public void HideHud(int Client, int Type)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Send, "m_iHideHUD", Type);
}

public void SetEntityArmor(int Client, int Armor)
{

	//Initialize:
	SetEntProp(Client, Prop_Data, "m_ArmorValue", Armor, 4);
}

public int GetClientScore(int Client)
{

	//Return:
	return GetEntProp(Client, Prop_Data, "m_iFrags");
}

public void SetClientScore(int Client, int Score)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Data, "m_iFrags", Score);
}

public void SetClientDeath(int Client, int Death)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Data, "m_iDeaths", Death); 
}

public int GetEntHealth(int Ent)
{

	//Return:
	return GetEntProp(Ent, Prop_Data, "m_iHealth");
}

public void SetEntHealth(int Ent, int Health)
{

	//Return:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);
}

public int GetEntMaxHealth(int Ent)
{

	//Return:
	return GetEntProp(Ent, Prop_Data, "m_iMaxHealth");
}

public void SetEntMaxHealth(int Ent, int Health)
{

	//Return:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);
}

public void SetEntitySpeed(int Client, float fSpeed)
{

	//Set Prop Data:
	SetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue", fSpeed);	
}

public int GetClientTeamEx(Client)
{

	//Get Client Team:
	int m_iTeamNum = FindSendPropInfo("CBasePlayer", "m_iTeamNum");

	//Return:
	return m_iTeamNum;
}

public void ChangeClientTeamEx(int Client, int Team)
{

	//Get Client Team:
	int m_iTeamNum = FindSendPropInfo("CBasePlayer", "m_iTeamNum");

	//Set Prop Data:
	SetEntData(Client, m_iTeamNum, Team);
}

public int GetClientMoveCollide(int Client)
{

	//Get Client Team:
	int MoveCollide = FindSendPropInfo("CBaseEntity", "movecollide");

	//Return:
	return GetEntData(Client, MoveCollide);
}

public void SetClientMoveCollide(int Client, int Collide)
{

	//Get Client Team:
	int MoveCollide = FindSendPropInfo("CBaseEntity", "movecollide");

	//Set Ent Data:
	SetEntData(Client, MoveCollide, Collide);
}

public int GetClientMoveType(int Client)
{

	//Get Client Team:
	int movetype = FindSendPropInfo("CBaseEntity", "movetype");

	//Return:
	return GetEntData(Client, movetype);
}

public void SetClientMoveType(int Client, int Type)
{

	//Get Client Team:
	int movetype = FindSendPropInfo("CBaseEntity", "movetype");

	//Set Ent Data:
	SetEntData(Client, movetype, Type);
}

public void GetEntityvecVelocity(int Entity, float vecVelocity[3])
{

	//Get Ent Data:
	GetEntPropVector(Entity, Prop_Data, "m_vecVelocity", vecVelocity);
}

char ServerMap()
{

	//Declare:
	char Map[64];

	//Initialize:
	GetCurrentMap(Map, sizeof(Map));

	//Return
	return Map;
}

public float GetLastPressedE(int Client)
{

	//Return:
	return LastPressedE[Client];
}

public void SetLastPressedE(int Client, float Time)
{

	//Initulize:
	LastPressedE[Client] = Time;
}

public float GetLastPressedSH(int Client)
{

	//Return:
	return LastPressedE[Client];
}

public void SetLastPressedSH(int Client, float Time)
{

	//Initulize:
	LastPressedSH[Client] = Time;
}

public void SetMaxSpeed(int Client, float Speed)

{



	//Declare:

	int SpeedOffset = FindSendPropInfo(GetCPlayer(), "m_flMaxspeed");



	//Set Speed:

	if(SpeedOffset > 0) SetEntData(Client, SpeedOffset, Speed, 4, true);

}

public int GetClientActiveDevices(int Client)
{

	//Return:
	return GetEntProp(Client, Prop_Send, "m_bitsActiveDevices");
}

public int RemoveClientActiveDevices(int Client, int ActiveDevice)
{

	//Initulize:
	SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", GetClientActiveDevices(Client) & ~ActiveDevice);
}

public int SetClientActiveDevices(int Client, int ActiveDevice)
{

	//Initulize:
	SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", ActiveDevice);
}

public int AddClientActiveDevices(int Client, int ActiveDevice)
{

	//Initulize:
	SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", (GetClientActiveDevices(Client) | ActiveDevice));
}

//Cache Natives:
public int Laser()
{

	//Return:
	return LaserCache;
}

public int Sprite()
{

	//Return:
	return SpriteCache;
}
public int Explode()
{

	//Return:
	return ExplodeCache1;
}

public int ExplodeNew()
{

	//Return:
	return ExplodeCache2;
}

public int Smoke()
{

	//Return:
	return SmokeCache1;
}

public int SmokeNew()
{

	//Return:
	return SmokeCache2;
}

public int GlowBlue()
{

	//Return:
	return GlowBlueCache;
}

public int Water()
{

	//Return:
	return WaterCache;
}

public int BloodEffect()
{

	//Return:
	return BloodCache;
}

public int BloodDropEffect()
{

	//Return:
	return BloodDropCache;
}

public int GetObserverMode(int Client)
{

	//Return:
	return GetEntProp(Client, Prop_Send, "m_iObserverMode");
}

public int GetObserverTarget(int Client)
{

	//Return:
	return GetEntProp(Client, Prop_Send, "m_hObserverTarget");
}

public Action Command_HideWearables(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Wearables[Client])
	{

		//Initulize:
		Wearables[Client] = false;

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled Your Wearables!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled your Wearables!");
	}


	//Return:
	return Plugin_Handled;
}

public Action Command_ShowWearables(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!Wearables[Client])
	{

		//Initulize:
		Wearables[Client] = true;

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled Your Wearables!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled your Wearables!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_FirstPerson(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(ThirdPerson[Client])
	{

		//Initulize:
		ThirdPerson[Client] = false;

		//Send:
		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", -1);
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 1);
		SetEntProp(Client, Prop_Send, "m_iFOV", 90);

		//Declare:
		char valor[6];

		//Get Server ConVar Value:
		GetConVarString(GetForceCameraConVar(), valor, 6);

		//Send Client ConVar:
		SendConVarValue(Client, GetForceCameraConVar(), valor);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled FirstPerson!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled FirstPerson!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_ThirdPerson(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!ThirdPerson[Client])
	{

		//Initulize:
		ThirdPerson[Client] = true;

		//Send:
		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", Client);
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 5);
		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 0);
		SetEntProp(Client, Prop_Send, "m_iFOV", 90);

		//Send Client ConVar:
		SendConVarValue(Client, GetForceCameraConVar(), "1");

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Toggled ThirdPerson!");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already Toggled ThirdPerson!");
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_ResetView(int Client, int Args)
{

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Reset View!");

	RemoveObserverView(Client);

	//Return:
	return Plugin_Handled;
}

public Action Command_RunTime(int Client, int Args)
{

	//Declare:
	int iSeconds = (GetRunTime() / 10);

	int iMinutes = (iSeconds / 60);

	int iHours = (((iSeconds / 10) / 60) / 60);

	//Declare:
	int iDays = 0;

	//Check:
	if(iMinutes > 60 * 24)
	{

		//Initulize:
		iDays = (iMinutes / (60 * 24));
	}

	//Declare:
	int iMinutesEx = (iSeconds % 60);

	//Has Days:
	if(iDays != 0)
	{

		//Initialize:
		int iHoursEx = iHours - (iDays * 24);

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i days, %i hours and %i minutes.", iDays, iHoursEx, iMinutesEx);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i days, %i hours and %i minutes.", iDays, iHoursEx, iMinutesEx);
		}
	}

	//Has Hours:
	else if(iMinutes > 60)
	{

		//Declare:
		int iHoursEx = (iMinutes % 60);

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i hours and %i minutes.", iHoursEx, iMinutesEx);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i hours and %i minutes.", iHoursEx, iMinutesEx);
		}
	}

	//Has Minutes:
	else if(iSeconds > 60)
	{

		//Declare:
		int iSecondsEx = (iSeconds % 60);

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i minutes and %i seconds.", iMinutes, iSecondsEx);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i minutes and %i seconds.", iMinutes, iSecondsEx);
		}
	}

	//Override:
	else
	{

		//Is Colsole:
		if(Client == 0)
		{

			//Print:
			PrintToServer("|RP| - Server has been running for %i seconds.", iSeconds);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Server has been running for %i seconds.", iSeconds);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action Command_ViewOnlineAdmins(int Client, int Args)
{

	//Declare:
	bool Result = false;

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Admin Check:
			if(IsAdmin(i))
			{

				//Initulize:
				Result = true;
			}
		}
	}

	//Admins Online:
	if(Result == true)
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Define:
				int Flags = GetUserFlagBits(i);

				//Has Root:
				if(Flags == ADMFLAG_ROOT)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - %N is a Root Admin.", i);
				}

				//Has Advanced Admin:
				else if(Flags == ADMFLAG_BAN)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - %N is a Advanced Admin.", i);
				}

				//Has Basic Admin:
				else if(Flags == ADMFLAG_SLAY)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - %N is a Basic Admin.", i);
				}
			}
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There are no Online admins currently in the server.");
	}

	//Return:
	return Plugin_Handled;
}
#if defined HL2DM
public void HL2dmThirdPersonViewFix(int Client)
{

	//Check:
	if(GetThirdPersonView(Client))
	{

		//Remove VGUI Panel:
		RemoveObserverView(Client);

		//Check:
		if(GetObserverMode(Client) != 5)
		{

			//Send:
			SetEntProp(Client, Prop_Send, "m_iObserverMode", 5);
		}

		//Check:
		if(GetClientMoveType(Client) != 2 && !IsJetpackOn(Client))
		{

			//Set Proper Move Type:
			SetClientMoveType(Client, 2);
		}

		//Check:
		if(GetClientMoveType(Client) != 5 && IsJetpackOn(Client))
		{

			//Set Proper Move Type:
			SetClientMoveType(Client, 5);
		}

		//Check:
		if(GetObserverTarget(Client) != Client)
		{

			//Send:
			SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", Client);
		}
	}
}
#endif
public bool GetViewWearables(int Client)
{

	//Return:
	return Wearables[Client];
}

public void SetViewWearables(int Client, bool Result)
{

	//Initulize:
	Wearables[Client] = Result;
}

public bool GetThirdPersonView(int Client)
{

	//Return:
	return ThirdPerson[Client];
}

public void SetThirdPersonView(int Client, bool Result)
{

	//Initulize:
	ThirdPerson[Client] = Result;
}


public bool intTobool(int i)
{

	if(i == 1) return true;
	else return false;
}

public int boolToint(bool i)
{

	if(i) return 1;
	else return 0;
}

public void TE_SetupGaussExplosion(float vecOrigin[3], int type, float direction[3])
{
	

 	TE_Start("GaussExplosion");

	TE_WriteFloat("m_vecOrigin[0]", vecOrigin[0]);

	TE_WriteFloat("m_vecOrigin[1]", vecOrigin[1]);

	TE_WriteFloat("m_vecOrigin[2]", vecOrigin[2]);

	TE_WriteNum("m_nType", type);

	TE_WriteVector("m_vecDirection", direction);

}

public int GetMenuTarget(int Client)
{

	//Return:
	return MenuTarget[Client];
}

public void SetMenuTarget(int Client, int Target)
{

	//Initulize:
	MenuTarget[Client] = Target;
}

public int GetPlayerIdFromString(char Text[32])
{

	//Declare
	int Player = -1;

	//Clear Buffers:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Check:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Declare:
			char PlayerName[32];

			//Initialize:
			GetClientName(i, PlayerName, sizeof(PlayerName));

			//Check:
			if(StrContains(PlayerName, Text, false) != -1)
			{

				//Initialize:
				Player = i;

				//Stop:
				break;
			}
		}
	}

	//Return:
	return Player;
}

public void ShowHudTextEx(int Client, int Channel, float Position[2], int Color[4], float holdtime, int Effect, float fxTime, float fadeIn, float FadeOutTime, const char[] Text)
{

	//Setup Hud:
	SetHudTextParams(Position[0], Position[1], holdtime, Color[0], Color[1], Color[2], Color[3], Effect, fxTime, fadeIn, FadeOutTime);

	//Show Hud Text:
        ShowHudText(Client, Channel, Text); 
}

public ShowHudTextAllEx(int Channel, float Position[2], int Color[4], float holdtime, int Effect, float fxTime, float fadeIn, float FadeOutTime, const char[] Text)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++) 
	{ 

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i)) 
		{

			//Initulize:
			ShowHudTextEx(i, Channel, Position, Color, holdtime, Effect, fxTime, fadeIn, FadeOutTime, Text);
		} 
	} 
}

public void CSGOShowHudTextEx(int Client, int Channel, float Position[2], int Color1[4], int Color2[4], float holdtime, int Effect, float fxTime, float fadeIn, float FadeOutTime, const char[] Text)
{

	//Setup Hud:
	SetHudTextParamsEx(Position[0], Position[1], holdtime, Color1, Color2, Effect, fxTime, fadeIn, FadeOutTime);

	//Show Hud Text:
        ShowHudText(Client, Channel, Text); 
}

public CSGOShowHudTextAllEx(int Channel, float Position[2], int Color1[4], int Color2[4], float holdtime, int Effect, float fxTime, float fadeIn, float FadeOutTime, const char[] Text)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++) 
	{ 

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i)) 
		{

			//Initulize:
			CSGOShowHudTextEx(i, Channel, Position, Color1, Color2, holdtime, Effect, fxTime, fadeIn, FadeOutTime, Text);
		} 
	} 
}

public void RemoveObserverView(int Client)
{

	ShowVGUIPanel(Client, "specmenu", INVALID_HANDLE, false);
	ShowVGUIPanel(Client, "specgui", INVALID_HANDLE, false);
	ShowVGUIPanel(Client, "overview", INVALID_HANDLE, false);
}

public void RemoveWebPanel(int Client)
{

	ShowVGUIPanel(Client, "info", INVALID_HANDLE, false);
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param client		Client index.
 * @param format		Message
 * @return			No bool.
 */
stock bool CPrintKeyHintText(int Client, const char[] format, any:...)
{

	//Handle:
	Handle userMessage = StartMessageOne("KeyHintText", Client);

	//Is Valid:
	if(userMessage == INVALID_HANDLE)
	{

		//Return:
		return false;
	}

	//Declare:
	char buffer[254];

	//Set Language:
	SetGlobalTransTarget(Client);

	//Format:
	VFormat(buffer, sizeof(buffer), format, 3);

	//Write Byte:
	BfWriteByte(userMessage, 1);

	//Write String:
	BfWriteString(userMessage, buffer); 

	//Send Message:
	EndMessage();

	//Return:
	return true;
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param format		Message
 * @return			No bool.
 */
stock void CPrintKeyHintTextAll(const char[] format, any:...)
{

	//Declare:
	char buffer[254];

	//Loop:
	for(int i = 1; i <= MaxClients; i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{

			//Set Language:
			SetGlobalTransTarget(i);

			//Format:
			VFormat(buffer, sizeof(buffer), format, 2);

			//Print:
			CPrintKeyHintText(i, buffer);
		}
	}
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param client		Client index.
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CPrintDialogText(int Client, int Level, float Time, int r, int g, int b, int a, char[] Text, any:...)
{

	//Declare:
	char message[100];

	//Format:
	VFormat(message, sizeof(message), Text, 3);

	// message in the top of the screen
	Handle msgValues = CreateKeyValues("msg");

	//Text:
	KvSetString(msgValues, "title", Text);

	//Set Color:
	KvSetColor(msgValues, "color", r, g, b, a);

	//Level Type:
	KvSetNum(msgValues, "level", Level);

	//Time:
	KvSetFloat(msgValues, "time", Time);

	//Send Menu:
	CreateDialog(Client, msgValues, DialogType_Msg);

	//Close:
	CloseHandle(msgValues);
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CPrintDialogTextAll(int Level, float Time, int r, int g, int b, int a, char[] Text, any:...)
{

	//Declare:
	char buffer[254];

	//Loop:
	for(int i = 1; i <= MaxClients; i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{

			//Set Language:
			SetGlobalTransTarget(i);

			//Format:
			VFormat(buffer, sizeof(buffer), Text, 2);

			//Print:
			CPrintDialogText(i, Level, Time, r, g, b, a, buffer)
		}
	}
}

/**
 * Sends a Dialog Menu to a client
 *
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CreateMenuTextBox(int Client, int Level, int Time, int R, int G, int B, int A, char[] Buffer, any:...)
{

	//Declare:
	char message[1028];

	//Format:
	VFormat(message,sizeof(message), Buffer, 9);

	//Handle:
	Handle kv = CreateKeyValues("message", "title", message);

	//Set Colour:
	KvSetColor(kv, "color", R, G, B, A);

	//Set Number
	KvSetNum(kv, "level", Level);

	//Set Number
	KvSetNum(kv, "time", Time);

	//Create Menu:
	CreateDialog(Client, kv, DialogType_Menu);

	//Create Menu:
	//CreateDialog(Client, kv, DialogType_Entry);

	//Create Menu:
	//CreateDialog(Client, kv, DialogType_Text);

	//Close:
	CloseHandle(kv);
}
/**
 * Sends a Dialog Menu to a client
 *
 * @param Level			Hud Type
 * @param Time			Hud Time
 * @param r			Red
 * @param g			Green
 * @param b			Blue
 * @param a			Alpha
 * @param Text			Message
 * @return			No bool.
 */
stock void CreateMenuTextBoxAll(int Level, int Time, int R, int G, int B, int A, char[] Buffer, any:...)
{

	//Declare:
	char buffer[1028];

	//Loop:
	for(int i = 1; i <= MaxClients; i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
		{

			//Set Language:
			SetGlobalTransTarget(i);

			//Format:
			VFormat(buffer, sizeof(buffer), Text, 2);

			//Print:
			CreateMenuTextBox(i, Level, Time, r, g, b, a, buffer)
		}
	}
}

public int IsClientPressingJump(int &Buttons)
{

	//Multi Button Check:
	if((Buttons & IN_JUMP)) return 1;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED)) return 2;

	if((Buttons & IN_JUMP) && (Buttons & IN_USE)) return 3;

	if((Buttons & IN_JUMP) && (Buttons & IN_ATTACK)) return 4;

	if((Buttons & IN_JUMP) && (Buttons & IN_ATTACK2)) return 5;

	if((Buttons & IN_JUMP) && (Buttons & IN_FORWARD)) return 6;

	if((Buttons & IN_JUMP) && (Buttons & IN_BACK)) return 7;

	if((Buttons & IN_JUMP) && (Buttons & IN_RIGHT)) return 8;

	if((Buttons & IN_JUMP) && (Buttons & IN_LEFT)) return 9;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED)) return 10;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_FORWARD)) return 11;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_BACK)) return 12;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_RIGHT)) return 13;

	if((Buttons & IN_JUMP) && (Buttons & IN_SPEED) && (Buttons & IN_LEFT)) return 14;

	if((Buttons & IN_JUMP) && (Buttons & IN_FORWARD) && (Buttons & IN_RIGHT)) return 15;

	if((Buttons & IN_JUMP) && (Buttons & IN_FORWARD) && (Buttons & IN_LEFT)) return 16;

	//Return:
	return -1;
}