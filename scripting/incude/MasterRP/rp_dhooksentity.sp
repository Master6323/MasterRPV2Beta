//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dhooksentity_included_
  #endinput
#endif
#define _rp_dhookesntity_included_

public void OnVendorHardWareStoreHook(int Entity)
{

	//Client Hooking:
 	DHookEntity(hPreStartTouch, false, Entity);

	//Client Hooking:
 	DHookEntity(hPreTouch, false, Entity);
}

// void Unknown...
public void OnEntityCreated(int Entity, const char[] ClassName)
{
#if defined HL2DM
	//Is Valid
	if(StrContains(ClassName, "grenade") != -1)
	{

		//Client Hooking:
 		DHookEntity(hPreStartTouch, false, Entity);

		//Client Hooking:
 		DHookEntity(hPreTouch, false, Entity);

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}

	//Is Valid
	if(StrContains(ClassName, "prop_combine_ball") != -1)
	{

		//Client Hooking:
 		DHookEntity(hPostSpawn, true, Entity);
	}
#endif
	//Is Valid
	if(StrContains(ClassName, "gib") != -1)
	{

		//SQL Load:
		CreateTimer(10.00, RemoveGibs, Entity);
	}

	//Is Valid:
	if(StrContains(ClassName, "prop_physics") != -1)
	{

		//Declare:
		char ModelName[128];

		//Initialize:
		GetEntPropString(Entity, Prop_Data, "m_ModelName", ModelName, 128);

		//Is Valid:
		if(StrContains(ModelName, "gib", false) != -1)
		{

			//SQL Load:
			CreateTimer(10.00, RemoveGibs, Entity);
		}
	}
}

// void Unknown...
// remove players from Vehicles before they are destroyed or the server will crash!
public void OnEntityDeleted(int Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Remove Crate:
		OnCrateDestroyed(Entity);

		//Remove Bomb:
		OnBombDestroyed(Entity);

		//Remove Fire:
		OnFireDestroyed(Entity);

		//Remove Anomaly:
		OnAnomalyDestroyed(Entity);

		//Declare:
		char ClassName[30];

		//Initulize:
		GetEdictClassname(Entity, ClassName, sizeof(ClassName));

		//Is Valid:
		if(StrEqual("prop_Vehicle_driveable", ClassName, false))
		{

			//Declare:
			int Driver = GetEntPropEnt(Entity, Prop_Send, "m_hPlayer");

			//Has Driver:
			if(Driver != -1)
			{

				//Exit Car:
				ExitVehicle(Driver, Entity, true);
			}
		}

		//Check:
		if(IsValidAttachedEffect(Entity))
		{

			//Remove:
			RemoveAttachedEffect(Entity);
		}
	}
}
#if defined HL2DM
public MRESReturn OnGrenadePostSpawn(int Entity, Handle hParams)
{

	//Set Entity Model:
	SetEntityModel(Entity, "models/props_c17/doll01.mdl");

	//GetOwner
	int Client = GetEntPropEnt(Entity, Prop_Data, "m_hOwnerEntity");

	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		int Effect = -1;

		//Check:
		if(IsCop(Client))
		{

			//Added Effect:
			Effect = CreateLight(Entity, 1, 120, 120, 255, "null");
		}

		//Check:
		else if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Added Effect:
			Effect = CreateLight(Entity, 1, 255, 255, 120, "null");
		}

		//Override:
		else
		{

			//Added Effect:
			Effect = CreateLight(Entity, 1, 255, 120, 120, "null");
		}

		//Initulize:
		SetEntAttatchedEffect(Entity, 0, Effect);
	}

	//Return:
	return MRES_Ignored;
}

public MRESReturn OnPropCombineBallPostSpawn(int Entity, Handle hParams)
{

	//Added Effect:
	int Effect = CreateLight(Entity, 1, 120, 120, 255, "null");

	SetEntAttatchedEffect(Entity, 0, Effect);

	//Return:
	return MRES_Ignored;
}
#endif
//Spawn Timer:
public Action RemoveGibs(Handle Timer, any Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > MaxClients)
	{

		//Remove:
		//RemoveEdict(Ent);

		//Dessolve:
		EntityDissolve(Ent, 1);
	}
}
