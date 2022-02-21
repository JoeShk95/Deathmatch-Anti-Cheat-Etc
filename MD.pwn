/*
	* VGames.co.il DeathMatch Objects Streamer
	* © Copyright 2008-2009, Amit Barami (`Amit_B`)
	* Type:				SanAndreas:MultiPlayer 0.2.2 + 0.2X
	* Version:			0.2.3C
	* Creation Date:	17/11/2008
*/
#include <a_samp>
#define MAX_STREAM_OBJECTS 250
enum object_enum
{
	modelid,
	Float:xpos,
	Float:ypos,
	Float:zpos,
	Float:xrot,
	Float:yrot,
	Float:zrot,
	Float:viewdist,
	attached,
	Float:xoff,
	Float:yoff,
	Float:zoff,
	bool:moving,
	movingid,
	Float:movx,
	Float:movy,
	Float:movz,
	Float:speed,
	movetimer,
	id,
	interior,
	world
}
enum player_enum
{
	pobjects[MAX_STREAM_OBJECTS],
	bool:seen[MAX_STREAM_OBJECTS]
}
new Objects[MAX_STREAM_OBJECTS][object_enum];
new PlayerObjects[MAX_PLAYERS][player_enum];
new created = 0, attaching[2] = {0,0};
bool:PointToPoint(Float:x,Float:y,Float:z,Float:x2,Float:y2,Float:z2,Float:dist)
{
	x = (x > x2) ? x - x2 : x2 - x;
	if(x > dist) return false;
	y = (y > y2) ? y - y2 : y2 - y;
	if(y > dist) return false;
	z = (z > z2) ? z - z2 : z2 - z;
	if(z > dist) return false;
	return true;
}
Float:GetDistance(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2) return Float:floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
forward Core_CreateStreamObject(modelid2,Float:xpos2,Float:ypos2,Float:zpos2,Float:xrot2,Float:yrot2,Float:zrot2,Float:viewdist2, wrld);
public Core_CreateStreamObject(modelid2,Float:xpos2,Float:ypos2,Float:zpos2,Float:xrot2,Float:yrot2,Float:zrot2,Float:viewdist2, wrld)
{
	for(new i=0;i<MAX_STREAM_OBJECTS;i++)
	{
		if(!Objects[i][modelid])
		{
			Objects[i][modelid] = modelid2;
			Objects[i][xpos] = xpos2;
			Objects[i][ypos] = ypos2;
			Objects[i][zpos] = zpos2;
			Objects[i][xrot] = xrot2;
			Objects[i][yrot] = yrot2;
			Objects[i][zrot] = zrot2;
			Objects[i][viewdist] = viewdist2;
			Objects[i][attached] = -1;
			Objects[i][moving] = false;
			Objects[i][id] = i;
	//		Objects[i][interior] = intr;
			Objects[i][world] = wrld;
			if(created < i) created = i;
			return i;
		}
	}
	return 0;
}
forward Core_DestroyStreamObject(id2);
public Core_DestroyStreamObject(id2)
{
 	Objects[id2][modelid] = 0;
 	KillTimer(Objects[id2][movetimer]);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		if(IsPlayerConnected(i) && PlayerObjects[i][seen][id2] == true)
		{
			DestroyPlayerObject(i,PlayerObjects[i][pobjects][id2]);
			PlayerObjects[i][seen][id2] = false;
		}
	}
}
forward Float:Core_GetXPos(id2);
public Float:Core_GetXPos(id2) return Objects[id2][xpos];
forward Float:Core_GetYPos(id2);
public Float:Core_GetYPos(id2) return Objects[id2][ypos];
forward Float:Core_GetZPos(id2);
public Float:Core_GetZPos(id2) return Objects[id2][zpos];
forward Float:Core_GetXRot(id2);
public Float:Core_GetXRot(id2) return Objects[id2][xrot];
forward Float:Core_GetYRot(id2);
public Float:Core_GetYRot(id2) return Objects[id2][yrot];
forward Float:Core_GetZRot(id2);
public Float:Core_GetZRot(id2) return Objects[id2][zrot];
forward Core_SetStreamObjectPos(id2,Float:xpos2,Float:ypos2,Float:zpos2);
public Core_SetStreamObjectPos(id2,Float:xpos2,Float:ypos2,Float:zpos2)
{
	Objects[id2][xpos] = xpos2, Objects[id2][ypos] = ypos2, Objects[id2][zpos] = zpos2;
	for(new i=0;i<MAX_PLAYERS;i++) if(IsPlayerConnected(i) && PlayerObjects[i][seen][id2] == true) SetPlayerObjectPos(i,PlayerObjects[i][pobjects][id2],xpos2,ypos2,zpos2);
}
forward Core_SetStreamObjectRot(id2,Float:xrot2,Float:yrot2,Float:zrot2);
public Core_SetStreamObjectRot(id2,Float:xrot2,Float:yrot2,Float:zrot2)
{
	Objects[id2][xrot] = xrot2, Objects[id2][yrot] = yrot2, Objects[id2][zrot] = zrot2;
	for(new i=0;i<MAX_PLAYERS;i++) if(IsPlayerConnected(i) && PlayerObjects[i][seen][id2] == true) SetPlayerObjectRot(i,PlayerObjects[i][pobjects][id2],xrot2,yrot2,zrot2);
}
forward Core_AttachStreamObjectToPlayer(id2,playerid,Float:xoff2,Float:yoff2,Float:zoff2,Float:xrot2,Float:yrot2,Float:zrot2);
public Core_AttachStreamObjectToPlayer(id2,playerid,Float:xoff2,Float:yoff2,Float:zoff2,Float:xrot2,Float:yrot2,Float:zrot2)
{
	Objects[id2][attached] = playerid;
	Objects[id2][xoff] = xoff2;
	Objects[id2][yoff] = yoff2;
	Objects[id2][zoff] = zoff2;
	Objects[id2][xrot] = xrot2;
	Objects[id2][yrot] = yrot2;
	Objects[id2][zrot] = zrot2;
	if(!attaching[0])
	{
		attaching[0] = 1;
		attaching[1] = SetTimer("UpdateAttach",100,1);
	}
	for(new i=0;i<MAX_PLAYERS;i++) if (IsPlayerConnected(i) && PlayerObjects[i][seen][id2] == true)
	{
		SetPlayerObjectPos(i,PlayerObjects[i][pobjects][id2],xoff2,yoff2,zoff2);
		SetPlayerObjectRot(i,PlayerObjects[i][pobjects][id2],xrot2,yrot2,zrot2);
	}
}
forward Core_MoveStreamObject(id2,Float:movx2,Float:movy2,Float:movz2,Float:speed2);
public Core_MoveStreamObject(id2,Float:movx2,Float:movy2,Float:movz2,Float:speed2)
{
	Objects[id2][moving] = true;
	Objects[id2][movx] = movx2;
	Objects[id2][movy] = movy2;
	Objects[id2][movz] = movz2;
	Objects[id2][speed] = speed2;
	for(new i=0;i<MAX_PLAYERS;i++) if (IsPlayerConnected(i) && PlayerObjects[i][seen][id2] == true) MovePlayerObject(i,PlayerObjects[i][pobjects][id2],movx2,movy2,movz2,speed2);
	new Float:time = (GetDistance(Objects[id2][xpos],Objects[id2][ypos],Objects[id2][zpos],movx2,movy2,movz2)/speed2)/1.17;
	new Float:xadd = (time == 0.0) ? 0.0 : ((movx2 - Objects[id2][xpos])/time);
	new Float:yadd = (time == 0.0) ? 0.0 : ((movy2 - Objects[id2][ypos])/time);
	new Float:zadd = (time == 0.0) ? 0.0 : ((movz2 - Objects[id2][zpos])/time);
	new bool:xisbigger = (movx2 >= Objects[id2][xpos]) ? true : false;
	new bool:yisbigger = (movy2 >= Objects[id2][ypos]) ? true : false;
	new bool:zisbigger = (movz2 >= Objects[id2][zpos]) ? true : false;
	Objects[id2][movetimer] = SetTimerEx("MoveTimer",1000,1,"ifffbbb",id2,xadd,yadd,zadd,xisbigger,yisbigger,zisbigger);
}
forward Core_MidoStreamDisconnect(playerid);
public Core_MidoStreamDisconnect(playerid)
{
	for(new i=0;i<=created;i++)
	{
		if(PlayerObjects[playerid][seen][i] == true)
		{
			DestroyPlayerObject(playerid,PlayerObjects[playerid][pobjects][i]);
			PlayerObjects[playerid][seen][i] = false;
		}
	}
}
public OnFilterScriptInit()
{
	SetTimer("StreamTimer", 1000, 1);
	return 1;
}
forward StreamTimer();
public StreamTimer()
{
	new Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2;
	for(new i = 0 ; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			GetPlayerPos(i,x,y,z);
			for(new p=0;p<=created;p++)
			{
				if(Objects[p][modelid] != 0)
				{
					if(Objects[p][attached] != -1)
					{
						GetPlayerPos(Objects[p][attached],x2,y2,z2);
						Objects[p][xpos] = x2+Objects[p][xoff];
						Objects[p][ypos] = y2+Objects[p][yoff];
						Objects[p][zpos] = z2+Objects[p][zoff];
					}
					if(PointToPoint(x,y,z,Objects[p][xpos],Objects[p][ypos],Objects[p][zpos],Objects[p][viewdist]) && GetPlayerVirtualWorld(i) == Objects[i][world])
					{
						if(PlayerObjects[i][seen][p] == false)
						{
							PlayerObjects[i][pobjects][p] = CreatePlayerObject(i,Objects[p][modelid],Objects[p][xpos],Objects[p][ypos],Objects[p][zpos],Objects[p][xrot],Objects[p][yrot],Objects[p][zrot]);
							if (Objects[p][moving] == true) MovePlayerObject(i,PlayerObjects[i][pobjects][p],Objects[p][movx],Objects[p][movy],Objects[p][movz],Objects[p][speed]);
							PlayerObjects[i][seen][p] = true;
						}
					}
					else if (PlayerObjects[i][seen][p] == true)
					{
						DestroyPlayerObject(i,PlayerObjects[i][pobjects][p]);
						PlayerObjects[i][seen][p] = false;
					}
				}
			}
		}
	}
}
forward UpdateAttach();
public UpdateAttach()
{
	new Float:x, Float:y, Float:z, os = 0;
	for(new p=0;p<=created;p++) if(Objects[p][modelid] != 0 && Objects[p][attached] != -1) os++;
	if(!os) KillTimer(attaching[1]);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		if(IsPlayerConnected(i))
		{
			GetPlayerPos(i,x,y,z);
			for(new p=0;p<=created;p++)
			{
				if(Objects[p][modelid] != 0 && Objects[p][attached] != -1 && PlayerObjects[i][seen][p] == true)
				{
					SetPlayerObjectPos(i,PlayerObjects[i][pobjects][p],Objects[p][xoff],Objects[p][yoff],Objects[p][zoff]);
					SetPlayerObjectRot(i,PlayerObjects[i][pobjects][p],Objects[p][xrot],Objects[p][yrot],Objects[p][zrot]);
				}
			}
		}
	}
}
forward MoveTimer(id2,Float:xadd,Float:yadd,Float:zadd,bool:xisbigger,bool:yisbigger,bool:zisbigger);
public MoveTimer(id2,Float:xadd,Float:yadd,Float:zadd,bool:xisbigger,bool:yisbigger,bool:zisbigger)
{
	new bool:reached = false;
	if(xisbigger)
	{
		if (Objects[id2][xpos] >= Objects[id2][movx]) reached = true;
		else reached = false;
	}
	else
	{
		if(Objects[id2][xpos] <= Objects[id2][movx]) reached = true;
		else reached = false;
	}
	if(reached == true)
	{
		if(yisbigger)
		{
			if(Objects[id2][ypos] >= Objects[id2][movy]) reached = true;
			else reached = false;
		}
		else
		{
			if(Objects[id2][ypos] <= Objects[id2][movy]) reached = true;
			else reached = false;
		}
		if(reached == true)
		{
			if(zisbigger)
			{
				if(Objects[id2][zpos] >= Objects[id2][movz]) reached = true;
				else reached = false;
			}
			else
			{
				if(Objects[id2][zpos] <= Objects[id2][movz]) reached = true;
				else reached = false;
			}
		}
	}
	if(reached)
	{
		Objects[id2][moving] = false;
		for(new i=0; i<MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && PlayerObjects[i][seen][id2] == true)
			{
				MovePlayerObject(i,PlayerObjects[i][pobjects][id2],Objects[id2][movx],Objects[id2][movy],Objects[id2][movz],Objects[id2][speed]);
				Objects[id2][xpos] = Objects[id2][movx];
				Objects[id2][ypos] = Objects[id2][movy];
				Objects[id2][zpos] = Objects[id2][movz];
			}
		}
		CallRemoteFunction("OnSObjectMoved","ifff",id2,Objects[id2][xpos],Objects[id2][ypos],Objects[id2][zpos]);
		KillTimer(Objects[id2][movetimer]);
	}
	else
	{
		Objects[id2][xpos] = Objects[id2][xpos]+xadd;
		Objects[id2][ypos] = Objects[id2][ypos]+yadd;
		Objects[id2][zpos] = Objects[id2][zpos]+zadd;
	}
}
