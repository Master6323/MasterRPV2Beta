//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_sql_included_
  #endinput
#endif
#define _rp_sql_included_

//Definitions:
#define SQLVERSION		"1.05.00"

//Database Sql:
Handle hDataBase = INVALID_HANDLE;

//Setup Sql Connection:
public void initSQL()
{

	//find Configeration:
	if(SQL_CheckConfig("RoleplayDB"))
	{

		//Print:
	     	PrintToServer("|DataBase| : Initial (CONNECTED)");

		//Sql Connect:
		SQL_TConnect(DBConnect, "RoleplayDB");
	}

	//Override:
	else
	{
#if defined DEBUG
		//Logging:
		LogError("|DataBase| : Invalid Configeration.");
#endif
	}
}

public void DBConnect(Handle owner, Handle hndl, const char[] error, any data)
{

	//Is Valid Handle:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("|DataBase| : %s", error);
#endif
		//Return:
		return;
	}

	//Override:
	else
	{

		//Copy Handle:
		hDataBase = hndl;

		//Declare:
		char SQLDriver[32];
		bool iSqlite = true;

		//Read SQL Driver
		SQL_ReadDriver(hndl, SQLDriver, sizeof(SQLDriver));

		//MYSQL
		if(strcmp(SQLDriver, "mysql", false)==0)
		{

			//Thread Query:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, "SET NAMES \"UTF8\"");

			//Initulize:
			iSqlite = false;
		}

		//Is Sqlite:
		if(iSqlite)
		{

			//Print:
			PrintToServer("|DataBase| Connected to SQLite Database. Version %s", SQLVERSION);
		}

		//Override:
		else
		{

			//Print:
			PrintToServer("|DataBase| Connected to MySQL Database I.e External Config. Version %s.", SQLVERSION);
		}
	}

	//Return:
	return;
}

public void SQLErrorCheckCallback(Handle owner, Handle hndl, const char[] error, any data)
{

	//Is Error:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("RP_Core] SQLErrorCheckCallback: Query failed! %s", error);
		LogError("RP_Core] Query Id = '%i'", data);
#endif
	}
}

//Create Database:
public Handle GetGlobalSQL()
{

	//Return:
	return hDataBase;
}
