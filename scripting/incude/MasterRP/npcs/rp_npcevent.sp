//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcevent_included_
  #endinput
#endif
#define _rp_npcevent_included_

#define EVENTINTERVAL 		30
#define MAXDYNAMICSPAWNS	30
#define MAXNPCTYPES		10

int EventTimer = 0;

//Special NPC Events
public void InitNpcEvents()
{

	//Initluze:
	EventTimer -= 1;

	//Check:
	if(EventTimer <= 0)
	{

		if(GetNpcsOnMap() < 30)
		{

			//Declare:
			float Origin[3];
			float Angles[3] = {0.0,...};

			Angles[1] = GetRandomFloat(-360.0, 360.0);

			//Initulize
			EventTimer = EVENTINTERVAL;

			//Declare:
			new Random = GetRandomInt(1, 10);

			//Spawn Antlion Boss
			if(Random == 1)
			{

				//Initulize
				Random = GetRandomInt(1, 10);

				//Get Origin:
				GetDynamicNpcSpawn(Random, 1, Origin);
#if defined HL2DM
				CreateNpcAntLionGuard("null", Origin, Angles, 10000, 1);
#endif
			}

			//Spawn Vortigaunt:
			if(Random == 2)
			{

				//Initulize
				Random = GetRandomInt(5, 10);

				//Loop:
				for(int i = 1; i <= Random; i++)
				{

					//Get Origin:
					GetDynamicNpcSpawn(i, 1, Origin);
#if defined HL2DM
					CreateNpcVortigaunt("null", Origin, Angles, 200);
#endif
				}
			}
		}
	}
}