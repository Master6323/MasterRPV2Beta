//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_entity_included_
  #endinput
#endif
#define _rp_entity_included_

public void EntityDissolve(int Ent, int Type)
{

	//Declare:
	int Dissolver = CreateEntityByName("env_entity_dissolver");

	//Check:
	if(Dissolver > 0 && IsValidEdict(Ent))
	{

		//declare:
		char TargetName[32];
		char sType[32];

		//Format:
		Format(TargetName, sizeof(TargetName), "dis_%i", Ent);

		Format(sType, sizeof(sType), "%i", Type);

		//Dispatch:
		DispatchKeyValue(Ent, "targetname", TargetName);

		DispatchKeyValue(Dissolver, "dissolvetype", sType);

		DispatchKeyValue(Dissolver, "target", TargetName);

		//Accept:
		AcceptEntityInput(Dissolver, "Dissolve");

		AcceptEntityInput(Dissolver, "kill");
	}
}

public int CreateInfoParticleSystem(int Ent, char[] Attachment, char[] ParticleType)
{

	//Declare:
	int Particle = CreateEntityByName("info_particle_system");

	//Check:
	if(IsValidEdict(Particle) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Particle, "effect_name", ParticleType);

		//Set Owner
		SetEntPropEnt(Particle, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Particle);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Particle, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Particle, "SetParent", Ent, Particle, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Particle, "SetParentAttachment", Particle, Particle, 0);
		}

		//Activate:
		ActivateEntity(Particle);

		//Accept:
		AcceptEntityInput(Particle, "start");

		//Return:
		return Particle;
	}

	//Return:
	return -1;
}

public int CreatePointTesla(int Ent, char[] Attachment, char[] Color)
{

	//Declare:
	int Tesla = CreateEntityByName("point_tesla");

	//Check:
	if(IsValidEdict(Tesla) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Tesla, "m_flRadius", "100.0");

		DispatchKeyValue(Tesla, "m_SoundName", "DoSpark");

		DispatchKeyValue(Tesla, "beamcount_min", "10");

		DispatchKeyValue(Tesla, "beamcount_max", "20");

		DispatchKeyValue(Tesla, "texture", "sprites/physbeam.vmt");

		DispatchKeyValue(Tesla, "m_Color", Color);

		DispatchKeyValue(Tesla, "thick_min", "3.0");

		DispatchKeyValue(Tesla, "thick_max", "6.0");

		DispatchKeyValue(Tesla, "lifetime_min", "0.3");

		DispatchKeyValue(Tesla, "lifetime_max", "0.3");

		DispatchKeyValue(Tesla, "interval_max", "0.2");

		DispatchKeyValue(Tesla, "interval_min", "0.1");

		//Set Owner
		SetEntPropEnt(Tesla, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Tesla);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Tesla, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Tesla, "SetParent", Ent, Tesla, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Tesla, "SetParentAttachment", Tesla, Tesla, 0);
		}

		//Spark:
		AcceptEntityInput(Tesla, "DoSpark");

		//Return:
		return Tesla;
	}

	//Return:
	return -1;
}

public int CreatePointTeslaNoSound(int Ent, char[] Attachment, char[] Color)
{

	//Declare:
	int Tesla = CreateEntityByName("point_tesla");

	//Check:
	if(IsValidEdict(Tesla) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Tesla, "m_flRadius", "100.0");

		DispatchKeyValue(Tesla, "beamcount_min", "5");

		DispatchKeyValue(Tesla, "beamcount_max", "10");

		DispatchKeyValue(Tesla, "texture", "sprites/physbeam.vmt");

		DispatchKeyValue(Tesla, "m_Color", Color);

		DispatchKeyValue(Tesla, "thick_min", "3.0");

		DispatchKeyValue(Tesla, "thick_max", "6.0");

		DispatchKeyValue(Tesla, "lifetime_min", "0.3");

		DispatchKeyValue(Tesla, "lifetime_max", "0.3");

		DispatchKeyValue(Tesla, "interval_max", "0.2");

		DispatchKeyValue(Tesla, "interval_min", "0.1");

		//Set Owner
		SetEntPropEnt(Tesla, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Tesla);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Tesla, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Tesla, "SetParent", Ent, Tesla, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Tesla, "SetParentAttachment", Tesla, Tesla, 0);
		}

		//Spark:
		AcceptEntityInput(Tesla, "DoSpark");

		//Return:
		return Tesla;
	}

	//Return:
	return -1;
}

public int CreateEnvBlood(int Ent, char[] Attachment, float Direction[3], float Time)
{

	//Declare:
	char Angles[128];

	//Format:
	Format(Angles, 128, "%f %f %f", Direction[0], Direction[1], Direction[2]);

	//Blood:
	int Blood = CreateEntityByName("env_blood");

	//Create:
	if(IsValidEdict(Blood) && IsValidEdict(Ent))
	{

		//Properties:
		DispatchKeyValue(Blood, "color", "0");

		DispatchKeyValue(Blood, "amount", "1000");

		DispatchKeyValue(Blood, "spraydir", Angles);

		DispatchKeyValue(Blood, "spawnflags", "12");

		//Set Owner
		SetEntPropEnt(Blood, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Blood);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Blood, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Blood, "SetParent", Ent, Blood, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Blood, "SetParentAttachment", Blood, Blood, 0);
		}

		//Check:
		if(Time > 0.0)
		{

			//Timer:
			CreateTimer(Time, RemoveBlood, Blood);
		}

		//Accept:
		AcceptEntityInput(Blood, "EmitBlood", Ent);

		//Return:
		return Blood;
	}

	//Return:
	return -1;
}

public Action RemoveBlood(Handle Timer, any Ent)
{

	//Check:
	if(IsValidEdict(Ent))
	{

		//Accept:
		AcceptEntityInput(Ent, "kill");
	}
}

public int CreateEnvShake(int Ent, char[] Attachment, char[] SpawnFlags, char[] Radius, char[] Frequency, char[] Duration, char[] Amplitude, float Time)
{

	//Shake:
	int Shake = CreateEntityByName("env_shake");

	//Create:
	if(IsValidEdict(Shake) && IsValidEdict(Ent))
	{

		//Properties:
		DispatchKeyValue(Shake, "spawnflags", SpawnFlags);

		DispatchKeyValue(Shake, "radius", Radius);

		DispatchKeyValue(Shake, "frequency", Frequency);

		DispatchKeyValue(Shake, "amplitude", Amplitude);

		//Set Owner
		SetEntPropEnt(Shake, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Shake);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Shake, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Shake, "SetParent", Ent, Shake, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Shake, "SetParentAttachment", Shake, Shake, 0);
		}

		//Check:
		if(Time > 0.0)
		{

			//Timer:
			CreateTimer(Time, RemoveShake, Shake);
		}

		//Accept:
		AcceptEntityInput(Shake, "StartShake", Ent);

		//Return:
		return Shake;
	}

	//Return:
	return -1;
}

public Action RemoveShake(Handle Timer, any Ent)
{

	//Check:
	if(IsValidEdict(Ent))
	{

		//Accept:
		AcceptEntityInput(Ent, "kill");
	}
}
public int CreateEnvFire(int Ent, char[] Attachment, char[] Health, char[] Size, char[] Attack, char[] Type)
{

	//Declare:
	int Fire = CreateEntityByName("env_fire");

	//Check:
	if(IsValidEdict(Fire) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Fire, "health", Health);

		DispatchKeyValue(Fire, "firesize", Size);

		DispatchKeyValue(Fire, "fireattack", Attack);

		DispatchKeyValue(Fire, "firetype", Type);

		DispatchKeyValue(Fire, "ignitionpoint", "0");

		DispatchKeyValue(Fire, "damagescale", "0");

		//Set Owner
		SetEntPropEnt(Fire, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Fire);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Fire, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Fire, "SetParent", Ent, Fire, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Fire, "SetParentAttachment", Fire, Fire, 0);
		}

		//Accept:
		AcceptEntityInput(Fire, "enable");

		AcceptEntityInput(Fire, "startfire");

		//Return:
		return Fire;
	}

	//Return:
	return -1;
}

public int CreateEnvFireTrail(int Ent, char[] Attachment, char[] Health, char[] Size, char[] Attack, char[] Type)
{

	//Declare:
	int Fire = CreateEntityByName("env_fire_trail");

	//Check:
	if(IsValidEdict(Fire) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Fire, "health", Health);

		DispatchKeyValue(Fire, "firesize", Size);

		DispatchKeyValue(Fire, "fireattack", Attack);

		DispatchKeyValue(Fire, "firetype", Type);

		DispatchKeyValue(Fire, "ignitionpoint", "0");

		DispatchKeyValue(Fire, "damagescale", "0");

		DispatchKeyValue(Fire, "spawnflags", "1");

		//Set Owner
		SetEntPropEnt(Fire, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Fire);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Fire, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Fire, "SetParent", Ent, Fire, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Fire, "SetParentAttachment", Fire ,Fire, 0);
		}

		//Accept:
		AcceptEntityInput(Fire, "enable");

		AcceptEntityInput(Fire, "startfire");

		//Return:
		return Fire;
	}

	//Return:
	return -1;
}

public int CreateFireSmoke(int Ent, char[] Attachment, char[] Health, char[] Size, char[] Attack, char[] Type)
{

	//Declare:
	int Fire = CreateEntityByName("_firesmoke");

	//Check:
	if(IsValidEdict(Fire) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Fire, "health", Health);

		DispatchKeyValue(Fire, "firesize", Size);

		DispatchKeyValue(Fire, "fireattack", Attack);

		DispatchKeyValue(Fire, "firetype", Type);

		DispatchKeyValue(Fire, "ignitionpoint", "0");

		DispatchKeyValue(Fire, "damagescale", "0");

		//Set Owner
		SetEntPropEnt(Fire, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Fire);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Fire, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Fire, "SetParent", Ent, Fire, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Fire, "SetParentAttachment", Fire ,Fire, 0);
		}

		//Accept:
		AcceptEntityInput(Fire, "enable");

		AcceptEntityInput(Fire, "startfire");

		//Return:
		return Fire;
	}

	//Return:
	return -1;
}
public int CreatePlasmaSmoke(int Ent, char[] Attachment)
{

	//Declare:
	int Plasma = CreateEntityByName("_Plasma");

	//Check:
	if(IsValidEdict(Plasma) && IsValidEdict(Ent))
	{

		//Set Owner
		SetEntPropEnt(Plasma, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Plasma);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Plasma, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Plasma, "SetParent", Ent, Plasma, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Plasma, "SetParentAttachment", Plasma ,Plasma, 0);
		}

		//Accept:
		AcceptEntityInput(Plasma, "enable");

		AcceptEntityInput(Plasma, "TurnOn");

		ActivateEntity(Plasma);

		//Return:
		return Plasma;
	}

	//Return:
	return -1;
}
public int CreateProp(float Origin[3], float Angles[3], char[] Model, bool WalkThru, bool Stuck, bool IndexTimer)
{

	//Initialize:
	int Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", Model);

		//Spawn:
		DispatchSpawn(Ent);

		//Send:
		TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

		//Send:
		SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

		//Check:
		if(WalkThru)
		{

			//Debris:
			new Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

			//Send:
			SetEntData(Ent, Collision, 1, 1, true);
		}

		//Check:
		if(Stuck)
		{

			//Accept:
			AcceptEntityInput(Ent, "disablemotion", Ent);
		}

		//Not Stuck:
		if(!Stuck)
		{

			//Accept:
			AcceptEntityInput(Ent, "enablemotion", Ent);
		}

		//Check:
		if(IndexTimer)
		{

			//Initulize:
			SetPropSpawnedTimer(Ent, 0);
		}

		//Initulize:
		SetPropIndex((GetPropIndex() + 1));

		//Return:
		return Ent;
	}

	//Return:
	return -1;
}

public int CreateEnvSmokeStack(int Ent, char[] Attachment, char[] Material, char[] Color, char[] BaseSpread, char[] SpreadSpeed, char[] Speed, char[] StartSize, char[] EndSize, char[] Rate, char[] JetLength, char[] Twist)
{

	//Declare:
	int SmokeStack = CreateEntityByName("env_smokestack");

	//Check:
	if(IsValidEdict(SmokeStack) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(SmokeStack, "smokematerial", Material);

		DispatchKeyValue(SmokeStack, "rendercolor", Color);

		DispatchKeyValue(SmokeStack, "InitialState", "0");

		DispatchKeyValue(SmokeStack, "BaseSpread", BaseSpread);

		DispatchKeyValue(SmokeStack, "SpreadSpeed", SpreadSpeed);

		DispatchKeyValue(SmokeStack, "Speed", Speed);

		DispatchKeyValue(SmokeStack, "StartSize", StartSize);

		DispatchKeyValue(SmokeStack, "EndSize", EndSize);

		DispatchKeyValue(SmokeStack, "Rate", Rate);

		DispatchKeyValue(SmokeStack, "JetLength", JetLength);

		DispatchKeyValue(SmokeStack, "twist", Twist);

		//Set Owner
		SetEntPropEnt(SmokeStack, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(SmokeStack);

		//Accept:
		AcceptEntityInput(Ent, "turnon");

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(SmokeStack, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SmokeStack, "SetParent", Ent, SmokeStack, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SmokeStack, "SetParentAttachment", SmokeStack, SmokeStack, 0);
		}

		//Accept:
		AcceptEntityInput(SmokeStack, "enable");

		//Return:
		return SmokeStack;
	}

	//Return:
	return -1;
}

//CreateEnvSmokeTrail(Ent, String:Attachment[], "materials/effects/fire_cloud1.vmt", "20.0", "10.0", "50.0", "5", "3", "50", "100", "0", "255 50 50", "5");
public int CreateEnvSmokeTrail(int Ent, char[] Attachment, char[] Material, char[] BaseSpread, char[] SpreadSpeed, char[] Speed, char[] StartSize, char[] EndSize, char[] Rate, char[] JetLength, char[] Twist, char[] Color, char[] Transparency)
{

	//Declare:
	int SmokeTrail = CreateEntityByName("env_smoketrail");

	//Check:
	if(IsValidEdict(SmokeTrail) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(SmokeTrail, "SmokeMaterial", Material);

		DispatchKeyValue(SmokeTrail, "InitialState", "1");

		DispatchKeyValue(SmokeTrail, "BaseSpread", BaseSpread);

		DispatchKeyValue(SmokeTrail, "SpreadSpeed", SpreadSpeed);

		DispatchKeyValue(SmokeTrail, "Speed", Speed);

		DispatchKeyValue(SmokeTrail, "StartSize", StartSize);

		DispatchKeyValue(SmokeTrail, "EndSize", EndSize);

		DispatchKeyValue(SmokeTrail, "Rate", Rate);

		DispatchKeyValue(SmokeTrail, "JetLength", JetLength);

		DispatchKeyValue(SmokeTrail, "twist", Twist);

		//DispatchKeyValue(SmokeTrail, "RenderColor", Color);

		DispatchKeyValue(SmokeTrail, "StartColor", Color);

		DispatchKeyValue(SmokeTrail, "Renderfx", Transparency);

		//Set Owner
		SetEntPropEnt(SmokeTrail, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(SmokeTrail);

		//Accept:
		AcceptEntityInput(Ent, "TurnOn");

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(SmokeTrail, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SmokeTrail, "SetParent", Ent, SmokeTrail, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SmokeTrail, "SetParentAttachment", SmokeTrail, SmokeTrail, 0);
		}

		//Accept:
		AcceptEntityInput(SmokeTrail, "enable");

		//Return:
		return SmokeTrail;
	}

	//Return:
	return -1;
}

public int CreateEnvSplash(int Ent, char[] Attachment, char[] SplashScale)
{

	//Declare:
	int Splash = CreateEntityByName("env_splash");

	//Check:
	if(IsValidEdict(Splash) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Splash, "Scale", SplashScale); // Float

		//Set Owner
		SetEntPropEnt(Splash, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Splash);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Splash, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Splash, "SetParent", Ent, Splash, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Splash, "SetParentAttachment", Splash, Splash, 0);
		}

		//Spark:
		AcceptEntityInput(Splash, "Splash");

		//Return:
		return Splash;
	}

	//Return:
	return -1;
}

public int CreateEnvSteam(int Ent, char[] Attachment, char[] Color, char[] Translucency, char[] Type, char[] SpreadSpeed, char[] Speed, char[] StartSize, char[] EndSize, char[] Rate, char[] JetLength, char[] Spin)
{

	//Declare:
	int Steam = CreateEntityByName("env_steam");

	//Check:
	if(IsValidEdict(Steam) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Steam, "RenderColor", Color);

		DispatchKeyValue(Steam, "RenderAmt", Translucency);

		DispatchKeyValue(Steam, "InitialState", "1");

		DispatchKeyValue(Steam, "Type", Type);

		DispatchKeyValue(Steam, "SpreadSpeed", SpreadSpeed);

		DispatchKeyValue(Steam, "Speed", Speed);

		DispatchKeyValue(Steam, "StartSize", StartSize);

		DispatchKeyValue(Steam, "EndSize", EndSize);

		DispatchKeyValue(Steam, "Rate", Rate);

		DispatchKeyValue(Steam, "JetLength", JetLength);

		DispatchKeyValue(Steam, "Spin", Spin);

		//Set Owner
		SetEntPropEnt(Steam, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Steam);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Steam, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Steam, "SetParent", Ent, Steam, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Steam, "SetParentAttachment", Steam, Steam, 0);
		}

		//Spark:
		AcceptEntityInput(Steam, "TurnOn");

		//Return:
		return Steam;
	}

	//Return:
	return -1;
}

public int CreateEnvFlame(int Ent, char[] Attachment, float Angles[3])
{

	//Declare:
	int Flame = CreateEntityByName("env_steam");

	//Check:
	if(IsValidEdict(Flame) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Flame, "SpawnFlags", "1");

		DispatchKeyValue(Flame, "Type", "0");

		DispatchKeyValue(Flame, "InitialState", "1");

		DispatchKeyValue(Flame, "Spreadspeed", "20");

		DispatchKeyValue(Flame, "Speed", "800");

		DispatchKeyValue(Flame, "Startsize", "30");

		DispatchKeyValue(Flame, "EndSize", "250");

		DispatchKeyValue(Flame, "Rate", "40");

		DispatchKeyValue(Flame, "JetLength", "200");

		DispatchKeyValue(Flame, "RenderColor", "180 120 8");

		DispatchKeyValue(Flame, "RenderAmt", "250");

		//Set Owner
		SetEntPropEnt(Flame, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Flame);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Flame, Position, Angles, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Flame, "SetParent", Ent, Flame, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Flame, "SetParentAttachment", Flame, Flame, 0);
		}

		//Spark:
		AcceptEntityInput(Flame, "TurnOn");

		//Return:
		return Flame;
	}

	//Return:
	return -1;
}

public int CreateEnvFireExtinguisher(int Ent, char[] Attachment, float Angles[3])
{

	//Declare:
	int Extinguisher = CreateEntityByName("env_steam");

	//Check:
	if(IsValidEdict(Extinguisher) && IsValidEdict(Extinguisher))
	{

		//Dispatch:
		DispatchKeyValue(Extinguisher, "SpawnFlags", "1");

		DispatchKeyValue(Extinguisher, "Type", "0");

		DispatchKeyValue(Extinguisher, "InitialState", "1");

		DispatchKeyValue(Extinguisher, "Spreadspeed", "20");

		DispatchKeyValue(Extinguisher, "Speed", "800");

		DispatchKeyValue(Extinguisher, "Startsize", "30");

		DispatchKeyValue(Extinguisher, "EndSize", "250");

		DispatchKeyValue(Extinguisher, "Rate", "40");

		DispatchKeyValue(Extinguisher, "JetLength", "200");

		DispatchKeyValue(Extinguisher, "RenderColor", "120 120 255");

		DispatchKeyValue(Extinguisher, "RenderAmt", "250");

		//Set Owner
		SetEntPropEnt(Extinguisher, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Extinguisher);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Extinguisher, Position, Angles, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Extinguisher, "SetParent", Ent, Extinguisher, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Extinguisher, "SetParentAttachment", Extinguisher, Extinguisher, 0);
		}

		//Spark:
		AcceptEntityInput(Extinguisher, "TurnOn");

		//Return:
		return Extinguisher;
	}

	//Return:
	return -1;
}

public int CreateEnvAr2Explosion(int Ent, char[] Attachment, char[] Material)
{

	//Declare:
	int Ar2Explosion = CreateEntityByName("env_ar2explosion");

	//Check:
	if(IsValidEdict(Ar2Explosion) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Ar2Explosion, "Material", Material);

		//Set Owner
		SetEntPropEnt(Ar2Explosion, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Ar2Explosion);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Ar2Explosion, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Ar2Explosion, "SetParent", Ent, Ar2Explosion, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Ar2Explosion, "SetParentAttachment", Ar2Explosion, Ar2Explosion, 0);
		}

		//Accept:
		AcceptEntityInput(Ar2Explosion, "explode");

		//Return:
		return Ar2Explosion;
	}

	//Return:
	return -1;
}

public int CreateEnvAlyxEmp(int Ent, char[] Attachment, char[] Type, char[] TargetName)
{

	//Declare:
	int AlyxEmp = CreateEntityByName("env_alyxemp");

	//Check:
	if(IsValidEdict(AlyxEmp) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(AlyxEmp, "Type", Type);

		DispatchKeyValue(AlyxEmp, "SetTargetEnt", TargetName);

		//Set Owner
		SetEntPropEnt(AlyxEmp, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(AlyxEmp);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(AlyxEmp, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(AlyxEmp, "SetParent", Ent, AlyxEmp, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(AlyxEmp, "SetParentAttachment", AlyxEmp, AlyxEmp, 0);
		}

		//Set String:
		SetVariantString(TargetName);

		//Accept:
		AcceptEntityInput(AlyxEmp, "SetTargetEnt");

		//Accept:
		AcceptEntityInput(AlyxEmp, "startdischarge");

		//Return:
		return AlyxEmp;
	}

	//Return:
	return -1;
}

public int CreateEnvLightGlow(int Ent, char[] Attachment, char[] Color, char[] VerticalGlowSize, char[] HorizontalGlowSize, char[] MinDist, char[] MaxDist, char[] OuterMaxDist, char[] GlowProxySize)
{

	//Declare:
	int LightGlow = CreateEntityByName("env_lightglow");

	//Check:
	if(IsValidEdict(LightGlow) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(LightGlow, "RenderColor", Color);

		DispatchKeyValue(LightGlow, "VerticalGlowSize", VerticalGlowSize);

		DispatchKeyValue(LightGlow, "HorizontalGlowSize", HorizontalGlowSize);

		DispatchKeyValue(LightGlow, "MinDist", MinDist);

		DispatchKeyValue(LightGlow, "MaxDist", MaxDist);

		DispatchKeyValue(LightGlow, "OuterMaxDist", OuterMaxDist);

		DispatchKeyValue(LightGlow, "GlowProxySize", GlowProxySize);

		//Set Owner
		SetEntPropEnt(LightGlow, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(LightGlow);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(LightGlow, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(LightGlow, "SetParent", Ent, LightGlow, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(LightGlow, "SetParentAttachment", LightGlow, LightGlow, 0);
		}

		//Return:
		return LightGlow;
	}

	//Return:
	return -1;
}

// Thanks to V0gelz Edited By Master(D)
stock int CreateEnvShooter(int Ent, char[] Attachment, float Angles[3], float iGibs,float Delay, float GibAngles[3], float Velocity, float Variance, float Giblife, char[] ModelType)
{
	//Declare:
	int Shooter = CreateEntityByName("env_shooter");

	//Check:
	if(IsValidEdict(Shooter) && IsValidEdict(Ent))
	{

		// Gib Direction (Pitch Yaw Roll) - The direction the gibs will fly. 
		DispatchKeyValueVector(Shooter, "angles", Angles);

		// Number of Gibs - Total number of gibs to shoot each time it's activated
		DispatchKeyValueFloat(Shooter, "m_iGibs", iGibs);

		// Delay between shots - Delay (in seconds) between shooting each gib. If 0, all gibs shoot at once.
		DispatchKeyValueFloat(Shooter, "delay", Delay);

		// <angles> Gib Angles (Pitch Yaw Roll) - The orientation of the spawned gibs. 
		DispatchKeyValueVector(Shooter, "gibangles", GibAngles);

		// Gib Velocity - Speed of the fired gibs. 
		DispatchKeyValueFloat(Shooter, "m_flVelocity", Velocity);

		// Course Variance - How much variance in the direction gibs are fired. 
		DispatchKeyValueFloat(Shooter, "m_flVariance", Variance);

		// Gib Life - Time in seconds for gibs to live +/- 5%. 
		DispatchKeyValueFloat(Shooter, "m_flGibLife", Giblife);
		
		// <choices> Used to set a non-standard rendering mode on this entity. See also 'FX Amount' and 'FX Color'. 
		DispatchKeyValue(Shooter, "rendermode", "5");

		// Model - Thing to shoot out. Can be a .mdl (model) or a .vmt (material/sprite). 
		DispatchKeyValue(Shooter, "shootmodel", ModelType);

		// <choices> Material Sound
		DispatchKeyValue(Shooter, "shootsounds", "-1"); // No sound

		// <choices> Simulate, no idea what it realy does tbh...
		// could find out but to lazy and not worth it...
		//DispatchKeyValue(Shooter, "simulation", "1");

		SetVariantString("spawnflags 4");
		AcceptEntityInput(Shooter, "AddOutput");

		//Activate:
		ActivateEntity(Shooter);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Shooter, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Shooter, "SetParent", Ent, Shooter, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Shooter, "SetParentAttachment", Shooter, Shooter, 0);
		}

		//Input:
		AcceptEntityInput(Shooter, "Shoot", Ent);

		//Return:
		return Shooter;
	}

	//Return:
	return -1;
}

public int CreatePointPush(int Ent, char[] Attachment, char[] Radius, char[] InnerRadius, char[] Magnitude)
{

	//Declare:
	int Push = CreateEntityByName("point_push");

	//Check:
	if(IsValidEdict(Push) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Push, "Radius", Radius);

		DispatchKeyValue(Push, "Inner_Radius", InnerRadius);

		DispatchKeyValue(Push, "Magnitude", Magnitude);

		DispatchKeyValue(Push, "SpawnFlags", "28");

		//Set Owner
		SetEntPropEnt(Push, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Push);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Push, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Push, "SetParent", Ent, Push, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Push, "SetParentAttachment", Push, Push, 0);
		}

		//Return:
		return Push;
	}

	//Return:
	return -1;
}

//Model = sprites/laser.vmt/ sprites/light_glow02_add_noz.vmt "sprites/steam1.vmt sprites/blueglow2.vmt
//RenderMode = 5
//RenderAmt = 255
//LifeTime = 3
//StartWidth = 5
//EndWidth = 1
public int CreateEnvSpriteTrail(int Ent, char[] Attachment, char[] ModelName, char[] Mode, char[] RenderAmt, char[] LifeTime, char[] StartWidth, char[] EndWidth, int R, int G, int B)
{

	//Declare:
	int SpriteTrail = CreateEntityByName("env_spritetrail");

	//Create:
	if(IsValidEdict(SpriteTrail))
	{

		//Declare:
		char Color[32];

		//Format:
		Format(Color, sizeof(Color), "%i %i %i", R, G, B);

		//Dispatch:
		DispatchKeyValue(SpriteTrail, "spritename", ModelName);

		DispatchKeyValue(SpriteTrail, "rendermode", Mode);

		DispatchKeyValue(SpriteTrail, "renderamt", RenderAmt);

		DispatchKeyValue(SpriteTrail, "lifetime", LifeTime);

		DispatchKeyValue(SpriteTrail, "rendercolor", Color);

		DispatchKeyValue(SpriteTrail, "startwidth", StartWidth);

		DispatchKeyValue(SpriteTrail, "endwidth", EndWidth);

		//Set Owner
		SetEntPropEnt(SpriteTrail, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(SpriteTrail);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(SpriteTrail, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SpriteTrail, "SetParent", Ent, SpriteTrail, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SpriteTrail, "SetParentAttachment", SpriteTrail ,SpriteTrail, 0);
		}

		//Accept:
		AcceptEntityInput(SpriteTrail, "enable");

		AcceptEntityInput(SpriteTrail, "ShowSprite");

		//Return:
		return SpriteTrail;
	}

	//Return:
	return - 1;
}

public int CreateEnvSpriteOrientaded(int Ent, char[] Attachment, char[] Model, char[] Scale, int R, int G, int B)
{

	//Declare:
	int SpriteOrientaded = CreateEntityByName("env_Sprite_orientaded");

	//Create:
	if(IsValidEdict(SpriteOrientaded))
	{

		//Declare:
		char Color[32];

		//Format:
		Format(Color, sizeof(Color), "%i %i %i", R, G, B);

		//Dispatch:
		DispatchKeyValue(SpriteOrientaded, "rendercolor", Color);

		DispatchKeyValue(SpriteOrientaded, "rendermode", "5");

		DispatchKeyValue(SpriteOrientaded, "spawnflags", "1");

		DispatchKeyValue(SpriteOrientaded, "Scale", Scale);

		DispatchKeyValue(SpriteOrientaded, "model", Model);

		//Set Owner
		SetEntPropEnt(SpriteOrientaded, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(SpriteOrientaded);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(SpriteOrientaded, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SpriteOrientaded, "SetParent", Ent, SpriteOrientaded, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SpriteOrientaded, "SetParentAttachment", SpriteOrientaded ,SpriteOrientaded, 0);
		}

		//Accept:
		AcceptEntityInput(SpriteOrientaded, "enable");

		//Return:
		return SpriteOrientaded;
	}

	//Return:
	return - 1;
}

public int CreateEnvCitadelEnergyCore(int Ent, char[] Attachment, char[] Scale, char[] ChangeState)
{

	//Initulize::
	int EnergyCore = CreateEntityByName("env_citadel_energy_core");

	//Is Valid:
	if(IsValidEdict(EnergyCore))
	{

		//Dispatch:
		DispatchKeyValue(EnergyCore, "scale", Scale);

		DispatchKeyValue(EnergyCore, "StartCharge", ChangeState);

		//Set Owner
		SetEntPropEnt(EnergyCore, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(EnergyCore);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(EnergyCore, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(EnergyCore, "SetParent", Ent, EnergyCore, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(EnergyCore, "SetParentAttachment", EnergyCore ,EnergyCore, 0);
		}

		//Accept:
		AcceptEntityInput(EnergyCore, "enable");

		//Return:
		return EnergyCore;
	}

	//Return:
	return - 1;
}

public int CreateEnvFlare(int Ent, char[] Attachment, char[] Scale)
{

	//Initulize::
	int Flare = CreateEntityByName("env_flare");

	//Is Valid:
	if(IsValidEdict(Flare))
	{

		//Dispatch:
		DispatchKeyValue(Flare, "scale", Scale);

		DispatchKeyValue(Flare, "spawnflags", "4");

		//Set Owner
		SetEntPropEnt(Flare, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn
		DispatchSpawn(Flare);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Flare, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Flare, "SetParent", Ent, Flare, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Flare, "SetParentAttachment", Flare ,Flare, 0);
		}

		//Accept:
		AcceptEntityInput(Flare, "enable");

		//Spawn:
		DispatchSpawn(Flare);

		//Return:
		return Flare;
	}

	//Return:
	return - 1;
}

public int CreateEnvStarField(int Ent, char[] Attachment, float Density)
{

	//Declare:
	int StarField = CreateEntityByName("env_starfield");

	//Check:
	if(IsValidEdict(StarField))
	{

		//Set:
		SetVariantFloat(Density);

		//Accept:
		AcceptEntityInput(StarField, "SetDensity");

		AcceptEntityInput(StarField, "TurnOn");

		//Spawn:
		DispatchSpawn(StarField);

		//Check:
		if(Ent > 0 && IsValidEdict(Ent))
		{

			//Set Owner
			SetEntPropEnt(StarField, Prop_Send, "m_hOwnerEntity", Ent);

			//Declare:
			float Position[3];

			//Initulize:
			GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

			//Teleport:
			TeleportEntity(StarField, Position, NULL_VECTOR, NULL_VECTOR);

			//Set String:
			SetVariantString("!activator");

			//Accept:
			AcceptEntityInput(StarField, "SetParent", Ent, StarField, 0);

			//Check:
			if(!StrEqual(Attachment, "null"))
			{

				//Attach:
				SetVariantString(Attachment);

				//Accept:
				AcceptEntityInput(StarField, "SetParentAttachment", StarField, StarField, 0);
			}
		}

		//Return:
		return StarField;
	}

	//Return:
	return -1;
}

public int CreateEnvExplosion(int Ent, char[] Attachment, float fMagnitude, int Radius)
{

	//Declare:
	int Explosion = CreateEntityByName("env_explosion");

	//Check:
	if(IsValidEdict(Explosion) && IsValidEdict(Ent))
	{

		//Set Sprite Material Used for explosion Effect:
		SetEntProp(Explosion, Prop_Data, "m_sFireballSprite", Explode());

		// The amount of damage done by the explosion:
		SetEntProp(Explosion, Prop_Data, "m_iMagnitude", RoundToNearest(fMagnitude));

		// If specified, the radius in which the explosion damages entities. If unspecified, the radius will be based on the magnitude:
		SetEntProp(Explosion, Prop_Data, "m_iRadiusOverride", Radius);

		// Damagetype:
		SetEntProp(Explosion, Prop_Data, "m_iCustomDamageType", DMG_BLAST);

		//Render:
		SetEntProp(Explosion, Prop_Data, "m_nRenderMode", 5); // Additive

		//Set Owner
		SetEntPropEnt(Explosion, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Explosion);

		//Declare:
		float Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Explosion, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Explosion, "SetParent", Ent, Explosion, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Explosion, "SetParentAttachment", Explosion, Explosion, 0);
		}

		//Accept:
		AcceptEntityInput(Explosion, "Explode", Ent, Ent);

		//Timer:
		CreateTimer(0.5, RemoveEnvExplosion, Explosion);

		//Return:
		return Explosion;
	}

	//Return:
	return -1;
}

public Action RemoveEnvExplosion(Handle Timer, any Ent)
{

	//Check:
	if(IsValidEdict(Ent))
	{

		//Remove Ent:
		RemoveEdict(Ent);
	}
}

public Action CreateExplosion(int Ent, int Ent2)
{

	//Declare:
	float Origin[3];

	//Get Prop Data:
	GetEntPropVector(Ent2, Prop_Send, "m_vecOrigin", Origin);

	//Create Effect:
	CreateEnvExplosion(Ent2, "null", 1000.0, 500);

	//Emit Sound:
	EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

	//CreateDamage:
	ExplosionDamage(Ent, Ent2, Origin, DMG_SHOCK);

	/*//Temp Ent:
	//TE_SetupExplosion(Origin, Smoke(), 10.0, 1, 0, 100, 5000);

	//Send:
	//TE_SendToAll();

	//Temp Ent:
	//TE_SetupExplosion(Origin, Explode(), 5.0, 1, 0, 600, 5000);

	//Send:
	//TE_SendToAll();*/
}

public Action ExplosionDamage(int Ent, int Ent2, float Origin[3], int DamageType)
{

	//Initulize:
	Origin[2] += 5.0;

	//Declare:
	decl Float:AllEntOrigin[3]; new Float:Damage = 0.0;

	//Loop:
	for (new i = 1; i < 2047; i++)
	{

		//Connected:
		if(i > 0 && i <= GetMaxClients() && IsClientConnected(i) && IsClientInGame(i))
		{

			//Initulize:
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

			AllEntOrigin[2] += 15.0;
 
			//Declare:
			float Dist = GetVectorDistance(Origin, AllEntOrigin);

			//In Distance:
			if(Dist <= 225 && IsTargetInLineOfSight(Ent2, i))
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

					//SDKHooks Forward:
					SDKHooks_TakeDamage(i, Ent, Ent2, Damage, DamageType);
				}
			}
		}

		if(i > GetMaxClients() && i != Ent2 && IsValidEdict(i))
		{

			//Declare:
			char ClassName[32];

			//Get Entity Info:
			GetEdictClassname(i, ClassName, sizeof(ClassName));

			//Valid Check:
			if(!IsValidNpc(i) && IsValidDymamicNpc(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					SDKHooks_TakeDamage(i, Ent, Ent2, Damage, DamageType);
				}
			}

			//Prop Generator:
			if(StrEqual(ClassName, "prop_Generator"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientGenerator(i, Damage, Ent);
				}
			}

			//Prop BitCoin Mine:
			if(StrEqual(ClassName, "prop_BitCoin_Mine"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBitCoinMine(i, Damage, Ent);
				}
			}

			//Prop Printer:
			if(StrEqual(ClassName, "prop_Money_Printer"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPrinter(i, Damage, Ent);
				}
			}

			//Prop Battery:
			if(StrEqual(ClassName, "prop_Battery"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBattery(i, Damage, Ent);
				}
			}

			//Prop Kitchen Meth:
			if(StrEqual(ClassName, "prop_Kitchen_Meth"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientMeth(i, Damage, Ent);
				}
			}

			//Prop Propane Tank:
			if(StrEqual(ClassName, "prop_Propane_Tank"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPropaneTank(i, Damage, Ent);
				}
			}

			//Prop Phosphoru Tank:
			if(StrEqual(ClassName, "prop_Phosphoru_Tank"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPhosphoruTank(i, Damage, Ent);
				}
			}

			//Prop Sodium Tub:
			if(StrEqual(ClassName, "prop_Sodium_Tub"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientSodiumTub(i, Damage, Ent);
				}
			}

			//Prop HcAcid Tub:
			if(StrEqual(ClassName, "prop_HcAcid_Tub"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientHcAcidTub(i, Damage, Ent);
				}
			}

			//Prop Plant Plant:
			if(StrEqual(ClassName, "prop_Plant_Plant"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPlant(i, Damage, Ent);
				}
			}

			//Prop Drug Seeds:
			if(StrEqual(ClassName, "prop_Drug_Seeds"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientSeeds(i, Damage, Ent);
				}
			}

			//Prop Drug Lamp:
			if(StrEqual(ClassName, "prop_Drug_Lamp"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientLamp(i, Damage, Ent);
				}
			}

			//Prop Drug Bong:
			if(StrEqual(ClassName, "prop_Drug_Bong"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBong(i, Damage, Ent);
				}
			}

			//Prop Kitchen Cocain:
			if(StrEqual(ClassName, "prop_Kitchen_Cocain"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientCocain(i, Damage, Ent);
				}
			}

			//Prop Erythroxylum:
			if(StrEqual(ClassName, "prop_Erythroxylum"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientErythroxylum(i, Damage, Ent);
				}
			}

			//Prop Benzocaine:
			if(StrEqual(ClassName, "prop_Benzocaine"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBenzocaine(i, Damage, Ent);
				}
			}

			//Prop Kitchen Pills:
			if(StrEqual(ClassName, "prop_Kitchen_Pills"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPills(i, Damage, Ent);
				}
			}

			//Prop Toulene:
			if(StrEqual(ClassName, "prop_Toulene"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientToulene(i, Damage, Ent);
				}
			}

			//Prop SAcid Tub:
			if(StrEqual(ClassName, "prop_SAcid_Tub"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientSAcidTub(i, Damage, Ent);
				}
			}

			//Prop Ammonia:
			if(StrEqual(ClassName, "prop_Ammonia"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientAmmonia(i, Damage, Ent);
				}
			}

			//Prop Shield:
			if(StrEqual(ClassName, "prop_Shield"))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				float Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					SDKHooks_TakeDamage(i, Ent, Ent2, Damage, DMG_SHOCK);
				}
			}
		}
	}
}
