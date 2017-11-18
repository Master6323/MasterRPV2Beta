//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).
///////////////////////////////////////////////////////////////////////////////
///////////////////////// Masters Car Mod v1.0.01 /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/** Double-include prevention */
#if defined _rp_carmod_included_
  #endinput
#endif
#define _rp_carmod_included_

float CurrentEyeAngle[MAXPLAYERS + 1][3];

public void initCarMod()
{

	//Beta
	RegAdminCmd("sm_cartest", CommandCarsTest, ADMFLAG_ROOT, "test");

	//Beta
	RegAdminCmd("sm_exitcar", Command_ExitCars, ADMFLAG_ROOT, "test");
}

public void OnClientPreThinkVehicleViewFix(int Client)
{

	//Declare:
	int WasInVehicle[MAXPLAYERS + 1] = {0,...};

	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle == -1)
	{

		//Is Valid:
		if(WasInVehicle[Client] != 0)
		{

			//Is Valid:
			if(IsValidEdict(WasInVehicle[Client]))
			{

				//Initulize:
				SendConVarValue(Client, FindConVar("sv_Client_predict"), "1");

				//Set Ent:
				SetEntProp(WasInVehicle[Client], Prop_Send, "m_iTeamNum", 0);
			}

			//Initulize:
			WasInVehicle[Client] = 0;
		}

		//Return:
		return;
	}
	
	// "m_bEnterAnimOn" is the culprit for vehicles controlling all players views.
	// this is the earliest it can be changed, also stops vehicle starting..
	if(GetEntProp(InVehicle, Prop_Send, "m_bEnterAnimOn") == 1)
	{

		//Initulize:
		WasInVehicle[Client] = InVehicle;

		//Declare:
		float FaceFront[3] = {0.0, 90.0, 0.0};

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, FaceFront, NULL_VECTOR);

		//Set Ent:
		SetEntProp(InVehicle, Prop_Send, "m_bEnterAnimOn", 0);
		
		// stick the player in the correct view position if they're stuck in and enter animation.
		SetEntProp(InVehicle, Prop_Send, "m_nSequence", 0);
		
		// set the vehicles team so team mates can't destroy it.
		int DriverTeam = GetEntProp(Client, Prop_Send, "m_iTeamNum");
		SetEntProp(InVehicle, Prop_Send, "m_iTeamNum", DriverTeam);

		//Accept:
		AcceptEntityInput(InVehicle, "Lock");

		//Loop:
		for(int players = 1; players <= MaxClients; players++) 
		{

			//Is Valid:
			if(IsClientInGame(players) && IsPlayerAlive(players))
			{

				//Not Player:
				if(players != Client)
				{

					//Teleport:
					TeleportEntity(players, NULL_VECTOR, CurrentEyeAngle[players], NULL_VECTOR);
				}
			}
		}

		//Initulize:
		SendConVarValue(Client, FindConVar("sv_Client_predict"), "0");
	}

	//Override:
	else
	{

		//Accept:
		AcceptEntityInput(InVehicle, "TurnOn");
	}

	if(GetThirdPersonView(Client))
	{

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, CurrentEyeAngle[Client], NULL_VECTOR);
	}
}

public Action OnVehicleUse(int Client)
{

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle != -1)
	{

		//Declare:
		int Ent = GetClientAimTarget(Client, false);

		//Check:
		if(IsValidEdict(Ent) && Ent == InVehicle)
		{

			//Declare:
			char ClassName[32];

			//Initulize:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual("prop_vehicle_driveable", ClassName, false) || StrEqual("prop_vehicle_prisoner_pod", ClassName, false))
			{

				//Exit
				ExitVehicle(Client, InVehicle, true);
			}
		}
	}
}

public void ExitVehicle(int Client, int Vehicle, bool Force)
{

	//Declare:
	float ExitPoint[3];

	//Force:
	if(Force)
	{

		// check left.
		if (!IsExitClear(Client, Vehicle, 90.0, ExitPoint))
		{

			// check right.
			if (!IsExitClear(Client, Vehicle, -90.0, ExitPoint))
			{

				// check front.
				if (!IsExitClear(Client, Vehicle, 0.0, ExitPoint))
				{

					// check back.
					if (!IsExitClear(Client, Vehicle, 180.0, ExitPoint))
					{

						// check above the vehicle.
						float ClientEye[3];

						//Initulize:
						GetClientEyePosition(Client, ClientEye);

						//Declare:
						float ClientMinHull[3];

						float ClientMaxHull[3];

						//Initulize:
						GetEntPropVector(Client, Prop_Send, "m_vecMins", ClientMinHull);

						GetEntPropVector(Client, Prop_Send, "m_vecMaxs", ClientMaxHull);

						//Declare:
						float TraceEnd[3];

						//Initulize:
						TraceEnd = ClientEye;
						TraceEnd[2] += 500.0;

						//Trace:
						TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, Client);

						//Declare:
						float CollisionPoint[3];

						//Check:
						if (TR_DidHit())
						{

							//Get Ent Position:
							TR_GetEndPosition(CollisionPoint);
						}

						//Override:
						else
						{

							//Initulize:
							CollisionPoint = TraceEnd;
						}

						//Trace
						TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

						//Declare:
						float VehicleEdge[3];

						//En:
						TR_GetEndPosition(VehicleEdge);
						
						float ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

						//Check:
						if (ClearDistance >= 100.0)
						{
							ExitPoint = VehicleEdge;
							ExitPoint[2] += 100.0;
							
							if (TR_PointOutsideWorld(ExitPoint))
							{
								CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF No safe exit point found!!!!!");
								return;
							}
						}
						else
						{
							CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF No safe exit point found!!!!!");
							return;
						}
					}
				}
			}
		}
	}
	else
	{
		GetClientAbsOrigin(Client, ExitPoint);
	}
	
	AcceptEntityInput(Client, "ClearParent");
	
	SetEntPropEnt(Client, Prop_Send, "m_hVehicle", -1);
	
	SetEntPropEnt(Vehicle, Prop_Send, "m_hPlayer", -1);
	
	SetEntityMoveType(Client, MOVETYPE_WALK);
	
	SetEntProp(Client, Prop_Send, "m_CollisionGroup", 5);
	
	int hud = GetEntProp(Client, Prop_Send, "m_iHideHUD");
	hud &= ~1;
	hud &= ~256;
	hud &= ~1024;
	SetEntProp(Client, Prop_Send, "m_iHideHUD", hud);
	
	int EntEffects = GetEntProp(Client, Prop_Send, "m_fEffects");
	EntEffects &= ~32;
	SetEntProp(Client, Prop_Send, "m_fEffects", EntEffects);

	//Declare:
	char ClassName[32];

	//Initulize:
	GetEdictClassname(Vehicle, ClassName, sizeof(ClassName));

	//Is Valid:
	if(StrEqual("prop_vehicle_driveable", ClassName, false))
	{

		SetEntProp(Vehicle, Prop_Send, "m_nSpeed", 0);
		SetEntPropFloat(Vehicle, Prop_Send, "m_flThrottle", 0.0);
	}

	float ExitAng[3];
	
	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", ExitAng);
	ExitAng[0] = 0.0;
	ExitAng[1] += 90.0;
	ExitAng[2] = 0.0;

	TeleportEntity(Client, ExitPoint, ExitAng, NULL_VECTOR);
}

// checks if 100 units away from the edge of the Vehicle in the given direction is clear.
public bool IsExitClear(int Client, int Vehicle, float direction, float exitpoint[3])
{

	//Declare:
	float ClientEye[3];
	float VehicleAngle[3];
	float ClientMinHull[3];
	float ClientMaxHull[3];
	float DirectionVec[3];

	//Initulize:
	GetClientEyePosition(Client, ClientEye);

	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", VehicleAngle);

	GetEntPropVector(Client, Prop_Send, "m_vecMins", ClientMinHull);

	GetEntPropVector(Client, Prop_Send, "m_vecMaxs", ClientMaxHull);

	//Math:
	VehicleAngle[0] = 0.0;
	VehicleAngle[2] = 0.0;
	VehicleAngle[1] += direction;
	
	//Initulize:
	GetAngleVectors(VehicleAngle, NULL_VECTOR, DirectionVec, NULL_VECTOR);

	//Scale:
	ScaleVector(DirectionVec, -500.0);

	//Declare:
	float TraceEnd[3];
	float CollisionPoint[3];
	float VehicleEdge[3];

	//Add:
	AddVectors(ClientEye, DirectionVec, TraceEnd);

	//Trace:
	TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, Client);

	//Found End:
	if(TR_DidHit())
	{

		//Get End Point:
		TR_GetEndPosition(CollisionPoint);
	}

	//Override:
	else
	{

		//Initulize:
		CollisionPoint = TraceEnd;
	}

	//Trace:
	TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

	//Get End Point:
	TR_GetEndPosition(VehicleEdge);

	//Declare:
	float ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

	//Is Valid:
	if(ClearDistance >= 100.0)
	{

		//Math:
		MakeVectorFromPoints(VehicleEdge, CollisionPoint, DirectionVec);
		NormalizeVector(DirectionVec, DirectionVec);
		ScaleVector(DirectionVec, 100.0);
		AddVectors(VehicleEdge, DirectionVec, exitpoint);

		//Can Spawn:
		if(TR_PointOutsideWorld(exitpoint))
		{

			//Return:
			return false;
		}

		//Override:
		else
		{

			//Return:
			return true;
		}
	}

	//Override:
	else
	{

		//Return:
		return false;
	}
}

public bool DontHitClientOrVehicle(int Entity, int contentsMask, any data)
{

	//Declare:
	int InVehicle = GetEntPropEnt(data, Prop_Send, "m_hVehicle");

	//Return:
	return ((Entity != data) && (Entity != InVehicle));
}

public bool RayDontHitClient(int Entity, int contentsMask, any data)
{
	return (Entity != data);
}

public void SpawnVehicle(int Client, float spawnorigin[3], float spawnangles[3], int skin, int client, const char[] Model, const char[] Script, int type)
{

	//Declare:
	int VehicleIndex = CreateEntityByName("prop_vehicle_driveable");

	//Check:
	if (VehicleIndex == -1)
	{

		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");

		//Return:
		return;
	}

	//Declare:
	char TargetName[10];

	//Format:
	Format(TargetName, sizeof(TargetName), "%i",VehicleIndex);

	//Dispatch:
	DispatchKeyValue(VehicleIndex, "targetname", TargetName);
	
	DispatchKeyValue(VehicleIndex, "model", Model);

	DispatchKeyValue(VehicleIndex, "vehiclescript", Script);

	//Send:
	SetEntProp(VehicleIndex, Prop_Send, "m_nSolidType", 6);

	//Check:
	if (skin == -1)
	{

		//Initulize:
		skin = 1;
	}

	//Send:
	SetEntProp(VehicleIndex, Prop_Send, "m_nSkin", skin);

	//Check:
	if (type == 1)
	{
		SetEntProp(VehicleIndex, Prop_Data, "m_nVehicleType", 8);
	}

	//Spawn:
	DispatchSpawn(VehicleIndex);

	//Activate:
	ActivateEntity(VehicleIndex);
	
	// stops the vehicle rolling back when it is spawned.
	SetEntProp(VehicleIndex, Prop_Data, "m_nNextThinkTick", -1);

	SetEntProp(VehicleIndex, Prop_Data, "m_bHasGun", 0);

	// anti flip, not 100% effective.
	int PhysIndex = CreateEntityByName("phys_ragdollconstraint");

	//Check:
	if (PhysIndex == -1)
	{

		//Accept:
		AcceptEntityInput(VehicleIndex, "Kill");

		//Print:
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");

		//Return:
		return;
	}

	//Dispatch:
	DispatchKeyValue(PhysIndex, "spawnflags", "2");

	DispatchKeyValue(PhysIndex, "ymin", "-50.0");

	DispatchKeyValue(PhysIndex, "ymax", "50.0");

	DispatchKeyValue(PhysIndex, "zmin", "-180.0");

	DispatchKeyValue(PhysIndex, "zmax", "180.0");

	DispatchKeyValue(PhysIndex, "xmin", "-50.0");

	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);

	//Spawn:	
	DispatchSpawn(PhysIndex);

	//Activate:
	ActivateEntity(PhysIndex);

	//Set:
	SetVariantString(TargetName);

	//Accept:
	AcceptEntityInput(PhysIndex, "SetParent");

	//Teleport:
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	//Declare:
	float MinHull[3];
	float MaxHull[3];

	//Initulize:
	GetEntPropVector(VehicleIndex, Prop_Send, "m_vecMins", MinHull);

	GetEntPropVector(VehicleIndex, Prop_Send, "m_vecMaxs", MaxHull);

	//Declare:
	float temp;

	//Initulize:
	temp = MinHull[0];
	MinHull[0] = MinHull[1];
	MinHull[1] = temp;

	//Initulize:
	temp = MaxHull[0];
	MaxHull[0] = MaxHull[1];
	MaxHull[1] = temp;

	//Check:
	if (client == 0)
	{

		//Trace:
		TR_TraceHull(spawnorigin, spawnorigin, MinHull, MaxHull, MASK_SOLID);
	}

	//Override:
	else
	{

		//Trace:
		TR_TraceHullFilter(spawnorigin, spawnorigin, MinHull, MaxHull, MASK_SOLID, RayDontHitClient, client);
	}

	//Check:
	if (TR_DidHit())
	{

		//Accept:
		AcceptEntityInput(VehicleIndex, "Kill");

		//Print:
		PrintToServer("|RP-vehicleMod|: spawn coordinates not clear");

		//Print:
		return;
	}

	//Teleport:
	TeleportEntity(VehicleIndex, spawnorigin, spawnangles, NULL_VECTOR);

	//Send:
	SetEntProp(VehicleIndex, Prop_Data, "m_takedamage", 0);

	// force players in.
	if (client != 0)
	{

		//Accept:
		AcceptEntityInput(VehicleIndex, "use", client);
	}

	//Accept:
	AcceptEntityInput(VehicleIndex, "TurnOn", client);
}

//Create NPC:
public Action CommandCarsTest(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	float EyeAng[3];
	float SpawnOrigin[3];
	float Origin[3];

	//Initulize:
	GetClientEyeAngles(Client, EyeAng);

	//Initulize:
	GetClientEyePosition(Client, Origin);

	//Initialize:
	SpawnOrigin[0] = (Origin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAng[1])))));

	SpawnOrigin[1] = (Origin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAng[1])))));

	SpawnOrigin[2] = (Origin[2] + 100);

	SpawnVehicle(Client, SpawnOrigin, EyeAng, 1, 0, "models/blodia/buggy.mdl", "scripts/vehicles/buggy_edit.txt", 0);
	//SpawnVehicle(Client, SpawnOrigin, SpawnAngles, 1, Client, "models/supra.mdl", "scripts/vehicles/supra.txt", 0);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF - You have spawned a test jeep");

	//Return:
	return Plugin_Handled;
}

//Create NPC:
public Action Command_ExitCars(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle != -1)
	{

		//Exit
		//ExitVehicle(Client, InVehicle, true);

		//Declare:
		float Origin[3] = {0.0,...};

		float ExitAngles[3] = {0.0,...};

		//Check:
		if(!IsExitClearMod(Client, InVehicle, ExitOrigin))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF - No Clear Exit");
		}

		//Exit:
		SetPlayerLeaveVehicle(Client, Origin, ExitAngles);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF - You have exited the car");
	}

	//Return:
	return Plugin_Handled;
}

// checks if 100 units away from the edge of the Vehicle in the given direction is clear.
public bool IsExitClearMod(int Client, int Vehicle, float exitpoint[3])
{

	//Declare:
	float ClientEye[3];
	float VehicleAngle[3];
	float ClientMinHull[3];
	float ClientMaxHull[3];
	float DirectionVec[3];

	//Float:
	float direction = 0.0;

	//Loop:
	for(int X = 1; X <= 4; X++)
	{

		if(X == 1) direction = 90.0;
		if(X == 2) direction = -90.0;
		if(X == 3) direction = 0.0;
		if(X == 4) direction = 180.0;

		//Initulize:
		GetClientEyePosition(Client, ClientEye);

		GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", VehicleAngle);

		GetEntPropVector(Client, Prop_Send, "m_vecMins", ClientMinHull);

		GetEntPropVector(Client, Prop_Send, "m_vecMaxs", ClientMaxHull);

		//Math:
		VehicleAngle[0] = 0.0;
		VehicleAngle[2] = 0.0;
		VehicleAngle[1] += direction;

		//Initulize:
		GetAngleVectors(VehicleAngle, NULL_VECTOR, DirectionVec, NULL_VECTOR);

		//Scale:
		ScaleVector(DirectionVec, -500.0);

		//Declare:
		float TraceEnd[3];
		float CollisionPoint[3];
		float VehicleEdge[3];

		//Add:
		AddVectors(ClientEye, DirectionVec, TraceEnd);

		//Trace:
		TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, Client);

		//Found End:
		if(TR_DidHit())
		{

			//Get End Point:
			TR_GetEndPosition(CollisionPoint);
		}

		//Override:
		else
		{

			//Initulize:
			CollisionPoint = TraceEnd;
		}

		//Trace:
		TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

		//Get End Point:
		TR_GetEndPosition(VehicleEdge);

		//Declare:
		float ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

		//Is Valid:
		if(ClearDistance >= 100.0)
		{

			//Math:
			MakeVectorFromPoints(VehicleEdge, CollisionPoint, DirectionVec);
			NormalizeVector(DirectionVec, DirectionVec);
			ScaleVector(DirectionVec, 100.0);
			AddVectors(VehicleEdge, DirectionVec, exitpoint);

			//Can Spawn:
			if(TR_PointOutsideWorld(exitpoint))
			{

			}

			//Override:
			else
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}
