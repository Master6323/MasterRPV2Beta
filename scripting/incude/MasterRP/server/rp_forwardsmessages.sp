//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_forwardsmessages_included_
  #endinput
#endif
#define _rp_forwardsmessages_included_

//Event Connect:
public void OnClientConnectMessage(int Client)
{

	//Declare:
	char Auth[32];

	//Initialize:
	GetClientAuthId(Client, AuthId_Steam3, Auth, sizeof(Auth));

	//Masters root:
	if(SteamIdToInt(Client) == 30027290)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF the magnificent modder! ", Client);
	}

	//Is Admin:
	else if(IsAdmin(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) enterd the city ({olive}ADMIN\x07FFFFFF).", Client, Auth);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) enterd the city", Client, Auth);
	}
}

//Event Disconnect:
public void OnClientDisconnectMessage(int Client)
{

	//Declare:
	char Auth[32];

	//Initialize:
	GetClientAuthId(Client, AuthId_Steam3, Auth, sizeof(Auth));

	//Is Admin:
	if(IsAdmin(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) left the city ({olive}ADMIN\x07FFFFFF).", Client, Auth);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) left the city", Client, Auth);
	}
}

//Event Server Cvar Change:
public Action OnCvarChange(const char[] CvarName, const char[] CvarValue)
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Server Cvar '\x0732CD32%s\x07FFFFFF' changed to \x0732CD32%s\x07FFFFFF.", CvarName, CvarValue);
}
