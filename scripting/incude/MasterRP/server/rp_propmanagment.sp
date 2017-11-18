//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_propmanagment_included_
  #endinput
#endif
#define _rp_propmanagment_included_

#define MAXINDEX		2047
#define MAXSPAWNEDTIME		30

int PropNumbIndex = 0;
int PropSpawnedTime[MAXINDEX] = {-1,...};

public void ResetIndexNumbAfterMapStart()
{

	//Initulize:
	PropNumbIndex = CheckMapEntityCount();

	//Loop:
	for(int X = 1; X < MAXINDEX; X++)
	{

		//Initulize:
		PropSpawnedTime[X] = -1;
	}
}

public void initPropSpawnedTime()
{

	//Loop:
	for(int X = 1; X < MAXINDEX; X++)
	{

		//Check:
		if(PropSpawnedTime[X] > 0)
		{

			//Initulize:
			PropSpawnedTime[X] += 1;

			//Check:
			if(PropSpawnedTime[X] >= MAXSPAWNEDTIME)
			{

				//Remove Prop:
				RemoveProp(X);
			}
		}
	}
}

public void RemoveProp(int Ent)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Prop Garbage:
	if(StrEqual(ClassName, "prop_Garbage"))
	{

		//Initlize:
		SetGarbageOnMap(GetGarbageOnMap() - 1);
	}

	//Is Money:
	if(GetDroppedMoneyValue(Ent))
	{

		//Initulize:
		SetDroppedMoneyValue(Ent, 0);
	}

	//Loop Items:
	for(int X = 1; X <= 400; X++)
	{

		//Check:
		if(GetDroppedItemValue(Ent, X) > 0)
		{

			//Initulize:
			SetDroppedItemValue(Ent, X, 0);
		}
	}

	//Kill:
	AcceptEntityInput(Ent, "Kill");
}

public int GetPropSpawnedTimer(Ent)
{

	//Return:
	return PropSpawnedTime[Ent];
}

public void SetPropSpawnedTimer(int Ent, int Value)
{

	//Check:
	if(Value > 0 && Value < MAXINDEX)
	{

		//Initulize:
		PropSpawnedTime[Ent] = Value;
	}

	//Override:
	else
	{

		//Initulize:
		PropSpawnedTime[Ent] = -1;
	}
}

public int GetPropIndex()
{

	//Return:
	return PropNumbIndex;
}

public void SetPropIndex(int Value)
{

	//Initulize:
	PropNumbIndex = Value;
}