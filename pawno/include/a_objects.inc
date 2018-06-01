#if defined _objects_included
	#endinput
#endif
#define _objects_included
// Objects

native CreateObject(modelid, Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ);
native SetObjectPos(objectid, Float:X, Float:Y, Float:Z);
native GetObjectPos(objectid, &Float:X, &Float:Y, &Float:Z);
native SetObjectRot(objectid, Float:RotX, Float:RotY, Float:RotZ);
native GetObjectModel(objectid);
native GetObjectRot(objectid, &Float:RotX, &Float:RotY, &Float:RotZ);
native IsValidObject(objectid);
native DestroyObject(objectid);
native MoveObject(objectid, Float:X, Float:Y, Float:Z, Float:Speed);
native StopObject(objectid);

native CreatePlayerObject(playerid, modelid, Float:X, Float:Y, Float:Z, Float:rX, Float:rY, Float:rZ);

native SetPlayerObjectPos(playerid, objectid, Float:X, Float:Y, Float:Z);
native GetPlayerObjectPos(playerid, objectid, &Float:X, &Float:Y, &Float:Z);
native SetPlayerObjectRot(playerid, objectid, Float:RotX, Float:RotY, Float:RotZ);
native GetPlayerObjectRot(playerid, objectid, &Float:RotX, &Float:RotY, &Float:RotZ);
native GetPlayerObjectModel(playerid, objectid);
native IsValidPlayerObject(playerid, objectid);
native DestroyPlayerObject(playerid, objectid);
native MovePlayerObject(playerid, objectid, Float:X, Float:Y, Float:Z, Float:Speed);
native StopPlayerObject(playerid, objectid);

native AttachObjectToPlayer(objectid, playerid, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:rX, Float:rY, Float:rZ);
native AttachPlayerObjectToPlayer(objectplayer, objectid, attachplayer, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:rX, Float:rY, Float:rZ);

// Visibility

native ToggleObjectVisible(objectid, forplayerid, visible);