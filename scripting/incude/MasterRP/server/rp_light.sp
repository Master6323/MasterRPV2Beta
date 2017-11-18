//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_Light_included_
  #endinput
#endif
#define _rp_Light_included_

//Lighs / Lamps:
int LightIsOn[2047] = {0,...};
int LightEnt[2047] = {-1,...};

public void initLight()
{

	//Clean map entitys:
	for(int X = 0; X < 2047; X++)
	{

		//Initialize:
		LightEnt[X] = -1;

		LightIsOn[X] = 0;
	}
}

public bool IsValidLight(int Ent)
{

	//Check:
	if(IsValidEdict(LightEnt[Ent]))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public bool RemoveLight(int Ent)
{

	//Check:
	if(IsValidEdict(LightEnt[Ent]))
	{

		//Accept:
		AcceptEntityInput(LightEnt[Ent], "kill", Ent);

		LightEnt[Ent] = -1;

		//Return:
		return true;
	}

	//Return:
	return false;
}

public int IsLightOn(Ent)
{

	//Return:
	return LightIsOn[Ent];
}
public int GetLightEnt(Ent)
{

	//Return:
	return LightEnt[Ent];
}

public int CreateLight(int Ent, int IsOn, int Red, int Green, int Blue, const char[] Attachment)
{

	//Declare:
	float EntOrigin[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", EntOrigin);

	//Edit Position:
	EntOrigin[2] += 30.0;

	//Initulize::
	int Light = CreateEntityByName("light_dynamic");

	//Is Valid:
	if(IsValidEdict(Light))
	{

		//Declare:
		char LightColor[32];

		//Format:
		Format(LightColor, sizeof(LightColor), "%i %i %i", Red, Green, Blue);

		//Dispatch:
		DispatchKeyValue(Light, "_light", LightColor);

		DispatchKeyValue(Light, "distance", "640");

		DispatchKeyValue(Light, "spotlight_radius", "80");

		DispatchKeyValue(Light, "brightness", "3");

		DispatchKeyValue(Light, "style", "0");

		//Declare:
		char SpawnOrg[50];

		//Format:
		Format(SpawnOrg, sizeof(SpawnOrg), "%f %f %f", EntOrigin[0], EntOrigin[1], EntOrigin[2]);

		//Dispatch:
		DispatchKeyValue(Light, "origin", SpawnOrg);

		//Spawn:
		DispatchSpawn(Light);

		//Initulize:
		LightEnt[Ent] = Light;

		LightIsOn[Ent] = IsOn;

		//Is Light On:
		if(IsOn == 1)
		{

			//Accept:
			AcceptEntityInput(Light, "TurnOn", Ent);
		}

		//Override:
		else
		{

			//Accept:
			AcceptEntityInput(Light, "TurnOff", Ent);
		}

		//Activate
		ActivateEntity(Light);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Light, "SetParent", Ent, Light, 0);

		//Custom Attachment point!
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Light, "SetParentAttachment", Light , Light, 0);
		}
		//Return:
		return Light;
	}

	//Return:
	return -1;
}
