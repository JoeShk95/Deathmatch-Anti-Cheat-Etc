/*
		 Roey_Omer (JoeShk / SlyRaccoon`) Clan Proffessional System!
		 Skype: roeyomer
		 Email: omerroye@gmail.com
*/


//=[Includes & Defines]===========================================================
#include "a_samp.inc"
#include "dini.inc"
#tryinclude "cpstream"
#pragma unused ret_memcpy
#pragma dynamic 145000
#define COLOR_WHITE 0xFFFFFFAA
#define red 0xFF0000AA
#define COLOR_ORANGE 0xFF9900AA
#define clanCost 300000
#define MAX_MOVE_GATES 200

//=[News & Enums]===========================================================
new clanName[MAX_PLAYERS][256], isInvited[MAX_PLAYERS], pClan[MAX_PLAYERS][20], clanBanks[500], HQ_MoveObject = 0, HQ_Vehicles = 0, clanVehicles[MAX_VEHICLES];
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
stock GateInfo[MAX_MOVE_GATES][moveGates], pGateInfo[MAX_PLAYERS][pmoveGates];
public OnFilterScriptInit()
{
   new string[128], string2[128];
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
   return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid)
{
   if(isHQVehicle(vehicleid)) return SendClientMessage(playerid, red, ".��� �� ���� ������ �� ���� ����� ����");
   return 1;
}
public OnPlayerUpdate(playerid)
{
   if(dini_Exists(ClanPlayerFile(playerid)) && GetPlayerState(playerid) != 7)
   {
       strmid(pClan[playerid], dini_Get(ClanPlayerFile(playerid),"Clan_Name"),0,strlen(dini_Get(ClanPlayerFile(playerid),"Clan_Name")));
       if(!dini_Exists(ClanFile(pClan[playerid])))
	   {
	        dini_Remove(ClanPlayerFile(playerid));
	        SendClientMessage(playerid, red, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(playerid), false)? (".���� �� ����� �� ����, ����� ��� ���� ������ ����� ����, �� ��� ����� ����� ��� ����� ��") : (".����� ������ �������� �� ��� ����� ����, ����� ������ ��� �� ����� ���, ��� ����� ��"));
	        SendClientMessage(playerid, COLOR_ORANGE,"#Error: 0001");
	        if(!strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(playerid), false)) GivePlayerMoney(playerid, clanCost / 2);
	   }
   }
   return 1;
}
public OnPlayerConnect(playerid)
{
   pGateInfo[playerid][gid] = 1;
   return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
   new cmd[256], idx, string[128];
   cmd = strtok(cmdtext, idx);
   if(!strcmp(cmd, "/cbinfo", true) || !strcmp(cmd, "/clanbankinfo", true))
   {
	   if(getPlayerClanLevel(playerid) < 1) return SendClientMessage(playerid, red, ".��� �� ���� ���� ���� �����");
       if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return SendClientMessage(playerid, red, ".��� �� ���� ���� �� ����� ������ ���");
       SendClientMessage(playerid,COLOR_WHITE," --- Clan Bank Info - ���� ��� ���� --- ");
	   format(string, sizeof string, "!%d$ - ����� ���� �� ����� ���� �� �", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank"));
	   SendClientMessage(playerid, COLOR_ORANGE, string);
	   format(string, sizeof string, "!%d$ - �� ���� ���� ����� ���� �� ���", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
	   SendClientMessage(playerid, COLOR_ORANGE, string);
	   format(string, sizeof string, "%s", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? (".���� �� ����� ��� ����") : (".���� �� ����� ����"));
	   SendClientMessage(playerid, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? red : 0x16EB43ff, string);
	   return 1;
   }
   if(!strcmp(cmd, "/cdeposit", true))
   {
      if(getPlayerClanLevel(playerid) < 1) return SendClientMessage(playerid, red, ".��� �� ���� ���� ���� �����");
      if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return SendClientMessage(playerid, red, ".��� �� ���� ���� �� ����� ������ ���");
	  if(GetPlayerMoney(playerid) < 1) return SendClientMessage(playerid, red, ".��� ���� ���");
      ShowPlayerDialog(playerid,1,2, "All Of Money :���� ���� ��������� �������, �� �� ������� ������ �� �� ���� ���\nAmount Of Money :�� �� ������� ������ ��� �����"," � (1) Amount Of Money\n � (2) All Of Money", "���", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/cwithdraw", true))
   {
	  new date[3];
	  getdate(date[2], date[1], date[0]);
	  format(string, sizeof string, "%d/%d/%d",date[2], date[1], date[0]);
      if(getPlayerClanLevel(playerid) < 1) return SendClientMessage(playerid, red, ".��� �� ���� ���� ���� �����");
      if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return SendClientMessage(playerid, red, ".��� �� ���� ���� �� ����� ������ ���");
      if(!DaysBetweenDates(dini_Get(ClanPlayerFile(playerid),"Last_Withdraw"), string) && strcmp(dini_Get(ClanPlayerFile(playerid),"Last_Withdraw"), "None", true) && getPlayerClanLevel(playerid) != 4) return SendClientMessage(playerid, red, ".��� ���� ���� ��� ������� ��� �� ����� ���");
	  format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
      ShowPlayerDialog(playerid,4, DIALOG_STYLE_INPUT, string," � ��� ��� �� ����� ����� ���� ����� ������� ��� �� ����� ��� ", "����", "�����");
	  return 1;
   }
   if(!strcmp(cmd, "/og", true))
   {
       getMoveObjectNearPlayer(playerid);
	   if(getPlayerClanLevel(playerid) < 1) return SendClientMessage(playerid, red, ".��� �� ���� ���� ���� �����");
	   if(strcmp(pGateInfo[playerid][owner], dini_Get(ClanPlayerFile(playerid),"Clan_Name"), false)) return SendClientMessage(playerid, red,".������ ��� �� ����� ����� ���");
	   if(!PlayerToPoint(playerid, 15.0, GateInfo[pGateInfo[playerid][gid]][xn], GateInfo[pGateInfo[playerid][gid]][yn], GateInfo[pGateInfo[playerid][gid]][zn])) return SendClientMessage(playerid, red, ".��� �� ���� ��� ��� ������� ����� ����� ������ ���");
	   if(GateInfo[pGateInfo[playerid][gid]][gstate]) return SendClientMessage(playerid, red, ".�������� ��� ��� ����");
	   setGateLoctions(pGateInfo[playerid][gid], true);
	   return 1;
   }
   if(!strcmp(cmd, "/cg", true))
   {
       getMoveObjectNearPlayer(playerid);
	   if(getPlayerClanLevel(playerid) < 1) return SendClientMessage(playerid, red, ".��� �� ���� ���� ���� �����");
	   if(strcmp(pGateInfo[playerid][owner], dini_Get(ClanPlayerFile(playerid),"Clan_Name"), false)) return SendClientMessage(playerid, red,".������ ��� �� ����� ����� ���");
	   if(!PlayerToPoint(playerid, 15.0, GateInfo[pGateInfo[playerid][gid]][xn], GateInfo[pGateInfo[playerid][gid]][yn], GateInfo[pGateInfo[playerid][gid]][zn])) return SendClientMessage(playerid, red, ".��� �� ���� ��� ��� ������� ����� ����� ������ ���");
	   if(!GateInfo[pGateInfo[playerid][gid]][gstate]) return SendClientMessage(playerid, red, ".�������� ��� ��� ����");
	   setGateLoctions(pGateInfo[playerid][gid], false);
	   return 1;
   }
   format(string, sizeof string, "/Clans/HQ/%s.ini", dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
   if(dini_Exists(string) && !strcmp(cmd, dini_Get(string,"CMD"), true))
   {
	  if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid,dini_Float(string, "FX"),dini_Float(string, "FY"),dini_Float(string, "FZ"));
	  else SetVehiclePos(GetPlayerVehicleID(playerid),dini_Float(string, "VX"),dini_Float(string, "VY"),dini_Float(string, "VZ"));
	  format(string, sizeof string, " � !%s - ������ ����� ������ �� ����� ���",dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
	  SendClientMessage(playerid, COLOR_ORANGE, string);
      return 1;
   }
   if(!strcmp(cmd, "/hq", true) && !dini_Exists(string)) return SendClientMessage(playerid, red, dini_Exists(ClanPlayerFile(playerid))? (".����� ��� ��� �����") : (".��� �� ���� ���� ����"));
   if(!strcmp(cmd, "/clan", true))
   {
	  new tmpclan[256];
	  tmpclan = strtok(cmdtext, idx);
	  if(!strlen(tmpclan))
	  {
	  	  SendClientMessage(playerid,COLOR_WHITE," --- Clan - ���� --- ");
	  	  SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Create - �� ��� ����� ����");
	  	  SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Invite - ������ ���� ����� ���");
	  	  SendClientMessage(playerid,0x16EB43ff," [03] � /Clan [Accept/Join] - ����� ����� �����");
          SendClientMessage(playerid,0x16EB43ff," [04] � /Clan [Leave/Exit/Quit] - ����� ����� �����");
	  	  SendClientMessage(playerid,0x16EB43ff," [05] � /Clan Info - �� ���� ������ ���� �� ������");
	  	  SendClientMessage(playerid,0x16EB43ff," [06] � /Clan [Set/Edit] - ����� / ����� �� ������ �����");
	  	  SendClientMessage(playerid,0x16EB43ff," [07] � /Clan Bank - ������ ����� ����");
	  	  SendClientMessage(playerid,0x16EB43ff," [08] � /Clan Members - ����� �� �� ������� ������� ����� ������");
	  	  SendClientMessage(playerid,0x16EB43ff," [09] � '@' :�� ��� ���� ����� �'��");
	  	  SendClientMessage(playerid,red," � JoeShk / Roye_Omer - ����� ����� �� ���");
	  	  if(IsPlayerAdmin(playerid))
	  	  {
  	  	       SendClientMessage(playerid,red,"*[A01] � /Clan HQ - ������ ������ ����");
  	  	       SendClientMessage(playerid,red,"*[A02] � /Clan Remove - ����� ����");
  	  	       SendClientMessage(playerid,red,"*[A03] � /ClanWar /ClanWarEnd - ������ ����� ���������");
		  }
		  return 1;
	  }
	  if(!strcmp(tmpclan,"hq", true) && IsPlayerAdmin(playerid))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan2))
		  {
              SendClientMessage(playerid,COLOR_WHITE," --- Clan - ���� --- ");
			  SendClientMessage(playerid,0x16EB43ff," [01] � /Clan HQ Create [Clan Name] - �� ��� ����� ����� �����");
			  SendClientMessage(playerid,0x16EB43ff," [02] � /Clan HQ Remove [Clan Name] - �� ��� ����� ����� �����");
			  SendClientMessage(playerid,0x16EB43ff," [03] � /Clan HQ SetAccess [From] [To] - ������ ����� ����� ��� ����� ���");
			  SendClientMessage(playerid,0x16EB43ff," [04] � /Clan HQ SetArea [Clan Name] [1-2] - �� ��� ����� �� ������ �� ������");
			  SendClientMessage(playerid,0x16EB43ff," [05] � (�� ���� - �� ����) | /Clan HQ Loadlist [Clan Name] - �� ��� ������ �� ������ ������");
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "loadlist", true))
		  {
			  new tmpclan3[256], string2[128];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan HQ Loadlist [Clan Name]");
			  format(string, sizeof string, "%s", tmpclan3);
			  format(string2, sizeof string2, "%i", dini_Int("/Clans/HQ/Objects/Main.ini", "Total"));
			  dini_Set("/Clans/HQ/Objects/Main.ini", string2, string);
			  dini_IntSet("/Clans/HQ/Objects/Main.ini", "Total", dini_Int("/Clans/HQ/Objects/Main.ini", "Total") + 1);
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "setaccess", true))
		  {
			  new tmpclan3[256], tmpclan4[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  tmpclan4 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3) || !strlen(tmpclan4)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan HQ SetAccess [From] [To]");
			  if(!dini_Exists(ClanFile(tmpclan3)) || !dini_Exists(ClanFile(tmpclan4))) return SendClientMessage(playerid, red,".�� ���� / ������ ������ ����");
			  if(dini_Exists(HQ_ClanFile(tmpclan4))) return SendClientMessage(playerid, red,".����� ���� ���� ��� �� �� ������ �� ��� �����, �� ���� ������ �� ���� ����� ����� �� �� �����");
			  dini_Create(HQ_ClanFile(tmpclan4));
			  fcopytextfile(HQ_ClanFile(tmpclan3), HQ_ClanFile(tmpclan4));
			  dini_Remove(HQ_ClanFile(tmpclan3));
		      dini_Set(HQ_ClanFile(tmpclan4), "CMD", "/hq");
		      format(string, sizeof string, " � !%s - ����� �� %s - ����� �� ������ ��", tmpclan4, tmpclan3);
			  SendClientMessage(playerid, COLOR_ORANGE, string);
			  Admin_ClanMessageToAll(tmpclan3, red, " �  !��� ��� ���� �����, ������ ��� ����, �� ��� ���� ����� ����� �� ������ ����");
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "create", true))
		  {
			  new tmpclan3[256], Float:pos[3];
			  tmpclan3 = strtok(cmdtext, idx);
			  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan HQ Create [Clan Name]");
			  if(!dini_Exists(ClanFile(tmpclan3))) return SendClientMessage(playerid, red,".�� ���� ���� ���");
			  if(dini_Exists(HQ_ClanFile(tmpclan3))) return SendClientMessage(playerid, red,".����� �� �� ��� �����");
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
			  SendClientMessage(playerid, COLOR_ORANGE, string);
			  Admin_ClanMessageToAll(tmpclan3, COLOR_ORANGE, " � /HQ - ������ ��� ����� ���� �����, ���� ����� ����? ���/�");
		      return 1;
		  }
		  if(!strcmp(tmpclan2,"setarea", true) && IsPlayerAdmin(playerid))
		  {
		     new tmpclana2[256],tmpclana1[256], Float:pos[3], i = 0;
		     tmpclana1 = strtok(cmdtext, idx);
		     tmpclana2 = strtok(cmdtext, idx);
		     GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		     if(!dini_Exists(HQ_ClanFile(tmpclana1))) return SendClientMessage(playerid, red,".���� �� �� ���� / ����� �� ��� �����");
		     if(!strlen(tmpclana2) || !strlen(tmpclana1)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /clan hq setarea [Clan Name] [1-2] (1 = x1 + y1 | 2 = x2 + y2)");
		     if(strval(tmpclana2) < 1 && strval(tmpclana2) > 2) return SendClientMessage(playerid, red, ".���� ����� ����");
		     while(i < 2)
		     {
			     format(string,sizeof string,!i? ("x%i") : ("y%i"), strval(tmpclana2));
			     dini_FloatSet(HQ_ClanFile(tmpclana1), string, !i? pos[0] : pos[1]);
			     i++;
		     }
		     SendClientMessage(playerid, COLOR_ORANGE,strval(tmpclana2) == 2? ("!������ x2 + y2 ���� �� ��������") : ("!������ x1 + y1 ���� �� ��������"));
			 return 1;
		  }
		  if(!strcmp(tmpclan2, "remove", true))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan HQ Remove [Clan Name]");
			  if(!dini_Exists(HQ_ClanFile(tmpclan3))) return SendClientMessage(playerid, red,".����� �� ��� �����");
			  dini_Remove(HQ_ClanFile(tmpclan3));
			  format(string, sizeof string, " � !%s - ���� �� ������ �����", tmpclan3);
			  SendClientMessage(playerid, COLOR_ORANGE, string);
			  Admin_ClanMessageToAll(tmpclan3, red, " �  !��� ��� ���� �����, ������ ��� ����, �� ��� ���� ����� ����� �� ������ ����");
		      return 1;
		  }
		  return SendClientMessage(playerid, red,".����� ���� �����");
	  }
	  if(!strcmp(tmpclan,"remove", true) && IsPlayerAdmin(playerid))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Remove [Name]");
		  if(!dini_Exists(ClanFile(tmpclan2))) return SendClientMessage(playerid, red,".�� ���� ���� ���");
		  dini_IntSet("/Clans/Main.txt", "Total", dini_Int("/Clans/Main.txt", "Total")-1);
		  dini_Remove(ClanFile(tmpclan2));
		  if(dini_Exists(HQ_ClanFile(tmpclan2))) dini_Remove(HQ_ClanFile(tmpclan2));
		  return 1;
	  }
	  if(!strcmp(tmpclan,"create", true))
	  {
		  new tmpclan2[256], date[3];
		  getdate(date[2], date[1], date[0]);
		  tmpclan2 = strtok(cmdtext, idx);
          format(string, sizeof string , "%d/%d/%d",date[0],date[1],date[2]);
		  if(GetPlayerMoney(playerid) < clanCost) return SendClientMessage(playerid,red,".��� ���� ����� 300000$ �� ��� ����� ����");
		  if(dini_Exists(ClanPlayerFile(playerid))) return SendClientMessage(playerid, red,".��� ��� ���� �����");
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Create [Name]");
		  if(dini_Exists(ClanFile(tmpclan2))) return SendClientMessage(playerid, red,".���� ��� ���� ��� ���");
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
		  SendClientMessage(playerid, COLOR_WHITE, string);
		  SendClientMessage(playerid, 0x16EB43FF," � /Clan Invite - �� ��� ������ ���� ����� ���� ���");
		  SendClientMessage(playerid, 0x16EB43FF," � /Clan Edit Color - �� ��� ����� �� ���� �� ����� ���");
		  SendClientMessage(playerid, 0x16EB43FF," � /Clans  - �� ��� ����� ������ ������ ����");
		  SendClientMessage(playerid, 0x16EB43FF," � /Clan - �� ��� ����� ��� ������ ������");
		  SendClientMessage(playerid, COLOR_ORANGE," � '@' - ��� ���� ��'�� �� ����� ���");
		  SendClientMessage(playerid, COLOR_WHITE, " -------------------------------------- ");
		  GivePlayerMoney(playerid, -clanCost);
	 	  return 1;
	  }
	  if(!strcmp(tmpclan, "info", true))
 	  {
		  new tmpclan4[256];
		  tmpclan4 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan4))
		  {
		      SendClientMessage(playerid,COLOR_WHITE," --- Clan Info - ���� ���� --- ");
		      SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Info Stats - ������ �� �����");
		      SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Info Details - ���� �� �����");
		      SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Info Members - ���� ������ ������ �� �����");
			  return 1;
		  }
		  if(!strcmp(tmpclan, "Members", true))
		  {
		     new tmpclan3[256];
		     tmpclan3 = strtok(cmdtext, idx);
		     clanMembers(playerid, tmpclan3);
		     return 1;
		  }
		  if(!strcmp(tmpclan4, "stats", true))
		  {
			 new tmpclan3[256];
			 tmpclan3 = strtok(cmdtext, idx);
			 if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Info Stats [name]");
			 if(!dini_Exists(ClanFile(tmpclan3))) return SendClientMessage(playerid, red,".�� ���� ���� ���");
		     format(string, sizeof string, " -------- [ Clan(%s) - Statics] -------- ",tmpclan3);
		     SendClientMessage(playerid, COLOR_WHITE, string);
	 	     format(string, sizeof string, getClanConnected(tmpclan3) > 0? (" � %d - ������ ������� ����� �� ���") : (" � .��� ��� ������ ������� ����� ��"),getClanConnected(tmpclan3));
	 	     SendClientMessage(playerid, getClanConnected(tmpclan3) > 0? 0x16EB43FF : red, string);
	 	     format(string, sizeof string, dini_Int(ClanFile(tmpclan3),"Kills") != 0? (" � %d - ����� �� ������� �� ������� ��� �������� �����") : (" � .��� ����� ������ ����� ��"),dini_Int(ClanFile(tmpclan3),"Kills"));
	 	     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Kills") != 0? 0x16EB43FF : red, string);
	 	     format(string, sizeof string, dini_Int(ClanFile(tmpclan3),"Bank") != 0? (" � %d$ - ���� ���� ��� ����� ��� ������") : (" � .����� �� ��� ��� ����"),dini_Int(ClanFile(tmpclan3),"Bank"));
	 	     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Bank") != 0? 0x16EB43FF : red, string);
		     format(string, sizeof string, " � ./Clan Info [Details/Members] %s - ���� ���� �� �����", tmpclan3);
		     SendClientMessage(playerid, COLOR_ORANGE, string);
			 SendClientMessage(playerid, COLOR_WHITE, " -------------------------------------- ");
	 	     return 1;
	 	  }
 		  if(!strcmp(tmpclan4, "details", true))
		  {
			 new tmpclan3[256];
			 tmpclan3 = strtok(cmdtext, idx);
			 if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Info Details [name]");
			 if(!dini_Exists(ClanFile(tmpclan3))) return SendClientMessage(playerid, red,".�� ���� ���� ���");
		     format(string, sizeof string, " -------- [ Clan(%s) - Details ] -------- ",tmpclan3);
		     SendClientMessage(playerid, COLOR_WHITE, string);
		     format(string, sizeof string, " � %i - ���� ������ - %s - ���� ������ ����  � %s - ���� �� ���",dini_Int(ClanFile(tmpclan3),"Total"), dini_Get(ClanFile(tmpclan3),"Opend_Date"),dini_Get(ClanFile(tmpclan3),"Clan_Owner"));
		     SendClientMessage(playerid, 0x16EB43FF, string);
		     format(string, sizeof string, " � ����� �� �����: %d � ��� ��� �������� ����� �� ����� ����: %d.0$",dini_Int(ClanFile(tmpclan3),"Skin"), dini_Int(ClanFile(tmpclan3),"Bank") / dini_Int(ClanFile(tmpclan3),"Total"));
		     SendClientMessage(playerid, 0x16EB43FF, string);
		     format(string, sizeof string, !dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In")? (" � ���� �� �� ����� ����� ���������") : (" � %d/%d �������� ���������"),dini_Int(ClanFile(tmpclan3),"Tournament_Victory"), dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In"));
		     SendClientMessage(playerid, !dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In")? red : 0x16EB43FF, string);
		     format(string, sizeof string, !strcmp(dini_Get(ClanFile(tmpclan3),"Clan_Message"), "None", false)? (" � ��� ��� ����� ������ �����") : (" � %s"), dini_Get(ClanFile(tmpclan3),"Clan_Message"));
		     SendClientMessage(playerid, !strcmp(dini_Get(ClanFile(tmpclan3),"Clan_Message"), "None", false)? red : 0x16EB43FF, string);
		     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Test")? 0x16EB43FF : red, dini_Int(ClanFile(tmpclan3),"Test")? (" � ����� ���� ������") : (" � ����� ���� ������"));
		     format(string, sizeof string, " � ./Clan Info [Stats/Members] %s - ���� ���� �� �����", tmpclan3);
		     SendClientMessage(playerid, COLOR_ORANGE, string);
			 SendClientMessage(playerid, COLOR_WHITE, " -------------------------------------- ");
	 	     return 1;
	 	  }
		  return SendClientMessage(playerid, red,".����� ���� �����");
	  }
	  if(!strcmp(tmpclan, "Members", true))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  clanMembers(playerid, tmpclan2);
		  return 1;
	  }
	  if(!strcmp(tmpclan, "leave", true) || !strcmp(tmpclan, "exit", true) || !strcmp(tmpclan, "quit", true))
	  {
		   new a = -1;
	       if(!isPlayerInClan(playerid)) return SendClientMessage(playerid, red, ".��� �� ���� ���� ����");
 		   format(string, sizeof string," � !%s - ���� ������ �� ����� ,%s - ���� ��", dini_Get(ClanPlayerFile(playerid), "Clan_Name"), GetName(playerid));
		   SendClientMessage(playerid, red, string);
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
	  if(!strcmp(tmpclan, "kick", true))
	  {
		   new tmpclan2[256], id = -1;
		   tmpclan2 = strtok(cmdtext, idx);
		   id = IsNumeric(tmpclan2)? strval(tmpclan2) : GetPlayerID(tmpclan2);
		   if(getPlayerClanLevel(playerid) < 3) return SendClientMessage(playerid, red, getPlayerClanLevel(playerid) > 0? (".����� �� ������� ����� ������ ����") : (".��� �� ���� ���� ����"));
		   if(!strlen(tmpclan2)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Kick [playerid]");
		   if(!IsPlayerConnected(id)) return SendClientMessage(playerid, red,".���� �� �� �����");
		   if(!isPlayerInClan(id)) return SendClientMessage(playerid, red, ".���� �� �� ���� ���� ����");
   		   if(getPlayerClanLevel(playerid) < getPlayerClanLevel(id) || !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false))
		   {
		      SendClientMessage(playerid, red, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false)? (".��� �� ���� ����� �� ������ �� �����") : (".��� �� ���� ����� ���� ����� ��� ����� ���� ���� ����"));
		      format(string, sizeof string, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false)? (" � (%s) !���� ����� �� ������ �� ����� ,%s - �����") : (" � (%s) !���� ����� ���� ������ ���� ���� ���� ���� ,%s - �����"), GetName(id), GetName(playerid));
		      SendClanMessageToAllEx(playerid, red, string);
		      return 1;
		   }
		   if(strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), false)) return SendClientMessage(playerid, red,".���� �� �� ���� ����� ���");
           format(string, sizeof string, "Clan_Player%i", dini_Int(ClanPlayerFile(id), "Clan_Memmber"));
		   dini_Set(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), string, "None");
  	       dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), "Total", dini_Int(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), "Total")-1);
		   dini_Remove(ClanPlayerFile(id));
		   format(string, sizeof string," � !������ %s - ���� ��",GetName(id));
		   SendClientMessage(playerid, red, string);
 		   format(string, sizeof string," � !��� ���� ������ %s - ����� ,%s - ���� ��",GetName(playerid), GetName(id));
		   SendClientMessage(id, red, string);
		   format(string, sizeof string, " � !%s ���� ������ �� ��� %s - �����", GetName(playerid), GetName(id));
		   SendClanMessageToAllEx(playerid, red, string);
		   return 1;
	  }
	  if(!strcmp(tmpclan, "invite", true))
	  {
		  new tmpclan2[256], id = -1;
		  tmpclan2 = strtok(cmdtext, idx);
		  id = IsNumeric(tmpclan2)? strval(tmpclan2) : GetPlayerID(tmpclan2);
		  if(getPlayerClanLevel(playerid) < 3) return SendClientMessage(playerid, red, getPlayerClanLevel(playerid) > 0? (".����� �� ������� ����� ������ ����") : (".��� �� ���� ���� ����"));
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Invite [playerid]");
		  if(!IsPlayerConnected(id)) return SendClientMessage(playerid, red,".���� �� �� �����");
		  if(isPlayerInClan(id)) return SendClientMessage(playerid, red, ".���� �� ��� ���� �����");
		  if(!strcmp(dini_Get(ClanPlayerFile(playerid), "Clan_Name"), clanName[id], false)) return SendClientMessage(playerid, red, ".���� �� ��� ����� ����� ���");
		  format(string,sizeof string,".�� ��� ������ ��� ����� ,%s - ����� ���� ������ ����� %s - �����",dini_Get(ClanPlayerFile(playerid), "Clan_Name"), GetName(playerid));
		  ShowPlayerDialog(id,0,DIALOG_STYLE_MSGBOX," �  /Clan Accept - ����� ����� �����, �� ��� ������ ��� \"�����\" �� ����� �",string,"�����","���� ����");
		  format(string, sizeof string," � !����� ����� ��� %s - ����� ��", GetName(playerid));
		  SendClientMessage(playerid, COLOR_ORANGE, string);
		  format(string, sizeof string, "!������ ����� %s - ����� �� ����� %s - �����", GetName(id), GetName(playerid));
		  SendClanMessageToAllEx(playerid, COLOR_ORANGE, string);
		  format(string, sizeof string," � !%s - ���� �� ������ ����� %s - �����", dini_Get(ClanPlayerFile(playerid),"Clan_Name"), GetName(playerid));
		  SendClientMessage(id, COLOR_ORANGE, string);
		  SendClientMessage(id,0x16EB43FF, " � (�� ����� ������) /Clan Accept - �� ��� ���� �� ������ ����� ���/�");
		  isInvited[id] = 1;
		  clanName[id] = dini_Get(ClanPlayerFile(playerid),"Clan_Name");
		  return 1;
	  }
	  if(!strcmp(tmpclan, "join", true) || !strcmp(tmpclan, "accept", true)) return !isPlayerInClan(playerid)? clan_Accept(playerid) : SendClientMessage(playerid, red,".��� ��� ���� �����");
	  if(!strcmp(tmpclan, "set", true))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 4) return SendClientMessage(playerid, red, getPlayerClanLevel(playerid) > 0? (".����� �� ����� ����� ����") : (".��� �� ���� ���� ����"));
		  if(!strlen(tmpclan2))
		  {
		      SendClientMessage(playerid,COLOR_WHITE," --- Clan Set - ���� ������ --- ");
		      SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Set Level - ����� ���� ��� ����");
		      SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Set Skin [Skin-id/OFF] - �� ��� ����� �� ����� �� �����");
	  	      SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Edit - ���� ��������");
		      return 1;
		  }
		  if(!strcmp(tmpclan2, "level", true))
		  {
			  new tmpclan3[256], tmpclan4[256], name_level[34];
			  tmpclan3 = strtok(cmdtext, idx);
			  tmpclan4 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan4) || !strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan Set Level [playerid] [1 - Noraml | 2 - Tester | 3 - SubLeader | 4 - Owner + Leader]");
			  if(strval(tmpclan3) == playerid) return SendClientMessage(playerid, red, ".��� �� ���� ����� �� ���� ���");
			  if(getPlayerClanLevel(playerid) < getPlayerClanLevel(strval(tmpclan3)) || !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false))
			  {
		          SendClientMessage(playerid, red, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false)? (".��� �� ���� ����� �� ���� �� ������") : (".��� �� ���� ����� ��� ����� ���� ���"));
		          format(string, sizeof string, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false)? (" � (%s) !����� ���� ����� �� ���� �� ������ ,%s - �����") : (" � (%s) !���� ����� �� ���� ��� ����� ,%s - �����"), GetName(strval(tmpclan3)), GetName(playerid));
		          SendClanMessageToAllEx(playerid, red, string);
		          return 1;
			  }
			  if(strval(tmpclan4) == 1) name_level = "Normal";
			  if(strval(tmpclan4) == 2) name_level = "Tester";
			  if(strval(tmpclan4) == 3) name_level = "SubLeader";
			  if(strval(tmpclan4) == 4) name_level = "Owner + Leader";
			  format(string, sizeof string, "!\"%s (%i)\" - � %s - ���� �� ���� �� ,%s - ������", name_level, strval(tmpclan4), GetName(strval(tmpclan3)), GetName(playerid));
			  SendClanMessageToAll(playerid, COLOR_ORANGE, string);
			  dini_IntSet(ClanPlayerFile(strval(tmpclan3)), "Clan_Level", strval(tmpclan4));
			  return 1;
		  }
   		  if(!strcmp(tmpclan2, "skin", true))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan Set Skin [skin-id]");
			  if(isSkinCrash(strval(tmpclan3)) && strcmp(tmpclan3, "off", true)) return SendClientMessage(playerid, red, ".���� ����");
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin", strcmp(tmpclan3, "off", true)? strval(tmpclan3) : -1);
			  format(string, sizeof string, strcmp(tmpclan3, "off", true)? (" � !%d :���� �� ����� �� ����� ������ ,%s - ������") : (" � !������ �� ����� ���� �� ����� ������"), strval(tmpclan3), GetName(playerid));
			  SendClanMessageToAll(playerid, COLOR_ORANGE, string);
 			  return 1;
		  }
		  return SendClientMessage(playerid, red,".����� ���� �����");
	  }
	  if(!strcmp(tmpclan, "edit", true))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 3) return SendClientMessage(playerid, red, getPlayerClanLevel(playerid) > 0? (".����� �� ������� ����� ������ ����") : (".��� �� ���� ���� ����"));
		  if(!strlen(tmpclan2))
		  {
	  	      SendClientMessage(playerid,COLOR_WHITE," --- Clan Edit - ���� ����� --- ");
	  	      SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Edit Color - �� ��� ����� ����");
	  	      SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Edit HQ - ����� ������");
	  	      SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Edit Test - ����� / ����� ��������� ������");
	  	      SendClientMessage(playerid,0x16EB43ff," [04] � /Clan Edit Comment - ����� ����� �����");
	  	      SendClientMessage(playerid,0x16EB43ff," [05] � /Clan Set - ���� ��������");
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "comment", true))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok_line(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE,"Usage: /Clan Edit Comment [Action]");
			  dini_Set(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Clan_Message",tmpclan3);
			  format(string, sizeof string, " � ./Clan Info Details - ���� �� ������� �� �����, �� ��� ����� �� %s - �����", GetName(playerid));
			  SendClanMessageToAll(playerid, COLOR_ORANGE, string);
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "test", true))
		  {
			  SendClientMessage(playerid, COLOR_ORANGE, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? (".���� �� ������� ������ �����") : (".���� �� ������� ������ �����"));
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Test", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? 0 : 1);
			  format(string,sizeof string, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? ("!��� �� ����� ������ ,%s - �����") : ("!��� �� ����� ������ ,%s - �����"), GetName(playerid));
			  SendClanMessageToAllEx(playerid, COLOR_ORANGE, string);
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "hq", true))
		  {
			  new tmpclan3[256], Float:pos[3];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(getPlayerClanLevel(playerid) < 4) return SendClientMessage(playerid, red, getPlayerClanLevel(playerid) > 0? (".����� �� ����� ����� ����") : (".��� �� ���� ���� ����"));
			  if(!dini_Exists(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")))) return SendClientMessage(playerid, red, ".��� ����� ��� �����");
			  if(!strlen(tmpclan3))
			  {
	  	         SendClientMessage(playerid,COLOR_WHITE," --- Clan Edit HQ - ���� ����� ����� --- ");
	  	         SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Edit HQ CMD - ����� ������ ������ ������");
                 SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Edit HQ Foot - ����� ������ �� ������ ������ �����");
	  	         SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Edit HQ Vehicle - ����� ������ �� ������ ������ ����");
	  	         return 1;
	  	      }
	  	      if(!isPlayerInHerHQ(playerid) && strcmp(tmpclan3, "cmd", true)) return SendClientMessage(playerid,red, ".�� ��� ���� ����� ����� ������ ��� ���� ����� ������ ���");
	  	      if(!strcmp(tmpclan3, "foot", true) || !strcmp(tmpclan3, "vehicle", true))
	  	      {
				 new changed = 0;
				 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
				 format(string,sizeof string, "%sX", !strcmp(tmpclan3, "foot", true)? ("F") : ("V"));
				 for(new i = 0; i < 3; i++)
				 {
				    dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), string, pos[changed]);
				    changed++;
				    if(changed > 0) format(string,sizeof string, "%s%s", !strcmp(tmpclan3, "foot", true)? ("F") : ("V"), changed == 1? ("Y") : ("Z"));
			     }
				 SendClanMessageToAll(playerid, COLOR_ORANGE, !strcmp(tmpclan3, "vehicle", true)? (" � .������ ���� �� ������ �� ���� ������") : (" � .������ ���� �� ������ �� ����� ������"));
				 return 1;
	  	      }
	  	      if(!strcmp(tmpclan3, "cmd", true))
	  	      {
				  new tmpclan4[256];
				  tmpclan4 = strtok(cmdtext, idx);
				  if(!strlen(tmpclan4)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan Edit HQ Cmd [Command Name]");
				  if(tmpclan4[0] == '/') return SendClientMessage(playerid, red, ".��� ���� ������ � \"/\" ������ ����� �� �� �������");
				  format(string, sizeof string, "/%s", tmpclan4);
				  dini_Set(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "CMD", string);
				  format(string, sizeof string, " � /%s - ���� �� ������ �� ������ ������ � %s - ������", tmpclan4, GetName(playerid));
				  SendClanMessageToAll(playerid, COLOR_ORANGE, string);
				  return 1;
			  }
			  return SendClientMessage(playerid, red,".����� ���� �����");
		  }
		  if(!strcmp(tmpclan2, "color", true))
		  {
		      new CC[3][256];
		      for(new d = 0; d < sizeof CC; d++) CC[d] = strtok(cmdtext, idx);
		      if(!strlen(CC[0]) || !strlen(CC[1]) || !strlen(CC[2])) return SendClientMessage(playerid,COLOR_WHITE,"Usage: /Clan Edit Color [red-1-255] [green-1-255] [blue-1-255]");
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
		  return SendClientMessage(playerid, red,".����� ���� �����");
	  }
	  if(!strcmp(tmpclan, "bank", true))
	  {
		  new Float:pos[3];
		  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 4) return SendClientMessage(playerid, red, getPlayerClanLevel(playerid) > 0? (".����� �� ����� ����� ����") : (".��� �� ���� ���� ����"));
		  if(!dini_Exists(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")))) return SendClientMessage(playerid, red, ".��� ����� ��� �����");
		  if(!strlen(tmpclan2))
		  {
             SendClientMessage(playerid,COLOR_WHITE," --- Clan Bank - ��� ���� --- ");
             SendClientMessage(playerid,0x16EB43ff," [01] � /Clan Bank MaxWithdraw - ����� �\"������� �����\" ���� ���, �����");
             SendClientMessage(playerid,0x16EB43ff," [02] � /Clan Bank SetPos - ����� ������ �� ����");
             SendClientMessage(playerid,0x16EB43ff," [03] � /Clan Bank Lock - �� ��� ����� / ����� �� ���� �� �����");
			 return 1;
		  }
		  if(!strcmp(tmpclan2, "maxwithdraw", true))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan Bank MaxWithdraw [Amount]");
			  if(strval(tmpclan3) > 1000000 || strval(tmpclan3) <= 1) return SendClientMessage(playerid, red, ".���� ����� ����");
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw", strval(tmpclan3));
		      format(string, sizeof string, " � !%d$ :���� �� �������� ����� ���� ���� ����� �� � %s - ������ �� �����", strval(tmpclan3), GetName(playerid));
		      SendClanMessageToAll(playerid, red, string);
			  return 1;
		  }
		  if(!strcmp(tmpclan2, "lock", true))
		  {
             dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? 0 : 1);
			 format(string, sizeof string, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? (" � !��� �� ���� �� ����� %s - ������ �� �����") : (" � !��� �� ���� �� ����� %s - ������ �� �����"), GetName(playerid));
			 SendClanMessageToAll(playerid, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? red : 0x16EB43FF, string);
			 return 1;
		  }
		  if(!strcmp(tmpclan2, "setpos", true))
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
		  return SendClientMessage(playerid, red,".����� ���� �����");
	  }
	  return SendClientMessage(playerid, red,".����� ���� �����");
   }
   if(!strcmp(cmd, "/clans", true))
   {
	   new clanfile[128], count_clan = 0;
	   if !dini_Int("/Clans/Main.txt", "Total") *then return SendClientMessage(playerid, red,".��� ������ ������ ����");
	   format(string, sizeof string, " -------- [ Memmber(s) Clan(s): %i] -------- ",dini_Int("/Clans/Main.txt", "Total"));
	   SendClientMessage(playerid, COLOR_WHITE, string);
	   for(new i = 0; i < dini_Int("/Clans/Main.txt", "Total") + 2; i++)
	   {
		  format(clanfile,sizeof clanfile,"Clan%i", i);
		  if(dini_Isset("/Clans/Main.txt", clanfile) && strcmp(dini_Get("/Clans/Main.txt", clanfile), "None", false))
		  {
		       format(string,sizeof string, " � %i. %s [Memmber(s): #%d | Connected Players: %d | Create By: %s]",count_clan + 1, dini_Get("/Clans/Main.txt", clanfile),1,getClanConnected(dini_Get("/Clans/Main.txt", clanfile)), dini_Get(ClanFile(dini_Get("/Clans/Main.txt", clanfile)),"Clan_Owner"));
		       SendClientMessage(playerid,dini_Exists(ClanPlayerFile(playerid)) && !strcmp(dini_Get(ClanPlayerFile(playerid),"Clan_Name"), dini_Get("/Clans/Main.txt", clanfile), false)? red : COLOR_ORANGE, string);
		       count_clan++;
		  }
		  else continue;
	   }
	   SendClientMessage(playerid, COLOR_WHITE, " -------------------------------------- ");
	   return 1;
   }
   return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
   new string[128];
   if(dini_Exists(ClanPlayerFile(playerid)))
   {
       if(CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")]))
       {
		    format(string, sizeof string, "  ~~~ !%s - ������ ����� ���� �� ����� ��� ~~~  ", dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
		    SendClientMessage(playerid, 0x00FFFFAA, string);
		    SendClientMessage(playerid, COLOR_ORANGE, "!���� ��, ������ ����� ������ ��� �� ����� ���, ��� ��� ���� ��� ��� ����� �� ���� �����");
		    SendClientMessage(playerid, 0x16EB43ff, " � /cbinfo - �� ��� ���� ���� �� ���� ����");
		    SendClientMessage(playerid, 0x16EB43ff, " � /cdeposit - �� ��� ������ ��� ������ ���� �� �����");
		    SendClientMessage(playerid, 0x16EB43ff, " � /cwithdraw - �� ��� ����� ��� ������� �� ���� �� �����");
       }
   }
   return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new string[128],  date[3];
    getdate(date[2], date[1], date[0]);
    if(dialogid == 0) return response? clan_Accept(playerid) : SendClientMessage(playerid,COLOR_ORANGE," � /Clan Accept - �� �� 30 ����� ������ �� ��� ���� ������ ����� ������� ����, �� ��� ���� ���/�");
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
	    SendClanMessageToAll(playerid, COLOR_ORANGE, string);
	    dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank") + strval(inputtext));
	    GivePlayerMoney(playerid, -strval(inputtext));
	    return 1;
	}
	if(dialogid == 3 && response)
	{
	    if(GetPlayerMoney(playerid) < 1) return SendClientMessage(playerid, red, ".��� �� ���");
	    format(string, sizeof string, " � !%d$ - ����� ������ ��� �� �� ���� %s �����", GetPlayerMoney(playerid), GetName(playerid));
	    SendClanMessageToAll(playerid, COLOR_ORANGE, string);
	    dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank") + GetPlayerMoney(playerid));
	    ResetPlayerMoney(playerid);
	    return 1;
	}
	if(dialogid == 4 && response)
	{
	   if(strval(inputtext) > dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank"))
	   {
           format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
		   ShowPlayerDialog(playerid,4, DIALOG_STYLE_INPUT, string," � ��� ��, ����� ����� ����� ���� ���� ��� ���� ����, ��� ��� ���� ������ ", "����", "�����");
		   return 1;
	   }
	   if(strval(inputtext) > dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw") && getPlayerClanLevel(playerid) != 4)
	   {
           format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
		   ShowPlayerDialog(playerid,4, DIALOG_STYLE_INPUT, string, " � \"MaxWithdraw\" :��� ��, ����� ����� ���� ������, ���� ���� ����� ���� ������ ������ ����� ", "����", "�����");
		   return 1;
	   }
	   format(string, sizeof string, "%d/%d/%d",date[2], date[1], date[0]);
	   dini_Set(ClanPlayerFile(playerid),"Last_Withdraw", string);
	   GivePlayerMoney(playerid, strval(inputtext));
       format(string, sizeof string, " � !%d$ - ��� ������ ���� �� ����� %s �����", strval(inputtext), GetName(playerid));
	   SendClanMessageToAll(playerid, COLOR_ORANGE, string);
	   return 1;
	}
	return 1;
}
public OnPlayerText(playerid, text[])
{
   new string[128];
   if(text[0] == '@' && isPlayerInClan(playerid))
   {
	   format(string, sizeof string, "@ %s [CLVL %d | ID: %i]", GetName(playerid), getPlayerClanLevel(playerid), playerid);
       SendClanMessageToAll(playerid, 0x00FFFFAA, string);
	   return 0;
   }
   return 1;
}
stock clan_Accept(playerid)
{
	 new string[128];
	 if(isPlayerInClan(playerid)) return SendClientMessage(playerid, red, ".��� ��� ���� �����");
	 if(!isInvited[playerid]) return SendClientMessage(playerid, red,".�� ������ ���� ����");
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
	 SendClientMessage(playerid, COLOR_ORANGE, string);
	 ShowPlayerDialog(playerid,0,DIALOG_STYLE_MSGBOX,"!������ ������ �����:",string,"�����","���� ����");
	 format(string, sizeof string, " � !����� �����, ��� ��� %s - �����", GetName(playerid));
	 SendClanMessageToAllEx(playerid, COLOR_ORANGE, string);
	 isInvited[playerid] = 0;
	 return 1;
}
stock clanMembers(playerid, tmpclan2[])
{
	new string[128], string2[128], string3[128], b = 0;
	if(!strlen(tmpclan2)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /Clan Members [name]");
	if(!dini_Exists(ClanFile(tmpclan2))) return SendClientMessage(playerid, red,".�� ���� ���� ���");
	format(string3, sizeof string3, " -------- [ Clan(%s) - Memmber(s) %d ] -------- ",tmpclan2, dini_Int(ClanFile(tmpclan2),"Total"));
	SendClientMessage(playerid, COLOR_WHITE, string3);
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
	SendClientMessage(playerid, COLOR_ORANGE, string);
	SendClientMessage(playerid, COLOR_WHITE, " -------------------------------------- ");
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
				 if(aLoad == 0) CreateObject(strval(xreaded[0]), floatstr(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), floatstr(xreaded[5]),  floatstr(xreaded[6]), strval(xreaded[7]));
				 if(aLoad == 1) clanVehicles[HQ_Vehicles++] = AddStaticVehicle(strval(xreaded[0]), floatstr(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), strval(xreaded[5]), strval(xreaded[6]));
				 if(aLoad == 2) CreatePickup(strval(xreaded[0]),strval(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]));
				 if(aLoad == 3)
				 {
                      HQ_MoveObject += 1;
				      GateInfo[HQ_MoveObject][gid] = CreateObject(strval(xreaded[0]), floatstr(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), floatstr(xreaded[5]),  floatstr(xreaded[6]), strval(xreaded[7]));
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
public OnPlayerSpawn(playerid)
{
   if(isPlayerInClan(playerid) && dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin") != -1) SetPlayerSkin(playerid,dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin"));
   if(isPlayerInClan(playerid)) setPlayerClanColor(playerid);
   return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
   if(isPlayerInClan(killerid)) dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Kills",dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Kills") + 1);
   return 1;
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
   if(!mgstate) MoveObject(GateInfo[x][gid], GateInfo[x][xn], GateInfo[x][yn], GateInfo[x][zn], GateInfo[x][speed]);
   else	MoveObject(GateInfo[x][gid], GateInfo[x][xun], GateInfo[x][yun], GateInfo[x][zun], GateInfo[x][speed]);
   GateInfo[x][gstate] = mgstate;
   return 1;
}
stock ClanPlayerFile(playerid)
{
  new string[256];
  format(string, sizeof string,"/Clans/Users/%s.ini",GetName(playerid));
  return string;
}
stock ClanFile(name[])
{
  new string[256];
  format(string,sizeof string,"/Clans/%s.ini",name);
  return string;
}
stock HQ_ClanFile(name[])
{
  new string[256];
  format(string,sizeof string,"/Clans/HQ/%s.ini",name);
  return string;
}
stock isPlayerInHerHQ(playerid) return make_isPlayerInArea(playerid,dini_Float(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "x1"),dini_Float(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "y1"),dini_Float(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "x2"),dini_Float(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "y2"))? 1 : 0;
stock isPlayerInClan(playerid) return dini_Exists(ClanPlayerFile(playerid))? 1 : 0;
stock getPlayerClanLevel(playerid) return dini_Int(ClanPlayerFile(playerid), "Clan_Level");
stock isHQVehicle(vehicleid)
{
   for(new i = 0; i < MAX_VEHICLES; i++) if(vehicleid == clanVehicles[i]) return 1;
   return 0;
}
stock getClanConnected(name[])
{
   new connected_count = 0;
   for(new i = 0; i < MAX_PLAYERS; i++) if(dini_Exists(ClanPlayerFile(i)) && !strcmp(dini_Get(ClanPlayerFile(i),"Clan_Name"), name, true)) connected_count++;
   return connected_count;
}

stock GetName(playerid)
{
  new n[24];
  GetPlayerName(playerid, n, sizeof n);
  return n;
}
stock DaysBetweenDates(DateStart[], DateEnd[])
{
	new datetmp[256], idx1, idx2;
	datetmp = strtok(DateStart, idx1, '/');
	new Start_Day = strval(datetmp);
	datetmp = strtok(DateStart, idx1, '/');
	new Start_Month = strval(datetmp);
	datetmp = strtok(DateStart, idx1, '/');
	new Start_Year = strval(datetmp);
	datetmp = strtok(DateEnd, idx2, '/');
	new End_Day = strval(datetmp);
	datetmp = strtok(DateEnd, idx2, '/');
	new End_Month = strval(datetmp);
	datetmp = strtok(DateEnd, idx2, '/');
	new End_Year = strval(datetmp);
	new init_date = mktime(12,0,0,Start_Day,Start_Month,Start_Year);
	new dest_date = mktime(12,0,0,End_Day,End_Month,End_Year);
	new offset = dest_date-init_date;
	new days = floatround(offset/60/60/24, floatround_floor);
	return days;
}
stock PlayerToPoint(playerid, Float:radi, Float:x, Float:y, Float:z)
{
   new Float:oldposx, Float:oldposy, Float:oldposz, Float:tempposx, Float:tempposy, Float:tempposz;
   GetPlayerPos(playerid, oldposx, oldposy, oldposz);
   tempposx = (oldposx -x), tempposy = (oldposy -y), tempposz = (oldposz -z);
   return ((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))? 1 : 0;
}
stock IsNumeric(string[])
{
  for (new i = 0, j = strlen(string); i < j; i++) if (string[i] > '9' || string[i] < '0') return 0;
  return 1;
}
stock GetPlayerID(const Name[])
{
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && !strcmp(Name, GetName(i), true)) return i;
	return INVALID_PLAYER_ID;
}
stock make_isPlayerInArea(playerid, Float:x1, Float:y1, Float:x2, Float:y2) /// JoeShk
{
   new Float:mx[2], Float:my[2], Float:pos[3];
   mx[0] = x1 > x2? x1 : x2, mx[1] = x1 < x2? x1 : x2,
   my[0] = y1 > y2? y1 : y2, my[1] = y1 < y2? y1 : y2;
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   return pos[0] <= mx[0] && pos[0] >= mx[1] && pos[1] <= my[0] && pos[1] >= my[1]? true : false;
}
stock getPlayerUserID(playerid) return dini_Int(getPlayerFile(playerid, _fileusers), "Userid");
stock SendClanMessageToAllEx(playerid, color, const message[])
{
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && i != playerid && !strcmp(dini_Get(ClanPlayerFile(playerid), "Clan_Name"), dini_Get(ClanPlayerFile(i), "Clan_Name"), false)) SendClientMessage(i, color, message);
   return 1;
}
stock SendClanMessageToAll(playerid, color, const message[])
{
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && !strcmp(dini_Get(ClanPlayerFile(playerid), "Clan_Name"), dini_Get(ClanPlayerFile(i), "Clan_Name"), false)) SendClientMessage(i, color, message);
   return 1;
}
stock Admin_ClanMessageToAll(clan[], color, const message[])
{
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && !strcmp(dini_Get(ClanPlayerFile(i), "Clan_Name"), clan, true)) SendClientMessage(i, color, message);
   return 1;
}
stock sgba2hex(s,g,b,a) return (s*16777216) + (g*65536) + (b*256) + a;
stock strtok_line(const string[], index)
{
	new length = strlen(string), offset = index, result[256];
	while ((index < length) && ((index - offset) < (sizeof result - 1)) && (string[index] > '\r')) result[index - offset] = string[index], index++;
	result[index - offset] = EOS;
	return result;
}
stock isSkinCrash(skinid)
{
    new badSkins[22] = { 3, 4, 5, 6, 8, 42, 65, 74, 86, 119, 149, 208, 268, 273, 289 };
    if (skinid < 0 || skinid > 299) return false;
    for (new i = 0; i < 22; i++) if (skinid == badSkins[i]) return true;
    return false;
}
stock _split(const strsrc[], strdest[][], delimiter)
{
	new i, w, x, z;
	while(i <= strlen(strsrc))
	{
	     if(strsrc[i] == delimiter || i == strlen(strsrc))
		 {
	         z = strmid(strdest[x], strsrc, w, i, 128);
	         strdest[x][z] = 0, w = i + 1, x++;
		 }
		 i++;
	}
	return 1;
}
