#if defined _streamer_included
	#endinput
#endif
#define _streamer_included

#define DEFAULT_STREAM_DISTANCE		(100.0)
#define DEFAULT_WORLD_ID			(-1)
#define DEFAULT_INTERIOR_ID			(-1)

// Dynamic objects

native CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:streamdistance = DEFAULT_STREAM_DISTANCE, virtualworld = DEFAULT_WORLD_ID, interiorid = DEFAULT_INTERIOR_ID);
native IsValidDynamicObject(objectid);
native DestroyDynamicObject(objectid);
native SetDynamicObjectPos(objectid, Float:x, Float:y, Float:z);
native SetDynamicObjectRot(objectid, Float:rx, Float:ry, Float:rz);
native GetDynamicObjectPos(objectid, &Float:x, &Float:y, &Float:z);
native GetDynamicObjectRot(objectid, &Float:rx, &Float:ry, &Float:rz);
native MoveDynamicObject(objectid, Float:x, Float:y, Float:z, Float:speed);
native StopDynamicObject(objectid);
native GetDynamicObjectModel(objectid);
native SetDynamicObjectModel(objectid, modelid);
native SetDynamicObjectVirtualWorld(objectid, virtualworld);
native SetDynamicObjectInterior(objectid, interiorid);
native GetDynamicObjectVirtualWorld(objectid);
native GetDynamicObjectInterior(objectid);
native EnableStreamerDebug();
native SetIntervalPerStreamerUpdate(milliseconds);