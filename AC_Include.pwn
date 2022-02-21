#if defined scripting_included
	#endinput
#else
	#define scripting_included
#endif
//=[Includes & Defines]===========================================================
#include "a_samp.inc"
//Colors:
#define red 0xFF0000AA
#define darkblue 0x3399ffaa
#define MAX_WARNINGS 3 // Max warning's before punish
#define kick_or_ban 1 // 1 = Kick, 2 = Ban.
#if !MAX_WARNINGS || !kick_or_ban || kick_or_ban > 2
#error
#endif
/*
   native SetVehicleHealth(playerid, vehicleid, Float:h);
*/
stock fixed_strval(string[]) return strlen(string) < 49 ? strval(string) : 0;
#define strval fixed_strval
enum AC //(<<= 1)
{
   Float:health,
   Float:armour,
   cash,
   warnings[4]
};
stock AC_Info[MAX_PLAYERS][AC];
stock _SetPlayerHealth(playerid, Float:h)
{
   AC_Info[playerid][health] = h;
   SetPlayerHealth(playerid, h);
   return 1;
}
stock _SetPlayerArmour(playerid, Float:a)
{
   AC_Info[playerid][armour] = a;
   SetPlayerArmour(playerid, a);
   return 1;
}
stock _GivePlayerMoney(playerid, money)
{
   if(money >= 0) AC_Info[playerid][cash] += money;
   else AC_Info[playerid][cash] -= money;
   GivePlayerMoney(playerid, money);
   return 1;
}
stock _ResetPlayerMoney(playerid)
{
   ResetPlayerMoney(playerid);
   AC_Info[playerid][cash] = 0;
   return 1;
}
stock _getName(playerid)
{
  new n[24];
  GetPlayerName(playerid, n, sizeof n);
  return n;
}
#define SetPlayerHealth _SetPlayerHealth
#define SetPlayerArmour _SetPlayerArmour
#define GivePlayerMoney _GivePlayerMoney
#define ResetPlayerMoney _ResetPlayerMoney
