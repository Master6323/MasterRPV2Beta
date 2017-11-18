//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcichthyosaur_included_
  #endinput
#endif
#define _rp_npcichthyosaur_included_
#if defined HL2DM
public void initNpcichthyosaur()
{

	//NPC Management:
	RegAdminCmd("sm_testichthyosaur", Command_CreateNpcIchthyosaur, ADMFLAG_ROOT, "<No Arg>");
}

//Create NPC:
public Action Command_CreateNpcIchthyosaur(int Client, int Args)
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

	CreateNpcIchthyosaur("npc_ichthyosaur", "null", Position, Angles);

	//Return:
	return Plugin_Handled;
}

public int CreateNpcIchthyosaur(const char[] sNpc, const char[] Model, float Position[3], float Angles[3])
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	int NPC = CreateEntityByName(sNpc);

	//Is Valid:
	if(NPC > 0)
	{

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
		SetVariantString("player D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
#endif