//=[Includes & Defines]===========================================================
#include "../DeathMatch/acf.pwn"
#define COLOR_WHITE 0xFFFFFFAA
#define red 0xFF0000AA
#define COLOR_ORANGE 0xFF9900AA
#pragma unused ret_memcpy
#define vehicle_insetsfile "/Insets/Vehicles/Main.txt"
#define pickup_insetsfile "/Insets/Pickups/Main.txt"
#define teleports_insetsfile "/Insets/Teleports/Main.txt"
#define teleports_lists "/Insets/Teleports/list.txt"
//=[News & Enums]===========================================================
new tele_words[100][MAX_STRING];
public OnFilterScriptInit()
{
	new string[128];
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
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
   new cmd[256], idx, string[256];
   cmd = strtok(cmdtext, idx);
   if(!strcmp(cmd, "/t", true) || !strcmp(cmd, "/tele", true) || !strcmp(cmd, "/teleports", true) || !strcmp(cmd, "/teleport", true))
   {
   		new next_line = 0, lines = 0;
		if !dini_Int(teleports_insetsfile, "Total") *then return SendClientMessage(playerid, red, ".אין שיגורים בשרת כרגע");
        format(string, sizeof string, "-------- [ Teleports - (%03d) - שיגורים ] --------", dini_Int(teleports_insetsfile, "Total"));
        SendClientMessage(playerid, COLOR_WHITE, string);
        cmd = " ";
		for(new i = 0; i < sizeof tele_words; i++)
		{
		    if (!strcmp(tele_words[i],"*EOF*",true)) continue;
   			format(string,sizeof string," • /%s",tele_words[i]); //  •
   			strcat(cmd, string);
			next_line++;
			if(next_line == 10)
			{
                 lines++;
				 SendClientMessage(playerid,COLOR_ORANGE, cmd);
				 string = " ", next_line = 0, cmd = " ";
			}
		}
		if (next_line >= 1) SendClientMessage(playerid,COLOR_ORANGE,cmd);
        SendClientMessage(playerid, COLOR_WHITE, "--------------------------------------------------");
        return 1;
   }
   format(string, sizeof string, "/Insets/Teleports/%s.ini", cmd);
   if(dini_Exists(string))
   {
	   createTeleport(playerid, dini_Int(string, "interior"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), dini_Int(string, "with_vehicle"), dini_Int(string, "level"), dini_Get(string, "cmd"));
	   return 1;
   }
   if(!strcmp(cmd, "/insets", true))
   {
	    new _a1[256], _a2[256], _a3[256], _a4[256], _a5[256], Float:opos[4], File:fp;
	    _a1 = strtok(cmdtext, idx);
	    if(!strlen(_a1)) return SendClientMessage(playerid,COLOR_WHITE, "Usage: /insets [create/destroy]");
	    if(!strcmp(_a1, "create", true))
	    {
             _a2 = strtok(cmdtext, idx);
             if(!strlen(_a2)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets create [pickup/vehicle/teleport]");
             if(!strcmp(_a2, "teleport", true))
             {
                 _a3 = strtok(cmdtext, idx);
                 _a4 = strtok(cmdtext, idx);
                 _a5 = strtok(cmdtext, idx);
				 GetPlayerPos(playerid, opos[0], opos[1], opos[2]);
				 GetPlayerFacingAngle(playerid, opos[3]);
                 if(!strlen(_a3) || !strlen(_a4) || !strlen(_a5)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets create teleport [command name] [with vehicle: 1 / 0] [level]");
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
				 format(string, sizeof string, " • /insets desroy teleport %s :יצרת שיגור חדש, צלם תמונה זו למקרה ביטחון, במקרה ואתה רוצה למחוק את השיגור",_a3);
			     SendClientMessage(playerid, COLOR_ORANGE, string);
			     LoadTeleportsList();
				 return 1;
			 }
             if(!strcmp(_a2, "vehicle", true))
             {
                 _a3 = strtok(cmdtext, idx);
                 if(!strlen(_a3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets create vehicle [term]");
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
			     format(string, sizeof string, " • /insets desroy vehicle %i :יצרת רכב תמידי חדש בשרת, אנא צלם תמונה זו בבקשה, אם תרצה למחוק את הרכב תמידי זה בצע",dini_Int(vehicle_insetsfile, "Total"));
			     SendClientMessage(playerid, COLOR_ORANGE, string);
			     return 1;
             }
 			 if(!strcmp(_a2, "pickup", true))
			 {
                _a3 = strtok(cmdtext, idx);
                _a4 = strtok(cmdtext, idx);
                _a5 = strtok(cmdtext, idx);
                if(!(strlen(_a3) || strlen(_a4) || strlen(_a5))) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets create pickup [pickupid] [type] [term]");
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
			    format(string, sizeof string, " • /insets desroy pickup %i :יצרת פיקאפ תמידי חדש בשרת, אנא צלם תמונה זו בבקשה, אם תרצה למחוק את הפיקאפ תמידי זה בצע",dini_Int(pickup_insetsfile, "Total"));
				SendClientMessage(playerid, COLOR_ORANGE, string);
				return 1;
			 }
             return 1;
	    }
	    if(!strcmp(_a1, "destroy", true))
	    {
		   _a2 = strtok(cmdtext, idx);
		   if(!strlen(_a2)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets desroy [pickup/vehicle/teleport]");
		   if(!strcmp(_a2, "teleport", true))
		   {
			 new bool:results = false;
			 _a3 = strtok(cmdtext, idx);
			 if(!strlen(_a3) || _a3[0] == '/') return SendClientMessage(playerid, !strlen(_a3) && _a3[0] != '/'? COLOR_WHITE : red, !strlen(_a3) && _a3[0] != '/'? ("Usage: /insets desroy teleport [tele name]") : (".אין צורך בשימוש ב - '/' אנא הוריד את זה מהפקודה"));
			 for (new i = 0; i < 100; i++)
			 {
		          if (!strcmp(tele_words[i],cmd,true))
				  {
				      memcpy(tele_words[i],"*EOF*",0, MAX_STRING);
				      results = true;
		          }
			 }
		     format(string,sizeof string,!results? (".\"%s\" - לא נמצא שיגור בשם") : (".\"%s\" - מחקת את השיגור") ,cmd);
		     SendClientMessage(playerid, COLOR_ORANGE, string);
		     SaveTeleportsList();
			 return 1;
		   }
		   if(!strcmp(_a2, "pickup", true))
		   {
			  _a3 = strtok(cmdtext, idx);
			  format(string, sizeof string, "/Insets/Pickups/%d.ini", strval(_a3));
			  if(!strlen(_a3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets desroy pickup [pickup-id]");
			  if(!dini_Exists(string)) return SendClientMessage(playerid, red, ".לא קיים פיקאפ כזה, אנא בדוק את האיידי שנית");
		      dini_Remove(string);
              format(string, sizeof string, "!%i :מחקת את הפיקאפ", strval(_a3));
		      SendClientMessage(playerid, COLOR_ORANGE, string);
			  return 1;
			}
		   if(!strcmp(_a2, "vehicle", true))
		   {
			  _a3 = strtok(cmdtext, idx);
			  format(string, sizeof string, "/Insets/Vehicles/%d.ini", strval(_a3));
			  if(!strlen(_a3)) return SendClientMessage(playerid, COLOR_WHITE, "Usage: /insets desroy vehicle [pickup-id]");
			  if(!dini_Exists(string)) return SendClientMessage(playerid, red, ".לא קיים רכב כזה, אנא בדוק את האיידי שנית");
		      dini_Remove(string);
              format(string, sizeof string, "!%i :מחקת את הרכב", strval(_a3));
		      SendClientMessage(playerid, COLOR_ORANGE, string);
			  return 1;
			}
		}
	    return 1;
   }
   return 1;
}
//createTeleport(playerid, dini_Int(string, "interior"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), dini_Int(string, "with_vehicle"), _a3);

stock createTeleport(playerid, interior, Float:x, Float:y, Float:z, Float:a, withvehicle, level, message[])
{
   new string[128];
   if(getPlayerLevel(playerid) < level)
   {
      format(string, sizeof string, "שיגור זה משמש שחקנים מרמה %i בלבד!", level);
      SendClientMessage(playerid, red, string);
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
   format(string, sizeof string, "!תהנה ,\"%s\" - ברוכים הבאים לאיזור ה", message);
   SendClientMessage(playerid, COLOR_ORANGE, string);
   format(string, sizeof string, "%s~y~~h~-[] ~g~~h~• ~r~~h~Welcome To~w~: ~b~~h~(%s) ~g~~h~•~y~~h~[] -", ("~n~~n~~n~~n~~n~"), message);
   GameTextForAll(string,5*1000, 3);
   return 1;
}
/*
stock showTeleports(playerid)
{
   new string[128], file[4][128];
   if !dini_Int(teleports_insetsfile, "Total") *then return SendClientMessage(playerid, red, ".אין שיגורים בשרת כרגע");
   format(string, sizeof string, "-------- [ Teleports - (%i) - שיגורים ] --------", dini_Int(teleports_insetsfile, "Total"));
   SendClientMessage(playerid, COLOR_WHITE, string);
   for(new t = 0; t < dini_Int(teleports_insetsfile, "Total") + 1; t++)
   {
        format(file[0], 128, "tele%i", t);
        format(file[1], 128, "tele%i", t+1);
	    format(file[2], 128, "/Insets/Teleports/%s.ini", dini_Get(teleports_insetsfile, file[0]));
	    format(file[3], 128, "/Insets/Teleports/%s.ini", dini_Get(teleports_insetsfile, file[1]));
        if(dini_Isset(teleports_insetsfile, file[0]))
        {
            format(string, sizeof string, dini_Isset(teleports_insetsfile, file[0]) && !dini_Isset(teleports_insetsfile, file[1])? (" • %s (Level: %i | Info: %s )") : (" • %s (Level: %i | Info: %s ), %s (Level: %i | Info: %s )"), dini_Get(teleports_insetsfile, file[0]), dini_Int(file[2], "level"), dini_Get(file[2], "info"), dini_Get(teleports_insetsfile, file[1]), dini_Int(file[3], "level"), dini_Get(file[3], "info"));
		    SendClientMessage(playerid, COLOR_ORANGE, string);
		    if(dini_Isset(teleports_insetsfile, file[1])) t++;
        }
   }
   SendClientMessage(playerid, COLOR_WHITE, "--------------------------------------------------");
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
