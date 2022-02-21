//=[Includes & Defines]===========================================================
#include "../DeathMatch/acf.pwn"

pi.private PlayerInfo(bool:logged[MAX_PLAYERS] = {false, ...}),
    PlayerInfo(worngPassword[MAX_PLAYERS] = {4, ...}),
	PlayerInfo(bool:isafk[MAX_PLAYERS]),
	PlayerInfo(mints[MAX_PLAYERS]);


function(OnPlayerConnect(playerid)) return _Callback(OnPlayerJoin, playerid, GetName(playerid), GetIP(playerid), dini_Exists(getPlayerFile(playerid, _fileusers)), dini_Int(getPlayerFile(playerid, _fileusers), "autologin"), IsPlayerNPC(playerid)? 1 : 0);
function(OnPlayerRequestSpawn(playerid)) return _Callback(int, playerid, IsPlayerNPC(playerid), dini_Exists(getPlayerFile(playerid, _fileusers)));
function(OnFilterScriptInit())
{
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
   return 1;
}
function(OnPlayerCommandText(playerid, cmdtext[]))
{
   new cmd[256], idx;
   cmd = strtok(cmdtext, idx);
   if(!strcmp(cmd, "/login", true))
   {
	  if(PlayerInfo(logged[playerid])) return SendClientMessage(playerid, red, ".��� ��� �����");
	  if(!dini_Exists(getPlayerFile(playerid, _fileusers))) return SendClientMessage(playerid, red, "/register :��� �� ���� ��� �����");
      ShowPlayerDialog(playerid,5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/register", true))
   {
	  if(dini_Exists(getPlayerFile(playerid, _fileusers))) return SendClientMessage(playerid, red, "/login :��� ��� ����, ��� �����");
	  ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ������ ������ ����� ������", "����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/stats", true))
   {
	  cmd = strtok(cmdtext, idx);
	  showStats(playerid, !strlen(cmd)? playerid : strval(cmd));
 	  return 1;
   }
   adminCommand(cmd, "/tag")
   {
	  new file[32], cmd2[256];
	  cmd = strtok(cmdtext, idx);
	  if(!strlen(cmd)) return SendClientMessage(playerid, white, "Usage: /tag [set/remove]");
	  if(_equal(cmd, "set"))
	  {
		  cmd = strtok(cmdtext, idx);
		  cmd2 = strtok_line(cmdtext, idx);
		  format(file, sizeof file, "%s", cmd);
		  if(!strlen(cmd) || !strlen(cmd2)) return SendClientMessage(playerid, white, "Usage: /tag set [name] [dest]");
		  dini_Set(_fileconfig "Tags.ini", file, cmd2);
		  SendClientMessage(playerid, orange, ".����� ����� �� �� ���� ������");
		  return 1;
	  }
	  if(_equal(cmd, "remove"))
	  {
          cmd = strtok(cmdtext, idx);
		  format(file, sizeof file, "%s", cmd);
		  if(!dini_Isset(_fileconfig "Tags.ini", file)) return SendClientMessage(playerid, red, ".����� �� ��� ���");
		  dini_Set(_fileconfig "Tags.ini", file, "None");
		  SendClientMessage(playerid, orange, ".���� ����� �� �� ���� ������");
		  return 1;
	  }
	  return SendClientMessage(playerid, red, ".����� �����");
   }
/*   if(!strcmp(cmd, "/players", true))
   {
       new fr[64], string[1024], players = 0;
       cmd = " ", string = " ";
       for(new i = 0; i <= 200 + 1; i++)
       {
		   format(fr, sizeof fr, "Player%06d", i);
		   if(dini_Isset(_fileconfig "Main.ini", fr))
		   {
              format(cmd, sizeof cmd, " � %s(%i)\n", dini_Get(_fileconfig "Main.ini", fr), ++players);
		      strcat(string, cmd);
		   }
       }
       ShowPlayerDialog(playerid, 200, 2, "Players List", string, "OK", "Close");
       return 1;
   }*/
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
	  SendClientMessage(playerid, red, string);
	  format(string, sizeof string, ".����� � - 15 ���� ����� ��� ������ �����, ��� ��� ������ ���� %i ���� IP - ������", PlayerInfo(mints[dini_Int(string, "id")]));
	  SendClientMessage(playerid, red, string);
      SetTimerEx("Kick_", 2000, false, "i", playerid);
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
   if(strcmp(password, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true))
   {
	  format(string, sizeof string, "%s You have %02d more %s to login.", GetName(playerid), PlayerInfo(worngPassword[playerid]), PlayerInfo(worngPassword[playerid]) > 1? ("attempts") : ("attempt"));
	  SendClientMessage(playerid, red, string);
	  PlayerInfo(worngPassword[playerid])--;
	  if(PlayerInfo(worngPassword[playerid]) != 0) ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
	  if(!PlayerInfo(worngPassword[playerid]))
	  {
		  SendClientMessage(playerid, red, ".�� ���� ������ � - 15 ���� ����� ���� ���� ����� ������ 5 �����");
		  dini_IntSet(_fileconfig "BIP.ini", GetIP(playerid), 1);
		  dini_IntSet(_fileconfig "BIP.ini", "Total", dini_Int(_fileconfig "BIP.ini", "Total") + 1);
		  PlayerInfo(mints[dini_Int(_fileconfig "BIP.ini", "Total")]) = 15;
		  SetTimerEx("unTempban", 1*60*1000, false, "s", GetIP(playerid), dini_Int(_fileconfig "BIP.ini", "Total"));
		  format(string, sizeof string, _fileconfig "%s.ini", GetIP(playerid));
		  dini_Create(string);
		  dini_IntSet(string, "id", dini_Int(_fileconfig "BIP.ini", "Total"));
		  SetTimerEx("Kick_", 2000, false, "i", playerid);
	  }
      return 1;
   }
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Date", GetDateAsString('/', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Time", GetTimeAsString(':', 1));
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_IP", GetIP(playerid));
   PlayerInfo(logged[playerid] = true);
   ShowPlayerDialog(playerid,100,DIALOG_STYLE_MSGBOX,"   !�������� �����", "/HelpMe :����� ���� ���� �������\n/Help - ����� ����\n\n!������ ����� WDM.co.il - ������ ������ �","�����","���� ����");
   SetTimerEx("_mints", 60*1000, false, "i", playerid);
   return 1;
}
UseCallback(register, playerid, password[], ip[])
{
   new string[128], File:f;
   if(!strlen(password))
   {
      format(string, sizeof string, " !��� ��� ����� - %s", GetName(playerid));
      ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, string," � ���� ��, ��� ���/� �� ������ ��� �� ��� ������ ������� ����", "�����", "�����");
      SendClientMessage(playerid, red, string);
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
   _Callback(createState, playerid);
   SendHeader(playerid, "Registered Complete - ������ �����");
   format(string, sizeof string, " � >> \"%s\" - �����", password);
   SendClientMessage(playerid, brown, string);
   format(string, sizeof string, " � >> \"%s\" - �� �����", GetName(playerid));
   SendClientMessage(playerid, brown, string);
   format(string, sizeof string, " � >> \"%09d\" - ����� ������� ���", dini_Int(_fileconfig "Main.ini", "Total"));
   SendClientMessage(playerid, brown, string);
   SendClientMessage(playerid, yellow, " � /editprofile - �� ��� ����� �� ������� ���");
   SendClientMessage(playerid, yellow, " � /setting - �� ��� ����� ������� ������� ���");
   SendClientMessage(playerid, yellow, " � /stats - �� ��� ����� ������� ���");
   SendClientMessage(playerid, darkblue, " � GameMode Version: " version " � Ventrilo IP: " ventrilo " � Last Update: " lastupdate);
   SetTimerEx("_mints", 60*1000, false, "i", playerid);
   return 1;
}
UseCallback(createState, playerid)
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
   dini_Set(getPlayerFile(playerid, _filestats), "Tag", "Noob");
   return 1;
}
function(_mints(playerid))
{
   dini_IntSet(getPlayerFile(playerid, _filestats), "Mints", dini_Int(getPlayerFile(playerid, _filestats), "Mints") + 1);
   if(dini_Int(getPlayerFile(playerid, _filestats), "Mints") > 59)
   {
      dini_IntSet(getPlayerFile(playerid, _filestats), "Mints", 0);
      dini_IntSet(getPlayerFile(playerid, _filestats), "Hours", dini_Int(getPlayerFile(playerid, _filestats), "Hours") + 1);
   }
   if(PlayerInfo(logged[playerid]) && !PlayerInfo(isafk[playerid])) SetTimerEx("_mints", 60*1000, false, "i", playerid);
   return 1;
}
function(AFK(playerid, Float:x, Float:y, Float:z))
{
   new Float:pos[3];
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   if(x == pos[0] && y == pos[1] && z == pos[2] && !PlayerInfo(isafk[playerid]) && PlayerInfo(logged[playerid]) == true) return setAFK(playerid, true);
   SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
   return 1;
}
function(showStats(playerid, id))
{
   new string[128], string2[2][128], Float:_health, Float:_armour, color = id == playerid? brown : orange;
   GetPlayerHealth(id, _health);
   GetPlayerArmour(id, _armour);
   format(string2[0], 128, "%s", GetDateAsString('/', 1));
   format(string2[1], 128, "%s", dini_Get(getPlayerFile(id, _fileusers), "Registered_Date"));
   format(string, sizeof string, playerid == id? ("~~~ You're Stats - %s: ~~~") : ("~~~ %s(%03i) - Stats: ~~~"), GetName(id), id);
   SendClientMessage(playerid, lightblue, string);
   format(string, sizeof string, " [%s] � %03i :���", dini_Get(getPlayerFile(id, _filestats), "Tag"), dini_Int(getPlayerFile(id, _filestats), "Level"));
   SendClientMessage(playerid, id == playerid? orange : brown, string);
   format(string, sizeof string, " Kills: %i � Deaths: %i � VIP: %s", dini_Int(getPlayerFile(id, _filestats), "Kills"), dini_Int(getPlayerFile(id, _filestats), "Deaths"), isPlayerVIP(playerid)? ("YES") : ("NO"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, dini_Exists(ClanPlayerFile(playerid))? (" Health: %.1f%s � Armour: %.1f%s � Clan: %s (/clan info [details/stats] %s)") : (" Health: %.1f%s � Armour: %.1f%s � Clan: %s"), _health, "%%", _armour, "%%", dini_Exists(ClanPlayerFile(id))? dini_Get(ClanPlayerFile(id), "Clan_Name") : ("None"), dini_Get(ClanPlayerFile(id), "Clan_Name"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, " Days Between Registered: %i � Hours Games: %03i(minuents: %03i) � Private Weapons: %s %i", DaysBetweenDates(string2[1], string2[0]), dini_Int(getPlayerFile(id, _filestats), "Hours"), dini_Int(getPlayerFile(id, _filestats), "Mints"), dini_Int(WeaponFile(id), "Total") > 0? ("None") : ("/weapons"), id);
   SendClientMessage(playerid, color, string);
   return 1;
}
function(OnPlayerKeyStateChange(playerid, newkeys, oldkeys))
{
   if(PlayerInfo(isafk[playerid])) setAFK(playerid, false);
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
   }
   else SendClientMessage(playerid, darkblue, "!Away From Keyboard(AFK) - ����� �������� ����");
   PlayerInfo(isafk[playerid]) = s;
   TogglePlayerControllable(playerid, s == true? false : true);
   return 1;
}
function(OnPlayerDeath(playerid, killerid, reason))
{
   if(killerid != playerid && IsPlayerConnected(killerid))
   {
      dini_IntSet(getPlayerFile(killerid, _filestats), "Kills", dini_Int(getPlayerFile(killerid, _filestats), "Kills")+1);
      dini_IntSet(getPlayerFile(playerid, _filestats), "Deaths", dini_Int(getPlayerFile(playerid, _filestats), "Deaths")+1);
   }
   fakeKill(playerid, killerid);
   return 1;
}
function(OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]))
{
   if(dialogid == 5 && response) return _Callback(login, playerid, inputtext);
   if(dialogid == 6 && response) return _Callback(register, playerid, inputtext, GetIP(playerid));
   return 1;
}
function(OnPlayerText(playerid, text[]))
{
   new string[3][128];
   format(string[0], 128, "%s", GetName(playerid));
   format(string[1], 128, dini_Isset(_fileconfig "Tags.ini", string[0]) && strcmp(dini_Get(_fileconfig "Tags.ini", string[0]), "None", true) ? (" | %s") : (""), string[0]);
   format(string[2], 128, " %s [ID: %03d%s]", text, playerid, string[1]);
   for(new i = 0; i < MAX_PLAYERS; i++) if(PlayerInfo(logged[i])) SendPlayerMessageToPlayer(i, playerid, string[2]);
   return 0;
}
UseCallback(int, playerid, isnpc, _state)
{
   new Float:pos[3], string[128];
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
   if(!PlayerInfo(logged[playerid]))
   {
      format(string, sizeof string, _state? ("/login :��� ���� ������ ���� ����� ����� �� ,%s") : ("/register :��� ���� ������ ���� ����� ����� �� ,%s"), GetName(playerid));
      SendClientMessage(playerid, red, string);
      return 0;
   }
   return 1;
}
