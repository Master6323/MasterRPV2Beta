//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_tracers_included_
  #endinput
#endif
#define _rp_tracers_included_

#define MINCRIMETRACE 		5000

public void OnClientShowTracers(Client)
{

	//Declare:
	int BeamColor[4];
	float ClientOrigin[3];
	bool FoundItem = false;
	int ColorEnt[4] = {255, 255, 120, 255};

	//Initulize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Initulize:
	BeamColor[3] = 255;

	//Setup Cop Tracer:
	if((IsCop(Client) || IsAdmin(Client)))
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && Client != i)
			{

				//Is Cop + Beam Can Use:
				if(IsPlayerAlive(i) && GetCrime(Client) > MINCRIMETRACE && GetCrimeTracer(Client) == 1 && GetPoliceJammerTime(i) < GetGameTime())
				{

					//Declare:
					float CriminalOrigin[3];

					//Initulize:
					GetClientAbsOrigin(i, CriminalOrigin);

					//Override:
					if(GetBounty(i) > 0 && GetBountyTracer(Client) == 1)
					{

						//Initialize:
						BeamColor[0] = 255;
						BeamColor[1] = 50;
						BeamColor[2] = 50;
					}

					//Override:
					else
					{

						//Initialize:
						BeamColor[0] = 255;
						BeamColor[1] = 255;
						BeamColor[2] = 50;
					}

					//Initulize:
					CriminalOrigin[2] += 40.0;

					//EntCheck:
					if(CheckMapEntityCount() < 2047)
					{

						//End Temp:
						TE_SetupBeamPoints(ClientOrigin, CriminalOrigin, Laser(), 0, 0, 66, 0.25, 1.0, 3.0, 0, 0.0, BeamColor, 0);

						//Show To Client:
						TE_SendToClient(Client);
					}
				}
			}
		}
	}

	//Override:
	else if(GetBountyTracer(Client) == 1)
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && Client != i)
			{

				//Is Cop + Beam Can Use:
				if(IsPlayerAlive(i) && GetBounty(i) > 0 && GetBountyJammerTime(i) < GetGameTime())
				{

					//Declare:
					float CriminalOrigin[3];

					//Initulize:
					GetClientAbsOrigin(i, CriminalOrigin);

					//Initialize:
					BeamColor[0] = 255;
					BeamColor[1] = 50;
					BeamColor[2] = 50;

					//Initulize:
					CriminalOrigin[2] += 40.0;

					//EntCheck:
					if(CheckMapEntityCount() < 2047)
					{

						//End Temp:
						TE_SetupBeamPoints(ClientOrigin, CriminalOrigin, Laser(), 0, 0, 66, 0.25, 1.0, 3.0, 0, 0.0, BeamColor, 0);

						//Show To Client:
						TE_SendToClient(Client);
					}
				}
			}
		}
	}

	//Override:
	else if(GetPoliceJammerTime(Client) < GetGameTime())
	{

		//Loop:
		for(int i = 1; i <= GetMaxClients(); i ++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i) && Client != i)
			{

				//Is Cop + Beam Can Use:
				if(IsPlayerAlive(i) && IsCop(i))
				{

					//Declare:
					float CopOrigin[3];

					//Initulize:
					GetClientAbsOrigin(i, CopOrigin);

					//Initialize:
					BeamColor[0] = 120;
					BeamColor[1] = 120;
					BeamColor[2] = 255;

					//Initulize:
					CopOrigin[2] += 40.0;

					//EntCheck:
					if(CheckMapEntityCount() < 2047)
					{

						//End Temp:
						TE_SetupBeamPoints(ClientOrigin, CopOrigin, Laser(), 0, 0, 66, 0.25, 1.0, 3.0, 0, 0.0, BeamColor, 0);

						//Show To Client:
						TE_SendToClient(Client);
					}
				}
			}
		}
	}

	//Has Player got Tracer Enabled:
	if(GetTrashTracer(Client) == 1)
	{

		//Declare:
		int Colorgarbage[4] = {50, 250, 50, 250};

		//Valid Check:
		if(StrContains(GetJob(Client), "Street Sweeper", false) != -1 || IsAdmin(Client))
		{

			//Declare:
			char ClassName[32];
			float GarbageOrigin[3];

			//Loop:
			for(int X = 0; X < 2047; X++)
			{

				//Is Valid:
				if(IsValidEdict(X) && IsValidEntity(X) && X != Client)
				{

					//Initulize:
					GetEntPropVector(X, Prop_Data, "m_vecOrigin", GarbageOrigin);

					//Initialize:
					float Dist = GetVectorDistance(ClientOrigin, GarbageOrigin);

					//In Distance:
					if(Dist <= 1200)
					{

						//Get Entity Info:
						GetEdictClassname(X, ClassName, sizeof(ClassName));

						//Prop Garbage:
						if(StrEqual(ClassName, "prop_Garbage"))
						{

							//EntCheck:
							if(CheckMapEntityCount() < 2047)
							{

								//End Temp:
								TE_SetupBeamPoints(ClientOrigin, GarbageOrigin, Laser(), 0, 0, 66, 0.25, 1.0, 3.0, 0, 0.0, Colorgarbage, 0);

								//Show To Client:
								TE_SendToClient(Client);
							}
						}
					}
				}
			}
		}
	}

	//Has Player got Item/Money Dectector Enabled:
	if(GetItemDetector(Client) > 0)
	{

		//Loop:
		for(int X = 0; X < 2047; X++)
		{

			//Is Valid:
			if(IsValidEdict(X))
			{

				//Is Money:
				if(GetDroppedMoneyValue(X) > 0 && GetItemDetector(Client) == 1)
				{

					//Declare:
					float EntOrigin[3];

					//Initulize:
					GetEntPropVector(X, Prop_Data, "m_vecOrigin", EntOrigin);

					//Initialize:
					float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

					//In Distance:
					if(Dist <= 800)
					{

						//EntCheck:
						if(CheckMapEntityCount() < 2047)
						{

							//Show To Client:
							TE_SetupBeamRingPoint(EntOrigin, 1.0, 20.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, ColorEnt, 10, 0);

							//End Temp:
							TE_SendToClient(Client);

							//Initulize:
							FoundItem = true;
						}
					}
				}

				//Loop:
				if(GetItemDetector(Client) == 2) for(int Y = 0; Y <= 400; Y++)
				{

					//Is Money:
					if(GetDroppedItemValue(X, Y) > 0)
					{

						//Declare:
						float EntOrigin[3];

						//Initulize:
						GetEntPropVector(X, Prop_Data, "m_vecOrigin", EntOrigin);

						//Initialize:
						float Dist = GetVectorDistance(ClientOrigin, EntOrigin);

						//In Distance:
						if(Dist <= 800)
						{

							//Show To Client:
							TE_SetupBeamRingPoint(EntOrigin, 1.0, 20.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, ColorEnt, 10, 0);

							//End Temp:
							TE_SendToClient(Client);

							//Initulize:
							FoundItem = true;
						}
					}
				}
			}
		}
	}

	//Check:
	if(FoundItem == true && GetPing(Client) == 1)
	{

		//Play Sound:
		EmitSoundToClient(Client, "npc/turret_floor/ping.wav", SOUND_FROM_PLAYER, 5);
	}
}

//Crime Hud:
public void ShowIllegalItemToCops(float Origin[3])
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Is Cop:
			if(IsCop(i) || IsAdmin(i))
			{

				//Declare:
				float ClientOrigin[3];

				//Initialize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

				//Initialize:
				float Dist = GetVectorDistance(ClientOrigin, Origin);

				//In Distance:
				if(Dist <= 800)
				{

					//Declare:
					int Color[4] = {255, 50, 50, 250};

					//Show To Client:
					TE_SetupBeamRingPoint(Origin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, Color, 10, 0);

					//End Temp:
					TE_SendToClient(i);
				}
			}
		}
	}
}

public void ShowItemToAll(float Origin[3])
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Declare:
			float ClientOrigin[3];

			//Initialize:
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

			//Initialize:
			float Dist = GetVectorDistance(ClientOrigin, Origin);

			//In Distance:
			if(Dist <= 800)
			{

				//Declare:
				int Color[4] = {255, 50, 50, 250};

				//Show To Client:
				TE_SetupBeamRingPoint(Origin, 1.0, 30.0, Laser(), Sprite(), 0, 10, 0.7, 10.0, 0.5, Color, 10, 0);

				//End Temp:
				TE_SendToClient(i);
			}
		}
	}
}
