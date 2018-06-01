/*
	Author - Decode Lorenzo - (0x23C023) - vk.com/cachegetfield
	This is my first project in RW-MP, and it's a test mode.
*/

/*
	ƒоделать VIP:
		¬ыбор сохранени€ оружи€
		ƒобавить выбор Sniper Rifle
		ƒобавить VIP чат
		ƒобавить ульту
*/

#include <a_rwmp>
#include <a_mysql>
#include <dc_cmd>
#include <foreach>
#include <a_zones>
#include <sscanf2>

#define colorAlert 		0xc70000FF
#define colorSuccess    0x00b300FF
#define colorInfo       0xfad000FF
#define colorGroove     0x009900AA
#define colorBallas		0xCC00FFAA
#define colorAztecas	0x00b4e1AA
#define colorVagos	 	0xffcd00AA
#define colorRifa		0x6666ffAA
#define colorMask       0xA5A5A500
#define colorAdmin      0x9999ffAA
#define colorAdminAlert 0xbebebeFF


#define MAX_GANGZONE		104

// System Configuration.
#define serverName 		"WildWay DeathMatch" // Server name
#define serverVersion	"0.1 Alpha"// Server Version (Revision)

#define hostConnect 	"localhost"// Host
#define loginConnect 	"root"	 // Login
#define passwordConnect ""		 // Password
#define databaseConnect "wildway"// DataBase

// Vars
new MySQL: mysqlConnection;

new Menu: spectrate_menu;

new wrongPassword[MAX_PLAYERS];
new spectrate_player_id[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};

new there_is_capture,
	team_capture[2],
	kills_team[2],
	name_zone[MAX_ZONE_NAME],
	time_to_expiration_capture,
	capture_start;

enum specInformation
{
    specID,
	Float: getXPosition,
	Float: getYPosition,
	Float: getZPosition,
	virtualWorld,
	interior
}
new specInfo[MAX_PLAYERS][specInformation];

enum eDialogIDS
{
	dKickMessage,
	dRegister,
	dLogin,
	dBandSelect,
	dInfoDialog,
	dWarehouse,
	dSelectGuns,
	dTest
};

enum ePlayerInfo
{
	pID,
	pName[MAX_PLAYER_NAME],
	pPassword[31],
	pKills,
	pDeaths,
	pAdmin
};

enum player_virable
{
	p_gang,
	p_heal,
	p_mask
};

enum gangzone_information
{
	gz_id,
	Float:gz_coords[4],
	gz_gang
}

new total_gangzone, gangzone[5];

new gz_info[MAX_GANGZONE][gangzone_information];
new p_virable[MAX_PLAYERS][player_virable];
new playerInfo[MAX_PLAYERS][ePlayerInfo];
new playerIsAuthorized[MAX_PLAYERS char];

new warehouseCheck[5];

static const grooveSkins[] = {105, 106, 107, 149, 195, 269, 270, 271};
static const ballasSkins[] = {102, 103, 104, 195};
static const vagosSking[] = {108, 109, 110, 190};
static const aztecasSking[] = {114, 115, 116, 193, 292};
static const rifa_skins[] = {173, 174, 175, 226, 273};
static const organization_name[][] = {"Grove Street", "The Ballas", "Los Santos Vagos", "Varios Los Aztecas", "The Rifa"};
static const organization_rang_name[5][10][32] = {
	{"Newman", "Hustla", "Huckster", "True", "Warrior", "Gangsta", "O.G", "Big Bro", "Legend", "Daddy"},
	{"Baby", "Tested", "Cracker", "Nigga", "Big Nigga", "Gangster", "Defender", "Shooter", "Star", "Big Daddy"},
	{"Mamarracho", "Compinche", "Bandito", "Vato Loco", "Chaval", "Forajido", "Veterano", "Elite", "El Orgullo", "Padre"},
	{"Novato", "Amigo", "Asistente", "Asesino", "Latinos", "Mejor", "Empresa", "Aproximado", "Diputado", "Padre"},
	{"Amigo", "Macho", "Junior", "Ermanno", "Bandido", "Autoridad", "Adjunto", "Veterano", "Vato Loco", "Padre"}};


#define IsPlayerAuthorized(%0) playerIsAuthorized{%0}
#define SetPlayerAuthorized(%0,%1) playerIsAuthorized{%0} = %1

#define PLAYER_OFFLINE0
#define PLAYER_ONLINE 1

main()
{
	printf("%s loaded. Version: %s", serverName, serverVersion);
}

public OnGameModeInit()
{
	mysqlConnection = mysql_connect(hostConnect, loginConnect, passwordConnect, databaseConnect);
	switch(mysql_errno())
	{
		case 0: print("Connection to database successful!");
		case 1044: print("Database connection failed [unknown user name Specified]");
		case 1045: print("Database connection failed [unknown password Specified]");
		case 1049: print("Database connection failed [unknown database Specified]");
		case 2003: print("Database connection failed [database Hosting not available]");
		case 2005: print("Database connection failed [unknown hosting address Specified]");
		default: printf("Database connection failed [Unknown error. Error code: %d]", mysql_errno());
	}

	mysql_tquery(mysqlConnection, "SELECT * FROM gangzone", "OnGZLoad", "");

	SetNameTagDrawDistance(30.0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();

	SetTimer("EverySecondTimer", 1000, true);

	mysql_tquery(mysqlConnection, !"SET CHARACTER SET 'utf8'", "", "");
	mysql_tquery(mysqlConnection, !"SET NAMES 'utf8'", "", "");
	mysql_tquery(mysqlConnection, !"SET character_set_client = 'cp1251'", "", "");
	mysql_tquery(mysqlConnection, !"SET character_set_connection = 'cp1251'", "", "");
	mysql_tquery(mysqlConnection, !"SET character_set_results = 'cp1251'", "", "");
	mysql_tquery(mysqlConnection, !"SET SESSION collation_connection = 'utf8_general_ci'", "", "");

	SetGameModeText(serverVersion);
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

    spectrate_menu = CreateMenu("_", 1, 500.0, 150.0, 100.0 );
	AddMenuItem(spectrate_menu, 0, "-EXIT-");
	AddMenuItem(spectrate_menu, 0, "Skick");
	AddMenuItem(spectrate_menu, 0, "Slap");
	AddMenuItem(spectrate_menu, 0, "GMTest");
	AddMenuItem(spectrate_menu, 0, "Info");
	AddMenuItem(spectrate_menu, 0, "Stats");
	AddMenuItem(spectrate_menu, 0, "Update");
	AddMenuItem(spectrate_menu, 0, "-EXIT-");

	return 1;
}

public OnGameModeExit()
{
	mysql_close(mysqlConnection);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerFacingAngle(playerid, 0.4727);
	SetPlayerCameraPos(playerid, 1097.7706,1625.2844,12.5469);
	SetPlayerCameraLookAt(playerid, 1098.7706,1600.2844,15.5469);
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    DisablePlayerCheckpoint(playerid);
	GetPlayerName(playerid, playerInfo[playerid][pName], MAX_PLAYER_NAME);
	new queryString[49+MAX_PLAYER_NAME-4];
	format(queryString, sizeof(queryString), "SELECT * FROM `accounts` WHERE `player_name` = '%s'", playerInfo[playerid][pName]);
	mysql_tquery(mysqlConnection, queryString, "FindPlayerInTable","i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveAccount(playerid);
	RemovePlayerInfo(playerid);
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!IsPlayerAuthorized(playerid))
	{
		SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not authorized and cannot write command!");
		return 0;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	switch(p_virable[playerid][p_gang])
	{
	    case 1: warehouseCheck[0] = SetPlayerCheckpoint(playerid, 2455.5740, -1706.3229, 1013.5078, 1.0);
	    case 2: warehouseCheck[1] = SetPlayerCheckpoint(playerid, -42.5511, 1412.5063, 1084.4297, 1.0);
	    case 3: warehouseCheck[2] = SetPlayerCheckpoint(playerid, 333.0990, 1118.9160, 1083.8903, 1.0);
	    case 4: warehouseCheck[3] = SetPlayerCheckpoint(playerid, 223.0524, 1249.5559, 1082.1406, 1.0);
	    case 5: warehouseCheck[4] = SetPlayerCheckpoint(playerid, -71.8009, 1366.5933, 1080.2185, 1.0);
	}

	SetPlayerScore(playerid, playerInfo[playerid][pKills]);
	for(new i = 0; i != sizeof(gz_info); i++)
	{
		GangZoneShowForPlayer(playerid, gz_info[i][gz_id], OnGZColor(gz_info[i][gz_gang]));
	}

	if(!IsPlayerAuthorized(playerid))
	{
		SendClientMessage(playerid, colorAlert, "Х [ALERT]: Enter /q (/quit) to exit");
		SendClientMessage(playerid, colorAlert, "Х [ALERT]: To play on the server You must log in");
		KickEx(playerid);
	}
	switch(p_virable[playerid][p_gang])
	{
 		case 1:
		{
			SetPlayerPos(playerid, 2466.6086,-1698.4858,1013.5078);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 2);
			SetPlayerSkin(playerid, grooveSkins[random(9)]);
		}
		case 2:
		{
			SetPlayerPos(playerid, -49.8575,1408.5522,1084.4297);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 8);
			SetPlayerSkin(playerid, ballasSkins[random(4)]);
		}
		case 3:
		{
			SetPlayerPos(playerid, 321.0667,1123.1947,1083.8828);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 5);
			SetPlayerSkin(playerid, vagosSking[random(4)]);
		}
		case 4:
		{
			SetPlayerPos(playerid, 219.6040,1241.9434,1082.1406);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 2);
			SetPlayerSkin(playerid, aztecasSking[random(5)]);
		}
		case 5:
		{
			SetPlayerPos(playerid, -59.1456,1364.5851,1080.2109);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 6);
			SetPlayerSkin(playerid, rifa_skins[random(5)]);
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SendDeathMessage(killerid, playerid, reason);
	switch(p_virable[playerid][p_gang])
	{
		case 1: SetPlayerColor(playerid, colorGroove);
		case 2: SetPlayerColor(playerid, colorBallas);
		case 3: SetPlayerColor(playerid, colorBallas);
		case 4: SetPlayerColor(playerid, colorAztecas);
		case 5: SetPlayerColor(playerid, colorRifa);
	}
	playerInfo[playerid][pDeaths]++;
	playerInfo[killerid][pKills]++;
	p_virable[playerid][p_mask] = 0;
	p_virable[playerid][p_heal] = 0;
	SetPlayerScore(killerid, playerInfo[killerid][pKills]);
	if(GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
	{
		SendClientMessage(killerid, colorAlert, "Х [ALERT]: Murder by means of a vehicle prohibited!");
		KickEx(killerid);
		return true;
	}
	if(killerid != INVALID_PLAYER_ID)
	{
		if(there_is_capture == 1)
		{
			if(p_virable[killerid][p_gang] == team_capture[0] && p_virable[playerid][p_gang] == team_capture[1])
			{
				kills_team[0] += 1;
			}
			else if(p_virable[killerid][p_gang] == team_capture[1] && p_virable[playerid][p_gang] == team_capture[0])
			{
				kills_team[1] += 1;
			}
		}
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case dTest:
	    {
	        if(!response)
	        {
	            SendClientMessage(playerid, colorInfo, "Х [INFO]: Cancel (отмена)");
	        }
			else if(response)
			{
       			SendClientMessage(playerid, colorInfo, "Х [INFO]: Submit (ѕодтверждение)");
       			SendClientMessage(playerid, colorInfo, inputtext);
			}
	    }
		case dRegister:
		{
			if(!response)
			{
				ShowPlayerDialog(playerid, dKickMessage, DIALOG_STYLE_MSGBOX, "Alert", "{FFFFFF}You have been kicked from the server. Reason: the Refusal of registration. To exit from server, enter \"/q\" in the chat", "Exit", "");
				return Kick(playerid);
			}
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, dRegister, DIALOG_STYLE_INPUT, "New Account", "Error: you cannot continue without entering a password!Please enter a password to register a new account: note:- the Password is case sensitive.- the Password must contain between 4 and 30 characters.- the Password can contain Latin/Cyrillic characters and numbers (aA-zZ, AA-ZZ, 0-9).", "Registration", " Exit");
			else if(strlen(inputtext) < 4) return ShowPlayerDialog(playerid, dRegister, DIALOG_STYLE_INPUT, "New Account", "Error: the Password is too short!Please enter a password to register a new account:note:- the Password is case sensitive.- the Password must contain between 4 and 30 characters.- the Password can contain Latin/Cyrillic characters and numbers (aA-zZ, AA-ZZ, 0-9).", "Registration", " Exit");
			else if(strlen(inputtext) > 30) return ShowPlayerDialog(playerid, dRegister, DIALOG_STYLE_INPUT, "New Account", "Error: the Password is too long!Please enter a password to register a new account:{C0C0C0}note:{666666}- the Password is case sensitive.- the Password must contain between 4 and 30 characters.- the Password can contain Latin/Cyrillic characters and numbers (aA-zZ, AA-ZZ, 0-9).", "Registration", " Exit");
			for(new i = strlen(inputtext)-1; i != -1; i--)
			{
				switch(inputtext[i])
				{
					case '0'..'9', 'а'..'€', 'a'..'z', 'ј'..'я', 'A'..'Z': continue;
					default: return ShowPlayerDialog(playerid, dRegister, DIALOG_STYLE_INPUT, "New Account", "Error: Password contains forbidden characters!Please enter a password to register a new account:{C0C0C0}note:{666666} - the Password is case sensitive.- the Password must contain between 4 and 30 characters.- the Password can contain Latin/Cyrillic characters and numbers (aA-zZ, AA-ZZ, 0-9).", "Registration", " Exit");
				}
			}
			playerInfo[playerid][pPassword][0] = EOS;
			strins(playerInfo[playerid][pPassword], inputtext, 0);
			CreateNewAccount(playerid, playerInfo[playerid][pPassword]);
			return 1;
		}
		case dLogin:
		{
			if(!response)
			{
				ShowPlayerDialog(playerid, dKickMessage, DIALOG_STYLE_MSGBOX, "Alert", "You have been kicked from the server.Reason: the Rejection of the authorization.to exit the server, enter \"/q\" in chat", " Exit", "");
				return Kick(playerid);
			}
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Error: you cannot continue authorization without entering a password!enter the password for the account to log on to the server:", "Login", "Logout");
			for(new i = strlen(inputtext)-1; i != -1; i--)
			{
				switch(inputtext[i])
				{
					case '0'..'9', 'а'..'€', 'a'..'z', 'ј'..'я', 'A'..'Z': continue;
					default: return ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Error: password Entered contains forbidden characters!enter the password for the account to log on to the server:", "Login", " Logout");
				}
			}
			if(!strcmp(playerInfo[playerid][pPassword], inputtext))
			{
				new queryString[49+MAX_PLAYER_NAME];
				format(queryString, sizeof(queryString), "SELECT * FROM `accounts` WHERE `player_name` = '%s'", playerInfo[playerid][pName]);
				mysql_tquery(mysqlConnection, queryString, "UploadPlayerAccount","i", playerid);
			}
			else
			{
				switch(wrongPassword[playerid])
				{
					case 0: ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Error: You have entered an incorrect password! You have 3 attempts left.enter the password for the account to log on to the server:", "Login", " Logout");
					case 1: ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Error: You entered the wrong password! You have 2 attempts left.enter the password for the account to log on to the server:", "Login", " Logout");
					case 2: ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Error: You entered the wrong password! You have 1 attempt left.enter the password for the account to log on to the server:", "Login", " Logout");
					case 3: ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Error: You entered the wrong password! You have the last attempt, after which You kyknet.enter the password for the account to log on to the server:", "Login", " Logout");
					default:
					{
						ShowPlayerDialog(playerid, dKickMessage, DIALOG_STYLE_MSGBOX, "Alert", "You have been kicked from the server.Reason: Exceeded limit of attempts to enter the password.to exit the server, enter \"/q\" in chat", " Exit", "");
						return Kick(playerid);
					}
				}
				wrongPassword[playerid] += 1;
			}
			return 1;
		}
		case dBandSelect: 
		{
			if(!response)
			{
				SendClientMessage(playerid, colorAlert, "Х [ALERT]: You were disconnected from the server.");
				SendClientMessage(playerid, colorAlert, "Х [ALERT]: The reason: Refusal from choice gangs.");
				KickEx(playerid);
				return true;
			}
			switch(listitem)
			{
				case 0:
				{
					SendClientMessage(playerid, colorSuccess, "Х [SUCCESS]: You have chosen Grove Street");
					SetPlayerColor(playerid, colorGroove);
					p_virable[playerid][p_gang] = 1;
					SpawnPlayer(playerid);
				}
				case 1:
				{
					SendClientMessage(playerid, colorSuccess, "Х [SUCCESS]: You have chosen The Ballas");
					SetPlayerColor(playerid, colorBallas);
					p_virable[playerid][p_gang] = 2;
					SpawnPlayer(playerid);
				}
				case 2:
				{
					SendClientMessage(playerid, colorSuccess, "Х [SUCCESS]: You have chosen Los Santos Vagos");
					SetPlayerColor(playerid, colorVagos);
					p_virable[playerid][p_gang] = 3;
					SpawnPlayer(playerid);
				}
				case 3:
				{
					SendClientMessage(playerid, colorSuccess, "Х [SUCCESS]: You have chosen Varios Los Aztecas");
					SetPlayerColor(playerid, colorAztecas);
					p_virable[playerid][p_gang] = 4;
					SpawnPlayer(playerid);
				}
				case 4:
				{
					SendClientMessage(playerid, colorSuccess, "Х [SUCCESS]: You have chosen The Rifa");
					SetPlayerColor(playerid, colorRifa);
					p_virable[playerid][p_gang] = 5;
					SpawnPlayer(playerid);
				}
			}
		}
		case dWarehouse:
		{
		    switch(listitem)
		    {
		        case 0:
		        {
		            if(p_virable[playerid][p_heal] > 1) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You already have first aid kits!");
					SendClientMessage(playerid, colorInfo, "Х [INFO]: You took 3 first aid kits. Use /healme for using the kit");
					p_virable[playerid][p_heal] = 3;
					ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
		        }
		        case 1:
		        {
                    if(p_virable[playerid][p_mask] == 1) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You already have a mask!");
					SendClientMessage(playerid, colorInfo, "Х [INFO]: You got the mask. Use /mask to hide Your location on the map");
					p_virable[playerid][p_mask] = 1;
					ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
		        }
		        case 2: ShowPlayerDialog(playerid, dSelectGuns, DIALOG_STYLE_LIST, "Warehouse", "1. Desert Eagle + M4A1\n2. Desert Eagle + Shotgun\n3. Desert Eagle + AK-47", "Select", "Back");
		    }
		}
		case dSelectGuns:
		{
		    if(!response) return ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
		    switch(listitem)
		    {
		        case 0:
		        {
		            GivePlayerWeapon(playerid, 24, 100);
					GivePlayerWeapon(playerid, 31, 200);
	                SendClientMessage(playerid, colorInfo, "Х [INFO]: You got the Desert Eagle and M4A1");
	                ShowPlayerDialog(playerid, dSelectGuns, DIALOG_STYLE_LIST, "Warehouse", "1. Desert Eagle + M4A1\n2. Desert Eagle + Shotgun\n3. Desert Eagle + AK-47", "Select", "Back");
				}
		        case 1:
		        {
		            GivePlayerWeapon(playerid, 24, 100);
					GivePlayerWeapon(playerid, 25, 200);
	                SendClientMessage(playerid, colorInfo, "Х [INFO]: You got the Desert Eagle and Shotgun");
	                ShowPlayerDialog(playerid, dSelectGuns, DIALOG_STYLE_LIST, "Warehouse", "1. Desert Eagle + M4A1\n2. Desert Eagle + Shotgun\n3. Desert Eagle + AK-47", "Select", "Back");
		        }
		        case 2:
		        {
		            GivePlayerWeapon(playerid, 24, 100);
					GivePlayerWeapon(playerid, 30, 200);
	                SendClientMessage(playerid, colorInfo, "Х [INFO]: You got the Desert Eagle and Kalashnikov");
	                ShowPlayerDialog(playerid, dSelectGuns, DIALOG_STYLE_LIST, "Warehouse", "1. Desert Eagle + M4A1\n2. Desert Eagle + Shotgun\n3. Desert Eagle + AK-47", "Select", "Back");
		        }
		    }
		}
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	/*
	    SetPlayerInterior(playerid, GetPlayerInterior(params[0]));
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(params[0]));
		TogglePlayerSpectating(playerid, 1);

	    specInfo[playerid][specID] = params[0];
		GetPlayerPos(playerid, specInfo[playerid][getXPosition], specInfo[playerid][getXPosition], specInfo[playerid][getXPosition]);

	    specInfo[playerid][virtualWorld] = GetPlayerVirtualWorld(playerid);
	    specInfo[playerid][interior] = GetPlayerInterior(playerid);
	*/

    if(GetPlayerMenu(playerid) == spectrate_menu)
	{
	    switch(row)
        {
			case 0:
			{
			    TogglePlayerSpectating(playerid, false);
			    HideMenuForPlayer(spectrate_menu, playerid);
				SetPlayerPos(playerid, specInfo[playerid][getXPosition], specInfo[playerid][getXPosition], specInfo[playerid][getXPosition]);
            	SetPlayerVirtualWorld(playerid, specInfo[playerid][virtualWorld]), SetPlayerInterior(playerid, specInfo[playerid][interior]);
            	specInfo[playerid][specID] = 0;
            	specInfo[playerid][getXPosition] = 0;
				specInfo[playerid][getYPosition] = 0;
				specInfo[playerid][getZPosition] = 0;
				specInfo[playerid][virtualWorld] = 0;
				specInfo[playerid][interior] = 0;
			}
			case 1: SendClientMessage(playerid, colorInfo, "Х [INFO]: DEVELOP");
			/*case 2:
			{
	   		    new
				   	Float: position[3];
				GetPlayerPos(GetPVarInt(playerid, "spectrate_id"), position[0], position[1], position[2]);
				SetPlayerPos(GetPVarInt(playerid, "spectrate_id"), position[0], position[1], position[2] + 5);
				ShowMenuForPlayer(spectrate_menu, playerid);
			}
			case 3:
			{
			    if(p_info[playerid][p_admin] < 4) return SendClientMessage(playerid, COLOR_DARKORANGE, "¬ам не доступна данна€ функци€.");
				new
					cmd_str[11];
				format(cmd_str, sizeof(cmd_str), "%d", GetPVarInt(playerid, "spectrate_id"));
				cmd::gm(playerid, cmd_str);
				ShowMenuForPlayer(spectrate_menu, playerid);
			}
			case 4:
			{
			    if(p_info[playerid][p_admin] < 1) return SendClientMessage(playerid, COLOR_DARKORANGE, "¬ам не доступна данна€ функци€.");
			    static const fmt_str[] = "[A] Ќик: %s [ID: %i] [IP: %s] [PING: %i]";
			    new str[sizeof fmt_str + 36 + MAX_PLAYER_NAME + 16 + 11];
				format(str, sizeof(str), fmt_str, p_info[GetPVarInt(playerid, "spectrate_id")][p_name], GetPVarInt(playerid, "spectrate_id"), p_ip[GetPVarInt(playerid, "spectrate_id")], GetPlayerPing(GetPVarInt(playerid, "spectrate_id")));
				SendClientMessage(playerid, 0x33CCFFAA, str);
				ShowMenuForPlayer(spectrate_menu, playerid);
			}
			case 5:
			{
			    if(p_info[playerid][p_admin] < 1) return SendClientMessage(playerid, COLOR_DARKORANGE, "¬ам не доступна данна€ функци€.");
				new
					cmd_str[11];
				format(cmd_str, sizeof(cmd_str), "%d", GetPVarInt(playerid, "spectrate_id"));
				cmd::stats(playerid, cmd_str);
				ShowMenuForPlayer(spectrate_menu, playerid);
			}
			case 6:
			{
			    if(p_info[playerid][p_admin] < 1) return SendClientMessage(playerid, COLOR_DARKORANGE, "¬ам не доступна данна€ функци€.");
			    new
					cmd_str[11];
				GameTextForPlayer(playerid, "~w~SPEC ~g~UPDATED", 1000, 3);
				format(cmd_str, sizeof(cmd_str), "%d", GetPVarInt(playerid, "spectrate_id"));
				cmd::sp(playerid, cmd_str);
				ShowMenuForPlayer(spectrate_menu, playerid);
			}*/
			case 7:
			{
			    TogglePlayerSpectating(playerid, false);
			    HideMenuForPlayer(spectrate_menu, playerid);
				SetPlayerPos(playerid, specInfo[playerid][getXPosition], specInfo[playerid][getXPosition], specInfo[playerid][getXPosition]);
            	SetPlayerVirtualWorld(playerid, specInfo[playerid][virtualWorld]), SetPlayerInterior(playerid, specInfo[playerid][interior]);
            	specInfo[playerid][getXPosition] = 0;
				specInfo[playerid][getYPosition] = 0;
				specInfo[playerid][getZPosition] = 0;
				specInfo[playerid][virtualWorld] = 0;
				specInfo[playerid][interior] = 0;
			}
		}
	}
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

forward EverySecondTimer();
public EverySecondTimer()
{
	foreach(new i: Player)
	{

	}
	
	OnCaptureTimer();
	return true;
}

forward OnSquared(playerid,Float:min_x,Float:min_y,Float:max_x,Float:max_y);
public OnSquared(playerid,Float:min_x,Float:min_y,Float:max_x,Float:max_y)
{
	new Float: position[3];
	GetPlayerPos(playerid, position[0], position[1], position[2]);
	if((position[0] <= max_x && position[0] >= min_x) && (position[1] <= max_y && position[1] >= min_y)) return true;
	return false;
}

forward OnGZLoad();
public OnGZLoad()
{
	new time = GetTickCount();
	cache_get_row_count(total_gangzone);
	if(!total_gangzone) return print("[MYSQL_LOG]: Table `gangzone` exist");
	for(new i = 0; i != sizeof(gz_info); i++)
	{
		cache_get_value_name_float(i, "X", gz_info[i][gz_coords][0]);
		cache_get_value_name_float(i, "Y", gz_info[i][gz_coords][1]);
		cache_get_value_name_float(i, "XX", gz_info[i][gz_coords][2]);
		cache_get_value_name_float(i, "YY", gz_info[i][gz_coords][3]);
		cache_get_value_name_int(i, "member", gz_info[i][gz_gang]);
		switch(gz_info[i][gz_gang])
		{
			case 1: gangzone[0]++;
			case 2: gangzone[1]++;
			case 3: gangzone[2]++;
			case 4: gangzone[3]++;
			case 5: gangzone[4]++;
		}
		gz_info[i][gz_id] = GangZoneCreate(gz_info[i][gz_coords][0], gz_info[i][gz_coords][1], gz_info[i][gz_coords][2], gz_info[i][gz_coords][3]);
	}
	return printf("\n- GangZones loaded: %d. For: (%d ms)", total_gangzone, GetTickCount() - time);
}

forward FindPlayerInTable(playerid);
public FindPlayerInTable(playerid)
{
	new rows;
	cache_get_row_count(rows);

	if(!rows)
	{
		ShowPlayerDialog(playerid, dRegister, DIALOG_STYLE_INPUT, "New Account", "Enter your password to register a new account:", "Register", " sign Out");
	}
	else
	{
		ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "Authorization", "Enter password to continue:", "Login", "Exit");
		cache_get_value_name(0, "password", playerInfo[playerid][pPassword], 31);
	}
	return 1;
}

forward OnGZSave(i);
public OnGZSave(i)
{
	static const fmt_str[] = "UPDATE `gangzone` SET `X`='%f', `Y`='%f', `XX`='%f', `YY`='%f', `member`='%d' WHERE `id`='%d'";
	new mysql_str[sizeof fmt_str + 150];
	format(mysql_str, sizeof(mysql_str), fmt_str, gz_info[i][gz_coords][0], gz_info[i][gz_coords][1], gz_info[i][gz_coords][2], gz_info[i][gz_coords][3], gz_info[i][gz_gang], i);
	mysql_tquery(mysqlConnection, mysql_str, "", "");
	return true;
}

stock SendAdminMessage(color, string[])
{
	foreach(new i: Player)
	{
		if(!IsPlayerConnected(i) || !playerInfo[i][pAdmin]) continue;
		SendClientMessage(i, color, string);
	}
}

stock OnStartCapture(familyone, familytwo)
{
	foreach(new i: Player)
	{
		if(!p_virable[i][p_gang]) continue;
		{
			static const fmt_str0[] = "Х [ALERT]: %s began to conquer the territory of the gang %s is in district %s";
			new str0[sizeof fmt_str0 + 18 * 2 + 42 + MAX_ZONE_NAME];
			format(str0, sizeof(str0), fmt_str0, organization_name[familyone-1], organization_name[familytwo-1], name_zone);
			SendClientMessage(i, colorAlert, str0);
		}
	}
	return true;
}

stock GetPlayerRang(playerid)
{
	new string[10];
	switch(playerInfo[playerid][pKills])
	{
		case 0..100: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][0]);
		case 101..200: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][1]);
		case 201..300: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][2]);
		case 301..400: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][3]);
		case 401..500: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][4]);
		case 501..600: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][5]);
        case 601..700: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][6]);
        case 701..800: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][7]);
        case 801..900: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][8]);
        case 901..1000: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][9]);
        default: format(string, sizeof(string), organization_rang_name[p_virable[playerid][p_gang]-1][9]);
    }
    return string;
}

stock OnCaptureTimer()
{
	time_to_expiration_capture --;

	/* static const first_alert = "Х [ALERT]: Remained %d (sec). Score [%s - %d | %s - %d]"; */
	
	static const
		fmt_str4[] = "Х [ALERT]: Attempt %s to seize territory from %s failed",
		fmt_str5[] = "Х [ALERT]: %s captured the territory from the gang %s is in district %s";
		
 	new str4[sizeof fmt_str4 + 18*2 + 54],
		str5[sizeof fmt_str5 + 18*2 + 40 + MAX_ZONE_NAME];
	if(!time_to_expiration_capture)
    {
        foreach(new i: Player)
        {
            GangZoneStopFlashForAll(capture_start);
            RemovePlayerMapIcon(i, 31);
            if(kills_team[0] == kills_team[1] || kills_team[0] < kills_team[1])
			{
			    format(str4, sizeof(str4), fmt_str4, organization_name[team_capture[0]-1], organization_name[team_capture[1]-1]);
			    SendClientMessage(i, colorAlert, str4);
			}
            else if(kills_team[0] > kills_team[1])
			{
			    format(str5, sizeof(str5), fmt_str5, organization_name[team_capture[0]-1], organization_name[team_capture[1]-1], name_zone);
			    SendClientMessage(i, colorAlert, str5);
                GangZoneHideForAll(capture_start);
	            GangZoneShowForAll(capture_start, OnGZColor(team_capture[0]));
                gangzone[0] = 0, gangzone[1] = 0, gangzone[2] = 0, gangzone[3] = 0, gangzone[4] = 0;
				for(new territory = 0; territory < sizeof(gz_info); territory++)
				{
				    switch(gz_info[territory][gz_gang])
				    {
				        case 1: gangzone[0]++;
				        case 2: gangzone[1]++;
				        case 3: gangzone[2]++;
				        case 4: gangzone[3]++;
				        case 5: gangzone[4]++;
				    }
				}
				gz_info[capture_start][gz_gang] = team_capture[0];
                OnGZSave(capture_start);
			}
        }
        capture_start = 0;
        there_is_capture = 0;
        time_to_expiration_capture = 0;
    }
    return true;
}

stock OnGZColor(fnumber)
{
    new fnumberid;
    switch(fnumber)
    {
		case 0: fnumberid = 0xFFFFFFAA;
        case 1: fnumberid = colorGroove;
		case 2: fnumberid = colorBallas;
        case 3: fnumberid = colorVagos;
        case 4: fnumberid = colorAztecas;
        case 5: fnumberid = colorRifa;
    }
    return fnumberid;
}

stock KickEx(playerid)
{
    SetTimerEx("OnPlayerKick", 1000, false, "d", playerid);
    return true;
}

stock CreateNewAccount(playerid, password[])
{
    new queryString[66+MAX_PLAYER_NAME-4+30];
    format(queryString, sizeof(queryString), "INSERT INTO `accounts` (`player_name`, `password`) VALUES ('%s', '%s')", playerInfo[playerid][pName], password);
    mysql_tquery(mysqlConnection, queryString, "UploadPlayerAccountNumber", "i", playerid);

    format(queryString, sizeof(queryString), "Х [SUCCESS]: Account %s has been successfully registered.", playerInfo[playerid][pName]);
    SendClientMessage(playerid, colorInfo, "Х [INFO]: To familiarize with the rules of the server - key 'Y' -> the Second point.");
    SendClientMessage(playerid, colorInfo, "Х [INFO]: To contact the server administration - use /rep(ort)");
    SendClientMessage(playerid, colorSuccess, queryString);
    SetPlayerAuthorized(playerid, PLAYER_ONLINE);

    ShowPlayerDialog(playerid, dBandSelect, 2, "Select band", "1. Grove Street\n2. The Ballas\n3. Los Santos Vagos\n4. Varios Los Aztecas\n5. The Rifa", "¬ыбрать", "¬ыйти");
    return 1;
}

forward UploadPlayerAccountNumber(playerid);
public UploadPlayerAccountNumber(playerid) playerInfo[playerid][pID] = cache_insert_id();

forward OnPlayerKick(playerid);
public OnPlayerKick(playerid)
{
    if(IsPlayerConnected(playerid))
	{
	 	Kick(playerid);
	}
}

forward UploadPlayerAccount(playerid);
public UploadPlayerAccount(playerid)
{
    cache_get_value_name_int(0, "id", playerInfo[playerid][pID]);
    cache_get_value_name_int(0, "kills", playerInfo[playerid][pKills]);
    cache_get_value_name_int(0, "deaths", playerInfo[playerid][pKills]);
    cache_get_value_name_int(0, "Admin", playerInfo[playerid][pAdmin]);

    SendClientMessage(playerid, colorSuccess, "Х [SUCCESS]: You have successfully authorized!");
    SendClientMessage(playerid, colorInfo, "Х [INFO]: To familiarize with the rules of the server - key 'Y' -> the Second point.");
    SendClientMessage(playerid, colorInfo, "Х [INFO]: To contact the server administration - use /rep(ort)");

    SetPlayerAuthorized(playerid, PLAYER_ONLINE);
    ShowPlayerDialog(playerid, dBandSelect, 2, "Select band", "1. Grove Street\n2. The Ballas\n3. Los Santos Vagos\n4. Varios Los Aztecas\n5. The Rifa", "¬ыбрать", "¬ыйти");
    return 1;
}

stock SaveAccount(playerid)
{
    new queryString[(21)+(16+11)+(20+MAX_PLAYER_NAME)+(16+30)] = "UPDATE `accounts` SET";

    format(queryString, sizeof(queryString), "%s `player_name` = '%s',", queryString, playerInfo[playerid][pName]);
    format(queryString, sizeof(queryString), "%s `password` = '%s',", queryString, playerInfo[playerid][pPassword]);
    format(queryString, sizeof(queryString), "%s `kills` = '%d',", queryString, playerInfo[playerid][pKills]);
    format(queryString, sizeof(queryString), "%s `deaths` = '%d',", queryString, playerInfo[playerid][pDeaths]);
    format(queryString, sizeof(queryString), "%s `Admin` = '%d'", queryString, playerInfo[playerid][pAdmin]);

    format(queryString, sizeof(queryString), "%s WHERE `id` = '%d'", queryString, playerInfo[playerid][pID]);
    mysql_tquery(mysqlConnection, queryString, "", "");
    return 1;
}

forward SendGhettoMessage(family, color, string[]);
public SendGhettoMessage(family, color, string[])
{
    foreach(new i: Player)
    {
        if(p_virable[i][p_gang] != family) continue;
        SendClientMessage(i, color, string);
    }
}

stock RemovePlayerInfo(playerid)
{
    playerInfo[playerid][pID] = 0;
    playerInfo[playerid][pName][0] = EOS;
    playerInfo[playerid][pPassword][0] = EOS;
    playerInfo[playerid][pKills] = 0;
    playerInfo[playerid][pDeaths] = 0;
    playerInfo[playerid][pAdmin] = 0;
    wrongPassword[playerid] = 0;
    
	return 1;
}

//  оманды.
CMD:capture(playerid, params[])
{
    for(new i = 0; i != sizeof(gz_info); i++)
    {
	    if(OnSquared(playerid, gz_info[i][gz_coords][0], gz_info[i][gz_coords][1], gz_info[i][gz_coords][2], gz_info[i][gz_coords][3]))
        {
	        if(p_virable[playerid][p_gang] == gz_info[i][gz_gang]) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: This territory belongs to your gang.");
            if(there_is_capture == 1) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: Already there is a capture of one of the zones. Wait for the end!");
            switch(i)
            {
                case 7, 25, 67, 74, 90: return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You can't start taking over territories where gang members appear!");
            }
            new
	           Float:x = (gz_info[i][gz_coords][0]+gz_info[i][gz_coords][2])/2.0,
               Float:y = (gz_info[i][gz_coords][1]+gz_info[i][gz_coords][3])/2.0,
               Float:z = 0;
           	foreach(new a: Player)
            {
                switch(p_virable[playerid][p_gang])
                {
                    case 1: SetPlayerMapIcon(a, 31, x, y , z, 62, 0);
                    case 2: SetPlayerMapIcon(a, 31, x, y , z, 60, 0);
                    case 3: SetPlayerMapIcon(a, 31, x, y , z, 59, 0);
                    case 4: SetPlayerMapIcon(a, 31, x, y , z, 58, 0);
                    case 5: SetPlayerMapIcon(a, 31, x, y , z, 61, 0);
                }
            }
            GetPlayer2DZone(playerid, name_zone, MAX_ZONE_NAME);
            time_to_expiration_capture = 420;
	        kills_team[0] = 0;
            kills_team[1] = 0;
            capture_start = i;
            there_is_capture = 1;
            GangZoneFlashForAll(capture_start, OnGZColor(p_virable[playerid][p_gang]));
            OnStartCapture(p_virable[playerid][p_gang], gz_info[i][gz_gang]);
            team_capture[0] = p_virable[playerid][p_gang];
            team_capture[1] = gz_info[i][gz_gang];
            static const fmt_str[] = "Х [ALERT]: %s %s Began to capture territory";
			new str[sizeof fmt_str + MAX_PLAYER_NAME + 19];
            format(str, sizeof(str), fmt_str, GetPlayerRang(playerid), playerInfo[playerid][pName]);
			SendGhettoMessage(team_capture[0], colorAlert, str);
            SendGhettoMessage(team_capture[0], colorInfo, "Х [INFO]: The place marked on the GPS. Go there and support your gang");
            SendGhettoMessage(team_capture[1], colorInfo, "Х [INFO]: The place marked on the GPS. Go there and support your gang");
            return true;
        }
    }
    return true;
}

CMD:newgang(playerid, params[])
{
    for(new i = 0; i < sizeof(warehouseCheck); i++)
		DestroyPickup(i);
    ShowPlayerDialog(playerid, dBandSelect, 2, "¬ыберите банду", "1. Grove Street\n2. The Ballas\n3. Los Santos Vagos\n4. Varios Los Aztecas\n5. The Rifa", "¬ыбрать", "¬ыйти");
	return true;
}

CMD:exit(playerid)
{
	switch(p_virable[playerid][p_gang])
	{
	    case 1:
	    {   
            if (!IsPlayerInRangeOfPoint(playerid, 5, 2468.4163, -1698.2432, 1013.5078)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You're not near the door");
       	    SetPlayerPos(playerid, 2495.3022,-1688.5438,13.8722);
       	    SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 0);
	    }
	    case 2:
	    {
	        if (!IsPlayerInRangeOfPoint(playerid, 5, -42.6055, 1405.7949, 1084.4297)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You're not near the door");
    	    SetPlayerPos(playerid, 2022.9169,-1122.7472,26.2329);
    	    SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 0);
	    }
	    case 3:
	    {
            if (!IsPlayerInRangeOfPoint(playerid, 5, 318.6152, 1114.8966, 1083.8828)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You're not near the doorr");
    	    SetPlayerPos(playerid, 2756.1492,-1180.2386,69.3978);
    	    SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 0);
	    }
	    case 4:
	    {
            if (!IsPlayerInRangeOfPoint(playerid, 5, 225.756989,1240.000000,1082.149902)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You're not near the door");
    	    SetPlayerPos(playerid, 2185.6555,-1812.5112,13.5650);
    	    SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 0);
	    }
	    case 5:
	    {
            if (!IsPlayerInRangeOfPoint(playerid, 5, -68.8279, 1351.3553, 1080.2109)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You're not near the door");
    	    SetPlayerPos(playerid, 2784.5544,-1926.1563,13.5469);
    	    SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 0);
	    }
	}
	return true;
}

CMD:enter(playerid)
{
    switch(p_virable[playerid][p_gang])
	{
    	case 1:
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 5, 2495.4309, -1691.1400, 14.7656)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not in the interior");
			if(p_virable[playerid][p_gang] != 1) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You have no access to the entrance");
			SetPlayerPos(playerid, 2466.6086, -1698.4858, 1013.5078);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 2);
	    }
	    case 2:
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 5, 2022.8790, -1120.2637, 26.4210)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not in the interior");
    	    if(p_virable[playerid][p_gang] != 2) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You have no access to the entrance");
			SetPlayerPos(playerid, -49.8575,1408.5522,1084.4297);
			SetPlayerFacingAngle(playerid, 0);
 			SetPlayerInterior(playerid, 8);
	    }
	    case 3:
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5, 2756.2825, -1182.4691, 69.3998)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not in the interior");
            if(p_virable[playerid][p_gang] != 3) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You have no access to the entrance");
			SetPlayerPos(playerid, 318.564971,1118.209960,1083.882812);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 5);
	    }
	    case 4:
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5, 2185.8071, -1813.8461, 13.5469)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not in the interior");
            if(p_virable[playerid][p_gang] != 4) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You have no access to the entrance");
			SetPlayerPos(playerid, 223.0174, 1240.1416, 1082.1406);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 2);
	    }
	    case 5:
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5, 2787.0759, -1926.1780, 13.5469)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not in the interior");
            if(p_virable[playerid][p_gang] != 5) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You have no access to the entrance");
			SetPlayerPos(playerid, -68.9146,1353.8420,1080.2109);
			SetPlayerFacingAngle(playerid, 0);
			SetPlayerInterior(playerid, 6);
	    }
	}
	return true;
}

CMD:warehouse(playerid)
{
	switch(p_virable[playerid][p_gang])
	{
	    case 1:
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 2, 2455.5740, -1706.3229, 1013.5078)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not near checkpoint");
	        if(p_virable[playerid][p_gang] != 1) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You do not have access to this warehouse");
	        ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
	    }
	    case 2:
	    {
	        if (!IsPlayerInRangeOfPoint(playerid, 2, -42.5511, 1412.5063, 1084.4297)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not near checkpoint");
            if(p_virable[playerid][p_gang] != 2) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You do not have access to this warehouse");
	        ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
		}
	    case 3:
		{
		    if (!IsPlayerInRangeOfPoint(playerid, 2, 333.0990, 1118.9160, 1083.8903)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not near checkpoint");
		    if(p_virable[playerid][p_gang] != 3) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You do not have access to this warehouse");
	        ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
	    }
	    case 4:
	    {
	        if (!IsPlayerInRangeOfPoint(playerid, 2, 223.0524, 1249.5559, 1082.1406)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not near checkpoint");
	        if(p_virable[playerid][p_gang] != 4) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You do not have access to this warehouse");
	        ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
	    }
	    case 5:
	    {
	        if (!IsPlayerInRangeOfPoint(playerid, 2, -71.8009, 1366.5933, 1080.2185)) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You are not near checkpoint");
	        if(p_virable[playerid][p_gang] != 5) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You do not have access to this warehouse");
	        ShowPlayerDialog(playerid, dWarehouse, DIALOG_STYLE_LIST, "Warehouse", "1. First aid kit\n2. Mask\n3. Weapons", "Select", "Close");
	    }
	}
	return true;
}

CMD:mask(playerid)
{
	if(p_virable[playerid][p_mask] == 0) return SendClientMessage(colorAlert, playerid, "Х [ALERT]: You don't have a mask!");
	//SetPlayerChatBubble(playerid, "ќдевает маску", 0x0099FFAA, 10.0, 2000);
	GameTextForPlayer(playerid, "~b~IVISIBLE ON", 1000, 1);
	SetPlayerColor(playerid, colorMask);
	p_virable[playerid][p_mask] -= 1;
	SendClientMessage(playerid, colorInfo, "Х [INFO]: Your location on GPS is hidden");
	return true;
}

CMD:healme(playerid)
{
    new Float: max_health;
	if(p_virable[playerid][p_heal] == 0) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: You don't have a first aid kit!");
	//SetPlayerChatBubble(playerid, "+ 60 HP", 0x0099FFAA, 10.0, 2000);
 	GameTextForPlayer(playerid, "~b~+ 60 hp", 1000, 1);
  	SendClientMessage(playerid, colorInfo, "Х [INFO]: You used the first aid kit! Your health is replenished");
	p_virable[playerid][p_heal] -= 1;
 	GetPlayerHealth(playerid, max_health);
	SetPlayerHealth(playerid, (max_health + 60 <= 100) ? 60.0 : 100.0);
	return true;
}

// јдмин часть.

CMD:ahelp(playerid, params[])
{
	if(playerInfo[playerid][pAdmin] < 1) return true;
	if(playerInfo[playerid][pAdmin] >= 1) SendClientMessage(playerid, colorInfo, "[1 A-LEVEL]: {bebebe}/a(dmin) /sp /admins /ip /ans /weap /gm /messages");
	return true;
}

CMD:a(playerid, params[])
{
    if(playerInfo[playerid][pAdmin] < 1) return true;
    new string[144];
    if(sscanf(params, "s[144]", params[0])) return SendClientMessage(playerid, colorInfo,"Х [INFO]: Usage: /a(dmin) [Text]");
	format(string, sizeof(string), "[A] {bebebe}%s[%d]: %s", playerInfo[playerid][pName], playerid, params[0]);
	SendAdminMessage(colorInfo, string);
    return true;
}

CMD:sp(playerid, params[])
{
	if(playerInfo[playerid][pAdmin] < 1) return true;
	if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, colorInfo, "Х [INFO]: Usage: /sp [id]");
    if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: Player not found!");
	spectrate_player_id[playerid] = params[0];
	switch(GetPlayerState(params[0]))
 	{
 	    case 1: PlayerSpectatePlayer(playerid, params[0]);
 	    case 2..3: PlayerSpectateVehicle(playerid, GetPlayerVehicleID(params[0]));
		default: return false;
 	}
 	ShowMenuForPlayer(spectrate_menu, playerid);
	SetPlayerInterior(playerid, GetPlayerInterior(params[0]));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(params[0]));
	TogglePlayerSpectating(playerid, 1);
 
    specInfo[playerid][specID] = params[0];
	GetPlayerPos(playerid, specInfo[playerid][getXPosition], specInfo[playerid][getXPosition], specInfo[playerid][getXPosition]);
	
    specInfo[playerid][virtualWorld] = GetPlayerVirtualWorld(playerid);
    specInfo[playerid][interior] = GetPlayerInterior(playerid);
    SendClientMessage(playerid, colorInfo, "Х [INFO]: Usage /spoff for exiting from /sp(ec)");
	return true;
}

CMD:skick(playerid, params[])
{
	static const formatString[] = "[A] %s[%d] kick player %s[%d] without unnecessary noise";
	new str[sizeof formatString + 46 + MAX_PLAYER_NAME * 2];
	if(playerInfo[playerid][pAdmin] < 3) return true;
	if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, colorInfo, "Х [INFO]: Usage /skick [id]");
	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, colorAlert, "Х [ALERT]: Player not found!");
	format(str, sizeof(str), formatString, playerInfo[playerid][pName], playerid, playerInfo[params[0]][pName], params[0]);
	SendAdminMessage(colorAdminAlert, str);
	return KickEx(params[0]);
}

CMD:te(playerid, params[])
{
    /*if(sscanf(params, "s[100]", params[0])) return SendClientMessage(playerid, colorInfo, "Х [INFO]: Usage /te [text]");
    static const convertMessage[] = "[OUTPUTED]: %s";
	new string[sizeof(convertMessage) + 50];
	format(string, sizeof(string), convertMessage, params[0]);
	SendClientMessage(playerid, colorInfo, string);*/
	ShowPlayerDialog(playerid, dTest, DIALOG_STYLE_INPUT, "“естовый ƒиалог | Test Dialog", "Input Here", "Send", "Close");
	return true;
}
