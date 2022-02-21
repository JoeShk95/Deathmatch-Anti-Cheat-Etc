#if defined scripting_included
	#endinput
#else
	#define scripting_included
#endif
//=[Includes & Defines]===========================================================
#include "a_samp.inc"
#tryinclude "cpstream"
#tryinclude "streamer"
#pragma unused ret_memcpy
#pragma unused strtok
#define function(%1) forward %1; public %1
#define MAX_WARNINGS 3
#define MAX_LEVEL 30
#define MAX_AMMO_SHOP 10
#define MAX_WORNGS_LOGIN 5
#pragma dynamic 145000
#define VIPColor sgba2hex(dini_Int("/VIP/Details.txt", "C1"),dini_Int("/VIP/Details.txt", "C2"),dini_Int("/VIP/Details.txt", "C3"),100)
#define clanCost 10000
#define MAX_MOVE_GATES 200
#define MAX_USERS_PER_PLAYER 2
///=[Insets & Informations]===========================================================
#define UseCallback(%1,%2) forward users_%1(%2); public users_%1(%2)
#define UseCallback_(%1) forward users_%1(); public users_%1()
#define function(%1) forward %1; public %1
#define _Callback(%1,%2) users_%1(%2)
#define PlayerInfo(%1) %1
#define adminCommand(%1,%2) if(!strcmp(%1,%2, true) && IsPlayerAdmin(playerid))
#define strreplace dini_strreplace
#define hash dini_hash
#tryinclude "dini.inc"
#undef hash
#undef strreplace
#define equal dini_equal
#undef equal
//Info Defines:
#define version "0.1b"
#define ventrilo "123.0.0:7777 (V3.0)"
#define lastupdate "1/1/2010"
#define forum "SA-MP.co.il"
#define namemode "LucifeR DeathMatch"
#define scripter "(IST)JoeShk"
#define hostservername "SA-MP.co.il - LucifeR DeathMatch"
//Files:
#define _rich "Rich.txt"
#define _fileusers "Users"
#define _filestats "Users/Stats"
#define _filebank "Users/Bank"
#define _filevehicle "Users/Vehicle"
#define _fileprivate "Users/Private/"
#define _fileips "Users/IPS/"
#define _fileconfig "/Users/Configs/"
#define _filetags "/Users/Tags/"
#define cweapon "/Users/Weapons/Main.txt"
#define cbank "/Users/Bank/Main.txt"
#define vehicle_insetsfile "/Insets/Vehicles/Main.txt"
#define pickup_insetsfile "/Insets/Pickups/Main.txt"
#define teleports_insetsfile "/Insets/Teleports/Main.txt"
#define teleports_lists "/Insets/Teleports/list.txt"
//Colors:
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_ORANGE 0xFF9900AA
#define pink 0xFF66FFAA
#define yellow 0xF6F658FF
#define green 0x00ed00ff
#define red 0xFF0000AA
#define white 0xffffffaa
#define npink 0xccff00ff
#define blue 0x5455ffff
#define grey 0xc0c0c0AA
#define lightblue 0x17E5F6FF
#define orange 0xFF9900AA
#define black 0x000000aa
#define darkblue 0x3399ffaa
#define purple 0x800080aa
#define brown 0xb15a00ff
#define new.private new
#define error(%1,%2) SendClientMessage(%1, red, %2)
new.private PlayerInfo(cOkdie[MAX_PLAYERS]),
            PlayerInfo(InVehicle2[MAX_PLAYERS]),
			PlayerInfo(InVehicle3[MAX_PLAYERS]);
new clanVehicles[MAX_VEHICLES], Ammo_SHOP[MAX_AMMO_SHOP], Bank_CP[10], Bank_Lock = 0, Float:spawn[3][MAX_PLAYERS], Text3D: Pickups3D[MAX_PICKUPS], Pickups[MAX_PICKUPS], Text:TDH[MAX_PLAYERS];
new Float:SAMP[][4] =
{
{-2564.538,1092.589,55.664,337.096},
{-2356.0573,995.4032,50.8984,182.0485},
{-1382.105224,-230.142044,14.148437,313.913299},
{-2396.605468,-617.606628,132.737396,36.312511},
{1867.630493,-1442.807006,13.540561,317.000457},
{-2128.956298,925.477416,79.966804,93.446701},
{2192.915283,1670.262939,12.367187,89.400100},
{366.690490,2557.363281,16.856082,181.276748},
{-2929.666992,453.267517,4.914062,270.580932},
{-2422.023437,286.051605,35.257869,71.032470},
{2495.416748,-1687.549682,13.516131,2.144218},
{-1508.722045,1019.904846,7.187500,179.759155},
{-1499.821166,715.792602,7.212387,89.336952},
{-1619.134155,681.706298,7.190120,89.963623},
{-1410.905273,456.152038,7.187500,1.245707},
{-2408.289794,-2175.717285,33.289062,270.799926},
{-1631.521606,-2239.001220,31.476562,91.180885},
{-90.911148,-1159.593139,2.067930,58.911594},
{-2246.060791,2284.073486,4.970916,359.469268},
{-2543.482177,1216.352905,37.421875,3.426709},
{-2650.885742,1361.723266,12.250000,179.712753},
{-2841.463378,1301.068481,7.101562,181.569442},
{-2899.006591,1063.880126,32.132812,266.714843},
{-2758.178955,376.006683,4.333554,271.460571},
{-2654.040527,206.110565,4.335937,0.469989},
{-2026.803344,156.846771,29.039062,269.686340},
{-1969.536743,159.899826,27.687500,180.095474},
{-1959.827880,293.920349,35.468750,90.191314},
{-2039.647705,-81.948585,35.320312,1.408744},
{-1828.319213,108.475776,15.117187,264.632873},
{-1710.443725,399.048828,7.187244,225.592437},
{-1617.258666,1286.358520,7.184526,85.461174},
{-2063.862304,1381.531005,7.100666,180.327468},
{-2476.466308,1266.988769,28.159187,271.818572},
{-2280.303710,1022.978637,83.932350,271.810791},
{-2269.722900,535.506103,35.015625,268.893798},
{-2212.083251,307.103424,35.117187,179.338928},
{-2286.310546,150.778594,35.312500,270.636749},
{-2656.270263,-278.185577,7.495392,43.365280},
{-2721.727050,-317.288574,7.843750,45.895351},
{708.769714,1926.467773,5.582498,358.166961},
{-2540.925537,-596.941040,132.710937,268.919036},
{-1995.975708,-859.088928,32.171875,94.306816},
{-2136.151855,-388.964965,35.343013,359.299926},
{-1421.252319,-514.835449,14.177608,203.312210},
{-3102.738037,477.210845,35.113548,269.079071},
{-2483.815429,1069.525390,55.766624,355.448913},
{-2407.970703,722.858520,38.273437,91.772735},
{-2445.706054,516.771789,30.108627,271.580230},
{-2571.287597,556.769042,14.460937,359.057678},
{-1658.594116,1207.322875,7.250000,19.374435},
{-2660.122802,878.268493,79.773796,2.053548},
{-2300.773437,1100.437500,79.993370,93.170181},
{-2314.582031,1064.930664,65.585937,85.336761},
{-2572.343017,1156.694091,63.390625,159.725082},
{-2800.076416,1184.888183,20.273437,128.795059},
{-2090.675537,2314.161621,25.914062,116.540672},
{-2387.207519,2446.915283,10.169355,159.660369},
{-2062.444824,1095.738037,55.614360,178.901611},
{-1699.265380,1351.616210,7.179687,135.997940},
{-2018.340576,952.518920,45.802761,269.142486},
{-2304.288574,1544.356811,18.773437,90.848190},
{-2646.972,1400.710,24.765,198.280}
};
new Float:DMPostion[][3] =
{
{2613.9866,	2848.4475,	19.9922}, {2647.6553,	2805.0278,	10.8203},
{2611.5500,	2845.7542,	16.7020}, {2545.9243,	2839.1824,	10.8203},
{2672.9387,	2800.3374,	10.8203}, {2672.8306,	2792.1057,	10.8203},
{2647.7834,	2697.5884,	19.3222}, {2654.5427,	2720.3474,	19.3222},
{2653.2063,	2738.2432,	19.3222}, {2685.8875,	2816.6575,	36.3222},
{2641.1350,	2703.2019,	25.8222}, {2599.1304,	2700.7249,	25.8222},
{2606.1384,	2721.5237,	25.8222}, {2597.3745,	2748.0884,	23.8222},
{2595.0657,	2776.6729,	23.8222}, {2601.3640,	2777.8101,	23.8222},
{2584.3940,	2825.1748,	27.8203}, {2631.8110,	2834.2593,	40.3281},
{2632.2852,	2834.9390,	122.9219}, {2646.1997,	2817.7070,	36.3222},
{2691.1233,	2787.7883,	59.0212}, {2717.8071,	2771.3464,	74.8281},
{2695.2622,	2699.5488,	22.9472}, {2688.8206,	2689.0039,	28.1563},
{2655.0229,	2650.6807,	36.9154}, {2570.4668,	2701.2876,	22.9507},
{2498.9915,	2704.6204,	10.9844}, {2524.1584,	2743.3735,	10.9917},
{2498.3167,	2782.3357,	10.8203}, {2504.5142,	2805.9763,	14.8222},
{2522.2144,	2814.7087,	24.9536}, {2510.6292,	2849.6384,	14.8222},
{2618.2646,	2720.8005,	36.5386}, {2690.9980,	2741.9060,	19.0722},
{2544.5032,	2805.8840,	19.9922}, {2556.2554,	2832.5313,	19.9922},
{2561.9175,	2848.5532,	19.9922}
};
stock fixed_strval(string[]) return strlen(string) < 49 ? strval(string) : 0;
#define strval fixed_strval
#define Cheates 8
enum AC
{
   Float:health,
   Float:armour,
   Float:vhealth,
   cash,
   Fakekill,
   bool:inVehicle,
   bool:_sWeapons[38],
   warnings[6]
};
enum Encryptmode
{
	en_ascci,
	en_byte,
	en_mix,
	en_long
};
new profile_item[MAX_PLAYERS] = {-1, ...};
new settings[][32] =
{
  "joinMsg",
  "quitMsg",
  "punishMsg",
  "pmMsg",
  "autoLogin",
  "textDraw",
  "replayFastPM"
};
new tmsg_Settings[][128] =
{
  " - !מעכשיו תראה הודעות כניסה של שחקנים שמתחברים",
  " - !מעכשיו תראה הודעות יציאה של שחקנים שמתנתקים",
  " - !מעכשיו תראה הודעות הענשה של שחקנים אחרים",
  " - !מעכשיו התיבת הודעות פרטיות שלך חסומה",
  " - !שלך IP - מעכשיו תתחבר לפי ה",
  " - !מעכשיו תראה את טקסט המוד",
  " - !מכשיו כל פעם שתקבל הודעה פרטית יופיע לך דיאלוג להשבה מהירה"
};
new fmsg_Settings[][128] =
{
  " - !מעכשיו לא תראה הודעות כניסה של שחקנים אחרים",
  " - !מעכשיו לא תראה הודעות כניסה של שחקנים אחרים",
  " - !מעכשיו לא תראה הודעות הענשה של שחקנים אחרים",
  " - !מעכשיו התיבה הודעות פרטיות שלך פתוחה",
  " - !שלך IP - מעכשיו לא תתחבר לפי ה",
  " - !מעכשיו לא תראה את טקסד המוד",
  " - !מעכשיו כל פעם שתקבל הודעה פרטית לא יופיע לך דיאלוג להשבה מהירה"
};
new profiles[][32] =
{
  "First Name",
  "Family Name",
  "E-mail",
  "Messenger",
  "ICQ",
  "City",
  "Brithday",
  "Age"
};
new profilesm[][128] =
{
  "--- !מערכת פרופיל: שינת בהצלחה את שמך הפרטי",
  "--- !מערכת פרופיל: שינת בהצלחה את שם משפחתך",
  "--- !מערכת פרופיל: שינת בהצלחה את הדוא\"ל האלקטרוני שלך",
  "--- !מערכת פרופיל: שינת בהצלחה את המנסג'ר שלך",
  "--- !מערכת פרופיל: שינת בהצלחה את כתובת האייסיקיו שלך",
  "--- !מערכת פרופיל: שינת בהצלחה את העיר שבה אתה גר",
  "--- !מערכת פרופיל: שינת בהצלחה את תאריך יום הולדתך"
};
#pragma unused fmsg_Settings
#pragma unused tmsg_Settings
#pragma unused profiles
#pragma unused profile_item
#pragma unused profilesm
#pragma unused Bank_Lock
stock AC_Info[MAX_PLAYERS][AC];
stock _SetPlayerHealth(playerid, Float:h)
{
   AC_Info[playerid][health] = h;
   SetPlayerHealth(playerid, h);
//   SetTDHealth(playerid);
   return 1;
}
stock _SetPlayerArmour(playerid, Float:a)
{
   AC_Info[playerid][armour] = a;
   SetPlayerArmour(playerid, a);
   return 1;
}
function(_GivePlayerMoney(playerid, money))
{
   if (money > 0)
   {
	   AC_Info[playerid][cash] += money;
	   GivePlayerMoney(playerid,money);
   }
   else
   {
	   GivePlayerMoney(playerid,money);
	   AC_Info[playerid][cash] -= money;
   }
   SetPlayerScore(playerid, AC_Info[playerid][cash]);
   dini_IntSet(getPlayerFile(playerid, _filebank), "TotalMoney", dini_Int(getPlayerFile(playerid, _filebank), "TotalMoney")+money);
   printf("%i %i", playerid, money);
   return 1;
}
function(_ResetPlayerMoney(playerid))
{
   ResetPlayerMoney(playerid);
   AC_Info[playerid][cash] = 0;
   return 1;
}
function(_GetPlayerMoney(playerid)) return AC_Info[playerid][cash];
stock _SetVehicleHealth(playerid, vehicleid, Float:h)
{
   AC_Info[playerid][vhealth] = h;
   SetVehicleHealth(vehicleid, h);
   return 1;
}
stock _GivePlayerWeapon(playerid, weaponid, ammo)
{
    AC_Info[playerid][_sWeapons][weaponid] = true;
    GivePlayerWeapon(playerid, weaponid, ammo);
	return 1;
}
stock _ResetPlayerWeapons(playerid)
{
   ResetPlayerWeapons(playerid);
   for(new i = 0; i < 38; i++) AC_Info[playerid][_sWeapons][i] = false;
   return 1;
}
stock _PutPlayerInVehicle(playerid, vehicleid, setid)
{
   PutPlayerInVehicle(playerid, vehicleid, setid);
   AC_Info[playerid][inVehicle] = true;
   PlayerInfo(InVehicle2[playerid]) = 1;
   PlayerInfo(InVehicle3[playerid]) = 0;
   return 1;
}
stock _RemovePlayerFromVehicle(playerid, vehicleid, setid)
{
   RemovePlayerFromVehicle(playerid);
   AC_Info[playerid][inVehicle] = false;
   return 1;
}
stock _color[] = {pink, yellow, green, red, white, npink, blue, grey, lightblue, orange, darkblue, purple, brown};
stock CreatePickup_(model, type, Float:X, Float:Y, Float:Z, virtualworld, count, text[] = "None", color = 0)
{
   if(strcmp(text, "None", true)) Pickups3D[count] = Create3DTextLabel(text, !color? red : color, X, Y, Z+0.5, 40.0, virtualworld, 0);
   Pickups[count] = CreatePickup(model, type, Float:X, Float:Y, Float:Z, virtualworld);
   return 1;
}
#define CreatePickup CreatePickup_
stock DestroyPickup_(pickup)
{
  DestroyPickup(Pickups[pickup]);
  Delete3DTextLabel(Pickups3D[pickup]);
  return 1;
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
stock GetPlayerID(const Name[])
{
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && !strcmp(Name, GetName(i), true)) return i;
	return INVALID_PLAYER_ID;
}
stock IsNumeric(string[])
{
  for (new i = 0, j = strlen(string); i < j; i++) if (string[i] > '9' || string[i] < '0') return 0;
  return 1;
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
stock GetIP(playerid)
{
   new n[24];
   GetPlayerIp(playerid, n, sizeof n);
   return n;
}
stock getPlayerFile(playerid, f[])
{
   new string[64];
   format(string, sizeof string, "/%s/%s.ini", f, GetName(playerid));
   return string;
}
stock getPlayerFile2(name[], f[])
{
   new string[64];
   format(string, sizeof string, "/%s/%s.ini", f, name);
   return string;
}
stock GetTimeAsString(m = ':', zeros = 0)
{
	new t[3], s[64];
	gettime(t[0],t[1],t[2]);
	format(s,sizeof s, zeros? ("%02d%c%02d") : ("%d%c%d"),t[0],m,t[1]);
	return s;
}
stock GetDateAsString(m = '/', zeros = 0)
{
	new d[3], s[64];
	getdate(d[0],d[1],d[2]);
	format(s,sizeof s, zeros? ("%02d%c%02d%c%02d") : ("%d%c%d%c%d"),d[2],m,d[1],m,d[0]);
	return s;
}
stock Clean(playerid) for(new i = 0; i < 100; i++) SendClientMessage(playerid,white,"\n");
stock SendHeader(playerid, text[])
{
	new string[256];
//	for(new i = 0; i < strlen(text); i++) if(text[i] >= 97 && text[i] <= 122) text[i] -= 32;
	format(string,sizeof string," --- %s ---", text);
	return SendClientMessage(playerid, white, string);
}
stock ActMessage(caption[], comman[] = "none" , msg1[] = "none", msg2[] = "none", msg3[] = "none")
{
	new string[256], rand = random(3);
	format(string, sizeof string, " [_______________ %s - משחק _______________]", caption);
	SendClientMessageToAll(white, string);
	if(strcmp(msg1, "none", false)) SendClientMessageToAll(rand? 0xF6F658FF : 0x16EB43FF, msg1);
	if(strcmp(msg2, "none", false)) SendClientMessageToAll(rand? 0xF6F658FF : 0x16EB43FF, msg2);
	if(strcmp(msg3, "none", false)) SendClientMessageToAll(rand? 0xF6F658FF : 0x16EB43FF, msg3);
	if(strcmp(comman, "none", false)) SendClientMessageToAll(rand? 0xF6F658FF : 0x16EB43FF, comman);
	SendClientMessageToAll(white, " ------------------------------------------------");
	return 1;
}
stock ReturnUser(text[])
{   // by Y_Less
	new pos = 0, userid = INVALID_PLAYER_ID, count = 0, name[MAX_PLAYER_NAME];
	while(text[pos] < 0x21)
	{
		if(!text[pos]) return INVALID_PLAYER_ID;
		pos++;
	}
	if(IsNumeric(text[pos]))
	{
		userid = strval(text[pos]);
		if(userid >= 0 && userid < MAX_PLAYERS)
		{
			if(!IsPlayerConnected(userid)) userid = INVALID_PLAYER_ID;
			else return userid;
		}
	}
	new len = strlen(text[pos]);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			GetPlayerName(i,name,sizeof name);
			if(!strcmp(name,text[pos],true,len))
			{
				if(len == strlen(name)) return i;
				else count++, userid = i;
			}
		}
	}
	if(count != 1) userid = INVALID_PLAYER_ID;
	return userid;
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
stock VIPFile(playerid)
{
  new string[256];
  format(string,sizeof string,"/VIP/%s.ini",GetName(playerid));
  return string;
}
stock isPlayerVIP(playerid)
{
  new string[256];
  format(string,sizeof string,"/VIP/%s.ini",GetName(playerid));
  return dini_Exists(string)? 1 : 0;
}
stock getOnlineVIP()
{
  new vicount = 0;
  for(new i = 0; i < MAX_PLAYERS; i++) if(isPlayerVIP(i) && IsPlayerConnected(i)) vicount++;
  return vicount;
}
stock SendVIPMessageToAll(color, const msg[])
{
   for(new i = 0; i < MAX_PLAYERS; i++) if(isPlayerVIP(i) && IsPlayerConnected(i)) SendClientMessage(i, color, msg);
   return 1;
}
stock getIntoVIPHQ()
{
  new vicount = 0;
  for(new i = 0; i < MAX_PLAYERS; i++) if(make_isPlayerInArea(i,dini_Float("/VIP/Main.txt", "x1"),dini_Float("/VIP/Main.txt", "y1"),dini_Float("/VIP/Main.txt", "x2"),dini_Float("/VIP/Main.txt", "y2")) && IsPlayerConnected(i)) vicount++;
  return vicount;
}
stock getVIPMemmbers()
{
   new vc = 0, string[256];
   for(new i = 0; i < dini_Int("/VIP/Main.txt", "Total") + 2; i++)
   {
	   format(string, sizeof string, "VIP%i", i);
	   if(strcmp(dini_Get("/VIP/Main.txt", string), "None", false)) vc++;
   }
   return vc;
}
stock WeaponFile(playerid)
{
  new string[256];
  format(string, sizeof string,"/Users/Weapons/Players/%s.ini", GetName(playerid));
  return string;
}
stock isPlayerInAmmoSHOP(playerid)
{
   new bool:results = false;
   for(new i = 0; i < dini_Int(cweapon, "CPS"); i++)
   {
	   if(CPS_IsPlayerInCheckpoint(playerid, Ammo_SHOP[i]))
	   {
           results = true;
           break;
	   }
   }
   return results;
}
stock isPlayerInBank(playerid)
{
   new bool:results = false;
   for(new i = 0; i < dini_Int(cbank, "CPS") + 2; i++)
   {
	   if(CPS_IsPlayerInCheckpoint(playerid, Bank_CP[i]))
	   {
           results = true;
           break;
	   }
   }
   return results;
}
function(GivePlayerWeapons(playerid))
{
   new string[2][256];
   if(dini_Exists(WeaponFile(playerid)))
   {
	   for(new i = 0; i < dini_Int(WeaponFile(playerid), "Total") + 1; i++)
	   {
           format(string[0], 128, "weapon%i", i);
		   format(string[1], 128, "ammo%i", i);
		   if(dini_Isset(WeaponFile(playerid), string[0]) && dini_Isset(WeaponFile(playerid), string[1]) && dini_Int(WeaponFile(playerid), string[0]) >= 1 && dini_Int(WeaponFile(playerid), string[1]) >= 1)
		       _GivePlayerWeapon(playerid, dini_Int(WeaponFile(playerid), string[0]), dini_Int(WeaponFile(playerid), string[1]));
	   }
   }
   return 1;
}
function(fakeKill(playerid, killerid))
{
	new Float:pos[3];
	if(!IsPlayerConnected(killerid)) return 1;
	GetPlayerPos(killerid, pos[0],pos[1],pos[2]);
    GetPlayerPos(playerid, spawn[0][playerid], spawn[1][playerid],spawn[2][playerid]);
	if(!PlayerToPoint(playerid, 80.0, pos[0], pos[1], pos[2]) && killerid != INVALID_PLAYER_ID)
	{
        dini_IntSet(getPlayerFile(killerid, _filestats), "Kills", dini_Int(getPlayerFile(killerid, _filestats), "Kills") - 1);
	    return AC_Info[playerid][warnings][4] == MAX_WARNINGS? AC_Warning(playerid, AC_Info[playerid][warnings][4], "Fakekill") : AC_Kick(playerid, "Fakekill");
	}
    for(new i = 0; i < sizeof SAMP; i++)
    {
	    if(IsPlayerConnected(killerid) && (SAMP[i][0] == spawn[0][playerid] && SAMP[i][1] == spawn[1][playerid] && SAMP[i][2] == spawn[2][playerid]) && killerid != INVALID_PLAYER_ID)
		{
           dini_IntSet(getPlayerFile(killerid, _filestats), "Kills", dini_Int(getPlayerFile(killerid, _filestats), "Kills") - 1);
		   return AC_Info[playerid][warnings][4] == MAX_WARNINGS? AC_Warning(playerid, AC_Info[playerid][warnings][4], "Fakekill") : AC_Kick(playerid, "Fakekill");
		}
    }
	return 1;
}
stock AC_Kick(playerid, reason[])
{
   new string[256];
   format(string, sizeof string, "[ACA Arrowhead] %s, got kicked from the server by using cheats (Reason: Cheat %s)", GetName(playerid), reason);
   msgSetting(playerid, 0x3399ffaa, string, 2, true);
   format(string, sizeof string, "[ACA Arrowhead] (%d/%d) %s :קיבלת אזהרה על שימוש בצ'יט ,%s", MAX_WARNINGS, MAX_WARNINGS, reason, GetName(playerid));
   SendClientMessage(playerid, 0xFF0000AA, string);
   for(new i = 0; i < 6; i++) AC_Info[playerid][warnings][i] = 0;
   Kick(playerid);
   return 1;
}
stock AC_Warning(playerid, &warningid, reason[])
{
   new string[256];
   format(string, sizeof string, "[ACA Arrowhead] (%d/%d) %s :קיבלת אזהרה על שימוש בצ'יט ,%s", ++warningid, MAX_WARNINGS, reason, GetName(playerid));
   SendClientMessage(playerid, 0xFF0000AA, string);
   return 1;
}
stock GetPlayerSpeed(playerid, Float:x, Float:y)
{
  new Float:x1,Float:y1,Float:z1, Float:tmpdis;
  GetPlayerPos(playerid,x1,y1,z1);
  tmpdis = floatsqroot(floatpower(floatabs(floatsub(x,x1)),2)+floatpower(floatabs(floatsub(y,y1)),2));
  return floatround(tmpdis);
}
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
stock VehiclesName[][] =
{
   "Landstalker",
   "Bravura",
   "Buffalo",
   "Linerunner",
   "Pereniel",
   "Sentinel",
   "Dumper",
   "Firetruck",
   "Trashmaster",
   "Stretch",
   "Manana",
   "Infernus",
   "Voodoo",
   "Pony",
   "Mule",
   "Cheetah",
   "Ambulance",
   "Leviathan",
   "Moonbeam",
   "Esperanto",
   "Taxi" ,
   "Washington",
   "Bobcat",
   "Mr Whoopee",
   "BF Injection",
   "Hunter Type: Halicopter",
   "Premier",
   "Enforcer",
   "Securicar",
   "Banshee",
   "Predator",
   "Bus",
   "Rhino",
   "Barracks",
   "Hotknife",
   "Trailer",
   "Previon",
   "Coach",
   "Cabbie",
   "Stallion",
   "Rumpo",
   "RC Bandit",
   "Romero",
   "Packer",
   "Monster Type: Truck",
   "Admiral",
   "Squalo",
   "Seasparrow",
   "Pizzaboy",
   "Tram",
   "Trailer",
   "Turismo",
   "Speeder",
   "Reefer",
   "Tropic",
   "Flatbed",
   "Yankee",
   "Caddy",
   "Solair",
   "Berkley's RC Van",
   "Skimmer",
   "PCJ-600",
   "Faggio",
   "Freeway",
   "RC Baron",
   "RC Raider",
   "Glendale",
   "Oceanic",
   "Sanchez",
   "Sparrow",
   "Patriot",
   "Quadbike",
   "Coastguard",
   "Dinghy",
   "Hermes",
   "Sabre",
   "Rustler",
   "ZR-350",
   "Walton",
   "Regina",
   "Comet",
   "BMX",
   "Burrito",
   "Camper",
   "Marquis",
   "Baggage",
   "Dozer",
   "Maverick",
   "News Chopper",
   "Rancher",
   "FBI Rancher",
   "Virgo",
   "Greenwood",
   "Jetmax",
   "Hotring",
   "Sandking",
   "Blista Compact",
   "Police Maverick",
   "Boxville",
   "Benson",
   "Mesa",
   "RC Goblin",
   "Hotring Racer",
   "Hotring Racer",
   "Bloodring Banger",
   "Rancher",
   "Super GT",
   "Elegant",
   "Journey",
   "Bike",
   "Mountain Bike",
   "Beagle",
   "Cropdust",
   "Stunt",
   "Tanker",
   "RoadTrain",
   "Nebula",
   "Majestic",
   "Buccaneer",
   "Shamal",
   "Hydra",
   "FCR-900",
   "NRG-500",
   "HPV1000",
   "Cement Truck",
   "Tow Truck",
   "Fortune",
   "Cadrona",
   "FBI Truck",
   "Willard",
   "Forklift",
   "Tractor",
   "Combine",
   "Feltzer",
   "Remington",
   "Slamvan",
   "Blade",
   "Freight",
   "Streak",
   "Vortex",
   "Vincent",
   "Bullet",
   "Clover",
   "Sadler",
   "Firetruck",
   "Hustler",
   "Intruder",
   "Primo",
   "Cargobob",
   "Tampa",
   "Sunrise",
   "Merit",
   "Utility",
   "Nevada",
   "Yosemite",
   "Windsor",
   "Monster Truck",
   "Monster Truck",
   "Uranus",
   "Jester",
   "Sultan",
   "Stratum",
   "Elegy",
   "Raindance",
   "RC Tiger",
   "Flash",
   "Tahoma",
   "Savanna",
   "Bandito",
   "Freight",
   "Trailer",
   "Kart",
   "Mower",
   "Duneride",
   "Sweeper",
   "Broadway",
   "Tornado",
   "AT-400",
   "DFT-30",
   "Huntley",
   "Stafford",
   "BF-400",
   "Newsvan",
   "Tug",
   "Trailer",
   "Emperor",
   "Wayfarer",
   "Euros",
   "Hotdog",
   "Club",
   "Trailer",
   "Trailer",
   "Andromada",
   "Dodo",
   "RC Cam",
   "Launch",
   "Police Car (LSPD)",
   "Police Car (SFPD)",
   "Police Car (LVPD)",
   "Police Ranger",
   "Picador",
   "S.W.A.T. Van",
   "Alpha",
   "Phoenix",
   "Glendale",
   "Sadler",
   "Luggage Trailer",
   "Luggage Trailer",
   "Stair Trailer",
   "Boxville",
   "Farm Plow",
   "Utility Trailer"
};
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
   if(strfind(text, "212.150.123.200", true) != -1) return false;
   count_true = 0;
   for(i = 0; i < sizeof censorip; i++) if(strfind(text,censorip[i], true) != -1) count_true++;
   return count_true > 2? true : false;
}
stock Encrypt(string[],len,key,Encryptmode: mode = en_ascci)
{
    new EN[64];
	if(!len) return EN;
    for(new i = 0; i < len; i++) EN[i] = string[i];
 	if(mode == en_ascci) for(new i = 0; i < len; i++) EN[i] += key;
	if(mode == en_byte) for(new i = 0; i < len; i++) EN[i] += (i << key);
	if(mode == en_mix) for(new i = 0; i < len; i++) EN[i] += ((i << key) + i);
	return EN;
}
stock Decrypt(string[],len,key,Encryptmode: mode = en_ascci)
{
    new EN[256];
	if(!len) return EN;
    for(new i; i < len; i++) EN[i] = string[i];
 	if(mode == en_ascci) for(new i = 0; i < len; i++) EN[i] -= key;
	if(mode == en_byte) for(new i = 0; i < len; i++) EN[i] -= (i << key);
	if(mode == en_mix) for(new i = 0; i < len; i++) EN[i] -= ((i << key) + i);
	return EN;
}
stock halt(seconds)
{
	new NewTime[4], OldTime[4];
	gettime(OldTime[0], OldTime[1], OldTime[2]);
	OldTime[3] = OldTime[2] + (OldTime[1] * 60) + (OldTime[0] * 600);
	while (NewTime[3] != (OldTime[3] + seconds))
	{
		gettime(NewTime[0], NewTime[1], NewTime[2]);
		NewTime[3] = NewTime[2] + (NewTime[1] * 60) + (NewTime[0] * 600);
	}
}
stock SendClientMessageToAdmins(color, text[])
{
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerAdmin(i)) SendClientMessage(i, color, text);
   return 1;
}
stock strrest(const string[], index)
{
	new length = strlen(string), offset = index, result[256];
	while((index < length) && ((index - offset) < (sizeof result - 1)) && (string[index] > '\r')) result[index - offset] = string[index], index++;
	result[index - offset] = EOS;
	if(result[0] == ' ' && string[0] != ' ') strdel(result,0,1);
	return result;
}
stock stradd(string[],addstr[],pos)
{
	new firststr[256], endstr[256], retstr[256];
	strmid(firststr,string,0,pos-1);
	strmid(endstr,string,pos+1,strlen(string));
	format(retstr,sizeof retstr,"%s%s%s",firststr,addstr,endstr);
	return retstr;
}
stock strmul(string[],times)
{
	new returned[256];
	for(new i = 0; i < times; i++) format(returned, sizeof returned,"%s%s",returned,string);
	return returned;
}
stock strcount(string[],find[])
{
	new p = 0, count = 0;
	while(strfind(string,find,true,p) != -1) count++, p = p = strfind(string,find,true,p);
	return count;
}
stock strreplace(string[],str1[],str2[])
{
	new p = strfind(string,str1), sStart[256], sEnd[256], strtoset[256];
	if(p == -1) return 0;
	strmid(sStart,string,0,p - 1);
	strmid(sEnd,string,p + strlen(str1),strlen(string));
	format(strtoset,sizeof strtoset,"%s%s%s",sStart,str2,sEnd);
	strset(string,strtoset);
	return 1;
}
stock strreplaceall(string[],str1[],str2[])
{
	new returned[256];
	for(new i = 0, c = strcount(string,str1); i < c; i++) strreplace(string,str1,str2);
	return returned;
}
stock strset(string[],setto[])
{
	new c = strlen(string);
	for(new i = 0; i < c; i++) setto[i] = string[i];
	setto[c] = 0;
	return 1;
}
stock firstchars(string[], len)
{
	new first[256];
	strmid(first,string,0,len,255);
	return first;
}
stock PropertyExists(name[]) return existproperty(0,"",hash(name));
stock GetProperty(name[])
{
	new getAs[256];
	getproperty(0,"",hash(name),getAs);
	strunpack(getAs,getAs);
	return getAs;
}
stock SetProperty(name[],value[]) return setproperty(0,"",hash(name),value);
stock RemoveProperty(name[]) return deleteproperty(0,"",hash(name));
stock hash(string[])
{   // by DracoBlue, improved by Amit_B
	new s[2] = {1,0};
	for(new i = 0, j = strlen(string); i < j; i++) s[0] = (s[0] + string[i]) % 65521, s[1] = (s[1] + s[0]) % 65521;
	return (s[1] << 16) + s[0];
}
stock msgSetting(playerid, color, msg[], item, v)
{
   new string[128];
   for(new i = 0; i < MAX_PLAYERS; i++)
   {
       format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(i));
       if(i != playerid && dini_Bool(string, settings[item]) == v)
       {
          format(string, sizeof string, msg, GetName(playerid));
          SendClientMessage(i, color, string);
       }
   }
   return 1;
}
function(Kick_(playerid)) Kick(playerid);
stock _equal(str1[],str2[]) return !strcmp(str1,str2,true) && strlen(str1) == strlen(str2);
stock setMaxPlayersOnline()
{
   new string[128];
   if(GetOnlinePlayers() > dini_Int(_fileconfig "Main.ini", "MaxOnlinePlayers"))
   {
	  dini_IntSet(_fileconfig "Main.ini", "MaxOnlinePlayers", GetOnlinePlayers());
	  format(string, sizeof string, " - %03i :שיא חדש של אנשים מחוברים בו זמנית", dini_Int(_fileconfig "Main.ini", "MaxOnlinePlayers"));
	  SendClientMessageToAll(darkblue, string);
	  format(string, sizeof string, "~r~Players~w~:~b~~h~ %03i", dini_Int(_fileconfig "Main.ini", "MaxOnlinePlayers"));
	  GameTextForAll(string, 2000, 6);
	  return 1;
   }
   return 1;
}
stock GetOnlinePlayers()
{
   new count = 0;
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) count++;
   return count;
}
stock modeLine(playerid, text[], line=1)
{
   new string[128];
   format(string, sizeof string, "» [%i] %s", line, text);
   SendClientMessage(playerid, white, string);
   return 1;
}
stock featureModeIn(playerid, caption[], cline[] = "None", cinfo[] = "None", line1[] = "None", line2[] = "None", line3[] = "None", line4[] = "None", line5[] = "None", line6[] = "None", line7[] = "None", line8[] = "None", res[]= "None")
{
   new string[128];
   format(string, sizeof string, " -- -- -- -- -- -- -- -- Feature Mode (%s) -- -- -- -- -- -- -- --", caption);
   SendClientMessage(playerid, white, string);
   if(strcmp(line1, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line1);
   if(strcmp(line2, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line2);
   if(strcmp(line3, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line3);
   if(strcmp(line4, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line4);
   if(strcmp(line5, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line5);
   if(strcmp(line6, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line6);
   if(strcmp(line7, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line7);
   if(strcmp(line8, "None", false)) SendClientMessage(playerid, sgba2hex(221,27,34,230), line8);
   if(strcmp(cline, "None", false)) SendClientMessage(playerid, sgba2hex(102,175,14,230), cline);
   if(strcmp(cinfo, "None", false)) SendClientMessage(playerid, 0xFFFF00AA, cinfo);
   if(strcmp(res, "None", false)) SendClientMessage(playerid, red, res);
   SendClientMessage(playerid, white, " -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --");
   return 1;
}
stock equal_Mode(_cmd[], _cmd2[], _cmd3[], count=1) return !strcmp(_cmd, _cmd2, true) || !strcmp(_cmd, _cmd3, true) || strval(_cmd) == count;
stock validICQ(text[])
{
   if(strlen(text) < 5 || strlen(text) > 9 || text[0] == '0') return 0;
   for(new i = 0; i < strlen(text); ++i)
   {
       switch(text[i])
       {
           case '0' .. '9': { }
		   default: return 0;
       }
   }
   return 1;
}
stock isEnglish(text[])
{
   for(new i = 0; i < strlen(text); ++i)
   {
       switch(text[i])
       {
           case 'a' .. 'z': { }
           case 'A' .. 'Z': { }
		   default: return 1;
       }
   }
   return 0;
}
stock Brithday(text[])
{
   new year, month, day, DateInfo[3][20];
   getdate(year, month, day);
   _split(text, DateInfo, '/');
   if(year - strval(DateInfo[2]) > 100 || strval(DateInfo[2]) < 1 || strval(DateInfo[2]) >= year)
   return 0;
   new check = year - strval(DateInfo[2]);
   if(check == year) return 0;
   if(strval(DateInfo[1]) > month) check -= 1;
   else if(strval(DateInfo[1]) == month && strval(DateInfo[0]) > day) check -= 1;
   return check;
}
stock CreateTeleportEx(Float:x, Float:y, Float:z, Float:a, cmd[], cmd2[], withvehicle, level, interior, stpo)
{
   new File:fp, string[128];
   format(string, sizeof string, "/Insets/Teleports/%s.ini", cmd);
   if(!dini_Exists(string))
   {
     dini_IntSet(teleports_insetsfile, "Total", dini_Int(teleports_insetsfile, "Total")+1);
     dini_Create(string);
     dini_FloatSet(string, "x", x);
     dini_FloatSet(string, "y", y);
     dini_FloatSet(string, "z", z);
     dini_FloatSet(string, "angle", a);
     dini_Set(string, "cmd", cmd);
     dini_Set(string, "cmd2", cmd2);
     dini_Set(string, "Creater", "Automatic");
     dini_IntSet(string, "with_vehicle", withvehicle);
     dini_IntSet(string, "stpo", stpo);
     dini_IntSet(string, "level", level);
     dini_IntSet(string, "interior", interior);
     format(string, sizeof string, "tele%i", dini_Int(teleports_insetsfile, "Total"));
     dini_Set(teleports_insetsfile, string, cmd);
     format(string, sizeof string, "%s(%i)", cmd, level);
     fp = fopen(teleports_lists,io_append);
     fwrite(fp, string);
     fwrite(fp,"\n");
     fclose(fp);
     LoadTeleportsList();
	 return 1;
   }
   return 1;
}
stock Kill(playerid)
{
  PlayerInfo(cOkdie[playerid]) = 1;
  _SetPlayerHealth(playerid, 0.0);
  return 1;
}
stock fileCopy(from[], to[])
{
   if(!dini_Exists(to)) dini_Create(to);
   if(dini_Exists(from) && dini_Exists(to)) fcopytextfile(from, to);
   if(dini_Exists(from)) dini_Remove(from);
   return 1;
}
stock SetTDHealth(playerid)
{
   new string[128], color;
   if(AC_Info[playerid][health] > 55.0) color = green;
   if(AC_Info[playerid][health] < 55.0 && AC_Info[playerid][health] > 30.0) color = grey;
   if(AC_Info[playerid][health] < 30.0) color = red;
   format(string, sizeof string, !AC_Info[playerid][health]? ("dead") : ("%.1f%s"), AC_Info[playerid][health], "%");
   TextDrawSetString(TDH[playerid], string);
   TextDrawColor(TDH[playerid], color);
   TextDrawHideForPlayer(playerid, TDH[playerid]);
   TextDrawShowForPlayer(playerid, TDH[playerid]);
   return 1;
}
stock curNick(const nick[])
{
	if(strlen(nick) > 20 || strlen(nick) < 3) return false;
	for(new i = 0; i < strlen(nick); ++i)
	{
		switch(nick[i])
		{
			case 'A' .. 'Z': { }
			case 'a' .. 'z': { }
			case '0' .. '9': { }
			case '[', ']', '_', '.', '$', '(', ')': { }
			default: return false;
		}
	}
	return true;
}
stock isBike(vehicleid)
{
    new result, model = GetVehicleModel(vehicleid);
    switch(model)
    {
        case 509, 481, 510, 462, 448, 581, 522, 461, 521, 523, 463, 586, 468, 471: result = model;
        default: result = 0;
    }
	return result;
}
stock resetAC(playerid) for(new i = 0; i < Cheates; i++) AC_Info[playerid][warnings][i] = 0;
stock KickEx(playerid) return !IsPlayerAdmin(playerid)? Kick(playerid) : 1;
stock InArea(playerid, Float:max_x, Float:min_x, Float:max_y, Float:min_y)
{
    new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	return (X <= max_x && X >= min_x && Y <= max_y && Y >= min_y)? 1 : 0;
}
stock PlaySoundForPlayer(playerid, soundid)
{
	new Float:pX, Float:pY, Float:pZ;
	GetPlayerPos(playerid, pX, pY, pZ);
	PlayerPlaySound(playerid, soundid,pX, pY, pZ);
}
#define Kick KickEx
