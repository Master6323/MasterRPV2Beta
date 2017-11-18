//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_attachedeffects_included_
  #endinput
#endif
#define _rp_attachedeffects_included_

#define MAXEFFECTS 		10

int ElecticEffectEnt[2047][MAXEFFECTS + 1];

public void ResetEffects()
{

	//Loop:
	for(int X = 0; X < 2047; X++) for(int Y = 0; Y <= MAXEFFECTS; Y++)
	{

		ElecticEffectEnt[X][Y] = -1;
	}
}

public int GetEntAttatchedEffect(int Ent, int Slot)
{

	//Return:
	return ElecticEffectEnt[Ent][Slot];
}

public void SetEntAttatchedEffect(int Ent, int Slot, int AttachedEnt)
{

	//Initulize:
	ElecticEffectEnt[Ent][Slot] = AttachedEnt;
}

public bool IsValidAttachedEffect(int Ent)
{

	//Loop:
	for(int Y = 0; Y <= MAXEFFECTS; Y++)
	{

		//Check:
		if(Ent > 0 && Ent < 2047)
		{

			//Is Valid:
			if(ElecticEffectEnt[Ent][Y] > 0)
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

public Action RemoveAttachedEffect(int Ent)
{

	//Loop:
	for(int  Y = 0; Y <= MAXEFFECTS; Y++)
	{

		if(IsValidEdict(ElecticEffectEnt[Ent][Y]))
		{

			//Accept:
			AcceptEntityInput(ElecticEffectEnt[Ent][Y], "Kill");
		}

		//Initulize:
		ElecticEffectEnt[Ent][Y] = -1;
	}
}

public int FindAttachedPropFromEnt(int Ent)
{

	//Loop:
	for(int X = 0; X < 2047; X++) for(int Y = 0; Y <= MAXEFFECTS; Y++)
	{

		//Checl:
		if(ElecticEffectEnt[X][Y] == Ent)
		{

			//Return:
			return X;
		}
	}

	//Return:
	return -1;
}

public int FindClientFromAttachedEnt(int Ent)
{

	//Loop:
	for(int i = 1; i <= GetMaxClients(); i++) for(int Y = 0; Y <= MAXEFFECTS; Y++)
	{

		//Checl:
		if(ElecticEffectEnt[i][Y] == Ent)
		{

			//Return:
			return Y;
		}
	}

	//Return:
	return -1;
}

public int FindEntitySlot(int Ent)
{

	//Loop:
	for(int Y = 0; Y <= MAXEFFECTS; Y++)
	{

		//Check:
		if(Ent > 0 && Ent < 2047)
		{

			//Is Valid:
			if(ElecticEffectEnt[Ent][Y] == Ent)
			{

				//Return:
				return Y;
			}
		}
	}

	//Return:
	return -1;
}
