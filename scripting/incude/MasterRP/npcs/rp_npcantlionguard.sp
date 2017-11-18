//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcantlionguard_included_
  #endinput
#endif
#define _rp_npcantlionguard_included_
#if defined HL2DM
//Eplode Sound:
char AntLionShieldSound[255] = "ambient/levels/labs/electric_explosion5.wav";

public void initNpcAntLionGuard()
{

	//NPC Beta:
	RegAdminCmd("sm_testantlionguard", Command_CreateNpcAntLionGuard, ADMFLAG_ROOT, "<No Arg>");

	//Entity Event Hook:
	HookEntityOutput("npc_antlionguard", "OnDeath", OnAntLionGuardDied);

	//Precache:
	PrecacheSound(AntLionShieldSound);
}

//Event Damage:
public Action OnAntLionGuardDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(75.0, 200.0);

	damageType = DMG_DISSOLVE;
}

//Event Damage:
public Action OnDamageAntLionGuard(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Initialize:
	damageType = DMG_DISSOLVE;

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public void OnAntLionGuardDied(const char[] Output, int Caller, int Activator, float Delay)
{

	//Is Valid:
	if(IsValidEdict(Activator) && Activator > 0 && Activator <= GetMaxClients())
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has Killed the AntLion Guard!", Activator);
	}

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(i > 0 && IsClientConnected(i) && IsClientInGame(i))
		{

			//Declare:
			int Amount = RoundFloat(GetDamage(i) * 5);

			//Check:
			if(Amount > 0)
			{

				//DamageCheck
				if(Amount > 10000) Amount = GetRandomInt(9500, 15000);

				//Initulize:
				SetBank(i, (GetBank(i) + Amount));

				//Bank State:
				BankState(i, Amount);

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - You have been rewarded %s!", IntToMoney(Amount));

				//Initulize:
				SetDamage(i, 0.0);
			}
		}
	}

	//Check:
	if(IsValidAttachedEffect(Caller))
	{

		//Remove:
		RemoveAttachedEffect(Caller);
	}

	//Check:
	if(IsValidLight(Caller))
	{

		//Remove Light:
		RemoveLight(Caller);
	}

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);

	SetNpcsOnMap((GetNpcsOnMap() - 1));
}

//Create NPC:
public Action Command_CreateNpcAntLionGuard(int Client, int Args)
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
	float Position[3]; 
	float Angles[3] = {0.0,...};

	//Initulize:
	GetCollisionPoint(Client, Position);

	CreateNpcAntLionGuard("null", Position, Angles, 10000, 1);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcAntLionGuard(const char[] Model, float Position[3], float Angles[3], int Health, int Custom)
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	int NPC = CreateEntityByName("npc_antlionguard");

	//Is Valid:
	if(NPC > 0)
	{

		//Dispatch
		DispatchKeyValue(NPC, "spawnflags", "512");
		//DispatchKeyValue(NPC, "cavern breed", "1");

		DispatchKeyValue(NPC, "name", "npc_antlionguard");

		//Spawn & Send:
		DispatchSpawn(NPC);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Set Hate Status
		SetVariantString("Player D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_vortigaunt D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_advisor D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_clawscanner D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//AcceptEntityInput(NPC, "EnableBark");

		//SetEntProp(NPC, Prop_Data, "m_bCavernBreed", 1);

		//SetEntProp(NPC, Prop_Data, "m_bInCavern", 1);

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		SetEntProp(NPC, Prop_Data, "m_iMaxHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnDamageAntLionGuard);

		//Initulizse:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Check:
		if(Custom == 1)
		{

			//Initulize Effects:
			int Effect = CreatePointTesla(NPC, "0", "51 120 255");

			SetEntAttatchedEffect(NPC, 0, Effect);

			Effect = CreatePointTesla(NPC, "1", "51 120 255");

			SetEntAttatchedEffect(NPC, 1, Effect);

			//Set Ent Color:
			SetEntityRenderColor(NPC, 51, 120, 255, 255);

			//Initulize:
			SetIsCritical(NPC, true);

			//Timer:
			CreateTimer(0.5, InitCritical, NPC, TIMER_REPEAT);

			//Added Effect:
			Effect = CreateLight(NPC, 1, 51, 120, 255, "0");

			SetEntAttatchedEffect(NPC, 2, Effect);

			//Added Effect:
			Effect = CreateLight(NPC, 1, 51, 120, 255, "1");

			SetEntAttatchedEffect(NPC, 3, Effect);
		}

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}

public Action InitCritical(Handle Timer, any Ent)
{

	//Check & Is Alive::
	if(!IsValidEdict(Ent) || (GetEntHealth(Ent) <= 0))
	{

		//Kill:
		KillTimer(Timer);

		//Initulize:
		Timer = INVALID_HANDLE;
	}

	//Override:
	else
	{

		//Declare:
		int TempEnt = GetEntAttatchedEffect(Ent, 0);

		//Accept:
		AcceptEntityInput(TempEnt, "TurnOn");

		AcceptEntityInput(TempEnt, "DoSpark");

		//Timer:
		CreateTimer(0.25, DelayEffect, Ent);

		//Declare:
		float ClientOrigin[3];
		float Origin[3];
		float Damage = 0.0;

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, ClientOrigin);

				//In Distance:
				if(Dist <= 225 && IsTargetInLineOfSight(Ent, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					//Has Shield Near By:
					if(IsShieldInDistance(i))
					{

						//Shield Forward:
						OnClientShieldDamage(i, Damage);
					}

					//Override:
					else
					{

						//Check:
						if(GetClientHealth(i) - RoundFloat(Damage) <= 0)
						{

							//Damage Client:
							SDKHooks_TakeDamage(i, Ent, Ent, Damage, DMG_DISSOLVE);
						}

						//Override:
						else
						{

							//Damage Client:
							SDKHooks_TakeDamage(i, Ent, Ent, Damage, DMG_DISSOLVE & DMG_PREVENT_PHYSICS_FORCE);
						}
					}
				}
			}
		}

		//Declare:
		int Random = GetRandomInt(1, 25);

		//Check:
		if(Random == 1)
		{

			//Create Special Effect:
			CreateAntLionBomb(Ent, Origin);
		}
	}
}


public Action DelayEffect(Handle Timer, any Ent)
{

	//Declare:
	int TempEnt = GetEntAttatchedEffect(Ent, 1);

	//Check & Is Alive::
	if(IsValidEdict(TempEnt))
	{

		//Accept:
		AcceptEntityInput(TempEnt, "TurnOn");

		AcceptEntityInput(TempEnt, "DoSpark");
	}
}

public Action CreateAntLionBomb(int Ent, float Origin[3])
{

	//Initulize:
	Origin[2] += 30;

	//Temp Ent Setup:
	TE_SetupGlowSprite(Origin, GlowBlue(), 5.0, 10.0, 100);

	//Send To All Clients:
	TE_SendToAll();

	//Emit:
	EmitAmbientSound(AntLionShieldSound, Origin, Ent, SNDLEVEL_NORMAL);

	//Declare:
	int EntHealth = GetEntHealth(Ent);

	int MaxHealth = GetEntMaxHealth(Ent);

	//Check:
	if(GetEntHealth(Ent) != GetEntMaxHealth(Ent))
	{

		if(EntHealth + 100 < MaxHealth)
		{

			//Set Health:
			SetEntHealth(Ent, (EntHealth + 100));
		}

		//Override:
		else
		{

			//Set Health:
			SetEntHealth(Ent, GetEntMaxHealth(Ent));
		}
	}
}
#endif