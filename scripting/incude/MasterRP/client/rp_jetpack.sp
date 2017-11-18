//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jetpack_included_
  #endinput
#endif
#define _rp_jetpack_included_

char JetpackFlySound[256] = "vehicles/airboat/fan_blade_fullthrottle_loop1.wav";
bool JetPack[MAXPLAYERS + 1] = {false,...};
bool JetPackEnabled[MAXPLAYERS + 1] = {false,...};
int JetPackEffect[MAXPLAYERS + 1] = {-1,...};
int JetPackEnt[MAXPLAYERS + 1] = {-1,...};

public void intJetPack()
{

	//Commands:
	RegConsoleCmd("sm_jetpack", Command_JetPack);

	//Commands:
	RegConsoleCmd("+sm_jetpack", JetpackP, "", FCVAR_GAMEDLL);

	RegConsoleCmd("-sm_jetpack", JetpackM, "", FCVAR_GAMEDLL);
}

public void initDefaultJetpack(int Client)
{

	//Initulize:
	JetPack[Client] = false;

	JetPackEnabled[Client] = true;

	JetPackEnt[Client] = -1;

	JetPackEffect[Client] = 1;
}

//Int every 0.1 sec
public void initJetPackTimer(int Client, int Timer)
{

	//Check:
	if(JetPack[Client] == true)
	{

		//Is Player Alive:
		if(!IsPlayerAlive(Client))
		{

			//Stop:
			StopJetPack(Client);
		}

		//Override:
		else
		{

			//Jetpack:
			AddVelocity(Client, 160.0);
		}

		//Limit Timer to hud!
		if(Timer == 1 || Timer == 3 || Timer == 5 || Timer == 7 || Timer == 9)
		{

			//Effect:
			if(IsValidEdict(JetPackEnt[Client]))
			{

				//Effect:
				if(JetPackEffect[Client] == 2)
				{

					//Accept:
					AcceptEntityInput(JetPackEnt[Client], "TurnOn");

					AcceptEntityInput(JetPackEnt[Client], "DoSpark");
				}

				//Effect:
				if(JetPackEffect[Client] == 3)
				{

					//Accept:
					AcceptEntityInput(JetPackEnt[Client], "Splash");
				}

				//RofleChopter:
				if(JetPackEffect[Client] == 6)
				{

					//Initulize:
					RotateRofleChopter(JetPackEnt[Client], 120.0);
				}
			}

			//Ring Effect:
			if(JetPackEffect[Client] == 7)
			{

				//EntCheck:
				if(CheckMapEntityCount() < 1900)
				{

					//Declare:
					float Origin[3];

					//Initulize:
					GetEntPropVector(Client, Prop_Data, "m_vecOrigin", Origin);

					//Declare:
					int Color[4] = {255, 255, 255, 255};

					//Show To Client:
					TE_SetupBeamRingPoint(Origin, 1.0, 50.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, Color, 10, 0);

					//Show To Client:
					TE_SendToAll();
				}
			}

			//Spark Effect:
			if(JetPackEffect[Client] == 8)
			{

				//EntCheck:
				if(CheckMapEntityCount() < 1900)
				{

					//Declare:
					float Origin[3];

					//Initulize:
					GetEntPropVector(Client, Prop_Data, "m_vecOrigin", Origin);

					//Temp Ent:
					TE_SetupSparks(Origin, NULL_VECTOR, 5, 5);

					//Send:
					TE_SendToAll();
				}
			}
		}
	}
}

public Action JetpackP(int Client, int Args)
{

	//Check:
	if(IsAdmin(Client) || GetDonator(Client) > 0 || HasItemTypeInInventory(Client, 60))
	{

		//Check:
		if(JetPackEnabled[Client] == true)
		{

			//Check:
			if(IsPlayerAlive(Client))
			{

				//Declare:
				int InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

				//Is In Car:
				if(InVehicle == -1)
				{

					//Check:
					if(JetPack[Client] == false)
					{

						//Start:
						StartJetPack(Client);

						//Return:
						return Plugin_Handled;
					}
				}

				//Override:
				else
				{

					//Print:
					OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use a jetpack whilst your inside a car!!");
				}
			}

			//Override:
			else
			{

				//Print:
				OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You are dead you cannot use your jetpack!");
			}
		}

		//Override:
		else
		{

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have your jetpack Enabled!");
		}
	}

	//Override:
	else
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have access to this menu!");
	}

	//Stop:
	StopJetPack(Client);

	//Return:
	return Plugin_Handled;
}

public void StartJetPack(int Client)
{

	//Declare:
	float vecPos[3];

	//Initulize:
	GetClientAbsOrigin(Client, vecPos);

	//Emit Sound:
	EmitSoundToAll(JetpackFlySound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);

	//Set Move Type:
	SetClientMoveType(Client, 5);

	//Set Move Collide:
	SetClientMoveCollide(Client, 1);

	//Initulize:
	JetPack[Client] = true;

	//Default Jetpack:
	if(JetPackEffect[Client] == 1)
	{

		//Create Effect:
		JetPackEnt[Client] = CreateEnvSteam(Client, "null", "255 255 50", "255", "1", "20", "50", "15", "1", "15", "25", "20");
	}

	//Eletric Jetpack:
	if(JetPackEffect[Client] == 2)
	{

		//Is Client Cop:
		if(IsCop(Client))
		{

			//Create Effect:
			JetPackEnt[Client] = CreatePointTesla(Client, "null", "50 50 250");
		}

		//Override:
		else if(IsAdmin(Client))
		{

			//Create Effect:
			JetPackEnt[Client] = CreatePointTesla(Client, "null", "250 250 50");
		}

		//Override:
		else
		{

			//Create Effect:
			JetPackEnt[Client] = CreatePointTesla(Client, "null", "250 50 50");
		}
	}

	//Water Jetpack:
	else if(JetPackEffect[Client] == 3)
	{

		//Create Effect:
		JetPackEnt[Client] = CreateEnvSplash(Client, "null", "15");
	}

	//Fire Jetpack:
	else if(JetPackEffect[Client] == 4)
	{

	}

	//Trail Jetpack:
	else if(JetPackEffect[Client] == 5)
	{

	}

	//RofleChopter:
	else if(JetPackEffect[Client] == 6)
	{

		//Create Effect:
		JetPackEnt[Client] = CreateRofleChopter(Client);
	}

	//Ring Jetpack:
	else if(JetPackEffect[Client] == 7)
	{

	}

	//Spark Jetpack:
	else if(JetPackEffect[Client] == 8)
	{

	}

	//Jetpack:
	else if(JetPackEffect[Client] == 9)
	{

		//Create Effect:
		JetPackEnt[Client] = CreateJetPack(Client);
	}
}

public Action JetpackM(int Client, int Args)
{

	//Stop:
	StopJetPack(Client);

	//Return:
	return Plugin_Continue;
}

public void StopJetPack(int Client)
{

	//Check:
	if(JetPack[Client])
	{

		//Check:
		if(IsPlayerAlive(Client))
		{

			//Set Move Type:
			SetClientMoveType(Client, 2);

			//Set Move Collide:
			SetClientMoveCollide(Client, 1);
		}

		//Stop:
		StopSound(Client, SNDCHAN_AUTO, JetpackFlySound);

		//Initulize:
		JetPack[Client] = false;
	}

	//Check:
	if(IsValidEdict(JetPackEnt[Client]))
	{

		//Declare:
		int Effect = GetEntAttatchedEffect(Client, 5);

		//Check:
		if(IsValidEntity(Effect))
		{

			//Accept:
			AcceptEntityInput(Effect, "kill");

			//Remove Index:
			SetEntAttatchedEffect(Client, 5, -1);
		}

		//Check:
		if(IsValidAttachedEffect(JetPackEnt[Client]))
		{

			//Remove:
			RemoveAttachedEffect(JetPackEnt[Client]);
		}

		//Accept:
		AcceptEntityInput(JetPackEnt[Client], "kill");
	}
}

public void AddVelocity(int Client, float Speed)
{

	//Declare:
	float Origin[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Data, "m_vecVelocity", Origin);

	//Boost Client:
	Origin[2] = Speed;

	//Teleport:
	TeleportEntity(Client, NULL_VECTOR, NULL_VECTOR, Origin);
}

public bool IsJetpackOn(int Client)
{

	//Return:
	return JetPack[Client];
}

public void SetJetPackOn(int Client, bool Result)
{

	//Initulize:
	JetPack[Client] = Result;
}

public bool IsJetpackEnabled(int Client)
{

	//Return:
	return JetPackEnabled[Client];
}

public void SetJetPackEnabled(int Client, bool Result)
{

	//Initulize:
	JetPackEffect[Client] = Result;
}


public int GetJetPackEffect(int Client)
{

	//Return:
	return JetPackEffect[Client];
}

public void SetJetPackEffect(int Client, int Effect)
{

	//Initulize:
	JetPackEffect[Client] = Effect;
}

public int CreateRofleChopter(Client)
{

	//Declare:
	float Angles[3];
	float Position[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

	GetEntPropVector(Client, Prop_Data, "m_angRotation", Angles);

	//Initulize:
	Position[2] + 10;

	//Create Effect:
	int Ent = CreateProp(Position, Angles, "models/props_c17/trappropeller_blade.mdl", true, false, false);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(Ent, "SetParent", Client, Ent, 0);

	//Return:
	return Ent;
}

public int CreateJetPack(Client)
{

	//Declare:
	float Angles[3];
	float Position[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Position);

	GetEntPropVector(Client, Prop_Data, "m_angRotation", Angles);

	//Create Effect:
	int Ent = CreateProp(Position, Angles, "models/ice_dragon/jetpack/blue_jetpack.mdl", true, false, false);

	//Set String:
	SetVariantString("!activator");

	//Accept:
	AcceptEntityInput(Ent, "SetParent", Client, Ent, 0);

	//Attach:
	SetVariantString("chest");

	//Accept:
	AcceptEntityInput(Ent, "SetParentAttachment", Ent, Ent, 0);

	//Initulize:
	Position[0] = 0.0;
	Position[1] = 0.0;
	Position[2] = 0.0;

	//Calculate Just Behind the Player:
	GetPushBetweenEntities(Ent, -10.0, Position);

	//Teleport:
	TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);

	Angles[0] = 90.0;
	Angles[1] = 0.0;
	Angles[2] = 0.0;

	//Declare
	int Effect = CreateEnvFlame(Ent, "null", Angles);

	SetEntAttatchedEffect(Ent, 5, Effect);

	//Initulize:
	Position[0] = 0.0;
	Position[1] = 0.0;
	Position[2] = 0.0;

	//Calculate Just Behind the Player:
	GetPushBetweenEntities(Client, -10.0, Position);

	//Teleport:
	TeleportEntity(Effect, Position, NULL_VECTOR, NULL_VECTOR);

	//Initulize Effects:
	Effect = CreateLight(Ent, 1, 180, 120, 8, "null");

	SetEntAttatchedEffect(Ent, 6, Effect);

	//Initulize:
	Position[0] = 0.0;
	Position[1] = 0.0;
	Position[2] = 0.0;

	//Calculate Just Behind the Player:
	GetPushBetweenEntities(Client, -10.0, Position);

	//Teleport:
	TeleportEntity(Effect, Position, NULL_VECTOR, NULL_VECTOR);

	//SDKHOOK:
	SDKHook(Ent, SDKHook_SetTransmit, OnJetPackSetTransmit);

	//Return:
	return Ent;
}

public Action OnJetPackSetTransmit(int Ent, int Client)
{

	//Connected:
	if(Ent > 0 && IsValidEdict(Ent) && IsClientConnected(Client) && IsClientInGame(Client))
	{

		if(GetObserverMode(Client) == 5 || GetViewWearables(Client))
			return Plugin_Continue;

		if(GetObserverMode(Client) == 4 && GetObserverTarget(Client) >= 0)
				if(Ent == PlayerHat[GetObserverTarget(Client)])
					return Plugin_Handled;

		if(Ent == JetPackEnt[Client])
			return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}
public void RotateRofleChopter(int Ent, float Rotation)
{

	//Declare:
	float Angles[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Initulize:
	Angles[1] += Rotation;

	//Teleport:
	TeleportEntity(Ent, NULL_VECTOR, Angles, NULL_VECTOR);
}

public Action Command_JetPack(int Client, int Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");
	}

	//Is Colsole:
	if(!IsAdmin(Client) && GetDonator(Client) == 0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have access to this menu!");
	}

	//Override:
	else
	{

		//Show Menu:
		JetPackMenu(Client);
	}

	//Return:
	return Plugin_Handled;
}

public void JetPackMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleJetPackMenu);

	//Menu Title:
	menu.SetTitle("JetPack Settings Menu");

	//Declare:
	char State[128];

	//Format:
	Format(State, sizeof(State), "JetPack is %s", JetPackEnabled[Client] ? "Enabled" : "Disabled");

	//Menu Button:
	menu.AddItem("0", State);

	//Menu Button:
	menu.AddItem("1", "Jetpack Effect");

	//Set Exit Button:
	menu.ExitButton = false;

	//Show Menu:
	menu.Display(Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-JetPack|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Handle:
public int HandleJetPackMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Declare:
			int Result = StringToInt(info);

			//Button Selected:
			if(Result == 0)
			{

				//Is Valid:
				if(JetPackEnabled[Client] == false)
				{

					//Set JetPack Status:
					JetPackEnabled[Client] = true;

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-JetPack|\x07FFFFFF - JetPack has been Activated.");
				}

				//Override:
				else if(JetPackEnabled[Client] == true)
				{

					//Set JetPack Status:
					JetPackEnabled[Client] = false;

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-JetPack|\x07FFFFFF - JetPack has been Deactivated.");
				}

				//Declare:
				char query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Settings SET JetPack = %i WHERE STEAMID = %i;", boolToint(JetPackEnabled[Client]), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 16);
			}

			//Button Selected:
			if(Result == 1)
			{

				//Show Menu:
				JetPackEffectMenu(Client);
			}

			//Initulize:
			JetPackEffect[Client] = Result;
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}

public void JetPackEffectMenu(int Client)
{

	//Handle:
	Menu menu = CreateMenu(HandleJetPackEffectMenu);

	//Menu Title:
	menu.SetTitle("What Effect had would you like to put on?");

	//Check:
	if(IsAdmin(Client))
	{

		//Menu Button:
		menu.AddItem("1", "Normal");

		//Menu Button:
		menu.AddItem("2", "Eletric");

		//Menu Button:
		menu.AddItem("3", "Water");

		//Menu Button:
		menu.AddItem("4", "Fire");

		//Menu Button:
		menu.AddItem("5", "Trail");

		//Menu Button:
		menu.AddItem("7", "Ring");

		//Menu Button:
		menu.AddItem("8", "Spark");

		//Menu Button:
		menu.AddItem("6", "RofleChopter");

		//Menu Button:
		menu.AddItem("9", "JetPack");

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Has JetPack In Inventory:
	if(HasItemTypeInInventory(Client, 60))
	{

		//HasItem:
		if(GetItemAmount(Client, 379))
		{

			//Menu Button:
			menu.AddItem("1", "Normal");
		}

		//HasItem:
		if(GetItemAmount(Client, 380))
		{

			//Menu Button:
			menu.AddItem("2", "Eletric");
		}

		//HasItem:
		if(GetItemAmount(Client, 381))
		{

			//Menu Button:
			menu.AddItem("3", "Water");
		}

		//HasItem:
		if(GetItemAmount(Client, 382))
		{

			//Menu Button:
			menu.AddItem("4", "Fire");
		}

		//HasItem:
		if(GetItemAmount(Client, 383))
		{

			//Menu Button:
			menu.AddItem("5", "Trail");
		}

		//HasItem:
		if(GetItemAmount(Client, 384))
		{

			//Menu Button:
			menu.AddItem("7", "Ring");
		}

		//HasItem:
		if(GetItemAmount(Client, 385))
		{

			//Menu Button:
			menu.AddItem("8", "Spark");
		}

		//HasItem:
		if(GetItemAmount(Client, 386))
		{

			//Menu Button:
			menu.AddItem("6", "RofleChopter");
		}

		//HasItem:
		if(GetItemAmount(Client, 387))
		{

			//Menu Button:
			menu.AddItem("9", "JetPack!");
		}

		//Set Exit Button:
		menu.ExitButton = false;

		//Show Menu:
		menu.Display(Client, 30);
	}

	//Override:
	else
	{

		//Close:
		delete menu;
	}

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-JetPack|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Handle:
public int HandleJetPackEffectMenu(Menu menu, MenuAction HandleAction, int Client, int Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			char info[32];
			char display[255];

			//Get Menu Info:
			menu.GetItem(Parameter, info, sizeof(info), _, display, sizeof(display));

			//Declare:
			int Result = StringToInt(info);

			//Initulize:
			JetPackEffect[Client] = Result;

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your new JetPack Effect is a \x0732CD32%s!", display);

			//Declare:
			char query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET JetPackEffect = %i WHERE STEAMID = %i;", JetPackEffect[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, 17);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		delete menu;
	}

	//Return:
	return true;
}