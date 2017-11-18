//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorhardware_included_
  #endinput
#endif
#define _rp_vendorhardware_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//On Client Attempt To Sell Item:
public bool OnHardWareVendorTouch(int Ent, int OtherEnt)
{

	//Declare:
	char ClassName[32];

	//Get Entity Info:
	GetEdictClassname(OtherEnt, ClassName, sizeof(ClassName));

	//Prop Battery:
	if(StrEqual(ClassName, "prop_Battery"))
	{

		//Declare:
		int Client = GetBatteryOwnerFromEnt(OtherEnt);
		int Id = GetBatteryIdFromEnt(OtherEnt);

		//Check:
		if(GetBatteryEnergy(Client, Id) > 250.0)
		{

			//Declare:
			int AddCash = (RoundFloat(GetBatteryEnergy(Client, Id)) * 4);

			//Initulize:
			SetCash(Client, (GetCash(Client) + AddCash));

			//Remove From DB:
			RemoveSpawnedItem(Client, 23, Id);

			//Remove:
			RemoveBattery(Client, Id, false);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You have sold a battery for \x0732CD32%s\x07FFFFFF!", IntToMoney(AddCash));

			//Return:
			return true;
		}

		//Override:
		else
		{

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You can't sell this battery as it doesn't have enough charge!");
		}
	}

	//Return:
	return false;
}
