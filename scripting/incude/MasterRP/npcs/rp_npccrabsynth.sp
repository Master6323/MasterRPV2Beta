//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npccrabsynth_included_
  #endinput
#endif
#define _rp_npccrabsynth_included_
#if defined HL2DM
public void initNpcCrabSynth()
{

	//NPC Beta:
	RegAdminCmd("sm_testcrabsynth", Command_CreateNpcCrabSynth, ADMFLAG_ROOT, "<No Arg>");

	//Entity Event Hook:
	HookEntityOutput("npc_crabsynth", "OnDeath", OnCrabSynthDied);
}

//Event Damage:
public Action OnCrabSynthDamageClient(int Client, int &attacker, int &inflictor, float &damage, int &damageType)
{

	//Initialize:
	damage = GetRandomFloat(25.0, 35.0);

	damageType = DMG_DISSOLVE;
}

//Event Damage:
public Action OnClientDamageCrabSynth(int Ent, int &Client, int &inflictor, float &damage, int &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Declare:
	char Classname[64];

	//Initialize:
	GetEdictClassname(Client, Classname, sizeof(Classname));

	if(!StrEqual(Classname, "npc_antlionguard"))
	{
		//Initulize:
		damageType = DMG_DISSOLVE;
	}

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public void OnCrabSynthDied(const char[] Output, int Caller, int Activator, float Delay)
{

	//Is Valid:
	if(IsValidEdict(Activator))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has took out the CrabSynth!", Activator);
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

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);

	SetNpcsOnMap((GetNpcsOnMap() - 1));
}

//Create NPC:
public Action Command_CreateNpcCrabSynth(int Client, int Args)
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
	GetClientAbsOrigin(Client, Position);

	CreateNpcCrabSynth("models/synth.mdl", Position, Angles, 2000);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcCrabSynth(const char[] Model, float Position[3], float Angles[3], int Health)
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	int NPC = CreateEntityByName("npc_headcrab");

	//Is Valid:
	if(NPC > 0)
	{

		DispatchKeyValue(NPC, "name", "npc_crabsynth");

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
		SetVariantString("player D_LI");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_antlionguard D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Set Prip:
		SetEntPropFloat(NPC, Prop_Send, "m_flModelScale", 0.2);

		//Debris:
		int Collision = GetEntSendPropOffs(NPC, "m_CollisionGroup");
		SetEntData(NPC, Collision, 1, 1, true);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageCrabSynth);

		//Initulize:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
#endif