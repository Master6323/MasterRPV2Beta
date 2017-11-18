//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cough_included_
  #endinput
#endif
#define _rp_cough_included_

//Random Cough:
public void initCough(int Client)
{

	//Initialize:
	int Random = GetRandomInt(1, 20);

	//Is Already Critical:
	if(Random == 1)
	{

		//Declare:
		char CoughSound[128] = "Null";

		//Initialize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(CoughSound, sizeof(CoughSound), "ambient/voices/cough%i.wav", Random);

		//Declare
		float vecPos[3];

		//Initulize:
		GetClientAbsOrigin(Client, vecPos);

		//Is Precached:
		if(IsSoundPrecached(CoughSound)) PrecacheSound(CoughSound);

		//Emit Sound:
		EmitSoundToAll(CoughSound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5, SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);
	}
}
