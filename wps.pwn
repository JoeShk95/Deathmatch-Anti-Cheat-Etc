//=[Includes & Defines]===========================================================
#include "../DeathMatch/acf.pwn"
//=[News & Enums & Stocks]===========================================================
stock Weapons[][32] =
{
	{"Unarmed (Fist)"},
	{"Brass Knuckles"},
	{"Golf Club"},
	{"Night Stick"},
	{"Knife"},
	{"Baseball Bat"},
	{"Shovel"},
	{"Pool Cue"},
	{"Katana"},
	{"Chainsaw"},
	{"Purple Dildo"},
	{"Big White Vibrator"},
	{"Medium White Vibrator"},
	{"Small White Vibrator"},
	{"Flowers"},
	{"Cane"},
	{"Grenade"},
	{"Teargas"},
	{"Molotov"},
	{" "},
	{" "},
	{" "},
	{"Colt 45"},
	{"Colt 45 (Silenced)"},
	{"Desert Eagle"},
	{"Normal Shotgun"},
	{"Sawnoff Shotgun"},
	{"Combat Shotgun"},
	{"Micro Uzi (Mac 10)"},
	{"MP5"},
	{"AK47"},
	{"M4"},
	{"Tec9"},
	{"Country Rifle"},
	{"Sniper Rifle"},
	{"Rocket Launcher"},
	{"Heat-Seeking Rocket Launcher"},
	{"Flamethrower"},
	{"Minigun"},
	{"Satchel Charge"},
	{"Detonator"},
	{"Spray Can"},
	{"Fire Extinguisher"},
	{"Camera"},
	{"Night Vision Goggles"},
	{"Infrared Vision Goggles"},
	{"Parachute"},
	{"Fake Pistol"}
};

public OnFilterScriptInit()
{
   new cstring[3][64];
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
   return 1;
}
public OnPlayerSpawn(playerid)
{
   GivePlayerWeapons(playerid);
   return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
	new string[128];
	if(isPlayerInAmmoSHOP(playerid))
	{
	    format(string, sizeof string, "-------- [ ( • /BW [1-%i] • ) | !ברוכים הבאים לחנות נשקים ] --------",dini_Int(cweapon, "Total"));
	    SendClientMessage(playerid, COLOR_WHITE, string);
	    SendClientMessage(playerid, 0x16EB43FF, ".ברוכים הבאים לחנות נשקים, פה תוכל לקנות נשקים תמידיים שימשרו לך גם לאחר שתמות");
	    format(string, sizeof string, " • /BuyWeapon(/Bw) [1-%i] - על מנת לקנות נשק", dini_Int(cweapon, "Total"));
	    SendClientMessage(playerid, COLOR_ORANGE, string);
	    SendClientMessage(playerid, COLOR_ORANGE, " • /WeaponList(/Wl) - על מנת לצפות ברשימת נשקים");
	    SendClientMessage(playerid, COLOR_WHITE, "--------------------------------------");
		return 1;
	}
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
   new cmd[256], idx, string[128];
   cmd = strtok(cmdtext, idx);
   if(!strcmp(cmd, "/kill", true)) return SetPlayerHealth(playerid, 0);
   if(!strcmp(cmd, "/weapons", true))
   {
       new wstring[2][128], found = 0, wps[256], id = -1;
       wps = strtok(cmdtext, idx);
       id = !strlen(wps)? playerid : strval(wps);
	   if(strlen(wps) > 0 && !IsPlayerConnected(id)) return SendClientMessage(playerid, red, ".שחקן זה לא מחובר");
       if(!dini_Exists(WeaponFile(id))) return SendClientMessage(playerid, red, (id) == (playerid)? (".אין לך נשקים תמידיים") : (".לשחקן זה אין נשקים תמידיים"));
       format(string, sizeof string, (id) == (playerid)? ("-------- [ %s's - רשימת הנשקים שלך ] --------") : ("-------- [ %s's - רשימת הנשקים של ] --------"), GetName(id));
	   SendClientMessage(playerid, COLOR_WHITE, string);
	   for(new i = 0; i < dini_Int(cweapon, "Total"); i++)
	   {
           format(wstring[0], 128, "weapon%i", i);
           format(wstring[1], 128, "ammo%i", i);
	       if(dini_Isset(WeaponFile(id), wstring[0]) && dini_Isset(WeaponFile(id), wstring[1]) && dini_Int(WeaponFile(id), wstring[0]) >= 1 && dini_Int(WeaponFile(id), wstring[1]) >= 1)
	       {
			    format(string, sizeof string, " • %i. Weapon: %s ( Weapon DN\"S: %i ) <~> Ammo: %d", ++found, Weapons[dini_Int(WeaponFile(id), wstring[0])], dini_Int(WeaponFile(id), wstring[1]));
			    SendClientMessage(playerid, random(2) == random(2)? darkblue : brown, string);
	       }
	   }
	   SendClientMessage(playerid, COLOR_WHITE, "--------------------------------------");
	   return 1;
   }
   if !strcmp(cmd, "/wl", true) || !strcmp(cmd, "/weaponlist", true) *then
   {
	 new string2[128], string3[128];
	 if !isPlayerInAmmoSHOP(playerid) *then return SendClientMessage(playerid, red, ".אתה לא נמצא באחת מחנויות הנשק הרישמיות");
	 if !dini_Int(cweapon, "Total") *then return SendClientMessage(playerid, red, ".האדמין עוד לא הוסיף נשקים לשרת, אם קיבלת הודעה זו התלונן בפורום");
	 format(string3, sizeof string3, "-------- [ (%i) - רשימת נשקים ] --------",dini_Int(cweapon, "Total"));
	 SendClientMessage(playerid, COLOR_WHITE, string3);
	 for(new i = 0; i < dini_Int(cweapon, "Total")+1; i++)
	 {
         format(string, sizeof string, "/Users/Weapons/Weapon%d.ini",i);
         format(string2, sizeof string2, "/Users/Weapons/Weapon%d.ini",i+1);
         if dini_Exists(string) *then
         {
		     format(string3, sizeof string3, dini_Exists(string) && !dini_Exists(string2) ? (" • (\"/bw %d\"), Weapon: %s, Ammo: %d, Cost: %d$") : (" • (\"/bw %d\"), Weapon: %s, Ammo: %d, Cost: %d$ | (\"/bw %d\"),  Weapon: %s, Ammo: %d, Cost: %d$"), i, dini_Get(string, "Weapon_Name"), dini_Int(string, "ammo"), dini_Int(string, "cost"), i+1, dini_Get(string2, "Weapon_Name"), dini_Int(string2, "ammo"), dini_Int(string2, "cost"));
		     SendClientMessage(playerid, random(2)+1? 0x16EB43FF : COLOR_ORANGE, string3);
		     if dini_Exists(string) && dini_Exists(string2) *then i++;
         }
	 }
	 SendClientMessage(playerid, COLOR_WHITE, "--------------------------------------");
     return 1;
   }
   if(!strcmp(cmd, "/dw", true) || !strcmp(cmd, "/dropweapon", true))
   {
      new wps[256];
      wps = strtok(cmdtext, idx);
   	  format(wstring[0], 128, "weapon%i", strval(wps));
	  format(wstring[1], 128, "ammo%i", strval(wps));
	  if(!isPlayerInAmmoSHOP(playerid)) return SendClientMessage(playerid, red, " .אתה לא נמצא באחת מחנויות הנשק הרישמיות");
      if(!strlen(wps))
	  {
	     SendClientMessage(playerid, COLOR_WHITE, " Usage: /dropweapon(/dw) [Weapon DN\"S]");
	     SendClientMessage(playerid, COLOR_WHITE, " /Weapons - של הנשק DN\"S - על מנת לגלות את ה");
	     return 1;
	  }
	  if(!dini_Isset(WeaponFile(playerid), wstring[0]) || dini_Int(WeaponFile(playerid), wstring[0]) <= 0) return SendClientMessage(playerid, red, ".אין לך את הנשק הזה");
	  format(string, sizeof string, " • !\"%s\" - זרקת את הנשק", Weapons[dini_Int(WeaponFile(playerid), wstring[0])]);
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
	  if !isPlayerInAmmoSHOP(playerid) *then return SendClientMessage(playerid, red, ".אתה לא נמצא באחת מחנויות הנשק הרישמיות");
	  if !dini_Int(cweapon, "Total") *then return SendClientMessage(playerid, red, ".האדמין עוד לא הוסיף נשקים לשרת, אם קיבלת הודעה זו התלונן בפורום");
	  if(!strlen(_vtmp))
	  {
		 (format(string, sizeof string, (" Usage: /bw [1-%d]") ,dini_Int(cweapon, "Total")),
		 SendClientMessage(playerid, COLOR_WHITE, string));
	     return 1;
	  }
	  if(!dini_Exists(string)) return SendClientMessage(playerid, red, ".נשק שגוי");
	  if(GetPlayerMoney(playerid) < dini_Int(string, "cost"))
	  {
		  format(string3, sizeof string3, " • !%d$ - עולה \"%s\" - הנשק", dini_Int(string, "cost"), dini_Get(string, "Weapon_Name"));
		  SendClientMessage(playerid, red, string);
		  format(string3, sizeof string3, " • !%d$ - על מנת לקנות נשק זה חסר לך", dini_Int(string, "cost") - GetPlayerMoney(playerid)); // Tested (my money: 7$, cost weapon: 12$) (Test: 7-12 = 5, 5 + = 7 = 12)
		  SendClientMessage(playerid, red, string);
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
  	  format(string3, sizeof string3, " • !בהצלחה \"%s\" - קנית את הנשק", dini_Get(string, "Weapon_Name"));
	  SendClientMessage(playerid, COLOR_ORANGE, string3);
	  format(string3, sizeof string3, " • !%i - מספר הכדורים שקנית לנשק", dini_Int(string, "Ammo"));
	  SendClientMessage(playerid, COLOR_ORANGE, string3);
  	  format(string3, sizeof string3, " • !%i - מספר הכדורים שיש לך בנשק זה", _ammo);
	  SendClientMessage(playerid, COLOR_ORANGE, string3);
	  GivePlayerMoney(playerid, -dini_Int(string, "cost"));
	  return 1;
   }
   if(!strcmp(cmd, "/cweapons", true) && IsPlayerAdmin(playerid))
   {
	  new _vtmp[256];
	  _vtmp = strtok(cmdtext, idx);
	  if(!strlen(_vtmp)) return SendClientMessage(playerid, COLOR_WHITE, " Usage: /cweapons [add/store]");
	  if(!strcmp(_vtmp, "add", true))
	  {
		  new _vtmp2[256], _vtmp3[256], _vtmp4[256], _vtmp5[256];
		  _vtmp2 = strtok(cmdtext, idx); _vtmp3 = strtok(cmdtext, idx);
		  _vtmp4 = strtok(cmdtext, idx); _vtmp5 = strtok(cmdtext, idx);
		  if(!strlen(_vtmp2) || !strlen(_vtmp3) || !strlen(_vtmp4) || !strlen(_vtmp5)) return SendClientMessage(playerid, COLOR_WHITE, " Usage: /cweapons add [weapon id] [ammo] [cost] [level]");
		  dini_IntSet(cweapon, "Total", dini_Int(cweapon, "Total") + 1);
          format(string, sizeof string, "/Users/Weapons/Weapon%d.ini",dini_Int(cweapon, "Total"));
          dini_Create(string);
          dini_IntSet(string, "id", strval(_vtmp2));
          dini_IntSet(string, "ammo", strval(_vtmp3));
          dini_IntSet(string, "cost", strval(_vtmp4));
          dini_IntSet(string, "level", strval(_vtmp5));
          dini_Set(string, "Weapon_Name", Weapons[strval(_vtmp2)]);
          format(string, sizeof string, " • You was created a new weapon(gun): ID: %i, Ammo: %i, Cost: %d$, Level: %d, Weapon: \"%s\"",strval(_vtmp2),strval(_vtmp3), strval(_vtmp4), strval(_vtmp5), Weapons[strval(_vtmp2)]);
          SendClientMessage(playerid, COLOR_ORANGE, string);
		  return 1;
	  }
	  if(!strcmp(_vtmp, "store", true))
	  {
		 new Float:pos[3];
		 if(dini_Int(cweapon,"CPS") == MAX_AMMO_SHOP) return SendClientMessage(playerid, red, "!אתה לא יכול להוסיף עוד חנויות נשקים");
		 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		 format(string, sizeof string, "CPX%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[0]);
  		 format(string, sizeof string, "CPY%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[1]);
  		 format(string, sizeof string, "CPZ%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[2]);
		 Ammo_SHOP[dini_Int(cweapon, "CPS")] = CPS_AddCheckpoint(pos[0], pos[1], pos[2], 2.5, 30);
		 dini_IntSet(cweapon, "CPS", dini_Int(cweapon, "CPS") + 1);
		 SendClientMessage(playerid, COLOR_ORANGE, ".הוספת חנות נשקים בהצלחה");
		 return 1;
	  }
	  return 1;
   }
   return 1;
}
