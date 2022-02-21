/*
	* WDM DeathMatch Beta #1
	* � Copyright 2009, Roye Omer (`JoeShk`), Israel SA-MP Team
	* San Andreas Multiplayer 0.3
	* Creation Date: 18.12.2009
*/
#include "../DeathMatch/functions.pwn"
//=[News & Enums]===========================================================
// Main :
new Float:vspeed[MAX_PLAYERS][2];
// Users :
new.private PlayerInfo(logged[MAX_PLAYERS]) = {false, ...},
    PlayerInfo(worngPassword[MAX_PLAYERS]) = {MAX_WORNGS_LOGIN, ...},
	PlayerInfo(bool:isafk[MAX_PLAYERS]),
	PlayerInfo(mints[MAX_PLAYERS]),
	PlayerInfo(onClick[MAX_PLAYERS]);
// Insets :
new tele_words[100][MAX_STRING];
// VIP :
new VIPBank = -1;
// Clan :
new clanName[MAX_PLAYERS][256], isInvited[MAX_PLAYERS], pClan[MAX_PLAYERS][20], clanBanks[500], HQ_MoveObject = 0, HQ_Vehicles = 0;
enum pmoveGates
{
   gid,
   owner[256]
};
enum moveGates
{
   Float:xn,
   Float:yn,
   Float:zn,
   Float:xun,
   Float:yun,
   Float:zun,
   gid,
   owner[256],
   speed,
   bool:gstate
}
// Simple Password :
new simplePassword[][32] =
{
  "123", "1234",
  "12345", "123456",
  "1234567", "12345678",
  "123456789", "123123",
  "123321", "321321"
};
stock GateInfo[MAX_MOVE_GATES][moveGates], pGateInfo[MAX_PLAYERS][pmoveGates];
main() print("World DeathMatch by JoeShk loaded");
function(OnGameModeInit())
{
   new string[128], string2[128], cstring[3][64], a[][10] = { "?","!","?"};
   SetGameModeText(namemode " " version);
   UsePlayerPedAnims();
   ShowPlayerMarkers(1);
   ShowNameTags(1);
   // Clan :
   if(!dini_Exists("/Clans/Main.txt"))
   {
      dini_Create("/Clans/Main.txt");
      dini_IntSet("/Clans/Main.txt", "Total", 0);
   }
   if(!dini_Exists("/Clans/HQ/Main.ini"))
   {
      dini_Create("/Clans/HQ/Main.ini");
      dini_IntSet("/Clans/HQ/Main.ini", "Total", 0);
   }
   if(!dini_Exists("/Clans/HQ/Objects/Main.ini"))
   {
      dini_Create("/Clans/HQ/Objects/Main.ini");
      dini_IntSet("/Clans/HQ/Objects/Main.ini", "Total", 0);
   }
   for(new i = 0; i < dini_Int("/Clans/HQ/Objects/Main.ini", "Total") ; i++)
   {
	   format(string, sizeof string, "%i", i);
	   LoadHQObjects(string2, 0, dini_Get("/Clans/HQ/Objects/Main.ini", string));
   	   format(string2, sizeof string2, "/Clans/HQ/Objects/HQ_Pickups/%s.ini", dini_Get("/Clans/HQ/Objects/Main.ini", string));
	   format(string2, sizeof string2, "/Clans/HQ/Objects/HQ_Vehicles/%s.ini", dini_Get("/Clans/HQ/Objects/Main.ini", string));
	   LoadHQObjects(string2, 1, dini_Get("/Clans/HQ/Objects/Main.ini", string));
   	   format(string2, sizeof string2, "/Clans/HQ/Objects/HQ_Objects/%s.ini", dini_Get("/Clans/HQ/Objects/Main.ini", string));
	   LoadHQObjects(string2, 2, dini_Get("/Clans/HQ/Objects/Main.ini", string));
   	   format(string2, sizeof string2, "/Clans/HQ/Objects/HQ_MoveObjects/%s.ini", dini_Get("/Clans/HQ/Objects/Main.ini", string));
	   LoadHQObjects(string2, 3, dini_Get("/Clans/HQ/Objects/Main.ini", string));
       clanBanks[dini_Int(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "HQ_Count")] = CPS_AddCheckpoint(dini_Float(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "BX"), dini_Float(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "BY"), dini_Float(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "BZ"), 2.5, 20);
   }
   // VIP :
   if(!dini_Exists("/VIP/Details.txt")) dini_Create("/VIP/Details.txt");
   if(!dini_Exists("/VIP/Main.txt"))
   {
      dini_Create("/VIP/Main.txt");
      dini_IntSet("/VIP/Main.txt", "Total", 0);
      dini_FloatSet("/VIP/Main.txt", "B1", 0.0);
      dini_FloatSet("/VIP/Main.txt", "B2", 0.0);
      dini_FloatSet("/VIP/Main.txt", "B3", 0.0);
      dini_FloatSet("/VIP/Main.txt", "x1", 0.0);
      dini_FloatSet("/VIP/Main.txt", "y1", 0.0);
      dini_FloatSet("/VIP/Main.txt", "x2", 0.0);
      dini_FloatSet("/VIP/Main.txt", "y2", 0.0);
   }
   if(!dini_Exists("/VIP/Stats.txt"))
   {
      dini_Create("/VIP/Stats.txt");
      dini_IntSet("/VIP/Stats.txt", "Kills", 0);
      dini_IntSet("/VIP/Stats.txt", "Bank", 0);
   }
   if(dini_Float("/VIP/Main.txt", "B1") != 0.0 && dini_Float("/VIP/Main.txt", "B2") != 0.0 && dini_Float("/VIP/Main.txt", "B3") != 0.0) VIPBank = CPS_AddCheckpoint(dini_Float("/VIP/Main.txt", "B1"),dini_Float("/VIP/Main.txt", "B2"),dini_Float("/VIP/Main.txt", "B3"), 2.5, 20);
   // Weapons :
   if(!dini_Exists(cweapon))
   {
	   dini_Create(cweapon);
	   dini_IntSet(cweapon, "Total", 0);
	   dini_IntSet(cweapon, "CPS", 0);
   }
   for(new i = 0; i < dini_Int(cweapon, "CPS"); i++)
   {
	  format(cstring[0], 64, "CPX%i", i);
	  format(cstring[1], 64, "CPY%i", i);
	  format(cstring[2], 64, "CPZ%i", i);
	  Ammo_SHOP[i] = CPS_AddCheckpoint(dini_Float(cweapon, cstring[0]), dini_Float(cweapon, cstring[1]), dini_Float(cweapon, cstring[2]), 2.5, 30);
   }
   // Users :
   if(!dini_Exists(_fileconfig "Main.ini"))
   {
      dini_Create(_fileconfig "Main.ini");
	  dini_IntSet(_fileconfig "Main.ini", "Total", 0);
   }
   if(!dini_Exists(_fileconfig "Tags.ini"))
   {
      dini_Create(_fileconfig "Tags.ini");
	  dini_IntSet(_fileconfig "Tags.ini", "Total", 0);
   }
   if(!dini_Exists(_fileconfig "BIP.ini")) dini_Create(_fileconfig "BIP.ini");
   else
   {
	   dini_Remove(_fileconfig "BIP.ini");
       dini_Create(_fileconfig "BIP.ini");
   }
   dini_IntSet(_fileconfig "BIP.ini", "Total", 0);
   // Insets :
   if(!dini_Exists(vehicle_insetsfile))
   {
      dini_Create(vehicle_insetsfile);
	  dini_IntSet(vehicle_insetsfile, "Total", 0);
   }
   if(!dini_Exists(pickup_insetsfile))
   {
      dini_Create(pickup_insetsfile);
      dini_IntSet(pickup_insetsfile, "Total", 0);
   }
   if(!dini_Exists(teleports_insetsfile))
   {
      dini_Create(teleports_insetsfile);
      dini_IntSet(teleports_insetsfile, "Total", 0);
   }
   LoadTeleportsList();
   for(new p = 0; p < dini_Int(pickup_insetsfile, "Total") + 1; p++)
   {
      format(string, sizeof string,"/Insets/Pickups/%d.ini", p);
      if(dini_Exists(string)) CreatePickup(dini_Int(string, "pickupid"), dini_Int(string, "type"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"));
   }
   for(new v = 0; v < dini_Int(vehicle_insetsfile, "Total") + 1; v++)
   {
      format(string, sizeof string,"/Insets/Vehicles/%d.ini", v);
      if(dini_Exists(string)) CreateVehicle(dini_Int(string, "modelid"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), random(126), random(126), -1);
   }
   #pragma unused a
   return 1;
}
function(OnPlayerEnterVehicle(playerid, vehicleid))
{
   if(isHQVehicle(vehicleid)) return error(playerid, ".��� �� ���� ������ �� ���� ����� ����");
   return 1;
}
function(OnPlayerUpdate(playerid))
{
   // AntiCheat:
   new Float:_health[MAX_PLAYERS], Float:_armour[MAX_PLAYERS], Float:_vhealth[MAX_PLAYERS], Float:z;
   GetPlayerPos(playerid, vspeed[playerid][0], vspeed[playerid][1], z);
   GetPlayerHealth(playerid, _health[playerid]);
   GetPlayerArmour(playerid, _armour[playerid]);
   GetVehicleHealth(GetPlayerVehicleID(playerid), _vhealth[playerid]);
   if(_armour[playerid] > AC_Info[playerid][armour])
   {
	  SetPlayerArmour(playerid, AC_Info[playerid][armour]);
	  return AC_Info[playerid][warnings][0] == MAX_WARNINGS - 1? AC_Kick(playerid, "Armour") : AC_Warning(playerid, AC_Info[playerid][warnings][0], "Armour");
   }
   else if(_armour[playerid] < AC_Info[playerid][armour]) AC_Info[playerid][armour] = _armour[playerid];
   if(_health[playerid] > AC_Info[playerid][health])
   {
	  SetPlayerHealth(playerid, AC_Info[playerid][health]);
	  return AC_Info[playerid][warnings][1] == MAX_WARNINGS - 1? AC_Kick(playerid, "Health") : AC_Warning(playerid, AC_Info[playerid][warnings][1], "Health");
   }
   else if(_health[playerid] < AC_Info[playerid][health]) AC_Info[playerid][health] = _health[playerid];
   if(GetPlayerMoney(playerid) > AC_Info[playerid][cash])
   {
      ResetPlayerMoney(playerid);
	  return AC_Info[playerid][warnings][2] == MAX_WARNINGS - 1? AC_Kick(playerid, "Money") : AC_Warning(playerid, AC_Info[playerid][warnings][2], "Money");
   }
   else if(GetPlayerMoney(playerid) < AC_Info[playerid][cash]) AC_Info[playerid][cash] = GetPlayerMoney(playerid);
   if(!AC_Info[playerid][_sWeapons][GetPlayerWeapon(playerid)] && GetPlayerWeapon(playerid) != 0)
   {
	  ResetPlayerWeapons(playerid);
	  return AC_Info[playerid][warnings][3] == MAX_WARNINGS - 1? AC_Kick(playerid, "Weapons") : AC_Warning(playerid, AC_Info[playerid][warnings][3], "Weapons");
   }
   // Clan :
   if(dini_Exists(ClanPlayerFile(playerid)) && GetPlayerState(playerid) != 7)
   {
       strmid(pClan[playerid], dini_Get(ClanPlayerFile(playerid),"Clan_Name"),0,strlen(dini_Get(ClanPlayerFile(playerid),"Clan_Name")));
       if(!dini_Exists(ClanFile(pClan[playerid])))
	   {
	        dini_Remove(ClanPlayerFile(playerid));
	        error(playerid, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(playerid), false)? (".���� �� ����� �� ����, ����� ��� ���� ������ ����� ����, �� ��� ����� ����� ��� ����� ��") : (".����� ������ �������� �� ��� ����� ����, ����� ������ ��� �� ����� ���, ��� ����� ��"));
	        SendClientMessage(playerid, orange,"#Error: 0001");
	        if(!strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(playerid), false)) GivePlayerMoney(playerid, clanCost / 2);
	   }
   }
   return 1;
}
function(OnPlayerConnect(playerid))
{
   pGateInfo[playerid][gid] = 1;
   _Callback(OnPlayerJoin, playerid, GetName(playerid), GetIP(playerid), dini_Exists(getPlayerFile(playerid, _fileusers)), dini_Int(getPlayerFile(playerid, _fileusers), "autologin"), IsPlayerNPC(playerid)? 1 : 0);
   return 1;
}
function(OnPlayerRequestSpawn(playerid)) return _Callback(int, playerid, IsPlayerNPC(playerid), dini_Exists(getPlayerFile(playerid, _fileusers)));
function(OnPlayerEnterCheckpoint(playerid))
{
   new string[128];
   if(dini_Exists(ClanPlayerFile(playerid)))
   {
       if(CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")]))
       {
		    format(string, sizeof string, "  ~~~ !%s - ������ ����� ���� �� ����� ��� ~~~  ", dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
		    SendClientMessage(playerid, 0x00FFFFAA, string);
		    SendClientMessage(playerid, orange, "!���� ��, ������ ����� ������ ��� �� ����� ���, ��� ��� ���� ��� ��� ����� �� ���� �����");
		    SendClientMessage(playerid, 0x16EB43ff, " � /cbinfo - �� ��� ���� ���� �� ���� ����");
		    SendClientMessage(playerid, 0x16EB43ff, " � /cdeposit - �� ��� ������ ��� ������ ���� �� �����");
		    SendClientMessage(playerid, 0x16EB43ff, " � /cwithdraw - �� ��� ����� ��� ������� �� ���� �� �����");
		    return 1;
        }
   }
   if(CPS_IsPlayerInCheckpoint(playerid, VIPBank))
   {
	   if(isPlayerVIP(playerid))
	   {
			SendClientMessage(playerid, white, "------- [ VIP Bank - ��� ����''�� ] -------");
			format(string, sizeof string, " � !VIP - ������ ����� ���� �� ������ � %s - ���� ��",GetName(playerid));
			SendClientMessage(playerid, 0x00FFFFAA, string);
			format(string, sizeof string, dini_Int("/VIP/Stats.txt", "Bank") != 0? (" � %d$ - ���� �� � VIP - ����� �� ��� �") : (" � .��� ������� VIP - ����� ��� �"),dini_Int("/VIP/Stats.txt", "Bank"));
			SendClientMessage(playerid, dini_Int("/VIP/Stats.txt", "Bank") != 0? 0x16EB43FF : red, string);
			SendClientMessage(playerid,0x16EB43FF, " � /VDeposit - �� ��� ������ ������ ���� �� �������");
			SendClientMessage(playerid,0x16EB43FF, " � /VWithdraw - �� ��� ����� ��� ������ ���� �������");
			SendClientMessage(playerid,orange, " � VIP ����: �� ���� �� ���� ����� ����� ����, ���� ���� ����� ���� ��� ������, �� ������ ���� ��� ����� ������ *");
			SendClientMessage(playerid, white, "--------------------------------------");
		    return 1;
	   }
	   else error(playerid,".���� VIP - �'� ����� �� ���� �� ������ �");
	   return 1;
   }
   if(isPlayerInAmmoSHOP(playerid))
   {
	  format(string, sizeof string, "-------- [ ( � /BW [1-%i] � ) | !������ ����� ����� ����� ] --------",dini_Int(cweapon, "Total"));
	  SendClientMessage(playerid, white, string);
	  SendClientMessage(playerid, 0x16EB43FF, ".������ ����� ����� �����, �� ���� ����� ����� ������� ������ �� �� ���� �����");
	  format(string, sizeof string, " � /BuyWeapon(/Bw) [1-%i] - �� ��� ����� ���", dini_Int(cweapon, "Total"));
	  SendClientMessage(playerid, orange, string);
	  SendClientMessage(playerid, orange, " � /WeaponList(/Wl) - �� ��� ����� ������ �����");
	  SendClientMessage(playerid, white, "--------------------------------------");
	  return 1;
   }
   return 1;
}
function(OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]))
{
	new string[128];
    if(dialogid == 0) return response? clan_Accept(playerid) : SendClientMessage(playerid,orange," � /Clan Accept - �� �� 30 ����� ������ �� ��� ���� ������ ����� ������� ����, �� ��� ���� ���/�");
    if(dialogid == 1 && response)
	{
	   if(listitem == 0) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"  Clan Bank - Amount Of Money"," � ���� �� ����� ����� ���� ������ ������ ���� ���", "����", "�����");
	   if(listitem == 1) return ShowPlayerDialog(playerid,3,DIALOG_STYLE_MSGBOX,"  Clan Bank - All Of Money"," � �''� ����� �� ������ \"�����\" �� ���� ����� ���� ���� ��� ����� ������ ��� �� �����", "�����", "�����");
	   return 1;
	}
	if(dialogid == 2 && response)
	{
	    if(GetPlayerMoney(playerid) < strval(inputtext) || strval(inputtext) <= 0) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"  Clan Bank - Amount Of Money (Error: Worng Money)"," � ���� �� ����� ����� ���� ������ ������ ���� ���", "����", "�����");
	    format(string, sizeof string, " � !%d$ - ����� ������ ��� %s �����", strval(inputtext), GetName(playerid));
	    SendClanMessageToAll(playerid, orange, string);
	    dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank") + strval(inputtext));
	    GivePlayerMoney(playerid, -strval(inputtext));
	    return 1;
	}
	if(dialogid == 3 && response)
	{
	    if(GetPlayerMoney(playerid) < 1) return error(playerid, ".��� �� ���");
	    format(string, sizeof string, " � !%d$ - ����� ������ ��� �� �� ���� %s �����", GetPlayerMoney(playerid), GetName(playerid));
	    SendClanMessageToAll(playerid, orange, string);
	    dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank") + GetPlayerMoney(playerid));
	    ResetPlayerMoney(playerid);
	    return 1;
	}
	if(dialogid == 4 && response)
	{
	   if(strval(inputtext) > dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank"))
	   {
           format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
		   ShowPlayerDialog(playerid, 4, DIALOG_STYLE_INPUT, string," � ��� ��, ����� ����� ����� ���� ���� ��� ���� ����, ��� ��� ���� ������ ", "����", "�����");
		   return 1;
	   }
	   if(strval(inputtext) > dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw") && getPlayerClanLevel(playerid) != 4)
	   {
           format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
		   ShowPlayerDialog(playerid, 4, DIALOG_STYLE_INPUT, string, " � \"MaxWithdraw\" :��� ��, ����� ����� ���� ������, ���� ���� ����� ���� ������ ������ ����� ", "����", "�����");
		   return 1;
	   }
	   format(string, sizeof string, "%s",GetDateAsString('/', 1));
	   dini_Set(ClanPlayerFile(playerid),"Last_Withdraw", string);
	   GivePlayerMoney(playerid, strval(inputtext));
       format(string, sizeof string, " � !%d$ - ��� ������ ���� �� ����� %s �����", strval(inputtext), GetName(playerid));
	   SendClanMessageToAll(playerid, orange, string);
	   return 1;
	}
    if(dialogid == 5 && response) return _Callback(login, playerid, inputtext);
    if(dialogid == 6 && response) return _Callback(register, playerid, inputtext, GetIP(playerid));
	if(dialogid == 7 && response)
	{
  		if(listitem == 0)
		{
		     if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
			 ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " � Private Messsage - ����� �����",".��� ���� �� ������ ����� ��� ���� ���","���","�����");
			 return 1;
   		}
   		if(listitem == 1)
		{
		     if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
		     showStats(playerid, PlayerInfo(onClick[playerid]), 0);
			 return 1;
   		}
   		if(listitem == 2)
		{
		     if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
			 ShowPlayerDialog(playerid, 9, DIALOG_STYLE_INPUT, " � Pay - ����",".��� ���� �� ����� ����� ���� ���� �����", "���", "�����");
			 return 1;
   		}
   		if(listitem == 3)
   		{
		     if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
			 ShowPlayerDialog(playerid, 10, DIALOG_STYLE_INPUT," � Report - ����� ",".��� ���� �� ����� �� ������ �� �����","���","�����");
			 return 1;
        }
		return 1;
	}
	if(dialogid == 8 && response)
	{
       if(!strlen(inputtext)) return ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " � Private Messsage - ����� �����",".��� ���� �� ������ ����� ��� ���� ���","���","�����");
       OnPlayerPrivmsg(playerid, PlayerInfo(onClick[playerid]), inputtext);
	   return 1;
	}
	if(dialogid == 9 && response == 1)
	{
		if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
		if(GetPlayerMoney(playerid) < strval(inputtext)) return	ShowPlayerDialog(playerid,9, DIALOG_STYLE_INPUT," � Pay - ����",".���� ����! ��� ���� ���� ��� ��","���","�����");
		if(strval(inputtext) < 1) return ShowPlayerDialog(playerid, 9, DIALOG_STYLE_INPUT, " � Pay - ����",".���� ����! ��� ���� ���� ������","���","�����");
	    GivePlayerMoney(playerid, -strval(inputtext));
	    GivePlayerMoney(PlayerInfo(onClick[playerid]), strval(inputtext));
	    format(string, sizeof string, " � !(> %d$) :���� ���� ����� �� ��� %s - ���� ��� � � ", strval(inputtext), GetName(PlayerInfo(onClick[playerid])));
	    SendClientMessage(playerid, darkblue, string);
	    format(string, sizeof string, " � !(> %d$) :���� ���� ������ %s - ����� ��� � � ", strval(inputtext), GetName(playerid));
	    SendClientMessage(PlayerInfo(onClick[playerid]), darkblue, string);
	    return 1;
	}
	if(dialogid == 10 && response == 1)
	{
		if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
		format(string ,sizeof string, " � Report on: %s [ID: � %i] from: %s � ", GetName(PlayerInfo(onClick[playerid])), PlayerInfo(onClick[playerid]), GetName(playerid));
		SendClientMessageToAdmins(red, string);
		format(string ,sizeof string, " � (\"%s\") � ", inputtext);
		SendClientMessageToAdmins(green, string);
		SendClientMessage(playerid, green," � !���� �� ������, �������� ����� ������ ������� ������� � ");
		return 1;
	}
	return 1;
}
function(OnPlayerClickPlayer(playerid, clickedplayerid, source))
{
   new string[128];
   PlayerInfo(onClick[playerid]) = clickedplayerid;
   if(playerid != clickedplayerid)
   {
      format(string, sizeof string, "   %s(#%03i) - �� ��������� ������� �����", GetName(clickedplayerid), clickedplayerid);
      ShowPlayerDialog(playerid, 7, 2, string, " � (1) Private Message(PM)\n � (2) Stats\n � (3) Pay (Give Money)\n � (4) Report","���","�����");
	  return 1;
   }
   return 1;
}
function(OnPlayerPrivmsg(playerid, recieverid, text[]))
{
   new string[128];
   if(strfind(text, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true) != -1)
   {
	  error(playerid, ".���� ���� ����� �� ������ ��� ������ �����");
	  return 0;
   }
   if(!PlayerInfo(logged[playerid]))
   {
      format(string, sizeof string, dini_Exists(getPlayerFile(playerid, _fileusers))? ("/login :��� ���� ������ ���� ����� ����� �� ,%s") : ("/register :��� ���� ������ ���� ����� ����� �� ,%s"), GetName(playerid));
      error(playerid, string);
      return 0;
   }
   if(isTextIP(text) == 1)
   {
	  error(playerid, ".�� ��� ����� ������� IP ���� ���� �����");
	  format(string, sizeof(string), "Anti IP: %s (id: %d) tried to write (PM): \"%s\"", GetName(playerid), playerid, text);
	  SendClientMessageToAdmins(red, string);
	  return 0;
   }
   format(string, sizeof string," > � %s (%03d) %s", GetName(recieverid), recieverid, text);
   SendClientMessage(playerid, darkblue, string);
   format(string, sizeof string," > � %s (%03d): %s", GetName(playerid), playerid, text);
   SendClientMessage(recieverid, 0xffff00ff, string);
   return 1;
}
function(OnPlayerText(playerid, text[]))
{
   new string[128], _string[3][128];
   if(!PlayerInfo(logged[playerid]))
   {
      format(string, sizeof string, dini_Exists(getPlayerFile(playerid, _fileusers))? ("/login :��� ���� ������ ���� ����� ����� �� ,%s") : ("/register :��� ���� ������ ���� ����� ����� �� ,%s"), GetName(playerid));
      error(playerid, string);
      return 0;
   }
   if(strfind(text, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true) != -1)
   {
	  error(playerid, ".���� ���� ����� �� ������ ��� ��'��");
	  return 0;
   }
   if(isTextIP(text))
   {
	  error(playerid, ".�� ��� ����� ������� IP ���� ���� �����");
	  format(string, sizeof string, "Anti IP: %s (id: %d) tried to write (Public Chat): \"%s\"", GetName(playerid), playerid, text);
	  SendClientMessageToAdmins(red, string);
	  return 0;
   }
   if(text[0] == '@' && isPlayerInClan(playerid))
   {
	   format(string, sizeof string, "@ %s [CLVL %d | ID: %i]", GetName(playerid), getPlayerClanLevel(playerid), playerid);
       SendClanMessageToAll(playerid, 0x00FFFFAA, string);
	   return 0;
   }
   else if(text[0] == '$')
   {
        format(string, sizeof string,"$ [VIP Chat]: %s [ID: %i]: %s", GetName(playerid), playerid, text[1]);
	    for(new i = 0; i < MAX_PLAYERS; i++) if(isPlayerVIP(i)) SendClientMessage(playerid, VIPColor, string);
	    return 0;
   }
   format(_string[0], 128, "%s", GetName(playerid));
   format(_string[1], 128, dini_Isset(_fileconfig "Tags.ini", _string[0]) && strcmp(dini_Get(_fileconfig "Tags.ini", _string[0]), "None", true) ? (" | %s") : (""), dini_Get(_fileconfig "Tags.ini", _string[0]));
   format(_string[2], 128, " %s [%03d%s]", text, playerid, _string[1]);
   for(new i = 0; i < MAX_PLAYERS; i++) if(PlayerInfo(logged[i])) SendPlayerMessageToPlayer(i, playerid, _string[2]);
   return 0;
}
function(OnPlayerSpawn(playerid))
{
   if(isPlayerInClan(playerid) && dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin") != -1) SetPlayerSkin(playerid,dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin"));
   if(isPlayerInClan(playerid)) setPlayerClanColor(playerid);
   if(dini_Int(VIPFile(playerid),"Color")) SetPlayerColor(playerid, VIPColor);
   ResetPlayerWeapons(playerid);
   SetPlayerHealth(playerid, 100.0);
   GivePlayerWeapons(playerid);
   return 1;
}
function(OnPlayerPickUpPickup(playerid, pickupid))
{
   AC_Info[playerid][armour] = 100.0;
   AC_Info[playerid][health] = 100.0;
   return 1;
}
function(OnPlayerDeath(playerid, killerid, reason))
{
   if(isPlayerInClan(killerid)) dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Kills",dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Kills") + 1);
   if(playerid != INVALID_PLAYER_ID && killerid != playerid && IsPlayerConnected(killerid) && !isPlayerVIP(playerid)) dini_IntSet("/VIP/Stats.txt", "Kills",dini_Int("/VIP/Stats.txt", "Kills")+1);
   if(killerid != playerid && IsPlayerConnected(killerid))
   {
      dini_IntSet(getPlayerFile(killerid, _filestats), "Kills", dini_Int(getPlayerFile(killerid, _filestats), "Kills")+1);
      dini_IntSet(getPlayerFile(playerid, _filestats), "Deaths", dini_Int(getPlayerFile(playerid, _filestats), "Deaths")+1);
   }
   fakeKill(playerid, killerid);
   return 1;
}
function(OnPlayerKeyStateChange(playerid, newkeys, oldkeys))
{
   if(PlayerInfo(isafk[playerid])) setAFK(playerid, false);
   return 1;
}
function(OnPlayerCommandText(playerid, cmdtext[]))
{
   new cmd[256], idx, string[256];
   cmd = strtok(cmdtext, idx);
   mainCommands(playerid, cmdtext, cmd, idx, string); // Main Commands
   vipCommands(playerid, cmdtext, cmd, idx, string); // VIP Commands
   clanCommands(playerid, cmdtext, cmd, idx, string); // Clan Commands
   weaponsCommands(playerid, cmdtext, cmd, idx, string); // Weapons Commands
   if(IsPlayerAdmin(playerid)) insetsCommands(playerid, cmdtext, cmd, idx, string); // Insets Commands
   return 1;
}
stock vehicleCommands(playerid, cmdtext[], cmd[], idx=1, string[256])
{
   if(!strcmp(cmd, "/v", true) || !strcmp(cmd, "/vehicle", true))
   {
	  cmd = strtok(cmdtext, idx);
	  if(!strlen(cmd))
	  {
		  return 1;
	  }
	  return 1;
   }
   return 1;
}
stock mainCommands(playerid, cmdtext[], cmd[], idx=1, string[256])
{
   new anOcmd[256];
   if(!strcmp(cmd, "/help", true))
   {
	  anOcmd = strtok(cmdtext, idx);
	  if(!strlen(anOcmd))
	  {
	     SendClientMessage(playerid, lightblue, "  ~~~ Main Help - ���� ����� ~~~");
	     SendClientMessage(playerid, 0xff0000f, "  " forum " - ����� ������");
	     SendClientMessage(playerid, pink,  "  .�� ��� ���� ���� ����� ����� �� ����� ����� ���� ���� ����");
	     SendClientMessage(playerid, pink,  "  /help mode - ��� ����� | /help 1 - ������ | /help {subject/id} - ����� ���� ����");
	     SendClientMessage(playerid, 0xff0066ff, "  [Target/2] - ���� ���� / ����� ���� | [Features/Mode/1] - ������� ����");
	     SendClientMessage(playerid, 0xff0066ff, "  [Levels/4] - ���� | [Tips/3] - �����");
	     SendClientMessage(playerid, 0xff0066ff, "  [Server/6] - ���� �� ���� | [Info/5] - ���� ����");
         SendClientMessage(playerid, 0xffff00ff, "  " version " - ���� ������ �� ����");
         return 1;
	  }
	  if(_equal(anOcmd, "features") || _equal(anOcmd, "mode") || strval(anOcmd) == 1)
	  {
		 anOcmd = strtok(cmdtext, idx);
		 if(!strlen(anOcmd))
		 {
			 SendClientMessage(playerid, white, "\n");
			 modeLine(playerid, " Teleports(1) � Commands(2) � Bank(3) � Weapons(4) � Vehicle(5) � VIP(6) � Clan(7)");
			 modeLine(playerid, "", 2);
			 modeLine(playerid, "", 3);
			 SendClientMessage(playerid, white, "\n");
			 return 1;
		 }
		 if(equal_Mode(anOcmd, "teleports", "tele", 1))
		 {
            featureModeIn(playerid, "Teleports",
			" :������ �������",
			" /t � /teleports" ,
			" ,���� ��, ����� �������� ���� ���� ���� ����� ����� ������� ���",
			" ,������� �� ����� ������� ������� ��������, ������ ������, ������ �����, ����",
			" .��� ��������� ���� ����� ��������, ��� ���� ��� ���� ���� - ���� �������",
			" .���� ��, �� ���� ������ ����� ���, �� ���� ������ ���� ���� ������� - ��� ���� ����",
			"None",
			"None",
			"None",
			"None");
			return 1;
		 }
		 if(equal_Mode(anOcmd, "commands", "com", 2))
		 {
			return 1;
		 }
		 if(equal_Mode(anOcmd, "bank", "banks", 3))
		 {
			return 1;
		 }
		 if(equal_Mode(anOcmd, "weapons", "weap", 4))
		 {
			return 1;
		 }
		 if(equal_Mode(anOcmd, "vehicle", "vehicles", 5))
		 {
			return 1;
		 }
		 if(equal_Mode(anOcmd, "vip", "veryimportantpepole", 6))
		 {
			return 1;
		 }
		 if(equal_Mode(anOcmd, "clans", "clan", 7))
		 {
			return 1;
		 }
		 return error(playerid, ".����� ���� ����");
	  }
	  if(_equal(anOcmd, "target") || _equal(anOcmd, "objective") || strval(anOcmd) == 2)
	  {
		 return 1;
	  }
	  if(_equal(anOcmd, "tips") || _equal(anOcmd, "vices") || strval(anOcmd) == 3)
	  {
		 return 1;
	  }
	  if(_equal(anOcmd, "levels") || _equal(anOcmd, "lvls") || strval(anOcmd) == 4)
	  {
		 return 1;
	  }
	  if(_equal(anOcmd, "info") || strval(anOcmd) == 5)
	  {
	     SendClientMessage(playerid, lightblue, " ~~~ Help Info - ���� ���� ~~~");
	     SendClientMessage(playerid, pink, "  ~ " scripter " - ���� ����� �� ����");
	     SendClientMessage(playerid, grey, "  ~ " forum " - �� ��� ���� ����� ������ ����");
	     SendClientMessage(playerid, grey, "  ~ " ventrilo " - ����� ��������� �� ����");
	     SendClientMessage(playerid, grey, "  ~ " version " - ����� ����");
	     SendClientMessage(playerid, grey, "  ~ " namemode " - �� ����");
	     SendClientMessage(playerid, grey, "  ~ " lastupdate " - ����� �����");
         SendClientMessage(playerid, lightblue, "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
		 return 1;
	  }
	  if(_equal(anOcmd, "server") || _equal(anOcmd, "svr") || strval(anOcmd) == 6)
	  {
		 return 1;
	  }
      return error(playerid, ".���� ���� ����");
   }
   if(!strcmp(cmd, "/changepass", true) || !strcmp(cmd, "/changepassword", true))
   {
	  if(!dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/register :��� �� ���� ��� �����");
	  ShowPlayerDialog(playerid, 11, DIALOG_STYLE_INPUT, "   Users Systems \\ ����� �������", " � \"��� ��� �� ������ ����� ��� ����: \"��� �����", "��� �����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/login", true))
   {
	  if(PlayerInfo(logged[playerid])) return error(playerid, ".��� ��� �����");
	  if(!dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/register :��� �� ���� ��� �����");
      ShowPlayerDialog(playerid,5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/register", true))
   {
	  if(dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/login :��� ��� ����, ��� �����");
	  ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ������ ������ ����� ������", "����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/stats", true))
   {
	  anOcmd = strtok(cmdtext, idx);
	  showStats(playerid, !strlen(anOcmd)? playerid : strval(anOcmd), 0);
 	  return 1;
   }
   adminCommand(cmd, "/tag")
   {
	  new file[32], cmd2[256];
	  anOcmd = strtok(cmdtext, idx);
	  if(!strlen(anOcmd)) return SendClientMessage(playerid, white, "Usage: /tag [set/remove]");
	  if(_equal(anOcmd, "set"))
	  {
		  anOcmd = strtok(cmdtext, idx);
		  cmd2 = strtok_line(cmdtext, idx);
		  format(file, sizeof file, "%s", anOcmd);
		  if(!strlen(anOcmd) || !strlen(cmd2)) return SendClientMessage(playerid, white, "Usage: /tag set [name] [dest]");
		  dini_Set(_fileconfig "Tags.ini", file, cmd2);
		  SendClientMessage(playerid, orange, ".����� ����� �� �� ���� ������");
		  return 1;
	  }
	  if(_equal(anOcmd, "remove"))
	  {
          anOcmd = strtok(cmdtext, idx);
		  format(file, sizeof file, "%s", anOcmd);
		  if(!dini_Isset(_fileconfig "Tags.ini", file)) return error(playerid, ".����� �� ��� ���");
		  dini_Set(_fileconfig "Tags.ini", file, "None");
		  SendClientMessage(playerid, orange, ".���� ����� �� �� ���� ������");
		  return 1;
	  }
	  return error(playerid, ".����� �����");
   }
   if(!strcmp(cmd, "/kill", true)) return SetPlayerHealth(playerid, 0);
   if(!strcmp(cmd, "/t", true) || !strcmp(cmd, "/tele", true) || !strcmp(cmd, "/teleports", true) || !strcmp(cmd, "/teleport", true))
   {
   		new next_line = 0, lines = 0, _text[256];
		if !dini_Int(teleports_insetsfile, "Total") *then return error(playerid, ".��� ������� ���� ����");
        format(string, sizeof string, "-------- [ Teleports - (%03d) - ������� ] --------", dini_Int(teleports_insetsfile, "Total"));
        SendClientMessage(playerid, white, string);
        _text = " ";
		for(new i = 0; i < sizeof tele_words; i++)
		{
		    if (!strcmp(tele_words[i],"*EOF*",true)) continue;
   			format(string,sizeof string," � /%s",tele_words[i]);
   			strcat(_text, string);
			next_line++;
			if(next_line == 10)
			{
                 lines++;
				 SendClientMessage(playerid,orange, _text);
				 string = " ", next_line = 0, _text = " ";
			}
		}
		if (next_line >= 1) SendClientMessage(playerid, orange, _text);
        SendClientMessage(playerid, white, "--------------------------------------------------");
        return 1;
   }
   format(string, sizeof string, "/Insets/Teleports/%s.ini", cmd);
   if(dini_Exists(string))
   {
	   createTeleport(playerid, dini_Int(string, "interior"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), dini_Int(string, "with_vehicle"), dini_Int(string, "level"), dini_Get(string, "cmd"));
	   return 1;
   }
   return 1;
}
stock weaponsCommands(playerid, cmdtext[], cmd[], idx=1, string[256])
{
   if(!strcmp(cmd, "/weapons", true))
   {
       new wstring[2][128], found = 0, wps[256], id = -1;
       wps = strtok(cmdtext, idx);
       id = !strlen(wps)? playerid : strval(wps);
	   if(strlen(wps) > 0 && !IsPlayerConnected(id)) return error(playerid, ".���� �� �� �����");
       if(!dini_Exists(WeaponFile(id))) return error(playerid, (id) == (playerid)? (".��� �� ����� �������") : (".����� �� ��� ����� �������"));
       format(string, sizeof string, (id) == (playerid)? ("-------- [ %s's - ����� ������ ��� ] --------") : ("-------- [ %s's - ����� ������ �� ] --------"), GetName(id));
	   SendClientMessage(playerid, white, string);
	   for(new i = 0; i < dini_Int(cweapon, "Total"); i++)
	   {
           format(wstring[0], 128, "weapon%i", i);
           format(wstring[1], 128, "ammo%i", i);
	       if(dini_Isset(WeaponFile(id), wstring[0]) && dini_Isset(WeaponFile(id), wstring[1]) && dini_Int(WeaponFile(id), wstring[0]) >= 1 && dini_Int(WeaponFile(id), wstring[1]) >= 1)
	       {
			    format(string, sizeof string, " � %i. Weapon: %s ( Weapon DN\"S: %i ) <~> Ammo: %d", ++found, Weapons[dini_Int(WeaponFile(id), wstring[0])], dini_Int(WeaponFile(id), wstring[1]));
			    SendClientMessage(playerid, random(2) == random(2)? darkblue : brown, string);
	       }
	   }
	   SendClientMessage(playerid, white, "--------------------------------------");
	   return 1;
   }
   if !strcmp(cmd, "/wl", true) || !strcmp(cmd, "/weaponlist", true) *then
   {
	 new string2[128], string3[128];
	 if !isPlayerInAmmoSHOP(playerid) *then return error(playerid, ".��� �� ���� ���� ������� ���� ��������");
	 if !dini_Int(cweapon, "Total") *then return error(playerid, ".������ ��� �� ����� ����� ����, �� ����� ����� �� ������ ������");
	 format(string3, sizeof string3, "-------- [ (%i) - ����� ����� ] --------",dini_Int(cweapon, "Total"));
	 SendClientMessage(playerid, white, string3);
	 for(new i = 0; i < dini_Int(cweapon, "Total")+1; i++)
	 {
         format(string, sizeof string, "/Users/Weapons/Weapon%d.ini",i);
         format(string2, sizeof string2, "/Users/Weapons/Weapon%d.ini",i+1);
         if dini_Exists(string) *then
         {
		     format(string3, sizeof string3, dini_Exists(string) && !dini_Exists(string2) ? (" � (\"/bw %d\"), Weapon: %s, Ammo: %d, (%d$, %i)") : (" � (\"/bw %d\"), Weapon: %s, Ammo: %d, (%d$, %i) | (\"/bw %d\"),  Weapon: %s, Ammo: %d, (%d$, %i)"), i, dini_Get(string, "Weapon_Name"), dini_Int(string, "ammo"), dini_Int(string, "cost"), dini_Int(string, "level"), i+1, dini_Get(string2, "Weapon_Name"), dini_Int(string2, "ammo"), dini_Int(string2, "cost"), dini_Int(string2, "level"));
		     SendClientMessage(playerid, random(2)+1? 0x16EB43FF : orange, string3);
		     if dini_Exists(string) && dini_Exists(string2) *then i++;
         }
	 }
	 SendClientMessage(playerid, white, "--------------------------------------");
     return 1;
   }
   if(!strcmp(cmd, "/dw", true) || !strcmp(cmd, "/dropweapon", true))
   {
      new wps[256];
      wps = strtok(cmdtext, idx);
   	  format(wstring[0], 128, "weapon%i", strval(wps));
	  format(wstring[1], 128, "ammo%i", strval(wps));
	  if(!isPlayerInAmmoSHOP(playerid)) return error(playerid, " .��� �� ���� ���� ������� ���� ��������");
      if(!strlen(wps))
	  {
	     SendClientMessage(playerid, white, " Usage: /dropweapon(/dw) [Weapon DN\"S]");
	     SendClientMessage(playerid, white, " /Weapons - �� ���� DN\"S - �� ��� ����� �� �");
	     return 1;
	  }
	  if(!dini_Isset(WeaponFile(playerid), wstring[0]) || dini_Int(WeaponFile(playerid), wstring[0]) <= 0) return error(playerid, ".��� �� �� ���� ���");
	  format(string, sizeof string, " � !\"%s\" - ���� �� ����", Weapons[dini_Int(WeaponFile(playerid), wstring[0])]);
	  SendClientMessage(playerid, darkblue, string);
	  for(new i = 0; i < 2; i++) dini_IntSet(WeaponFile(playerid), wstring[i], 0);
	  dini_IntSet(WeaponFile(playerid), "Total", dini_Int(WeaponFile(playerid), "Total")-1);
	  return 1;
   }
   if(!strcmp(cmd, "/bw", true) || !strcmp(cmd, "/buyweapon", true))
   {
	  new _vtmp[256], string3[128], _ammo = 0;
	  _vtmp = strtok(cmdtext, idx);
	  format(string, sizeof string, "/Users/Weapons/Weapon%d.ini", strval(_vtmp));
	  if !isPlayerInAmmoSHOP(playerid) *then return error(playerid, ".��� �� ���� ���� ������� ���� ��������");
	  if !dini_Int(cweapon, "Total") *then return error(playerid, ".������ ��� �� ����� ����� ����, �� ����� ����� �� ������ ������");
	  if(!strlen(_vtmp))
	  {
		 (format(string, sizeof string, (" Usage: /bw [1-%d]") ,dini_Int(cweapon, "Total")),
		 SendClientMessage(playerid, white, string));
	     return 1;
	  }
	  if(!dini_Exists(string)) return error(playerid, ".��� ����");
	  if(dini_Int(string, "level") < getPlayerLevel(playerid))
	  {
		 format(string3, sizeof string3, "��� �� ���� ������� ����: %i ����.", dini_Int(string, "level"));
		 error(playerid, string3);
		 return 1;
	  }
	  if(GetPlayerMoney(playerid) < dini_Int(string, "cost"))
	  {
		  format(string3, sizeof string3, " � !%d$ - ���� \"%s\" - ����", dini_Int(string, "cost"), dini_Get(string, "Weapon_Name"));
		  error(playerid, string3);
		  format(string3, sizeof string3, " � !%d$ - �� ��� ����� ��� �� ��� ��", dini_Int(string, "cost") - GetPlayerMoney(playerid)); // Tested (my money: 7$, cost weapon: 12$) (Test: 7-12 = 5, 5 + = 7 = 12)
		  error(playerid, string3);
		  return 1;
	  }
	  if(!dini_Exists(WeaponFile(playerid)))
	  {
	     dini_Create(WeaponFile(playerid));
	     dini_IntSet(WeaponFile(playerid), "Total", 0);
	  }
	  format(string3, sizeof string3, "weapon%i", strval(_vtmp));
	  if(!dini_Isset(WeaponFile(playerid), string3) || !dini_Int(WeaponFile(playerid), string3)) dini_IntSet(WeaponFile(playerid), "Total", dini_Int(WeaponFile(playerid), "Total")+1);
	  dini_IntSet(WeaponFile(playerid), string3, dini_Int(string, "id"));
	  format(string3, sizeof string3, "ammo%i", strval(_vtmp));
	  dini_IntSet(WeaponFile(playerid), string3, dini_Int(WeaponFile(playerid), string3) + dini_Int(string, "Ammo"));
	  GivePlayerWeapon(playerid, strval(_vtmp), dini_Int(string, "Ammo"));
	  _ammo = dini_Int(WeaponFile(playerid), string3);
  	  format(string3, sizeof string3, " � !������ \"%s\" - ���� �� ����", dini_Get(string, "Weapon_Name"));
	  SendClientMessage(playerid, orange, string3);
	  format(string3, sizeof string3, " � !%i - ���� ������� ����� ����", dini_Int(string, "Ammo"));
	  SendClientMessage(playerid, orange, string3);
  	  format(string3, sizeof string3, " � !%i - ���� ������� ��� �� ���� ��", _ammo);
	  SendClientMessage(playerid, orange, string3);
	  GivePlayerMoney(playerid, -dini_Int(string, "cost"));
	  return 1;
   }
   if(!strcmp(cmd, "/cweapons", true) && IsPlayerAdmin(playerid))
   {
	  new _vtmp[256];
	  _vtmp = strtok(cmdtext, idx);
	  if(!strlen(_vtmp)) return SendClientMessage(playerid, white, " Usage: /cweapons [add/store]");
	  if(_equal(_vtmp, "add"))
	  {
		  new _vtmp2[256], _vtmp3[256], _vtmp4[256], _vtmp5[256];
		  _vtmp2 = strtok(cmdtext, idx); _vtmp3 = strtok(cmdtext, idx);
		  _vtmp4 = strtok(cmdtext, idx); _vtmp5 = strtok(cmdtext, idx);
		  if(!strlen(_vtmp2) || !strlen(_vtmp3) || !strlen(_vtmp4) || !strlen(_vtmp5)) return SendClientMessage(playerid, white, " Usage: /cweapons add [weapon id] [ammo] [cost] [level]");
		  dini_IntSet(cweapon, "Total", dini_Int(cweapon, "Total") + 1);
          format(string, sizeof string, "/Users/Weapons/Weapon%d.ini",dini_Int(cweapon, "Total"));
          dini_Create(string);
          dini_IntSet(string, "id", strval(_vtmp2));
          dini_IntSet(string, "ammo", strval(_vtmp3));
          dini_IntSet(string, "cost", strval(_vtmp4));
          dini_IntSet(string, "level", strval(_vtmp5));
          dini_Set(string, "Weapon_Name", Weapons[strval(_vtmp2)]);
          format(string, sizeof string, " � You was created a new weapon(gun): ID: %i, Ammo: %i, Cost: %d$, Level: %d, Weapon: \"%s\"",strval(_vtmp2),strval(_vtmp3), strval(_vtmp4), strval(_vtmp5), Weapons[strval(_vtmp2)]);
          SendClientMessage(playerid, orange, string);
		  return 1;
	  }
	  if(_equal(_vtmp, "store"))
	  {
		 new Float:pos[3];
		 if(dini_Int(cweapon,"CPS") == MAX_AMMO_SHOP) return error(playerid, "!��� �� ���� ������ ��� ������ �����");
		 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		 format(string, sizeof string, "CPX%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[0]);
  		 format(string, sizeof string, "CPY%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[1]);
  		 format(string, sizeof string, "CPZ%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[2]);
		 Ammo_SHOP[dini_Int(cweapon, "CPS")] = CPS_AddCheckpoint(pos[0], pos[1], pos[2], 2.5, 30);
		 dini_IntSet(cweapon, "CPS", dini_Int(cweapon, "CPS") + 1);
		 SendClientMessage(playerid, orange, ".����� ���� ����� ������");
		 return 1;
	  }
	  return 1;
   }
   return 1;
}
stock insetsCommands(playerid, cmdtext[], cmd[], idx=1, string[256])
{
   if(!strcmp(cmd, "/insets", true))
   {
	    new _a1[256], _a2[256], _a3[256], _a4[256], _a5[256], Float:opos[4], File:fp;
	    _a1 = strtok(cmdtext, idx);
	    if(!strlen(_a1)) return SendClientMessage(playerid,white, "Usage: /insets [create/destroy]");
	    if(_equal(_a1, "create"))
	    {
             _a2 = strtok(cmdtext, idx);
             if(!strlen(_a2)) return SendClientMessage(playerid, white, "Usage: /insets create [pickup/vehicle/teleport]");
             if(_equal(_a2, "teleport"))
             {
                 _a3 = strtok(cmdtext, idx);
                 _a4 = strtok(cmdtext, idx);
                 _a5 = strtok(cmdtext, idx);
				 GetPlayerPos(playerid, opos[0], opos[1], opos[2]);
				 GetPlayerFacingAngle(playerid, opos[3]);
                 if(!strlen(_a3) || !strlen(_a4) || !strlen(_a5)) return SendClientMessage(playerid, white, "Usage: /insets create teleport [command name] [with vehicle: 1 / 0] [level]");
                 dini_IntSet(teleports_insetsfile, "Total", dini_Int(teleports_insetsfile, "Total")+1);
				 format(string, sizeof string, "/Insets/Teleports/%s.ini", _a3);
			     dini_Create(string);
			     dini_FloatSet(string, "x", opos[0]);
			     dini_FloatSet(string, "y", opos[1]);
			     dini_FloatSet(string, "z", opos[2]);
			     dini_FloatSet(string, "angle", opos[3]);
			     dini_Set(string, "cmd", _a3);
//			     dini_Set(string, "info", _a6);
			     dini_Set(string, "Creater", GetName(playerid));
			     dini_IntSet(string, "with_vehicle", strval(_a4));
			     dini_IntSet(string, "level", strval(_a5));
			     //dini_IntSet(string, "interior", !GetPlayerInterior(playerid)? 0 : GetPlayerInterior(playerid));
                 format(string, sizeof string, "tele%i", dini_Int(teleports_insetsfile, "Total"));
                 dini_Set(teleports_insetsfile, string, _a3);
                 format(string, sizeof string, "%s(%i)", _a3, strval(_a5));
		         fp = fopen(teleports_lists,io_append);
		         fwrite(fp, string);
		         fwrite(fp,"\n");
		         fclose(fp);
				 format(string, sizeof string, " � /insets desroy teleport %s :���� ����� ���, ��� ����� �� ����� ������, ����� ���� ���� ����� �� ������",_a3);
			     SendClientMessage(playerid, orange, string);
			     LoadTeleportsList();
				 return 1;
			 }
             if(_equal(_a2, "vehicle"))
             {
                 _a3 = strtok(cmdtext, idx);
                 if(!strlen(_a3)) return SendClientMessage(playerid, white, "Usage: /insets create vehicle [term]");
                 dini_IntSet(vehicle_insetsfile, "Total", dini_Int(vehicle_insetsfile, "Total")+1);
				 format(string, sizeof string, "/Insets/Vehicles/%d.ini", dini_Int(vehicle_insetsfile, "Total"));
			     GetVehiclePos(GetPlayerVehicleID(playerid), opos[0], opos[1], opos[2]);
			     GetVehicleZAngle(GetPlayerVehicleID(playerid), opos[3]);
			     dini_Create(string);
			     dini_IntSet(string, "modelid", GetVehicleModel(GetPlayerVehicleID(playerid)));
			     dini_FloatSet(string, "x", opos[0]);
			     dini_FloatSet(string, "y", opos[1]);
			     dini_FloatSet(string, "z", opos[2]);
			     dini_FloatSet(string, "angle", opos[3]);
			     dini_Set(string, "var", _a3);
			     SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			     CreateVehicle(GetVehicleModel(GetPlayerVehicleID(playerid)), opos[0], opos[1], opos[2], opos[3], random(126), random(126), -1);
			     format(string, sizeof string, " � /insets desroy vehicle %i :���� ��� ����� ��� ����, ��� ��� ����� �� �����, �� ���� ����� �� ���� ����� �� ���",dini_Int(vehicle_insetsfile, "Total"));
			     SendClientMessage(playerid, orange, string);
			     return 1;
             }
 			 if(_equal(_a2, "pickup"))
			 {
                _a3 = strtok(cmdtext, idx);
                _a4 = strtok(cmdtext, idx);
                _a5 = strtok(cmdtext, idx);
                if(!(strlen(_a3) || strlen(_a4) || strlen(_a5))) return SendClientMessage(playerid, white, "Usage: /insets create pickup [pickupid] [type] [term]");
                dini_IntSet(vehicle_insetsfile, "Total", dini_Int(vehicle_insetsfile, "Total")+1);
				format(string, sizeof string, "/Insets/Pickups/%d.ini", dini_Int(pickup_insetsfile, "Total"));
			    GetPlayerPos(playerid, opos[0], opos[1], opos[2]);
			    dini_Create(string);
			    dini_IntSet(string, "pickupid", strval(_a3));
			    dini_IntSet(string, "type", strval(_a4));
			    dini_FloatSet(string, "x", opos[0]);
			    dini_FloatSet(string, "y", opos[1]);
			    dini_FloatSet(string, "z", opos[2]);
			    dini_Set(string, "var", _a5);
			    CreatePickup(strval(_a3), strval(_a4), opos[0], opos[1], opos[2]);
			    format(string, sizeof string, " � /insets desroy pickup %i :���� ����� ����� ��� ����, ��� ��� ����� �� �����, �� ���� ����� �� ������ ����� �� ���",dini_Int(pickup_insetsfile, "Total"));
				SendClientMessage(playerid, orange, string);
				return 1;
			 }
             return 1;
	    }
	    if(_equal(_a1, "destroy"))
	    {
		   _a2 = strtok(cmdtext, idx);
		   if(!strlen(_a2)) return SendClientMessage(playerid, white, "Usage: /insets desroy [pickup/vehicle/teleport]");
		   if(_equal(_a2, "teleport"))
		   {
			 new bool:results = false;
			 _a3 = strtok(cmdtext, idx);
			 if(!strlen(_a3) || _a3[0] == '/') return SendClientMessage(playerid, !strlen(_a3) && _a3[0] != '/'? white : red, !strlen(_a3) && _a3[0] != '/'? ("Usage: /insets desroy teleport [tele name]") : (".��� ���� ������ � - '/' ��� ����� �� �� �������"));
			 for (new i = 0; i < 100; i++)
			 {
		          if (!strcmp(tele_words[i],cmd,true))
				  {
				      memcpy(tele_words[i],"*EOF*",0, MAX_STRING);
				      results = true;
		          }
			 }
		     format(string,sizeof string,!results? (".\"%s\" - �� ���� ����� ���") : (".\"%s\" - ���� �� ������") ,cmd);
		     SendClientMessage(playerid, orange, string);
		     SaveTeleportsList();
			 return 1;
		   }
		   if(_equal(_a2, "pickup"))
		   {
			  _a3 = strtok(cmdtext, idx);
			  format(string, sizeof string, "/Insets/Pickups/%d.ini", strval(_a3));
			  if(!strlen(_a3)) return SendClientMessage(playerid, white, "Usage: /insets desroy pickup [pickup-id]");
			  if(!dini_Exists(string)) return error(playerid, ".�� ���� ����� ���, ��� ���� �� ������ ����");
		      dini_Remove(string);
              format(string, sizeof string, "!%i :���� �� ������", strval(_a3));
		      SendClientMessage(playerid, orange, string);
			  return 1;
			}
		   if(_equal(_a2, "vehicle"))
		   {
			  _a3 = strtok(cmdtext, idx);
			  format(string, sizeof string, "/Insets/Vehicles/%d.ini", strval(_a3));
			  if(!strlen(_a3)) return SendClientMessage(playerid, white, "Usage: /insets desroy vehicle [pickup-id]");
			  if(!dini_Exists(string)) return error(playerid, ".�� ���� ��� ���, ��� ���� �� ������ ����");
		      dini_Remove(string);
              format(string, sizeof string, "!%i :���� �� ����", strval(_a3));
		      SendClientMessage(playerid, orange, string);
			  return 1;
			}
		}
	    return 1;
   }
   return 1;
}
stock clanCommands(playerid, cmdtext[], cmd[], idx=1, string[256])
{
   if(!strcmp(cmd, "/cbinfo", true) || !strcmp(cmd, "/clanbankinfo", true))
   {
	   if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".��� �� ���� ���� ���� �����");
       if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return error(playerid, ".��� �� ���� ���� �� ����� ������ ���");
       SendClientMessage(playerid,white," --- Clan Bank Info - ���� ��� ���� --- ");
	   format(string, sizeof string, "!%d$ - ����� ���� �� ����� ���� �� �", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank"));
	   SendClientMessage(playerid, orange, string);
	   format(string, sizeof string, "!%d$ - �� ���� ���� ����� ���� �� ���", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
	   SendClientMessage(playerid, orange, string);
	   format(string, sizeof string, "%s", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? (".���� �� ����� ��� ����") : (".���� �� ����� ����"));
	   SendClientMessage(playerid, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? red : 0x16EB43ff, string);
	   return 1;
   }
   if(!strcmp(cmd, "/cdeposit", true))
   {
      if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".��� �� ���� ���� ���� �����");
      if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return error(playerid, ".��� �� ���� ���� �� ����� ������ ���");
	  if(GetPlayerMoney(playerid) < 1) return error(playerid, ".��� ���� ���");
      ShowPlayerDialog(playerid,1,2, "All Of Money :���� ���� ��������� �������, �� �� ������� ������ �� �� ���� ���\nAmount Of Money :�� �� ������� ������ ��� �����"," � (1) Amount Of Money\n � (2) All Of Money", "���", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/cwithdraw", true))
   {
	  format(string, sizeof string, "%s",GetDateAsString('/', 1));
      if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".��� �� ���� ���� ���� �����");
      if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return error(playerid, ".��� �� ���� ���� �� ����� ������ ���");
      if(!DaysBetweenDates(dini_Get(ClanPlayerFile(playerid),"Last_Withdraw"), string) && strcmp(dini_Get(ClanPlayerFile(playerid),"Last_Withdraw"), "None", true) && getPlayerClanLevel(playerid) != 4) return error(playerid, ".��� ���� ���� ��� ������� ��� �� ����� ���");
	  format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
      ShowPlayerDialog(playerid,4, DIALOG_STYLE_INPUT, string," � ��� ��� �� ����� ����� ���� ����� ������� ��� �� ����� ��� ", "����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/og", true))
   {
       getMoveObjectNearPlayer(playerid);
	   if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".��� �� ���� ���� ���� �����");
	   if(strcmp(pGateInfo[playerid][owner], dini_Get(ClanPlayerFile(playerid),"Clan_Name"), false)) return error(playerid,".������ ��� �� ����� ����� ���");
	   if(!PlayerToPoint(playerid, 15.0, GateInfo[pGateInfo[playerid][gid]][xn], GateInfo[pGateInfo[playerid][gid]][yn], GateInfo[pGateInfo[playerid][gid]][zn])) return error(playerid, ".��� �� ���� ��� ��� ������� ����� ����� ������ ���");
	   if(GateInfo[pGateInfo[playerid][gid]][gstate]) return error(playerid, ".�������� ��� ��� ����");
	   setGateLoctions(pGateInfo[playerid][gid], true);
	   return 1;
   }
   if(!strcmp(cmd, "/cg", true))
   {
       getMoveObjectNearPlayer(playerid);
	   if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".��� �� ���� ���� ���� �����");
	   if(strcmp(pGateInfo[playerid][owner], dini_Get(ClanPlayerFile(playerid),"Clan_Name"), false)) return error(playerid,".������ ��� �� ����� ����� ���");
	   if(!PlayerToPoint(playerid, 15.0, GateInfo[pGateInfo[playerid][gid]][xn], GateInfo[pGateInfo[playerid][gid]][yn], GateInfo[pGateInfo[playerid][gid]][zn])) return error(playerid, ".��� �� ���� ��� ��� ������� ����� ����� ������ ���");
	   if(!GateInfo[pGateInfo[playerid][gid]][gstate]) return error(playerid, ".�������� ��� ��� ����");
	   setGateLoctions(pGateInfo[playerid][gid], false);
	   return 1;
   }
   format(string, sizeof string, "/Clans/HQ/%s.ini", dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
   if(dini_Exists(string) && !strcmp(cmd, dini_Get(string,"CMD"), true))
   {
	  if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid,dini_Float(string, "FX"),dini_Float(string, "FY"),dini_Float(string, "FZ"));
	  else SetVehiclePos(GetPlayerVehicleID(playerid),dini_Float(string, "VX"),dini_Float(string, "VY"),dini_Float(string, "VZ"));
	  format(string, sizeof string, " � !%s - ������ ����� ������ �� ����� ���",dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
	  SendClientMessage(playerid, orange, string);
      return 1;
   }
   if(!strcmp(cmd, "/hq", true) && !dini_Exists(string)) return error(playerid, dini_Exists(ClanPlayerFile(playerid))? (".����� ��� ��� �����") : (".��� �� ���� ���� ����"));
   if(!strcmp(cmd, "/clan", true))
   {
	  new tmpclan[256];
	  tmpclan = strtok(cmdtext, idx);
	  if(!strlen(tmpclan))
	  {
	  	  SendClientMessage(playerid,white," --- Clan - ���� --- ");
	  	  SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Create - �� ��� ����� ����");
	  	  SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Invite - ������ ���� ����� ���");
	  	  SendClientMessage(playerid,0x16EB43ff," [03] � /Clan [Accept/Join] - ����� ����� �����");
          SendClientMessage(playerid,0x16EB43ff," [04] � /Clan [Leave/Exit/Quit] - ����� ����� �����");
	  	  SendClientMessage(playerid,0x16EB43ff," [05] � /Clan Info - �� ���� ������ ���� �� ������");
	  	  SendClientMessage(playerid,0x16EB43ff," [06] � /Clan [Set/Edit] - ����� / ����� �� ������ �����");
	  	  SendClientMessage(playerid,0x16EB43ff," [07] � /Clan Bank - ������ ����� ����");
	  	  SendClientMessage(playerid,0x16EB43ff," [08] � /Clan Memmbers - ����� �� �� ������� ������� ����� ������");
	  	  SendClientMessage(playerid,orange," [09] � '@' :�� ��� ���� ����� �'��");
	  	  if(IsPlayerAdmin(playerid))
	  	  {
  	  	       SendClientMessage(playerid,red,"*[A01] � /Clan HQ - ������ ������ ����");
  	  	       SendClientMessage(playerid,red,"*[A02] � /Clan Remove - ����� ����");
  	  	       SendClientMessage(playerid,red,"*[A03] � /ClanWar /ClanWarEnd - ������ ����� ���������");
		  }
		  return 1;
	  }
	  if(_equal(tmpclan,"hq") && IsPlayerAdmin(playerid))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan2))
		  {
              SendClientMessage(playerid,white," --- Clan - ���� --- ");
			  SendClientMessage(playerid,0x16EB43ff," [01] � /Clan HQ Create [Clan Name] - �� ��� ����� ����� �����");
			  SendClientMessage(playerid,0x16EB43ff," [02] � /Clan HQ Remove [Clan Name] - �� ��� ����� ����� �����");
			  SendClientMessage(playerid,0x16EB43ff," [03] � /Clan HQ SetAccess [From] [To] - ������ ����� ����� ��� ����� ���");
			  SendClientMessage(playerid,0x16EB43ff," [04] � /Clan HQ SetArea [Clan Name] [1-2] - �� ��� ����� �� ������ �� ������");
			  SendClientMessage(playerid,0x16EB43ff," [05] � (�� ���� - �� ����) | /Clan HQ Loadlist [Clan Name] - �� ��� ������ �� ������ ������");
			  return 1;
		  }
		  if(_equal(tmpclan2, "loadlist"))
		  {
			  new tmpclan3[256], string2[128];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan HQ Loadlist [Clan Name]");
			  format(string, sizeof string, "%s", tmpclan3);
			  format(string2, sizeof string2, "%i", dini_Int("/Clans/HQ/Objects/Main.ini", "Total"));
			  dini_Set("/Clans/HQ/Objects/Main.ini", string2, string);
			  dini_IntSet("/Clans/HQ/Objects/Main.ini", "Total", dini_Int("/Clans/HQ/Objects/Main.ini", "Total") + 1);
			  return 1;
		  }
		  if(_equal(tmpclan2, "setaccess"))
		  {
			  new tmpclan3[256], tmpclan4[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  tmpclan4 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3) || !strlen(tmpclan4)) return SendClientMessage(playerid, white, "Usage: /Clan HQ SetAccess [From] [To]");
			  if(!dini_Exists(ClanFile(tmpclan3)) || !dini_Exists(ClanFile(tmpclan4))) return error(playerid,".�� ���� / ������ ������ ����");
			  if(dini_Exists(HQ_ClanFile(tmpclan4))) return error(playerid,".����� ���� ���� ��� �� �� ������ �� ��� �����, �� ���� ������ �� ���� ����� ����� �� �� �����");
			  dini_Create(HQ_ClanFile(tmpclan4));
			  fcopytextfile(HQ_ClanFile(tmpclan3), HQ_ClanFile(tmpclan4));
			  dini_Remove(HQ_ClanFile(tmpclan3));
		      dini_Set(HQ_ClanFile(tmpclan4), "CMD", "/hq");
		      format(string, sizeof string, " � !%s - ����� �� %s - ����� �� ������ ��", tmpclan4, tmpclan3);
			  SendClientMessage(playerid, orange, string);
			  Admin_ClanMessageToAll(tmpclan3, red, " �  !��� ��� ���� �����, ������ ��� ����, �� ��� ���� ����� ����� �� ������ ����");
			  return 1;
		  }
		  if(_equal(tmpclan2, "create"))
		  {
			  new tmpclan3[256], Float:pos[3];
			  tmpclan3 = strtok(cmdtext, idx);
			  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan HQ Create [Clan Name]");
			  if(!dini_Exists(ClanFile(tmpclan3))) return error(playerid,".�� ���� ���� ���");
			  if(dini_Exists(HQ_ClanFile(tmpclan3))) return error(playerid,".����� �� �� ��� �����");
		      dini_IntSet("/Clans/HQ/Main.ini", "Total", dini_Int("/Clans/HQ/Main.ini", "Total") + 1);
			  dini_Create(HQ_ClanFile(tmpclan3));
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "FX", pos[0]);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "FY", pos[1]);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "FZ", pos[2]);
	    	  dini_FloatSet(HQ_ClanFile(tmpclan3), "VX", pos[0]);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "VY", pos[1]);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "VZ", pos[2]);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "BX", 0.0);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "VY", 0.0);
		      dini_FloatSet(HQ_ClanFile(tmpclan3), "BZ", 0.0);
		      dini_Set(HQ_ClanFile(tmpclan3), "CMD", "/hq");
		      dini_IntSet(HQ_ClanFile(tmpclan3), "HQ_Count", dini_Int("/Clans/HQ/Main.ini", "Total"));
		      format(string, sizeof string, " � !%s - ���� ���� ������", tmpclan3);
			  SendClientMessage(playerid, orange, string);
			  Admin_ClanMessageToAll(tmpclan3, orange, " � /HQ - ������ ��� ����� ���� �����, ���� ����� ����? ���/�");
		      return 1;
		  }
		  if(_equal(tmpclan2,"setarea") && IsPlayerAdmin(playerid))
		  {
		     new tmpclana2[256],tmpclana1[256], Float:pos[3], i = 0;
		     tmpclana1 = strtok(cmdtext, idx);
		     tmpclana2 = strtok(cmdtext, idx);
		     GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		     if(!dini_Exists(HQ_ClanFile(tmpclana1))) return error(playerid,".���� �� �� ���� / ����� �� ��� �����");
		     if(!strlen(tmpclana2) || !strlen(tmpclana1)) return SendClientMessage(playerid, white, "Usage: /clan hq setarea [Clan Name] [1-2] (1 = x1 + y1 | 2 = x2 + y2)");
		     if(strval(tmpclana2) < 1 && strval(tmpclana2) > 2) return error(playerid, ".���� ����� ����");
		     while(i < 2)
		     {
			     format(string,sizeof string,!i? ("x%i") : ("y%i"), strval(tmpclana2));
			     dini_FloatSet(HQ_ClanFile(tmpclana1), string, !i? pos[0] : pos[1]);
			     i++;
	     	 }
		     SendClientMessage(playerid, orange,strval(tmpclana2) == 2? ("!������ x2 + y2 ���� �� ��������") : ("!������ x1 + y1 ���� �� ��������"));
			 return 1;
		  }
		  if(_equal(tmpclan2, "remove"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan HQ Remove [Clan Name]");
			  if(!dini_Exists(HQ_ClanFile(tmpclan3))) return error(playerid,".����� �� ��� �����");
			  dini_Remove(HQ_ClanFile(tmpclan3));
			  format(string, sizeof string, " � !%s - ���� �� ������ �����", tmpclan3);
			  SendClientMessage(playerid, orange, string);
			  Admin_ClanMessageToAll(tmpclan3, red, " �  !��� ��� ���� �����, ������ ��� ����, �� ��� ���� ����� ����� �� ������ ����");
		      return 1;
		  }
		  return error(playerid,".����� ���� �����");
	  }
	  if(_equal(tmpclan,"remove") && IsPlayerAdmin(playerid))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Remove [Name]");
		  if(!dini_Exists(ClanFile(tmpclan2))) return error(playerid,".�� ���� ���� ���");
		  dini_IntSet("/Clans/Main.txt", "Total", dini_Int("/Clans/Main.txt", "Total")-1);
		  dini_Remove(ClanFile(tmpclan2));
		  if(dini_Exists(HQ_ClanFile(tmpclan2))) dini_Remove(HQ_ClanFile(tmpclan2));
		  return 1;
	  }
	  if(_equal(tmpclan,"create"))
	  {
		  new tmpclan2[256], date[3];
		  getdate(date[2], date[1], date[0]);
		  tmpclan2 = strtok(cmdtext, idx);
          format(string, sizeof string , "%s",GetDateAsString('/', 1));
		  if(GetPlayerMoney(playerid) < clanCost) return SendClientMessage(playerid,red,".��� ���� ����� 300000$ �� ��� ����� ����");
		  if(dini_Exists(ClanPlayerFile(playerid))) return error(playerid,".��� ��� ���� �����");
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Create [Name]");
		  if(dini_Exists(ClanFile(tmpclan2))) return error(playerid,".���� ��� ���� ��� ���");
		  dini_IntSet("/Clans/Main.txt", "Total", dini_Int("/Clans/Main.txt", "Total") + 1);
		  dini_Create(ClanFile(tmpclan2));
		  dini_IntSet(ClanFile(tmpclan2), "Total", 1);
		  dini_IntSet(ClanFile(tmpclan2), "Tournament_Take_Part_In", 0);
		  dini_IntSet(ClanFile(tmpclan2), "Tournament_Victory", 0);
		  dini_IntSet(ClanFile(tmpclan2), "Skin", -1);
		  dini_IntSet(ClanFile(tmpclan2), "C1", -1);
		  dini_IntSet(ClanFile(tmpclan2), "C2", -1);
		  dini_IntSet(ClanFile(tmpclan2), "C3", -1);
		  dini_IntSet(ClanFile(tmpclan2), "HQ_Count", -1);
		  dini_IntSet(ClanFile(tmpclan2), "Tests", 1);
		  dini_IntSet(ClanFile(tmpclan2), "Chat", 1);
		  dini_IntSet(ClanFile(tmpclan2), "Bank", 0);
		  dini_IntSet(ClanFile(tmpclan2), "Bank_MaxWithdraw", 2500);
		  dini_IntSet(ClanFile(tmpclan2), "Bank_Lock", 1);
		  dini_IntSet(ClanFile(tmpclan2), "Clan_Count", dini_Int("/Clans/Main.txt", "Total"));
		  dini_Set(ClanFile(tmpclan2),"Clan_Name",tmpclan2);
		  dini_Set(ClanFile(tmpclan2),"Clan_Owner",GetName(playerid));
		  dini_Set(ClanFile(tmpclan2),"Opend_Date",string);
		  dini_Set(ClanFile(tmpclan2),"Clan_Message","None");
		  dini_Set(ClanFile(tmpclan2),"Clan_Player1",GetName(playerid));
		  dini_Create(ClanPlayerFile(playerid));
		  dini_Set(ClanPlayerFile(playerid),"Clan_Name",tmpclan2);
		  dini_Set(ClanPlayerFile(playerid),"Last_Withdraw","None");
		  dini_IntSet(ClanPlayerFile(playerid), "Clan_Skin", 1);
		  dini_IntSet(ClanPlayerFile(playerid), "Clan_Chat", 1);
		  dini_IntSet(ClanPlayerFile(playerid), "Clan_Level", 4);
		  dini_IntSet(ClanPlayerFile(playerid), "Clan_Count", dini_Int("/Clans/Main.txt", "Total"));
		  dini_IntSet(ClanPlayerFile(playerid), "Clan_Memmber", 1);
		  format(string, sizeof string,"Clan%i", dini_Int("/Clans/Main.txt", "Total"));
		  dini_Set("/Clans/Main.txt", string, tmpclan2);
		  format(string, sizeof string, " -------- [ %s - ���� ���� ��� ��� ] -------- ", tmpclan2);
		  SendClientMessage(playerid, white, string);
		  SendClientMessage(playerid, 0x16EB43FF," � /Clan Invite - �� ��� ������ ���� ����� ���� ���");
		  SendClientMessage(playerid, 0x16EB43FF," � /Clan Edit Color - �� ��� ����� �� ���� �� ����� ���");
		  SendClientMessage(playerid, 0x16EB43FF," � /Clans  - �� ��� ����� ������ ������ ����");
		  SendClientMessage(playerid, 0x16EB43FF," � /Clan - �� ��� ����� ��� ������ ������");
		  SendClientMessage(playerid, orange," � '@' - ��� ���� ��'�� �� ����� ���");
		  SendClientMessage(playerid, white, " -------------------------------------- ");
		  GivePlayerMoney(playerid, -clanCost);
	 	  return 1;
	  }
	  if(_equal(tmpclan, "info"))
 	  {
		  new tmpclan4[256];
		  tmpclan4 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan4))
		  {
		      SendClientMessage(playerid,white," --- Clan Info - ���� ���� --- ");
		      SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Info Stats - ������ �� �����");
		      SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Info Details - ���� �� �����");
		      SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Info Memmbers - ���� ������ ������ �� �����");
			  return 1;
		  }
		  if(_equal(tmpclan, "memmbers"))
		  {
		     new tmpclan3[256];
		     tmpclan3 = strtok(cmdtext, idx);
		     clanMemmbers(playerid, tmpclan3);
		     return 1;
		  }
		  if(_equal(tmpclan4, "stats"))
		  {
			 new tmpclan3[256];
			 tmpclan3 = strtok(cmdtext, idx);
			 if(!strlen(tmpclan3)) return SendClientMessage(playerid, white,"Usage: /Clan Info Stats [name]");
			 if(!dini_Exists(ClanFile(tmpclan3))) return error(playerid,".�� ���� ���� ���");
		     format(string, sizeof string, " -------- [ Clan(%s) - Statics] -------- ",tmpclan3);
		     SendClientMessage(playerid, white, string);
	 	     format(string, sizeof string, getClanConnected(tmpclan3) > 0? (" � %d - ������ ������� ����� �� ���") : (" � .��� ��� ������ ������� ����� ��"),getClanConnected(tmpclan3));
	 	     SendClientMessage(playerid, getClanConnected(tmpclan3) > 0? 0x16EB43FF : red, string);
	 	     format(string, sizeof string, dini_Int(ClanFile(tmpclan3),"Kills") != 0? (" � %d - ����� �� ������� �� ������� ��� �������� �����") : (" � .��� ����� ������ ����� ��"),dini_Int(ClanFile(tmpclan3),"Kills"));
	 	     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Kills") != 0? 0x16EB43FF : red, string);
	 	     format(string, sizeof string, dini_Int(ClanFile(tmpclan3),"Bank") != 0? (" � %d$ - ���� ���� ��� ����� ��� ������") : (" � .����� �� ��� ��� ����"),dini_Int(ClanFile(tmpclan3),"Bank"));
	 	     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Bank") != 0? 0x16EB43FF : red, string);
		     format(string, sizeof string, " � ./Clan Info [Details/Memmbers] %s - ���� ���� �� �����", tmpclan3);
		     SendClientMessage(playerid, orange, string);
			 SendClientMessage(playerid, white, " -------------------------------------- ");
	 	     return 1;
	 	  }
 		  if(_equal(tmpclan4, "details"))
		  {
			 new tmpclan3[256], _skin[12], _bank[128];
			 tmpclan3 = strtok(cmdtext, idx);
			 if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Info Details [name]");
			 if(!dini_Exists(ClanFile(tmpclan3))) return error(playerid,".�� ���� ���� ���");
			 format(_skin, 12, dini_Int(ClanFile(tmpclan3),"Skin") >= 1? ("%i") : ("���"), dini_Int(ClanFile(tmpclan3),"Skin"));
			 format(_bank, sizeof _bank, dini_Int(ClanFile(tmpclan3),"Bank") / dini_Int(ClanFile(tmpclan3),"Total") >= 1? ("%i") : ("��� ����� �� ��� ����"), dini_Int(ClanFile(tmpclan3),"Bank") / dini_Int(ClanFile(tmpclan3),"Total"));
		     format(string, sizeof string, " -------- [ Clan(%s) - Details ] -------- ",tmpclan3);
		     SendClientMessage(playerid, white, string);
		     format(string, sizeof string, " � %i - ���� ������ - %s - ���� ������ ����  � %s - ���� �� ���",dini_Int(ClanFile(tmpclan3),"Total"), dini_Get(ClanFile(tmpclan3),"Opend_Date"),dini_Get(ClanFile(tmpclan3),"Clan_Owner"));
		     SendClientMessage(playerid, 0x16EB43FF, string);
		     format(string, sizeof string, " � ����� �� �����: %s � ��� ��� �������� ����� �� ����� ����: %d.0$", _skin, _bank);
		     SendClientMessage(playerid, 0x16EB43FF, string);
		     format(string, sizeof string, !dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In")? (" � ���� �� �� ����� ����� ���������") : (" � %d/%d �������� ���������"),dini_Int(ClanFile(tmpclan3),"Tournament_Victory"), dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In"));
		     SendClientMessage(playerid, !dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In")? red : 0x16EB43FF, string);
		     format(string, sizeof string, !strcmp(dini_Get(ClanFile(tmpclan3),"Clan_Message"), "None", false)? (" � ��� ��� ����� ������ �����") : (" � %s"), dini_Get(ClanFile(tmpclan3),"Clan_Message"));
		     SendClientMessage(playerid, !strcmp(dini_Get(ClanFile(tmpclan3),"Clan_Message"), "None", false)? red : 0x16EB43FF, string);
		     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Test")? 0x16EB43FF : red, dini_Int(ClanFile(tmpclan3),"Test")? (" � ����� ���� ������") : (" � ����� ���� ������"));
		     format(string, sizeof string, " � ./Clan Info [Stats/Memmbers] %s - ���� ���� �� �����", tmpclan3);
		     SendClientMessage(playerid, orange, string);
			 SendClientMessage(playerid, white, " -------------------------------------- ");
	 	     return 1;
	 	  }
		  return error(playerid,".����� ���� �����");
	  }
	  if(_equal(tmpclan, "memmbers"))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  clanMemmbers(playerid, tmpclan2);
		  return 1;
	  }
	  if(_equal(tmpclan, "leave") || _equal(tmpclan, "exit") || _equal(tmpclan, "quit"))
	  {
		   new a = -1;
	       if(!isPlayerInClan(playerid)) return error(playerid, ".��� �� ���� ���� ����");
 		   format(string, sizeof string," � !%s - ���� ������ �� ����� ,%s - ���� ��", dini_Get(ClanPlayerFile(playerid), "Clan_Name"), GetName(playerid));
		   error(playerid, string);
		   format(string, sizeof string, " � !��� �� ���� %s - �����", GetName(playerid));
		   SendClanMessageToAllEx(playerid, red, string);
           format(string, sizeof string, "Clan_Player%i", dini_Int(ClanPlayerFile(playerid), "Clan_Memmber"));
		   dini_Set(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), string, "None");
  	       dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Total", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Total")-1);
  	       if(dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Total") < 1)
  	       {
			   a = dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Clan_Count");
			   dini_Remove(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")));
			   format(string, sizeof string, "Clan%i", a);
			   dini_Set("/Clans/Main.txt", string, "None");
			   dini_IntSet("/Clans/Main.txt", "Total", dini_Int("/Clans/Main.txt", "Total")-1);
		   }
		   dini_Remove(ClanPlayerFile(playerid));
		   return 1;
	  }
	  if(_equal(tmpclan, "kick"))
	  {
		   new tmpclan2[256], id = -1;
		   tmpclan2 = strtok(cmdtext, idx);
		   id = IsNumeric(tmpclan2)? strval(tmpclan2) : GetPlayerID(tmpclan2);
		   if(getPlayerClanLevel(playerid) < 3) return error(playerid, getPlayerClanLevel(playerid) > 0? (".����� �� ������� ����� ������ ����") : (".��� �� ���� ���� ����"));
		   if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Kick [playerid]");
		   if(!IsPlayerConnected(id)) return error(playerid,".���� �� �� �����");
		   if(!isPlayerInClan(id)) return error(playerid, ".���� �� �� ���� ���� ����");
   		   if(getPlayerClanLevel(playerid) < getPlayerClanLevel(id) || !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false))
		   {
		      error(playerid, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false)? (".��� �� ���� ����� �� ������ �� �����") : (".��� �� ���� ����� ���� ����� ��� ����� ���� ���� ����"));
		      format(string, sizeof string, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false)? (" � (%s) !���� ����� �� ������ �� ����� ,%s - �����") : (" � (%s) !���� ����� ���� ������ ���� ���� ���� ���� ,%s - �����"), GetName(id), GetName(playerid));
		      SendClanMessageToAllEx(playerid, red, string);
		      return 1;
		   }
		   if(strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), false)) return error(playerid,".���� �� �� ���� ����� ���");
           format(string, sizeof string, "Clan_Player%i", dini_Int(ClanPlayerFile(id), "Clan_Memmber"));
		   dini_Set(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), string, "None");
  	       dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), "Total", dini_Int(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), "Total")-1);
		   dini_Remove(ClanPlayerFile(id));
		   format(string, sizeof string," � !������ %s - ���� ��",GetName(id));
		   error(playerid, string);
 		   format(string, sizeof string," � !��� ���� ������ %s - ����� ,%s - ���� ��",GetName(playerid), GetName(id));
		   SendClientMessage(id, red, string);
		   format(string, sizeof string, " � !%s ���� ������ �� ��� %s - �����", GetName(playerid), GetName(id));
		   SendClanMessageToAllEx(playerid, red, string);
		   return 1;
	  }
	  if(_equal(tmpclan, "invite"))
	  {
		  new tmpclan2[256], id = -1;
		  tmpclan2 = strtok(cmdtext, idx);
		  id = IsNumeric(tmpclan2)? strval(tmpclan2) : GetPlayerID(tmpclan2);
		  if(getPlayerClanLevel(playerid) < 3) return error(playerid, getPlayerClanLevel(playerid) > 0? (".����� �� ������� ����� ������ ����") : (".��� �� ���� ���� ����"));
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Invite [playerid]");
		  if(!IsPlayerConnected(id)) return error(playerid,".���� �� �� �����");
		  if(isPlayerInClan(id)) return error(playerid, ".���� �� ��� ���� �����");
		  if(!strcmp(dini_Get(ClanPlayerFile(playerid), "Clan_Name"), clanName[id], false)) return error(playerid, ".���� �� ��� ����� ����� ���");
		  format(string,sizeof string,".�� ��� ������ ��� ����� ,%s - ����� ���� ������ ����� %s - �����",dini_Get(ClanPlayerFile(playerid), "Clan_Name"), GetName(playerid));
		  ShowPlayerDialog(id,0,DIALOG_STYLE_MSGBOX," �  /Clan Accept - ����� ����� �����, �� ��� ������ ��� \"�����\" �� ����� �",string,"�����","���� ����");
		  format(string, sizeof string," � !����� ����� ��� %s - ����� ��", GetName(playerid));
		  SendClientMessage(playerid, orange, string);
		  format(string, sizeof string, "!������ ����� %s - ����� �� ����� %s - �����", GetName(id), GetName(playerid));
		  SendClanMessageToAllEx(playerid, orange, string);
		  format(string, sizeof string," � !%s - ���� �� ������ ����� %s - �����", dini_Get(ClanPlayerFile(playerid),"Clan_Name"), GetName(playerid));
		  SendClientMessage(id, orange, string);
		  SendClientMessage(id,0x16EB43FF, " � (�� ����� ������) /Clan Accept - �� ��� ���� �� ������ ����� ���/�");
		  isInvited[id] = 1;
		  clanName[id] = dini_Get(ClanPlayerFile(playerid),"Clan_Name");
		  return 1;
	  }
	  if(_equal(tmpclan, "join") || _equal(tmpclan, "accept")) return !isPlayerInClan(playerid)? clan_Accept(playerid) : error(playerid,".��� ��� ���� �����");
	  if(_equal(tmpclan, "set"))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 4) return error(playerid, getPlayerClanLevel(playerid) > 0? (".����� �� ����� ����� ����") : (".��� �� ���� ���� ����"));
		  if(!strlen(tmpclan2))
		  {
		      SendClientMessage(playerid,white," --- Clan Set - ���� ������ --- ");
		      SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Set Level - ����� ���� ��� ����");
		      SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Set Skin [Skin-id/OFF] - �� ��� ����� �� ����� �� �����");
	  	      SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Edit - ���� ��������");
		      return 1;
		  }
		  if(_equal(tmpclan2, "level"))
		  {
			  new tmpclan3[256], tmpclan4[256], name_level[34];
			  tmpclan3 = strtok(cmdtext, idx);
			  tmpclan4 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan4) || !strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Set Level [playerid] [1 - Noraml | 2 - Tester | 3 - SubLeader | 4 - Owner + Leader]");
			  if(strval(tmpclan3) == playerid) return error(playerid, ".��� �� ���� ����� �� ���� ���");
			  if(getPlayerClanLevel(playerid) < getPlayerClanLevel(strval(tmpclan3)) || !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false))
			  {
		          error(playerid, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false)? (".��� �� ���� ����� �� ���� �� ������") : (".��� �� ���� ����� ��� ����� ���� ���"));
		          format(string, sizeof string, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false)? (" � (%s) !����� ���� ����� �� ���� �� ������ ,%s - �����") : (" � (%s) !���� ����� �� ���� ��� ����� ,%s - �����"), GetName(strval(tmpclan3)), GetName(playerid));
		          SendClanMessageToAllEx(playerid, red, string);
		          return 1;
			  }
			  if(strval(tmpclan4) == 1) name_level = "Normal";
			  if(strval(tmpclan4) == 2) name_level = "Tester";
			  if(strval(tmpclan4) == 3) name_level = "SubLeader";
			  if(strval(tmpclan4) == 4) name_level = "Owner + Leader";
			  format(string, sizeof string, "!\"%s (%i)\" - � %s - ���� �� ���� �� ,%s - ������", name_level, strval(tmpclan4), GetName(strval(tmpclan3)), GetName(playerid));
			  SendClanMessageToAll(playerid, orange, string);
			  dini_IntSet(ClanPlayerFile(strval(tmpclan3)), "Clan_Level", strval(tmpclan4));
			  return 1;
		  }
   		  if(_equal(tmpclan2, "skin"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Set Skin [skin-id]");
			  if(isSkinCrash(strval(tmpclan3)) && strcmp(tmpclan3, "off", true)) return error(playerid, ".���� ����");
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin", strcmp(tmpclan3, "off", true)? strval(tmpclan3) : -1);
			  format(string, sizeof string, strcmp(tmpclan3, "off", true)? (" � !%d :���� �� ����� �� ����� ������ ,%s - ������") : (" � !������ �� ����� ���� �� ����� ������"), strval(tmpclan3), GetName(playerid));
			  SendClanMessageToAll(playerid, orange, string);
 			  return 1;
		  }
		  return error(playerid,".����� ���� �����");
	  }
	  if(_equal(tmpclan, "edit"))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 3) return error(playerid, getPlayerClanLevel(playerid) > 0? (".����� �� ������� ����� ������ ����") : (".��� �� ���� ���� ����"));
		  if(!strlen(tmpclan2))
		  {
	  	      SendClientMessage(playerid,white," --- Clan Edit - ���� ����� --- ");
	  	      SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Edit Color - �� ��� ����� ����");
	  	      SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Edit HQ - ����� ������");
	  	      SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Edit Test - ����� / ����� ��������� ������");
	  	      SendClientMessage(playerid,0x16EB43ff," [04] � /Clan Edit Comment - ����� ����� �����");
	  	      SendClientMessage(playerid,0x16EB43ff," [05] � /Clan Set - ���� ��������");
			  return 1;
		  }
		  if(_equal(tmpclan2, "comment"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok_line(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white,"Usage: /Clan Edit Comment [Action]");
			  dini_Set(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Clan_Message",tmpclan3);
			  format(string, sizeof string, " � ./Clan Info Details - ���� �� ������� �� �����, �� ��� ����� �� %s - �����", GetName(playerid));
			  SendClanMessageToAll(playerid, orange, string);
			  return 1;
		  }
		  if(_equal(tmpclan2, "test"))
		  {
			  SendClientMessage(playerid, orange, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? (".���� �� ������� ������ �����") : (".���� �� ������� ������ �����"));
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Test", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? 0 : 1);
			  format(string,sizeof string, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? ("!��� �� ����� ������ ,%s - �����") : ("!��� �� ����� ������ ,%s - �����"), GetName(playerid));
			  SendClanMessageToAllEx(playerid, orange, string);
			  return 1;
		  }
		  if(_equal(tmpclan2, "hq"))
		  {
			  new tmpclan3[256], Float:pos[3];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(getPlayerClanLevel(playerid) < 4) return error(playerid, getPlayerClanLevel(playerid) > 0? (".����� �� ����� ����� ����") : (".��� �� ���� ���� ����"));
			  if(!dini_Exists(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")))) return error(playerid, ".��� ����� ��� �����");
			  if(!strlen(tmpclan3))
			  {
	  	         SendClientMessage(playerid,white," --- Clan Edit HQ - ���� ����� ����� --- ");
	  	         SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Edit HQ CMD - ����� ������ ������ ������");
                 SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Edit HQ Foot - ����� ������ �� ������ ������ �����");
	  	         SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Edit HQ Vehicle - ����� ������ �� ������ ������ ����");
	  	         return 1;
	  	      }
	  	      if(!isPlayerInHerHQ(playerid) && strcmp(tmpclan3, "cmd", true)) return SendClientMessage(playerid,red, ".�� ��� ���� ����� ����� ������ ��� ���� ����� ������ ���");
	  	      if(_equal(tmpclan3, "foot") || _equal(tmpclan3, "vehicle"))
	  	      {
				 new changed = 0;
				 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
				 format(string,sizeof string, "%sX", _equal(tmpclan3, "foot")? ("F") : ("V"));
				 for(new i = 0; i < 3; i++)
				 {
				    dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), string, pos[changed]);
				    changed++;
				    if(changed > 0) format(string,sizeof string, "%s%s", !strcmp(tmpclan3, "foot", true)? ("F") : ("V"), changed == 1? ("Y") : ("Z"));
			     }
				 SendClanMessageToAll(playerid, orange, _equal(tmpclan3, "vehicle")? (" � .������ ���� �� ������ �� ���� ������") : (" � .������ ���� �� ������ �� ����� ������"));
				 return 1;
	  	      }
	  	      if(_equal(tmpclan3, "cmd"))
	  	      {
				  new tmpclan4[256];
				  tmpclan4 = strtok(cmdtext, idx);
				  if(!strlen(tmpclan4)) return SendClientMessage(playerid, white, "Usage: /Clan Edit HQ Cmd [Command Name]");
				  if(tmpclan4[0] == '/') return error(playerid, ".��� ���� ������ � \"/\" ������ ����� �� �� �������");
				  format(string, sizeof string, "/%s", tmpclan4);
				  dini_Set(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "CMD", string);
				  format(string, sizeof string, " � /%s - ���� �� ������ �� ������ ������ � %s - ������", tmpclan4, GetName(playerid));
				  SendClanMessageToAll(playerid, orange, string);
				  return 1;
			  }
			  return error(playerid,".����� ���� �����");
		  }
		  if(_equal(tmpclan2, "color"))
		  {
		      new CC[3][256];
		      for(new d = 0; d < sizeof CC; d++) CC[d] = strtok(cmdtext, idx);
		      if(!strlen(CC[0]) || !strlen(CC[1]) || !strlen(CC[2])) return SendClientMessage(playerid,white,"Usage: /Clan Edit Color [red-1-255] [green-1-255] [blue-1-255]");
		      if(!strval(CC[0]) || strval(CC[0]) > 255 || !strval(CC[1]) || strval(CC[1]) > 255 || !strval(CC[2]) || strval(CC[2]) > 255) return SendClientMessage(playerid,red,".��� ���� ���� �� ��� �������� ���� �������� 1-255");
		      for(new i = 0; i < sizeof CC; i++)
		      {
			       format(string, sizeof string, "C%i", i + 1);
                   dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), string, strval(CC[i]));
		      }
		      format(string,sizeof string," � ���� �� ���� �� ����� ���� �� ����� �� ,%s - ����� ", GetName(playerid));
		      SendClientMessage(playerid, sgba2hex(strval(CC[0]), strval(CC[1]), strval(CC[2]), 200), string);
		      return 1;
		  }
		  return error(playerid,".����� ���� �����");
	  }
	  if(_equal(tmpclan, "bank"))
	  {
		  new Float:pos[3];
		  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 4) return error(playerid, getPlayerClanLevel(playerid) > 0? (".����� �� ����� ����� ����") : (".��� �� ���� ���� ����"));
		  if(!dini_Exists(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")))) return error(playerid, ".��� ����� ��� �����");
		  if(!strlen(tmpclan2))
		  {
             SendClientMessage(playerid,white," --- Clan Bank - ��� ���� --- ");
             SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Bank MaxWithdraw - ����� �\"������� �����\" ���� ���, �����");
             SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Bank SetPos - ����� ������ �� ����");
             SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Bank Lock - �� ��� ����� / ����� �� ���� �� �����");
			 return 1;
		  }
		  if(_equal(tmpclan2, "maxwithdraw"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Bank MaxWithdraw [Amount]");
			  if(strval(tmpclan3) > 1000000 || strval(tmpclan3) <= 1) return error(playerid, ".���� ����� ����");
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw", strval(tmpclan3));
		      format(string, sizeof string, " � !%d$ :���� �� �������� ����� ���� ���� ����� �� � %s - ������ �� �����", strval(tmpclan3), GetName(playerid));
		      SendClanMessageToAll(playerid, red, string);
			  return 1;
		  }
		  if(_equal(tmpclan2, "lock"))
		  {
             dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? 0 : 1);
			 format(string, sizeof string, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? (" � !��� �� ���� �� ����� %s - ������ �� �����") : (" � !��� �� ���� �� ����� %s - ������ �� �����"), GetName(playerid));
			 SendClanMessageToAll(playerid, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? red : 0x16EB43FF, string);
			 return 1;
		  }
		  if(_equal(tmpclan2, "setpos"))
		  {
	  	      if(!isPlayerInHerHQ(playerid)) return SendClientMessage(playerid,red, ".�� ��� ���� ����� ����� ������ ��� ���� ����� ������ ���");
			  if(dini_Float(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BX") != 0.0) CPS_RemoveCheckpoint(clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")]);
              clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")] = CPS_AddCheckpoint(pos[0], pos[1], pos[2], 2.5, 20);
              dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BX", pos[0]);
              dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BY", pos[1]);
              dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BZ", pos[2]);
		      format(string, sizeof string, " � !���� �� ������ �� ���� �� ����� %s - ������ �� �����",  GetName(playerid));
		      SendClanMessageToAll(playerid, red, string);
			  return 1;
		  }
		  return error(playerid,".����� ���� �����");
	  }
	  return error(playerid,".����� ���� �����");
   }
   if(!strcmp(cmd, "/clans", true))
   {
	   new clanfile[128], count_clan = 0;
	   if !dini_Int("/Clans/Main.txt", "Total") *then return error(playerid,".��� ������ ������ ����");
	   format(string, sizeof string, " -------- [ Memmber(s) Clan(s): %i] -------- ",dini_Int("/Clans/Main.txt", "Total"));
	   SendClientMessage(playerid, white, string);
	   for(new i = 0; i < dini_Int("/Clans/Main.txt", "Total") + 2; i++)
	   {
		  format(clanfile,sizeof clanfile,"Clan%i", i);
		  if(dini_Isset("/Clans/Main.txt", clanfile) && strcmp(dini_Get("/Clans/Main.txt", clanfile), "None", false))
		  {
		       format(string,sizeof string, " � %i. %s [Memmber(s): #%d | Connected Players: %d | Create By: %s]",count_clan + 1, dini_Get("/Clans/Main.txt", clanfile),1,getClanConnected(dini_Get("/Clans/Main.txt", clanfile)), dini_Get(ClanFile(dini_Get("/Clans/Main.txt", clanfile)),"Clan_Owner"));
		       SendClientMessage(playerid,dini_Exists(ClanPlayerFile(playerid)) && !strcmp(dini_Get(ClanPlayerFile(playerid),"Clan_Name"), dini_Get("/Clans/Main.txt", clanfile), false)? red : orange, string);
		       count_clan++;
		  }
		  else continue;
	   }
	   SendClientMessage(playerid, white, " -------------------------------------- ");
	   return 1;
   }
   return 1;
}
stock vipCommands(playerid, cmdtext[], cmd[], idx=1, string[256])
{
   if(!strcmp(cmd, "/vdeposit", true))
   {
	  new tmpvip[256];
	  tmpvip = strtok(cmdtext, idx);
	  #define vcp tmpvip
	  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP ���� ���");
	  if(!CPS_IsPlayerInCheckpoint(playerid, VIPBank)) return error(playerid, " � (VIP) ��� ���� ����� ���� �� ������� ���");
	  if(!strlen(tmpvip)) return SendClientMessage(playerid, white,"Usage: /vdeposit [amount]");
	  if(GetPlayerMoney(playerid) < strval(tmpvip)) return SendClientMessage(playerid, white, GetPlayerMoney(playerid) < 1? (".��� �� ��� ����") : (".��� �� �� ����� ������"));
	  format(string,sizeof string," � !%d$ - ���� �� � (VIP) ����� ������ ������� %s - �����", strval(tmpvip), GetName(playerid));
	  SendVIPMessageToAll(VIPColor, string);
	  format(string,sizeof string," � !%d$ - ����� ����� ��� ���� �� �", dini_Int(VIPFile(playerid),"Bank")+strval(tmpvip));
	  SendVIPMessageToAll(orange, string);
	  GivePlayerMoney(playerid, -strval(tmpvip));
	  dini_IntSet(VIPFile(playerid), "Bank", dini_Int(VIPFile(playerid),"Bank")+strval(tmpvip));
	  dini_IntSet("/VIP/Stats.txt", "Bank", dini_Int("/VIP/Stats.txt", "Bank")+strval(tmpvip));
	  return 1;
   }
   if(!strcmp(cmd, "/vwithdraw", true))
   {
	  new tmpvip[256];
	  tmpvip = strtok(cmdtext, idx);
	  #define vcp tmpvip
	  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP ���� ���");
	  if(!CPS_IsPlayerInCheckpoint(playerid, VIPBank)) return error(playerid, " � (VIP) ��� ���� ����� ���� �� ������� ���");
	  if(!strlen(tmpvip)) return SendClientMessage(playerid, white,"Usage: /vwithdraw [amount]");
	  if(dini_Int(VIPFile(playerid),"Bank") < strval(tmpvip)) return SendClientMessage(playerid, white, dini_Int(VIPFile(playerid),"Bank") < strval(tmpvip)? (".VIP - ��� �� ���� ����� ����� ���� �� ��� ���� �") : (".VIP - ��� �� ���� ����� ��� ������ �"));
	  format(string,sizeof string," � !%d$ - ���� �� � (VIP) ��� ������ ������ � %s - �����", strval(tmpvip), GetName(playerid));
	  SendVIPMessageToAll(VIPColor, string);
	  format(string,sizeof string," � !%d$ - ����� ����� ��� ���� �� �", dini_Int(VIPFile(playerid),"Bank")-strval(tmpvip));
	  SendVIPMessageToAll(orange, string);
	  GivePlayerMoney(playerid, strval(tmpvip));
	  dini_IntSet(VIPFile(playerid), "Bank", dini_Int(VIPFile(playerid),"Bank")-strval(tmpvip));
	  dini_IntSet("/VIP/Stats.txt", "Bank", dini_Int("/VIP/Stats.txt", "Bank") - strval(tmpvip));
	  return 1;
   }
   if(!strcmp(cmd, "/vips", true)) return showVIPMemmbers(playerid);
   if(!strcmp(cmd, "/vip", true))
   {
	  new tmpvip[256], vpfile[128];
	  tmpvip = strtok(cmdtext, idx);
	  #define vcp tmpvip
	  if(!strlen(tmpvip))
	  {
		  SendClientMessage(playerid,white,"--- VIP - ���''�� ---");
		  SendClientMessage(playerid,0x16EB43FF,"[01] � /VIP HQ - ����� ������");
		  SendClientMessage(playerid,0x16EB43FF,"[02] � /VIP [Leave/Quit] - �� ��� ����� �� ������");
		  SendClientMessage(playerid,0x16EB43FF,"[03] � /VIP [Tag/Color] - ����� / ������ �� ���� / ���� ������ �� �������");
		  SendClientMessage(playerid,0x16EB43FF,"[04] � /VIP Info [Details/Stats/Online] - ������ ������");
		  SendClientMessage(playerid,0x16EB43FF,"[05] � /VIP CMDS - VIP ������ ������� ������");
		  SendClientMessage(playerid,0x16EB43FF,"[06] � /VIP Memmbers (/VIPS) :�� ��� ����� �� ����� ���''�� �� ����");
		  SendClientMessage(playerid,orange,"[07] � '$' :�'�� VIP�� ��� ���� �");
		  if(IsPlayerAdmin(playerid))
		  {
		      SendClientMessage(playerid,red,"*[A01] � /VIP Remove [player name] - ������ �����");
		      SendClientMessage(playerid,red,"*[A02] � /VIP Create [player name] - VIP ����� ������ �����");
		      SendClientMessage(playerid,red,"*[A03] � /VIP SetColor [red 1-255] [green 1-255] [blue 1-255] - VIP �� ��� ����� �� ���� �� �");
		      SendClientMessage(playerid,red,"*[A04] � /VIP SetBank - �� ��� ����� �� ������ �� ����");
		      SendClientMessage(playerid,red,"*[A05] � /VIP SetArea [1-2] - ����� �� ������ �� ����� �����, �� ���� �� �� ������");
		  }
		  return 1;
	  }
	  if(_equal(vcp,"setarea") && IsPlayerAdmin(playerid))
	  {
		 new tmpvip2[256], Float:pos[3], i = 0;
		 tmpvip2 = strtok(cmdtext, idx);
		 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		 if(!strlen(tmpvip2)) return SendClientMessage(playerid, white, "Usage: /vip setarea [1-2] (1 = x1 + y1 | 2 = x2 + y2)");
		 if(strval(tmpvip2) < 1 && strval(tmpvip2) > 2) return SendClientMessage(playerid, white, ".���� ����� ����");
		 while(i < 2)
		 {
			 format(string, sizeof string, !i? ("x%i") : ("y%i"), strval(tmpvip2));
			 dini_FloatSet("/VIP/Main.txt", string, !i? pos[0] : pos[1]);
			 i++;
		 }
		 SendClientMessage(playerid, orange,strval(tmpvip2) == 2? ("!������ x2 + y2 ���� �� ��������") : ("!������ x1 + y1 ���� �� ��������"));
		 return 1;
	  }
	  if(_equal(vcp, "create") && IsPlayerAdmin(playerid))
	  {
		  new tmpvip2[256], id = -1;
		  tmpvip2 = strtok(cmdtext, idx);
		  format(string,sizeof string,"/Mode/Users/%s.ini",tmpvip2);
		  format(vpfile, sizeof vpfile,"/VIP/%s.ini", tmpvip2);
		  if(dini_Exists(vpfile)) return error(playerid, ".���� ��� ����� ���");
		  if(!strlen(tmpvip2)) return SendClientMessage(playerid,white,"Usage: /VIP Create [name]");
		  id = GetPlayerID(tmpvip2);
		  dini_IntSet("/VIP/Main.txt", "Total", dini_Int("/VIP/Main.txt", "Total")+1);
		  dini_Create(vpfile);
		  dini_IntSet(vpfile, "Level", 1);
		  dini_IntSet(vpfile, "Color", 0);
		  dini_IntSet(vpfile, "Tag", 1);
		  dini_IntSet(vpfile, "Bank", 0);
		  dini_IntSet(vpfile, "ivc", dini_Int("/VIP/Main.txt", "Total"));
		  format(string, sizeof string,"VIP%i", dini_Int("/VIP/Main.txt", "Total"));
		  dini_Set("/VIP/Main.txt", string, tmpvip2);
		  SendClientMessage(playerid, orange,id != playerid? ("� !VIP - ���� ����� �� ����� ������� �") : ("� !VIP - ����� �� ���� ������� �"));
		  return (id != -1 && !IsPlayerAdmin(id) && id != playerid)? SendClientMessage(id, orange,"/VIP :����� ���� VIP - ������ ���� ���� ������� �") : 1;
	  }
	  if(_equal(vcp, "remove") && IsPlayerAdmin(playerid))
	  {
		  new tmpvip2[256], id = -1;
		  tmpvip2 = strtok(cmdtext, idx);
		  format(string,sizeof string,"/Mode/Users/%s.ini",tmpvip2);
          format(vpfile, sizeof vpfile,"/VIP/%s.ini", tmpvip2);
		  if(!(dini_Exists(string) || dini_Exists(vpfile))) return error(playerid, !dini_Exists(string)? (".�� ���� ����� ��� ���") : (".VIP - ���� �� �� ���"));
		  if(!strlen(tmpvip2)) return SendClientMessage(playerid,white,"Usage: /VIP Remove [name]");
		  id = GetPlayerID(tmpvip2);
		  format(string, sizeof string, "VIP%i", dini_Int(vpfile, "ivc"));
		  dini_Set("/VIP/Main.txt", string, "None");
		  dini_Remove(vpfile);
		  dini_IntSet("/VIP/Main.txt", "Total", dini_Int("/VIP/Main.txt", "Total")-1);
		  SendClientMessage(playerid, orange,id != playerid? ("� !VIP - ����� ������ �� ���� �� ������� �") : ("� !VIP - ����� �� ���� ������� �"));
		  return (id != -1 && !IsPlayerAdmin(id))? SendClientMessage(id, orange,"� Satla-Zone.co.il - �� ��� ������� ������� ��� ����� �� ��� ������ !VIP - ������ ����� ���� ������� �") : 1;
	  }
	  if(_equal(vcp,"setbank") && IsPlayerAdmin(playerid))
	  {
		  new Float:pos[3];
		  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		  for(new i = 0; i < 3; i++)
		  {
			   format(string, sizeof string,"B%i", i+1);
			   dini_FloatSet("/VIP/Main.txt", string, pos[i]);
		  }
		  CPS_RemoveCheckpoint(VIPBank);
		  VIPBank = CPS_AddCheckpoint(dini_Float("/VIP/Main.txt", "B1"),dini_Float("/VIP/Main.txt", "B2"),dini_Float("/VIP/Main.txt", "B3"), 2.5, 20);
		  SendClientMessage(playerid, VIPColor, " � !VIP - ���� �� ������ �� ���� �� ����� �");
		  return 1;
	  }
	  if(_equal(vcp, "setcolor") && IsPlayerAdmin(playerid))
	  {
		  new CC[3][256];
		  for(new d = 0; d < sizeof CC; d++) CC[d] = strtok(cmdtext, idx);
		  if(!strlen(CC[0]) || !strlen(CC[1]) || !strlen(CC[2])) return SendClientMessage(playerid,white,"Usage: /VIP SetColor [red-1-255] [green-1-255] [blue-1-255]");
		  if(!strval(CC[0]) || strval(CC[0]) > 255 || !strval(CC[1]) || strval(CC[1]) > 255 || !strval(CC[2]) || strval(CC[2]) > 255) return SendClientMessage(playerid,white,".��� ���� ���� �� ��� ���� �������� 1-255");
		  for(new i = 0; i < sizeof CC; i++)
		  {
			   format(string, sizeof string, "C%i", i+1);
               dini_IntSet("/VIP/Details.txt", string, strval(CC[i]));
		  }
		  SendClientMessage(playerid, sgba2hex(strval(CC[0]), strval(CC[1]), strval(CC[2]), 200), " � .������ ���� ���� �� ����� �� VIP - ���� �� �");
		  return 1;
      }
      if(_equal(vcp, "color"))
      {
         if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP ���� ���");
         dini_IntSet(VIPFile(playerid),"Color", !dini_Int(VIPFile(playerid),"Color")? 1 : 0);
         SendClientMessage(playerid,VIPColor, dini_Int(VIPFile(playerid),"Color")? (" � !VIP - ����� �� ���� ������ �� ������ �") : (" � !VIP - ���� �� ���� ������ �� ������ �"));
         SetPlayerColor(playerid, dini_Int(VIPFile(playerid),"Color")? VIPColor : sgba2hex(random(256), random(256), random(256), 100));
		 return 1;
	  }
      if(_equal(vcp, "tag"))
      {
         if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP ���� ���");
         dini_IntSet(VIPFile(playerid),"Tag", !dini_Int(VIPFile(playerid),"Tag")? 1 : 0);
         SendClientMessage(playerid,VIPColor, dini_Int(VIPFile(playerid),"Tag")? (" � !VIP - ����� �� ���� ������ �� ������ �") : (" � !VIP - ���� �� ���� ������ �� ������ �"));
		 return 1;
	  }
	  if(_equal(vcp, "info"))
	  {
		 new vtmp[256];
		 vtmp = strtok(cmdtext, idx);
		 if(!strlen(vtmp))
		 {
		     SendClientMessage(playerid,white,"--- VIP - ���''�� ---");
			 SendClientMessage(playerid,0x16EB43FF,"[01] � /VIP Info Details - VIP ���� �� �");
			 SendClientMessage(playerid,0x16EB43FF,"[02] � /VIP Info Stats - VIP ���� �� �");
			 SendClientMessage(playerid,0x16EB43FF,"[03] � /VIP Info Online - ���� ����� ������ �������");
		     return 1;
		 }
		 if(_equal(vtmp,"memmbers")) return showVIPMemmbers(playerid);
		 if(_equal(vtmp, "online"))
		 {
			 new vicount = 0;
			 if(!getOnlineVIP()) return SendClientMessage(playerid, white, !dini_Exists("/VIP/Main.txt") || !dini_Int("/VIP/Main.txt", "Total")? (".������ ���� VIP ��� ����") : (".������� ���� VIP ��� ����"));
			 format(string, sizeof string, "-------- [ %i - ����� ���''�� ������� ] --------", getOnlineVIP());
			 SendClientMessage(playerid, white, string);
			 for(new i = 0; i < MAX_PLAYERS; i++)
			 {
			      if(isPlayerVIP(i) && IsPlayerConnected(i))
			      {
					   vicount++;
					   format(string, sizeof string, " � %i. %s [VIP Level %d | ID: %d]", vicount, GetName(i),dini_Int(VIPFile(i),"Level"), i);
					   SendClientMessage(playerid, i == playerid? red : 0x16EB43FF, string);
			      }
			 }
			 SendClientMessage(playerid, white, "--------------------------------------");
			 return 1;
		 }
		 if(_equal(vtmp, "details"))
		 {
			 SendClientMessage(playerid, white, "-------- [ VIP Details - ���� ���''�� ] --------");
			 format(string, sizeof string, getVIPMemmbers() != 0? (" � .%i ������ VIP ����") : (" � .VIP �� ������ ����"), getVIPMemmbers());
			 SendClientMessage(playerid, getVIPMemmbers() != 0? 0x16EB43FF : red, string);
			 format(string, sizeof string, getOnlineVIP() != 0? (" � .%i ������� ���� VIP ����") : (" � .������� VIP ��� ���� ����"), getOnlineVIP());
			 SendClientMessage(playerid, getOnlineVIP() != 0? 0x16EB43FF : red, string);
   			 format(string, sizeof string, getIntoVIPHQ() != 0? (" � .%i :VIP ���� ������ ��� ������ ������ ����� �") : (" � .VIP - ��� ���� ����� ������ �"), getIntoVIPHQ());
			 SendClientMessage(playerid, getIntoVIPHQ() != 0? 0x16EB43FF : red, string);
			 SendClientMessage(playerid, 0x16EB43FF, " � .10000$ - ������ ���� ��� ������ ���� �� � VIP �� 5 ���� ���� �");
			 SendClientMessage(playerid, !dini_Int("/VIP/Details.txt", "C1") && !dini_Int("/VIP/Details.txt", "C2") && !dini_Int("/VIP/Details.txt", "C3")? red : VIPColor, !dini_Int("/VIP/Details.txt", "C1") && !dini_Int("/VIP/Details.txt", "C2") && !dini_Int("/VIP/Details.txt", "C3")? (" � .VIP - �� ���� ��� ����� ������� �") : (" � .VIP - ��� �� ����� �� ���� ���� �� ������ �"));
			 SendClientMessage(playerid, orange, " � /VIP Info Stats - VIP ��� ����� �� ����� �� ���� �");
			 SendClientMessage(playerid, white, "--------------------------------------");
			 return 1;
		 }
		 if(_equal(vtmp, "stats"))
		 {
			 SendClientMessage(playerid, white, "-------- [ VIP Stats - ����� ���''�� ] --------");
			 format(string, sizeof string," � .%d - ��� �������� VIP ����� �� ������� �� ���� �", dini_Int("/VIP/Stats.txt", "Kills"));
			 SendClientMessage(playerid, 0x16EB43FF, string);
			 format(string, sizeof string," � $%d - VIP - ���� ����� ���� �� �", dini_Int("/VIP/Stats.txt", "Bank"));
			 SendClientMessage(playerid, 0x16EB43FF, string);
   			 format(string, sizeof string,getVIPMemmbers() > dini_Int("/VIP/Stats.txt", "Bank")? (" � ������ �� ����� ���� ���� ���� ����") : (" � $%d - �� �� ���� ������ VIP ��� ���� �������"), dini_Int("/VIP/Stats.txt", "Bank") / getVIPMemmbers());
			 SendClientMessage(playerid, getVIPMemmbers() > dini_Int("/VIP/Stats.txt", "Bank")? red : 0x16EB43FF, string);
			 SendClientMessage(playerid, orange, " � /VIP Info Details - VIP ��� ����� �� ���� �");
			 SendClientMessage(playerid, white, "--------------------------------------");
			 return 1;
		 }
		 return SendClientMessage(playerid,white,".����� VIP �����");
	  }
	  if(_equal(vcp, "hq"))
	  {
		  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP ���� ���");
		  SendClientMessage(playerid,orange,"!VIP - ������ ����� ������ �");
		  return 1;
	  }
	  if(_equal(vcp,"leave") || _equal(vcp,"quit"))
	  {
 		  format(vpfile, sizeof vpfile,"/VIP/%s.ini", GetName(playerid));
		  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP ���� ���");
		  format(string, sizeof string, "VIP%i", dini_Int(vpfile, "ivc"));
		  dini_Set("/VIP/Main.txt", string, "None");
		  dini_Remove(vpfile);
   		  dini_IntSet("/VIP/Main.txt", "Total", dini_Int("/VIP/Main.txt", "Total")-1);
   		  error(playerid,"� !VIP - ���� ������� �");
		  return 1;
	  }
	  if(_equal(vcp, "memmbers"))
	  {
		 showVIPMemmbers(playerid);
 		 return 1;
	  }
      return SendClientMessage(playerid,white,".����� VIP �����");
   }
   return 1;
}
stock clan_Accept(playerid)
{
	 new string[128];
	 if(isPlayerInClan(playerid)) return error(playerid, ".��� ��� ���� �����");
	 if(!isInvited[playerid]) return error(playerid,".�� ������ ���� ����");
	 dini_Create(ClanPlayerFile(playerid));
	 dini_Set(ClanPlayerFile(playerid),"Clan_Name",clanName[playerid]);
	 dini_Set(ClanPlayerFile(playerid),"Last_Withdraw","None");
	 dini_IntSet(ClanPlayerFile(playerid), "Clan_Skin", 1);
	 dini_IntSet(ClanPlayerFile(playerid), "Clan_Chat", 1);
	 dini_IntSet(ClanPlayerFile(playerid), "Clan_Level", 1);
	 dini_IntSet(ClanPlayerFile(playerid), "Clan_Memmber", dini_Int(ClanFile(clanName[playerid]), "Total")+ 1);
     dini_IntSet(ClanPlayerFile(playerid), "Clan_Count", dini_Int(ClanFile(clanName[playerid]), "Clan_Count"));
     dini_IntSet(ClanFile(clanName[playerid]), "Total", dini_Int(ClanFile(clanName[playerid]), "Total")+ 1);
     format(string, sizeof string, "Clan_Player%i",dini_Int(ClanFile(clanName[playerid]), "Total"));
     dini_Set(ClanFile(clanName[playerid]), string, GetName(playerid));
	 format(string, sizeof string," � !%s - ������ ������ ����� ,%s - ���� ��", dini_Get(ClanPlayerFile(playerid),"Clan_Name"), GetName(playerid));
	 SendClientMessage(playerid, orange, string);
	 ShowPlayerDialog(playerid,0,DIALOG_STYLE_MSGBOX,"!������ ������ �����:",string,"�����","���� ����");
	 format(string, sizeof string, " � !����� �����, ��� ��� %s - �����", GetName(playerid));
	 SendClanMessageToAllEx(playerid, orange, string);
	 isInvited[playerid] = 0;
	 return 1;
}
stock clanMemmbers(playerid, tmpclan2[])
{
	new string[128], string2[128], string3[128], b = 0;
	if(!strlen(tmpclan2)) return SendClientMessage(playerid, white, "Usage: /Clan Memmbers [name]");
	if(!dini_Exists(ClanFile(tmpclan2))) return error(playerid,".�� ���� ���� ���");
	format(string3, sizeof string3, " -------- [ Clan(%s) - Memmber(s) %d ] -------- ",tmpclan2, dini_Int(ClanFile(tmpclan2),"Total"));
	SendClientMessage(playerid, white, string3);
	for(new i = 0; i < dini_Int(ClanFile(tmpclan2),"Total") + 2; i++)
	{
		format(string, sizeof string, "Clan_Player%i", i);
		if(strcmp(dini_Get(ClanFile(tmpclan2), string), "None", false))
		{
               format(string2,sizeof string2,"/Clans/Users/%s.ini",dini_Get(ClanFile(tmpclan2), string));
			   format(string3, sizeof string3, GetPlayerID(dini_Get(ClanFile(tmpclan2), string)) == -1? ("%i. %s [Clan Level %i]") : ("%i. %s [Clan Level %i | ID: %i]"), b + 1, dini_Get(ClanFile(tmpclan2), string), dini_Int(string2, "Clan_Level"), GetPlayerID(dini_Get(ClanFile(tmpclan2), string)));
			   SendClientMessage(playerid, GetPlayerID(dini_Get(ClanFile(tmpclan2), string)) == -1? red : 0x16EB43FF, string3);
			   b++;
		}
	}
	format(string, sizeof string, " � ./Clan Info [Stats/Details] %s - ���� ���� �� �����", tmpclan2);
	SendClientMessage(playerid, orange, string);
	SendClientMessage(playerid, white, " -------------------------------------- ");
	return 1;
}
stock LoadHQObjects(fname[], aLoad, cowner[])
{
    new HQ_Objectcount = 0;
	if(fexist(fname))
	{
	    HQ_Countobjects(fname, HQ_Objectcount);
		new xreaded[12][256], entry[256], File: hqfile = fopen(fname, io_read);
	    if (hqfile)
		{
		    for(new i = 0; i < HQ_Objectcount; i++)
			{
				 fread(hqfile, entry);
				 _split(entry, xreaded, ',');
				 if(aLoad == 0) CreateStreamObject(strval(xreaded[0]), floatstr(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), floatstr(xreaded[5]),  floatstr(xreaded[6]), strval(xreaded[7]));
				 if(aLoad == 1) clanVehicles[HQ_Vehicles++] = AddStaticVehicle(strval(xreaded[0]), floatstr(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), strval(xreaded[5]), strval(xreaded[6]));
				 if(aLoad == 2) CreatePickup(strval(xreaded[0]),strval(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]));
				 if(aLoad == 3)
				 {
                      HQ_MoveObject += 1;
				      GateInfo[HQ_MoveObject][gid] = CreateStreamObject(strval(xreaded[0]), floatstr(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), floatstr(xreaded[5]),  floatstr(xreaded[6]), strval(xreaded[7]));
				      GateInfo[HQ_MoveObject][xn] = floatstr(xreaded[1]);
				      GateInfo[HQ_MoveObject][yn] = floatstr(xreaded[2]);
				      GateInfo[HQ_MoveObject][zn] = floatstr(xreaded[3]);
					  GateInfo[HQ_MoveObject][xun] = floatstr(xreaded[8]);
				      GateInfo[HQ_MoveObject][yun] = floatstr(xreaded[9]);
					  GateInfo[HQ_MoveObject][zun] = floatstr(xreaded[10]);
					  GateInfo[HQ_MoveObject][speed] = !strlen(xreaded[11])? 3 : strval(xreaded[11]);
					  strmid(GateInfo[HQ_MoveObject][owner], cowner, 0, strlen(cowner));
					  GateInfo[HQ_MoveObject][gstate] = false;
					  printf("( ( %i ) )", HQ_MoveObject);
				 }
			}
			fclose(hqfile);
		}
	}
}
stock HQ_Countobjects(fname[], &a01)
{
    new entry[256];
	new File: hqfile = fopen(fname, io_read);
	while(fread(hqfile, entry, 256)) a01++;
  	fclose(hqfile);
}
stock setPlayerClanColor(playerid) return SetPlayerColor(playerid, sgba2hex(dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "C1"),dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "C2"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "C2"), 100));
stock getMoveObjectNearPlayer(playerid)
{
	for(new i = 0; i < MAX_MOVE_GATES; i++)
	{
		 if(PlayerToPoint(playerid, 15.0, GateInfo[i][xn], GateInfo[i][yn], GateInfo[i][zn]))
		 {
             pGateInfo[playerid][gid] = i;
             strmid(pGateInfo[playerid][owner], GateInfo[i][owner], 0, strlen(GateInfo[i][owner]));
             printf("%i", i);
             break;
		 }
	}
	return 1;
}
stock setGateLoctions(x, bool:mgstate)
{
   if(!mgstate) MoveStreamObject(GateInfo[x][gid], GateInfo[x][xn], GateInfo[x][yn], GateInfo[x][zn], GateInfo[x][speed]);
   else	MoveStreamObject(GateInfo[x][gid], GateInfo[x][xun], GateInfo[x][yun], GateInfo[x][zun], GateInfo[x][speed]);
   GateInfo[x][gstate] = mgstate;
   return 1;
}
stock showVIPMemmbers(playerid)
{
	new vvip[128], vpfile[128], string[128];
	if(!getVIPMemmbers()) return SendClientMessage(playerid, white,".VIP �� ������ �����");
	format(string,sizeof string,"------- [ %d :����� ���''�� ������ ] -------",getVIPMemmbers());
	SendClientMessage(playerid, white, string);
	for(new i = 0; i < dini_Int("/VIP/Main.txt", "Total")+2; i++)
	{
		  format(vpfile,sizeof vpfile,"VIP%i", i);
		  if(dini_Isset("/VIP/Main.txt", vpfile) && strcmp(dini_Get("/VIP/Main.txt", vpfile), "None", true))
		  {
		       format(vvip, sizeof vvip,"/VIP/%s.ini", dini_Get("/VIP/Main.txt", vpfile));
		       format(string, sizeof string,GetPlayerID(dini_Get("/VIP/Main.txt", vpfile)) == INVALID_PLAYER_ID? (" � %s [VIP Level: %d]"): (" � %s [VIP Level: %d | ID: %d]"), dini_Get("/VIP/Main.txt", vpfile), dini_Int(vvip,"Level"), GetPlayerID(dini_Get("/VIP/Main.txt", vpfile)));
		       SendClientMessage(playerid,GetPlayerID(dini_Get("/VIP/Main.txt", vpfile)) == INVALID_PLAYER_ID? red : 0x16EB43FF, string);
		  }
		  else continue;
	}
	SendClientMessage(playerid, white, "--------------------------------------");
	return 1;
}
stock createTeleport(playerid, interior, Float:x, Float:y, Float:z, Float:a, withvehicle, level, message[])
{
   new string[128];
   if(getPlayerLevel(playerid) < level)
   {
      format(string, sizeof string, "����� �� ���� ������ ���� %i ����!", level);
      error(playerid, string);
      return 1;
   }
   if(IsPlayerInAnyVehicle(playerid) && withvehicle)
   {
	   SetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
	   SetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	   LinkVehicleToInterior(GetPlayerVehicleID(playerid), interior);
   }
   else
   {
	   SetPlayerInterior(playerid,interior);
	   SetPlayerPos(playerid, x, y, z);
	   SetPlayerFacingAngle(playerid, a);
   }
   format(string, sizeof string, "!���� ,\"%s\" - ������ ����� ������ �", message);
   SendClientMessage(playerid, orange, string);
   format(string, sizeof string, "%s~y~~h~-[] ~g~~h~� ~r~~h~Welcome To~w~: ~b~~h~(%s) ~g~~h~�~y~~h~[] -", ("~n~~n~~n~~n~~n~"), message);
   GameTextForAll(string,5*1000, 3);
   return 1;
}
/*
stock showTeleports(playerid)
{
   new string[128], file[4][128];
   if !dini_Int(teleports_insetsfile, "Total") *then return error(playerid, ".��� ������� ���� ����");
   format(string, sizeof string, "-------- [ Teleports - (%i) - ������� ] --------", dini_Int(teleports_insetsfile, "Total"));
   SendClientMessage(playerid, white, string);
   for(new t = 0; t < dini_Int(teleports_insetsfile, "Total") + 1; t++)
   {
        format(file[0], 128, "tele%i", t);
        format(file[1], 128, "tele%i", t+1);
	    format(file[2], 128, "/Insets/Teleports/%s.ini", dini_Get(teleports_insetsfile, file[0]));
	    format(file[3], 128, "/Insets/Teleports/%s.ini", dini_Get(teleports_insetsfile, file[1]));
        if(dini_Isset(teleports_insetsfile, file[0]))
        {
            format(string, sizeof string, dini_Isset(teleports_insetsfile, file[0]) && !dini_Isset(teleports_insetsfile, file[1])? (" � %s (Level: %i | Info: %s )") : (" � %s (Level: %i | Info: %s ), %s (Level: %i | Info: %s )"), dini_Get(teleports_insetsfile, file[0]), dini_Int(file[2], "level"), dini_Get(file[2], "info"), dini_Get(teleports_insetsfile, file[1]), dini_Int(file[3], "level"), dini_Get(file[3], "info"));
		    SendClientMessage(playerid, orange, string);
		    if(dini_Isset(teleports_insetsfile, file[1])) t++;
        }
   }
   SendClientMessage(playerid, white, "--------------------------------------------------");
   return 1;
}*/
stock LoadTeleportsList()
{
	new File:fp, count = 0, tele_word[MAX_STRING];
	if (!fexist(teleports_lists))
	{
		fp = fopen(teleports_lists,io_write);
		fclose(fp);
	}
	fp = fopen(teleports_lists,io_read);
	while (fread(fp,tele_word,sizeof tele_word))
	{
	    tele_words[count] = tele_word;
		tele_words[count][strlen(tele_words[count])-1] = 0;
		count++;
		if (count == 100) break;
	}
	tele_words[count] = "*EOF*";
	fclose(fp);
}
stock SaveTeleportsList()
{
	new File:fp;
	fp = fopen(teleports_lists,io_write);
	for (new i = 0; i < 100; i++)
	{
	    if (!strcmp(tele_words[i],"*EOF*",true)) continue;
	    fwrite(fp,tele_words[i]);
	    fwrite(fp,"\n");
 	}
	fclose(fp);
}
// Users :
UseCallback(int, playerid, isnpc, _state)
{
   new Float:pos[3], string[128];
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
   if(!PlayerInfo(logged[playerid]) || PlayerInfo(logged[playerid]) == 2)
   {
      format(string, sizeof string, _state? ("/login :��� ���� ������ ���� ����� ����� �� ,%s") : ("/register :��� ���� ������ ���� ����� ����� �� ,%s"), GetName(playerid));
      if(PlayerInfo(logged[playerid]) != 2) error(playerid, string);
      return 0;
   }
   return 1;
}
UseCallback(OnPlayerJoin, playerid, name[], ip[], state_, autologin, isnpc)
{
   new string[128], color = random(2) == 1? darkblue : pink;
   Clean(playerid);
   format(string, sizeof string, _fileconfig "%s", ip);
   if(dini_Exists(string))
   {
	  format(string, sizeof string, _fileconfig "%s.ini", GetIP(playerid));
	  format(string, sizeof string, " (%s) ", ip);
	  error(playerid, string);
	  format(string, sizeof string, ".����� � - 15 ���� ����� ��� ������ �����, ��� ��� ������ ���� %i ���� IP - ������", PlayerInfo(mints[dini_Int(string, "id")]));
	  error(playerid, string);
	  halt(2);
	  Kick(playerid);
	  return 1;
   }
   format(string, sizeof string," � (Your IP's: %s | ID's: #%03d) " forum " - Ultra DeathMatch - ���� ��, ������� ����� ���� �", ip, playerid);
   SendClientMessage(playerid, orange, string);
   SendClientMessage(playerid, black, "___________________________________________________________");
   if(!autologin)
   {
       format(string, sizeof string, state_? (".�� ��� ������ ���� ���� ������ ,%s ���� ��") : (".�� ��� ������ ���� ���� ������ ,%s ���� ��"), GetName(playerid));
       SendClientMessage(playerid, color, string);
       SendClientMessage(playerid, color, state_? (" (�� ����� ������) � /Login [Password] - �������� ���/�") : (" (�� ����� ������) � /Register - ������ ���/�"));
   }
   else if(autologin && !strcmp(ip, dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connect_IP"), false))
   {
       format(string, sizeof string, "(%s) .��� IP - ������ �������� �\"� ����� � ,%s ���� ��", ip, GetName(playerid));
       SendClientMessage(playerid, color, string);
	   _Callback(login, playerid, dini_Get(getPlayerFile(playerid, _fileusers), "Password"));
   }
   SendClientMessage(playerid, color, forum " - ���� ����� ���� ����� ������ ���� �������� �����");
   SendClientMessage(playerid, black, "___________________________________________________________");
   SendClientMessage(playerid, color == darkblue? brown : darkblue," � /HelpMe - �� ��� ���� ���� �������� ���� � /Help - ����� ����� ����");
   if(state_ && !PlayerInfo(logged[playerid])) ShowPlayerDialog(playerid,5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
   if(!state_ && !PlayerInfo(logged[playerid])) ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ������ ������ ����� ������", "����", "�����");
   if(isnpc) PlayerInfo(logged[playerid] = true);
   PlayerInfo(worngPassword[playerid]) = MAX_WORNGS_LOGIN;
   PlayerInfo(isafk[playerid]) = false;
   return 1;
}
function(unTempban(ip[], id))
{
   new string[128];
   PlayerInfo(mints[id])--;
   if(PlayerInfo(mints[id]) >= 1) SetTimerEx("unTempban", 1*60*1000, false, "s", ip, id);
   if(dini_Isset(_fileconfig "BIP.ini", ip) && !PlayerInfo(mints[id]))
   {
       dini_IntSet(_fileconfig "BIP.ini", ip, 0);
	   dini_IntSet(_fileconfig "BIP.ini", "Total", dini_Int(_fileconfig "BIP.ini", "Total") - 1);
	   format(string, sizeof string, _fileconfig "%s", ip);
	   dini_Remove(string);
	   PlayerInfo(mints[id]) = 0;
   }
   return 1;
}
UseCallback(login, playerid, password[])
{
   new string[128];
   if(!strlen(password))
   {
      format(string, sizeof string, " !��� ��� ����� - %s", GetName(playerid));
	  ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
	  error(playerid, string);
	  return 1;
   }
   if(strcmp(password, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true))
   {
	  format(string, sizeof string, "%s You have %02d more %s to login.", GetName(playerid), PlayerInfo(worngPassword[playerid]), PlayerInfo(worngPassword[playerid]) > 1? ("attempts") : ("attempt"));
	  error(playerid, string);
	  PlayerInfo(worngPassword[playerid])--;
	  if(PlayerInfo(worngPassword[playerid]) != 0) ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
	  if(!PlayerInfo(worngPassword[playerid]))
	  {
		  error(playerid, ".�� ���� ������ � - 15 ���� ����� ���� ���� ����� ������ 5 �����");
		  dini_IntSet(_fileconfig "BIP.ini", GetIP(playerid), 1);
		  dini_IntSet(_fileconfig "BIP.ini", "Total", dini_Int(_fileconfig "BIP.ini", "Total") + 1);
		  PlayerInfo(mints[dini_Int(_fileconfig "BIP.ini", "Total")]) = 15;
		  SetTimerEx("unTempban", 1*60*1000, false, "s", GetIP(playerid), dini_Int(_fileconfig "BIP.ini", "Total"));
		  format(string, sizeof string, _fileconfig "%s.ini", GetIP(playerid));
		  dini_Create(string);
		  dini_IntSet(string, "id", dini_Int(_fileconfig "BIP.ini", "Total"));
		  halt(3);
		  Kick(playerid);
	  }
      return 1;
   }
   SendHeader(playerid, "Logged Complete - ������ �����");
   format(string, sizeof string, " � %s :������ �������� ��� - %s ����", GetTimeAsString(':', 1), GetDateAsString('/', 1));
   SendClientMessage(playerid, darkblue, string);
   format(string, sizeof string, " � %s :������ ������ ��� ����� ������� - %s ����", dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Time"), dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Date"));
   SendClientMessage(playerid, darkblue, string);
   format(string, sizeof string, " � %i - ���� ����� ��� �������� ������� ���", DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Date"), GetDateAsString('/', 1)));
   if(DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Date"), GetDateAsString('/', 1)) >= 1) SendClientMessage(playerid, yellow, string);
   format(string, sizeof string, " � Last Connect IP: %s � Currently IP: %s � Automatic Login By IP: %s", dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_IP"), GetIP(playerid), dini_Int(getPlayerFile(playerid, _fileusers), "autologin")? ("YES") : ("NO"));
   SendClientMessage(playerid, yellow, string);
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Date", GetDateAsString('/', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Time", GetTimeAsString(':', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_IP", GetIP(playerid));
   ShowPlayerDialog(playerid,100,DIALOG_STYLE_MSGBOX,"   !�������� �����", "/HelpMe :����� ���� ���� �������\n/Help - ����� ����\n\n!������ ����� WDM.co.il - ������ ������ �","�����","���� ����");
   PlayerInfo(logged[playerid]) = 2;
   SetTimerEx("_mints", 60*1000, false, "i", playerid);
   SetTimerEx("showStats", 7000, false, "iii", playerid, playerid, 1);
   return 1;
}
UseCallback(register, playerid, password[], ip[])
{
   new string[128], File:f;
   if(!strlen(password))
   {
      format(string, sizeof string, " !��� ��� ����� - %s", GetName(playerid));
	  ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ������ ������ ����� ������", "����", "�����");
	  error(playerid, string);
	  return 1;
   }
   if(isSimplePassword(password))
   {
      ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ������ ������ ����� ������", "����", "�����");
      error(playerid, "   !����� ����� ���, ��� ��� ����� ����");
	  return 1;
   }
   if(dini_Exists(getPlayerFile(playerid, _fileusers))) return ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
   if(!dini_Exists(getPlayerFile(playerid, _fileusers))) dini_Create(getPlayerFile(playerid, _fileusers));
   dini_IntSet(_fileconfig "Main.ini", "Total", dini_Int(_fileconfig "Main.ini", "Total") + 1);
   format(string, sizeof string, "Player%09d=%s\n\r", dini_Int(_fileconfig "Main.ini", "Total"), GetName(playerid));
   f = fopen(_fileconfig "Main.ini", io_append);
   fwrite(f, string);
   fclose(f);
   dini_Set(getPlayerFile(playerid, _fileusers), "Registered_IP", ip);
   dini_Set(getPlayerFile(playerid, _fileusers), "Registered_Date", GetDateAsString('/', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Registered_Time", GetTimeAsString(':', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Registered_Password", password);
   dini_Set(getPlayerFile(playerid, _fileusers), "Registered_Name", GetName(playerid));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Date", GetDateAsString('/', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Time", GetTimeAsString(':', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_IP", ip);
   dini_Set(getPlayerFile(playerid, _fileusers), "Password", password);
   dini_IntSet(getPlayerFile(playerid, _fileusers), "Userid", dini_Int(_fileconfig "Main.ini", "Total"));
   dini_IntSet(getPlayerFile(playerid, _fileusers), "autologin", 1);
   _Callback(createStatics, playerid);
   SendHeader(playerid, "Registered Complete - ������ �����");
   format(string, sizeof string, " � >> \"%s\" - �����", password);
   SendClientMessage(playerid, lightblue, string);
   format(string, sizeof string, " � >> \"%s\" - �� �����", GetName(playerid));
   SendClientMessage(playerid, lightblue, string);
   format(string, sizeof string, " � >> \"%09d\" - ����� ������� ���", dini_Int(_fileconfig "Main.ini", "Total"));
   SendClientMessage(playerid, lightblue, string);
   SendClientMessage(playerid, yellow, " � /editprofile - �� ��� ����� �� ������� ���");
   SendClientMessage(playerid, yellow, " � /setting - �� ��� ����� ������� ������� ���");
   SendClientMessage(playerid, yellow, " � /stats - �� ��� ����� ������� ���");
   SendClientMessage(playerid, darkblue, " � GameMode Version: " version " � Ventrilo IP: " ventrilo " � Last Update: " lastupdate);
   SetTimerEx("_mints", 60*1000, false, "i", playerid);
   return 1;
}
UseCallback(createStatics, playerid)
{
   if(!dini_Exists(getPlayerFile(playerid, _filestats))) dini_Create(getPlayerFile(playerid, _filestats));
   dini_IntSet(getPlayerFile(playerid, _filestats), "Level", 1);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Kills", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Deaths", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Respect", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Bonus", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Points", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Hours", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Mints", 0);
   dini_IntSet(getPlayerFile(playerid, _filestats), "SHours", 0);
   dini_FloatSet(getPlayerFile(playerid, _filestats), "Seniority", 0.0);
   dini_Set(getPlayerFile(playerid, _filestats), "Tag", "Begginer(Noob)");
   return 1;
}
function(_mints(playerid))
{
   dini_IntSet(getPlayerFile(playerid, _filestats), "Mints", dini_Int(getPlayerFile(playerid, _filestats), "Mints") + 1);
   if(dini_Int(getPlayerFile(playerid, _filestats), "Mints") > 59)
   {
       dini_IntSet(getPlayerFile(playerid, _filestats), "Mints", 0);
       dini_IntSet(getPlayerFile(playerid, _filestats), "Hours", dini_Int(getPlayerFile(playerid, _filestats), "Hours") + 1);
       dini_IntSet(getPlayerFile(playerid, _filestats), "SHours", dini_Int(getPlayerFile(playerid, _filestats), "SHours") + 1);
	   if(dini_Int(getPlayerFile(playerid, _filestats), "SHours") >= 2 && dini_Float(getPlayerFile(playerid, _filestats), "Seniority") <= 100.0)
	   {
          dini_FloatSet(getPlayerFile(playerid, _filestats), "Seniority", dini_Float(getPlayerFile(playerid, _filestats), "Seniority") + 1.0);
		  if(dini_Float(getPlayerFile(playerid, _filestats), "Seniority") > 100) dini_FloatSet(getPlayerFile(playerid, _filestats), "Seniority", 100);
		  dini_IntSet(getPlayerFile(playerid, _filestats), "SHours", 0);
	   }
   }
   if(PlayerInfo(logged[playerid]) && !PlayerInfo(isafk[playerid])) SetTimerEx("_mints", 60*1000, false, "i", playerid);
   return 1;
}
function(AFK(playerid, Float:x, Float:y, Float:z))
{
   new Float:pos[3];
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   if(x == pos[0] && y == pos[1] && z == pos[2] && !PlayerInfo(isafk[playerid]) && PlayerInfo(logged[playerid])) return setAFK(playerid, true);
   SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
   return 1;
}
function(showStats(playerid, id, action))
{
   new string[128], string2[128], _id[4], Float:z, Float:_vhealth, Float:_health, Float:_armour, color = id == playerid? pink : grey;
   if(action)
   {
       for(new i = 0; i < 5; i++) SendClientMessage(playerid, white, "\n");
	   PlayerInfo(logged[playerid] = true);
   }
   GetPlayerHealth(id, _health);
   GetPlayerArmour(id, _armour);
   GetPlayerPos(id, vspeed[playerid][0], vspeed[playerid][1], z);
   GetVehicleHealth(IsPlayerInAnyVehicle(id)? GetPlayerVehicleID(id) : 2, _vhealth);
   format(_id, sizeof _id, id != playerid? ("%i") : (""), id);
   if(IsPlayerInAnyVehicle(playerid)) format(string2, 128, "YES(Type: %s | Health: %.1f%s | Speed: %.1f%s)", VehiclesName[GetVehicleModel(GetPlayerVehicleID(id))-400], _vhealth, "%%", GetPlayerSpeed(id, vspeed[id][0], vspeed[id][1]), "%%");
   format(string, sizeof string, playerid == id? ("  ~~~ You're Statics - %s(%03i | %09d): ~~~") : ("  ~~~ %s(%03i | %09d) - Statics: ~~~"), GetName(id), id, dini_Int(getPlayerFile(id, _fileusers), "Userid"));
   SendClientMessage(playerid, lightblue, string);
   format(string, sizeof string, "  [%s] � %03i - ���", dini_Get(getPlayerFile(id, _filestats), "Tag"), dini_Int(getPlayerFile(id, _filestats), "Level"));
   SendClientMessage(playerid, id == playerid? grey : pink, string);
   format(string, sizeof string, "  ������ ����: %i � ������ �����: %i � ��� ����: %i � ������: %i � �����: %i", dini_Int(getPlayerFile(id, _filestats), "Points"), dini_Int(getPlayerFile(id, _filestats), "Bonus"), dini_Int(getPlayerFile(id, _filestats), "Respect"), dini_Int(getPlayerFile(id, _filestats), "Kills"), dini_Int(getPlayerFile(id, _filestats), "Deaths"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, dini_Exists(ClanPlayerFile(playerid))? ("  ��� ����: %s � (/clan info [details/stats] %s) %s :����") : ("  ��� ����: %s � %s :����"), isPlayerVIP(playerid)? ("��") : ("��"), dini_Exists(ClanPlayerFile(id))? dini_Get(ClanPlayerFile(id), "Clan_Name") : ("None"), dini_Get(ClanPlayerFile(id), "Clan_Name"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, "  ����: %.1f%s � ���: %.1f%s � %s :����", _health, "%%", _armour, "%%", IsPlayerInAnyVehicle(playerid)? string2 : ("NO"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, "  %s %s :�����", dini_Int(WeaponFile(id), "Total") > 0? ("None") : ("/weapons"), _id);
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, "  ���� ����� ��� ������: %i � ���� ����: %03i(%02i) � ����� ����: %.1f%s", DaysBetweenDates(dini_Get(getPlayerFile(id, _fileusers), "Registered_Date"), GetDateAsString('/', 1)), dini_Int(getPlayerFile(id, _filestats), "Hours"), dini_Int(getPlayerFile(id, _filestats), "Mints"), dini_Float(getPlayerFile(id, _filestats), "Seniority"), "%%");
   SendClientMessage(playerid, color, string);
   SendClientMessage(playerid, lightblue, "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
   return 1;
}
stock setAFK(playerid, bool:s = true)
{
   new Float:pos[3];
   if(!s)
   {
	   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
       SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
   	   SendClientMessage(playerid, darkblue, "!Away From Keyboard(AFK) - ����� �������� ����");
   	   SetTimerEx("_mints", 60*1000, false, "i", playerid);
   }
   else SendClientMessage(playerid, darkblue, "!Away From Keyboard(AFK) - ����� �������� ����");
   PlayerInfo(isafk[playerid]) = s;
   TogglePlayerControllable(playerid, s == true? false : true);
   return 1;
}
stock isSimplePassword(text[])
{
   for(new i = 0; i < sizeof simplePassword; i++) if(!strcmp(simplePassword[i], text, true)) return 1;
   return 0;
}
stock modeLine(playerid, text[], line=1)
{
   new string[128];
   format(string, sizeof string, "� [%i] %s", line, text);
   SendClientMessage(playerid, white, string);
   return 1;
}
stock featureModeIn(playerid, caption[], cline[]="None", cinfo[]="None", line1[]="None", line2[]="None", line3[]="None", line4[]="None", line5[]="None", line6[]="None", line7[]="None", line8[]="None")
{
   new string[128];
   SendClientMessage(playerid, white, "\n");
   format(string, sizeof string, " ~~~~~ FM(%s) - ������� ���� ~~~~~", caption);
   SendClientMessage(playerid, darkblue, string);
   if(strcmp(line1, "None", false)) SendClientMessage(playerid, pink, line1);
   if(strcmp(line2, "None", false)) SendClientMessage(playerid, pink, line2);
   if(strcmp(line3, "None", false)) SendClientMessage(playerid, pink, line3);
   if(strcmp(line4, "None", false)) SendClientMessage(playerid, pink, line4);
   if(strcmp(line5, "None", false)) SendClientMessage(playerid, pink, line5);
   if(strcmp(line6, "None", false)) SendClientMessage(playerid, pink, line6);
   if(strcmp(line7, "None", false)) SendClientMessage(playerid, pink, line7);
   if(strcmp(line8, "None", false)) SendClientMessage(playerid, pink, line8);
   if(strcmp(cline, "None", false)) SendClientMessage(playerid, 0x46bbaa00, cline);
   if(strcmp(cinfo, "None", false)) SendClientMessage(playerid, 0x999900aa, cinfo);
   SendClientMessage(playerid, darkblue, "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
   SendClientMessage(playerid, white, "\n");
   return 1;
}
stock equal_Mode(_cmd[], _cmd2[], _cmd3[], count=1) return !strcmp(_cmd, _cmd2, true) || !strcmp(_cmd, _cmd3, true) || strval(_cmd) == count;
