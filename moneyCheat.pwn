#include "../DeathMatch/mc_f.pwn"
public OnPlayerUpdate(playerid)
{
   new string[128 char];
   if(GetPlayerMoney(playerid) > AC_MInfo[playerid][handMoney])
   {
	  format(string, sizeof string, " [ ACRO ] (%02i/3) - קיבלת אזהרה על שימוש בצ'יטים", ++AC_MInfo[playerid][warnings]);
	  SendClientMessage(playerid, 0 /* don't forget to change here the color RGB (alpha) */, string);
      if(AC_MInfo[playerid][warnings] == 3)
	  {
          AC_MInfo[playerid][warnings] = 0;
	      Kick(playerid);
	  }
   }
   return 1;
}
public OnPlayerConnect(playerid)
{
   AC_MInfo[playerid][warnings] = 0;
   AC_MInfo[playerid][handMoney] = 0;
   return 1;
}
