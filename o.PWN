/*
	* JoeShk DeathMatch Beta #1
	* © Copyright 2009, Roye Omer & Amit Barami (`JoeShk & Amit_B`), Israel SA-MP Team
	* San Andreas Multiplayer 0.3
	* Creation Date: 18.12.2009
*/
#include "../DeathMatch/functions.pwn"
#define richisland 1000000
#define MAX_GLASS_PLAYERS 30
#define SPAO{%0,%1,%2,%3,%4,%5} SetPlayerAttachedObject(playerid, 0, 18645, 2, (%0), (%1), (%2), (%3), (%4), (%5));
#define createCommand(%1) if(!strcmp(cmd,%1,true))
#define WLCheck(%1) if(GetPlayerWantedLevel(playerid) >= %1) TextDrawShowForPlayer(playerid, tStar%1); else TextDrawHideForPlayer(playerid, tStar%1)
//=[News & Enums]===========================================================
new mainPickups = 0,
    Text: TDrawPlayers[MAX_PLAYERS],
    vehicleCallBug[MAX_PLAYERS],
	Text: Stunts[2][MAX_PLAYERS],
	count_vehicles = 1,
	Stimers[MAX_PLAYERS][4],
	StuntsBugs[MAX_PLAYERS],
	intoVehicle[256] = "None",
	Gate_Castle[8],
	castle_pickup[2],
	Castle_Kills[MAX_PLAYERS],
	Text:tStar7,
	Text:tStar8,
	Text:tStar9,
	Text:tStar10,
	Text:tStar11,
	Text:tStar12,
	Text:tStar13,
	Text:tStar14,
	Text:tStar15,
	bool:gme;

// Users :
new.private PlayerInfo(logged[MAX_PLAYERS]) = {false, ...},
    PlayerInfo(worngPassword[MAX_PLAYERS]) = {MAX_WORNGS_LOGIN, ...},
	PlayerInfo(bool:isafk[MAX_PLAYERS]) = {false, ...},
	PlayerInfo(mints[MAX_PLAYERS]) = {0, ...},
	PlayerInfo(onClick[MAX_PLAYERS]) = {-1, ...},
	PlayerInfo(onClick2[MAX_PLAYERS]) = {-1, ...},
	PlayerInfo(Float:vspeed[MAX_PLAYERS][2]),
	PlayerInfo(firsts[MAX_PLAYERS]),
	PlayerInfo(spaming[MAX_PLAYERS][3]),
	PlayerInfo(MoneyStunts[MAX_PLAYERS]),
	PlayerInfo(god[MAX_PLAYERS]),
	PlayerInfo(inDM[MAX_PLAYERS]);
enum PInfo
{
   CarID,
   OwnCar
}
enum VehInfo
{
   CarID,
   CarName[30],
   CarModel,
   CarOwned,
   CarOwner[MAX_PLAYER_NAME],
   PayTax,
   MoneyTax,
   Buyable,
   Price,
   LevelCar,
   SaleV

};
enum RentCars
{
   CarID,
   Float:vPosv[4]
}
new Vehicle_Info[MAX_VEHICLES][PInfo],
    VehicleInfo[MAX_VEHICLES][VehInfo],
	rent_file[128],
	RentInfo[MAX_PLAYERS][RentCars],
    CarToRent[MAX_VEHICLES],
    PriceRentVehicle[MAX_VEHICLES],
    VLocked[MAX_VEHICLES],
	VehicleName[MAX_VEHICLES][128],
	Vunoccupied[MAX_VEHICLES],
	Float:Pos[MAX_PLAYERS][4], Float:vPos[MAX_PLAYERS][4],
	Text3D: Text3DVehicle[MAX_VEHICLES], Text3D: ShowInfoPlayers[MAX_PLAYERS];
	static xvehicles = 0, VCount = 0, CreateCount = 0, count_v = 1;
	new	boat[11][0] =
	{
       {472}, {473}, {493}, {595}, {484}, {430}, {453}, {539}, {452}, {446}, {454}
    };
	new	bike[14][0] =
	{
       {581}, {521}, {462}, {463}, {468}, {471}, {586}, {522}, {523}, {461}, {448},
       {509}, {481},{510}
    };
    new	plane[10][0] =
	{
       {512}, {513}, {460}, {464}, {465}, {519}, {511}, {553}, {592}, {577}
    };
	new expensive[18][0] =
	{
       {476}, {433}, {541}, {486}, {495}, {506}, {451}, {477}, {406}, {444}, {573},
       {449}, {537}, {558}, {587}, {407}, {528}, {529}
    };
    new Vexpensive[4][0] =
	{
       {432}, {425}, {520}, {447}
    };
	new VehicleParameter[][126] =
{
  "Buy - על מנת לקנות את הרכב שאתה נמצא בו",
  "Sell - על מנת למכור את הרכב שלך",
  "Call - על מנת לזמן את הרכב למקום בו אתה נמצא",
  "Reset - על מנת לאפס את הרכב שלך במידה והוא לא מגיע אליך",
  "Info - פרטים על הרכב בו אתה נמצא",
  "Tax - תשלום אגרת רכב על הרכב בבעלותך",
  "Start Sale - על מנת להציע את הרכב שלך לציבור בתמורה לסכום שתבחר",
  "Stop Sale - על מנת לעצור את מכירת הרכב שלך לציבור"
};
new var_Levels[] =
{
  150,
  300,
  450,
  750,
  950,
  1150,
  1300,
  1500,
  1700,
  1900,
  2100,
  2300,
  2400,
  2700,
  3000,
  3300,
  3500,
  3700,
  4000,
  4500,
  5000,
  5500,
  6000,
  10000
};
new var_Tags[][32] =
{
  "Garfield",
  "Peter Pan",
  "Shrek",
  "Avatar",
  "Matrix",
  "Hitman",
  "Robotrics",
  "Popeye the Sailor",
  "Tomb Raider",
  "Hercules",
  "Lion King",
  "Flying Dutchman",
  "The Incredible Hulk",
  "Iron Giant",
  "Super Narnia",
  "Sparta Fighter",
  "Dragon",
  "SpiderMan",
  "Iron Man",
  "Batman",
  "Superman",
  "Zoro",
  "The God Father",
  "LucifeR"
};
new Float:glass_postion[][3] =
{
   {1609.4617,530.5741,51.7348},
   {1606.7246,531.4717,51.7470},
   {1606.7246,531.4717,51.7470},
   {1605.0629,533.5165,51.7292},
   {1600.8646,533.6453,51.7322},
   {1596.3163,534.2724,51.7391},
   {1590.7118,535.8163,51.7463},
   {1589.4604,538.4800,51.7312},
   {1610.2494,523.8151,51.7324},
   {1602.7313,536.5044,51.7341},
   {1601.2214,537.4821,51.7497},
   {1597.5162,531.6644,51.7373},
   {1594.6808,527.6122,51.7311},
   {1588.2012,522.4496,51.7314},
   {1588.1393,541.1797,51.7379},
   {1605.9272,543.7529,51.9687},
   {1607.5095,533.9383,51.7363},
   {1599.3185,530.5872,51.7382},
   {1596.9194,532.9460,51.7353},
   {1592.9929,530.9703,51.7388},
   {1590.5796,526.3690,51.7304},
   {1591.7485,522.9672,51.7422},
   {1596.8494,524.3049,51.7460},
   {1596.8889,524.3182,51.7461},
   {1601.2532,526.5195,51.7285},
   {1603.7819,529.5235,51.7317},
   {1608.2523,539.9830,51.7268},
   {1604.0223,540.5998,51.7317},
   {1600.1053,540.3953,51.7355},
   {1593.2867,539.7971,51.7314}
};
new.private PlayerInfo(InGlass[MAX_PLAYERS]), PlayerInfo(inAct[MAX_PLAYERS]),
    glass_object[21],
    rand_glass,
	Float:object_positon[3],
	Float:save_rot[4],
	GlassPlayers = 0,
	GlassTotal = 0,
	Glass_On = 0,
	count_glass = 0,
	actgTimer = 0,
	is_fall_glass[21] = {0, ...};
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
stock GateInfo[MAX_MOVE_GATES][moveGates], pGateInfo[MAX_PLAYERS][pmoveGates];
main() print("LucifeR DeathMatch by JoeShk loaded");
function(OnGameModeExit())
{
	new a[][10] =
	{ "?","?","?"};
	#pragma unused a
	SaveFiles();
}
function(OnGameModeInit())
{
   new string[128], string2[128], cstring[3][64], a[][10] = { "?","!","?"}, variable[2][128];
   variable[0] = GetDateAsString('/', 1), variable[1] = GetTimeAsString(':', 1);
   SetGameModeText(namemode " " version);
   SendRconCommand("hostname " hostservername);
   UsePlayerPedAnims();
//  ShowPlayerMarkers(1);
//   ShowNameTags(1);
   SetTimer("noticeTax", 13*60*1000, true);
   SetTimer("getInVehicle", 45*60*1000, true);
   //=[Objects]=======================================
   // Pickups :
   CreatePickup(1582, 2, -2564.538+3.0,1092.589-2.0,55.664, 0, mainPickups++, "Pizza Box", 0);
   // Vehicles :
   AddRentVehicles();
   G_Vehicles();
//   for(new i = 0; i < 10; i++) AddStaticVehicle_(522,-2272.0798+2.0*i,2306.4705,4.3913,269.6809,0,0);
   // Teleports :
   CreateTeleportEx(1066.05, 1319.98, 247.50,269.6809, "Stunts Zone (0.3c!) [Stunts Points: 30]", 1, 1, 0, 30);
   // Classes :
   for(new i = 0; i <= 288; i++) if(!isSkinCrash(i)) AddPlayerClass(i, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
   // Clan :
   // Text Draw :
/*   TDraw[1] = TextDrawCreate(587, 40, forum); // 325, 235
   TextDrawAlignment(TDraw[1],2);
   TextDrawFont(TDraw[1],3);
   TextDrawLetterSize(TDraw[1],0.455555,1.000000); // 99999
   TextDrawColor(TDraw[1],0x00FFFFAA);
   TextDrawSetOutline(TDraw[1],2);
   TextDrawSetProportional(TDraw[1],1);
   TextDrawSetShadow(TDraw[1],1);
   // td main 2
   TDraw[0] = TextDrawCreate(250, 433 , "Suggestions~w~: ~w~~h~/~y~~h~Mode~w~, ~w~~h~/~g~~h~Help~w~, ~w~~h~/~p~~h~Editprofile~w~, ~w~~h~/~r~Setting~w~(~w~~h~/~r~set~w~)");
   TextDrawAlignment(TDraw[0],2);
   TextDrawFont(TDraw[0],3);
   TextDrawLetterSize(TDraw[0],0.455555,1.000000); // 99999
   TextDrawColor(TDraw[0],0x00FFFFAA);
   TextDrawSetOutline(TDraw[0],2);
   TextDrawSetProportional(TDraw[0],1);
   TextDrawSetShadow(TDraw[0],1);*/

//      TextDrawUseBox(TDrawPlayers[playerid],1);
//      TextDrawBoxColor(TDrawPlayers[playerid], sgba2hex(0,0,0, 240));

   //
/*   TDraw[1] = TextDrawCreate(1.00000,410.000000, "  " hostservername);
   TextDrawAlignment(TDraw[1],1);
   TextDrawBackgroundColor(TDraw[1],0x00000066);
   TextDrawColor(TDraw[1],0x00000066);
   TextDrawFont(TDraw[1],1);
   TextDrawLetterSize(TDraw[1],0.6,1);*/
   //
   // Timers :
   //SetTimer("maintd", 5*60*1000, true);
   // Files :
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
   if(dini_Int("/Clans/HQ/Objects/Main.ini", "Total") != 0) for(new i = 0; i < dini_Int("/Clans/HQ/Objects/Main.ini", "Total"); i++)
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
       clanBanks[dini_Int(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "HQ_Count")] = CPS_AddCheckpoint(dini_Float(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "BX"), dini_Float(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "BY"), dini_Float(HQ_ClanFile(dini_Get("/Clans/HQ/Objects/Main.ini", string)), "BZ"), 2.5, 30);
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
   if(dini_Float("/VIP/Main.txt", "B1") != 0.0 && dini_Float("/VIP/Main.txt", "B2") != 0.0 && dini_Float("/VIP/Main.txt", "B3") != 0.0)
   {
       VIPBank = CPS_AddCheckpoint(dini_Float("/VIP/Main.txt", "B1"),dini_Float("/VIP/Main.txt", "B2"),dini_Float("/VIP/Main.txt", "B3"), 2.5, 20);
       Create3DTextLabel("!VIP - ברוכים הבאים לבנק ה", pink, dini_Float("/VIP/Main.txt", "B1"),dini_Float("/VIP/Main.txt", "B2"),dini_Float("/VIP/Main.txt", "B3")+0.20, 40.0, 0, 0);
   }
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
	  Create3DTextLabel("!ברוכים הבאים לחנות נשקים", yellow, dini_Float(cweapon, cstring[0]), dini_Float(cweapon, cstring[1]), dini_Float(cweapon, cstring[2])+0.20, 60.0, 0, 0);
   }
   // Bank :
   if(!dini_Exists(cbank))
   {
	   dini_Create(cbank);
	   dini_IntSet(cbank, "CPS", 0);
   }
   for(new i = 0; i < dini_Int(cbank, "CPS"); i++)
   {
	  format(cstring[0], 64, "CPX%i", i);
	  format(cstring[1], 64, "CPY%i", i);
	  format(cstring[2], 64, "CPZ%i", i);
	  Bank_CP[i] = CPS_AddCheckpoint(dini_Float(cbank, cstring[0]), dini_Float(cbank, cstring[1]), dini_Float(cbank, cstring[2]), 2.5, 30);
	  Create3DTextLabel("!ברוכים הבאים לבנק", green, dini_Float(cbank, cstring[0]), dini_Float(cbank, cstring[1]), dini_Float(cbank, cstring[2])+0.20, 60.0, 0, 0);
   }
   // Rich Island
   if(!dini_Exists(_rich))
   {
	  dini_Create(_rich);
	  dini_IntSet(_rich, "Total", 0);
   }
   // Users :
   if(!dini_Exists(_fileconfig "UsersIP.ini"))
   {
      dini_Create(_fileconfig "UsersIP.ini");
      dini_IntSet(_fileconfig "UsersIP.ini", "Total", 0);
   }
   if(!dini_Exists(_fileconfig "Main.ini"))
   {
      dini_Create(_fileconfig "Main.ini");
	  dini_IntSet(_fileconfig "Main.ini", "CountPlayers", 0);
	  dini_IntSet(_fileconfig "Main.ini", "MaxOnlinePlayers", 0);
	  dini_Set(_fileconfig "Main.ini", "FirstRestartingDate", variable[0]);
	  dini_Set(_fileconfig "Main.ini", "FirstRestartingTime", variable[1]);
   }
   dini_Set(_fileconfig "Main.ini", "LastRestartingDate", variable[0]);
   dini_Set(_fileconfig "Main.ini", "LastRestartingTime", variable[1]);
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
   if(!dini_Exists("/KingCastle.ini"))
   {
      dini_Create("/KingCastle.ini");
      dini_Set("/KingCastle.ini","Name","None");
   }
   LoadTeleportsList();
   for(new p = 0; p < dini_Int(pickup_insetsfile, "Total") + 1; p++)
   {
      format(string, sizeof string,"/Insets/Pickups/%d.ini", p);
      if(dini_Exists(string)) CreatePickup(dini_Int(string, "pickupid"), dini_Int(string, "type"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), 0, mainPickups++, "None", 0);
   }
   for(new v = 0; v < dini_Int(vehicle_insetsfile, "Total") + 1; v++)
   {
      format(string, sizeof string,"/Insets/Vehicles/%d.ini", v);
      if(dini_Exists(string)) CreateVehicle(dini_Int(string, "modelid"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), random(126), random(126), -1);
   }
   if(!dini_Exists("Users/Vehicle/main.ini")) dini_Create("Users/Vehicle/main.ini");
   for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
   {
	  Stunts[0][playerid] = TextDrawCreate(500,100,"~y~~h~Stunts ~p~~h~Points");
      TextDrawColor(Stunts[0][playerid], 0xFFFFFFFF);
      TextDrawSetShadow(Stunts[0][playerid],0);
      TextDrawSetOutline(Stunts[0][playerid],1);
      TextDrawLetterSize(Stunts[0][playerid],0.5,2);
      TextDrawBackgroundColor(Stunts[0][playerid],0x00000040);
      TextDrawFont(Stunts[0][playerid],1);
      Stunts[1][playerid] = TextDrawCreate(500,100+20,"0");
      TextDrawColor(Stunts[1][playerid],0x000000FF);
      TextDrawSetShadow(Stunts[1][playerid],0);
      TextDrawSetOutline(Stunts[1][playerid],1);
      TextDrawLetterSize(Stunts[1][playerid],0.5,2);
      TextDrawBackgroundColor(Stunts[1][playerid],0xFFFFFF40);
      TextDrawFont(Stunts[1][playerid],3);
      if(_:TDrawPlayers[playerid] != -1)
      {
   	     TDrawPlayers[playerid] = TextDrawCreate(510, 410, "~w~SA-MP.co.il - LucifeR DeathMatch~n~Record Players Server: 123~n~You left 100 Teleports~n~You left 6000 kill(s) to next level.");
         TextDrawTextSize(TDrawPlayers[playerid], 230, 240);
	     TextDrawAlignment(TDrawPlayers[playerid], 2);
	     TextDrawFont(TDrawPlayers[playerid], 1);
	     TextDrawLetterSize(TDrawPlayers[playerid], 0.42221,1.000000); // 99999
	     TextDrawColor(TDrawPlayers[playerid], white);
	     TextDrawSetProportional(TDrawPlayers[playerid], 1);
	     TextDrawSetShadow(TDrawPlayers[playerid], 1);
		 TextDrawUseBox(TDrawPlayers[playerid], 1);
         TextDrawBoxColor(TDrawPlayers[playerid], sgba2hex(0,0,0, 190));
	  }
   }
   DoInit();
   G_Objects();
   #pragma unused a
   return 1;
}
function(OnPlayerEnterVehicle(playerid, vehicleid))
{
  new string[128], file[64];
  AC_Info[playerid][inVehicle] = true;
  PlayerInfo(InVehicle2[playerid]) = 0;
  PlayerInfo(InVehicle3[playerid]) = 1;
  if(isHQVehicle(vehicleid))
  {
     error(playerid, ".רכב זה שייך למפקדה לא ניתן לקנות אותו");
     return 0;
  }
  format(file,sizeof file,"Vehicle/%i.ini",GetPlayerVehicleID(playerid));
  if(vehicleid < xvehicles)
  {
       format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",vehicleid);
       SendHeader(playerid,"Rent Vehicle - רכב להשכרה");
       format(string,sizeof string, Vunoccupied[vehicleid]? (".%s :משכיר הרכב") : (".אין משכיר לרכב זה, אתה יכול להשכיר את הרכב"),dini_Get(rent_file,"Owner"));
       SendClientMessage(playerid,yellow,string);
       format(string,sizeof string,".מחיר הרכב ליום אחד הינו %i, האיידי של הרכב %03i %s :סוג רכב",PriceRentVehicle[vehicleid], vehicleid, VehiclesName[GetVehicleModel(vehicleid)-400]);
       SendClientMessage(playerid,yellow, RentInfo[playerid][CarID] == vehicleid? ("/RentHelp :אתה משכיר רכב זה כעת, על מנת לקבל עזרה עם המערכת השכרות") :("/RentCar [Days: 1-10] :על מנת להשכיר את הרכב "));
       SendClientMessage(playerid,white,"-------------------------------------------------------");
       return 0;
  }
  if(GetPlayerVehicleID(playerid) >= VCount) return 0;
  if(VehicleInfo[vehicleid][CarOwned])
  {
      if(!strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner], false))
	  {
	     format(string, sizeof string,"!%s \"%s\" ברוך הבא לרכב שלך מסוג",VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
	     SendClientMessage(playerid,orange,string);
	     if(VehicleInfo[vehicleid][SaleV] > 0 && VehicleInfo[vehicleid][PayTax] > 0) SendClientMessage(playerid,red,"> /Vehicle(/v) | Stop Sale :הרכב שלך, עדיין מוצע לקניה, על מנת להפסיק את מכירת הרכב ");
	     if(VehicleInfo[vehicleid][SaleV] > 0 && VehicleInfo[vehicleid][PayTax] < 1) SendClientMessage(playerid,red,"> /Vehicle(/v) | Tax :לא שילמת אגרת רכב על הרכב שלך, אם לא תשלם, רכבך ימכר, אנא שלם");
      }
	  if(strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner], false) && strcmp(VehicleInfo[vehicleid][CarOwner],"None", true))
	  {
          format(string, sizeof string," • !ולכן לא ניתן לקנייה ,%s רכב זה הינו בבעלות %s • ",VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
          SendClientMessage(playerid, 0xEEEEFFC4, string);
          if(VehicleInfo[vehicleid][SaleV] > 0)
          {
              format(string, sizeof string,VehicleInfo[vehicleid][PayTax] > 0? (" • .%s :בעלים [%s] :הצעה רכב זה מסוג • ") : (".%s :בעלים [%s] :הצעה מאגרת רכב הכנסה, רכב זה מסוג • "),VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
              SendClientMessage(playerid, yellow,string);
              format(string, sizeof string,VehicleInfo[vehicleid][PayTax] > 0? (" • .[$%d] :הציע את הרכב שלו לציבור במחיר של כ") :(".[$%d] :האגרת רכב הכנסה מציע את הרכב שלו למכירה במחיר של • ") ,VehicleInfo[vehicleid][SaleV]);
              SendClientMessage(playerid, orange,string);
          }
	  }
  }
  if(!VehicleInfo[vehicleid][Buyable] && !strcmp(VehicleInfo[vehicleid][CarOwner], "None", true))
  {
     format(string, sizeof string," • !הינו רכב ששייך לזכות הציבור ,%s רכב זה",VehicleInfo[vehicleid][CarName]);
     error(playerid, string);
  }
  if(VehicleInfo[vehicleid][Buyable])
  {
     format(string, sizeof string, " • !$%d :ניתן לקניה במחיר של ,%s :רכב זה מסוג • ", VehicleInfo[vehicleid][Price],VehicleInfo[vehicleid][CarName]);
     SendClientMessage(playerid, darkblue, string);
     format(string, sizeof string, "/Vehicle(/v) :פקודות רכב");
     SendClientMessage(playerid, darkblue, string);
  }
  return 1;
}
function(OnPlayerExitVehicle(playerid, vehicleid))
{
   if(isBike(GetPlayerVehicleID(playerid))) RemovePlayerAttachedObject(playerid, 0);
   if(StuntsBugs[playerid]) PlayerInfo(MoneyStunts[playerid]) = GetPlayerMoney(playerid) - AC_Info[playerid][cash];
   AC_Info[playerid][inVehicle] = false;
   PlayerInfo(InVehicle3[playerid]) = 0;
   GivePlayerMoney(playerid, -PlayerInfo(MoneyStunts[playerid]));
   return 1;
}
function(antiCheat(playerid))
{
   // AntiCheat:
   new Float:_health[MAX_PLAYERS], Float:_armour[MAX_PLAYERS], Float:z;
   GetPlayerPos(playerid, PlayerInfo(vspeed[playerid][0]), PlayerInfo(vspeed[playerid][1]), z);
   GetPlayerHealth(playerid, _health[playerid]);
   GetPlayerArmour(playerid, _armour[playerid]);
   if(_armour[playerid] > AC_Info[playerid][armour] && _armour[playerid] != 0.0 && !PlayerInfo(cOkdie[playerid]))
   {
	  SetPlayerArmour(playerid, AC_Info[playerid][armour]);
	  return AC_Info[playerid][warnings][0] == MAX_WARNINGS? AC_Kick(playerid, "Armour") : AC_Warning(playerid, AC_Info[playerid][warnings][0], "Armour");
   }
   else if(_armour[playerid] < AC_Info[playerid][armour]) AC_Info[playerid][armour] = _armour[playerid];
   if(_health[playerid] > AC_Info[playerid][health] && _health[playerid] != 0.0 && !PlayerInfo(cOkdie[playerid] && !vehicleCallBug[playerid]))
   {
	  _SetPlayerHealth(playerid, AC_Info[playerid][health]);
	  return AC_Info[playerid][warnings][1] == MAX_WARNINGS? AC_Kick(playerid, "Health") : AC_Warning(playerid, AC_Info[playerid][warnings][1], "Health");
   }
   else if(_health[playerid] < AC_Info[playerid][health])
   {
      AC_Info[playerid][health] = _health[playerid];
      //SetTDHealth(playerid);
   }
   if(GetPlayerMoney(playerid) > AC_Info[playerid][cash] || PlayerInfo(MoneyStunts[playerid]) == 500)
   {
	  if(!IsPlayerInAnyVehicle(playerid) && !PlayerInfo(MoneyStunts[playerid])) GivePlayerMoney(playerid, GetPlayerMoney(playerid) - AC_Info[playerid][cash]);
	  return 1;
   }
//   else if(GetPlayerMoney(playerid) < AC_Info[playerid][cash]) AC_Info[playerid][cash] = GetPlayerMoney(playerid);
   if(!AC_Info[playerid][_sWeapons][GetPlayerWeapon(playerid)] && GetPlayerWeapon(playerid) != 0 && GetPlayerState(playerid) != 7 && !PlayerInfo(firsts[playerid]))
   {
	  ResetPlayerWeapons(playerid);
	  return AC_Info[playerid][warnings][3] == MAX_WARNINGS? AC_Kick(playerid, "Weapons") : AC_Warning(playerid, AC_Info[playerid][warnings][3], "Weapons");
   }
   if(IsPlayerInAnyVehicle(playerid) && !AC_Info[playerid][inVehicle] && !PlayerInfo(InVehicle3[playerid]) && !vehicleCallBug[playerid])
   {
      PlayerInfo(InVehicle2[playerid])++;
	  if(PlayerInfo(InVehicle2[playerid]) == 5 && !AC_Info[playerid][inVehicle])
	  {
         Kill(playerid);
         if(AC_Info[playerid][warnings][5] == MAX_WARNINGS) AC_Kick(playerid, "Vehicle");
	     else AC_Warning(playerid, AC_Info[playerid][warnings][5], "Vehicle");
	     PlayerInfo(InVehicle2[playerid]) = 0;
	  }
	  return 1;
   }
   else if(!IsPlayerInAnyVehicle(playerid) && AC_Info[playerid][inVehicle]) AC_Info[playerid][inVehicle] = false;
   return 1;
}
function(OnPlayerConnect(playerid))
{
   new string[128];
   format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(playerid));
   setMaxPlayersOnline();
   resetAC(playerid);
   pGateInfo[playerid][gid] = 1;
   PlayerInfo(firsts[playerid]) = 1;
   AC_Info[playerid][cash] = 0;
   AC_Info[playerid][cash] = GetPlayerMoney(playerid);
   Vehicle_Info[playerid][CarID] = 0;
   Vehicle_Info[playerid][OwnCar] = 0;
   Castle_Kills[playerid] = 0;
   StuntsBugs[playerid] = 0;
   SetPlayerMapIcon( playerid, 1, -2579.2842,1119.8170,55.5184, 53, 0 );//race
   SetPlayerMapIcon( playerid, 3, 2001.6742, 1544.2804, 13.5859, 9, 0 );//ship
   SetPlayerMapIcon( playerid, 7, -1357.0162,-241.8450,14.1484, 5, 0 );//airport
   SetPlayerMapIcon( playerid, 8, -2404.3467,-598.3986,132.6484, 55, 0 );//drift
   SetPlayerMapIcon( playerid, 9, 2386.9690, 1043.2112, 10.8203, 27, 0 );//garage
   SetPlayerMapIcon( playerid, 10, 2507.1418, 1243.0775, 10.8203, 23, 0 );//club
   SetPlayerMapIcon( playerid, 4, -2715.9399, 217.8603, 4.3481, 27, 0 );//מוסך
   SetPlayerMapIcon( playerid, 5, 2387.1956, 1050.5073, 10.3850, 27, 0 );//מוסך
   SetPlayerMapIcon( playerid, 6, 2646.3372, -2038.0317, 13.1468, 27, 0 );//מוסך
   SetPlayerMapIcon( playerid, 7, -1988.8795,1118.0017,54.4721, 52,0); // bank
   SetPlayerMapIcon( playerid, 7, -2667.5696,732.9576,27.9531, 52,0); // mission
   SetPlayerMapIcon( playerid, 1, -2665.4519,632.4997,14.4531, 22,0); // hospital
   _Callback(OnPlayerJoin, playerid, GetName(playerid), GetIP(playerid), dini_Exists(getPlayerFile(playerid, _fileusers)), dini_Bool(string, "autoLogin"), IsPlayerNPC(playerid)? 1 : 0);
   return 1;
}
function(OnPlayerRequestClass(playerid))
{
  SetPlayerPos(playerid, -2408.1179,327.7134,35.1719);
  SetPlayerFacingAngle(playerid, 238.4170);
  SetPlayerCameraPos(playerid, -2398.1433,328.2122,35.0156);
  SetPlayerCameraLookAt(playerid, -2419.7932,323.1662,34.9688);
  return 1;
}
function(OnPlayerRequestSpawn(playerid)) return _Callback(int, playerid, IsPlayerNPC(playerid), dini_Exists(getPlayerFile(playerid, _fileusers)));
function(OnPlayerEnterCheckpoint(playerid))
{
   new string[128];
   if(isPlayerInBank(playerid)) return dini_Exists(getPlayerFile(playerid, _filebank))? ShowPlayerDialog(playerid, 17, 2, " - אנא בחר את הפעולה שתרצה לבצע", " • (1) Deposit\n • (2) Withdraw\n • (3) Transfer\n • (4) Balance\n • (5) Deposit all\n • (6) Withdraw all\n • (7) Last Bank Action(s)","בחר","ביטול") : ShowPlayerDialog(playerid, 18, DIALOG_STYLE_INPUT, " Bank create an account", "אנא הזן את הסיסמה שלך לחשבון בנק כאן\nמומלץ לא לשים את הסיסמה של החשבון שלך על מנת להימנע מפריצות","תיצור","ביטול");
   if(dini_Exists(ClanPlayerFile(playerid)))
   {
       if(CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")]))
       {
		    format(string, sizeof string, "!%s - ברוכים הבאים לבנק של הקלאן שלך", dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
		    SendHeader(playerid, string);
		    SendClientMessage(playerid, orange, "!שלום לך, ברוכים הבאים לחשבון בנק של הקלאן שלך, כמה שיש יותר כסף ככה לקלאן יש יותר דברים");
		    SendClientMessage(playerid, 0x16EB43ff, " • /cbinfo - על מנת לקבל מידע על הבנק קלאן");
		    SendClientMessage(playerid, 0x16EB43ff, " • /cdeposit - על מנת להפקיד כסף לחשבון הבנק של הקלאן");
		    SendClientMessage(playerid, 0x16EB43ff, " • /cwithdraw - על מנת למשוך כסף מהחשבון של הבנק של הקלאן");
		    return 1;
        }
   }
   if(CPS_IsPlayerInCheckpoint(playerid, VIPBank))
   {
	   if(isPlayerVIP(playerid))
	   {
			new b = dini_Int("/VIP/Stats.txt", "Bank");
			SendClientMessage(playerid, white, "-------- [ VIP Bank - בנק האחמ\"ים ] --------");
			format(string, sizeof string, " • !VIP - ברוכים הבאים לבנק של אירגון ה %s - שלום לך",GetName(playerid));
			SendClientMessage(playerid, 0x00FFFFAA, string);
			format(string, sizeof string, b != 0? (" • %d$ - עומד על כ VIP - המאזן של בנק ה") : (" • .ריק לחולטין VIP - חשבון בנק ה"), b);
			SendClientMessage(playerid, b != 0? 0x16EB43FF : red, string);
			SendClientMessage(playerid, 0x16EB43FF, " • /VDeposit - על מנת להפקיד לחשבון הבנק של האירגון");
			SendClientMessage(playerid, 0x16EB43FF, " • /VWithdraw - על מנת למשוך כסף מחשבון הבנק האירגון");
			SendClientMessage(playerid, orange, " • VIP הערה: כל הכסף של שאתה מפקיד יחזור אליך, אינך יכול למשוך יותר ממה שהפקדת, כל יומיים הכסף שלך יוכפל בחשבון *");
			SendClientMessage(playerid, white, "--------------------------------------");
		    return 1;
	   }
	   else return error(playerid,".בלבד VIP - צ'ק פוינט זה משמש את אירגון ה");
   }
   if(isPlayerInAmmoSHOP(playerid))
   {
	  SendClientMessage(playerid, white, "-------- [ !ברוכים הבאים לחנות נשקים ] --------");
	  SendClientMessage(playerid, 0x16EB43FF, " • ברוכים הבאים לחנות נשקים, פה תוכל לקנות נשקים תמידיים שימשרו לך גם לאחר שתמות");
	  SendClientMessage(playerid, orange, " • /BuyWeapon(/Bw) - על מנת לקנות נשק");
	  format(string, sizeof string, " • תשלם %s50 פחות על כל נשק ,VIP - בגלל שאתה חבר", "%%");
      if(isPlayerVIP(playerid)) SendClientMessage(playerid, pink, string);
	  SendClientMessage(playerid, white, "--------------------------------------");
	  return 1;
   }
   return 1;
}
function(OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]))
{
	new string[128];
    if(dialogid == 0) return response? clan_Accept(playerid) : SendClientMessage(playerid,orange," • /Clan Accept - יש לך 30 שניות להחליט אם אתה רוצה להצטרף לקלאן שהוזמנת אליו, אם אתה רוצה הקש/י");
    if(dialogid == 1 && response)
	{
	   if(listitem == 0) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"  Clan Bank - Amount Of Money"," » הכנס את הסכום שהינך רוצה להפקיד לחשבון קלאן בנק", "הפקד", "ביטול");
	   if(listitem == 1) return ShowPlayerDialog(playerid,3,DIALOG_STYLE_MSGBOX,"  Clan Bank - All Of Money"," » ע''י לחיצה על הכפתור \"אישור\" כל הכסף שכרגע נמצא בכיס שלך יעבור לחשבון בנק של הקלאן", "אישור", "ביטול");
	   return 1;
	}
	if(dialogid == 2 && response)
	{
	    if(_GetPlayerMoney(playerid) < strval(inputtext) || strval(inputtext) <= 0) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"  Clan Bank - Amount Of Money (Error: Worng Money)"," » הכנס את הסכום שהינך רוצה להפקיד לחשבון קלאן בנק", "הפקד", "ביטול");
	    format(string, sizeof string, " • !%d$ - הפקיד לחשבון בנק %s השחקן", strval(inputtext), GetName(playerid));
	    SendClanMessageToAll(playerid, orange, string);
	    dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank") + strval(inputtext));
	    _GivePlayerMoney(playerid, -1*strval(inputtext));
	    return 1;
	}
	if(dialogid == 3 && response)
	{
	    if(_GetPlayerMoney(playerid) < 1) return error(playerid, ".אין לך כסף");
	    format(string, sizeof string, " • !%d$ - הפקיד לחשבון בנק את כל כספו %s השחקן", _GetPlayerMoney(playerid), GetName(playerid));
	    SendClanMessageToAll(playerid, orange, string);
	    dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank") + _GetPlayerMoney(playerid));
	    _ResetPlayerMoney(playerid);
	    return 1;
	}
	if(dialogid == 4 && response)
	{
	   if(strval(inputtext) > dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank"))
	   {
           format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
		   ShowPlayerDialog(playerid, 4, DIALOG_STYLE_INPUT, string," • שים לב, הסכום הקודם שהזנת הינו סכום שלא קיים בבנק, אנא הזן סכום הגיוני ", "משוך", "ביטול");
		   return 1;
	   }
	   if(strval(inputtext) > dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw") && getPlayerClanLevel(playerid) != 4)
	   {
           format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
		   ShowPlayerDialog(playerid, 4, DIALOG_STYLE_INPUT, string, " • \"MaxWithdraw\" :שים לב, הסכום שהזנת אינו הגיוני, אינך יכול למשוך יותר מהסכום המצוין למעלה ", "משוך", "ביטול");
		   return 1;
	   }
	   if(strval(inputtext) < 1)
	   {
          format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
	      ShowPlayerDialog(playerid, 4, DIALOG_STYLE_INPUT, string, " • אתה לא יכול להקשיב סכום שלילי, הכוונה סכום פחות מ - 1 ", "משוך", "ביטול");
		  return 1;
	   }
	   format(string, sizeof string, "%s",GetDateAsString('/', 1));
	   dini_Set(ClanPlayerFile(playerid),"Last_Withdraw", string);
	   _GivePlayerMoney(playerid, strval(inputtext));
       format(string, sizeof string, " • !%d$ - משך מחשבון הבנק של הקלאן %s השחקן", strval(inputtext), GetName(playerid));
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
			 ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " » Private Messsage - הודעה פרטית",".אנא הקלד את ההודעה פרטית שלך ולחץ שלח","שלח","ביטול");
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
			 ShowPlayerDialog(playerid, 9, DIALOG_STYLE_INPUT, " » Pay - לשלם",".אנא הקלד את הסכום הרצוי שאתה רוצה לשלוח", "שלח", "ביטול");
			 return 1;
   		}
   		if(listitem == 3)
   		{
		     if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
			 ShowPlayerDialog(playerid, 10, DIALOG_STYLE_INPUT," » Report - דיווח ",".אנא הקלד את הסיבה של העבירה של השחקן","שלח","ביטול");
			 return 1;
        }
		return 1;
	}
	if(dialogid == 8 && response)
	{
       if(!strlen(inputtext)) return ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " » Private Messsage - הודעה פרטית",".אנא הקלד את ההודעה פרטית שלך ולחץ שלח","שלח","ביטול");
       OnPlayerPrivmsg(playerid, PlayerInfo(onClick[playerid]), inputtext, GetName(playerid), GetName(PlayerInfo(onClick[playerid])));
	   return 1;
	}
	if(dialogid == 9 && response == 1)
	{
		if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
		if(_GetPlayerMoney(playerid) < strval(inputtext)) return	ShowPlayerDialog(playerid,9, DIALOG_STYLE_INPUT," » Pay - לשלם",".סכום שגוי! אנא הקלד סכום שיש לך","שלח","ביטול");
		if(strval(inputtext) < 1) return ShowPlayerDialog(playerid, 9, DIALOG_STYLE_INPUT, " » Pay - לשלם",".סכום שגוי! אנא הקלד סכום הגיוני","שלח","ביטול");
	    _GivePlayerMoney(playerid, -1*strval(inputtext));
	    _GivePlayerMoney(PlayerInfo(onClick[playerid]), strval(inputtext));
	    format(string, sizeof string, " • !(> %d$) :סכום הכסף ששלחת לו הוא %s - שלחת כסף ל • ", strval(inputtext), GetName(PlayerInfo(onClick[playerid])));
	    SendClientMessage(playerid, darkblue, string);
	    format(string, sizeof string, " • !(> %d$) :סכום הכסף שקיבלת %s - קיבלת כסף מ • ", strval(inputtext), GetName(playerid));
	    SendClientMessage(PlayerInfo(onClick[playerid]), darkblue, string);
	    return 1;
	}
	if(dialogid == 10 && response)
	{
		if(!IsPlayerConnected(PlayerInfo(onClick[playerid]))) return 1;
		format(string ,sizeof string, " • Report on: %s [ID: » %i] from: %s • ", GetName(PlayerInfo(onClick[playerid])), PlayerInfo(onClick[playerid]), GetName(playerid));
		SendClientMessageToAdmins(red, string);
		format(string ,sizeof string, " • (\"%s\") • ", inputtext);
		SendClientMessageToAdmins(green, string);
		SendClientMessage(playerid, green," • !תודה על הדיווח, האדמינים יטפלו בדיווח במהירות האפשרית • ");
		return 1;
	}
	if(dialogid == 11 && response)
	{
	   if(listitem != 7 && listitem != 8)
	   {
 	     format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(playerid));
	     dini_BoolSet(string, settings[listitem], dini_Isset(string, settings[listitem]) && dini_Bool(string, settings[listitem])? false : true);
	     SendClientMessage(playerid, dini_Bool(string, settings[listitem])? green : red, dini_Bool(string, settings[listitem])? tmsg_Settings[listitem] : fmsg_Settings[listitem]);
	     if(listitem == 5) return dini_Bool(string, settings[5])? ShowMainTextDraw(playerid) : TextDrawHideForPlayer(playerid, TDrawPlayers[playerid]);
	     return 1;
	   }
 	   if(listitem == 7) return ShowPlayerDialog(playerid, 12, DIALOG_STYLE_INPUT, "   Users Systems \\ מערכת משתמשים", " • \"אנא הזן את הסיסמה החדשה שלך והקש: \"שנה סיסמה", "שנה סיסמה", "ביטול");
 	   if(listitem == 8) return ShowPlayerDialog(playerid, 13, DIALOG_STYLE_INPUT, "   Users Systems \\ מערכת משתמשים", " • \"אנא הזן את הכינוי החדש שלך ולאחר מכן לחץ \"שנה כינוי", "שנה כינוי", "ביטול");
	   return 1;
	}
	if(dialogid == 12 && response)
	{
       if(strlen(inputtext) > 30 || strlen(inputtext) < 6)
       {
	       ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
	       SendClientMessage(playerid, red, ".הסיסמה שלך ארוכה / קצרה מדי, אורך הסיסמה חייב להיות בין 6 ל - 30");
	       return 1;
       }
       if(!strlen(inputtext))
       {
          format(string, sizeof string, " !אנא הזן סיסמה - %s", GetName(playerid));
	      ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
	      error(playerid, string);
	      return 1;
       }
       if(isSimple(inputtext))
       {
          ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
          error(playerid, "  !סיסמה פשוטה מדי, אנא בחר סיסמה אחרת");
	      return 1;
       }
       SendClientMessage(playerid, green, " - !שינת את הסיסמה שלך");
       format(string, sizeof string, " - \"%s\" :שינת את הסיסמה שלך ל", inputtext);
  	   SendClientMessage(playerid, orange, string);
  	   dini_Set(getPlayerFile(playerid, _fileusers), "Password", inputtext);
	   return 1;
	}
	if(dialogid == 13 && response)
	{
	   new _sn[32];
	   format(string, sizeof string, strlen(inputtext) > 20 || strlen(inputtext) < 3? ("!הסיסמה שלך צריכה להיות בין 3 ל - 20 תווים בלבד") : ("(%s) אנא וודא שנית שהכינו שהזנת חוקי"), inputtext);
       if(curNick(inputtext)) return error(playerid, string);
       format(string, sizeof string, "אתה תוכל לשנות את הכינוי שלך רק בעוד %i ימים.", DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "LastChangeNick"), GetDateAsString('/', 1)) < 7);
  	   if(DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "LastChangeNick"), GetDateAsString('/', 1)) < 7 && strcmp(dini_Get(getPlayerFile(playerid, _fileusers), "LastChangeNick"), "None", true)) return SendClientMessage(playerid, red, string);
	   if(dini_Exists(getPlayerFile2(inputtext, "Users"))) return ShowPlayerDialog(playerid, 13, DIALOG_STYLE_INPUT, "   שגיאה: שם זה כבר קיים במערכת", " • \"אנא הזן את הכינוי החדש שלך ולאחר מכן לחץ \"שנה כינוי", "שנה כינוי", "ביטול");
	   fileCopy(getPlayerFile(playerid, _fileusers), getPlayerFile2(inputtext, "Users"));
	   fileCopy(getPlayerFile(playerid, _filestats), getPlayerFile2(inputtext, "Users/Stats"));
	   fileCopy(getPlayerFile(playerid, _filebank), getPlayerFile2(inputtext, "Users/Bank"));
	   fileCopy(getPlayerFile(playerid, _filevehicle), getPlayerFile2(inputtext, "Users/Vehicle"));
	   if(isPlayerInClan(playerid)) fileCopy(ClanPlayerFile(playerid), getPlayerFile2(inputtext, "Clans/Users"));
	   fileCopy(WeaponFile(playerid), getPlayerFile2(inputtext, "Users/Weapons/Players"));
	   fileCopy(VIPFile(playerid), getPlayerFile2(inputtext, "VIP"));
 	   format(_sn, sizeof _sn, _fileprivate "setting_%s.ini", GetName(playerid));
	   format(string, sizeof string, "Users/Private/setting_%s.ini", inputtext);
	   fileCopy(_sn, string);
 	   format(_sn, sizeof _sn, _fileprivate "profile_%s.ini", GetName(playerid));
	   format(string, sizeof string, "Users/Private/profile_%s.ini", inputtext);
	   fileCopy(_sn, string);
       dini_Set(getPlayerFile2(inputtext, "Users"), "LastChangeNick", GetDateAsString('/', 1));
	   format(string, sizeof string, "%s", inputtext);
	   SendHeader(playerid, string);
 	   format(string, sizeof string, " • %s - שינת את הכינוי ל", inputtext);
 	   SendClientMessage(playerid, orange, string);
 	   format(string, sizeof string, " • %s - הכינוי הקודם שלך", GetName(playerid));
 	   SendClientMessage(playerid, orange, string);
 	   SendClientMessage(playerid, red, " * אנא צלם תמונה זו על מנת לא לשכוח את הכינוי שלך");
 	   SendClientMessage(playerid, red, " * אתה תוכל לשנות את כינויך שנית בעוד יומיים");
       format(string, sizeof string, " • %s - שינה את הכינוי שלו ל ,%s - השחקן", inputtext, GetName(playerid));
       SendClientMessageToAll(yellow, string);
 	   SetTimerEx("Kick_", 2000, false, "i", playerid);
	   return 1;
	}
	if(dialogid == 14 && response)
	{
       format(string, sizeof string, "\"%s\" הפריט שהינו בחרת לערוך הוא", profiles[listitem]);
       ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, " • אנא הזן את הפרטים הנכונים לפריט שבחרת", string, "אשר", "ביטול");
       profile_item[playerid] = listitem;
	   return 1;
    }
 	if(dialogid == 15 && response)
	{
	   if(!strlen(inputtext))
	   {
          format(string, sizeof string, "\"%s\" הפריט שהינו בחרת לערוך הוא", profiles[profile_item[playerid]]);
          ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, " • אנא הזן את הפרטים הנכונים לפריט שבחרת", string, "אשר", "ביטול");
	      return 1;
	   }
	   if(!isEnglish(inputtext) && profile_item[playerid] != 2 && profile_item[playerid] != 3)
	   {
         format(string, sizeof string, ".המחרוזת שהקשת באנגלית, מותר לכתוב פריט זה רק בעברית \"%s\" הפריט שהינו בחרת לערוך הוא", profiles[profile_item[playerid]]);
         ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, " • אנא הזן את הפרטים הנכונים לפריט שבחרת", string, "אשר", "ביטול");
		 return 1;
	   }
	   if(!Brithday(inputtext) && profile_item[playerid] == 6) return ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, " • \"דוגמה להזנת תאריך יומלדת: \"13/2/1994", string, "אשר", "ביטול");
	   if(!ValidEmail(inputtext) && (profile_item[playerid] == 2 || profile_item[playerid] == 3))
	   {
          format(string, sizeof string, "המחרוזת שהקשת לא הגיונית, הזן שנית \"%s\" הפריט שהינו בחרת לערוך הוא", profiles[profile_item[playerid]]);
          ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, " • אנא הזן את הפרטים הנכונים לפריט שבחרת", string, "אשר", "ביטול");
		  return 1;
	   }
	   if(!validICQ(inputtext) && profile_item[playerid] == 4)
	   {
          format(string, sizeof string, "המחרוזת שהקשת לא הגיונית, הזן שנית \"%s\" הפריט שהינו בחרת לערוך הוא", profiles[profile_item[playerid]]);
          ShowPlayerDialog(playerid, 15, DIALOG_STYLE_INPUT, " • אנא הזן את הפרטים הנכונים לפריט שבחרת", string, "אשר", "ביטול");
		  return 1;
	   }
	   format(string, sizeof string, _fileprivate "profile_%s.ini", GetName(playerid));
	   if(!dini_Exists(string)) dini_Create(string);
       dini_Set(string, profiles[profile_item[playerid]], inputtext);
       if(profile_item[playerid] == 6) dini_IntSet(string, profiles[profile_item[playerid] + 1], Brithday(inputtext));
	   SendClientMessage(playerid, orange, profilesm[profile_item[playerid]]);
	   return 1;
	}
	if(dialogid == 16 && response)
	{
       format(string, sizeof string, "tele%i", listitem + 1);
       format(string, sizeof string, "/Insets/Teleports/%s.ini", dini_Get(teleports_insetsfile, string));
       if(dini_Exists(string)) createTeleport(playerid, dini_Int(string, "interior"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), dini_Int(string, "with_vehicle"), dini_Int(string, "level"), dini_Get(string, "cmd"), dini_Int(string, "stpo"));
       return 1;
    }
    if(dialogid == 17 && response)
    {
	   new variable[2][128];
	   variable[0] = GetTimeAsString(':'), variable[1] = GetDateAsString('/');
       if(listitem == 0) return ShowPlayerDialog(playerid, 19, DIALOG_STYLE_INPUT, " בנק - הפקדת כסף", ".אנא הזה את הסכום שהינך רוצה להפקיד לחשבון שלך","הפקד","ביטול");
       if(listitem == 1) return ShowPlayerDialog(playerid, 20, DIALOG_STYLE_INPUT, " בנק - משיכת כסף", ".אנא הזה את הסכום שהינך רוצה למשוך מהבנק שלק","משוך","ביטול");
       if(listitem == 2) // transfer
       {
		  return 1;
	   }
       if(listitem == 3) // balance
       {
		  format(string, sizeof string, "מאזן הבנק שלך עומד על %i$ דולר.", dini_Int(getPlayerFile(playerid, _filebank), "Bank"));
		  SendClientMessage(playerid, random(2) == 1? orange : green, string);
		  format(string, sizeof string, "Balance - %i$ [Date: %s | Time: %s]", dini_Int(getPlayerFile(playerid, _filebank), "Bank"), variable[1], variable[0]);
		  SetBankLastAction(playerid, string);
 		  return 1;
	   }
       if(listitem == 4) // deposit all
       {
		  format(string, sizeof string, ".הפקדת לחשבון בנק שלך %d$ כעת החשבו בנק שלך עומד על %d$", _GetPlayerMoney(playerid), _GetPlayerMoney(playerid) + dini_Int(getPlayerFile(playerid, _filebank), "Bank"));
		  SendClientMessage(playerid, random(2) == 1? orange : green, string);
		  format(string, sizeof string, "Deposit all - %i$ [Date: %s | Time: %s]", _GetPlayerMoney(playerid), variable[1], variable[0]);
		  SetBankLastAction(playerid, string);
		  dini_IntSet(getPlayerFile(playerid, _filebank), "Bank", dini_Int(getPlayerFile(playerid, _filebank), "Bank") + _GetPlayerMoney(playerid));
		  _ResetPlayerMoney(playerid);
		  return 1;
	   }
       if(listitem == 5) // withdraw all
       {
		  if(dini_Int(getPlayerFile(playerid, _filebank), "Bank") < 1) return SendClientMessage(playerid, red, ".אין לך כסף בבנק");
		  format(string, sizeof string, ".משכת מחשבון הבנק שלך %i דולר", dini_Int(getPlayerFile(playerid, _filebank), "Bank"));
		  SendClientMessage(playerid, random(2) == 1? orange : green, string);
		  format(string, sizeof string, "Witadraw all - %i$ [Date: %s | Time: %s]", dini_Int(getPlayerFile(playerid, _filebank), "Bank"), variable[1], variable[0]);
		  SetBankLastAction(playerid, string);
		  _GivePlayerMoney(playerid, dini_Int(getPlayerFile(playerid, _filebank), "Bank"));
		  dini_IntSet(getPlayerFile(playerid, _filebank), "Bank", 0);
		  return 1;
	   }
	   if(listitem == 6)
	   {
		 new x = 1, string2[256];
         SendHeader(playerid, "ה - 10 פעולות האחרונות שביצעת בבנק");
         for(new i = 0; i < dini_Int(getPlayerFile(playerid, _filebank), "Total"); i++)
         {
            format(string2, sizeof string2, "%i", i);
            format(string, sizeof string, "(%02i) %s", x, dini_Get(getPlayerFile(playerid, _filebank), string2));
			if(strcmp(dini_Get(getPlayerFile(playerid, _filebank), string2), " ", true))
			{
			    SendClientMessage(playerid, green, string);
			    x++;
			}
         }
		 return 1;
	   }
	   return 1;
    }
    if(dialogid == 18 && response)
    {
       if(!dini_Exists(getPlayerFile(playerid, _filebank))) dini_Create(getPlayerFile(playerid, _filebank));
       SendClientMessage(playerid, white, "\n");
	   format(string, sizeof string, "%s - פתחת חשבון בנק חדש", inputtext);
	   SendHeader(playerid, string);
	   //SendClientMessage(playerid, green, " • קיבלת 10000$ על פתיחת חשבון בנק חדש");
	   format(string, sizeof string, " * %s - סיסמה", inputtext);
	   error(playerid, string);
 	   SendClientMessage(playerid, red, " * !אנא צלם תמונה זו על מנת לזכור את סיסמתך");
 	   SendClientMessage(playerid, 0xffff00ff, " • \"Buy Credit Card\" :ובחר ב /banks :חדש: כרטיס אשראי, אם תרצה תוכל לקנות כרטיס אשראי, השתמש בפקודה");
 	   SendClientMessage(playerid, 0xffff00ff, " • טיפ: חסוך כמה שיותר כסף והפקד אותו מיידית בבנק על מנת למנוע איבוד הכסף");
 	   SendClientMessage(playerid, white, "\n");
       dini_IntSet(getPlayerFile(playerid, _filebank), "Bank", 500);
       dini_IntSet(getPlayerFile(playerid, _filebank), "CC", 0);
	   return 1;
	}
	if(dialogid == 19 && response)
	{
	   if(_GetPlayerMoney(playerid) < strval(inputtext)) return error(playerid, ".אין לך מספיק כסף כפי שהקשת בדיאלוג");
       format(string, sizeof string, ".הפקדת לחשבון בנק שלך %d$ כעת החשבו בנק שלך עומד על %d$", strval(inputtext), strval(inputtext) + dini_Int(getPlayerFile(playerid, _filebank), "Bank"));
       SendClientMessage(playerid, random(2) == 1? orange : green, string);
       dini_IntSet(getPlayerFile(playerid, _filebank), "Bank", dini_Int(getPlayerFile(playerid, _filebank), "Bank") + strval(inputtext));
       _GivePlayerMoney(playerid, -1*strval(inputtext));
	   format(string, sizeof string, "Deposit - +%i$ [Date: %s | Time: %s]", strval(inputtext), variable[1], variable[0]);
	   SetBankLastAction(playerid, string);
	   return 1;
	}
	if(dialogid == 20 && response)
	{
	   if(dini_Int(getPlayerFile(playerid, _filebank), "Bank") < strval(inputtext)) return error(playerid, ".אין לך מספיק כסף בבנק כפי שהקשת בדיאלוג");
       format(string, sizeof string, ".משכת מחשבון הבנק שלך %d$ דולר", strval(inputtext));
       SendClientMessage(playerid, random(2) == 1? orange : green, string);
       dini_IntSet(getPlayerFile(playerid, _filebank), "Bank", dini_Int(getPlayerFile(playerid, _filebank), "Bank") - strval(inputtext));
       _GivePlayerMoney(playerid, strval(inputtext));
	   format(string, sizeof string, "Withdraw - %i$ [Date: %s | Time: %s]", strval(inputtext), variable[1], variable[0]);
	   SetBankLastAction(playerid, string);
	   return 1;
	}
	if(dialogid == 21 && response)
    {
       if(getPlayerLevel(playerid) > listitem+1) format(string, sizeof string, "Tag: %s • Level: %i • Kills: %i", var_Tags[listitem], listitem + 1, var_Levels[listitem]);
       else format(string, sizeof string, " • אתה צריך עוד %i הריגות %s(%i) :על מנת לעבור לרמה", var_Levels[listitem] - dini_Int(getPlayerFile(playerid, _filestats), "Kills"), var_Tags[listitem], listitem + 2);
       SendClientMessage(playerid, random(2) == 1? yellow : orange, string);
	   return 1;
    }
    if(dialogid == 22 && response)
    {
	   if(!IsPlayerConnected(PlayerInfo(onClick2[playerid]))) return SendClientMessage(playerid, red, ".שחקן זה כבר התנתק");
	   if(!strlen(inputtext))
	   {
          PlayerInfo(onClick[playerid]) = PlayerInfo(onClick2[playerid]);
          ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " » Private Messsage - הודעה פרטית",".אנא הקלד את ההודעה פרטית שלך ולחץ שלח","שלח","ביטול");
	      return 1;
	   }
	   OnPlayerPrivmsg(playerid, PlayerInfo(onClick2[playerid]), inputtext, GetName(playerid), GetName(PlayerInfo(onClick2[playerid])));
	   return 1;
    }
    if(dialogid == 23 && response)
    {
	   new string2[128], string3[128], cost_[MAX_PLAYERS] = {0, ...}, _ammo = 0;
	   format(string, sizeof string, "/Users/Weapons/Weapon%d.ini", listitem+1);
	   cost_[playerid] = isPlayerVIP(playerid)? dini_Int(string, "cost") / 2 : dini_Int(string, "cost");
	   if(!dini_Exists(string)) return error(playerid, ".נשק שגוי");
	   if(getPlayerLevel(playerid) < dini_Int(string, "level"))
	   {
		  format(string2, sizeof string2, "נשק זה ניתן לשחקנים מרמה: %i בלבד.", dini_Int(string, "level"));
		  error(playerid, string2);
		  return 1;
	   }
	   if(_GetPlayerMoney(playerid) < cost_[playerid])
	   {
		   format(string2, sizeof string2, " • !%d$ - עולה \"%s\" - הנשק", cost_[playerid], dini_Get(string, "Weapon_Name"));
		   error(playerid, string2);
		   format(string2, sizeof string2, " • !%d$ - על מנת לקנות נשק זה חסר לך", cost_[playerid] - _GetPlayerMoney(playerid)); // Tested (my money: 7$, cost weapon: 12$) (Test: 7-12 = 5, 5 + = 7 = 12)
		   error(playerid, string2);
		   return 1;
	   }
	   if(!dini_Exists(WeaponFile(playerid)))
	   {
	      dini_Create(WeaponFile(playerid));
	      dini_IntSet(WeaponFile(playerid), "Total", 0);
	   }
	   format(string3, sizeof string3, "weapon%i", listitem+1);
	   if(!dini_Isset(WeaponFile(playerid), string3) || !dini_Int(WeaponFile(playerid), string3)) dini_IntSet(WeaponFile(playerid), "Total", dini_Int(WeaponFile(playerid), "Total")+1);
	   dini_IntSet(WeaponFile(playerid), string3, dini_Int(string, "id"));
	   format(string3, sizeof string3, "ammo%i", listitem+1);
	   dini_IntSet(WeaponFile(playerid), string3, dini_Int(WeaponFile(playerid), string3) + dini_Int(string, "Ammo"));
	   GivePlayerWeapon(playerid, dini_Int(string, "id"), dini_Int(string, "Ammo"));
	   _ammo = dini_Int(WeaponFile(playerid), string3);
  	   format(string3, sizeof string3, " • !בהצלחה \"%s\" - קנית את הנשק", dini_Get(string, "Weapon_Name"));
	   SendClientMessage(playerid, orange, string3);
	   format(string3, sizeof string3, " • !%i - מספר הכדורים שקנית לנשק", dini_Int(string, "Ammo"));
	   SendClientMessage(playerid, orange, string3);
  	   format(string3, sizeof string3, " • !%i - מספר הכדורים שיש לך בנשק זה", _ammo);
	   SendClientMessage(playerid, orange, string3);
	   _GivePlayerMoney(playerid, -1*cost_[playerid]);
	   return 1;
	}
	if(dialogid == 24 && response)
    {
       vehicleAction(playerid, VehicleParameter[listitem]);
	   return 1;
    }
    if(dialogid == 25 && response)
    {
       new filecar[64];
       if(strval(inputtext) > 500000 || strval(inputtext) < 1) return ShowPlayerDialog(playerid, 25, DIALOG_STYLE_INPUT, string, " • !אנא הזן את הסכום שבו תרצה למכור את הרכב שלך לציבור, המחיר אמור להיות בין 1$-50,000$", "בצע", "ביטול");
       format(filecar,sizeof filecar,"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
       dini_IntSet(filecar,"SaleV", strval(inputtext));
       VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] = dini_Int(filecar, "SaleV");
       format(string , sizeof string," • !%d$ - הצעת את הרכב שלך לציבור במחיר של כ • ",strval(inputtext));
       SendClientMessage(playerid, yellow, string);
       SendClientMessage(playerid, orange,".\"Stop Sale\" - ולאחר מכן תבחר בשורה /Vehicle(/v) - על מנת לעצור את מכירת הרכב");
	   Update3D(Vehicle_Info[playerid][CarID], VehicleInfo[Vehicle_Info[playerid][CarID]][Buyable]);
       return 1;
	}
    if(dialogid == 100 && response)
    {
	   new sfile[126];
//	   SendClientMessage(playerid, orange, ",אל תשכח לשמור על הכסף שלך! הכסף זה הדבר העיקרי בשרת ולעומת שרתים אחרים קשה להשיג אותו *");
//	   SendClientMessage(playerid, orange, "!את הכסף תשיגו מהריגות במיוחד עבודות, ופעיליות, תזכרו כל דולר חשוב בשרת הזה, תשדלו להפקיד את הכסף כמה שיותר מהר *");
//	   SendClientMessage(playerid, orange, "/buytele(/bt) - על מנת ליצור יותר עניין בשרת את השיגורים שלך תצטרכו לקנות, כל שיגור עולה 100$ קניית שיגור בעזרת הפקודה *");
//	   SendClientMessage(playerid, lightblue, "!שיהיה לך משחק מהנה, ואל תשכח לשחק את המשחק, אחרת לא תהנה");
	   format(sfile, sizeof sfile, _fileprivate "setting_%s.ini", GetName(playerid));
       format(string, sizeof string, " » %s :התאריך ההתחברות שלך - %s בשעה", GetTimeAsString(':', 1), GetDateAsString('/', 1));
       SendClientMessage(playerid, pink, string);
	   format(string, sizeof string, " » %s :התאריך האחרון שבו הופעת בשרתינו - %s בשעה", dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Time"), dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Date"));
       SendClientMessage(playerid, pink, string);
       format(string, sizeof string, " » %i - ימים שעברו מאז ההתחברות האחרונה שלך", DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Date"), GetDateAsString('/', 1)));
       format(string, sizeof string, " » Last Connect IP: %s » Currently IP: %s » Automatic Login By IP: %s", dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_IP"), GetIP(playerid), dini_Bool(sfile, "autoLogin")? ("YES") : ("NO"));
       if(DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connected_Date"), GetDateAsString('/', 1)) >= 1) SendClientMessage(playerid, pink, string);
       SendClientMessage(playerid, lightblue, "!התחברת בהצלחה, שיהיה לך משחק מהנה, תשמור על הכסף שלך, אל תשכח שזה הדבר החשוב במוד");
       dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Date", GetDateAsString('/', 1));
       dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_Time", GetTimeAsString(':', 1));
       dini_Set(getPlayerFile(playerid, _fileusers), "Last_Connected_IP", GetIP(playerid));
       if(dini_Int(getPlayerFile(playerid, _filestats),"Vehicle_ID") != 0)
	   {
	       Vehicle_Info[playerid][CarID] = dini_Int(getPlayerFile(playerid, _filestats),"Vehicle_ID");
	       SendClientMessage(playerid, yellow, "/Vehicle(/v) - אל תשכח שיש לך רכב, תשתמש בו, בעזרת הפקודה");
	   }
       giveVehicleToPlayer(playerid);
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
      format(string, sizeof string, "   %s(#%03i) - כל האפשרויות התייחסו לשחקן", GetName(clickedplayerid), clickedplayerid);
      ShowPlayerDialog(playerid, 7, 2, string, " • (1) Private Message(PM)\n • (2) Stats\n • (3) Pay (Give Money)\n • (4) Report","בחר","ביטול");
	  return 1;
   }
   else showStats(playerid, playerid, 0);
   return 1;
}
function(OnPlayerPrivmsg(playerid, recieverid, text[], name[], name2[]))
{
   new string[128];
   if(PlayerInfo(spaming[playerid][1]) && !IsPlayerAdmin(playerid))
   {
	  error(playerid, " • הודעה פרטית אחת כל 2 שניות");
	  PlayerInfo(onClick[playerid]) = recieverid;
	  ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " » Private Messsage - הודעה פרטית",".אנא הקלד את ההודעה פרטית שלך ולחץ שלח","שלח","ביטול");
	  return 0;
   }
   if(playerid == recieverid && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ".אינך יכול לשלוח הודעה פרטית לעצמך");
   format(string, sizeof string, _fileprivate "setting_%s.ini", name);
   if(dini_Bool(string, settings[3]) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, red, ".שחקן זה חסם את תיבת ההודעות הפרטיות שלו");
   if(strfind(text, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true) != -1)
   {
	  error(playerid, ".אינך יכול לכתוב את הסיסמה שלך בהודעה פרטית");
	  return 0;
   }
   if(!PlayerInfo(logged[playerid]))
   {
      format(string, sizeof string, dini_Exists(getPlayerFile(playerid, _fileusers))? ("/login :אתה חייב להתחבר לפני שתעשה פעולה זו ,%s") : ("/register :אתה חייב להירשם לפני שתעשה פעולה זו ,%s"), name);
      error(playerid, string);
      return 0;
   }
   if(isTextIP(text) == 1)
   {
	  error(playerid, ".של שרת מתחרה בשרתינו IP אינך יכול לפרסם");
	  format(string, sizeof(string), "Anti IP: %s (id: %d) tried to write (PM): \"%s\"", name, playerid, text);
	  SendClientMessageToAdmins(red, string);
	  return 0;
   }
   format(string, sizeof string," > • %s (%03d) %s", name2, recieverid, text);
   SendClientMessage(playerid, darkblue, string);
   format(string, sizeof string," > • %s (%03d): %s", name, playerid, text);
   SendClientMessage(recieverid, 0xffff00ff, string);
   format(string, sizeof string, _fileprivate "setting_%s.ini", name);
   if(dini_Bool(string, settings[6]))
   {
     format(text, 128, "  \"%s\"", text);
     format(string, sizeof string, "%s(#%03i) - קיבלת הודעה פרטית מ", name, playerid);
     ShowPlayerDialog(recieverid, 22, DIALOG_STYLE_INPUT, string, text, "השב", "סגור");
     PlayerInfo(onClick2[recieverid]) = playerid;
     return 1;
   }
   PlayerInfo(spaming[playerid][1]) = 1;
   SetTimerEx("spam", 2000, 0, "ii", playerid, 1);
   return 1;
}
function(spam(playerid, spamid))
{
   PlayerInfo(spaming[playerid][spamid]) = 0;
   return 1;
}
function(OnPlayerText(playerid, text[]))
{
   new string[128], _string[3][128];
   if(PlayerInfo(spaming[playerid][0]) && !IsPlayerAdmin(playerid))
   {
	  error(playerid, " • הודעה אחת כל 2 שניות");
	  return 0;
   }
   if(!PlayerInfo(logged[playerid]))
   {
      format(string, sizeof string, dini_Exists(getPlayerFile(playerid, _fileusers))? ("/login :אתה חייב להתחבר לפני שתעשה פעולה זו ,%s") : ("/register :אתה חייב להירשם לפני שתעשה פעולה זו ,%s"), GetName(playerid));
      error(playerid, string);
      return 0;
   }
   if(strfind(text, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true) != -1)
   {
	  error(playerid, ".אינך יכול לכתוב את הסיסמה שלך בצ'אט");
	  return 0;
   }
   if(isTextIP(text))
   {
	  error(playerid, ".של שרת מתחרה בשרתינו IP אינך יכול לפרסם");
	  format(string, sizeof string, "Anti IP: %s (id: %d) tried to write (Public Chat): \"%s\"", GetName(playerid), playerid, text);
	  SendClientMessageToAdmins(red, string);
	  return 0;
   }
   if(text[0] == '@' && isPlayerInClan(playerid))
   {
	   format(string, sizeof string, "@ %s [CLVL %d | ID: %i] %s", GetName(playerid), getPlayerClanLevel(playerid), playerid, text[1]);
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
   format(_string[2], 128, "[%03d%s] %s", playerid, _string[1], text);
   for(new i = 0; i < MAX_PLAYERS; i++) if(PlayerInfo(logged[i])) SendPlayerMessageToPlayer(i, playerid, _string[2]);
   PlayerInfo(spaming[playerid][0]) = 1;
   SetTimerEx("spam", 2000, 0, "ii", playerid, 0);
   return 0;
}
function(OnPlayerSpawn(playerid))
{
   new rand = random(sizeof SAMP), string[126];
   if(!PlayerInfo(inDM[playerid]))
   {
      SetPlayerInterior(playerid, 0);
	  SetPlayerPos(playerid, SAMP[rand][0], SAMP[rand][1], SAMP[rand][2]);
	  SetPlayerFacingAngle(playerid, SAMP[rand][3]);
   }
   if(dini_Int(getPlayerFile(playerid, _filebank), "TotalMoney") > richisland-1 && !dini_Int(getPlayerFile(playerid, _filebank), "rich"))
   {
	  SendHeader(playerid, "מזל טוב אתה עשיר");
	  SendClientMessage(playerid, green, ",מזל טוב, הינך עשיר, כעת אתה רשאי להיכנס לאי העשירים! הטבות מיוחדות למי שעשיר");
	  SendClientMessage(playerid, green, "/stats /rich /mode [7/rich] :כיף לך עכשיו, תוכל להינות ממגוון הטבות, על מנת לקבל יותר פרטים");
	  format(string, sizeof string, "!שהפך להיות עשיר! כעת הוא נהנה ממגוון הטבות, רוצים להיות גם עשירים? השיגו כמה שיותר כסף %s - שלום לכולם ומזל טוב ל", GetName(playerid));
	  SendClientMessageToAll(orange, string);
	  SendClientMessageToAll(orange, "/rich /mode [7/rich] - על מנה לקבל עוד פרטים על אי העשירים");
	  dini_IntSet(getPlayerFile(playerid, _filebank), "rich", 1);
	  dini_IntSet(_rich, "Total", dini_Int(_rich, "Total")+1);
	  format(string, sizeof string, "%i", dini_Int(_rich, "Total"));
	  dini_Set(_rich, string, GetName(playerid));
   }
   PlayerInfo(firsts[playerid]) = 0;
   _SetPlayerHealth(playerid, 100.0);
   ClearAnimations(playerid);
   ResetPlayerWeapons(playerid);
   GivePlayerWeapons(playerid);
   if(DaysBetweenDates(dini_Get(getPlayerFile(playerid, _fileusers), "Last_Money_Date"), GetDateAsString('/', 1)) >= 1)
   {
      dini_Set(getPlayerFile(playerid, _fileusers), "Last_Money_Date", GetDateAsString('/', 1));
      SendClientMessage(playerid, orange, " /bank - שים לב כדאי לך להפקיד את הכסף הזה בבנק! אתה מקבל כסף פעם ביום, כל יום אתה מקבל 1500$, לך תפקיד בבנק");
	  _GivePlayerMoney(playerid, 1500);
   }
   PlayerInfo(cOkdie[playerid]) = 0;
   if(isPlayerInClan(playerid) && dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin") != -1) SetPlayerSkin(playerid,dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin"));
   if(isPlayerInClan(playerid)) setPlayerClanColor(playerid);
   if(dini_Int(VIPFile(playerid),"Color")) SetPlayerColor(playerid, VIPColor);
   if(dini_Exists(ClanPlayerFile(playerid)) && GetPlayerState(playerid) != 7)
   {
       strmid(pClan[playerid], dini_Get(ClanPlayerFile(playerid),"Clan_Name"),0,strlen(dini_Get(ClanPlayerFile(playerid),"Clan_Name")));
       if(!dini_Exists(ClanFile(pClan[playerid])))
	   {
	        dini_Remove(ClanPlayerFile(playerid));
	        error(playerid, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(playerid), false)? (".שלום לך בעלים של קלאן, הקלאן שלך נמחק וקיבלת פיצוי כספי, על מנת להגיש תלונה צלם תמונה זו") : (".הוצאת מהקלאן אוטומטית על ידי מערכת השרת, כנראה האדמין מחק את הקלאן שלך, צלם תמונה זו"));
	        SendClientMessage(playerid, orange,"#Error: 0001");
	        if(!strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(playerid), false)) _GivePlayerMoney(playerid, clanCost);
	   }
   }
   if(PlayerInfo(inDM[playerid]) > 0)
   {
       new Randm = random(sizeof DMPostion);
	   SetPlayerPos(playerid, DMPostion[Randm][0], DMPostion[Randm][1], DMPostion[Randm][2]);
	   SendClientMessage(playerid, 0x0F482FF,"/dm :שוגרת לאיזור די-אם חזרה בספון, על מנת לצאת");
	   SetPlayerVirtualWorld(playerid,2);
	   SetPlayerInterior(playerid,0);
	   ResetPlayerWeapons(playerid);
	   GivePlayerWeapon(playerid, 35, 99999);
   }
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
   new string[126], x[MAX_PLAYERS];
   if(killerid == INVALID_PLAYER_ID) SendDeathMessage(INVALID_PLAYER_ID,playerid,reason);
   else SendDeathMessage(killerid,playerid,reason);
   if(killerid == INVALID_PLAYER_ID || IsPlayerConnected(killerid)) PlayerInfo(cOkdie[playerid]) = 1;
   if(isPlayerInClan(killerid)) dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Kills",dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Kills") + 1);
   if(playerid != INVALID_PLAYER_ID && killerid != playerid && IsPlayerConnected(killerid) && !isPlayerVIP(playerid)) dini_IntSet("/VIP/Stats.txt", "Kills",dini_Int("/VIP/Stats.txt", "Kills")+1);
   if(killerid != playerid && IsPlayerConnected(killerid))
   {
       dini_IntSet(getPlayerFile(killerid, _filestats), "Kills", dini_Int(getPlayerFile(killerid, _filestats), "Kills")+1);
       dini_IntSet(getPlayerFile(playerid, _filestats), "Deaths", dini_Int(getPlayerFile(playerid, _filestats), "Deaths")+1);
       SetPlayerWantedLevel(killerid, GetPlayerWantedLevel(killerid) + 1);
       WLCheck(7), WLCheck(8), WLCheck(9), WLCheck(10), WLCheck(11), WLCheck(12), WLCheck(13), WLCheck(14), WLCheck(15);
       x[playerid] = _GetPlayerMoney(playerid);
	   if(x[playerid] > 0)
	   {
	       _ResetPlayerMoney(playerid);
	       _GivePlayerMoney(killerid, x[playerid]);
	       format(string, sizeof string, "  Updates: !לקח לך %i$ תנקום בו %s :השחקן", x[playerid], GetName(killerid));
		   SendClientMessage(playerid, yellow, string);
	   }
       if GetPlayerWantedLevel(killerid) > 2 && GetPlayerWantedLevel(killerid) <= 12 *then
	   {
		   format(string, sizeof string,"!%d הוא מבוקש, רמת מבוקשות ,%s - השחקן",GetPlayerWantedLevel(killerid), GetName(killerid));
		   SendClientMessageToAll(yellow,string);
		   format(string, sizeof string,"$%d - שחקן אשר יהרוג אותו, יקבל פרס",GetPlayerWantedLevel(killerid)*(200));
		   SendClientMessageToAll(red,string);
	   }
	   if GetPlayerWantedLevel(playerid) > 2 && killerid != INVALID_PLAYER_ID *then
       {
		   format(string, sizeof string,"!$%d וזכה בפרס של כ %s הרג את המבוקש ,%s - השחקן",GetPlayerWantedLevel(playerid)*(200), GetName(playerid), GetName(killerid));
		   SendClientMessageToAll(yellow,string);
		   _GivePlayerMoney(killerid, GetPlayerWantedLevel(playerid)*(200));
		   format(string,sizeof string,"~r~+%d$", GetPlayerWantedLevel(playerid)*(200));
		   GameTextForPlayer(killerid, string, 3000, 1);
       }
       return 1;
   }
   if(InArea(killerid, 81.8207, -73.1855, 2041.7819, 1921.5438) && strcmp(GetName(killerid),dini_Get("/KingCastle.ini","Name"), true))
   {
       Castle_Kills[killerid] ++;
	   format(string,sizeof(string)," New's: • » !%d/5 :אנשים שהרגת בתוך הטירה ",Castle_Kills[killerid]);
	   SendClientMessage(killerid, sgba2hex(255,133,1,200),string);
	   format(string,sizeof(string),"!כאשר תגיע ל - 5 הריגות רצופות תקבל 2000$");
	   if(Castle_Kills[killerid] != 5) SendClientMessage(killerid,sgba2hex(255,133,1,200),string);
	   if(Castle_Kills[killerid] == 5)
	   {
             SendClientMessage(killerid,sgba2hex(255,133,1,200), "!ברוכתיי, אתה מלך הטירה, קיבלת 2000$");
			 SendClientMessage(killerid,sgba2hex(255,133,1,200),".מעכשיו את/ה מלך הטירה, תהנה");
			 format(string,sizeof string,"  Updates: !הפך למלך הטירת המכושפת - %s",GetName(killerid));
			 SendClientMessageToAll(orange, string);
			 Castle_Kills[killerid] = 0;
			 _GivePlayerMoney(playerid, 2000);
			 format(string, sizeof string, "%s", GetName(playerid));
			 dini_Set("/KingCastle.ini","Name",string);
	   }
   }
   if(!inDM[playerid] || !inDM[playerid]) fakeKill(playerid, killerid);
   checkNewLevel(killerid);
   actFail(playerid);
   return 1;
}
function(OnPlayerKeyStateChange(playerid, newkeys, oldkeys))
{
   if(PlayerInfo(isafk[playerid])) setAFK(playerid, false);
   return 1;
}
function(OnPlayerCommandText(playerid, cmdtext[]))
{
   new cmd[256], idx, string[256], string2[126];
   cmd = strtok(cmdtext, idx);
   if(richCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(actsCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(mainCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(vipCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(clanCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(weaponsCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(vehicleCommands(playerid, cmdtext, cmd, idx, string)) return 1;
   if(insetsCommands(playerid, cmdtext, cmd, idx, string) && IsPlayerAdmin(playerid)) return 1;
   format(string2, sizeof string2, " [/Mode/Help] - לא קיימת במערכת, אנא העזר בפקודה /%s - הפקודה", cmd[1]);
   return SendClientMessage(playerid, white, string2);
}
stock richCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   if(!strcmp(cmd, "/rich", true))
   {
      new anOcmd[256];
	  anOcmd = strtok(cmdtext, idx);
	  if(!strlen(anOcmd))
	  {
		  SendHeader(playerid, "Rich Island - אי העשירים");
          SendClientMessage(playerid, 0x16EB43ff, " • /rich island - על מנת להשתגר לאי העשירים");
          SendClientMessage(playerid, 0x16EB43ff, " • /rich gate - על מנת לפתוח את השער הקרוב אליך באי העשירים");
          SendClientMessage(playerid, 0x16EB43ff, " • /rich memmbers - על מנת לראות את השחקנים העשירים בשרת");
          return 1;
	  }
	  if(!strcmp(anOcmd, "island", true))
	  {
	     if(dini_Int(getPlayerFile(playerid, _filebank), "TotalMoney") < richisland) return error(playerid, "!אתה לא עשיר");
	     return 1;
	  }
	  if(!strcmp(anOcmd, "gate", true))
	  {
	     if(dini_Int(getPlayerFile(playerid, _filebank), "TotalMoney") < richisland) return error(playerid, "!אתה לא עשיר");
	     return 1;
	  }
	  if(!strcmp(anOcmd, "memmbers", true))
	  {
		 format(string, sizeof string, "%i - אנשים עשירים", dini_Int(_rich, "Total"));
		 SendHeader(playerid, string);
		 for(new i = 1; i < dini_Int(_rich, "Total"); i++)
		 {
			 format(string, sizeof string, "%i", i);
			 format(string, sizeof string, "%i) %s", i, dini_Get(_rich, string));
			 SendClientMessage(playerid, orange, string);
		 }
		 return 1;
	  }
	  return error(playerid, ".אין פקודה כזאת במערכת העשירים");
   }
   return 0;
}
stock AddStaticVehicle_(modelid, Float:spawn_x, Float:_spawn_y, Float:spawn_z, Float:angle, color1, color2, state_ = 1, prices = 300000)
{
  new string[128];
  count_vehicles++;
  format(string, sizeof string, "Users/Vehicle/IDs/%i.ini", count_vehicles);
  AddStaticVehicle(modelid, Float:spawn_x, Float:_spawn_y, Float:spawn_z, Float:angle, color1, color2);
  if(!dini_Exists(string))
  {
     dini_Create(string);
	 dini_IntSet(string, "states", state_);
	 dini_IntSet(string, "price", prices);
	 dini_IntSet(string, "tax", 15);
	 dini_Set(string, "own", "None");
  }
  return 1;
}
stock actsCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   if(!strcmp(cmd, "/glass", true))
   {
	  new anOcmd[256];
	  anOcmd = strtok(cmdtext, idx);
	  if(!strlen(anOcmd))
	  {
		  SendHeader(playerid, "Glass Game - משחק זכוכיות");
          SendClientMessage(playerid, 0x16EB43ff, " • /glass join - על מנת להרשם למשחק");
          SendClientMessage(playerid, 0x16EB43ff, " • /glass leave - על מנת לפרוש מהמשחק");
          SendClientMessage(playerid, 0x16EB43ff, " • /glass data - על מנת לבדוק את נתוני המשחק");
          if(IsPlayerAdmin(playerid)) SendClientMessage(playerid, orange, " • /glass start - על מנת להפעיל את המשחק || /glass cancel - על מנת לבטל את הפעילות");
          return 1;
	  }
	  if(!strcmp(anOcmd, "join", true))
	  {
         if(!Glass_On) return error(playerid, ".כרגע Glass - אין משחק");
         if(Glass_On == 2) return error(playerid, ".כבר התחילה Glass - משחק");
         if(GlassPlayers == MAX_GLASS_PLAYERS) return error(playerid, ".כל המקומות במשחק נתפסו");
         if(PlayerInfo(InGlass[playerid])) return error(playerid, "/glass leave :על מנת לפרוש ,Glass - אתה רשום כבר למשחק");
         PlayerInfo(InGlass[playerid]) = 1;
         GlassPlayers ++;
         format(string, sizeof string, "  Updates: !אתה משתתף, מספר %02i בהצלחה במשחק Glass - הצטרפת למשחק, ה", GlassPlayers);
         SendClientMessage(playerid, orange, string);
         return 1;
	  }
	  if(!strcmp(anOcmd, "leave", true))
	  {
         if(!PlayerInfo(InGlass[playerid])) return error(playerid, "Glass - אתה בכלל לא רשום למשחק");
         if(Glass_On != 2 && Glass_On != 1) return error(playerid, ".כעת Glass אין בכלל משחק");
         if(Glass_On == 2) OnPlayerSpawn(playerid);
         actFail(playerid);
         SendClientMessage(playerid, orange, "  Updates: !שיהיה לך המשך משחק נעים Glass - פרשת ממשחק ה");
		 return 1;
	  }
	  if(!strcmp(anOcmd, "data", true))
	  {
		 if(!Glass_On) error(playerid, ".משחק זה לא פעיל עכשיו");
		 if(Glass_On != 0 && GlassPlayers != MAX_GLASS_PLAYERS && PlayerInfo(InGlass[playerid]) != 0) SendClientMessage(playerid, 0x24FF0AB9, "/glass join - משחק זה פעיל עכשיו, על מנת להצטרף למשחק");
		 if(Glass_On != 0 && GlassPlayers == MAX_GLASS_PLAYERS) SendClientMessage(playerid, orange, ".משחק זה פעיל כעת, אבל לצערנו אין מקום לעוד משתתפים, תודה צוות השרת");
		 if(Glass_On != 0 && PlayerInfo(InGlass[playerid])) SendClientMessage(playerid, 0x24FF0AB9, "/glass leave - אתה כבר רשום למשחק זה, על מנת לעזוב את המשחק");
         return 1;
	  }
	  if(!strcmp(anOcmd, "cancel", true) && IsPlayerAdmin(playerid))
	  {
		 if(!Glass_On) return error(playerid, ".משחק זה לא פעיל עכשיו");
		 actOver("glass", ".האדמין ביטל את פעילות הזכוכיות");
		 return 1;
	  }
      if(!strcmp(anOcmd, "start", true) && IsPlayerAdmin(playerid))
      {
         if(Glass_On) return error(playerid, ".כבר הופעל Glass המשחק");
         startglass();
         rand_glass = -1;
         for(new i = 0; i < sizeof is_fall_glass; i++) is_fall_glass[i] = 0;
         glass_object[1] = CreateObject(3859,1599.182,540.691,50.734,17.189,90.241,-85.703);
         glass_object[2] = CreateObject(3859,1604.459,541.126,50.734,17.189,90.241,-85.703);
         glass_object[3] = CreateObject(3859,1609.740,541.592,50.734,17.189,90.241,-85.703);
         glass_object[4] = CreateObject(3859,1593.917,540.313,50.734,17.189,90.241,-85.703);
         glass_object[5] = CreateObject(3859,1588.651,539.901,50.734,17.189,90.241,-85.703);
         glass_object[6] = CreateObject(3859,1589.104,534.080,50.734,17.189,90.241,-85.703);
         glass_object[7] = CreateObject(3859,1594.382,534.463,50.734,17.189,90.241,-85.703);
         glass_object[8] = CreateObject(3859,1599.630,534.945,50.734,17.189,90.241,-85.703);
         glass_object[9] = CreateObject(3859,1604.911,535.246,50.734,17.189,90.241,-85.703);
         glass_object[10] = CreateObject(3859,1610.181,535.709,50.734,17.189,90.241,-85.703);
         glass_object[11] = CreateObject(3859,1589.528,528.184,50.734,17.189,90.241,-85.703);
         glass_object[12] = CreateObject(3859,1594.824,528.536,50.734,17.189,90.241,-85.703);
         glass_object[13] = CreateObject(3859,1600.108,529.050,50.734,17.189,90.241,-85.703);
         glass_object[14] = CreateObject(3859,1605.373,529.398,50.734,17.189,90.241,-85.703);
         glass_object[15] = CreateObject(3859,1610.574,529.680,50.734,17.189,90.241,-85.703);
         glass_object[16] = CreateObject(3859,1589.952,522.331,50.734,17.189,90.241,-85.703);
         glass_object[17] = CreateObject(3859,1595.288,522.615,50.734,17.189,90.241,-85.703);
         glass_object[18] = CreateObject(3859,1600.492,523.186,50.734,17.189,90.241,-85.703);
         glass_object[19] = CreateObject(3859,1605.787,523.562,50.734,17.189,90.241,-85.703);
         glass_object[20] = CreateObject(3859,1611.083,523.874,50.734,17.189,90.241,-85.703);
		 return 1;
      }
	  return error(playerid, "Glass - אין פקודה כזאת במשחק ה");
   }
   return 0;
}
stock vehicleCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   createCommand("/rentcar")
   {
   		new vid = GetPlayerVehicleID(playerid), rent_tmp[256],date[3];
   		format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",vid);
        rent_tmp = strtok(cmdtext, idx);
   		if(!IsPlayerInAnyVehicle(playerid)) return error(playerid,".אתה לא נמצא בשום רכב");
    	if(RentInfo[playerid][CarID] != 0) return error(playerid,".יש לך כבר רכב מושכר");
    	if(Vunoccupied[vid]) return error(playerid,!strcmp(dini_Get(rent_file,"Owner"),GetName(playerid),true)? (".רכב זה כבר מושכר על ידך") : (".רכב זה מושכר כבר על ידי מישהו אחר"));
    	if(!CarToRent[vid]) return error(playerid,".רכב זה אינו להשכרה");
    	if(!strlen(rent_tmp) || strval(rent_tmp) < 1 || strval(rent_tmp) > 10) return SendClientMessage(playerid, white,"Usage: /RentCar [Days: 1-10]");
    	new Days = strval(rent_tmp);
    	if(_GetPlayerMoney(playerid) < PriceRentVehicle[vid]*Days)
		{
		    format(string,sizeof string,".%d - על מנת להשכיר רכב זה למספר ימים של כ", Days);
		    SendClientMessage(playerid,orange,string);
		    format(string,sizeof string,".%d$ :אתה צריך לפחות סכום כסף של כ",PriceRentVehicle[vid]*Days);
		    SendClientMessage(playerid,yellow,string);
		    return 1;
		}
        Vunoccupied[vid] = 1;
	    RentInfo[playerid][CarID] = vid;
    	strmid(dini_Get(rent_file,"Owner") , GetName(playerid), 0, strlen(GetName(playerid)), 255);
    	dini_Set(rent_file, "Owner", GetName(playerid));
		format(string,sizeof string,".%d$ :שכרת רכב זה תמורת",PriceRentVehicle[vid]*Days);
		SendClientMessage(playerid,orange,string);
		format(string,sizeof string,".%s :סוג הרכב",VehiclesName[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
		SendClientMessage(playerid,yellow,string);
		SendClientMessage(playerid,0x16EB43FF,"/RentHelp :על מנת לקבל עזרה מורכת על המערכת השכרה רכבים");
		_GivePlayerMoney(playerid,-1*PriceRentVehicle[vid]*Days);
		dini_Set(rent_file,"Owner",GetName(playerid));
		getdate(date[2],date[1],date[0]);
		format(string,sizeof string,"%d.%d.%d",date[0],date[1],date[2]);
		dini_Set(rent_file,"DateOfBuy",string);
	    dini_IntSet(rent_file,"Days",Days);
		return 1;
   }
   if(!strcmp(cmd, "/stoprent", true))
   {
		new idc = RentInfo[playerid][CarID];
		if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
		else
		{
		     format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",RentInfo[playerid][CarID]);
		     dini_Set(rent_file,"Owner","None");
		     Vunoccupied[idc] = 0;
		     RentInfo[playerid][CarID] = 0;
		     SendClientMessage(playerid,yellow,"!הפסקת את השכרת הרכב שלך בהצלחה");
		}
		return 1;
   }
   createCommand("/rresetcar")
   {
      if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
	  if(GetPlayerVehicleID(playerid) == RentInfo[playerid][CarID]) return error(playerid,".אתה נמצא ברכב המשוכר שלך");
	  if(IsPlayerInAnyVehicle(playerid) == 1) return error(playerid,".אנא צא מהרכב על מנת לזמן את הרכב המושכר שלך");
	  SetVehicleToRespawn(RentInfo[playerid][CarID]);
	  SetVehicleHealth(RentInfo[playerid][CarID],1000.0);
	  SendClientMessage(playerid,yellow,"...עוד 5 שניות הרכב המושכר שלך יאופס, אנא המתן/י");
	  SetTimerEx("RepairRentCar",5000,0,"i",playerid);
	  GetVehiclePos(RentInfo[playerid][CarID],RentInfo[playerid][vPosv][0],RentInfo[playerid][vPosv][1],RentInfo[playerid][vPosv][2]);
	  SetPlayerPos(playerid, 346.8638, 309.1008, 999.1557);
	  SetPlayerFacingAngle(playerid, 180);
	  SetPlayerInterior(playerid,6);
	  TogglePlayerControllable(playerid,0);
	  return 1;
   }
   createCommand("/rlockv")
   {
       if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
       if(VLocked[RentInfo[playerid][CarID]]) return error(playerid,".הרכב שלך פתוח כבר נעול");
       for(new i = 0 ;i < MAX_PLAYERS; i++) if(i != playerid) SetVehicleParamsForPlayer(RentInfo[playerid][CarID],i, 0, 1);
       SendClientMessage(playerid,orange,".המכונית המושכרת שלך ננעלה בהצלחה");
       VLocked[RentInfo[playerid][CarID]] = 1;
       return 1;
   }
   createCommand("/runlockv")
   {
  	   if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
	   if(!VLocked[RentInfo[playerid][CarID]]) return error(playerid,".הרכב שלך פתוח כבר פתוח");
       for(new i = 0 ;i < MAX_PLAYERS; i++) if(i != playerid) SetVehicleParamsForPlayer(RentInfo[playerid][CarID],i, 0, 0);
	   SendClientMessage(playerid,orange,".המכונית המושכרת שלך נפתחה בהצלחה");
	   VLocked[RentInfo[playerid][CarID]] = 0;
	   return 1;
   }
   createCommand("/rcallcar")
   {
  	   if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
  	   if(GetPlayerVehicleID(playerid) == RentInfo[playerid][CarID]) return error(playerid,".אתה נמצא ברכב המשוכר שלך");
  	   if(IsPlayerInAnyVehicle(playerid)) return error(playerid,".אנא צא מהרכב על מנת לזמן את הרכב המושכר שלך");
  	   for(new o = 0; o < MAX_PLAYERS; o++) if(IsPlayerInVehicle(o,RentInfo[playerid][CarID]))
  	   {
  	      GetPlayerPos(playerid,RentInfo[o][vPosv][0],RentInfo[o][vPosv][1],RentInfo[o][vPosv][2]);
		  SetPlayerPos(o,RentInfo[o][vPosv][0]+3.0,RentInfo[o][vPosv][1]-1.0,RentInfo[o][vPosv][2]);
		  format(string,sizeof string,".שיגר אליו את הרכב שלו, הליכה נעימה %s - השחקן",GetName(playerid));
		  SendClientMessage(o,white,string);
  	   }
	   GetPlayerPos(playerid,RentInfo[playerid][vPosv][0],RentInfo[playerid][vPosv][1],RentInfo[playerid][vPosv][2]);
	   _PutPlayerInVehicle(playerid,RentInfo[playerid][CarID],0);
	   SetTimerEx("BackVehicleToPos",800,0,"i",playerid);
	   format(string,sizeof string,".המושכר שלך בהצלחה %s - שיגרת את הרכב ה",VehicleName[RentInfo[playerid][CarID]]);
	   SendClientMessage(playerid,orange,string);
	   SendClientMessage(playerid,yellow,"/RResetCar :במידה והרכב לא הגיע, אפס את הרכב המושכר שלך");
	   return 1;
	}
   createCommand("/RentList")
   {
	   new count_vehicle = 0, date[3], dstring[128], days_e = 0;
   	   if(!getRentVehicleCount()) return error(playerid,".אף אחד בשרת לא השכיר רכב");
   	   format(string,sizeof string,"--- %d :רכבים המושכרים בשרת ---",getRentVehicleCount());
   	   SendClientMessage(playerid,white,string);
   	   for(new o = 0; o < xvehicles+1; o++)
	   {
           format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",o);
           if(dini_Exists(rent_file))
           {
               if(strcmp(dini_Get(rent_file,"Owner"),"None",true))
		       {
                    format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",o);
                    getdate(date[2],date[1],date[0]);
                    format(dstring,sizeof dstring,"%d.%d.%d",date[0],date[1],date[2]);
                    days_e = dini_Int(rent_file,"Days")-DaysBetweenDates(dini_Get(rent_file,"DateOfBuy"),dstring);
                    count_vehicle++;
					format(string,sizeof string,"- %i. Rent Info - Type: %s | Owner: %s | Days: %i | VehicleID: %i",count_vehicle,dini_Get(rent_file,"VehicleName"),dini_Get(rent_file,"Owner"),days_e,o);
   			        SendClientMessage(playerid,0x16EB43FF,string);
		       }
           }
	   }
	   return 1;
   }
   if(!strcmp(cmd, "/v", true) || !strcmp(cmd, "/vehicle", true))
   {
	  new tstring[1000], bstring[1000];
	  for(new x = 0; x < sizeof VehicleParameter; x++)
	  {
          format(tstring, sizeof tstring, " • (%i) %s\n", x, VehicleParameter[x]);
	      strcat(bstring, tstring);
	  }
	  ShowPlayerDialog(playerid, 24, 2, "Vehicle System // מערכת רכבים", bstring, "בצע", "בטל");
  	  return 1;
   }
   return 0;
}
stock mainCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   new anOcmd[256];
   if(!strcmp(cmd, "/kcastle", true))
   {
      SendClientMessage(playerid, black, "___________________________________________________________");
	  SendClientMessage(playerid, yellow,":המלך של הטירה המכושפת");
	  format(string,sizeof string,"  Updtaes: %s",dini_Get("/KingCastle.ini","Name"));
	  SendClientMessage(playerid,orange,string);
	  SendClientMessage(playerid, black, "___________________________________________________________");
	  return 1;
   }
   if(!strcmp(cmd, "/sss", true))
   {
       SetPlayerWantedLevel(playerid, GetPlayerWantedLevel(playerid) + 1);
       WLCheck(7), WLCheck(8), WLCheck(9), WLCheck(10), WLCheck(11), WLCheck(12), WLCheck(13), WLCheck(14), WLCheck(15);
       return 1;
   }
   if(!strcmp(cmd, "/mode", true))
   {
	  new plast[128];
      anOcmd = strtok(cmdtext, idx);
      if(!strlen(anOcmd)) mainCommands(playerid, cmdtext, "/help mode", idx, string);
      format(plast, sizeof plast, "/help mode %i", strval(anOcmd));
      mainCommands(playerid, cmdtext, plast, idx, string);
	  return 1;
   }
   if(!strcmp(cmd, "/help", true))
   {
	  anOcmd = strtok(cmdtext, idx);
	  if(!strlen(anOcmd))
	  {
	     SendHeader(playerid, "Main Help - עזרה ראשית");
	     SendClientMessage(playerid, 0xff0000f, "  " forum " - כתובת הפורום");
	     SendClientMessage(playerid, pink,  "  /help [topic] - אנא בחר נושא שעליו תרצה לקבל מידע");
	     SendClientMessage(playerid, red, "  /help [target/2] - מטרת המוד / משימת המוד | /help [features/mode/1] - מאפייני המוד");
	     SendClientMessage(playerid, red, "  /help [levels/4] - רמות | /help [tips/3] - טיפים");
	     SendClientMessage(playerid, red, "  /help [server/6] - מידע על השרת | /help [info/5] - מידע כללי");
         SendClientMessage(playerid, 0xffff00ff, "  " version "(" namemode ")" " - גרסה נוכחית של המוד");
         SendClientMessage(playerid, orange, "  /setting - לשינוי הגדרות המשחק | /editprofile - לעריכת הפרופיל האישי שלך");
         return 1;
	  }
	  if(_equal(anOcmd, "features") || _equal(anOcmd, "mode") || strval(anOcmd) == 1)
	  {
		 anOcmd = strtok(cmdtext, idx);
		 if(!strlen(anOcmd))
		 {
			 new _main = 0;
			 modeLine(playerid, " Teleports(1) • Bank(2) • Weapons(3) • Vehicle(4) • VIP(5) • Clan(6) • Rich Island(7) • Special Commands(8) ", ++_main);
			 modeLine(playerid, " DeathMatch Zone (9)", ++_main);
			 return 1;
		 }
		 if(equal_Mode(anOcmd, "teleports", "tele", 1))
		 {
			format(string, sizeof string, "%02i - כמות השיגורים שנותרה לך היא", dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports"));
            featureModeIn(playerid, "Teleports - שיגורים",
			" :פקודות שיגורים",
			" /mteles • /t • /teleports" ,
			" ,שלום לך, בעזרת השיגורים בשרת תוכל לזוז ממקום למקום במהירות רבה",
			" ,בשרתינו יש מגוון שיגורים למקומות ייחודיים, מקומות טיולים, מקומות מלחמה, ועוד",
			" .חלק מהשיגורים יהיו מרמות מסויימות, כמה שאתה רמה יותר גבוה - יותר שיגורים",
			" .שימו לב, לא ניתן להשתגר במהלך קרב, לא ניתן להשתגר מרמת חיים מסויימת - הכל תלוי ברמה",
			"דרך אגב, על מנת להשתגר צריך לקנות שיגורי",
			"/buyteles(bt) :דרך אגב, על מנת להשתגר צריך לקנות שיגורים, כל שיגור עולה 100$ על מנת לקנות שיגור",
			string,
			"None",
			"None");
			return 1;
		 }
		 if(equal_Mode(anOcmd, "bank", "banks", 2))
		 {
            featureModeIn(playerid, "Bank - בנק",
			" :פקודות בנק",
			" /banks",
			",בבנק תוכל לשמור כסף, אשר יישמר גם לאחר שתמות",
			",במידה ואתה רשום, הכסף יישמר לתמיד",
			".בבנק יש לך מגוון אפשרויות, כגון: הלוואות, כרטיס אשראי, ועוד *",
			"None",
			"None",
			"None");
			return 1;
		 }
		 if(equal_Mode(anOcmd, "weapons", "weap", 3))
		 {
            featureModeIn(playerid, "Weapons - נשקים",
			" :פקודות נשקים",
			" /buyweapon(bw) • /weaponlist(wl) • /dropweapon(dw) • /myweapons • /weapons",
			" ,שלום לך, אם הינך רוצה נשקים תמידיים שימשרו לך גם לאחר שתמות תצטרך להגיע לחנות נשקים",
			" ,בחנות יש לך מגוון נשקים, כל נשק סכום שונה ואפילו גם מרמה שונה",
			" /dw: אם הינך רוצה לזרוק אחד מהנשקים תשתמש בפקודה",
			"None",
			"None",
			"None",
			"None",
			"None",
			" Roye_Omer@Hotmail.com(E-mail + Messenger) :חסר לך נשק כלשהו? רוצה שיהיה עוד נשק מסויים בחנות נשקים? תיצור קשר עימנו *");
			return 1;
		 }
		 if(equal_Mode(anOcmd, "vehicle", "vehicles", 4))
		 {
            featureModeIn(playerid, "Vehicles - רכבים",
			" :פקודות רכבים",
			" /vehicle • /v" ,
			".במוד שלנו ניתן לקנות רכבים, אם תקנה רכב הוא יהיה שלך לתמיד",
			".במידה וקנית רכב, תוכל לשגר אותו תמיד אליך ולהשתמש בו",
			"!ניתקעת בלי רכב? שגר אליך את הרכב שלך",
			"None",
			"None",
			"None",
			"None",
			"None",
			".הערות: כל 30 יום תצטרך לשלם אגרת רכב על הרכב, במידה ולא תשלם הרכב שלך יימכר *");
			return 1;
		 }
		 if(equal_Mode(anOcmd, "vip", "veryimportantpepole", 5))
		 {
            featureModeIn(playerid, "VIP - אחמ\"ים",
			" :VIP פקודות",
			" /VIP • /VIPS" ,
			".מקבלים הרבה הטבות VIP - משתמשי ה",
			".רק לשחקנים שמשקיעים מאוד בשרת VIP האדמינים יכולים לתת משתמשי",
			".צ'אט השתמש ב - $ לפני כל הודעה VIP - על מנת להשתמש ב",
			"None",
			"None",
			"None",
			"None",
			"None",
			".הטבות: נשקים בחצי מחיר, שיגור למפקדה מיוחדת *");
			return 1;
		 }
		 if(equal_Mode(anOcmd, "clans", "clan", 6))
		 {
            featureModeIn(playerid, "Clans - קלאנים",
			" :פקודות קלאנים",
			" /clan • /clans • /hq • /og • /cg • /cwithdraw • /cdeposit • /cbinfo",
			"$" #clanCost " - כל מי שרוצה לפתוח קלאן חייב שיהיה לו ביד לפחות ",
			".כל קלאן בעל 10 שחקנים ומעלה רשאי לקבל מפקדה, לכל מפקדה יש הטבות",
			"None",
			"None",
			"None",
			"None",
			"None",
			"None",
			".הטבות: מפקדה, צ'אט מיוחד, שערים זזים, ועוד *");
			return 1;
		 }
         if(equal_Mode(anOcmd, "rich", "richisland", 7))
		 {
            featureModeIn(playerid, "Rich Island - אי העשירים",
			" :פקודות \"אי העשירים\"",
			" • /rich",
			" ,אי העשירים הינו אי הבנו בעולם אחר במשחק, לאי הזה רשאים להיכנס אנשים עשירים בלבד ",
			" \".חישוב של כל הכסף שהחזקת אי פעם ביד\" /stats :איך אתה יודע אם אתה עשיר? בעזרת הפקודה",
			"$" #richisland " :בשורה של למעלה סכום \"stats\" - על מנת להיות עשיר להתקבל לאי תצטרך שיהיה רשום לך ב",
			"None",
			"None",
			"None",
			"None",
			"None",
			".הטבות: מפקדה, צ'אט מיוחד, שערים זזים, ועוד *");
			return 1;
		 }
         if(equal_Mode(anOcmd, "specialcommands", "scommands", 8))
		 {
            featureModeIn(playerid, "Special Commands - פקודות מיוחדות",
			" :פקודות מיוחדות",
			" /bomb(4) • /god(10)",
			" ,כל עוד אתה עולה רמות ככה יש לך יותר פקודות חדשות, כל פקודה תעזור לך להגיע לטופ בשרת",
			" .איך עולים רמות? הורגים! פשוט מאד, משחק מהנה",
			"None",
			"None",
			"None",
			"None",
			"None",
			"None",
			" SA-MP.co.il - יש לך רעיון לעוד פקודות מיוחדות? תציעו בפורום שלנו *");
			return 1;
		 }
         if(equal_Mode(anOcmd, "deathmatch", "dm", 9))
		 {
            featureModeIn(playerid, "DeathMatch Zones - איזור הריגות",
			" :פקודות",
			" • /dm ( Needed atleast 10 kills!)",
			" ,איזורי הריגות מיוחדים, איזורי ההריגות נמצאים ב \"עולם אחר\" על מנת שלא יכולו להפריע לכם שחקנים אחרים",
			" .כל איזור הריגות יש סוג מלחמה שונה, כמו מלחמה אוויר, מלחמות עם נשקים כבדים, ועוד",
			" !שיהיה לכם משחק מהנה",
			"None",
			"None",
			"None",
			"None",
			"None",
			" SA-MP.co.il - יש לך עוד רעיונות לאיזורות מלחמה? כנס לפורום שלנו *");
			return 1;
		 }
		 return error(playerid, ".תפריט עזרה שגוי");
	  }
	  if(_equal(anOcmd, "target") || _equal(anOcmd, "objective") || strval(anOcmd) == 2)
	  {
		 SendHeader(playerid, "Target - מטרת המוד");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (1) לתת לכם השחקנים הנאה במהלך כל השחק");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (2) להרוג כמה שיותר אנשים ולעלות רמות");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (3) להגיע לרמת הכבוד המקסימלית");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (4) להיכנס לכנופיית פשע או למאפיה");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (5) להכיר דברים חדשים שעוד לא ראיתם לעולם");
		 SendClientMessage(playerid, red, " • !יש עוד מלא מטרות, לא נפרט על הכל, את השאר ניתן לכם לגלות לבד *");
		 return 1;
	  }
	  if(_equal(anOcmd, "tips") || _equal(anOcmd, "vices") || strval(anOcmd) == 3)
	  {
		 SendHeader(playerid, "Tips - טיפים");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (1) תעלה רמות כמה שיותר מהר, כל עוד אתה רמה גבוה יותר, ככה נפתחות בפניך יותר אפשרויות");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (2) הילחם בחבורות ולא לבד, תקים חבורות פשע ותנסה להשתלט על העיר");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (3) יש לך כסף הרבה כסף ביד? רוץ לבנק לשמור אותו");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (4) תקנה כמה שיותר נשקים אשר ישמשו אותך במהלך הקרבות ויעזרו לך לנצח");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (5) /setting - שנה את הגדרות המשחק שלך לפי מה שאתה אוהב");
		 SendClientMessage(playerid, 0xFFFF00AA, " • (6) /editprofile - תבנה לעצמך פרופיל, ככה אנשים יוכלו להכיר אותך");
		 SendClientMessage(playerid, red, " • (7) !הדבר הכי הכי חשוב במוד זה הכסף, בשרת שלנו קשה להשיג אותו אז שמרו עליו טוב טוב *");
		 return 1;
	  }
	  if(_equal(anOcmd, "levels") || _equal(anOcmd, "lvls") || strval(anOcmd) == 4)
	  {
		 new _text[256], next_line = 0;
		 format(string, sizeof string, "(Levels: %i) - מערכת רמות", sizeof var_Levels+1);
		 SendHeader(playerid, string);
		 SendClientMessage(playerid, brown, "  (דוגמה: (הריגות, רמה");
         _text = " ";
         for(new i = 0; i < sizeof var_Levels; i++)
         {
			format(string, sizeof string, "  (%i, %i) ", i+2, var_Levels[i]);
            strcat(_text, string);
            next_line++;
            if(next_line == 10)
            {
               SendClientMessage(playerid, yellow, _text);
               string = " ", next_line = 0, _text = " ";
            }
         }
         if(next_line >= 1) SendClientMessage(playerid, yellow, _text);
         SendClientMessage(playerid, pink, " • /mlevels(mlvls) - למידע על הרמות");
		 SendClientMessage(playerid, white, "--------------------------------------------------");
		 return 1;
	  }
	  if(_equal(anOcmd, "info") || strval(anOcmd) == 5)
	  {
	     SendHeader(playerid, "Mode Info - מידע המוד");
	     SendClientMessage(playerid, pink, "  - " scripter " - בונה הראשי של המוד");
	     SendClientMessage(playerid, grey, "  - " forum " - על מנת לבקש אותנו בפורום שלנו");
	     SendClientMessage(playerid, grey, "  - " ventrilo " - כתובת הוונטרילו של השרת");
	     SendClientMessage(playerid, grey, "  - " version " - גרסאת המוד");
	     SendClientMessage(playerid, grey, "  - " namemode " - שם המוד");
	     SendClientMessage(playerid, grey, "  - " lastupdate " - עדכון אחרון");
		 return 1;
	  }
	  if(_equal(anOcmd, "server") || _equal(anOcmd, "svr") || strval(anOcmd) == 6)
	  {
		 anOcmd = "";
		 format(anOcmd, sizeof anOcmd, "/Users/Configs/CTC/%s.ini", GetDateAsString('_', 2));
         SendHeader(playerid, "Server Info - מידע שרת");
         format(string, sizeof string, " • %s:%s - התאריך והשעה הרשמיים שבו השרת התחיל לרוץ", dini_Get(_fileconfig "Main.ini", "FirstRestartingDate"), dini_Get(_fileconfig "Main.ini", "FirstRestartingTime"));
		 SendClientMessage(playerid, 0x0000ffff, string);
         format(string, sizeof string, " • %s:%s - התאריך והשעה האחרונים שבו השרת אופס", dini_Get(_fileconfig "Main.ini", "LastRestartingDate"), dini_Get(_fileconfig "Main.ini", "LastRestartingTime"));
		 SendClientMessage(playerid, 0x0000ffff, string);
		 format(string, sizeof string, " • %06i - מספר כניסות ייחודיות לתאריך היום", dini_Int(anOcmd, "Total"));
		 SendClientMessage(playerid, 0x0000ffff, string);
		 format(string, sizeof string, " • %03i/%i - הכי הרבה שחקנים שהיו מחוברים בו זמנית", dini_Int(_fileconfig "Main.ini", "MaxOnlinePlayers"), GetMaxPlayers());
		 SendClientMessage(playerid, 0x0000ffff, string);
         format(string, sizeof string, " • %03i/%i - מספר שחקנים מחוברים כרגע", GetOnlinePlayers(), GetMaxPlayers());
         SendClientMessage(playerid, 0x0000ffff, string);
         format(string, sizeof string, " • 05i - מספר שחקנים רשומים", dini_Int(_fileconfig "Main.ini", "CountPlayers"));
         SendClientMessage(playerid, 0x0000ffff, string);
		 return 1;
	  }
      return error(playerid, ".נושא עזרה שגוי");
   }
   if(!strcmp(cmd, "/cbank", true) && IsPlayerAdmin(playerid))
   {
	  anOcmd = strtok(cmdtext, idx);
	  if(!strlen(anOcmd)) return SendClientMessage(playerid, white, "Usage: /cbank [add/lock/unlock/state]");
	  if(_equal(anOcmd, "add"))
	  {
		 new Float:pos[3];
		 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		 format(string, sizeof string, "CPX%i", dini_Int(cbank, "CPS"));
		 dini_FloatSet(cbank, string, pos[0]);
  		 format(string, sizeof string, "CPY%i", dini_Int(cbank, "CPS"));
		 dini_FloatSet(cbank, string, pos[1]);
  		 format(string, sizeof string, "CPZ%i", dini_Int(cbank, "CPS"));
		 dini_FloatSet(cbank, string, pos[2]);
		 Bank_CP[dini_Int(cbank, "CPS")] = CPS_AddCheckpoint(pos[0], pos[1], pos[2], 2.5, 30);
		 dini_IntSet(cbank, "CPS", dini_Int(cbank, "CPS") + 1);
		 dini_IntSet(cbank, "Total", dini_Int(cbank, "Total") + 1);
		 Create3DTextLabel("!ברוכים הבאים לבנק", green, pos[0], pos[1], pos[2]+0.20, 40.0, 0, 0);
		 SendClientMessage(playerid, orange, ".הוספת בנק בהצלחה");
		 return 1;
	  }
	  if(_equal(anOcmd, "lock") || _equal(anOcmd, "unlock")) return  Bank_Lock = _equal(anOcmd, "unlock")? 0 : 1;
	  if(_equal(anOcmd, "state")) return SendClientMessage(playerid, !Bank_Lock? green : red, !Bank_Lock? (".הבנק אינו נעול") : (".הבנק נעול"));
	  return 1;
   }
   if(!strcmp(cmd, "/dm", true))
   {

	   if(dini_Int(getPlayerFile(playerid, _filestats), "Kills") < 10) return error(playerid, ".לפני שתוכל להיכנס לאיזור זה תצטרך להשיג 10 הריגות");
	   if(PlayerInfo(inDM[playerid]) > 0)
	   {
	       _ResetPlayerWeapons(playerid);
		   SetPlayerVirtualWorld(playerid,0);
		   SendClientMessage(playerid, red, ".DeathMatch - יצאת מאיזור ה");
		   PlayerInfo(inDM[playerid]) = 0;
		   return 1;
	   }
	   if(_GetPlayerMoney(playerid) < 10) return error(playerid, ".אתר צריך 10$ DeathMatch (DM) - על מנת להיכנס לאיזור ה");
	   new Randm = random(sizeof DMPostion);
       SetPlayerVirtualWorld(playerid, 2);
       SetPlayerInterior(playerid, 0);
	   PlayerInfo(inDM[playerid]) = 35;
	   GivePlayerWeapon(playerid, 35, 99999);
   	   SetPlayerPos(playerid, DMPostion[Randm][0], DMPostion[Randm][1], DMPostion[Randm][2]);
   	   _GivePlayerMoney(playerid, -1*10);
   	   SendClientMessage(playerid, lightblue, "!שיהיה לך משחק מהנה, תהרוג כמה שיותר, תנסה לשמור על הכסף ולהגיע איתו לבנק ,DeathMatch - תהנה באיזור ה");
	   return 1;
   }
   if(!strcmp(cmd, "/banks", true))
   {
	 if(!isPlayerInBank(playerid)) return SendClientMessage(playerid, red, ".אתה לא נמצא בבנק");
     return dini_Exists(getPlayerFile(playerid, _filebank))? ShowPlayerDialog(playerid, 17, 2, " - אנא בחר את הפעולה שתרצה לבצע", " • (1) Deposit\n • (2) Withdraw\n • (3) Transfer\n • (4) Balance\n • (5) Deposit all\n • (6) Withdraw all\n • (7) Last Bank Action(s)","בחר","ביטול") : ShowPlayerDialog(playerid, 18, DIALOG_STYLE_INPUT, " Bank create an account", "אנא הזן את הסיסמה שלך לחשבון בנק כאן\nמומלץ לא לשים את הסיסמה של החשבון שלך על מנת להימנע מפריצות","תיצור","ביטול");
   }
   if(!strcmp(cmd, "/settd", true))
   {
	  new anOcmd2[256];
	  anOcmd = strtok(cmdtext, idx);
	  anOcmd2 = strtok(cmdtext, idx);
      if(_:TDrawPlayers[playerid] != -1) TextDrawDestroy(TDrawPlayers[playerid]);
      TDrawPlayers[playerid] = TextDrawCreate(510, 410, "~w~SA-MP.co.il - LucifeR DeathMatch~n~Record Players Server: 123~n~You left 100 Teleports~n~You left 6000 kill(s) to next level.");
      TextDrawTextSize(TDrawPlayers[playerid], strval(anOcmd), strval(anOcmd2));
      TextDrawAlignment(TDrawPlayers[playerid], 2);
      TextDrawFont(TDrawPlayers[playerid], 1);
	  TextDrawLetterSize(TDrawPlayers[playerid], 0.42221,1.000000); // 99999
	  TextDrawColor(TDrawPlayers[playerid], white);
	  TextDrawSetProportional(TDrawPlayers[playerid], 1);
	  TextDrawSetShadow(TDrawPlayers[playerid], 1);
	  TextDrawUseBox(TDrawPlayers[playerid], 1);
	  TextDrawBoxColor(TDrawPlayers[playerid], sgba2hex(0,0,0, 120));
	  return 1;
   }
   if(!strcmp(cmd, "/editprofile", true) || !strcmp(cmd, "/setprofile", true) || !strcmp(cmd, "/setp", true))
   {
	  format(string, sizeof string, _fileprivate "profile_%s.ini", GetName(playerid));
      if(!dini_Exists(string)) dini_Create(string);
      ShowPlayerDialog(playerid, 14, 2, " • בחר איזה פאראמטר תרצה לערוך", "• (1) שם פרטי\n• (2) שם משפחה\n• (3) אימייל\n• (4) מסנג'ר\n• (5) אייסיקיו\n• (6) עיר\n• (7) תאריך יום-הולדת" ,"בחר","ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/setting", true) || !strcmp(cmd, "/set", true) || !strcmp(cmd, "/settings", true))
   {
	  format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(playerid));
      if(!dini_Exists(string)) dini_Create(string);
      ShowPlayerDialog(playerid, 11, 2, " • בחר איזה פאראמטר תרצה לערוך", " • (1) הסתר / הצג | הודעה ששחקן מתחבר\n • (2) הסתר / הצג | הודעה ששחקן מתנתק\n • (3) הצג / הסתר | הודעה ששחקן נענש\n • (4) (/pm) תחסום / תאשר | שליחת הודעות פרטיות\n • (5) IP תחסום / תאפשר | חיבור לשרת ע\"י\n • (6) הצג / הסתר | טקסט המוד\n • (7) (לא מומלץ לשימוש רציף) PM - אפשר / בטל | השבה מהירה ב\n • (8) לשנות סיסמה\n • (9) (לשנות כינוי (אפשרי פעם אחת בשבוע" ,"בחר","ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/changepass", true) || !strcmp(cmd, "/changepassword", true) || !strcmp(cmd, "/setpass", true) || !strcmp(cmd, "/setpassword", true))
   {
	  if(!dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/register :אתה לא רשום אנא הירשם");
	  ShowPlayerDialog(playerid, 12, DIALOG_STYLE_INPUT, "   Users Systems \\ מערכת משתמשים", " • \"אנא הזן את הסיסמה החדשה שלך והקש: \"שנה סיסמה", "שנה סיסמה", "ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/changenick", true) || !strcmp(cmd, "/changename", true) || !strcmp(cmd, "/cngnick", true) || !strcmp(cmd, "/setnick", true) || !strcmp(cmd, "/setname", true))
   {
	  if(!dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/register :אתה לא רשום אנא הירשם");
	  ShowPlayerDialog(playerid, 13, DIALOG_STYLE_INPUT, "   Users Systems \\ מערכת משתמשים", " • \"אנא הזן את הכינוי החדש שלך ולאחר מכן לחץ \"שנה כינוי", "שנה כינוי", "ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/login", true))
   {
	  if(PlayerInfo(logged[playerid])) return error(playerid, ".אתה כבר מחובר");
	  if(!dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/register :אתה לא רשום אנא הירשם");
      ShowPlayerDialog(playerid,5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה שלך על מנת להתחבר ולהתחיל לשחק", "התחבר", "ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/register", true))
   {
	  if(dini_Exists(getPlayerFile(playerid, _fileusers))) return error(playerid, "/login :אתה כבר רשום, אנא התחבר");
	  ShowPlayerDialog(playerid, 6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/levels", true) || !strcmp(cmd, "/lvls", true)) return OnPlayerCommandText(playerid, "/help lvls");
   if(!strcmp(cmd, "/mlevels", true) || !strcmp(cmd, "/mlvls", true))
   {
      new tstring[256], bstring[1000];
	  bstring = "";
	  for(new i = 0; i < sizeof var_Levels; i++)
	  {
          format(tstring, sizeof tstring, " <> • %s(%i)\n", var_Tags[i], i+2);
	      strcat(bstring, tstring);
	  }
	  ShowPlayerDialog(playerid, 21, 2, "Level List // רשימת רמות", bstring, "בדוק", "בטל");
	  return 1;
   }
   if(!strcmp(cmd, "/nextlevel", true) || !strcmp(cmd, "/level", true) || !strcmp(cmd, "/lvl", true))
   {
	  format(string, sizeof string, " • נשארו לך עוד %i הריגות על מנת לעבור לרמה %i", var_Levels[getPlayerLevel(playerid) - 1] - dini_Int(getPlayerFile(playerid, _filestats), "Kills"), getPlayerLevel(playerid) + 1);
	  SendClientMessage(playerid, random(2) == 1? yellow : orange, string);
	  return 1;
   }
   if(!strcmp(cmd, "/pay", true) || !strcmp(cmd, "/givemoney", true) || !strcmp(cmd, "/sendmoney", true) || !strcmp(cmd, "/money", true))
   {
      anOcmd = strtok(cmdtext, idx);
      format(string, sizeof string, " Usage: %s [playerid]", cmd);
      PlayerInfo(onClick[playerid]) = strval(anOcmd);
      if(!strlen(anOcmd) || strval(anOcmd) == playerid) return SendClientMessage(playerid, strval(anOcmd) == playerid? red : white, strval(anOcmd) == playerid? (".אתה לא יכול לשלוח כסף לעצמך") : string);
      if(!IsPlayerConnected(strval(anOcmd))) return error(playerid, " .השחקן אינו מחובר");
      ShowPlayerDialog(playerid, 9, DIALOG_STYLE_INPUT, " » Pay - לשלם",".אנא הקלד את הסכום הרצוי שאתה רוצה לשלוח", "שלח", "ביטול");
      return 1;
   }
   if(!strcmp(cmd, "/pm", true) || !strcmp(cmd, "/send", true) || !strcmp(cmd, "/sms", true))
   {
      anOcmd = strtok(cmdtext, idx);
      format(string, sizeof string, " Usage: %s [playerid]", cmd);
      PlayerInfo(onClick[playerid]) = strval(anOcmd);
      if(!strlen(anOcmd) || !IsPlayerConnected(strval(anOcmd))) return SendClientMessage(playerid, !IsPlayerConnected(strval(anOcmd))? red : white, !IsPlayerConnected(strval(anOcmd))? (".השחקן אינו מחובר") : string);
	  ShowPlayerDialog(playerid, 8, DIALOG_STYLE_INPUT, " » Private Messsage - הודעה פרטית",".אנא הקלד את ההודעה פרטית שלך ולחץ שלח","שלח","ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/report", true) || !strcmp(cmd, "/cheater", true))
   {
      anOcmd = strtok(cmdtext, idx);
      format(string, sizeof string, " Usage: %s [playerid]", cmd);
      PlayerInfo(onClick[playerid]) = strval(anOcmd);
      if(!strlen(anOcmd) || strval(anOcmd) == playerid) return SendClientMessage(playerid, strval(anOcmd) == playerid? red : white, strval(anOcmd) == playerid? (".אתה לא יכול לדווח על עצמך") : string);
      if(!IsPlayerConnected(strval(anOcmd))) return error(playerid, " .השחקן אינו מחובר");
	  ShowPlayerDialog(playerid, 10, DIALOG_STYLE_INPUT," » Report - דיווח ",".אנא הקלד את הסיבה של העבירה של השחקן","שלח","ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/precentes", true) || !strcmp(cmd, "/pre", true))
   {
	  format(string, sizeof string, "%03d%s :אחוזים לרמה הבאה", nextLevelPre(playerid), "%%");
	  SendClientMessage(playerid, orange, string);
	  return 1;
   }
   if(!strcmp(cmd, "/stats", true))
   {
	  anOcmd = strtok(cmdtext, idx);
	  showStats(playerid, !strlen(anOcmd)? playerid : strval(anOcmd), 0);
 	  return 1;
   }
   if(!strcmp(cmd, "/profile", true) || !strcmp(cmd, "/myprofile", true))
   {
	  anOcmd = strtok(cmdtext, idx);
	  showProfile(playerid, !strlen(anOcmd) || !strcmp(cmd, "/myprofile", true)? playerid : strval(anOcmd));
 	  return 1;
   }
   if (!strcmp(cmd,"/bomb",true))
   {
        new Float:pos[3];
        if(dini_Int(getPlayerFile(playerid, _filestats), "Level") < 4) return error(playerid, ".פקודה זאת מרמה 4 ומעלה בלבד");
	    if(GetPlayerMoney(playerid) < 500) return error(playerid, ".הטמנת פצצה עולה 500$ ואין לך מספיק כסף");
		if(GetPlayerInterior(playerid) > 0) return error(playerid, ".לא ניתן להטמין פצצה במקום סגור");
		_GivePlayerMoney(playerid, -1*500);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	    format(string, sizeof string,"  Updates: /Bomb !הטמין פצה, הפצצה תפוצץ עוד 6 שניות, לברוח %s - זהירות! השחקן", GetName(playerid));
	    SendClientMessageToAll(orange, string);
	    SetTimerEx("DestroyBomb",6*1000,0,"i", CreateObject(1654, pos[0], pos[1], pos[2], 0, 0, 0));
	    return 1;
   }
   if (!strcmp(cmd,"/god",true))
   {
		if(dini_Int(getPlayerFile(playerid, _filestats), "Level") < 10) return error(playerid, ".פקודה זאת מרמה 10 ומעלה בלבד");
	    if(PlayerInfo(god[playerid])) return error(playerid,".אתה כבר עם גוד מוד פעיל");
	    if(_GetPlayerMoney(playerid) < 1000) return error(playerid,".אתה צריך 1000$ על מנת לקנות גוד-מוד");
		_GivePlayerMoney(playerid, -1*1000);
	    format(string, sizeof string,"  Updates: /God ?משתמש בגוד מוד למשך 20 שניות, לשמור רחק! רוצה גם %s - זהירות! השחקן",GetName(playerid));
	    SendClientMessageToAll(orange, string);
	    _SetPlayerHealth(playerid, 100000000);
	    PlayerInfo(god[playerid]) = 1;
	    SetTimerEx("UnGodPlayer",20*1000, false,"i", playerid);
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
		  SendClientMessage(playerid, orange, ".החלפת לשחקן זה את התאג בהצלחה");
		  return 1;
	  }
	  if(_equal(anOcmd, "remove"))
	  {
          anOcmd = strtok(cmdtext, idx);
		  format(file, sizeof file, "%s", anOcmd);
		  if(!dini_Isset(_fileconfig "Tags.ini", file)) return error(playerid, ".לשחקן זה אין תאג");
		  dini_Set(_fileconfig "Tags.ini", file, "None");
		  SendClientMessage(playerid, orange, ".מחקת לשחקן זה את התאג בהצלחה");
		  return 1;
	  }
	  return error(playerid, ".פקודה שגויה");
   }
   if(!strcmp(cmd, "/kill", true)) return Kill(playerid);
   if(!strcmp(cmd, "/blabla", true))
   {
	   format(string, sizeof string, "%i", AC_Info[playerid][cash]);
	   SendClientMessage(playerid, red, string);
	   return 1;
   }
   if(!strcmp(cmd, "/buyteles", true) || !strcmp(cmd, "/buytele", true) || !strcmp(cmd, "/bt", true))
   {
	  if(dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports") == 100) return error(playerid, ".יש לך 100 שיגורים זמינים, לא תוכל לקנות יותר מ - 100, המשך משחק מהנה");
      anOcmd = strtok(cmdtext, idx);
	  new x = NumbersBetweenNumbers(dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports"), 100)-1, mcash = strval(anOcmd)*100;
	  if(!strlen(anOcmd) || strval(anOcmd) > x || strval(anOcmd) < 1)
	  {
	     format(string, sizeof string, "Usage: %s [1-%i]", cmd, x);
	     SendClientMessage(playerid, white, string);
	     return 1;
	  }
	  else if(AC_Info[playerid][cash] < mcash || AC_Info[playerid][cash] < 100 || !GetPlayerMoney(playerid))
	  {
	     format(string, sizeof string, "!על מנת לקנות %i שיגורים, אתה צריך %i$", strval(anOcmd), strval(anOcmd)? 100 : mcash);
	     error(playerid, string);
	     return 1;
	  }
	  _GivePlayerMoney(playerid, -1*mcash);
	  dini_IntSet(getPlayerFile(playerid, _filestats), "MaxTeleports", dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports")+strval(anOcmd));
	  format(string, sizeof string, "!מזל טוב! קנית - %i שיגורים, כעת יש לך %i שיגורים, הסכום שעלה לך שיגורים אלו: %i$", strval(anOcmd), dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports")+strval(anOcmd), mcash);
	  SendClientMessage(playerid, random(2)? orange : yellow, string);
	  return 1;
   }
   if(!strcmp(cmd, "/mteles", true))
   {
	  if(PlayerInfo(inAct[playerid])) return error(playerid, ".אתה לא יכול להשתגר באמצע משחק");
	  new tstring[256], exists[256], bstring[1000], fr[32], c = -1;
	  bstring = "";
	  for(new i = 0; i <= dini_Int(teleports_insetsfile, "Total"); i++)
	  {
          format(fr, sizeof fr, "tele%i", i);
	  	  format(exists, sizeof exists, "/Insets/Teleports/%s.ini", dini_Get(teleports_insetsfile, fr));
          format(tstring,sizeof tstring," <> • (%i) %s [Level: %i]\n", ++c, dini_Get(teleports_insetsfile, fr), !dini_Int(exists, "level")? 1 : dini_Int(exists, "level"));
	      if(dini_Exists(exists)) strcat(bstring, tstring);
	  }
	  ShowPlayerDialog(playerid, 16, 2, "Teleport List //// רשימת שיגורים", bstring, "שגר", "בטל");
	  return 1;
   }
   if(!strcmp(cmd, "/t", true) || !strcmp(cmd, "/tele", true) || !strcmp(cmd, "/teles", true) || !strcmp(cmd, "/teleports", true) || !strcmp(cmd, "/teleport", true))
   {
   		new next_line = 0, lines = 0, _text[256];
		if !dini_Int(teleports_insetsfile, "Total") *then return error(playerid, ".אין שיגורים בשרת כרגע");
        format(string, sizeof string, "-------- [ Teleports - (%03d) - שיגורים ] --------", dini_Int(teleports_insetsfile, "Total"));
        SendClientMessage(playerid, white, string);
        _text = " ";
		for(new i = 0; i < sizeof tele_words; i++)
		{
		    if(!strcmp(tele_words[i],"*EOF*",true)) continue;
   			format(string,sizeof string," • /%s",tele_words[i]);
   			strcat(_text, string);
			next_line++;
			if(next_line == 10)
			{
                 lines++;
				 SendClientMessage(playerid,orange, _text);
				 string = " ", next_line = 0, _text = " ";
			}
		}
		if(next_line >= 1) SendClientMessage(playerid, orange, _text);
		SendClientMessage(playerid, pink, "  • /mteles - אין לכם כח להקיש את כל הפקודה?  *");
        SendClientMessage(playerid, white, "--------------------------------------------------");
        return 1;
   }
   format(string, sizeof string, "/Insets/Teleports/%s.ini", cmd);
   if(dini_Exists(string)) return createTeleport(playerid, dini_Int(string, "interior"), dini_Float(string, "x"), dini_Float(string, "y"), dini_Float(string, "z"), dini_Float(string, "angle"), dini_Int(string, "with_vehicle"), dini_Int(string, "level"), dini_Get(string, "cmd"), dini_Int(string, "stpo"));
   return 0;
}
stock weaponsCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   if(!strcmp(cmd, "/weapons", true))
   {
       new wstring[2][128], found = 0, wps[256], id = -1;
       wps = strtok(cmdtext, idx);
       id = !strlen(wps)? playerid : strval(wps);
	   if(strlen(wps) > 0 && !IsPlayerConnected(id)) return error(playerid, ".שחקן זה לא מחובר");
       if(!dini_Exists(WeaponFile(id))) return error(playerid, (id) == (playerid)? (".אין לך נשקים תמידיים") : (".לשחקן זה אין נשקים תמידיים"));
       format(string, sizeof string, (id) == (playerid)? ("-------- [ %s's - רשימת הנשקים שלך ] --------") : ("-------- [ %s's - רשימת הנשקים של ] --------"), GetName(id));
	   SendClientMessage(playerid, white, string);
	   for(new i = 0; i < dini_Int(cweapon, "Total"); i++)
	   {
           format(wstring[0], 128, "weapon%i", i);
           format(wstring[1], 128, "ammo%i", i);
	       if(dini_Isset(WeaponFile(id), wstring[0]) && dini_Isset(WeaponFile(id), wstring[1]) && dini_Int(WeaponFile(id), wstring[0]) >= 1 && dini_Int(WeaponFile(id), wstring[1]) >= 1)
	       {
			    format(string, sizeof string, " • %i. Weapon: %s ( Weapon DN\"S: %i ) <> Ammo: %d", ++found, Weapons[dini_Int(WeaponFile(id), wstring[0])], i, dini_Int(WeaponFile(id), wstring[1]));
			    SendClientMessage(playerid, random(2) == random(2)? darkblue : brown, string);
	       }
	   }
	   SendClientMessage(playerid, white, "--------------------------------------");
	   return 1;
   }
   /*
   if(!strcmp(cmd, "/wl", true) || !strcmp(cmd, "/weaponlist", true))
   {
	 new tmp[256], x = 0;
	 tmp = strtok(cmdtext, idx);
	 x = strval(tmp) != 1? strval(tmp)*5 : 0;
	 if(!strlen(tmp) || strval(tmp) > dini_Int(cweapon, "Total") / 9)
	 {
		format(string, sizeof string, "Usage: /wl [1-%i]", dini_Int(cweapon, "Total") / 9);
		SendClientMessage(playerid, white, string);
	  	return 1;
	 }
	 if(!isPlayerInAmmoSHOP(playerid)) return error(playerid, ".אתה לא נמצא באחת מחנויות הנשק הרשמיות");
	 if(!dini_Int(cweapon, "Total")) return error(playerid, ".האדמין עוד לא הוסיף נשקים לשרת, אם קיבלת הודעה זו התלונן בפורום");
	 format(string, sizeof string, "-------- [ (%i/%i) - רשימת נשקים ] --------", strval(tmp), dini_Int(cweapon, "Total") / 9);
	 SendClientMessage(playerid, white, string);
	 for(new i = x; i <= x+9; i++)
	 {
         format(string, sizeof string, "/Users/Weapons/Weapon%d.ini",i);
         if(dini_Exists(string))
         {
			 format(string, sizeof string, " • /Bw %i | כדורים: %i, מחיר: %i$, רמה: %i %s :הנשק", i, dini_Int(string, "ammo"), !isPlayerVIP(playerid)? dini_Int(string, "cost") : dini_Int(string, "cost") / 2 , dini_Int(string, "level"), dini_Get(string, "Weapon_Name"));
			 SendClientMessage(playerid, isPlayerVIP(playerid)? pink : 0xFFFF00AA, string);
         }
	 }
     return 1;
   }*/
   if(!strcmp(cmd, "/dw", true) || !strcmp(cmd, "/dropweapon", true))
   {
      new wps[256];
      wps = strtok(cmdtext, idx);
      if(!strlen(wps))
	  {
	     SendClientMessage(playerid, white, " Usage: /dropweapon(/dw) [Weapon DN\"S]");
	     SendClientMessage(playerid, white, " /Weapons - של הנשק DN\"S - על מנת לגלות את ה");
	     return 1;
	  }
   	  format(wstring[0], 128, "weapon%i", strval(wps));
	  format(wstring[1], 128, "ammo%i", strval(wps));
	  if(!dini_Isset(WeaponFile(playerid), wstring[0]) || dini_Int(WeaponFile(playerid), wstring[0]) <= 0) return error(playerid, ".אין לך את הנשק הזה");
	  format(string, sizeof string, " • !\"%s\" - זרקת את הנשק", Weapons[dini_Int(WeaponFile(playerid), wstring[0])]);
	  SendClientMessage(playerid, darkblue, string);
	  for(new i = 0; i < 2; i++) dini_IntSet(WeaponFile(playerid), wstring[i], 0);
	  dini_IntSet(WeaponFile(playerid), "Total", dini_Int(WeaponFile(playerid), "Total")-1);
	  return 1;
   }
   if(!strcmp(cmd, "/bw", true))
   {
	  new tstring[256], bstring[1000], x = isPlayerVIP(playerid);
	  bstring = "";
	  if !isPlayerInAmmoSHOP(playerid) && !IsPlayerAdmin(playerid) *then return error(playerid, ".אתה לא נמצא באחת מחנויות הנשק הרשמיות");
	  if !dini_Int(cweapon, "Total") *then return error(playerid, ".האדמין עוד לא הוסיף נשקים לשרת, אם קיבלת הודעה זו התלונן בפורום");
	  for(new i = 1; i <= dini_Int(cweapon, "Total"); i++)
	  {
		 format(string, sizeof string, "/Users/Weapons/Weapon%d.ini", i);
		 format(tstring, sizeof tstring, !x? (" • (%03i) %s, %i$, [Level: %03i]\n") : (" • (%02i) %s, %i$ (VIP Discount - Half Cost), [Level: %03i]\n"), i, dini_Get(string, "Weapon_Name"), !isPlayerVIP(playerid)? dini_Int(string, "cost") : dini_Int(string, "cost") / 2, dini_Int(string, "level"));
		 if(dini_Exists(string)) strcat(bstring, tstring);
	  }
	  ShowPlayerDialog(playerid, 23, 2, "Weapons List // רשימת נשקים", bstring, "קנה", "בטל");
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
          format(string, sizeof string, " • You was created a new weapon(gun): ID: %i, Ammo: %i, Cost: %d$, Level: %d, Weapon: \"%s\"",strval(_vtmp2),strval(_vtmp3), strval(_vtmp4), strval(_vtmp5), Weapons[strval(_vtmp2)]);
          SendClientMessage(playerid, orange, string);
		  return 1;
	  }
	  if(_equal(_vtmp, "store"))
	  {
		 new Float:pos[3];
		 if(dini_Int(cweapon,"CPS") == MAX_AMMO_SHOP) return error(playerid, "!אתה לא יכול להוסיף עוד חנויות נשקים");
		 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		 format(string, sizeof string, "CPX%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[0]);
  		 format(string, sizeof string, "CPY%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[1]);
  		 format(string, sizeof string, "CPZ%i", dini_Int(cweapon, "CPS"));
		 dini_FloatSet(cweapon, string, pos[2]);
		 Ammo_SHOP[dini_Int(cweapon, "CPS")] = CPS_AddCheckpoint(pos[0], pos[1], pos[2], 2.5, 30);
		 dini_IntSet(cweapon, "CPS", dini_Int(cweapon, "CPS") + 1);
		 dini_IntSet(cweapon, "Total", dini_Int(cweapon, "Total") + 1);
		 Create3DTextLabel("!ברוכים הבאים לחנות נשקים", yellow, pos[0], pos[1], pos[2]+20.0, 40.0, 0, 0);
		 SendClientMessage(playerid, orange, ".הוספת חנות נשקים בהצלחה");
		 return 1;
	  }
	  return error(playerid, ".פקודה שגויה");
   }
   return 0;
}
stock insetsCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   if(!strcmp(cmd, "/insets", true))
   {
	    new _a1[256], _a2[256], _a3[256], _a4[256], _a5[256], _a6[256], Float:opos[4];
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
                 _a6 = strtok(cmdtext, idx);
				 GetPlayerPos(playerid, opos[0], opos[1], opos[2]);
				 GetPlayerFacingAngle(playerid, opos[3]);
                 if(!strlen(_a3) || !strlen(_a4) || !strlen(_a5) || !strlen(_a6)) return SendClientMessage(playerid, white, "Usage: /insets create teleport [command name] [with vehicle: 1 / 0] [level] [stunts points]");
                 CreateTeleportEx(opos[0], opos[1], opos[2], opos[3], _a3, strval(_a4), strval(_a5), GetPlayerInterior(playerid), strval(_a6));
				 format(string, sizeof string, " • /insets desroy teleport %s :יצרת שיגור חדש, צלם תמונה זו למקרה ביטחון, במקרה ואתה רוצה למחוק את השיגור",_a3);
			     SendClientMessage(playerid, orange, string);
				 return 1;
			 }
             if(_equal(_a2, "vehicle"))
             {
                 _a3 = strtok(cmdtext, idx);
                 if(!strlen(_a3)) return SendClientMessage(playerid, white, "Usage: /insets create vehicle [term]");
                 dini_IntSet(vehicle_insetsfile, "Total", dini_Int(vehicle_insetsfile, "Total")+1);
				 format(string, sizeof string, "/Insets/Vehicles/%d.ini", dini_Int(vehicle_insetsfile, "Total"));
				 if(IsPlayerInAnyVehicle(playerid))
				 {
				     GetVehiclePos(GetPlayerVehicleID(playerid), opos[0], opos[1], opos[2]);
			         GetVehicleZAngle(GetPlayerVehicleID(playerid), opos[3]);
			         SetVehicleToRespawn(GetPlayerVehicleID(playerid));
				 }
				 else GetPlayerPos(playerid, opos[0], opos[1], opos[2]);
			     dini_Create(string);
			     dini_IntSet(string, "modelid", GetVehicleModel(GetPlayerVehicleID(playerid)));
			     dini_FloatSet(string, "x", opos[0]);
			     dini_FloatSet(string, "y", opos[1]);
			     dini_FloatSet(string, "z", opos[2]);
			     dini_FloatSet(string, "angle", opos[3]);
			     dini_Set(string, "var", _a3);
				 CreateVehicle(IsPlayerInAnyVehicle(playerid)? GetVehicleModel(GetPlayerVehicleID(playerid)) : strval(_a3), opos[0], opos[1], opos[2], IsPlayerInAnyVehicle(playerid)? opos[3] : 123.00, random(126), random(126), -1);
			     format(string, sizeof string, " • /insets desroy vehicle %i :יצרת רכב תמידי חדש בשרת, אנא צלם תמונה זו בבקשה, אם תרצה למחוק את הרכב תמידי זה בצע",dini_Int(vehicle_insetsfile, "Total"));
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
			    CreatePickup(strval(_a3), strval(_a4), opos[0], opos[1], opos[2], 0, mainPickups++, "None", 0);
			    format(string, sizeof string, " • /insets desroy pickup %i :יצרת פיקאפ תמידי חדש בשרת, אנא צלם תמונה זו בבקשה, אם תרצה למחוק את הפיקאפ תמידי זה בצע",dini_Int(pickup_insetsfile, "Total"));
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
			 if(!strlen(_a3) || _a3[0] == '/') return SendClientMessage(playerid, !strlen(_a3) && _a3[0] != '/'? white : red, !strlen(_a3) && _a3[0] != '/'? ("Usage: /insets desroy teleport [tele name]") : (".אין צורך בשימוש ב - '/' אנא הוריד את זה מהפקודה"));
			 for (new i = 0; i < 100; i++)
			 {
		          if (!strcmp(tele_words[i],cmd,true))
				  {
				      memcpy(tele_words[i],"*EOF*",0, MAX_STRING);
				      results = true;
		          }
			 }
		     format(string,sizeof string,!results? (".\"%s\" - לא נמצא שיגור בשם") : (".\"%s\" - מחקת את השיגור") ,cmd);
		     SendClientMessage(playerid, orange, string);
		     SaveTeleportsList();
			 return 1;
		   }
		   if(_equal(_a2, "pickup"))
		   {
			  _a3 = strtok(cmdtext, idx);
			  format(string, sizeof string, "/Insets/Pickups/%d.ini", strval(_a3));
			  if(!strlen(_a3)) return SendClientMessage(playerid, white, "Usage: /insets desroy pickup [pickup-id]");
			  if(!dini_Exists(string)) return error(playerid, ".לא קיים פיקאפ כזה, אנא בדוק את האיידי שנית");
		      dini_Remove(string);
              format(string, sizeof string, "!%i :מחקת את הפיקאפ", strval(_a3));
		      SendClientMessage(playerid, orange, string);
			  return 1;
			}
		   if(_equal(_a2, "vehicle"))
		   {
			  _a3 = strtok(cmdtext, idx);
			  format(string, sizeof string, "/Insets/Vehicles/%d.ini", strval(_a3));
			  if(!strlen(_a3)) return SendClientMessage(playerid, white, "Usage: /insets desroy vehicle [pickup-id]");
			  if(!dini_Exists(string)) return error(playerid, ".לא קיים רכב כזה, אנא בדוק את האיידי שנית");
		      dini_Remove(string);
              format(string, sizeof string, "!%i :מחקת את הרכב", strval(_a3));
		      SendClientMessage(playerid, orange, string);
			  return 1;
			}
		}
	    return 1;
   }
   return 0;
}
stock clanCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   if(!strcmp(cmd, "/cbinfo", true) || !strcmp(cmd, "/clanbankinfo", true))
   {
	   if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".אתה לא נמצא בשום קלאן רשמי");
       if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return error(playerid, ".אתה לא נמצא בבנק של הקלאן הרשמי שלך");
       SendHeader(playerid," Clan Bank Info - קלאן בנק מידע");
	   format(string, sizeof string, "!%d$ - חשבון הבנק של הקלאן עומד על כ", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank"));
	   SendClientMessage(playerid, orange, string);
	   format(string, sizeof string, "!%d$ - כל שחקן יכול למשוך ביום אך ורק", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
	   SendClientMessage(playerid, orange, string);
	   format(string, sizeof string, "%s", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? (".הבנק של הקלאן שלך נעול") : (".הבנק של הלקאן פתוח"));
	   SendClientMessage(playerid, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? red : 0x16EB43ff, string);
	   return 1;
   }
   if(!strcmp(cmd, "/cdeposit", true))
   {
      if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".אתה לא נמצא בשום קלאן רשמי");
      if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return error(playerid, ".אתה לא נמצא בבנק של הקלאן הרשמי שלך");
	  if(_GetPlayerMoney(playerid) < 1) return error(playerid, ".אין עליך כסף");
      ShowPlayerDialog(playerid,1,2, "All Of Money :תבחר באחת האפשרויות הניתנות, אם את מעוניין להפקיד את כל כספך בחר\nAmount Of Money :אם את מעוניין להפקיד חלק מכספך"," • (1) Amount Of Money\n • (2) All Of Money", "בחר", "ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/cwithdraw", true))
   {
	  format(string, sizeof string, "%s",GetDateAsString('/', 1));
      if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".אתה לא נמצא בשום קלאן רשמי");
      if(!CPS_IsPlayerInCheckpoint(playerid, clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")])) return error(playerid, ".אתה לא נמצא בבנק של הקלאן הרשמי שלך");
      if(!DaysBetweenDates(dini_Get(ClanPlayerFile(playerid),"Last_Withdraw"), string) && strcmp(dini_Get(ClanPlayerFile(playerid),"Last_Withdraw"), "None", true) && getPlayerClanLevel(playerid) != 4) return error(playerid, ".כבר משכת היום כסף מהחשבון בנק של הקלאן שלך");
	  format(string, sizeof string, getPlayerClanLevel(playerid) < 4? ("  Withdraw Clan Bank (MaxWithdraw: %d$)") : ("  Withdraw Clan Bank"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw"));
      ShowPlayerDialog(playerid,4, DIALOG_STYLE_INPUT, string," • אנא הזן את הסכום שהינך רוצה למשוך מהחשבון בנק של הקלאן שלך ", "משוך", "ביטול");
	  return 1;
   }
   if(!strcmp(cmd, "/og", true))
   {
       getMoveObjectNearPlayer(playerid);
	   if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".אתה לא נמצא בשום קלאן רשמי");
	   if(strcmp(pGateInfo[playerid][owner], dini_Get(ClanPlayerFile(playerid),"Clan_Name"), false)) return error(playerid,".המפקדה הזו לא שייכת לקלאן שלך");
	   if(!PlayerToPoint(playerid, 15.0, GateInfo[pGateInfo[playerid][gid]][xn], GateInfo[pGateInfo[playerid][gid]][yn], GateInfo[pGateInfo[playerid][gid]][zn])) return error(playerid, ".אתה לא נמצא ליד שום אובייקט שניתן להזזה במפקדה שלך");
	   if(GateInfo[pGateInfo[playerid][gid]][gstate]) return error(playerid, ".האובייקט הזה כבר פתוח");
	   setGateLoctions(pGateInfo[playerid][gid], true);
	   return 1;
   }
   if(!strcmp(cmd, "/cg", true))
   {
       getMoveObjectNearPlayer(playerid);
	   if(getPlayerClanLevel(playerid) < 1) return error(playerid, ".אתה לא נמצא בשום קלאן רשמי");
	   if(strcmp(pGateInfo[playerid][owner], dini_Get(ClanPlayerFile(playerid),"Clan_Name"), false)) return error(playerid,".המפקדה הזו לא שייכת לקלאן שלך");
	   if(!PlayerToPoint(playerid, 15.0, GateInfo[pGateInfo[playerid][gid]][xn], GateInfo[pGateInfo[playerid][gid]][yn], GateInfo[pGateInfo[playerid][gid]][zn])) return error(playerid, ".אתה לא נמצא ליד שום אובייקט שניתן להזזה במפקדה שלך");
	   if(!GateInfo[pGateInfo[playerid][gid]][gstate]) return error(playerid, ".האובייקט הזה כבר סגור");
	   setGateLoctions(pGateInfo[playerid][gid], false);
	   return 1;
   }
   format(string, sizeof string, "/Clans/HQ/%s.ini", dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
   if(dini_Exists(string) && !strcmp(cmd, dini_Get(string,"CMD"), true))
   {
      if(PlayerInfo(inAct[playerid])) return error(playerid, ".אתה לא יכול להשתגר באמצע משחק");
	  if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid,dini_Float(string, "FX"),dini_Float(string, "FY"),dini_Float(string, "FZ"));
	  else SetVehiclePos(GetPlayerVehicleID(playerid),dini_Float(string, "VX"),dini_Float(string, "VY"),dini_Float(string, "VZ"));
	  format(string, sizeof string, " • !%s - ברוכים הבאים למפקדה של הקלאן שלך",dini_Get(ClanPlayerFile(playerid),"Clan_Name"));
	  SendClientMessage(playerid, orange, string);
      return 1;
   }
   if(!strcmp(cmd, "/hq", true) && !dini_Exists(string)) return error(playerid, dini_Exists(ClanPlayerFile(playerid))? (".לקלאן שלך אין מפקדה") : (".אתה לא נמצא בשום קלאן"));
   if(!strcmp(cmd, "/clan", true))
   {
	  new tmpclan[256];
	  tmpclan = strtok(cmdtext, idx);
	  if(!strlen(tmpclan))
	  {
	  	  SendHeader(playerid,"Clan - קלאן");
	  	  SendClientMessage(playerid,0x16EB43ff," [01] • /Clan Create"" ""("#clanCost"$)" " - על מנת ליצור קלאן");
	  	  SendClientMessage(playerid,0x16EB43ff," [02] • /Clan Invite - להזמין שחקן לקלאן שלך");
	  	  SendClientMessage(playerid,0x16EB43ff," [03] • /Clan [Accept/Join] - אישור הזמנה לקלאן");
          SendClientMessage(playerid,0x16EB43ff," [04] • /Clan [Leave/Exit/Quit] - אישור הזמנה לקלאן");
	  	  SendClientMessage(playerid,0x16EB43ff," [05] • /Clan Info - כל מיני מקורות מידע על קלאנים");
	  	  SendClientMessage(playerid,0x16EB43ff," [06] • /Clan [Set/Edit] - עריכת / שינוי של הגדרות הקלאן");
	  	  SendClientMessage(playerid,0x16EB43ff," [07] • /Clan Bank - הגדרות מערכת הבנק");
	  	  SendClientMessage(playerid,0x16EB43ff," [08] • /Clan Memmbers - לבדוק את כל השחקנים הרושמים לקלאן מסויים");
	  	  SendClientMessage(playerid,orange," [09] • '@' :על מנת לדבר בקלאן צ'אט");
	  	  if(IsPlayerAdmin(playerid)) SendClientMessage(playerid,red,"*[A01] • /Clan HQ - פקודות מפקדות השרת");
		  return 1;
	  }
	  if(_equal(tmpclan,"hq") && IsPlayerAdmin(playerid))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan2))
		  {
              SendHeader(playerid,"Clan - קלאן");
			  SendClientMessage(playerid,0x16EB43ff," [01] • /Clan HQ Create [Clan Name] - על מנת ליצור מפקדה לקלאן");
			  SendClientMessage(playerid,0x16EB43ff," [02] • /Clan HQ Remove [Clan Name] - על מנת למחוק לקלאן מפקדה");
			  SendClientMessage(playerid,0x16EB43ff," [03] • /Clan HQ SetAccess [From] [To] - להעביר מפקדה מקלאן אחד לקלאן אחר");
			  SendClientMessage(playerid,0x16EB43ff," [04] • /Clan HQ SetArea [Clan Name] [1-2] - על מנת לשנות את האיזור של המפקדה");
			  SendClientMessage(playerid,0x16EB43ff," [05] • (לא לגעת - רק רועי) | /Clan HQ Loadlist [Clan Name] - על מנת להוסיף את העצמים למפקדה");
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
			  if(!dini_Exists(ClanFile(tmpclan3)) || !dini_Exists(ClanFile(tmpclan4))) return error(playerid,".לא קיים / קיימים קלאנים כאלו");
			  if(dini_Exists(HQ_ClanFile(tmpclan4))) return error(playerid,".לקלאן שאתה רוצה לתת לו את המפקדה יש כבר מפקדה, אם תרצה להעביר לו אותה תצטרך למחוק לו את הישנה");
			  dini_Create(HQ_ClanFile(tmpclan4));
			  fcopytextfile(HQ_ClanFile(tmpclan3), HQ_ClanFile(tmpclan4));
			  dini_Remove(HQ_ClanFile(tmpclan3));
		      dini_Set(HQ_ClanFile(tmpclan4), "CMD", "/hq");
		      format(string, sizeof string, " • !%s - לקלאן של %s - העברת את המפקדה של", tmpclan4, tmpclan3);
			  SendClientMessage(playerid, orange, string);
			  Admin_ClanMessageToAll(tmpclan3, red, " •  !אין לכם יותר מפקדה, האדמין מחק אותה, אם אתה רוצה להגיש תלונה גש לפורום שלנו");
			  return 1;
		  }
		  if(_equal(tmpclan2, "create"))
		  {
			  new tmpclan3[256], Float:pos[3];
			  tmpclan3 = strtok(cmdtext, idx);
			  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan HQ Create [Clan Name]");
			  if(!dini_Exists(ClanFile(tmpclan3))) return error(playerid,".לא קיים קלאן כזה");
			  if(dini_Exists(HQ_ClanFile(tmpclan3))) return error(playerid,".לקלאן זה יש כבר מפקדה");
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
		      format(string, sizeof string, " • !%s - יצרת קלאן למפקדה", tmpclan3);
			  SendClientMessage(playerid, orange, string);
			  Admin_ClanMessageToAll(tmpclan3, orange, " • /HQ - האדמין יצר לקלאן שלכם מפקדה, רוצה לראות אותה? הקש/י");
		      return 1;
		  }
		  if(_equal(tmpclan2,"setarea") && IsPlayerAdmin(playerid))
		  {
		     new tmpclana2[256],tmpclana1[256], Float:pos[3], i = 0;
		     tmpclana1 = strtok(cmdtext, idx);
		     tmpclana2 = strtok(cmdtext, idx);
		     GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		     if(!dini_Exists(HQ_ClanFile(tmpclana1))) return error(playerid,".קלאן זה לא קיים / לקלאן זה אין מפקדה");
		     if(!strlen(tmpclana2) || !strlen(tmpclana1)) return SendClientMessage(playerid, white, "Usage: /clan hq setarea [Clan Name] [1-2] (1 = x1 + y1 | 2 = x2 + y2)");
		     if(strval(tmpclana2) < 1 && strval(tmpclana2) > 2) return error(playerid, ".מספר איזור שגוי");
		     while(i < 2)
		     {
			     format(string,sizeof string,!i? ("x%i") : ("y%i"), strval(tmpclana2));
			     dini_FloatSet(HQ_ClanFile(tmpclana1), string, !i? pos[0] : pos[1]);
			     i++;
	     	 }
		     SendClientMessage(playerid, orange, strval(tmpclana2) == 2? ("!בהצלחה x2 + y2 שינת את האקורדים") : ("!בהצלחה x1 + y1 שינת את האקורדים"));
			 return 1;
		  }
		  if(_equal(tmpclan2, "remove"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan HQ Remove [Clan Name]");
			  if(!dini_Exists(HQ_ClanFile(tmpclan3))) return error(playerid,".לקלאן זה אין מפקדה");
			  dini_Remove(HQ_ClanFile(tmpclan3));
			  format(string, sizeof string, " • !%s - מחקת את המפקדה לקלאן", tmpclan3);
			  SendClientMessage(playerid, orange, string);
			  Admin_ClanMessageToAll(tmpclan3, red, " •  !אין לכם יותר מפקדה, האדמין מחק אותה, אם אתה רוצה להגיש תלונה גש לפורום שלנו");
		      return 1;
		  }
		  return error(playerid,".פקודת קלאן שגויה");
	  }
	  if(_equal(tmpclan,"remove") && IsPlayerAdmin(playerid))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Remove [Name]");
		  if(!dini_Exists(ClanFile(tmpclan2))) return error(playerid,".לא קיים קלאן כזה");
		  dini_IntSet("/Clans/Main.txt", "Total", dini_Int("/Clans/Main.txt", "Total")-1);
		  dini_Remove(ClanFile(tmpclan2));
		  if(dini_Exists(HQ_ClanFile(tmpclan2))) dini_Remove(HQ_ClanFile(tmpclan2));
		  return 1;
	  }
	  if(_equal(tmpclan, "bank"))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 4) return error(playerid, getPlayerClanLevel(playerid) > 0? (".פקודה זו לבעלי הקלאן בלבד") : (".אתה לא נמצא בשום קלאן"));
		  if(!dini_Exists(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")))) return error(playerid, ".אין לקלאן שלך מפקדה");
		  if(!strlen(tmpclan2))
		  {
             SendHeader(playerid,"Clan Bank - בנק קלאן");
             SendClientMessage(playerid,0x16EB43ff," [01] • /Clan Bank MaxWithdraw - שינוי ה\"מקסימום משיכה\" ליום אחד, לשחקן");
             SendClientMessage(playerid,0x16EB43ff," [02] • /Clan Bank SetPos - שינוי המיקום של הבנק");
             SendClientMessage(playerid,0x16EB43ff," [03] • /Clan Bank Lock - על מנת לנעול / לפתוח את הבנק של הקלאן");
			 return 1;
		  }
		  if(_equal(tmpclan2, "maxwithdraw"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Bank MaxWithdraw [Amount]");
			  if(strval(tmpclan3) > 1000000 || strval(tmpclan3) <= 1) return error(playerid, ".סכום שינוי שגוי");
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_MaxWithdraw", strval(tmpclan3));
		      format(string, sizeof string, " • !%d$ :שינה את המקסימום משיכה לבנק ליום לסכום של כ %s - הבעלים של הקלאן", strval(tmpclan3), GetName(playerid));
		      SendClanMessageToAll(playerid, red, string);
			  return 1;
		  }
		  if(_equal(tmpclan2, "lock"))
		  {
             dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? 0 : 1);
			 format(string, sizeof string, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? (" • !נעל את הבנק של הקלאן %s - הבעלים של הקלאן") : (" • !פתח את הבנק של הקלאן %s - הבעלים של הקלאן"), GetName(playerid));
			 SendClanMessageToAll(playerid, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "Bank_Lock")? red : 0x16EB43FF, string);
			 return 1;
		  }
		  if(_equal(tmpclan2, "setpos"))
		  {
		      new Float:pos[3];
	    	  GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	  	      if(!isPlayerInHerHQ(playerid)) return SendClientMessage(playerid,red, ".על מנת לבצע פקודה שינוי המפקדה אתה צריך להיות במפקדה שלך");
			  if(dini_Float(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BX") != 0.0) CPS_RemoveCheckpoint(clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")]);
              clanBanks[dini_Int(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "HQ_Count")] = CPS_AddCheckpoint(pos[0], pos[1], pos[2], 2.5, 20);
              dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BX", pos[0]);
              dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BY", pos[1]);
              dini_FloatSet(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")), "BZ", pos[2]);
		      format(string, sizeof string, " • !שינה את המיקום של הבנק של הקלאן %s - הבעלים של הקלאן",  GetName(playerid));
		      SendClanMessageToAll(playerid, red, string);
			  return 1;
		  }
		  return error(playerid,".פקודת קלאן שגויה");
	  }
	  if(_equal(tmpclan,"create"))
	  {
		  new tmpclan2[256], date[3];
		  getdate(date[2], date[1], date[0]);
		  tmpclan2 = strtok(cmdtext, idx);
          format(string, sizeof string , "%s",GetDateAsString('/', 1));
		  if(_GetPlayerMoney(playerid) < clanCost) return SendClientMessage(playerid,red,".אתה צריך לפחות 300000$ על מנת לפתוח קלאן");
		  if(dini_Exists(ClanPlayerFile(playerid))) return error(playerid,".אתה כבר נמצא בקלאן");
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Create [Name]");
		  if(dini_Exists(ClanFile(tmpclan2))) return error(playerid,".קיים כבר קלאן בשם כזה");
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
		  format(string, sizeof string, " -------- [ %s - יצרת קלאן חדש בשם ] -------- ", tmpclan2);
		  SendClientMessage(playerid, white, string);
		  SendClientMessage(playerid, 0x16EB43FF," • /Clan Invite - על מנת להזמין שחקן לקלאן החדש שלך");
		  SendClientMessage(playerid, 0x16EB43FF," • /Clan Edit Color - על מנת לערוך את הצבע של הקלאן שלך");
		  SendClientMessage(playerid, 0x16EB43FF," • /Clans  - על מנת לראות קלאנים קיימים בשרת");
		  SendClientMessage(playerid, 0x16EB43FF," • /Clan - על מנת לראות עוד פקודות זמינות");
		  SendClientMessage(playerid, orange," • '@' - כדי לדבר בצ'אט של הקלאן שלך");
		  SendClientMessage(playerid, white, " -------------------------------------- ");
		  _GivePlayerMoney(playerid, -1*clanCost);
	 	  return 1;
	  }
	  if(_equal(tmpclan, "info"))
 	  {
		  new tmpclan4[256];
		  tmpclan4 = strtok(cmdtext, idx);
		  if(!strlen(tmpclan4))
		  {
		      SendClientMessage(playerid,white," --- Clan Info - קלאן מידע --- ");
		      SendClientMessage(playerid,0x16EB43ff," [01] • /Clan Info Stats - הסטאטס של הקלאן");
		      SendClientMessage(playerid,0x16EB43ff," [02] • /Clan Info Details - מידע על הקלאן");
		      SendClientMessage(playerid,0x16EB43ff," [03] • /Clan Info Memmbers - מידע שחקנים רשומים על הקלאן");
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
			 if(!dini_Exists(ClanFile(tmpclan3))) return error(playerid,".לא קיים קלאן כזה");
		     format(string, sizeof string, " -------- [ Clan(%s) - Statics] -------- ",tmpclan3);
		     SendClientMessage(playerid, white, string);
	 	     format(string, sizeof string, getClanConnected(tmpclan3) > 0? (" • %d - שחקנים מחוברים מקלאן זה כעת") : (" • .אין כעת שחקנים מחוברים לקלאן זה"),getClanConnected(tmpclan3));
	 	     SendClientMessage(playerid, getClanConnected(tmpclan3) > 0? 0x16EB43FF : red, string);
	 	     format(string, sizeof string, dini_Int(ClanFile(tmpclan3),"Kills") != 0? (" • %d - חישוב כל ההריגות של השחקנים מאז הצטרפותם לקלאן") : (" • .אין ממוצע הריגות לקלאן זה"),dini_Int(ClanFile(tmpclan3),"Kills"));
	 	     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Kills") != 0? 0x16EB43FF : red, string);
	 	     format(string, sizeof string, dini_Int(ClanFile(tmpclan3),"Bank") != 0? (" • %d$ - סכום הכסף שיש לקלאן הזה בחשבון") : (" • .לקלאן זה אין כסף בבנק"),dini_Int(ClanFile(tmpclan3),"Bank"));
	 	     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Bank") != 0? 0x16EB43FF : red, string);
		     format(string, sizeof string, " • ./Clan Info [Details/Memmbers] %s - לעוד מידע על הקלאן", tmpclan3);
		     SendClientMessage(playerid, orange, string);
			 SendClientMessage(playerid, white, " -------------------------------------- ");
	 	     return 1;
	 	  }
 		  if(_equal(tmpclan4, "details"))
		  {
			 new tmpclan3[256], _skin[12], _bank[128];
			 tmpclan3 = strtok(cmdtext, idx);
			 if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Info Details [name]");
			 if(!dini_Exists(ClanFile(tmpclan3))) return error(playerid,".לא קיים קלאן כזה");
			 format(_skin, 12, dini_Int(ClanFile(tmpclan3),"Skin") >= 1? ("%i") : ("אין"), dini_Int(ClanFile(tmpclan3),"Skin"));
			 format(_bank, sizeof _bank, dini_Int(ClanFile(tmpclan3),"Bank") / dini_Int(ClanFile(tmpclan3),"Total") >= 1? ("%i") : ("אין ממוצע של כסף בבנק"), dini_Int(ClanFile(tmpclan3),"Bank") / dini_Int(ClanFile(tmpclan3),"Total"));
		     format(string, sizeof string, " -------- [ Clan(%s) - Details ] -------- ", tmpclan3);
		     SendClientMessage(playerid, white, string);
		     format(string, sizeof string, " • %i - נוצר בתאריך - %s - מספר שחקנים כולל  • %s - נוצר על ידי",dini_Int(ClanFile(tmpclan3),"Total"), dini_Get(ClanFile(tmpclan3),"Opend_Date"),dini_Get(ClanFile(tmpclan3),"Clan_Owner"));
		     SendClientMessage(playerid, 0x16EB43FF, string);
		     format(string, sizeof string, " • הסקין של הקלאן: %s • לכל אחד מהשחקנים בקלאן יש ממוצע בבנק: %d.0$", _skin, _bank);
		     SendClientMessage(playerid, 0x16EB43FF, string);
		     format(string, sizeof string, !dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In")? (" • קלאן זה לא השתתף עדיין בטורנירים") : (" • %d/%d ניצחונות בטורנירים"),dini_Int(ClanFile(tmpclan3),"Tournament_Victory"), dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In"));
		     SendClientMessage(playerid, !dini_Int(ClanFile(tmpclan3),"Tournament_Take_Part_In")? red : 0x16EB43FF, string);
		     format(string, sizeof string, !strcmp(dini_Get(ClanFile(tmpclan3),"Clan_Message"), "None", false)? (" • אין שום הודעה ממנהלי הקלאן") : (" • %s"), dini_Get(ClanFile(tmpclan3),"Clan_Message"));
		     SendClientMessage(playerid, !strcmp(dini_Get(ClanFile(tmpclan3),"Clan_Message"), "None", false)? red : 0x16EB43FF, string);
		     SendClientMessage(playerid, dini_Int(ClanFile(tmpclan3),"Test")? 0x16EB43FF : red, dini_Int(ClanFile(tmpclan3),"Test")? (" • הקלאן פתוח לטסטים") : (" • הקלאן סגור לטסטים"));
		     format(string, sizeof string, " • ./Clan Info [Stats/Memmbers] %s - לעוד מידע על הקלאן", tmpclan3);
		     SendClientMessage(playerid, orange, string);
			 SendClientMessage(playerid, white, " -------------------------------------- ");
	 	     return 1;
	 	  }
		  return error(playerid,".פקודת קלאן שגויה");
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
	       if(!isPlayerInClan(playerid)) return error(playerid, ".אתה לא נמצא בשום קלאן");
 		   format(string, sizeof string," • !%s - עזבת בהצלחה את הקלאן ,%s - שלום לך", dini_Get(ClanPlayerFile(playerid), "Clan_Name"), GetName(playerid));
		   error(playerid, string);
		   format(string, sizeof string, " • !עזב את הקלא %s - השחקן", GetName(playerid));
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
		   if(getPlayerClanLevel(playerid) < 3) return error(playerid, getPlayerClanLevel(playerid) > 0? (".פקודה זו ללידרים וסגני לידרים בלבד") : (".אתה לא נמצא בשום קלאן"));
		   if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Kick [playerid]");
		   if(!IsPlayerConnected(id)) return error(playerid,".שחקן זה לא מחובר");
		   if(!isPlayerInClan(id)) return error(playerid, ".שחקן זה לא נמצא בשום קלאן");
   		   if(getPlayerClanLevel(playerid) < getPlayerClanLevel(id) || !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false))
		   {
		      error(playerid, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false)? (".אתה לא יכול להעיף את הבעלים של הקלאן") : (".אתה לא יכול להעיף שחקן שהרמה שלו בקלאן יותר גבוה משלך"));
		      format(string, sizeof string, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(id), false)? (" • (%s) !ניסה להעיף את הבעלים של הקלאן ,%s - השחקן") : (" • (%s) !ניסה להעיף שחקן מהקלאן ברמה יותר גבוה ממנו ,%s - השחקן"), GetName(id), GetName(playerid));
		      SendClanMessageToAllEx(playerid, red, string);
		      return 1;
		   }
		   if(strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), false)) return error(playerid,".שחקן זה לא נמצא בקלאן שלך");
           format(string, sizeof string, "Clan_Player%i", dini_Int(ClanPlayerFile(id), "Clan_Memmber"));
		   dini_Set(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), string, "None");
  	       dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), "Total", dini_Int(ClanFile(dini_Get(ClanPlayerFile(id), "Clan_Name")), "Total")-1);
		   dini_Remove(ClanPlayerFile(id));
		   format(string, sizeof string," • !מהקלאן %s - בעטת את",GetName(id));
		   error(playerid, string);
 		   format(string, sizeof string," • !בעט אותך מהקלאן %s - הלידר ,%s - שלום לך",GetName(playerid), GetName(id));
		   SendClientMessage(id, red, string);
		   format(string, sizeof string, " • !%s נבעט מהקלאן על ידי %s - השחקן", GetName(playerid), GetName(id));
		   SendClanMessageToAllEx(playerid, red, string);
		   return 1;
	  }
	  if(_equal(tmpclan, "invite"))
	  {
		  new tmpclan2[256], id = -1;
		  tmpclan2 = strtok(cmdtext, idx);
		  id = IsNumeric(tmpclan2)? strval(tmpclan2) : GetPlayerID(tmpclan2);
		  if(getPlayerClanLevel(playerid) < 3) return error(playerid, getPlayerClanLevel(playerid) > 0? (".פקודה זו ללידרים וסגני לידרים בלבד") : (".אתה לא נמצא בשום קלאן"));
		  if(!strlen(tmpclan2)) return SendClientMessage(playerid, white,"Usage: /Clan Invite [playerid]");
		  if(!IsPlayerConnected(id)) return error(playerid,".שחקן זה לא מחובר");
		  if(isPlayerInClan(id)) return error(playerid, ".שחקן זה כבר נמצא בקלאן");
		  if(isInvited[id] == 1 && !strcmp(dini_Get(ClanPlayerFile(playerid),"Clan_Name"), clanName[id], true)) return error(playerid, ".שחקן זה כבר הוזמן לקלאן שלך");
		  format(string,sizeof string,".על מנת להצטרף לחץ אישור ,%s - הזמין אותך להצטרף לקלאן %s - השחקן",dini_Get(ClanPlayerFile(playerid), "Clan_Name"), GetName(playerid));
		  ShowPlayerDialog(id,0,DIALOG_STYLE_MSGBOX," •  /Clan Accept - קיבלת הזמנה לקלאן, על מנת להצטרף לחץ \"הצטרף\" או השתמש ב",string,"הצטרף","סגור חלון");
		  format(string, sizeof string," • !הצטרף לקלאן שלך %s - הזמנת את", GetName(id));
		  SendClientMessage(playerid, orange, string);
		  format(string, sizeof string, "!להצטרף לקלאן %s - הזמין את השחקן %s - הלידר", GetName(id), GetName(playerid));
		  SendClanMessageToAllEx(playerid, orange, string);
		  format(string, sizeof string," • !%s - הציע לך להצטרף לקלאן %s - השחקן", dini_Get(ClanPlayerFile(playerid),"Clan_Name"), GetName(playerid));
		  SendClientMessage(id, orange, string);
		  SendClientMessage(id,0x16EB43FF, " • (או השתמש בתפריט) /Clan Accept - על מנת לאשר את ההזמנה לקלאן ");
		  isInvited[id] = 1;
		  clanName[id] = dini_Get(ClanPlayerFile(playerid),"Clan_Name");
		  return 1;
	  }
	  if(_equal(tmpclan, "join") || _equal(tmpclan, "accept")) return !isPlayerInClan(playerid)? clan_Accept(playerid) : error(playerid,".אתה כבר נמצא בקלאן");
	  if(_equal(tmpclan, "set"))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 4) return error(playerid, getPlayerClanLevel(playerid) > 0? (".פקודה זו לבעלי הקלאן בלבד") : (".אתה לא נמצא בשום קלאן"));
		  if(!strlen(tmpclan2))
		  {
		      SendHeader(playerid,"Clan Set - קלאן הגדרות");
		      SendClientMessage(playerid,0x16EB43ff," [01] • /Clan Set Level - לשנות לשחק רמת קלאן");
		      SendClientMessage(playerid,0x16EB43ff," [02] • /Clan Set Skin [Skin-id/OFF] - על מנת לשנות את הסקין של הקלאן");
	  	      SendClientMessage(playerid,0x16EB43ff," [03] • /Clan Edit - לעוד אפשרויות");
		      return 1;
		  }
		  if(_equal(tmpclan2, "level"))
		  {
			  new tmpclan3[256], tmpclan4[256], name_level[34];
			  tmpclan3 = strtok(cmdtext, idx);
			  tmpclan4 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan4) || !strlen(tmpclan3) || strval(tmpclan4) > 4 || strval(tmpclan4) < 1) return SendClientMessage(playerid, white, "Usage: /Clan Set Level [playerid] [1 - Noraml | 2 - Tester | 3 - SubLeader | 4 - Owner + Leader]");
			  if(strval(tmpclan3) == playerid) return error(playerid, ".אתה לא יכול לערוך את הרמה שלך");
			  if(getPlayerClanLevel(playerid) < getPlayerClanLevel(strval(tmpclan3)) || !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false))
			  {
		          error(playerid, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false)? (".אתה לא יכול לשנות את הרמה של הבעלים") : (".אתה לא יכול לשנות רמה לשחקן גבוה ממך"));
		          format(string, sizeof string, !strcmp(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Owner")), GetName(strval(tmpclan3)), false)? (" • (%s) !השחקן ניסה לערוך את הרמה של הבעלים ,%s - השחקן") : (" • (%s) !ניסה לשנות את הרמה שלך בקלאן ,%s - השחקן"), GetName(strval(tmpclan3)), GetName(playerid));
		          SendClanMessageToAllEx(playerid, red, string);
		          return 1;
			  }
			  if(strval(tmpclan4) == 1) name_level = "Normal";
			  if(strval(tmpclan4) == 2) name_level = "Tester";
			  if(strval(tmpclan4) == 3) name_level = "SubLeader";
			  if(strval(tmpclan4) == 4) name_level = "Owner + Leader";
			  format(string, sizeof string, "!\"%s (%i)\" - ל %s - שינה את הרמה של ,%s - הבעלים", name_level, strval(tmpclan4), GetName(strval(tmpclan3)), GetName(playerid));
			  SendClanMessageToAll(playerid, orange, string);
			  dini_IntSet(ClanPlayerFile(strval(tmpclan3)), "Clan_Level", strval(tmpclan4));
			  return 1;
		  }
   		  if(_equal(tmpclan2, "skin"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white, "Usage: /Clan Set Skin [skin-id]");
			  if(isSkinCrash(strval(tmpclan3)) && strcmp(tmpclan3, "off", true)) return error(playerid, ".סקין שגוי");
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Skin", strcmp(tmpclan3, "off", true)? strval(tmpclan3) : -1);
			  format(string, sizeof string, strcmp(tmpclan3, "off", true)? (" • !%d :שינה את הסקין של הקלאן לאיידי ,%s - הבעלים") : (" • !הבעלים של הקלאן כיבה את הסקין התמידי"), strval(tmpclan3), GetName(playerid));
			  SendClanMessageToAll(playerid, orange, string);
 			  return 1;
		  }
		  return error(playerid,".פקודת קלאן שגויה");
	  }
	  if(_equal(tmpclan, "edit"))
	  {
		  new tmpclan2[256];
		  tmpclan2 = strtok(cmdtext, idx);
		  if(getPlayerClanLevel(playerid) < 3) return error(playerid, getPlayerClanLevel(playerid) > 0? (".פקודה זו ללידרים וסגני לידרים בלבד") : (".אתה לא נמצא בשום קלאן"));
		  if(!strlen(tmpclan2))
		  {
	  	      SendHeader(playerid,"Clan Edit - קלאן שינוי");
	  	      SendClientMessage(playerid,0x16EB43ff," [01] • /Clan Edit Color - על מנת ליצור קלאן");
	  	      SendClientMessage(playerid,0x16EB43ff," [02] • /Clan Edit HQ - שינוי המפקדה");
	  	      SendClientMessage(playerid,0x16EB43ff," [03] • /Clan Edit Test - פתיחה / סגירת האפשרויות לטסטים");
	  	      SendClientMessage(playerid,0x16EB43ff," [04] • /Clan Edit Comment - עריכת הודעת הקלאן");
	  	      SendClientMessage(playerid,0x16EB43ff," [05] • /Clan Set - לעוד אפשרויות");
			  return 1;
		  }
		  if(_equal(tmpclan2, "comment"))
		  {
			  new tmpclan3[256];
			  tmpclan3 = strtok_line(cmdtext, idx);
			  if(!strlen(tmpclan3)) return SendClientMessage(playerid, white,"Usage: /Clan Edit Comment [Action]");
			  dini_Set(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")),"Clan_Message",tmpclan3);
			  format(string, sizeof string, " • ./Clan Info Details - שינה את הסטאטוס של הקלאן, על מנת לצפות בו %s - הלידר", GetName(playerid));
			  SendClanMessageToAll(playerid, orange, string);
			  return 1;
		  }
		  if(_equal(tmpclan2, "test"))
		  {
			  SendClientMessage(playerid, orange, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? (".סגרת את האפשרות לטסטים לקלאן") : (".פתחת את האפשרות לטסטים לקלאן"));
			  dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Test", dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? 0 : 1);
			  format(string,sizeof string, dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "Tests")? ("!פתח את הקלאן לטסטים ,%s - הלידר") : ("!סגר את הקלאן לטסטים ,%s - הלידר"), GetName(playerid));
			  SendClanMessageToAllEx(playerid, orange, string);
			  return 1;
		  }
		  if(_equal(tmpclan2, "hq"))
		  {
			  new tmpclan3[256], Float:pos[3];
			  tmpclan3 = strtok(cmdtext, idx);
			  if(getPlayerClanLevel(playerid) < 4) return error(playerid, getPlayerClanLevel(playerid) > 0? (".פקודה זו לבעלי הקלאן בלבד") : (".אתה לא נמצא בשום קלאן"));
			  if(!dini_Exists(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid),"Clan_Name")))) return error(playerid, ".אין לקלאן שלך מפקדה");
			  if(!strlen(tmpclan3))
			  {
	  	         SendHeader(playerid,"Clan Edit HQ - קלאן שינוי מפקדה");
	  	         SendClientMessage(playerid,0x16EB43ff," [01] • /Clan Edit HQ CMD - שינוי הפקודה לשיגור המפקדה");
                 SendClientMessage(playerid,0x16EB43ff," [02] • /Clan Edit HQ Foot - שינוי המיקום של השיגור למפקדה לשחקן");
	  	         SendClientMessage(playerid,0x16EB43ff," [03] • /Clan Edit HQ Vehicle - שינוי המיקום של השיגור למפקדה לרכב");
	  	         return 1;
	  	      }
	  	      if(!isPlayerInHerHQ(playerid)) return SendClientMessage(playerid,red, ".על מנת לבצע פקודה שינוי המפקדה אתה צריך להיות במפקדה שלך");
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
				 SendClanMessageToAll(playerid, orange, _equal(tmpclan3, "vehicle")? (" • .הבעלים שינה את השיגור של הרכב למפקדה") : (" • .הבעלים שינה את השיגור של השחקן למפקדה"));
				 return 1;
	  	      }
	  	      if(_equal(tmpclan3, "cmd"))
	  	      {
				  new tmpclan4[256];
				  tmpclan4 = strtok(cmdtext, idx);
				  if(!strlen(tmpclan4)) return SendClientMessage(playerid, white, "Usage: /Clan Edit HQ Cmd [Command Name]");
				  if(tmpclan4[0] == '/') return error(playerid, ".אין צורך להשתמש ב \"/\" המערכת תוסיף את זה אוטומטי");
				  format(string, sizeof string, "/%s", tmpclan4);
				  dini_Set(HQ_ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "CMD", string);
				  format(string, sizeof string, " • /%s - שינה את הפקודה של השיגור למפקדה ל %s - הבעלים", tmpclan4, GetName(playerid));
				  SendClanMessageToAll(playerid, orange, string);
				  return 1;
			  }
			  return error(playerid,".פקודת קלאן שגויה");
		  }
		  if(_equal(tmpclan2, "color"))
		  {
		      new CC[3][256];
		      for(new d = 0; d < sizeof CC; d++) CC[d] = strtok(cmdtext, idx);
		      if(!strlen(CC[0]) || !strlen(CC[1]) || !strlen(CC[2])) return SendClientMessage(playerid,white,"Usage: /Clan Edit Color [red-1-255] [green-1-255] [blue-1-255]");
		      if(!strval(CC[0]) || strval(CC[0]) > 255 || !strval(CC[1]) || strval(CC[1]) > 255 || !strval(CC[2]) || strval(CC[2]) > 255) return SendClientMessage(playerid,red,".צבע שגוי בדוק אם אחד מהמספרים חורג מהמספרים 1-255");
		      for(new i = 0; i < sizeof CC; i++)
		      {
			       format(string, sizeof string, "C%i", i + 1);
                   dini_IntSet(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), string, strval(CC[i]));
		      }
		      setPlayerClanColor(playerid);
		      format(string,sizeof string," • שינה את הצבע של הקלאן לצבע של הודעה זו ,%s - הלידר ", GetName(playerid));
		      SendClientMessage(playerid, sgba2hex(strval(CC[0]), strval(CC[1]), strval(CC[2]), 70), string);
		      return 1;
		  }
		  return error(playerid,".פקודת קלאן שגויה");
	  }
	  return error(playerid,".פקודת קלאן שגויה");
   }
   if(!strcmp(cmd, "/clans", true))
   {
	   new clanfile[128], count_clan = 0;
	   if !dini_Int("/Clans/Main.txt", "Total") *then return error(playerid,".אין קלאנים קיימים בשרת");
	   format(string, sizeof string, " -------- [ Memmber(s) Clan(s): %i] -------- ",dini_Int("/Clans/Main.txt", "Total"));
	   SendClientMessage(playerid, white, string);
	   for(new i = 0; i < dini_Int("/Clans/Main.txt", "Total") + 2; i++)
	   {
		  format(clanfile,sizeof clanfile,"Clan%i", i);
		  if(dini_Isset("/Clans/Main.txt", clanfile) && strcmp(dini_Get("/Clans/Main.txt", clanfile), "None", false))
		  {
		       format(string,sizeof string, " • %i. %s [Memmber(s): #%d | Connected Players: %d | Create By: %s]",count_clan + 1, dini_Get("/Clans/Main.txt", clanfile),1,getClanConnected(dini_Get("/Clans/Main.txt", clanfile)), dini_Get(ClanFile(dini_Get("/Clans/Main.txt", clanfile)),"Clan_Owner"));
		       SendClientMessage(playerid,dini_Exists(ClanPlayerFile(playerid)) && !strcmp(dini_Get(ClanPlayerFile(playerid),"Clan_Name"), dini_Get("/Clans/Main.txt", clanfile), false)? red : orange, string);
		       count_clan++;
		  }
		  else continue;
	   }
	   SendClientMessage(playerid, white, " -------------------------------------- ");
	   return 1;
   }
   return 0;
}
stock vipCommands(playerid, cmdtext[], cmd[], idx, string[256])
{
   if(!strcmp(cmd, "/vdeposit", true))
   {
	  new tmpvip[256];
	  tmpvip = strtok(cmdtext, idx);
	  #define vcp tmpvip
	  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP אינך חבר");
	  if(!CPS_IsPlayerInCheckpoint(playerid, VIPBank)) return error(playerid, " • (VIP) אתה חייב להיות בבנק של האירגון שלך");
	  if(!strlen(tmpvip)) return SendClientMessage(playerid, white,"Usage: /vdeposit [amount]");
	  if(_GetPlayerMoney(playerid) < strval(tmpvip)) return SendClientMessage(playerid, white, _GetPlayerMoney(playerid) < 1? (".אין לך כסף בכלל") : (".אין לך את הסכום שציינת"));
	  format(string,sizeof string," • !%d$ - סכום של כ (VIP) הפקיד לחשבון האירגון %s - השחקן", strval(tmpvip), GetName(playerid));
	  SendVIPMessageToAll(VIPColor, string);
	  format(string,sizeof string," • !%d$ - המאזן האישי שלך עומד על כ", dini_Int(VIPFile(playerid),"Bank")+strval(tmpvip));
	  SendVIPMessageToAll(orange, string);
	  _GivePlayerMoney(playerid, -1*strval(tmpvip));
	  dini_IntSet(VIPFile(playerid), "Bank", dini_Int(VIPFile(playerid),"Bank")+strval(tmpvip));
	  dini_IntSet("/VIP/Stats.txt", "Bank", dini_Int("/VIP/Stats.txt", "Bank")+strval(tmpvip));
	  return 1;
   }
   if(!strcmp(cmd, "/vwithdraw", true))
   {
	  new tmpvip[256];
	  tmpvip = strtok(cmdtext, idx);
	  #define vcp tmpvip
	  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP אינך חבר");
	  if(!CPS_IsPlayerInCheckpoint(playerid, VIPBank)) return error(playerid, " • (VIP) אתה חייב להיות בבנק של האירגון שלך");
	  if(!strlen(tmpvip)) return SendClientMessage(playerid, white,"Usage: /vwithdraw [amount]");
	  if(dini_Int(VIPFile(playerid),"Bank") < strval(tmpvip)) return SendClientMessage(playerid, white, dini_Int(VIPFile(playerid),"Bank") < strval(tmpvip)? (".VIP - אין לך זכות למשוך כזאתי כמות של כסף מבנק ה") : (".VIP - אין לך זכות למשוך כסף מחשבון ה"));
	  format(string,sizeof string," • !%d$ - סכום של כ (VIP) משך מחשבון אירגון ה %s - השחקן", strval(tmpvip), GetName(playerid));
	  SendVIPMessageToAll(VIPColor, string);
	  format(string,sizeof string," • !%d$ - המאזן האישי שלך עומד על כ", dini_Int(VIPFile(playerid),"Bank")-strval(tmpvip));
	  SendVIPMessageToAll(orange, string);
	  _GivePlayerMoney(playerid, strval(tmpvip));
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
		  SendHeader(playerid,"VIP - אחמ\"ים");
		  SendClientMessage(playerid,0x16EB43FF,"[01] • /VIP HQ - שיגור למפקדה");
		  SendClientMessage(playerid,0x16EB43FF,"[02] • /VIP [Leave/Quit] - על מנת לעזוב את הקבוצה");
		  SendClientMessage(playerid,0x16EB43FF,"[03] • /VIP [Tag/Color] - לכבות / להפעיל את התאג / הצבע התמידי של האירגון");
		  SendClientMessage(playerid,0x16EB43FF,"[04] • /VIP Info [Details/Stats/Online] - לבדיקת נתונים");
		  SendClientMessage(playerid,0x16EB43FF,"[05] • /VIP CMDS - VIP פקודות מיוחדות לשחקני");
		  SendClientMessage(playerid,0x16EB43FF,"[06] • /VIP Memmbers (/VIPS) :על מנת להציג את החברי אחמ\"ים של השרת");
		  SendClientMessage(playerid,orange,"[07] • '$' :צ'אט VIPעל מנת לדבר ב");
		  if(IsPlayerAdmin(playerid))
		  {
		      SendClientMessage(playerid,red,"*[A01] • /VIP Remove [player name] - להוציא מישהו");
		      SendClientMessage(playerid,red,"*[A02] • /VIP Create [player name] - VIP ליצור למישהו משתמש");
		      SendClientMessage(playerid,red,"*[A03] • /VIP SetColor [red 1-255] [green 1-255] [blue 1-255] - VIP על מנת לשנות את הצבע של ה");
		      SendClientMessage(playerid,red,"*[A04] • /VIP SetBank - על מנת לשנות את המיקום של הבנק");
		      SendClientMessage(playerid,red,"*[A05] • /VIP SetArea [1-2] - לשנות את המיקום של הגבלת איזור, לא לגעת אם לא יודעים");
		  }
		  return 1;
	  }
	  if(_equal(vcp,"setarea") && IsPlayerAdmin(playerid))
	  {
		 new tmpvip2[256], Float:pos[3], i = 0;
		 tmpvip2 = strtok(cmdtext, idx);
		 GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		 if(!strlen(tmpvip2)) return SendClientMessage(playerid, white, "Usage: /vip setarea [1-2] (1 = x1 + y1 | 2 = x2 + y2)");
		 if(strval(tmpvip2) < 1 && strval(tmpvip2) > 2) return SendClientMessage(playerid, white, ".מספר איזור שגוי");
		 while(i < 2)
		 {
			 format(string, sizeof string, !i? ("x%i") : ("y%i"), strval(tmpvip2));
			 dini_FloatSet("/VIP/Main.txt", string, !i? pos[0] : pos[1]);
			 i++;
		 }
		 SendClientMessage(playerid, orange,strval(tmpvip2) == 2? ("!בהצלחה x2 + y2 שינת את האקורדים") : ("!בהצלחה x1 + y1 שינת את האקורדים"));
		 return 1;
	  }
	  if(_equal(vcp, "create") && IsPlayerAdmin(playerid))
	  {
		  new tmpvip2[256], id = -1;
		  tmpvip2 = strtok(cmdtext, idx);
		  format(string, sizeof string,"/Users/%s.ini",tmpvip2);
		  format(vpfile, sizeof vpfile,"/VIP/%s.ini", tmpvip2);
		  if(dini_Exists(vpfile)) return error(playerid, ".קיים כבר משתמש כזה");
		  if(!dini_Exists(string)) return error(playerid, ".אין שחקן כזה");
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
		  SendClientMessage(playerid, orange,id != playerid? ("• !VIP - יצרת לשחקן זה חשבון באירגון ה") : ("• !VIP - הוספת את עצמך לאירגון ה"));
		  return (id != -1 && !IsPlayerAdmin(id) && id != playerid)? SendClientMessage(id, orange,"/VIP :לקבלת עזרה VIP - האדמין צירף אותך לאירגון ה") : 1;
	  }
	  if(_equal(vcp, "remove") && IsPlayerAdmin(playerid))
	  {
		  new tmpvip2[256], id = -1;
		  tmpvip2 = strtok(cmdtext, idx);
		  format(string,sizeof string,"/Users/%s.ini",tmpvip2);
          format(vpfile, sizeof vpfile,"/VIP/%s.ini", tmpvip2);
		  if(!(dini_Exists(string) || dini_Exists(vpfile))) return error(playerid, !dini_Exists(string)? (".לא קיים משתמש בשם כזה") : (".VIP - שחקן זה לא חבר"));
		  if(!strlen(tmpvip2)) return SendClientMessage(playerid,white,"Usage: /VIP Remove [name]");
		  id = GetPlayerID(tmpvip2);
		  format(string, sizeof string, "VIP%i", dini_Int(vpfile, "ivc"));
		  dini_Set("/VIP/Main.txt", string, "None");
		  dini_Remove(vpfile);
		  dini_IntSet("/VIP/Main.txt", "Total", dini_Int("/VIP/Main.txt", "Total")-1);
		  SendClientMessage(playerid, orange,id != playerid? ("• !VIP - הוצאת בהצלחה את שחקן זה מאירגון ה") : ("• !VIP - הוצאת את עצמך מאירגון ה"));
		  return (id != -1 && !IsPlayerAdmin(id))? SendClientMessage(id, orange,"• Satla-Zone.co.il - אם אתה מעוניין להתלונן צלם תמונה זו וגש לפורום !VIP - האדמין הוציא אותך מאירגון ה") : 1;
	  }
	  if(_equal(vcp, "setbank") && IsPlayerAdmin(playerid))
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
		  SendClientMessage(playerid, VIPColor, " • !VIP - שינת את המיקום של הבנק של מפקדת ה");
		  return 1;
	  }
	  if(_equal(vcp, "setcolor") && IsPlayerAdmin(playerid))
	  {
		  new CC[3][256];
		  for(new d = 0; d < sizeof CC; d++) CC[d] = strtok(cmdtext, idx);
		  if(!strlen(CC[0]) || !strlen(CC[1]) || !strlen(CC[2])) return SendClientMessage(playerid,white,"Usage: /VIP SetColor [red-1-255] [green-1-255] [blue-1-255]");
		  if(!strval(CC[0]) || strval(CC[0]) > 255 || !strval(CC[1]) || strval(CC[1]) > 255 || !strval(CC[2]) || strval(CC[2]) > 255) return SendClientMessage(playerid,white,".צבע שגוי בדוק אם אחד חורג מהמספרים 1-255");
		  for(new i = 0; i < sizeof CC; i++)
		  {
			  format(string, sizeof string, "C%i", i+1);
			  dini_IntSet("/VIP/Details.txt", string, strval(CC[i]));
		  }
		  SendClientMessage(playerid, sgba2hex(strval(CC[0]), strval(CC[1]), strval(CC[2]), 200), " • .התמידי שונה לצבע של הודעה זו VIP - הצבע של ה");
		  return 1;
      }
      if(_equal(vcp, "color"))
      {
         if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP אינך חבר");
         dini_IntSet(VIPFile(playerid),"Color", !dini_Int(VIPFile(playerid),"Color")? 1 : 0);
         SendClientMessage(playerid,VIPColor, dini_Int(VIPFile(playerid),"Color")? (" • !VIP - הפעלת את הצבע התמידי של אירגון ה") : (" • !VIP - כיבת את הצבע התמידי של אירגון ה"));
         SetPlayerColor(playerid, dini_Int(VIPFile(playerid),"Color")? VIPColor : sgba2hex(random(256), random(256), random(256), 70));
		 return 1;
	  }
      if(_equal(vcp, "tag"))
      {
         if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP אינך חבר");
         dini_IntSet(VIPFile(playerid),"Tag", !dini_Int(VIPFile(playerid),"Tag")? 1 : 0);
         SendClientMessage(playerid, VIPColor, dini_Int(VIPFile(playerid),"Tag")? (" • !VIP - הפעלת את התאג התמידי של אירגון ה") : (" • !VIP - כיבת את התאג התמידי של אירגון ה"));
		 return 1;
	  }
	  if(_equal(vcp, "info"))
	  {
		 new vtmp[256];
		 vtmp = strtok(cmdtext, idx);
		 if(!strlen(vtmp))
		 {
		     SendHeader(playerid,"VIP - אחמ\"ים");
			 SendClientMessage(playerid,0x16EB43FF,"[01] • /VIP Info Details - VIP מידע על ה");
			 SendClientMessage(playerid,0x16EB43FF,"[02] • /VIP Info Stats - VIP מידע על ה");
			 SendClientMessage(playerid,0x16EB43FF,"[03] • /VIP Info Online - הצגת רשימת שחקנים מחוברים");
		     return 1;
		 }
		 if(_equal(vtmp,"memmbers")) return showVIPMemmbers(playerid);
		 if(_equal(vtmp, "online"))
		 {
			 new vicount = 0, x = getOnlineVIP();
			 if(!x) return SendClientMessage(playerid, white, !dini_Exists("/VIP/Main.txt") || !dini_Int("/VIP/Main.txt", "Total")? (".קיימים בשרת VIP אין חברי") : (".מחוברים כרגע VIP אין חברי"));
			 format(string, sizeof string, "-------- [ %i - שחקני אחמ\"ים מחוברים ] --------", x);
			 SendClientMessage(playerid, white, string);
			 for(new i = 0; i < MAX_PLAYERS; i++)
			 {
			      if(isPlayerVIP(i) && IsPlayerConnected(i))
			      {
					   vicount++;
					   format(string, sizeof string, " • %i. %s [VIP Level %d | ID: %d]", vicount, GetName(i),dini_Int(VIPFile(i),"Level"), i);
					   SendClientMessage(playerid, i == playerid? red : 0x16EB43FF, string);
			      }
			 }
			 SendClientMessage(playerid, white, "--------------------------------------");
			 return 1;
		 }
		 if(_equal(vtmp, "details"))
		 {
			 new x = getVIPMemmbers(), o = getOnlineVIP(), i = getIntoVIPHQ();
			 SendClientMessage(playerid, white, "-------- [ VIP Details - פרטי אחמ\"ים ] --------");
			 format(string, sizeof string, x != 0? (" • .%i רשומים VIP חברי") : (" • .VIP לא קיימים חברי"), x);
			 SendClientMessage(playerid, x != 0? 0x16EB43FF : red, string);
			 format(string, sizeof string, o != 0? (" • .%i מחוברים כרגע VIP חברי") : (" • .מחוברים VIP אין כרגע חברי"), o);
			 SendClientMessage(playerid, o != 0? 0x16EB43FF : red, string);
   			 format(string, sizeof string, i != 0? (" • .%i :VIP כמות האנשים אשר נמצאים באיזור מפקדת ה") : (" • .VIP - אין כרגע אנשים במפקדת ה"), i);
			 SendClientMessage(playerid, i != 0? 0x16EB43FF : red, string);
			 SendClientMessage(playerid, 0x16EB43FF, " • .10000$ - מקבלים סכום נאה לחשבון הבנק של כ VIP כל 5 ימים חברי ה");
			 SendClientMessage(playerid, !dini_Int("/VIP/Details.txt", "C1") && !dini_Int("/VIP/Details.txt", "C2") && !dini_Int("/VIP/Details.txt", "C3")? red : VIPColor, !dini_Int("/VIP/Details.txt", "C1") && !dini_Int("/VIP/Details.txt", "C2") && !dini_Int("/VIP/Details.txt", "C3")? (" • .VIP - לא קיים צבע תמידי לאירגון ה") : (" • .VIP - צבע של הודעה זו הינו צבעה של אירגון ה"));
			 SendClientMessage(playerid, orange, " • /VIP Info Stats - VIP כדי לראות את המאזן של חברי ה");
			 SendClientMessage(playerid, white, "--------------------------------------");
			 return 1;
		 }
		 if(_equal(vtmp, "stats"))
		 {
			 new x = getVIPMemmbers(), b = dini_Int("/VIP/Stats.txt", "Bank");
			 SendClientMessage(playerid, white, "-------- [ VIP Stats - סטאטס אחמ\"ים ] --------");
			 format(string, sizeof string," • .%d - מאז הצטרפותם VIP חישוב כל ההריגות של חברי ה", dini_Int("/VIP/Stats.txt", "Kills"));
			 SendClientMessage(playerid, 0x16EB43FF, string);
			 format(string, sizeof string," • $%d - VIP - סכום מצטבר בבנק של ה", dini_Int("/VIP/Stats.txt", "Bank"));
			 SendClientMessage(playerid, 0x16EB43FF, string);
   			 format(string, sizeof string, x > b? (" • הממוצע של חשבון הבנק אינו קיים כרגע") : (" • $%d - יש לו בבנק בממוצע VIP לכל שחקן באירגון"), b / x);
			 SendClientMessage(playerid, x > b? red : 0x16EB43FF, string);
			 SendClientMessage(playerid, orange, " • /VIP Info Details - VIP כדי לראות את פרטי ה");
			 SendClientMessage(playerid, white, "--------------------------------------");
			 return 1;
		 }
		 return error(playerid, ".שגויה VIP פקודת");
	  }
	  if(_equal(vcp, "hq"))
	  {
		  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP אינך חבר");
		  SendClientMessage(playerid,orange,"!VIP - ברוכים הבאים למפקדת ה");
		  return 1;
	  }
	  if(_equal(vcp,"leave") || _equal(vcp,"quit"))
	  {
 		  format(vpfile, sizeof vpfile,"/VIP/%s.ini", GetName(playerid));
		  if(!isPlayerVIP(playerid)) return SendClientMessage(playerid, white, ".VIP אינך חבר");
		  format(string, sizeof string, "VIP%i", dini_Int(vpfile, "ivc"));
		  dini_Set("/VIP/Main.txt", string, "None");
		  dini_Remove(vpfile);
   		  dini_IntSet("/VIP/Main.txt", "Total", dini_Int("/VIP/Main.txt", "Total")-1);
   		  error(playerid,"• !VIP - פרשת מאירגון ה");
		  return 1;
	  }
	  if(_equal(vcp, "memmbers")) return showVIPMemmbers(playerid);
      return error(playerid,".שגויה VIP פקודת");
   }
   return 0;
}
stock clan_Accept(playerid)
{
	 new string[128];
	 if(isPlayerInClan(playerid)) return error(playerid, ".אתה כבר נמצא בקלאן");
	 if(!isInvited[playerid]) return error(playerid,".לא הוזמנת לשום קלאן");
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
	 format(string, sizeof string," • !%s - הצטרפת בהצלחה לקלאן ,%s - שלום לך", dini_Get(ClanPlayerFile(playerid),"Clan_Name"), GetName(playerid));
	 SendClientMessage(playerid, orange, string);
	 ShowPlayerDialog(playerid,0,DIALOG_STYLE_MSGBOX,"!הצטרפת בהצלחה לקלאן:",string,"אישור","סגור חלון");
	 format(string, sizeof string, " • !הצטרף לקלאן, מזל טוב %s - השחקן", GetName(playerid));
	 SendClanMessageToAllEx(playerid, orange, string);
	 isInvited[playerid] = 0;
	 return 1;
}
stock clanMemmbers(playerid, tmpclan2[])
{
	new string[128], string2[128], string3[128], b = 0;
	if(!strlen(tmpclan2)) return SendClientMessage(playerid, white, "Usage: /Clan Memmbers [name]");
	if(!dini_Exists(ClanFile(tmpclan2))) return error(playerid,".לא קיים קלאן כזה");
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
	format(string, sizeof string, " • ./Clan Info [Stats/Details] %s - לעוד מידע על הקלאן", tmpclan2);
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
				 if(aLoad == 2) CreatePickup(strval(xreaded[0]),strval(xreaded[1]), floatstr(xreaded[2]), floatstr(xreaded[3]), floatstr(xreaded[4]), 0, mainPickups++, "None", 0);
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
stock setPlayerClanColor(playerid) return SetPlayerColor(playerid, sgba2hex(dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "C1"),dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "C2"), dini_Int(ClanFile(dini_Get(ClanPlayerFile(playerid), "Clan_Name")), "C2"), 70));
stock getMoveObjectNearPlayer(playerid)
{
	for(new i = 0; i < MAX_MOVE_GATES; i++)
	{
		 if(PlayerToPoint(playerid, 10.0, GateInfo[i][xn], GateInfo[i][yn], GateInfo[i][zn]))
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
	new vvip[128], vpfile[128], string[128], x = getVIPMemmbers();
	if(!x) return SendClientMessage(playerid, white,".VIP לא קיימים שחקני");
	format(string,sizeof string,"------- [ %d :שחקני אחמ\"ים רשומים ] -------",x);
	SendClientMessage(playerid, white, string);
	for(new i = 0; i < dini_Int("/VIP/Main.txt", "Total")+2; i++)
	{
		  format(vpfile,sizeof vpfile,"VIP%i", i);
		  if(dini_Isset("/VIP/Main.txt", vpfile) && strcmp(dini_Get("/VIP/Main.txt", vpfile), "None", true))
		  {
		       format(vvip, sizeof vvip,"/VIP/%s.ini", dini_Get("/VIP/Main.txt", vpfile));
		       format(string, sizeof string,GetPlayerID(dini_Get("/VIP/Main.txt", vpfile)) == INVALID_PLAYER_ID? (" • %s [VIP Level: %d]"): (" • %s [VIP Level: %d | ID: %d]"), dini_Get("/VIP/Main.txt", vpfile), dini_Int(vvip,"Level"), GetPlayerID(dini_Get("/VIP/Main.txt", vpfile)));
		       SendClientMessage(playerid,GetPlayerID(dini_Get("/VIP/Main.txt", vpfile)) == INVALID_PLAYER_ID? red : 0x16EB43FF, string);
		  }
		  else continue;
	}
	SendClientMessage(playerid, white, "--------------------------------------");
	return 1;
}
stock createTeleport(playerid, interior, Float:x, Float:y, Float:z, Float:a, withvehicle, level, message[], stpo)
{
   new string[128];
   if(PlayerInfo(inDM[playerid]) > 0 || inAct[playerid]) return error(playerid, ".אתה לא יכול להשתגר באמצע משחק");
   if(!dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports")) return error(playerid, "/buytele(bt) :נגמרו לך כרטיסי השיגור, על מנת לקנות עוד");
   if(dini_Int(getPlayerFile(playerid, _filestats), "Points") < stpo)
   {
      format(string, sizeof string, "!על מנת להשתגר למקום זה אתה צריך לפחות %i נקודות סטאנטים", stpo);
	  SendClientMessage(playerid, orange, string);
	  SendClientMessage(playerid, orange, "...על מנת להשיג נקודות סטאנטים תעשה תרגילים כגון: הרמת גלגל, סטופי, קפיצות גבוהות ועוד");
      return 1;
   }
   if(getPlayerLevel(playerid) < level)
   {
      format(string, sizeof string, "!שיגור זה משמש שחקנים מרמה %i בלבד", level);
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
   if(message[0] >= 97 && message[0] <= 122) message[0] -= 32;
   dini_IntSet(getPlayerFile(playerid, _filestats), "MaxTeleports", dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports")-1);
   format(string, sizeof string, "/buyteles - נשאר לך עוד %i שיגורים, על מנת לקנות עוד", dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports"));
   if(dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports") < 5) SendClientMessage(playerid, orange, string);
   format(string, sizeof string, "~y~~h~%s", message);
   GameTextForPlayer(playerid, string,3*1000, 6);
   return 1;
}
stock LoadTeleportsList()
{
	new File:fp, count = 0, tele_word[MAX_STRING];
	if(!fexist(teleports_lists))
	{
		fp = fopen(teleports_lists,io_write);
		fclose(fp);
	}
	fp = fopen(teleports_lists,io_read);
	while(fread(fp,tele_word,sizeof tele_word))
	{
	    tele_words[count] = tele_word;
		tele_words[count][strlen(tele_words[count])-1] = 0;
		count++;
		if(count == 100) break;
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
   if(!PlayerInfo(logged[playerid]) || PlayerInfo(logged[playerid]) == 2)
   {
      format(string, sizeof string, _state? ("/login :אתה חייב להתחבר לפני שתעשה פעולה זו ,%s") : ("/register :אתה חייב להירשם לפני שתעשה פעולה זו ,%s"), GetName(playerid));
      if(PlayerInfo(logged[playerid]) != 2) error(playerid, string);
      return 1;
   }
   else SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
   return 1;
}
UseCallback(OnPlayerJoin, playerid, name[], ip[], state_, autologin, isnpc)
{
   new string[128], var[12], Float:pos[3];
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   Clean(playerid);
   format(string, sizeof string, _fileconfig "%s.ini", ip);
   if(dini_Exists(string) && dini_Int(_fileconfig "BIP.ini", ip))
   {
	  format(string, sizeof string, _fileconfig "%s.ini", ip);
	  format(string, sizeof string, " (%s) ", ip);
	  error(playerid, string);
	  format(string, sizeof string, ".נחסמה ל - 15 דקות מהשרת עקב ניסיון פריצה, אנא נסה להתחבר בעוד %i דקות IP - הכתובת", PlayerInfo(mints[dini_Int(string, "id")]));
	  error(playerid, string);
	  SetTimerEx("Kick_", 2000, false, "i", playerid);
	  return 1;
   }
   if(dini_Int(_fileconfig "UsersIP.ini", ip) == MAX_USERS_PER_PLAYER && !IsPlayerAdmin(playerid) && !state_)
   {
	  new dest[128] = "";
      format(string, sizeof string, "• כל שחקן רשאי לפתוח עד כ - %i שחקנים", MAX_USERS_PER_PLAYER);
	  SendClientMessage(playerid, red, string);
	  for(new i = 1; i <= dini_Int(_fileconfig "UsersIP.ini", ip); i++)
	  {
        format(var, sizeof var, "P%i", i);
        format(string, sizeof string, _fileips "%s.ini", ip);
        format(string, sizeof string, " %s (%s) •", dini_Get(string, var), dini_Get(getPlayerFile2(dini_Get(string, var), _fileusers), "Password"));
		strcat(dest, string);
	  }
	  SendClientMessage(playerid, orange, dest);
	  SendClientMessage(playerid, green, " - /changenick :שלום לך, שים לב, אם אתה רוצה כינוי חדש אתה לא חייב לפתוח משתמש חדש, תוכל להשתמש בשרת בפקודה");
	  SendClientMessage(playerid, darkblue, " - אם שחכת את הסיסמה של אחד השתמשים, היא כעת רשומה לך בסוגריים");
	  SetTimerEx("Kick_", 2000, false, "i", playerid);
	  return 1;
   }
   format(string, sizeof string," [%03i] " forum " - LucifeR DeathMatch - שלום לך, וברוכים הבאים לשרת", playerid);
   SendClientMessage(playerid, orange, string);
   if(!autologin)
   {
       format(string, sizeof string, state_? (" .על מנת להתחיל לשחק עליך להתחבר ,%s שלום לך") : (" .על מנת להתחיל לשחק עליך להירשם ,%s שלום לך"), GetName(playerid));
       SendClientMessage(playerid, green, string);
       SendClientMessage(playerid, pink, state_? (" (או השתמש בתפריט) • /Login [Password] - להתחברות הקש/י") : (" (או השתמש בתפריט) • /Register - להרשמה הקש/י"));
   }
   else if(autologin && !strcmp(ip, dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connect_IP"), false) && state_)
   {
       format(string, sizeof string, " (%s) .שלך IP - התחברת אוטומטית ע\"י כתובת ה ,%s שלום לך", ip, GetName(playerid));
       SendClientMessage(playerid, green, string);
   }
   SendClientMessage(playerid, darkblue, " SA-MP.co.il > LucifeR DeathMatch - אל תשכח להיות איתנו בקשר בפורום");
   if(state_ && !PlayerInfo(logged[playerid]) && !autologin) ShowPlayerDialog(playerid,5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה שלך על מנת להתחבר ולהתחיל לשחק", "התחבר", "ביטול");
   if(!state_ && !PlayerInfo(logged[playerid]) && !autologin) ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
   if(isnpc) PlayerInfo(logged[playerid] = true);
   if(autologin && !strcmp(ip, dini_Get(getPlayerFile(playerid, _fileusers), "Last_Connect_IP"), false)) _Callback(login, playerid, dini_Get(getPlayerFile(playerid, _fileusers), "Password"));
   PlayerInfo(worngPassword[playerid]) = MAX_WORNGS_LOGIN;
   PlayerInfo(isafk[playerid]) = false;
   PlayerInfo(MoneyStunts[playerid]) = 0;
   PlayerInfo(InVehicle2[playerid]) = 0;
   PlayerInfo(InVehicle3[playerid]) = 0;
   AC_Info[playerid][cash] = 0;
   format(string, sizeof string, GetPlayerWantedLevel(playerid) < 1? ("%s, ID: #%i, Level: %i") : ("%s, ID: #%i, Level: %i\n Wanted Player!!!!"), GetName(playerid), playerid, getPlayerLevel(playerid), GetPlayerWantedLevel(playerid));
   if(_:ShowInfoPlayers[playerid] == -1 || !_:ShowInfoPlayers[playerid]) ShowInfoPlayers[playerid] = Create3DTextLabel(string, yellow, pos[0], pos[1], pos[2]+0.2, 8.0, 0, 0);
   else Update3DTextLabelText(ShowInfoPlayers[playerid], GetPlayerWantedLevel(playerid) < 1? white : red, string);
   Attach3DTextLabelToPlayer(ShowInfoPlayers[playerid], playerid, 0.0, 0.0, 0.2);

   countTottalyConnectes(GetName(playerid), GetIP(playerid));
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
      format(string, sizeof string, " !אנא הזן סיסמה - %s", GetName(playerid));
	  ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה שלך על מנת להתחבר ולהתחיל לשחק", "התחבר", "ביטול");
	  error(playerid, string);
	  return 1;
   }
   if(strcmp(password, dini_Get(getPlayerFile(playerid, _fileusers), "Password"), true))
   {
	  format(string, sizeof string, "%s You have %02d more %s to login.", GetName(playerid), PlayerInfo(worngPassword[playerid]), PlayerInfo(worngPassword[playerid]) > 1? ("attempts") : ("attempt"));
	  error(playerid, string);
	  PlayerInfo(worngPassword[playerid])--;
	  if(PlayerInfo(worngPassword[playerid]) != 0) ShowPlayerDialog(playerid, 5, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה שלך על מנת להתחבר ולהתחיל לשחק", "התחבר", "ביטול");
	  if(!PlayerInfo(worngPassword[playerid]))
	  {
		  error(playerid, ".לא תוכל להיכנס ב - 15 דקות הבאות לשרת בגלל שטעית בסיסמה 5 פעמים");
		  dini_IntSet(_fileconfig "BIP.ini", GetIP(playerid), 1);
		  dini_IntSet(_fileconfig "BIP.ini", "Total", dini_Int(_fileconfig "BIP.ini", "Total") + 1);
		  PlayerInfo(mints[dini_Int(_fileconfig "BIP.ini", "Total")]) = 15;
		  SetTimerEx("unTempban", 1*60*1000, false, "s", GetIP(playerid), dini_Int(_fileconfig "BIP.ini", "Total"));
		  format(string, sizeof string, _fileconfig "%s.ini", GetIP(playerid));
		  dini_Create(string);
		  dini_IntSet(string, "id", dini_Int(_fileconfig "BIP.ini", "Total"));
		  SetTimerEx("Kick_", 3000, false, "i", playerid);
	  }
      return 1;
   }
   Stimers[playerid][0] = SetTimerEx("antiCheat", 2000, true, "i", playerid);
   Stimers[playerid][1] = SetTimerEx("stunts", 600, true, "i", playerid);
   Stimers[playerid][2] = SetTimerEx("_mints", 60*1000, false, "is", playerid, GetName(playerid));
   Stimers[playerid][3] = SetTimerEx("ShowMainTextDraw", 3000, true, "i", playerid);
   PlayerInfo(logged[playerid] = true);
   format(string, sizeof string, "*** %s has logged the server.", GetName(playerid));
   msgSetting(playerid, grey, string, 0, true);
   SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
   ShowPlayerDialog(playerid,100,DIALOG_STYLE_MSGBOX,"   !ההתחברות בוצעה", "/HelpMe :לקבלת עזרה מאחד התומכים\n/Help - לקבלת עזרה\n\n!מקווים שתהנה SA-MP.co.il - התחברת בהצלחה ל","אישור","סגור חלון");
   return 1;
}
function(OnPlayerDisconnect(playerid, reason))
{
   new string[128];
   format(string, sizeof string, "*** %s has quit the server.", GetName(playerid));
   if(PlayerInfo(logged[playerid]))
   {
	  msgSetting(playerid, grey, string, 1, true);
	  SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
   }
   PlayerInfo(logged[playerid]) = false;
   format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(playerid));
   if(dini_Exists(string)) dini_BoolSet(string, settings[3], false);
   for(new i = 0; i < 4; i++) if(Stimers[playerid][i] != -1) KillTimer(Stimers[playerid][i]);
   return 1;
}
UseCallback(register, playerid, password[], ip[])
{
   new string[128], var[32], File:f;
   if(strlen(password) > 30 || strlen(password) < 6)
   {
	  ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
	  SendClientMessage(playerid, red, strlen(password) > 30? (".הסיסמה ארוכה מדי, סיסמה נעה בין 6-30 תווים") : (".סיסמה קצרה מדי, סיסמה נעה בין 6-30 תווים"));
	  return 1;
   }
   if(!strlen(password))
   {
      format(string, sizeof string, " !אנא הזן סיסמה - %s", GetName(playerid));
	  ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
	  error(playerid, string);
	  return 1;
   }
   if(isSimple(password))
   {
      ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה הרצויה לפתיחת חשבון בשרתנו", "הרשם", "ביטול");
      error(playerid, "  !סיסמה פשוטה מדי, אנא בחר סיסמה אחרת");
	  return 1;
   }
   if(dini_Exists(getPlayerFile(playerid, _fileusers))) return ShowPlayerDialog(playerid,6, DIALOG_STYLE_INPUT, "  Welcome to - " forum " DeathMatch"," • שלום לך, אנא הקש/י את הסיסמה שלך על מנת להתחבר ולהתחיל לשחק", "התחבר", "ביטול");
   if(!dini_Exists(getPlayerFile(playerid, _fileusers))) dini_Create(getPlayerFile(playerid, _fileusers));
   dini_IntSet(_fileconfig "UsersIP.ini", "Total", dini_Int(_fileconfig "UsersIP.ini", "Total") + 1);
   dini_IntSet(_fileconfig "UsersIP.ini", GetIP(playerid), dini_Int(_fileconfig "UsersIP.ini", GetIP(playerid)) + 1);
   format(string, sizeof string, _fileips "%s.ini", GetIP(playerid));
   if(!dini_Exists(string)) dini_Create(string);
   format(var, sizeof var, "P%i", dini_Int(_fileconfig "UsersIP.ini", GetIP(playerid)));
   dini_Set(string, var, GetName(playerid));
   dini_IntSet(_fileconfig "Main.ini", "CountPlayers", dini_Int(_fileconfig "Main.ini", "CountPlayers") + 1);
   format(string, sizeof string, "Player%05d=%s\n\r", dini_Int(_fileconfig "Main.ini", "CountPlayers"), GetName(playerid));
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
   dini_Set(getPlayerFile(playerid, _fileusers), "LastChangeNick", "None");
   dini_Set(getPlayerFile(playerid, _fileusers), "Last_Money_Date", GetDateAsString('/', 1));
   dini_IntSet(getPlayerFile(playerid, _fileusers), "Userid", dini_Int(_fileconfig "Main.ini", "CountPlayers"));
   _Callback(createAnother, playerid);
   SendHeader(playerid, "Registered Complete - ההרשמה בוצעה");
   format(string, sizeof string, " • >> \"%s\" - סיסמה", password);
   SendClientMessage(playerid, lightblue, string);
   format(string, sizeof string, " • >> \"%s\" - שם משתמש", GetName(playerid));
   SendClientMessage(playerid, lightblue, string);
   format(string, sizeof string, " • >> \"%05d\" - המספר הסידורי שלך", dini_Int(_fileconfig "Main.ini", "CountPlayers"));
   SendClientMessage(playerid, lightblue, string);
   SendClientMessage(playerid, orange, " • /editprofile - על מנת לערוך את הפרופיל שלך");
   SendClientMessage(playerid, orange, " • /setting - על מנת לערוך ההגדרות האישיות שלך");
   SendClientMessage(playerid, orange, " • /stats - על מנת לצפות בפרופיל שלך");
   _GivePlayerMoney(playerid, 1500);
   SendClientMessage(playerid, red, " /bank - שים לב כדאי לך להפקיד את הכסף הזה בבנק! אתה מקבל כסף פעם ביום, כל יום אתה מקבל 1500$, לך תפקיד בבנק");
   SendClientMessage(playerid, darkblue, " • Gamemode version: " version " • Ventrilo IP: " ventrilo " • Last Update: " lastupdate);
   Stimers[playerid][0] = SetTimerEx("antiCheat", 2000, true, "i", playerid);
   Stimers[playerid][1] = SetTimerEx("stunts", 600, true, "i", playerid);
   Stimers[playerid][2] = SetTimerEx("_mints", 60*1000, false, "is", playerid, GetName(playerid));
   PlayerInfo(logged[playerid]) = 1;
   return 1;
}
UseCallback(createAnother, playerid)
{
   new string[128];
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
   dini_IntSet(getPlayerFile(playerid, _filestats), "MaxTeleports", 50);
   dini_IntSet(getPlayerFile(playerid, _filestats),"Vehicle_ID", 0);
   dini_FloatSet(getPlayerFile(playerid, _filestats), "Seniority", 0.0);
   dini_Set(getPlayerFile(playerid, _filestats), "Tag", "Mickey Mouse");
   format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(playerid));
   if(!dini_Exists(string)) dini_Create(string);
   dini_BoolSet(string, settings[0], true);
   dini_BoolSet(string, settings[1], false);
   dini_BoolSet(string, settings[2], true);
   dini_BoolSet(string, settings[3], false);
   dini_BoolSet(string, settings[5], true);
   dini_BoolSet(string, settings[4], true);
   dini_BoolSet(string, settings[5], true);
   dini_BoolSet(string, settings[6], true);
   return 1;
}
function(_mints(playerid, name[]))
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
   if(PlayerInfo(logged[playerid]) && !PlayerInfo(isafk[playerid]) && !strcmp(name, GetName(playerid), false)) Stimers[playerid][2] = SetTimerEx("_mints", 60*1000, false, "is", playerid, GetName(playerid));
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
   if(!IsPlayerConnected(id)) return error(playerid, ".שחקן זה לא מחובר");
   if(action)
   {
       for(new i = 0; i < 5; i++) SendClientMessage(playerid, white, "\n");
	   PlayerInfo(logged[playerid] = true);
   }
   GetPlayerHealth(id, _health);
   GetPlayerArmour(id, _armour);
   GetPlayerPos(id, PlayerInfo(vspeed[playerid][0]), PlayerInfo(vspeed[playerid][1]), z);
   GetVehicleHealth(IsPlayerInAnyVehicle(id)? GetPlayerVehicleID(id) : 2, _vhealth);
   format(_id, sizeof _id, id != playerid? ("%i") : (""), id);
   if(IsPlayerInAnyVehicle(playerid)) format(string2, 128, "YES(Type: %s | Health: %.1f%s | Speed: %.1f%s)", VehiclesName[GetVehicleModel(GetPlayerVehicleID(id))-400], _vhealth, "%%", GetPlayerSpeed(id, PlayerInfo(vspeed[id][0]), PlayerInfo(vspeed[id][1])), "%%");
   format(string, sizeof string, playerid == id? ("  -------- You're Statics - %s (ID: %03i | USERID: %05d): --------") : ("  -------- %s (ID: %03i | USERID: %05d) - Statics: --------"), GetName(id), id, dini_Int(getPlayerFile(id, _fileusers), "Userid"));
   SendClientMessage(playerid, white, string);
   format(string, sizeof string, "   [%s] • %03i - רמה", dini_Get(getPlayerFile(id, _filestats), "Tag"), dini_Int(getPlayerFile(id, _filestats), "Level"));
   SendClientMessage(playerid, id == playerid? grey : pink, string);
   format(string, sizeof string, "   נקודות סטאנטים: %i • נקודות בונוס: %i • רמת כבוד: %i • הריגות: %i • מיתות: %i", dini_Int(getPlayerFile(id, _filestats), "Points"), dini_Int(getPlayerFile(id, _filestats), "Bonus"), dini_Int(getPlayerFile(id, _filestats), "Respect"), dini_Int(getPlayerFile(id, _filestats), "Kills"), dini_Int(getPlayerFile(id, _filestats), "Deaths"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, dini_Exists(ClanPlayerFile(playerid))? ("   חבר כבוד: %s • (/clan info [details/stats] %s) %s :קלאן") : ("   חבר כבוד: %s • %s :קלאן"), isPlayerVIP(playerid)? ("כן") : ("לא"), dini_Exists(ClanPlayerFile(id))? dini_Get(ClanPlayerFile(id), "Clan_Name") : ("None"), dini_Get(ClanPlayerFile(id), "Clan_Name"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, "   חיים: %.1f%s • מגן: %.1f%s » %s :ברכב", _health, "%%", _armour, "%%", IsPlayerInAnyVehicle(playerid)? string2 : ("NO"));
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, "   ימים שעברו מאז ההרשמה: %i • שעות משחק: %03i(Mints: %03i) » אחוזי וותק: %.1f%s", DaysBetweenDates(dini_Get(getPlayerFile(id, _fileusers), "Registered_Date"), GetDateAsString('/', 1)), dini_Int(getPlayerFile(id, _filestats), "Hours"), dini_Int(getPlayerFile(id, _filestats), "Mints"), dini_Float(getPlayerFile(id, _filestats), "Seniority"), "%%");
   SendClientMessage(playerid, color, string);
   format(string, sizeof string, "   חישוב של כל הכסף שהחזקת אי פעם ביד: %06i$", dini_Int(getPlayerFile(id, _filebank), "TotalMoney"));
   SendClientMessage(playerid, color, string);
   SendClientMessage(playerid, white, "  --------------------------------------");
   checkNewLevel(playerid);
   return 1;
}
function(showProfile(playerid, id))
{
   new string[3][128], color = id == playerid? pink : grey;
   if(!IsPlayerConnected(id)) return error(playerid, ".שחקן זה לא מחובר");
   format(string[1], 128, playerid == id? ("  -------- You're Profile - %s (ID: %03i | USERID: %05d): --------") : ("  -------- %s (ID: %03i | USERID: %05d) - Profile: --------"), GetName(id), id, dini_Int(getPlayerFile(id, _fileusers), "Userid"));
   SendClientMessage(playerid, white, string[1]);
   format(string[0], 128, _fileprivate "profile_%s.ini", GetName(id));
   format(string[2], 128, "  שם פרטי: %s", dini_Get(string[0], profiles[0]));
   format(string[1], 128, !dini_Isset(string[0], profiles[0])? ("  שם פרטי: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   format(string[2], 128, "  שם משפחה: %s", dini_Get(string[0], profiles[1]));
   format(string[1], 128, !dini_Isset(string[0], profiles[1])? ("  שם משפחה: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   format(string[2], 128, "  %s :דוא\"ל", dini_Get(string[0], profiles[2]));
   format(string[1], 128, !dini_Isset(string[0], profiles[2])? ("  דוא\"ל: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   format(string[2], 128, "  %s :מסנג'ר", dini_Get(string[0], profiles[3]));
   format(string[1], 128, !dini_Isset(string[0], profiles[3])? ("  מסנג'ר: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   format(string[2], 128, "  אייסיקיו: %s", dini_Get(string[0], profiles[4]));
   format(string[1], 128, !dini_Isset(string[0], profiles[4])? ("  אייסיקיו: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   format(string[2], 128, "  עיר: %s", dini_Get(string[0], profiles[5]));
   format(string[1], 128, !dini_Isset(string[0], profiles[5])? ("  עיר: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   format(string[2], 128, "  תאריך לידה: %s גיל: %i", dini_Get(string[0], profiles[6]), dini_Int(string[0], profiles[7]));
   format(string[1], 128, !dini_Isset(string[0], profiles[6])? ("  תאריך לידה: לא נרשם") : string[2]);
   SendClientMessage(playerid, !dini_Isset(string[0], profiles[0])? red : color, string[1]);
   SendClientMessage(playerid, white, "  --------------------------------------");
   return 1;
}
function(OnPlayerStateChange(playerid, newstate, oldstate))
{
	new string[128];
	if(newstate != PLAYER_STATE_DRIVER) GivePlayerMoney(playerid, -PlayerInfo(MoneyStunts[playerid]));
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER && isBike(GetPlayerVehicleID(playerid)))
	{
        switch(GetPlayerSkin(playerid))
		{
            case 0, 65, 74, 149, 208, 273:  SPAO{0.070000, 0.000000, 0.000000, 88.000000, 75.000000, 0.000000}
            case 1..6, 8, 14, 16, 22, 27, 29, 33, 41..49, 82..84, 86, 87, 119, 289: SPAO{0.070000, 0.000000, 0.000000, 88.000000, 77.000000, 0.000000}
            case 7, 10: SPAO{0.090000, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
            case 9: SPAO{0.059999, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
            case 11..13: SPAO{0.070000, 0.019999, 0.000000, 88.000000, 90.000000, 0.000000}
            case 15: SPAO{0.059999, 0.000000, 0.000000, 88.000000, 82.000000, 0.000000}
            case 17..21: SPAO{0.059999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 23..26, 28, 30..32, 34..39, 57, 58, 98, 99, 104..118, 120..131: SPAO{0.079999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 40: SPAO{0.050000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 50, 100..103, 148, 150..189, 222: SPAO{0.070000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 51..54: SPAO{0.100000, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 55, 56, 63, 64, 66..73, 75, 76, 78..81, 133..143, 147, 190..207, 209..219, 221, 247..272, 274..288, 290..293: SPAO{0.070000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 59..62: SPAO{0.079999, 0.029999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 77: SPAO{0.059999, 0.019999, 0.000000, 87.000000, 82.000000, 0.000000}
            case 85, 88, 89: SPAO{0.070000, 0.039999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 90..97: SPAO{0.050000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 132: SPAO{0.000000, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 144..146: SPAO{0.090000, 0.000000, 0.000000, 88.000000, 82.000000, 0.000000}
            case 220: SPAO{0.029999, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 223, 246: SPAO{0.070000, 0.050000, 0.000000, 88.000000, 82.000000, 0.000000}
            case 224..245: SPAO{0.070000, 0.029999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 294: SPAO{0.070000, 0.019999, 0.000000, 91.000000, 84.000000, 0.000000}
            case 295: SPAO{0.050000, 0.019998, 0.000000, 86.000000, 82.000000, 0.000000}
            case 296..298: SPAO{0.064999, 0.009999, 0.000000, 88.000000, 82.000000, 0.000000}
            case 299: SPAO{0.064998, 0.019999, 0.000000, 88.000000, 82.000000, 0.000000}
		}
	}
	else RemovePlayerAttachedObject(playerid, 0);
	if(!strcmp(VehiclesName[GetVehicleModel(GetPlayerVehicleID(playerid))-400], intoVehicle, true) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
       format(string, sizeof string, " Updates: וזכה ב 1000$ %s - נכנס ראשון לרכב ,%s - השחקן",intoVehicle, GetName(playerid));
       SendClientMessageToAll(orange, string);
       _GivePlayerMoney(playerid, 1000);
       intoVehicle = "None";
       ShowPlayerDialog(playerid,101, DIALOG_STYLE_MSGBOX,"!זכית במבחן מהירות","  !זכית ב1000$\nזכית בתחרות מבחן מהירות, אתה הראשון שביצעת את המשימה","אישור","סגור חלון");
    }
	return 1;
}
stock setAFK(playerid, bool:s = true)
{
   new Float:pos[3];
   if(!s)
   {
	   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
       SetTimerEx("AFK", 30*1000, false, "ifff", playerid, pos[0], pos[1], pos[2]);
	   Stimers[playerid][2] = SetTimerEx("_mints", 60*1000, false, "is", playerid, GetName(playerid));
   }
   //else //SendClientMessage(playerid, darkblue, "!Away From Keyboard(AFK) - נכנסת אוטומטית למצב");
   PlayerInfo(isafk[playerid]) = s;
   //TogglePlayerControllable(playerid, s == true? false : true);
   return 1;
}
stock isSimple(text[])
{
  new ctrue = 0, password[32], j = 0;
  for(new i = 0; i < strlen(text); i++) if(IsNumeric(text[i])) password[j++] = text[i];
  for(new i = 0; i < j; i++) if(password[i]+1 == password[i+1] || password[i]-1 == password[i+1] || password[i] == password[i+1]) ctrue++;
  return ctrue >= 3 && ctrue <= 7? 1 : 0;
}
stock countTottalyConnectes(name[], ip[])
{
   new string[128];
   format(string, sizeof string, "/Users/Configs/CTC/%s.ini", GetDateAsString('_', 2));
   if(!dini_Exists(string))
   {
      dini_IntSet(string, "Total", 0);
      dini_Create(string);
   }
   if(!dini_Isset(string, ip) && !dini_Isset(string, name))
   {
      dini_IntSet(string, ip, 1);
      dini_IntSet(string, name, 1);
      dini_IntSet(string, "Total", dini_Int(string, "Total") + 1);
   }
   return 1;
}
function(checkNewLevel(id))
{
   new string[128];
   if(dini_Int(getPlayerFile(id, _filestats), "Kills") >= var_Levels[dini_Int(getPlayerFile(id, _filestats), "Level") - 1])
   {
      dini_IntSet(getPlayerFile(id, _filestats), "Level", dini_Int(getPlayerFile(id, _filestats), "Level") + 1);
      dini_Set(getPlayerFile(id, _filestats), "Tag", var_Tags[dini_Int(getPlayerFile(id, _filestats), "Level")-1]);
      format(string, sizeof string, "%s(%02i) - עלה לרמה %s", dini_Get(getPlayerFile(id, _filestats), "Tag"), dini_Int(getPlayerFile(id, _filestats), "Level"), GetName(id));
      SendClientMessageToAll(orange, string);
   }
}
stock GetSomeNames(...)
{
	new string[256]; // JoeShk
    for(new i = 0; i < numargs(); i++) if(IsPlayerConnected(getarg(i))) format(string, sizeof string, "%s %s\n", GetName(getarg(i)), string);
    return string;
}
stock GetHere(playerid, ...)
{
   new Float:pos[3]; // JoeShk
   GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
   for(new i = 0; i < numargs(); i++) if(IsPlayerConnected(getarg(i))) SetPlayerPos(getarg(i), pos[0], pos[1], pos[2]);
   return 1;
}
stock SetBankLastAction(playerid, action[])
{
  new string[128];
  dini_IntSet(getPlayerFile(playerid, _filebank), "Total", dini_Int(getPlayerFile(playerid, _filebank), "Total") + 1);
  format(string, sizeof string, "%i", dini_Int(getPlayerFile(playerid, _filebank), "Total"));
  dini_Set(getPlayerFile(playerid, _filebank), string, action);
  if(dini_Int(getPlayerFile(playerid, _filebank), "Total") == 10) dini_IntSet(getPlayerFile(playerid, _filebank), "Total", 0);
  return 1;
}
stock SetTextDrawColor(Text:text)
{
   new string[128];
   TextDrawColor(text, sgba2hex(100+random(156), 100+random(156), 100+random(156), 70));
   TextDrawHideForAll(text);
   for(new i = 0; i < MAX_PLAYERS; i++)
   {
      format(string, sizeof string, _fileprivate "setting_%s.ini", GetName(i));
      if(dini_Int(string, settings[5])) TextDrawShowForPlayer(i, text);
   }
   return 1;
}
//function(maintd()) SetTextDrawColor(TDraw[1]);
function(stunts(playerid))
{
   new total[MAX_PLAYERS], x = 0;
   x = IsPlayerInAnyVehicle(playerid);
   if(!x) PlayerInfo(MoneyStunts[playerid]) = 0;
   else if(x && !vehicleCallBug[playerid])
   {
      PlayerInfo(MoneyStunts[playerid]) = GetPlayerMoney(playerid) - AC_Info[playerid][cash];
      if(PlayerInfo(MoneyStunts[playerid]) > 600) GivePlayerMoney(playerid, -PlayerInfo(MoneyStunts[playerid]));
      if(x && PlayerInfo(MoneyStunts[playerid]) >= 1 && PlayerInfo(MoneyStunts[playerid]) <= 600 && PlayerInfo(MoneyStunts[playerid]) != 500)
      {
         total[playerid] = dini_Int(getPlayerFile(playerid, _filestats), "Points") + PlayerInfo(MoneyStunts[playerid]) / 60;
         StuntsPlayer(playerid, total[playerid]);
         StuntsBugs[playerid] = 1;
      }
   }
   if(StuntsBugs[playerid]) PlayerInfo(MoneyStunts[playerid]) = GetPlayerMoney(playerid) - AC_Info[playerid][cash];
   return 1;
}
stock StuntsPlayer(playerid, total)
{
   new string[128];
   TextDrawShowForPlayer(playerid, Stunts[0][playerid]);
   format(string, sizeof string, "%03i", total);
   TextDrawSetString(Stunts[1][playerid], string);
   TextDrawShowForPlayer(playerid, Stunts[1][playerid]);
   dini_IntSet(getPlayerFile(playerid, _filestats), "Points", total);
   GivePlayerMoney(playerid, -PlayerInfo(MoneyStunts[playerid]));
   SetTimerEx("HideStunts", 4000, 0, "i", playerid);
   PlayerInfo(MoneyStunts[playerid]) = 0;
   return 1;
}
function(HideStunts(playerid))
{
   for(new i = 0; i < 2; i++) TextDrawHideForPlayer(playerid, Stunts[i][playerid]);
   StuntsBugs[playerid] = 0;
   return 1;
}
function(returnMoney(playerid, cashc)) _GivePlayerMoney(playerid, cashc);
stock nextLevelPre(playerid)
{
  new Float:h = ( (dini_Int(getPlayerFile(playerid, _filestats), "Kills") - var_Levels[getPlayerLevel(playerid) - 1]) / ( var_Levels[getPlayerLevel(playerid)] - var_Levels[getPlayerLevel(playerid) - 1]))  * 100;
  return floatround( h );
}
stock NumbersBetweenNumbers(num1, num2)
{
   new result = 0;
   for(new x = num1; x <= num2; x++) result++;
   return result;
}
stock vehicleAction(playerid, anOcmd[])
{
   new string[256];
   if(!strcmp(anOcmd, "Info - פרטים על הרכב בו אתה נמצא", true))
   {
      new vehicleid = GetPlayerVehicleID(playerid);
      if(IsPlayerInAnyVehicle(playerid)) error(playerid, ".אתה לא נמצא בשום רכב");
      if(vehicleid < xvehicles)
      {
          format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",vehicleid);
          SendClientMessage(playerid,white,"--- :רכב להשכרה ---");
          format(string,sizeof string,Vunoccupied[vehicleid]? (" •.%s :משכיר הרכב") : (" •.אין משכיר לרכב זה, אתה יכול להשכיר את הרכב"),dini_Get(rent_file,"Owner"));
          SendClientMessage(playerid,0x16EB43FF,string);
          format(string,sizeof string," • %d$ :מחיר רכב זה ליום",PriceRentVehicle[vehicleid]);
          SendClientMessage(playerid,0x16EB43FF,string);
          format(string,sizeof string," • %i :איידי",vehicleid);
          SendClientMessage(playerid,0x16EB43FF,string);
          format(string,sizeof string," • %s :סוג רכב",VehiclesName[GetVehicleModel(vehicleid)-400]);
          SendClientMessage(playerid,0x16EB43FF,string);
          SendClientMessage(playerid,0x16EB43FF,RentInfo[playerid][CarID] == vehicleid? ("/RentHelp :אתה משכיר רכב זה כעת, על מנת לקבל עזרה עם המערכת השכרות") :("/RentCar [Days: 1-10] :על מנת להשכיר את הרכב "));
          return 1;
      }
	  if(VehicleInfo[vehicleid][CarOwned])
	  {
	       if(strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner],true))
 		   {
               format(string, sizeof string,"----- [ %s :פרטים עבור הרכב] -----",VehicleInfo[vehicleid][CarName]);
			   SendClientMessage(playerid,white,string);
			   format(string, sizeof string," • .%s - הרכב אשר אתה נמצא בוא הוא הרכב שלך",VehicleInfo[vehicleid][CarName]);
			   SendClientMessage(playerid,0x00FFFFAA,string);
			   format(string, sizeof string," • .%d :האיידי של הרכב",GetVehicleModel(GetPlayerVehicleID(playerid)));
			   SendClientMessage(playerid,0x00FFFFAA,string);
			   format(string, sizeof string," • .%d :האיידי של הרכב במוד",GetPlayerVehicleID(playerid));
			   SendClientMessage(playerid, yellow,string);
			   format(string, sizeof string," • .%d$ :תשלום אגרת רכב על הרכב",VehicleInfo[vehicleid][MoneyTax]);
			   SendClientMessage(playerid, yellow,string);
			   if(VehicleInfo[vehicleid][PayTax] > 1)
		 	   {
			      format(string, sizeof string, " • .%d :'מספר ימים שנשארו עד לשילום המס",VehicleInfo[vehicleid][PayTax]);
			      SendClientMessage(playerid,orange, string);
               }
		       if(VehicleInfo[vehicleid][SaleV] > 0 && VehicleInfo[vehicleid][PayTax] > 1) SendClientMessage(playerid,orange," • /StopSale :הרכב שלך, עדיין מוצע לקניה, על מנת להפסיק את מכירת הרכב ");
		       else if(VehicleInfo[vehicleid][PayTax] < 1) SendClientMessage(playerid,orange," • /PayTax :הרכב שלך מוצע למכירה בגלל שלא שילמת אגרת רכב על מנת לשלם ");
		   }
		   else if(strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner],true) == 1)
	       {
	          if(VehicleInfo[vehicleid][SaleV] != 0)
		      {
			      format(string, sizeof string,"----- [ %s :פרטים עבור הרכב] -----",VehicleInfo[vehicleid][CarName]);
			      SendClientMessage(playerid,white,string);
			      format(string, sizeof string," • .$%d :שים לב, בעל הרכב הציע על הרכב מחיר של כ",VehicleInfo[vehicleid][SaleV]);
			      SendClientMessage(playerid,0x00FFFFAA,string);
			      format(string, sizeof string," • .%s :הבעלים",VehicleInfo[vehicleid][CarOwner]);
		 		  SendClientMessage(playerid,0x00FFFFAA,string);
	 		      SendClientMessage(playerid,yellow," • /Vehicle(/v) :לקניית הרכב ");
			      format(string, sizeof string," • .%d :האיידי של הרכב",GetVehicleModel(GetPlayerVehicleID(playerid)));
			      SendClientMessage(playerid,yellow, string);
			      format(string, sizeof string," • .%d :האיידי של הרכב במוד",GetPlayerVehicleID(playerid));
			      SendClientMessage(playerid,yellow, string);
			      format(string, sizeof string," • .%d$ :תשלום אגרת רכב על הרכב",VehicleInfo[vehicleid][MoneyTax]);
			      SendClientMessage(playerid,yellow, string);
			      format(string, sizeof string," • .%d :'מספר ימים שנשארו עד לשילום המס",VehicleInfo[vehicleid][PayTax]);
			      SendClientMessage(playerid,yellow, string);
		      }
			  else
			  {
			      format(string, sizeof string," • .ולכן לא ניתן לקנייה %s רכב זה הינו בבעלות [%s] • ",VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
			      SendClientMessage(playerid,0x00FFFFAA,string);
			  }
	       }
	  }
	  else if(!VehicleInfo[vehicleid][Buyable])
      {
         format(string, sizeof string," • !לא ניתן לקניה, רכב זה שייך לזכות הציבור ,%s :רכב זה",VehicleInfo[vehicleid][CarName], VehicleInfo[vehicleid][CarOwner]);
	     SendClientMessage(playerid,0x00FFFFAA,string);
      }
	  else if(VehicleInfo[vehicleid][Buyable])
	  {
         format(string, sizeof string,"----- [ %s :פרטים עבור הרכב] -----",VehicleInfo[vehicleid][CarName]);
         SendClientMessage(playerid, white,string);
         format(string, sizeof string," • .$%d :הרכב פנוי לרכישה, מחיר הרכב",VehicleInfo[vehicleid][Price]);
         SendClientMessage(playerid,0x16EB43FF,string);
         SendClientMessage(playerid,0x16EB43FF," • /Vehicle(/v) :לקניית הרכב ");
         format(string, sizeof string," • .%d :האיידי של הרכב",GetVehicleModel(GetPlayerVehicleID(playerid)));
         SendClientMessage(playerid,0x16EB43FF, string);
         format(string, sizeof string," • .%d :האיידי של הרכב במוד",GetPlayerVehicleID(playerid));
         SendClientMessage(playerid,0x16EB43FF, string);
         format(string, sizeof string," • .%d$ :תשלום אגרת רכב על הרכב",VehicleInfo[vehicleid][MoneyTax]);
         SendClientMessage(playerid,0x16EB43FF, string);
	  }
	  return 1;
   }
   if(!strcmp(anOcmd, "Sell - על מנת למכור את הרכב שלך", true))
   {
	  new file[126];
      new vehicleid = Vehicle_Info[playerid][CarID];
      format(file,sizeof file ,"Vehicle/%i.ini", vehicleid);
      if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין בבעלותך שום רכב");
      if(dini_Exists(file))
      {
	       format(file,sizeof file,"Vehicle/%i.ini",Vehicle_Info[playerid][CarID]);
	       dini_IntSet(file,"CarOwned",0);
	       dini_Set(file,"CarOwner","None");
	       dini_IntSet(file,"Buyable",1);
	       VehicleInfo[vehicleid][CarOwned] = 0;
	       strmid(VehicleInfo[vehicleid][CarOwner], dini_Get(file,"CarOwner"), 0, strlen(dini_Get(file,"CarOwner")), 255);
	       VehicleInfo[vehicleid][Buyable] = 1;
	       Vehicle_Info[playerid][CarID] = 0;
	       Vehicle_Info[playerid][OwnCar] = 0;
	       dini_IntSet(getPlayerFile(playerid, _filestats), "Vehicle_ID", 0);
	   	   SendClientMessage(playerid, orange, "  Updates: !מכרת הרכב שלך, מחיר הרכב הועבר לחשבון בנק שלך");
	       dini_IntSet(getPlayerFile(playerid, _filebank),"Bank",dini_Int(getPlayerFile(playerid, _filebank), "Bank")+VehicleInfo[vehicleid][Price] / 2);
	       dini_Set(getPlayerFile(playerid, _filestats),"Car","None");
      }
	  return 1;
   }
   if(!strcmp(anOcmd, "Tax - תשלום אגרת רכב על הרכב בבעלותך", true))
   {
      new filecar[64];
  	  format(filecar,sizeof filecar,"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
      if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין לך שום רכב בבעלותך");
	  if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] > 5) return error(playerid,".אתה עוד לא צריך לשלם אגרת רכב על הרכב");
	  if(_GetPlayerMoney(playerid) < VehicleInfo[Vehicle_Info[playerid][CarID]][MoneyTax])
	  {
         format(string,sizeof string,"!%i$ :אין לך מספיק כסף כדי לשלם את האגרת רכב, תשלום האגרת רכב הינו",VehicleInfo[Vehicle_Info[playerid][CarID]][MoneyTax]);
		 SendClientMessage(playerid,orange,string);
		 return 1;
      }
	  _GivePlayerMoney(playerid, -1*VehicleInfo[Vehicle_Info[playerid][CarID]][MoneyTax]);
      VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] = 14;
      VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] = 0;
	  dini_IntSet(filecar,"SaleV",0);
	  dini_IntSet(filecar,"PayTax", 15);
	  format(string, sizeof string," • !%d :שילמת אגרת רכב על הרכב בהצלחה, תשלום הבא בעוד מספר ימים של כ • ",VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax]);
	  SendClientMessage(playerid, orange, string);
	  SendClientMessage(playerid, yellow, "!רכבך לא מוצע יותר למכירה, תהנה עם רכבך המחודש");
	  return 1;
   }
   if(!strcmp(anOcmd, "Buy - על מנת לקנות את הרכב שאתה נמצא בו", true))
   {
      new vehicleid = GetPlayerVehicleID(playerid), file[126];
      format(file, sizeof file,"Vehicle/%i.ini", vehicleid);
      if(GetPlayerInterior(playerid) > 0 || GetPlayerVirtualWorld(playerid) > 0) return error(playerid,".לא תוכל לקנות רכב זה");
      if(CarToRent[vehicleid]) return error(playerid,".רכב זה הינו להשכרה ולא למכירה");
      if(dini_Exists(file))
      {
         if(!VehicleInfo[vehicleid][SaleV])
	     {
              if(strcmp(VehicleInfo[vehicleid][CarOwner], "None", true)) return error(playerid,strcmp(VehicleInfo[vehicleid][CarOwner], GetName(playerid), false)? (".המכונית הזאת שייכת למישהו אחר ") : (".המכונית הזאת כבר שייכת לך"));
              if(_GetPlayerMoney(playerid) < VehicleInfo[vehicleid][Price]) return error(playerid,".אין לך מספיק כסף בשביל לקנות את המכונית הזאת ");
              if(!(IsPlayerInAnyVehicle(playerid))) return error(playerid,".אתה צריך להיות במכונית שאתה רוצה לקנות ");
              if(GetPlayerVehicleID(playerid) >= VCount) return error(playerid,".זהו רכב ציבורי, אינו ניתן לקניה");
              if(VehicleInfo[vehicleid][CarOwned]) return error(playerid,".המכונית הזאת שייכת למישהו אחר ");
              if(Vehicle_Info[playerid][CarID] > 0) return error(playerid,".יש לך כבר מכונית");
              if(!VehicleInfo[vehicleid][Buyable])
              {
                  format(string , sizeof string," • !הינו רכב ציבור שלא ניתן למכירה ,%s הרכב • ",VehicleInfo[vehicleid][CarName]);
			      error(playerid,string);
			      return 1;
              }
		      VehicleInfo[vehicleid][PayTax] = 15;
		      dini_IntSet(file,"PayTax", 15);
		      dini_IntSet(file,"CarOwned",1);
		      dini_Set(file,"CarOwner",GetName(playerid));
		      dini_IntSet(file,"Buyable",0);
		      VehicleInfo[vehicleid][CarOwned] = 1;
		      strmid(VehicleInfo[vehicleid][CarOwner], GetName(playerid), 0, strlen(GetName(playerid)), 255);
			  VehicleInfo[vehicleid][Buyable] = 0;
			  Vehicle_Info[playerid][CarID] = GetPlayerVehicleID(playerid);
		      Vehicle_Info[playerid][OwnCar] = 1;
  		      dini_IntSet(getPlayerFile(playerid, _filestats),"Vehicle_ID",Vehicle_Info[playerid][CarID]);
		      format(string,sizeof string," • /Vehicle :מזל טוב, על מנת לקבל עזרה !%s :קנית את הרכב ,%s שלום לך • ",VehiclesName[GetVehicleModel(vehicleid)-400],GetName(playerid));
		      SendClientMessage(playerid, green, string);
		      _GivePlayerMoney(playerid, -1*VehicleInfo[vehicleid][Price]);
		      Update3D(GetPlayerVehicleID(playerid), VehicleInfo[vehicleid][Buyable]);
		      return 1;
         }
         else if(VehicleInfo[vehicleid][SaleV] > 0)
         {
		    new id = GetPlayerID(dini_Get(file, "CarOwner"));
            if(_GetPlayerMoney(playerid) < VehicleInfo[vehicleid][SaleV]) return error(playerid,".אין לך מספיק כסף בשביל לקנות את המכונית הזאת ");
		    if(!(IsPlayerInAnyVehicle(playerid))) return error(playerid,".אתה צריך להיות במכונית שאתה רוצה לקנות ");
		    if(GetPlayerVehicleID(playerid) >= VCount) return error(playerid,".זהו רכב ציבורי, אינו ניתן לקניה");
		    if(Vehicle_Info[playerid][CarID] > 0) return error(playerid,".יש לך כבר מכונית");
		    format(string , sizeof string,"  Updates: !קנה ממך את הרכב, כספך הוכנס לבנק באופן אוטמאטי %s - השחקן",GetName(playerid));
		    if(id != -1)
		    {
		         SendClientMessage(id, orange, string);
      		     Vehicle_Info[id][CarID] = 0;
			     Vehicle_Info[id][OwnCar] = 0;
		    }
		    format(string, sizeof string, "/Users/Bank/%s.ini", dini_Get(file, "CarOwner"));
		    dini_IntSet(string, "Bank", dini_Int(string,"Bank")+VehicleInfo[vehicleid][SaleV]);
		    dini_IntSet(getPlayerFile(playerid, _filestats), "Vehicle_ID", 0);
		    dini_IntSet(file,"PayTax", 15);
		    dini_IntSet(file,"SaleV",0);
		    dini_IntSet(file,"CarOwned",1);
		    dini_IntSet(file,"Buyable", 0);
		    dini_Set(file,"CarOwner",GetName(playerid));
		    VehicleInfo[vehicleid][CarOwned] = 1;
   		    VehicleInfo[vehicleid][SaleV] = 0;
		    VehicleInfo[vehicleid][PayTax] = 15;
		    VehicleInfo[vehicleid][Buyable] = 0;
		    Vehicle_Info[playerid][CarID] = GetPlayerVehicleID(playerid);
		    Vehicle_Info[playerid][OwnCar] = 1;
		    dini_IntSet(getPlayerFile(playerid, _filestats),"Vehicle_ID",Vehicle_Info[playerid][CarID]);
		    format(string , sizeof string," • /Vehicle :מזל טוב, לקבלת עזרה ,%s קנית את הרכב ,%s שלום לך",VehiclesName[GetVehicleModel(vehicleid)-400],GetName(playerid));
		    SendClientMessage(playerid,0x00FFFFAA,string);
		    _GivePlayerMoney(playerid, -1*VehicleInfo[vehicleid][SaleV]);
		    strmid(VehicleInfo[vehicleid][CarOwner], GetName(playerid), 0, strlen(GetName(playerid)), 255);
		    Update3D(GetPlayerVehicleID(playerid), VehicleInfo[vehicleid][Buyable]);
		    return 1;
         }
      }
	  return 1;
   }
   if(!strcmp(anOcmd,"Start Sale - על מנת להציע את הרכב שלך לציבור בתמורה לסכום שתבחר",true))
   {
      if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין בבעלותך שום רכב");
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/Vehicle(/v) | Tax :אתה לא יכול לעצור את מכירת הרכב, לא שילמת אגרת רכב על הרכב, על מנת לשלם");
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] > 0) return error(playerid, ".\"Stop Sale\" - ולאחר מכן תבחר בשורה /Vehicle(/v) - על מנת לעצור את מכירת הרכב");
      ShowPlayerDialog(playerid, 25, DIALOG_STYLE_INPUT, string, " • !אנא הזן את הסכום שבו תרצה למכור את הרכב שלך לציבור, המחיר אמור להיות בין 1$-50,000$", "בצע", "ביטול");
      return 1;
   }
   if(!strcmp(anOcmd,"Stop Sale - על מנת לעצור את מכירת הרכב שלך לציבור",true))
   {
      format(string, sizeof string,"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
      if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין בבעלותך שום רכב");
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/Vehicle(v) Tax :לפני שתשתמש בפקודה זאת תצטרך לשלם קודם אגרת רכב");
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] < 1) return error(playerid,".הרכב שלך אינו מוצע לרכישה");
      dini_IntSet(string,"SaleV",0);
      VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] = 0;
      SendClientMessage(playerid,orange,".הפסקת את מכירת הרכב שלך");
      Update3D(GetPlayerVehicleID(playerid), VehicleInfo[Vehicle_Info[playerid][CarID]][Buyable]);
      return 1;
   }
   if(!strcmp(anOcmd,"Call - על מנת לזמן את הרכב למקום בו אתה נמצא", true))
   {
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][CarOwned] != 1 && Vehicle_Info[playerid][OwnCar] != 1) return error(playerid,".אין בבעלותך שום רכב");
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/Vehicle(v) Tax :לפני שתשתמש בפקודה זאת תצטרך לשלם קודם אגרת רכב");
      if(GetPlayerInterior(playerid) != 0) return error(playerid,".אתה לא יכול לזמן את הרכב שלך לתוך מקום סגור");
      vehicleCallBug[playerid] = 1;
      for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerInVehicle(i, Vehicle_Info[playerid][CarID]))
      {
         RemovePlayerFromVehicle(i);
         format(string , sizeof string,"  Updates: !זימן את הרכב שלו, הליכה נעימה ,%s", GetName(playerid));
         SendClientMessage(i, orange,string);
      }
      GetPlayerPos(playerid, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]);
      _PutPlayerInVehicle(playerid, Vehicle_Info[playerid][CarID], 0);
      GetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[playerid][3]);
      SetTimerEx("TeleCar",1000,0,"i", playerid);
      SendClientMessage(playerid,yellow,".שיגרת את הרכב שלך בהצלחה");
      SendClientMessage(playerid,orange,"/Vehicle(/v) Reset :זימנת את הרכב שלך בהצלחה, במידה והוא לא הגיע");
      return 1;
   }

   if(!strcmp(anOcmd, "Reset - על מנת לאפס את הרכב שלך במידה והוא לא מגיע אליך", true))
   {
      new vehicleid = GetPlayerVehicleID(playerid);
      if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין בבעלותך שום רכב");
      if((IsPlayerInAnyVehicle(playerid))) return error(playerid,".אנא צא מהרכב על מנת לאפס אותו");
      if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/Vehicle(v) Tax :לפני שתשתמש בפקודה זאת תצטרך לשלם קודם אגרת רכב");
      if(strcmp(GetName(playerid), VehicleInfo[vehicleid][CarOwner], true) != 0)return error(playerid,".זו לא המכונית שלך אז אינך יכול לתקן אותה");
      vehicleCallBug[playerid] = 1;
      SetVehicleToRespawn(Vehicle_Info[playerid][CarID]);
      SetVehicleHealth(Vehicle_Info[playerid][CarID],1000.0);
      SendClientMessage(playerid,yellow,"...עוד 5 שניות הרכב שלך יאופס, אנא המתן/י");
      SetTimerEx("RepairCar",5000, false,"i",playerid);
      GetVehiclePos(Vehicle_Info[playerid][CarID],vPos[playerid][0],vPos[playerid][1],vPos[playerid][2]);
      SetPlayerPos(playerid, 346.8638, 309.1008, 999.1557);
      SetPlayerFacingAngle(playerid, 180);
      SetPlayerInterior(playerid,6);
      TogglePlayerControllable(playerid,0);
      return 1;
   }
   return 0;
}
function(makedownGlass())
{
   if(Glass_On == 2)
   {
       rand_glass = random(20)+1;
	   if(is_fall_glass[rand_glass]) return makedownGlass();
	   else if(!is_fall_glass[rand_glass])
	   {
           is_fall_glass[rand_glass] = 1;
		   SetTimer("glass_set", 450, false);
		   GetObjectRot(glass_object[rand_glass],object_positon[0],object_positon[1],object_positon[2]);
		   for(new f = 0; f < 3; f++) save_rot[f] = object_positon[f];
		   GetObjectRot(glass_object[rand_glass],object_positon[0],object_positon[1],object_positon[2]);
		   SetObjectRot(glass_object[rand_glass],object_positon[0]-6.3,object_positon[1]-6.3,object_positon[2]);
	   }
   }
   return 1;
}
function(glass_set())
{
   if(Glass_On == 2)
   {
      SetTimer("glass_back",350,0);
	  GetObjectRot(glass_object[rand_glass],object_positon[0],object_positon[1],object_positon[2]);
	  SetObjectRot(glass_object[rand_glass],object_positon[0]-6.3,object_positon[1]-6.3,object_positon[2]);
   }
   return 1;
}
function(glass_back())
{
   if(Glass_On == 2)
   {
      SetTimer("glass_b",350,0);
      GetObjectRot(glass_object[rand_glass],object_positon[0],object_positon[1],object_positon[2]);
      SetObjectRot(glass_object[rand_glass],object_positon[0]-6.3,object_positon[1]-6.3,object_positon[2]);
   }
   return 1;
}
function(glass_b())
{
   if(Glass_On == 2)
   {
      SetTimer("move_glass",350,0);
      GetObjectRot(glass_object[rand_glass],object_positon[0],object_positon[1],object_positon[2]);
      SetObjectRot(glass_object[rand_glass],save_rot[0],save_rot[1],save_rot[2]);
   }
   print("glass bug functin \"glass_b\"");
   return 1;
}
function(move_glass())
{
   new Float:postion_b[3];
   if(Glass_On == 2)
   {
       GetObjectPos(glass_object[rand_glass],postion_b[0],postion_b[1],postion_b[2]);
	   MoveObject(glass_object[rand_glass],postion_b[0],postion_b[1],postion_b[2]-100.0,8.0);
	   SetObjectRot(glass_object[rand_glass],object_positon[0]-15.1,object_positon[1]-15.0,object_positon[2]);
	   SetTimer("makedownGlass",8*1000,0);
   }
   print("glass bug functin \"move glass\"");
   return 1;
}
function(startglass())
{
   GlassPlayers = 0, GlassTotal = 0, count_glass = 40, Glass_On = 1;
   countGlass();
   ActMessage(
   "Glass",
   " » /glass join",
   " • ,משחק הזכוכיות, המטרה שלכם היא לשרוד על משטח זכוכיות ולהישאר אחרונים",
   " • ,בכל כמה שניות זכוכית אחת תיפול מהמשטח, לפני שהזכוכית תשבר הזכוכית תזוז כמה פעמים",
   " • .שיהיה לכם משחק מהנה ובהצלחה");
   return 1;
}
function(countGlass())
{
   new string[256], rand = 0;
   count_glass --;
   if(count_glass > 0) SetTimer("countGlass",1000,0);
   format(string,sizeof string, count_glass > 5? ("~b~~h~~n~~n~%02i") : ("~r~~h~~n~~n~%i"), count_glass);
   GameTextForAll(string, 1000, 5);
   if(!GlassPlayers && count_glass < 7)
   {
       ActMessage("Glass", "none" ," • הפעילות בוטלה בגלל חוסר משתתפים", "none", "none");
       actOver("Glass");
	   return 0;
   }
   if(count_glass < 6)
   {
       for(new i = 0; i < MAX_PLAYERS; i++)
       {
           if(PlayerInfo(InGlass[i]) == 1)
	       {
              SetPlayerVirtualWorld(i, 1);
              PlayerInfo(InGlass[i]) = 2;
              PlayerInfo(inAct[i]) = 1;
              Glass_On = 2;
              ResetPlayerWeapons(i);
			  rand = random(sizeof glass_postion);
		      SetPlayerPos(i, glass_postion[rand][0], glass_postion[rand][1], glass_postion[rand][2]);
		      _SetPlayerHealth(i, 100.0);
			  _SetPlayerArmour(i, 100.0);
			  TogglePlayerControllable(i, 0);
			  GlassTotal = GlassPlayers;
	       }
       }
   }
   if(count_glass < 1)
   {
		 format(string, sizeof string, " • המשחק התחיל בהצלחה, המנצח יזכה ב %i מספר משתתפים: %i", GlassTotal*150, GlassPlayers);
		 ActMessage("Glass", "none" , string, " • !בהצלחה לכולם במשחק", "none");
         SetTimer("makedownGlass", 1000, false);
		 actgTimer = SetTimer("glassState", 1000, true);
		 for(new i = 0; i < MAX_PLAYERS; i++) if(PlayerInfo(InGlass[i]) == 2) TogglePlayerControllable(i, 1);
   }
   return 1;
}
function(glassState())
{
   new Float:postion_c_player[MAX_PLAYERS][3], string[256];
   if(!GlassPlayers && Glass_On > 0)
   {
      GlassPlayers = 0;
      rand_glass = -1;
      Glass_On = 0;
      count_glass = 0;
      KillTimer(actgTimer);
      SendClientMessageToAll(red, ".הסתיימה ללא מנצחים Glass הפעילות");
      for(new i = 0; i < sizeof glass_object; i++) DestroyObject(glass_object[i]);
	  return 0;
   }
   if(GlassPlayers < 2 && count_glass < 1)
   {
      for(new i = 0; i < MAX_PLAYERS; i++)
	  {
	      if(PlayerInfo(InGlass[i]) == 2)
		  {
			  format(string, sizeof string, "%i$ - והוא זכה ב %s - המנצח בפעילות הוא", GlassTotal*150, GetName(i));
		      ActMessage("Glass", "none" , string, "!בקרוב יהיה עוד משחקים, מקווים שנהנתם", "none");
		      PlayerInfo(InGlass[i]) = 0;
		      PlayerInfo(inAct[i]) = 0;
		      _GivePlayerMoney(i, GlassTotal*150);
		      actOver("Glass");
		  }
	  }
	  if(!GlassPlayers) for(new i = 0; i < 21; i++) DestroyObject(glass_object[i]);
	  return 0;
   }
   for(new i = 0; i < MAX_PLAYERS; i++)
   {
       if(PlayerInfo(InGlass[i]) > 0 && Glass_On > 0 && GlassPlayers > 0 && count_glass < 1)
	   {
           GetPlayerPos(i,postion_c_player[i][0], postion_c_player[i][1], postion_c_player[i][2]);
           if(postion_c_player[i][2] < 50.730 || PlayerInfo(isafk[i])) actFail(i);
	   }
   }
   return 1;
}
stock actFail(playerid)
{
    if(PlayerInfo(InGlass[playerid]) != 0 || PlayerInfo(inAct[playerid]))
	{
        PlayerInfo(InGlass[playerid]) = 0;
        PlayerInfo(inAct[playerid]) = 0;
	    GlassPlayers --;
	    error(playerid, Glass_On != 0? (".נפסלת במשחק") : (".פרשת / נפסלת / נגמר המשחק"));
	    SetPlayerVirtualWorld(playerid, 0);
    }
    return 1;
}
stock actOver(actid[], reason[] = "none")
{
	if(!strcmp(actid, "Glass", true))
	{
       GlassPlayers = 0,
	   rand_glass = -1,
	   Glass_On = 0,
	   count_glass = 0;
	   KillTimer(actgTimer);
	   for(new i = 0; i < MAX_PLAYERS; i++) actFail(i);
	   if(strcmp(reason, "none", true)) SendClientMessageToAll(red, reason);
	}
	return 1;
}
function(ShowMainTextDraw(playerid))
{
   new string[256];
   format(string, sizeof string, "~w~SA-MP.co.il - LucifeR DeathMatch~n~Record Players Server: %03i~n~You left %i Teleports", dini_Int(_fileconfig "Main.ini", "MaxOnlinePlayers"), dini_Int(getPlayerFile(playerid, _filestats), "MaxTeleports"));
   TextDrawSetString(TDrawPlayers[playerid], string);
   TextDrawHideForPlayer(playerid, TDrawPlayers[playerid]);
   TextDrawShowForPlayer(playerid, TDrawPlayers[playerid]);
   return 1;
}
function(getInVehicle())
{
	new string[128], VehiclesName2[][] =
	{
      "Landstalker",
      "Buffalo",
      "Infernus",
      "Taxi" ,
      "Banshee",
      "Hotknife",
      "Coach",
      "Seasparrow",
      "Pizzaboy",
      "Turismo",
      "Speeder",
      "Sanchez",
      "Quadbike",
      "Baggage",
      "Maverick",
      "Sandking",
      "Super GT",
      "Shamal",
      "Hydra",
      "NRG-500",
      "Vortex",
      "Bullet",
      "Monster Truck",
      "Sultan",
      "Elegy",
      "Flash",
      "Savanna",
      "Kart",
      "BF-400",
      "Euros",
      "Club",
      "Trailer",
      "Phoenix"
	}, x = random(sizeof VehiclesName2);

	format(string, sizeof string, "%s :הראשון שייכנס לתוך הרכב", VehiclesName2[x]);
	format(string, sizeof string, "%s", VehiclesName2[x]);
	intoVehicle = string;
    ActMessage(
    "Fast Test",
    "none",
    ",שלום לכם שחקני השרת, כרגע התחילה פעילות אשר תבחון את המהירות שלכם",
    string,
    " !ינצח ויזכה ב 1000$, יאללה בהצלחה");
    return 1;
}
function(UnGodPlayer(playerid))
{
	if(IsPlayerConnected(playerid) && PlayerInfo(god[playerid]))
	{
       PlayerInfo(god[playerid]) = 0;
	   _SetPlayerHealth(playerid, 100);
	}
}
function(DestroyBomb(object))
{
	new Float: pos[3];
	GetObjectPos(object, pos[0], pos[1], pos[2]);
	CreateExplosion(pos[0], pos[1], pos[2], 7, 20);
	DestroyObject(object);
	return 1;
}
function(AddRentVehicle(modelid,Float:Vx,Float:Vy,Float:Vz,Float:Va,color1,color2))
{
    for(new i = 0; i < MAX_VEHICLES; i++) CarToRent[i] = 0;
    AddStaticVehicle(modelid,Float:Vx,Float:Vy,Float:Vz,Float:Va,color1,color2);
    xvehicles++;
    count_v++;
    format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",xvehicles);
	if(!dini_Exists(rent_file))
	{
	    dini_Create(rent_file);
	    dini_Set(rent_file,"Owner","None");
        dini_Set(rent_file,"VehicleName",VehiclesName[GetVehicleModel(xvehicles)-400]);
		dini_IntSet(rent_file,"Days",0);
		Vunoccupied[xvehicles] = 0;
        CarToRent[xvehicles] = 1;
        VLocked[xvehicles] = 0;
        SetPrice(xvehicles);
		strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(xvehicles)-400], 0, strlen(VehiclesName[GetVehicleModel(xvehicles)-400]), 255);
    }
	else
	{
		new string[128],date[3];
		getdate(date[2],date[1],date[0]);
		format(string,sizeof string,"%d.%d.%d",date[0],date[1],date[2]);
		if(DaysBetweenDates(dini_Get(rent_file,"DateOfBuy"),string) < dini_Int(rent_file,"Days") && strcmp(dini_Get(rent_file,"Owner"),"None",true))
		{
             Vunoccupied[xvehicles] = 1;
             CarToRent[xvehicles] = 1;
             VLocked[xvehicles] = 0;
             SetPrice(xvehicles);
			 strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(xvehicles)-400], 0, strlen(VehiclesName[GetVehicleModel(xvehicles)-400]), 255);
	    }
	    else
		{
             Vunoccupied[xvehicles] = 0;
			 CarToRent[xvehicles] = 1;
             VLocked[xvehicles] = 0;
             dini_Set(rent_file,"Owner","None");
             dini_Set(rent_file,"VehicleName",VehiclesName[GetVehicleModel(xvehicles)-400]);
	         dini_IntSet(rent_file,"Days",0);
	         SetPrice(xvehicles);
			 strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(xvehicles)-400], 0, strlen(VehiclesName[GetVehicleModel(xvehicles)-400]), 255);
		}
	}
	return 1;
}
function(AddRentVehicleEx(modelid,Float:Vx,Float:Vy,Float:Vz,Float:Va,color1,color2,price))
{
    AddStaticVehicle(modelid,Float:Vx,Float:Vy,Float:Vz,Float:Va,color1,color2);
	xvehicles++;
	count_v++;
	format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",xvehicles);
	if(!dini_Exists(rent_file))
	{
	    dini_Create(rent_file);
	    dini_Set(rent_file,"Owner","None");
        dini_Set(rent_file,"VehicleName",VehiclesName[GetVehicleModel(xvehicles)-400]);
		dini_IntSet(rent_file,"Days",0);
		Vunoccupied[xvehicles] = 0;
        CarToRent[xvehicles] = 1;
        VLocked[xvehicles] = 0;
        PriceRentVehicle[xvehicles] = (price);
		strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(xvehicles)-400], 0, strlen(VehiclesName[GetVehicleModel(xvehicles)-400]), 255);
    }
	else
	{
		new string[128], date[3];
		getdate(date[2],date[1],date[0]);
		format(string,sizeof string,"%d.%d.%d",date[0],date[1],date[2]);
		if(DaysBetweenDates(dini_Get(rent_file,"DateOfBuy"),string) < dini_Int(rent_file,"Days") && strcmp(dini_Get(rent_file,"Owner"),"None",true))
		{
             Vunoccupied[xvehicles] = 1;
             CarToRent[xvehicles] = 1;
             VLocked[xvehicles] = 0;
             PriceRentVehicle[xvehicles] = (price);
			 strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(xvehicles)-400], 0, strlen(VehiclesName[GetVehicleModel(xvehicles)-400]), 255);
	    }
	    else
		{
             Vunoccupied[xvehicles] = 0;
			 CarToRent[xvehicles] = 1;
             VLocked[xvehicles] = 0;
             PriceRentVehicle[xvehicles] = (price);
             dini_Set(rent_file,"Owner","None");
             dini_Set(rent_file,"VehicleName",VehiclesName[GetVehicleModel(xvehicles)-400]);
	         dini_IntSet(rent_file,"Days",0);
			 strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(xvehicles)-400], 0, strlen(VehiclesName[GetVehicleModel(xvehicles)-400]), 255);
		}
	}
	return 1;
}
function(updateRent())
{
        new string[128], date[3];
        if(!getRentVehicleCount()) return 0;
		for(new i = 0; i < xvehicles+1; i++)
		{
           format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",i);
           getdate(date[2],date[1],date[0]);
           format(string,sizeof string,"%d.%d.%d",date[0],date[1],date[2]);
           if(dini_Exists(rent_file))
           {
               if(DaysBetweenDates(dini_Get(rent_file,"DateOfBuy"),string) < dini_Int(rent_file,"Days") && strcmp(dini_Get(rent_file,"Owner"),"None",true))
               {
                   Vunoccupied[i] = 1;
                   CarToRent[i] = 1;
                   VLocked[i] = 0;
                   strmid(VehicleName[i], VehiclesName[GetVehicleModel(i)-400], 0, strlen(VehiclesName[GetVehicleModel(i)-400]), 255);
               }
               else
               {
                   Vunoccupied[i] = 0;
                   CarToRent[i] = 1;
                   VLocked[i] = 0;
                   dini_Set(rent_file,"Owner","None");
                   dini_Set(rent_file,"VehicleName",VehiclesName[GetVehicleModel(i)-400]);
                   dini_IntSet(rent_file,"Days",0);
                   for(new o = o; o < MAX_PLAYERS; o++) if(i == RentInfo[o][CarID]) RentInfo[o][CarID] = 0;
                   strmid(VehicleName[xvehicles], VehiclesName[GetVehicleModel(i)-400], 0, strlen(VehiclesName[GetVehicleModel(i)-400]), 255);
               }
           }
		}
		return 1;
}
function(giveVehicleToPlayer(playerid))
{
    for(new i = 0; i < MAX_VEHICLES; i++)
    {
           format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",i);
           if(dini_Exists(rent_file))
           {
                 if(!strcmp(dini_Get(rent_file,"Owner"), GetName(playerid), true))
				 {
				       RentInfo[playerid][CarID] = i;
				       return 1;
				 }
		         else RentInfo[playerid][CarID] = 0;
		   }
    }
    return 1;
}
function(getRentVehicleCount())
{
	new count_rent_vehicles = 0;
	for(new i = 0; i < xvehicles+1; i++)
    {
       format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",i);
       if(strcmp(dini_Get(rent_file,"Owner"),"None",true)) count_rent_vehicles++;
	}
    return count_rent_vehicles;
}
stock AddRentVehicles()
{
  for(new i = 0; i < MAX_VEHICLES; i++) CarToRent[i] = 0;
  //carpark:
  AddRentVehicleEx(451,-1886.9193,-915.6405,31.7336,269.6473,3,3,1000); //
  AddRentVehicleEx(451,-1887.5793,-918.7184,31.7182,270.5284,16,16,1000); //
  AddRentVehicleEx(429,-1887.5288,-921.7253,31.7260,270.5622,126,126,1000); //
  AddRentVehicleEx(429,-1887.1370,-924.7302,31.7125,271.7532,1,1,1000); //
  AddRentVehicleEx(411,-1871.3257,-927.5740,31.7561,91.1199,65,65,1000); //
  AddRentVehicleEx(411,-1871.6158,-924.5886,31.7496,89.6616,79,79,1000); //
  AddRentVehicleEx(560,-1871.6027,-918.6078,31.7620,90.4087,0,0,500); //
  AddRentVehicleEx(560,-1871.6359,-915.3293,31.7289,89.7633,21,1,500); //
  AddRentVehicleEx(434,-1886.5096,-900.1259,31.9937,270.6687,2,2,500); //
  AddRentVehicleEx(434,-1886.6691,-896.8749,31.9950,268.7938,6,6,1000); //
  AddRentVehicleEx(572,-1896.1217,-915.7473,31.6049,89.1181,0,0,1000); //
  //carpark part 2:
  AddRentVehicleEx(451,-1872.1511,-874.4136,31.7304,269.7858,42,43,1000); // CarPark
  AddRentVehicleEx(451,-1871.8708,-890.3043,31.7303,269.7699,42,43,1000); // CarPark
  AddRentVehicleEx(451,-1871.8640,-900.0626,31.7303,267.4573,42,43,1000); // CarPark
  AddRentVehicleEx(522,-1886.8197,-890.7115,31.5933,89.5895,1,7,1000); // nrg-500 carpark
  AddRentVehicleEx(560,-1872.0295,-893.6117,31.7441,270.1748,37,0,1000); // /carparkcar
  AddRentVehicleEx(560,-1871.9204,-897.0663,31.7441,270.0742,33,0,1000); // /carparkcar
  AddRentVehicleEx(541,-1871.6267,-903.6390,31.6475,270.5792,60,1,1000); // /carparkcar
  AddRentVehicleEx(541,-1871.6360,-906.3990,31.6702,267.7623,68,8,1000); // /carparkcar
  AddRentVehicleEx(541,-1871.7286,-909.4115,31.6491,267.0488,2,1,1000); // /carparkcar
  //pepe:
  AddRentVehicleEx(473,-784.8475,-1917.1378,5.0187,229.4037,0,0,1000); //
  AddRentVehicleEx(473,-790.4391,-1924.1825,5.0350,232.0554,0,0,1000); //
  AddRentVehicleEx(473,-796.1826,-1931.8448,4.9794,227.5910,0,0,1000); //
  AddRentVehicleEx(473,-800.9719,-1936.9689,5.0322,225.5806,0,0,1000); //
  //Texi Los Santos Rent
  AddRentVehicleEx(420,2180.5249,-1722.6877,13.2367,181.5726,6,1,100); // Taxi - Los Santos
  AddRentVehicleEx(420,1778.1605,-1930.9053,13.1662,91.1757,6,1,100); // Taxi - Los Santos
  AddRentVehicleEx(420,1777.7006,-1911.2131,13.1663,91.1953,6,1,100); // Taxi - Los Santos
  AddRentVehicleEx(420,1802.2761,-1910.6981,13.1847,85.6801,6,1,100); // Taxi - Los Santos
  //Jeeps:
  AddRentVehicleEx(424,-2786.6104,-1531.7727,139.1942,253.7830,1,7,1000); // Jeeps
  AddRentVehicleEx(495,-2817.4170,-1536.1003,139.6432,266.0279,123,124,1000); // SandKing Jeeps
  AddRentVehicleEx(495,-2817.6851,-1540.2775,139.8806,266.1296,1,7,1000); // SandKing Jeeps
  AddRentVehicleEx(495,-2817.9590,-1544.3345,140.1799,266.1297,7,1,1000); // SandKing Jeeps
  AddRentVehicleEx(468,-2813.8940,-1506.6749,138.9429,87.4423,7,1,1000); // Sancheaz
  AddRentVehicleEx(468,-2813.7778,-1504.0646,138.9431,87.4411,8,23,1000); // Sancheaz
  AddRentVehicleEx(468,-2813.6589,-1501.4077,138.9434,87.4380,120,10,1000); // Sancheaz
  AddRentVehicleEx(424,-2793.9336,-1489.0233,138.1751,356.3302,90,10,1000); // Jeeps BF
  AddRentVehicleEx(424, -2785.1172, -1526.5591, 139.022, 253.8945, 1, 0,1000);
  AddRentVehicleEx(424,-2783.8660,-1521.8671,138.8829,252.5952,7,3,1000); // Jeeps
  AddRentVehicleEx(424,-2777.4451,-1523.8595,138.9228,252.8412,9,1,1000); // Jeeps
  AddRentVehicleEx(424,-2780.3809,-1533.3472,139.3487,252.8163,9,1,1000); // Jeeps
  AddRentVehicleEx(471,-2777.3882,-1527.3337,138.8049,184.7602,1,7,1000); // Quadbike Jeeps
  //Cycletrip:
  AddRentVehicleEx(495,-2374.9590,-2175.8115,33.7377,270.6107,1,7,1000); // SandKing Cycletrip part 2
  AddRentVehicleEx(495,-2374.9016,-2181.2134,33.7408,270.6107,1,7,1000); // SandKing Cycletrip part 2
  AddRentVehicleEx(495,-2374.8323,-2187.7549,33.7444,270.6106,1,7,1000); // SandKing Cycletrip part 2
  AddRentVehicleEx(495,-2380.7932,-2187.6658,33.6437,270.6710,0,1,1000); // SandKing At Cycletrip
  AddRentVehicleEx(495,-2380.8665,-2181.3918,33.6437,270.6710,0,1,1000); // SandKing At Cycletrip
  AddRentVehicleEx(495,-2380.9421,-2175.8765,33.6435,270.6706,0,1,1000); // SandKing At Cycletrip
  AddRentVehicleEx(495,-2411.9634,-2171.5530,33.6412,84.7818,0,1,1000); // SandKing At
  //Ships:
  AddRentVehicleEx(452,-2300.4463,2233.9014,-0.3443,179.0141,1,3, 1000); // 1
  AddRentVehicleEx(452,-2302.3267,2264.6624,-0.3018,177.5802,1,3, 1000); // 1
  AddRentVehicleEx(452,-2309.3953,2284.6091,-0.4052,210.7424,1,3, 1000); // 1
  AddRentVehicleEx(452,-2312.9431,2296.6006,-0.4695,174.7319,1,3, 1000); // 1
  AddRentVehicleEx(452,-2312.2556,2313.9436,-0.5963,179.7898,1,3, 500); // 1
  AddRentVehicleEx(452,-2420.4402,2306.1614,-0.5147,255.6763,1,3, 500); // 1
  AddRentVehicleEx(452,-2421.6287,2301.2463,-0.4307,255.6492,1,3, 500); // 1
  AddRentVehicleEx(452,-2422.7837,2294.8616,-0.4183,255.6492,1,3, 500); // 1
  AddRentVehicleEx(452,-2422.3237,2290.1580,-0.3658,255.6492,1,3, 500); // 1
  AddRentVehicleEx(452,-2422.2463,2283.8640,-0.3133,255.6492,1,3, 500); // 1
}
stock SetPrice(vid)
{
   PriceRentVehicle[vid] = 200;
   return 1;
}
function(Tax())
{
    new dbs[128], dbs2[128], datep[3], string[256], file[64];
    getdate(datep[2],datep[1],datep[0]);
	format(dbs2,sizeof dbs2,"%d.%d.%d",datep[0],datep[1],datep[2]);
    if(DaysBetweenDates(dbs,dbs2) > 0)
    {
	    for (new car = 1; car < VCount; car++)
	    {
		    format(file,sizeof file,"Vehicle/%i.ini",car);
		    if(dini_Exists(file))
			{
		        if(dini_Int(file,"CarOwned"))
				{
			        if(VehicleInfo[car][PayTax] != -1)
					{
		                VehicleInfo[car][PayTax]--;
		                dini_IntSet(file,"PayTax",VehicleInfo[car][PayTax]);
						getdate(datep[2],datep[1],datep[0]);
						format(dbs,sizeof dbs,"%d.%d.%d",datep[0],datep[1],datep[2]);

					}
					else if(VehicleInfo[car][PayTax] < 0)
					{
                        dini_IntSet(file,"SaleV", 10000);
                        VehicleInfo[car][SaleV] = dini_Int(file,"SaleV");
                        getdate(datep[2],datep[1],datep[0]);
					    format(dbs,sizeof dbs,"%d.%d.%d",datep[0],datep[1],datep[2]);
					}
				}
			}
    	}
	}
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
        new idcar = Vehicle_Info[i][CarID];
        if(VehicleInfo[idcar][PayTax] < 1 && idcar != 0)
        {
           format(string, sizeof string,"  Updats: !%d$ :שים לב, אתה חייב לשלם אגרת רכב על הרכב שלך, עליך לשלם",VehicleInfo[idcar][MoneyTax]);
           SendClientMessage(i, orange,string);
           SendClientMessage(i, yellow,"/PayTax - אם לא תשלם על האגרת רכב הרכב שלך ימכר ללא הודעה מוקדמת, על מנת לשלם");
        }
	}
	return 1;
}
function(LoadFiles())
{
	new VPrice[MAX_VEHICLES], file[64];
	VCount = CreateVehicle(411,0,0,0,0,0,0,-1);
	DestroyVehicle(VCount);
	printf("Total Vehicles : %i",VCount-1);
	for (new car = 1; car < VCount; car++)
	{
		format(file,sizeof file,"Vehicle/%i.ini",car);
		if(!dini_Exists(file))
		{
			  dini_Create(file); CreateCount++;
			  dini_IntSet(file,"CarID",car);
			  dini_Set(file,"CarName",VehiclesName[GetVehicleModel(car)-400] );
			  dini_IntSet(file,"CarModel",GetVehicleModel(car));
		      dini_IntSet(file,"CarOwned",0);
		      dini_Set(file,"CarOwner","None");
		      dini_IntSet(file,"Buyable",1);
		      dini_IntSet(file,"Price", 10000);
		      dini_IntSet(file,"LevelCar",0);
		      dini_IntSet(file,"SaleV",0);
		      dini_IntSet(file,"PayTax", 15);
		      dini_IntSet(file,"MoneyTax",0);
		      VehicleInfo[car][PayTax] = dini_Int(file,"PayTax");
			  VehicleInfo[car][LevelCar] = dini_Int(file,"LevelCar");
			  VehicleInfo[car][SaleV] = dini_Int(file,"SaleV");
			  VehicleInfo[car][CarID] = dini_Int(file,"CarID");
			  strmid(VehicleInfo[car][CarName], dini_Get(file,"CarName"), 0, strlen(dini_Get(file,"CarName")), 255);
			  VehicleInfo[car][CarModel] = dini_Int(file,"CarModel");
			  VehicleInfo[car][CarOwned] = dini_Int(file,"CarOwned");
			  strmid(VehicleInfo[car][CarOwner], dini_Get(file,"CarOwner"), 0, strlen(dini_Get(file,"CarOwner")), 255);
			  VehicleInfo[car][Buyable] = dini_Int(file,"Buyable");
			  VehicleInfo[car][MoneyTax] = dini_Int(file,"MoneyTax");
			  VehicleInfo[car][MoneyTax] = 550;
			  dini_IntSet(file,"MoneyTax",VehicleInfo[car][MoneyTax]);
			  VPrice[car] = 100000;
              for(new v = 0; v < sizeof(boat); v++) if(VehicleInfo[car][CarModel] == boat[v][0]) VPrice[car] = 4000;
              for(new v = 0; v < sizeof(bike); v++) if(VehicleInfo[car][CarModel] == bike[v][0]) VPrice[car] = 8000;
              for(new v = 0; v < sizeof(plane); v++) if(VehicleInfo[car][CarModel] == plane[v][0]) VPrice[car] = 10000;
              for(new v = 0; v < sizeof(expensive); v++) if(VehicleInfo[car][CarModel] == expensive[v][0]) VPrice[car] = 10000;
              for(new v = 0; v < sizeof(Vexpensive); v++) if(VehicleInfo[car][CarModel] == Vexpensive[v][0]) VPrice[car] = 12000;
			  VehicleInfo[car][Price] = VPrice[car];
			  dini_IntSet(file,"Price",VehicleInfo[car][Price]);
			  Update3D(car, VehicleInfo[car][Buyable]);
		}
		else if(dini_Exists(file))
		{
			  VehicleInfo[car][MoneyTax] = dini_Int(file,"MoneyTax");
			  VehicleInfo[car][PayTax] = dini_Int(file,"PayTax");
			  VehicleInfo[car][SaleV] = dini_Int(file,"SaleV");
			  VehicleInfo[car][LevelCar] = dini_Int(file,"LevelCar");
			  VehicleInfo[car][CarID] = dini_Int(file,"CarID");
			  strmid(VehicleInfo[car][CarName], dini_Get(file,"CarName"), 0, strlen(dini_Get(file,"CarName")), 255);
			  VehicleInfo[car][CarModel] = dini_Int(file,"CarModel");
			  VehicleInfo[car][CarOwned] = dini_Int(file,"CarOwned");
			  strmid(VehicleInfo[car][CarOwner], dini_Get(file,"CarOwner"), 0, strlen(dini_Get(file,"CarOwner")), 255);
			  VehicleInfo[car][Buyable] = dini_Int(file,"Buyable");
			  VehicleInfo[car][Price] = dini_Int(file,"Price");
			  Update3D(car, VehicleInfo[car][Buyable]);
			  if(dini_Int(file,"CarOwned")) printf("() %d       Owner: %s",car,VehicleInfo[car][CarOwner]);
		}
	}
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) OnPlayerConnect(i);
}
//==============================================================================
function(SaveFiles())
{
	new file[64];
    for (new car = 1; car < VCount; car++)
	{
         format(file,sizeof file,"Vehicle/%i.ini",car);
		 if(dini_Exists(file))
		 {
              dini_IntSet(file,"CarOwned",VehicleInfo[car][CarOwned]);
              if(!VehicleInfo[car][CarOwned]) dini_Set(file,"CarOwner","None");
              if(VehicleInfo[car][CarOwned]) dini_Set(file,"CarOwner",VehicleInfo[car][CarOwner]);
              dini_IntSet(file,"Buyable",VehicleInfo[car][Buyable]);
              dini_IntSet(file,"Price",VehicleInfo[car][Price]);
		 }
	}
}
function(TeleCar(playerid))
{
   SetVehiclePos(GetPlayerVehicleID(playerid), Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]+0.5);
   SetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[playerid][3]);
   SetCameraBehindPlayer(playerid);
   vehicleCallBug[playerid] = 0;
}
//=[RepairCAR]========================================
function(RepairCar(playerid))
{
   TogglePlayerControllable(playerid,1);
   GetVehiclePos(Vehicle_Info[playerid][CarID],vPos[playerid][0],vPos[playerid][1],vPos[playerid][2]);
   SetVehicleHealth(Vehicle_Info[playerid][CarID],1000.0);
   SetPlayerPos(playerid,vPos[playerid][0],vPos[playerid][1],vPos[playerid][2]+3.0);
   SetPlayerInterior(playerid,0);
   SetCameraBehindPlayer(playerid);
   vehicleCallBug[playerid] = 0;
}
stock AddStaticZVehicle(b,modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z,Float:spawn_angle, color1, color2)
{
  new file[126];
  AddStaticVehicle(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z,Float:spawn_angle, color1, color2);
  format(file,sizeof file,"Vehicle/%i.ini",count_v);
  count_v++;
  CarToRent[count_v] = 0;
  //Update3D(count_v, b);
  if(dini_Exists(file))
  {
	   dini_IntSet(file,"Buyable", b);
	   VehicleInfo[count_v][Buyable] = b;
  }
  else
  {
       VCount++;
       format(file,sizeof file,"Vehicle/%i.ini",VCount);
	   dini_Create(file);
	   dini_IntSet(file,"CarID",VCount);
	   dini_Set(file,"CarName",VehiclesName[GetVehicleModel(VCount)-400] );
	   dini_IntSet(file,"CarModel",GetVehicleModel(VCount));
	   dini_IntSet(file,"CarOwned",0);
	   dini_Set(file,"CarOwner","None");
	   dini_IntSet(file,"Price", 10000);
	   dini_IntSet(file,"LevelCar",0);
	   dini_IntSet(file,"SaleV",0);
	   dini_IntSet(file,"PayTax",14);
	   dini_IntSet(file,"MoneyTax",0);
	   dini_IntSet(file,"Buyable",b);
	   VehicleInfo[VCount][PayTax] = dini_Int(file,"PayTax");
	   VehicleInfo[VCount][LevelCar] = dini_Int(file,"LevelCar");
	   VehicleInfo[VCount][SaleV] = dini_Int(file,"SaleV");
	   VehicleInfo[VCount][CarID] = dini_Int(file,"CarID");
	   strmid(VehicleInfo[VCount][CarName], dini_Get(file,"CarName"), 0, strlen(dini_Get(file,"CarName")), 255);
	   VehicleInfo[VCount][CarModel] = dini_Int(file,"CarModel");
	   VehicleInfo[VCount][CarOwned] = dini_Int(file,"CarOwned");
	   strmid(VehicleInfo[VCount][CarOwner], dini_Get(file,"CarOwner"), 0, strlen(dini_Get(file,"CarOwner")), 255);
	   VehicleInfo[VCount][Buyable] = dini_Int(file,"Buyable");
	   VehicleInfo[VCount][MoneyTax] = dini_Int(file,"MoneyTax");
	   VehicleInfo[VCount][MoneyTax] = 550;
	   dini_IntSet(file,"MoneyTax", VehicleInfo[VCount][MoneyTax]);
  }
  return 1;
}
function(noticeTax())
{
  new string[128];
  for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
  {
      if(PlayerInfo(logged[playerid]))
	  {
          new idcar = Vehicle_Info[playerid][CarID];
		  if(VehicleInfo[idcar][PayTax] < 1 && VehicleInfo[idcar][MoneyTax] > 0 && idcar != 0)
		   {
               SendClientMessage(playerid, white, "   ");
			   format(string, sizeof string," • !%d$ :שים לב, אתה חייב לשלם מס' על הרכב שלך, עליך לשלם • ",VehicleInfo[idcar][MoneyTax]);
               SendClientMessage(playerid, orange, string);
               SendClientMessage(playerid, yellow, "/Vehicle(v) | Tax - אם לא תשלם על המס' הרכב שלך ימכר ללא הודעה מוקדמת, על מנת לשלם");
           }
		   else if(VehicleInfo[idcar][PayTax] > 1 && VehicleInfo[idcar][PayTax] < 5 && VehicleInfo[idcar][MoneyTax] > 0 && idcar != 0)
		   {
               SendClientMessage(playerid, white, "   ");
               format(string, sizeof string," • %d :שים לב, אנו ממליצים לך לשלם מס' על הרכב, אם לא תשלם הרכב של יוצע למכירה בעוד מספר ימים • ",VehicleInfo[idcar][PayTax]);
               SendClientMessage(playerid, orange, string);
               format(string, sizeof string," • !%d$ 'תשלום מס /Vehicle(v) | Tax - על מנת לשלם",VehicleInfo[idcar][MoneyTax]);
               SendClientMessage(playerid, yellow, string);
           }
	  }
  }
  return 1;
}
stock G_Vehicles()
{
  AddStaticZVehicle(0,522, -2589.1243, 1163.5635, 58.0881, 148.3558, 0, 5); // Race
  AddStaticZVehicle(0,522, -2599.8526, 1148.2684, 55.1477, 113.5569, 0, 1); // Race
  AddStaticZVehicle(0,522, -2600.9371, 1149.2207, 55.1529, 114.1736, 5, 1); // Race
  AddStaticZVehicle(0,522, -2602.0789, 1150.0208, 55.1577, 110.4085, 3, 3); // Race
  AddStaticZVehicle(0,522, -2603.1939, 1150.768, 55.1506, 109.6738, 39, 106); // Race
  AddStaticZVehicle(0,522, -2604.2295, 1151.5789, 55.1553, 99.8136, 51, 118); // Race
  AddStaticZVehicle(0,411, -2596.9917, 1109.8424, 55.306, 331.2974, 80, 1); // Race
  AddStaticZVehicle(0,411, -2599.7256, 1111.4083, 55.3049, 331.1954, 75, 1); // Race
  AddStaticZVehicle(0,411, -2602.2132, 1112.8842, 55.3051, 331.118, 12, 1); // Race
  AddStaticZVehicle(0,411, -2604.7542, 1114.3679, 55.304, 329.7554, 64, 1); // Race
  AddStaticZVehicle(0,411, -2607.2535, 1115.9053, 55.3051, 329.6423, 3, 3); // Race
  AddStaticZVehicle(0,541, -2578.5086, 1137.5618, 55.2299, 159.3347, 58, 8); // Race
  AddStaticZVehicle(0,541, -2575.7876, 1136.5317, 55.2532, 160.8014, 2, 1); // Race
  AddStaticZVehicle(0,541, -2573.2715, 1135.6857, 55.2728, 160.8883, 0, 1); // Race
  AddStaticZVehicle(0,451, -2572.2159, 1098.0496, 55.3139, 336.6589, 61, 61); // Race
  AddStaticZVehicle(0,451, -2567.2955, 1096.0803, 55.3488, 339.2178, 123, 123); // Race
  AddStaticZVehicle(0,451, -2569.6438, 1096.9428, 55.3152, 337.4364, 75, 75); // Race
  AddStaticZVehicle(0,451, -2564.5936, 1094.8433, 55.3683, 336.8817, 3, 3); // Race
  AddStaticZVehicle(0,451, -2561.8658, 1093.6462, 55.3871, 338.5524, 36, 36); // Race
  AddStaticZVehicle(1,416, -2649.6963, 630.1735, 14.6021, 89.9309, 1, 3);
  AddStaticZVehicle(1,416, -2658.2493, 630.0269, 14.603, 88.8713, 1, 3);
  AddStaticZVehicle(1,538, -1942.7771, 168.6436, 27.2245, 356.7156, 5, 3);
  AddStaticZVehicle(1,449, -2346.8028, 462.251, 32.4608, 216.7976, 1, 74);
  AddStaticZVehicle(1,449, -2346.8028+10, 462.251, 32.4608, 216.7976, 1, 74); // maybe crash
  AddStaticZVehicle(1,449, -2346.8028+20, 462.251, 32.4608, 216.7976, 1, 74); // maybe crash
  AddStaticZVehicle(0,522, 1911.4226, -1416.0341, 13.1413, 209.1517, 51, 118);
  AddStaticZVehicle(0,522, 1912.9511, -1415.8237, 13.1394, 212.503, 3, 3);
  AddStaticZVehicle(0,522, 1914.5983, -1415.5365, 13.14, 217.5095, 3, 8);
  AddStaticZVehicle(0,522, 1916.2413, -1415.2093, 13.1344, 221.2799, 6, 25);
  AddStaticZVehicle(0,522, 1918.439, -1414.9668, 13.1345, 182.8242, 7, 79);
  AddStaticZVehicle(0,522, 1920.1104, -1414.9383, 13.1335, 148.4096, 8, 82);
  AddStaticZVehicle(0,522, 1921.8055, -1415.2293, 13.1353, 149.5382, 36, 105);
  AddStaticZVehicle(0,522, 1923.2066, -1415.2952, 13.1345, 140.6638, 39, 106);
  AddStaticZVehicle(0,522, 1924.6876, -1415.6073, 13.1403, 142.9844, 51, 118);
  AddStaticZVehicle(0,522, 1926.0341, -1415.6976, 13.1408, 141.7378, 3, 3);
  AddStaticZVehicle(1,443, 1970.1499, -1448.4986, 14.1175, 269.9656, 1, 1);
  AddStaticZVehicle(1,429, -2556.8997, 1144.9517, 55.4062, 162.7243, 3, 5);
  AddStaticZVehicle(1,434, -2545.9539, 1143.0867, 55.6996, 168.1864, 12, 12);
  AddStaticZVehicle(1,506, -2531.1905, 1140.8096, 55.431, 173.1387, 1, 1);
  AddStaticZVehicle(1,480, -2510.231, 1139.3413, 55.4999, 177.722, 6, 6);
  AddStaticZVehicle(1,429, -2475.1951, 1139.3033, 55.408, 181.074, 6, 3);
  AddStaticZVehicle(1,451, -2454.8147, 1138.8909, 55.4347, 178.1257, 16, 16);
  AddStaticZVehicle(1,522, -2417.5123, 1134.3975, 55.2901, 194.906, 5, 3);
  AddStaticZVehicle(1,411, -2400.7298, 1131.6887, 55.4516, 162.6049, 6, 6);
  AddStaticZVehicle(1,541, -2366.4334, 1118.8144, 55.3564, 161.3479, 6, 0);
  AddStaticZVehicle(1,480, -2426.0193, 1022.2532, 50.1721, 359.5534, 2, 2);
  AddStaticZVehicle(1,494, -2458.0579, 1069.2463, 55.6713, 359.2484, 0, 5);
  AddStaticZVehicle(1,494, -2465.7693, 1069.2955, 55.6719, 1.493, 1, 6);
  AddStaticZVehicle(1,494, -2473.5423, 1069.0841, 55.6677, 1.0907, 3, 7);
  AddStaticZVehicle(1,494, -2480.6866, 1069.2369, 55.6582, 0.7129, 6, 4);
  AddStaticZVehicle(0,437, -2440.8726, 2240.6179, 4.9658, 178.9523, 79, 7);
  AddStaticZVehicle(0,437, -2443.8667, 2240.5717, 4.9408, 179.3966, 87, 7);
  AddStaticZVehicle(0,437, -2446.8975, 2240.6171, 4.9407, 178.9033, 95, 16);
  AddStaticZVehicle(0,437, -2449.9466, 2240.6767, 4.9208, 178.9557, 98, 20);
  AddStaticZVehicle(0,437, -2452.8953, 2240.5839, 4.9425, 179.6596, 105, 20);
  AddStaticZVehicle(0,437, -2479.6365, 2240.7055, 4.977, 178.6889, 123, 20);
  AddStaticZVehicle(1,437, -2464.6282, 2225.706, 4.9816, 0.8454, 87, 7);
  AddStaticZVehicle(1,541, -2753.4617, 370.1502, 3.7802, 180.4261, 0, 1);
  AddStaticZVehicle(1,541, -2753.5298, 379.4443, 3.7578, 180.4284, 0, 1);
  AddStaticZVehicle(1,429, -2730.0201, 291.9035, 4.1434, 90.5677, 1, 2);
  AddStaticZVehicle(1,522, -2796.9009, 218.7409, 6.768, 88.8703, 39, 106);
  AddStaticZVehicle(1,560, -2796.1207, 196.9306, 6.8926, 90.8777, 33, 0);
  AddStaticZVehicle(1,451, -2779.4576, 161.3824, 6.7376, 269.67, 36, 36);
  AddStaticZVehicle(1,434, -2796.4625, 135.9008, 7.1465, 89.6088, 46, 46);
  AddStaticZVehicle(1,411, -2796.4339, 88.2155, 6.9145, 269.9836, 80, 1);
  AddStaticZVehicle(1,468, -2794.2525, 24.2017, 6.8555, 355.0494, 3, 3);
  AddStaticZVehicle(1,522, -2797.3101, -107.4795, 6.7488, 269.7401, 51, 118);
  AddStaticZVehicle(1,571, -2796.9996, -114.3181, 6.4711, 178.2171, 0, 147);
  AddStaticZVehicle(1,480, -2746.7474, -282.0719, 6.8113, 179.533, 5, 5);
  AddStaticZVehicle(1,429, -2771.5899, -283.0789, 6.728, 179.4338, 0, 5);
  AddStaticZVehicle(1,560, -2754.19, -282.5182, 6.7448, 180.1053, 1, 1);
  AddStaticZVehicle(1,402, -2765.794, -312.1244, 6.8706, 1.8754, 6, 6);
  AddStaticZVehicle(1,409, -2726.3145, -311.8798, 6.839, 313.7818, 1, 1);
  AddStaticZVehicle(1,412, -2484.9368, -169.2697, 25.4542, 89.6585, 10, 8);
  AddStaticZVehicle(1,415, -2530.087, -143.4323, 19.5543, 3.7525, 62, 1);
  AddStaticZVehicle(1,597, -1605.9903, 673.9577, 6.958, 181.7133, 0, 1);
  AddStaticZVehicle(1,597, -1588.2872, 674.0264, 6.9562, 182.1625, 0, 1);
  AddStaticZVehicle(1,599, -1600.2472, 674.5014, 7.3741, 179.8294, 0, 1);
  AddStaticZVehicle(1,523, -1616.8323, 651.4166, 6.7539, 1.1734, 0, 0);
  AddStaticZVehicle(1,427, -1599.4843, 651.7039, 7.3194, 1.0881, 0, 1);
  AddStaticZVehicle(1,597, -1604.3517, 749.1448, -5.4728, 179.7151, 0, 1);
  AddStaticZVehicle(1,597, -1572.9598, 722.4598, -5.474, 269.9656, 0, 1);
  AddStaticZVehicle(1,597, -1612.3399, 693.713, -5.4746, 0.7408, 0, 1);
  AddStaticZVehicle(1,415, -1699.4028, 885.4962, 24.6613, 358.7974, 62, 1);
  AddStaticZVehicle(1,411, -1753.0547, 954.7661, 24.4692, 90.8078, 80, 1);
  AddStaticZVehicle(1,411, -1704.1959, 1028.394, 17.3129, 270.9418, 80, 1);
  AddStaticZVehicle(1,522, -1720.1546, 1024.0947, 17.1487, 271.8508, 3, 3);
  AddStaticZVehicle(1,451, -1705.1209, 1058.4147, 17.2928, 357.3504, 16, 16);
  AddStaticZVehicle(1,522, -1936.4057, 883.3156, 38.0772, 180.7915, 0, 98);
  AddStaticZVehicle(1,556, -2490.774, 1214.8739, 37.7887, 142.2816, 1, 1);
  AddStaticZVehicle(1,556, -2494.4034, 1217.4747, 37.7803, 143.4331, 1, 1);
  AddStaticZVehicle(1,556, -2497.857, 1220.1529, 37.7736, 144.113, 1, 1);
  AddStaticZVehicle(1,556, -2501.3597, 1222.7934, 37.7943, 142.9347, 1, 1);
  AddStaticZVehicle(1,463, -2540.449, 1231.4763, 36.9616, 211.8285, 36, 36);
  AddStaticZVehicle(1,463, -2536.086, 1231.5501, 36.9618, 211.4622, 22, 22);
  AddStaticZVehicle(1,463, -2527.6487, 1231.6783, 36.9641, 213.9781, 6, 6);
  AddStaticZVehicle(1,463, -2523.0589, 1231.6463, 36.9655, 212.6721, 7, 7);
  AddStaticZVehicle(1,463, -2518.461, 1231.5163, 36.9625, 209.6009, 5, 5);
  AddStaticZVehicle(1,463, -2531.8721, 1231.6977, 36.9561, 219.8728, 3, 3);
  AddStaticZVehicle(1,480, -2618.5157, 1379.5444, 6.9264, 90.5808, 6, 6);
  AddStaticZVehicle(1,409, -2617.2393, 1346.2999, 6.9906, 0.5978, 1, 1);
  AddStaticZVehicle(1,411, -2647.0709, 1333.2004, 6.9049, 359.7043, 0, 0);
  AddStaticZVehicle(1,415, -2645.5435, 1378.3291, 6.9376, 307.3609, 3, 3);
  AddStaticZVehicle(1,522, -2650.1785, 1367.4936, 6.7513, 179.7035, 36, 105);
  AddStaticZVehicle(1,506, -2301.7671, 1373.4837, 6.9015, 233.8851, 7, 7);
  AddStaticZVehicle(1,535, -2085.2654, 1431.9951, 6.8678, 179.8681, 28, 1);
  AddStaticZVehicle(1,411, -2071.0098, 1432.1182, 6.8291, 180.2388, 6, 6);
  AddStaticZVehicle(1,429, -2068.2313, 1432.043, 6.7822, 180.7333, 1, 3);
  AddStaticZVehicle(1,451, -2065.3746, 1431.8205, 6.8067, 178.9617, 125, 125);
  AddStaticZVehicle(1,448, -1718.7991, 1364.9283, 6.7863, 136.4871, 3, 6);
  AddStaticZVehicle(1,411, -1637.2648, 1297.7225, 6.7618, 135.1746, 12, 1);
  AddStaticZVehicle(1,522, -1658.3228, 1218.9095, 13.2358, 267.9854, 1, 3);
  AddStaticZVehicle(1,415, -1653.6331, 1211.7774, 13.4434, 241.5966, 5, 5);
  AddStaticZVehicle(1,468, -1652.9507, 1208.8997, 20.8223, 250.5137, 3, 3);
  AddStaticZVehicle(1,424, -1657.6783, 1215.8262, 20.9356, 315.1684, 2, 2);
  AddStaticZVehicle(1,522, -1543.8011, 1225.7028, 6.7508, 91.5672, 0, 2);
  AddStaticZVehicle(1,446, -1480.1866, 1090.294, -0.511, 269.2322, 1, 5);
  AddStaticZVehicle(1,460, -1463.4142, 1091.2089, 1.4821, 267.4433, 0, 1);
  AddStaticZVehicle(1,415, -1537.1127, 1014.4187, 6.9597, 91.7093, 1, 1);
  AddStaticZVehicle(1,451, -1490.2115, 840.7078, 6.8945, 90.2559, 16, 16);
  AddStaticZVehicle(1,522, -1629.3538, 883.8012, 8.7278, 7.6121, 36, 105);
  AddStaticZVehicle(1,451, -1774.5591, 762.7664, 24.5967, 90.2583, 18, 18);
  AddStaticZVehicle(1,470, -1938.6388, 792.1049, 45.8802, 90.2014, 43, 0);
  AddStaticZVehicle(1,429, -1997.7264, 685.6726, 44.9766, 181.1522, 0, 3);
  AddStaticZVehicle(1,522, -2048.4612, 744.2315, 56.859, 176.6649, 39, 106);
  AddStaticZVehicle(1,480, -1942.6056, 486.2616, 31.7429, 1.1095, 4, 4);
  AddStaticZVehicle(1,471, -2051.8692, 487.4067, 34.6543, 267.8486, 103, 111);
  AddStaticZVehicle(1,471, -2052.0267, 488.717, 34.6526, 270.9136, 120, 114);
  AddStaticZVehicle(1,471, -2051.941, 489.9674, 34.653, 271.9348, 3, 1);
  AddStaticZVehicle(1,451, -1964.3344, 433.8031, 34.8796, 356.7496, 5, 5);
  AddStaticZVehicle(1,571, -1990.0597, 305.6864, 34.4631, 268.8753, 91, 2);
  AddStaticZVehicle(1,571, -1989.9863, 304.1126, 34.4604, 266.1119, 40, 35);
  AddStaticZVehicle(1,571, -1990.0971, 302.35, 34.4833, 270.956, 11, 22);
  AddStaticZVehicle(1,463, -1989.2502, 300.1144, 34.7196, 271.0939, 22, 22);
  AddStaticZVehicle(1,463, -1989.3853, 308.7706, 34.7196, 268.0815, 3, 3);
  AddStaticZVehicle(1,522, -1969.1957, 307.9663, 34.7354, 178.2256, 0, 3);
  AddStaticZVehicle(1,415, -1944.4814, 258.6043, 35.2397, 89.7126, 6, 6);
  AddStaticZVehicle(1,411, -1944.5237, 261.5841, 35.1977, 89.6733, 2, 2);
  AddStaticZVehicle(1,603, -1944.7968, 264.8341, 35.3114, 89.8041, 1, 6);
  AddStaticZVehicle(1,567, -1944.9838, 268.2261, 35.3426, 90.6554, 16, 16);
  AddStaticZVehicle(1,560, -1944.6589, 271.6387, 35.1481, 88.9573, 21, 21);
  AddStaticZVehicle(1,535, -1944.5951, 275.0775, 35.2369, 89.7694, 1, 1);
  AddStaticZVehicle(1,477, -1953.3136, 293.0635, 35.2246, 89.2024, 16, 16);
  AddStaticZVehicle(1,506, -1952.9311, 296.3287, 35.1747, 90.3845, 0, 0);
  AddStaticZVehicle(1,451, -1953.0394, 299.2157, 35.1777, 90.9879, 6, 6);
  AddStaticZVehicle(1,541, -1952.7183, 302.1058, 35.0956, 89.4544, 5, 98);
  AddStaticZVehicle(1,480, -1952.9712, 305.3309, 35.2417, 90.8012, 3, 3);
  AddStaticZVehicle(1,522, -1951.5557, 297.9761, 40.5988, 318.6398, 6, 6);
  AddStaticZVehicle(1,522, -1951.3366, 296.7499, 40.6003, 325.8758, 5, 5);
  AddStaticZVehicle(1,522, -1951.2461, 295.5806, 40.6035, 323.9816, 2, 2);
  AddStaticZVehicle(1,522, -1951.2668, 294.1225, 40.6027, 319.1051, 1, 1);
  AddStaticZVehicle(1,522, -1951.1395, 293.0046, 40.5973, 312.0401, 0, 0);
  AddStaticZVehicle(1,522, -1951.0445, 291.8872, 40.6046, 316.272, 3, 3);
  AddStaticZVehicle(1,429, -1956.6065, 305.6044, 40.7267, 179.061, 0, 1);
  AddStaticZVehicle(1,560, -1944.9062, 255.0677, 40.7512, 270.1794, 6, 6);
  AddStaticZVehicle(1,507, -1945.178, 258.3757, 40.8712, 269.3464, 0, 0);
  AddStaticZVehicle(1,451, -1944.9324, 261.1914, 40.7529, 269.1318, 5, 5);
  AddStaticZVehicle(1,415, -1945.3963, 270.3432, 40.8218, 266.4778, 3, 3);
  AddStaticZVehicle(1,407, -2021.0236, 92.9794, 28.2327, 270.9491, 3, 1);
  AddStaticZVehicle(1,407, -2021.1403, 84.6867, 28.2154, 269.1317, 3, 1);
  AddStaticZVehicle(1,407, -2021.0705, 75.4904, 28.2977, 272.0686, 3, 1);
  AddStaticZVehicle(1,541, -1988.2293, 137.3159, 27.166, 3.6452, 5, 3);
  AddStaticZVehicle(1,522, -2128.0972, 904.6145, 79.443, 93.0177, 0, 5);
  AddStaticZVehicle(1,522, -2128.1949, 905.476, 79.4778, 92.2311, 3, 3);
  AddStaticZVehicle(1,522, -2128.1177, 906.4434, 79.4816, 90.2827, 0, 3);
  AddStaticZVehicle(1,522, -2128.1668, 907.3455, 79.4984, 91.5279, 0, 16);
  AddStaticZVehicle(1,541, -2105.3174, 892.3236, 76.3282, 0.3235, 58, 8);
  AddStaticZVehicle(1,411, -2157.7725, 942.3107, 79.7304, 270.2008, 116, 1);
  AddStaticZVehicle(1,451, -2157.6739, 960.6981, 79.7107, 270.2001, 123, 123);
  AddStaticZVehicle(1,560, -2157.9151, 979.0531, 79.7087, 269.4378, 3, 3);
  AddStaticZVehicle(1,463, -2158.5318, 997.3491, 79.5472, 228.6764, 79, 79);
  AddStaticZVehicle(1,434, -2158.3016, 1043.8963, 79.9674, 269.4031, 2, 2);
  AddStaticZVehicle(1,541, -2158.1592, 1062.2653, 79.6293, 271.203, 16, 1);
  AddStaticZVehicle(1,567, -2129.4156, 983.0222, 79.873, 90.28, 3, 3);
  AddStaticZVehicle(1,468, -2127.8843, 1000.5283, 79.6761, 38.7112, 0, 0);
  AddStaticZVehicle(1,480, -2128.9371, 1019.0717, 79.7769, 89.3202, 53, 53);
  AddStaticZVehicle(1,424, -2128.0481, 1037.3005, 79.7874, 89.2002, 3, 6);
  AddStaticZVehicle(1,477, -2129.1102, 1055.7713, 79.76, 89.7741, 0, 1);
  AddStaticZVehicle(1,415, -2156.1106, 894.7799, 79.7758, 270.1047, 75, 1);
  AddStaticZVehicle(1,439, -2156.5523, 873.1002, 78.0892, 270.5296, 8, 17);
  AddStaticZVehicle(1,434, -2119.1299, 856.4569, 70.1355, 88.3277, 6, 6);
  AddStaticZVehicle(1,411, -2156.7601, 835.9312, 69.272, 270.7681, 6, 6);
  AddStaticZVehicle(1,451, -2416.69, -589.3638, 132.3554, 216.3439, 18, 18);
  AddStaticZVehicle(1,451, -2414.0289, -587.4225, 132.3786, 214.2532, 6, 6);
  AddStaticZVehicle(1,451, -2411.4498, -585.5627, 132.3428, 217.5823, 16, 16);
  AddStaticZVehicle(1,463, -2400.0638, -589.6299, 132.1887, 160.1524, 6, 6);
  AddStaticZVehicle(1,522, -2402.2278, -587.2765, 132.2191, 167.7667, 16, 16);
  AddStaticZVehicle(1,463, -2403.8209, -585.5732, 132.1869, 164.369, 3, 3);
  AddStaticZVehicle(1,560, -2397.7527, -591.9548, 132.3538, 125.0008, 17, 1);
  AddStaticZVehicle(1,560, -2396.0518, -594.1855, 132.3535, 126.2751, 21, 1);
  AddStaticZVehicle(1,463, -2395.7247, -597.4358, 132.1882, 99.2309, 5, 5);
  AddStaticZVehicle(1,461, -2394.2579, -599.4488, 132.2326, 100.8934, 79, 1);
  AddStaticZVehicle(1,463, -2392.4603, -602.1329, 132.1882, 93.1064, 18, 18);
  AddStaticZVehicle(1,451, 2505.6293, -1694.8133, 13.2638, 359.6292, 18, 18);
  AddStaticZVehicle(1,522, 2513.4184, -1705.2452, 12.9884, 358.5816, 1, 3);
  AddStaticZVehicle(1,451, 2489.875, -1682.8249, 13.0434, 93.4132, 46, 46);
  AddStaticZVehicle(1,411, 2508.2683, -1665.8654, 13.1294, 13.3189, 12, 1);
  AddStaticZVehicle(1,429, 2491.7153, -1654.7613, 13.0385, 96.3925, 2, 1);
  AddStaticZVehicle(1,468, 464.5314, 868.7213, -28.0686, 101.0322, 3, 3);
  AddStaticZVehicle(1,468, 464.3268, 869.5377, -28.0885, 108.1218, 6, 6);
  AddStaticZVehicle(1,468, 464.2091, 870.4202, -28.1295, 105.7128, 46, 46);
  AddStaticZVehicle(1,468, 459.6115, 887.7598, -27.9588, 91.4309, 53, 53);
  AddStaticZVehicle(1,468, 459.7179, 886.5115, -28.0152, 95.4579, 3, 3);
  AddStaticZVehicle(1,468, 459.8926, 885.3942, -28.0765, 95.7479, 6, 6);
  AddStaticZVehicle(1,444, 541.2985, 881.119, -35.256, 256.0559, 32, 42);
  AddStaticZVehicle(1,471, 544.7893, 905.8767, -43.4792, 165.6062, 120, 117);
  AddStaticZVehicle(1,471, 543.4144, 906.2072, -43.4795, 165.4524, 66, 71);
  AddStaticZVehicle(1,522, 594.41, 873.2634, -43.8439, 87.5198, 6, 25);
  AddStaticZVehicle(1,522, 594.4083, 872.3873, -43.8321, 88.1352, 7, 79);
  AddStaticZVehicle(1,522, 594.3372, 871.1826, -43.8405, 89.8592, 8, 82);
  AddStaticZVehicle(1,471, 637.6956, 831.8212, -43.479, 178.0706, 103, 111);
  AddStaticZVehicle(1,468, 637.4808, 829.239, -40.6931, 352.3088, 46, 46);
  AddStaticZVehicle(1,556, 681.8029, 833.1633, -42.5849, 60.32, 1, 1);
  AddStaticZVehicle(1,556, 684.6414, 838.5499, -42.5832, 60.1181, 1, 1);
  AddStaticZVehicle(1,468, 683.0919, 923.5781, -41.1037, 309.7475, 53, 53);
  AddStaticZVehicle(1,468, 682.3679, 924.4779, -41.1138, 311.8392, 3, 3);
  AddStaticZVehicle(1,411, -2675.783, 204.6791, 4.063, 358.8742, 106, 1);
  AddStaticZVehicle(1,522, -2654.0682, 206.386, 3.9072, 359.3514, 51, 118);
  AddStaticZVehicle(1,560, -2692.2591, 205.1345, 4.0408, 358.8163, 9, 39);
  AddStaticZVehicle(1,451, -2702.6346, 183.9846, 3.8872, 180.7191, 123, 123);
  AddStaticZVehicle(1,434, -2675.4278, 137.669, 4.3477, 272.2481, 46, 46);
  AddStaticZVehicle(1,411, -2633.5584, -34.3079, 4.063, 180.2908, 75, 1);
  AddStaticZVehicle(1,411, -2630.5142, -34.377, 4.063, 180.0099, 12, 1);
  AddStaticZVehicle(1,411, -2627.4737, -34.4828, 4.063, 180.5171, 64, 1);
  AddStaticZVehicle(1,411, -2624.3125, -34.5495, 4.063, 180.4234, 123, 1);
  AddStaticZVehicle(1,429, -2653.4346, -55.7891, 4.0156, 359.2105, 14, 14);
  AddStaticZVehicle(1,429, -2656.7413, -55.7021, 4.017, 0.0984, 1, 2);
  AddStaticZVehicle(1,429, -2660.0457, -55.7168, 4.0184, 359.9183, 2, 1);
  AddStaticZVehicle(1,429, -2663.3152, -55.6783, 4.0156, 0.3364, 1, 3);
  AddStaticZVehicle(1,429, -2666.7017, -55.6549, 4.0156, 1.302, 3, 1);
  AddStaticZVehicle(1,429, -2670.0035, -55.575, 4.0156, 0.0296, 10, 10);
  AddStaticZVehicle(1,522, -2675.8335, -21.4341, 3.8986, 335.8135, 3, 8);
  AddStaticZVehicle(1,522, -2679.2405, -21.2687, 3.9066, 335.0006, 6, 25);
  AddStaticZVehicle(1,522, -2682.554, -20.9931, 3.9063, 335.8434, 7, 79);
  AddStaticZVehicle(1,463, -2685.9192, -21.2186, 3.8756, 336.0841, 79, 79);
  AddStaticZVehicle(1,463, -2689.2676, -21.0936, 3.8761, 331.6899, 84, 84);
  AddStaticZVehicle(1,463, -2692.5181, -21.0182, 3.8763, 332.4443, 7, 7);
  AddStaticZVehicle(1,468, -2089.4266, -84.7308, 34.8331, 12.9054, 53, 53);
  AddStaticZVehicle(0,495, -2081.2034, -85.3031, 35.5214, 0.6894, 119, 122);
  AddStaticZVehicle(1,411, -2184.2623, 306.5715, 34.8442, 179.8614, 80, 1);
  AddStaticZVehicle(1,507, -2175.8335, 293.6964, 34.9418, 0.2601, 10, 10);
  AddStaticZVehicle(1,522, -2172.2334, 306.6577, 34.6859, 172.1571, 0, 16);
  AddStaticZVehicle(1,451, -2210.0389, 292.8186, 34.824, 0.6509, 36, 36);
  AddStaticZVehicle(1,429, -2227.0359, 293.9018, 34.7967, 3.5775, 14, 14);
  AddStaticZVehicle(1,415, -2222.8897, 306.4866, 34.8885, 180.0227, 36, 1);
  AddStaticZVehicle(1,468, -2655.7737, -114.1596, 3.6891, 268.9634, 3, 3);
  AddStaticZVehicle(1,541, -2263.9061, -11.0813, 34.8686, 358.2825, 22, 1);
  AddStaticZVehicle(1,429, -2247.5152, -116.5037, 34.9193, 0.2707, 1, 2);
  AddStaticZVehicle(1,451, -2326.1612, -127.701, 35.0181, 180.5962, 16, 16);
  AddStaticZVehicle(1,468, -2265.3003, 186.2478, 34.8263, 267.6906, 6, 6);
  AddStaticZVehicle(1,451, -2266.2017, 140.7866, 34.8652, 89.9548, 18, 18);
  AddStaticZVehicle(1,480, -2266.2889, 109.1578, 34.9454, 88.6203, 53, 53);
  AddStaticZVehicle(1,448,-1806.6649,943.7151,24.4853,136.7509,3,6); // PizzaBoy Of Ninja
  AddStaticZVehicle(1,522,2636.9092,-2233.7012,61.0481,90.9854,6,25); // NRG-Spawn1
  AddStaticZVehicle(0,468,-661.9053,2315.8809,138.4489,85.2785,6,6); //
  AddStaticZVehicle(0,522,-662.3051,2319.6909,138.3797,79.5157,3,3); //
  AddStaticZVehicle(0,522,-661.3882,2322.3005,138.3161,82.1411,6,25);
  AddStaticZVehicle(0,495,-701.8160,2353.7788,127.9368,86.0277,118,117); //
  AddStaticZVehicle(0,495,-701.3953,2358.3601,128.1275,87.3927,118,117); //
  AddStaticZVehicle(0,424,-700.9930,2363.4241,127.8805,77.4453,2,2); //
  AddStaticZVehicle(0,424,-700.1772,2367.2053,128.2685,80.6949,0,0); //
  AddStaticZVehicle(0,424,-699.6188,2370.7805,128.5978,84.5756,1,1); //
  AddStaticZVehicle(1,522,-1637.8284,1160.3302,23.1834,232.2366,1,7); // NRG-500- SHADY
  AddStaticZVehicle(1,471,-2132.7144,1231.5138,33.4100,357.1033,1,7); // Quadbike SF
  AddStaticZVehicle(1,471,-2281.1555,1192.2797,54.7704,235.3649,1,3); // Quadbike SF
  AddStaticZVehicle(1,463,-2735.0190,1262.7703,11.3065,8.7192,1,7); // FreeWay
  AddStaticZVehicle(1,506,-2739.3669,1263.4763,11.4660,3.9284,1,1); // Super- GT
  AddStaticZVehicle(1,463,-2743.0164,1263.9384,11.3054,9.6276,1,7); // FreewWay SF
  AddStaticZVehicle(1,471,-2934.1187,441.3807,2.9262,88.2233,23,7); // QuadSF
  AddStaticZVehicle(1,452,-3000.7280,459.1496,-1.0441,359.6694,1,7); // Speed SF
  AddStaticZVehicle(1,423,-2826.4680,-401.3160,7.1346,174.4648,3,1); // IceCream Car -SF
  AddStaticZVehicle(1,470,-1627.4261,-2695.0818,48.5332,44.7983,1,1); // Tri S
  AddStaticZVehicle(1,443,-1544.2485,-2743.0737,49.1431,348.9653,1,7); // Packer SF
  AddStaticZVehicle(1,443,-1539.5975,-2743.9802,49.1415,348.9653,3,2); // Packer SF
  AddStaticZVehicle(1,443,-1534.8856,-2746.9915,49.1429,348.9750,6,6); // Packer SF
  AddStaticZVehicle(1,470,-1360.4171,456.9735,7.1822,180.6204,43,0); // Patriot SF
  AddStaticZVehicle(1,470,-1369.2336,456.8781,7.1824,180.6204,43,0); // Patriot SF
  AddStaticZVehicle(1,593,-1474.9814,372.4920,30.5469,268.7632,2,3); // Dodo
  AddStaticZVehicle(1,593,-1474.5914,390.5617,30.5469,268.7632,2,3); // Dodo
  AddStaticZVehicle(1,593,-1473.6027,436.3527,30.5467,268.7632,2,3); // Dodo
  AddStaticZVehicle(1,484,-635.1037,864.6246,0.1836,314.5651,50,32); // boat near gang home
  AddStaticZVehicle(1,531,-687.6762,965.3941,12.1144,270.3110,36,2); // Tractor
  AddStaticZVehicle(1,600,2473.2593,-1692.4158,13.2338,180.3435,32,8); // Ryder LS Vehicle
  AddStaticZVehicle(1,463,2297.6646,-1629.4259,14.2377,356.5174,7,1); // FreeWay LS
  AddStaticZVehicle(1,411,2301.3667,-1631.1306,14.3511,358.9872,1,7); // INFernus LS
  AddStaticZVehicle(1,463,2304.9976,-1630.2600,14.0593,356.5130,7,1); // Freeway
  AddStaticZVehicle(1,420,2310.1533,2379.3269,10.5991,0.9476,6,1); // Taxi - LV
  AddStaticZVehicle(1,438,2351.0530,2361.1113,10.8233,177.0285,6,76); // Cab - LV
  AddStaticZVehicle(1,506,2324.7800,2517.8501,10.4479,90.7998,6,6); // super-gt LV
  AddStaticZVehicle(1,502,2192.0635,2502.6560,10.7169,359.1063,1,7); // Horting Racer A LV
  AddStaticZVehicle(1,522,1087.0474,1071.4636,10.3833,314.5104,7,1); // NRG-LV
  AddStaticZVehicle(1,463,1413.6434,781.5512,10.3434,91.9650,1,9); // Freeway - LV
  AddStaticZVehicle(1,490,1414.0936,682.6036,10.9488,89.4445,1,7); // To LV
  // Air Port:
  AddStaticZVehicle(1,487,-1326.9041,-280.9383,14.3210,22.4297,1,7); // Maverick AP
  AddStaticZVehicle(1,487,-1348.9960,-261.9394,14.3521,315.9516,0,0); // Maervick SF
  AddStaticZVehicle(1,487,-1378.1238,-234.3131,14.2941,315.9514,0,0); // Maervick SF
  AddStaticZVehicle(1,463,-1373.1195,-258.2826,13.6813,286.9348,0,0); // FreeWay - AP
  AddStaticZVehicle(1,447,-1580.3591,43.7435,17.4061,225.9826,75,2); // SeaSparrow
  AddStaticZVehicle(1,447,-1574.4537,49.8561,17.5593,225.9826,75,2); // SeaSparrow
  AddStaticZVehicle(1,447,-1565.3083,59.3240,18.0658,225.9826,75,2); // SeaSparrow
  AddStaticZVehicle(1,535,-1362.6261,326.7534,6.9514,181.2514,1,7); // White SF Vehile Salmva
  AddStaticZVehicle(1,535,-1358.5978,326.8414,6.9506,181.2514,0,0); // Blak SF Vehile Salmva
  AddStaticZVehicle(1,452,-1454.1187,501.6400,-0.3553,89.8443,1,126); // speeder near ap
  AddStaticZVehicle(0,519,-1083.6965,-216.6885,15.0634,67.0536,1,1); // Shamal SF AP
  // Air Port SF:
  AddStaticZVehicle(1,519,-1387.0239,-209.7061,15.0694,278.2845,1,1); //
  AddStaticZVehicle(1,519,-1332.9235,-267.5302,15.0704,23.3071,1,1); //
  AddStaticZVehicle(1,487,-1293.0602,-261.4460,14.2872,18.2189,65,65); //
  AddStaticZVehicle(1,487,-1279.2457,-257.3970,14.2874,33.1975,0,8); //
  AddStaticZVehicle(1,476,-1239.2008,-93.1628,14.8416,134.8797,3,3); //
  AddStaticZVehicle(1,592,-1509.3455,-130.3087,15.3313,317.7641,1,1); //
  AddStaticZVehicle(1,443,-1323.7559,-363.6788,14.7843,186.3627,0,0); //
  AddStaticZVehicle(1,519,-1385.3925,-484.3452,15.0684,251.6320,1,1); //
  AddStaticZVehicle(1,519,-1355.6760,-467.9077,15.0881,162.2889,1,1); //
  AddStaticZVehicle(1,511,-1442.6512,-523.4780,15.5525,207.5157,8,66); //
  AddStaticZVehicle(1,469,-1189.7672,-151.7600,14.1575,132.0141,1,3); //
  AddStaticZVehicle(1,469,-1194.2996,-148.3409,14.1854,129.9893,1,3); //
  AddStaticZVehicle(1,487,-1198.8293,-141.5229,14.2648,132.1973,0,1); //
  AddStaticZVehicle(1,487,-1205.0498,-135.8239,14.3264,132.1967,0,1); //
  AddStaticZVehicle(1,417,-1217.8187,-128.3205,14.2473,137.4675,0,0); //
  AddStaticZVehicle(1,425,-1223.4148,-12.3957,14.7393,43.6659,43,0); //
  AddStaticZVehicle(1,425,-1184.8783,23.1352,14.7064,46.7357,43,0); //
  AddStaticZVehicle(1,577,-1697.8329,-258.8392,14.0601,270.3505,8,10); // at-400>AP
  AddStaticZVehicle(1,520, -1575.2896, -273.7479, 14.8717, 43.06, 0, 0);
  AddStaticZVehicle(1,520, -1583.6209, -282.5193, 14.8717, 46.826, 0, 0);
  AddStaticZVehicle(1,520, -1592.1606, -291.156, 14.8717, 44.3348, 0, 0);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  AddStaticZVehicle(0,590, -549.349304, 2593.856201, 52.981098, 269.459503, 255, 255);
  // Corelone Gang:
  AddStaticZVehicle(0,487,-707.7557,976.7243,12.6549,181.4516,2, 2); // Vehicle Corelone
  AddStaticZVehicle(0,487,-707.0580,949.2399,12.6181,1.4516,2, 2); // Vehicle Corelone
  AddStaticZVehicle(0,409,-686.8555,961.7623,11.9332,90.3732,2, 2); // Limo Corelone
  AddStaticZVehicle(0,409,-686.9049,969.3803,11.9336,90.3732,2, 2); // Limo Corelone
  AddStaticZVehicle(0,463,-687.2234,966.1779,11.6821,91.7211,2, 2); // FreeWay Corelone
  AddStaticZVehicle(0,452,-645.3965,864.9937,-0.5060,49.6402,2, 2); // Speeder Corelone
  AddStaticZVehicle(0,522,-669.5877,945.1866,11.6929,181.5172,2, 2); // Corelone NRG
  AddStaticZVehicle(0,522,-672.1756,945.1181,11.6929,181.5174,2, 2); // Corelone NRG
  AddStaticZVehicle(0,522,-675.3264,945.0347,11.6929,181.5176,2, 2); // Corelone NRG
  AddStaticZVehicle(0,522,-668.1536,970.7087,11.6965,359.6724,2, 2); // Corelone NRG
  AddStaticZVehicle(0,451,-716.4620,988.0799,11.8624,0.0173,2, 2); // Corelone Turismo
  AddStaticZVehicle(0,451,-723.3269,988.0759,11.8631,0.1038,2, 2); // Corelone Turismo
  //Abrgeel Gang:
  AddStaticZVehicle(0,409,2116.1819,1720.3982,10.5510,74.2697,3,3); // Limo Abrgeel - 18
  AddStaticZVehicle(0,409,2128.7163,1716.5703,10.5492,71.1960,3,3); // Limo Abrgeel
  AddStaticZVehicle(0,409,2160.1997,1675.7289,10.5524,169.0480,3,3); // Limo Abrgeel
  AddStaticZVehicle(0,451,2170.3237,1664.1577,10.5227,49.5355,3,3); // Turismo Abrgeel
  AddStaticZVehicle(0,451,2171.1526,1693.3219,10.5194,115.8092,3,3); // Turismo Abrgeel
  AddStaticZVehicle(0,463,2171.5623,1676.6541,10.3570,270.2036,3,3); // FreeWay
  AddStaticZVehicle(0,463,2171.5547,1678.7781,10.3570,270.2036,3,3); // FreeWay Abrgeel
  AddStaticZVehicle(0,487,2112.8357,1702.2515,10.9627,349.4554,3,3); // Maverick Abrgeel
  AddStaticZVehicle(0,487,2104.2681,1703.8462,10.9515,349.4553,3,3); // Maverick Abrgeel
  AddStaticZVehicle(0,411,2103.4519,1664.9641,10.5474,39.2396,3,3); // Abrgeel Infernus
  AddStaticZVehicle(0,411,2098.5918,1660.9946,10.5474,39.2396,3,3); // Abrgeel Infernus
  AddStaticZVehicle(0,522,2177.5676,1719.8007,10.6220,266.4034,3,3); // nrg abrgeel
  AddStaticZVehicle(0,522,2177.3855,1716.9000,10.6220,266.4034,3,3); // nrg abrgeel
  AddStaticZVehicle(0,522,2177.1558,1713.2452,10.6228,266.4035,3,3); // nrg abrgeel - 31
  //Castle:
  SetTimer("castleMove",200,1);
  castle_pickup[0] = CreatePickup(1239,23, 33.8500,1927.0360,18.0231, 0, mainPickups++, "Magic Castle", 0);
  castle_pickup[1] = CreatePickup(1239,23, -17.8747,1927.1907,18.0194, 0, mainPickups++, "Magic Castle", 0);
  Gate_Castle[0] = CreateStreamObject(980, -24.016531, 1930.344604, 19.414017, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[1] = CreateStreamObject(980, -35.556183, 1930.352905, 19.414017, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[2] = CreateStreamObject(980, -35.561935, 1930.384888, 24.945974, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[3] = CreateStreamObject(980, -24.022949, 1930.422852, 24.958113, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[4] = CreateStreamObject(980, 50.298721, 1930.268433, 19.414017, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[5] = CreateStreamObject(980, 38.752174, 1930.255493, 19.414017, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[6] = CreateStreamObject(980, 50.266106, 1930.419067, 24.888933, 0.0000, 0.0000, 180.0000, 500);
  Gate_Castle[7] = CreateStreamObject(980, 38.804054, 1930.417358, 24.888990, 0.0000, 0.0000, 180.0000, 500);
  CreateStreamObject(10377, 14.319541, 2027.815063, 34.207375, 1.7189, 357.4217, 273.5150, 500);
  CreateStreamObject(10381, -50.705734, 1983.597900, 27.907324, 0.0000, 0.0000, 180.0000, 500);
  CreateStreamObject(10380, -29.190094, 1943.281372, 26.339834, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(10380, 45.191750, 1943.291626, 26.339834, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(10381, 78.470253, 1987.070923, 29.217463, 0.0000, 0.0000, 0.1808, 500);
  CreateStreamObject(969, 4.275103, 1978.998291, 16.507530, 0.0000, 0.0000, 90.0000, 500);
  CreateStreamObject(993, 9.289627, 1978.535278, 18.254412, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(993, 9.235426, 1987.431274, 18.254412, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(993, 13.924053, 1983.455566, 18.261084, 0.0000, 0.0000, 270.0000, 500);
  CreateStreamObject(2773, 9.198727, 1984.249756, 17.157854, 0.0000, 0.0000, 270.0000, 500);
  CreateStreamObject(2773, 6.715851, 1982.745850, 17.157854, 0.0000, 0.0000, 270.0000, 500);
  CreateStreamObject(2773, 6.747015, 1984.196167, 17.157854, 0.0000, 0.0000, 270.0000, 500);
  CreateStreamObject(2773, 9.082054, 1982.804810, 17.157854, 0.0000, 0.0000, 270.0000, 500);
  CreateStreamObject(3267, 12.625572, 1980.595703, 15.901073, 15.4699, 0.8594, 202.5000, 500);
  CreateStreamObject(3267, 12.244181, 1985.985474, 15.951073, 15.4699, 0.8594, 326.2500, 500);
  CreateStreamObject(710, -42.887932, 1924.083374, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, -44.016418, 1902.539917, 32.234283, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, -44.133331, 1881.580444, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, -44.942642, 1856.337280, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, -44.750469, 1832.944336, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 82.542557, 1925.351074, 32.297688, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 82.448502, 1901.945557, 32.293037, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 81.404442, 1880.109619, 32.234283, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 81.206009, 1859.433350, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 81.027550, 1836.460815, 32.234283, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(7073, -5.622498, 1922.725708, 34.907375, 0.0000, 0.0000, 281.2500, 500);
  CreateStreamObject(7392, 10.311698, 1925.223145, 26.360699, 0.0000, 0.0000, 123.7499, 500);
  CreateStreamObject(2780, -29.660286, 1929.453369, 15.397636, 0.0000, 0.0000, 11.2500, 500);
  CreateStreamObject(2780, 46.475422, 1931.572876, 16.952324, 0.0000, 0.0000, 11.2500, 500);
  CreateStreamObject(2745, 15.724955, 2007.698486, 20.071444, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(3390, 7.617939, 1987.081787, 16.800909, 0.0000, 0.0000, 90.0000, 500);
  CreateStreamObject(8172, -20.901300, 1851.670532, 17.034983, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(8172, 18.939680, 1851.952393, 17.038719, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(8172, 58.864555, 1852.234497, 16.784986, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, -47.189667, 1810.114014, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, -44.624050, 1772.487671, 31.861179, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 80.697525, 1809.656372, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(710, 81.058479, 1773.021606, 32.227291, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1634, 57.290718, 1768.490723, 17.937943, 0.0000, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 67.860313, 1768.019165, 17.937943, 0.0000, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 53.289673, 1768.655273, 17.837944, 0.0000, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 61.076447, 1768.333374, 17.943428, 0.0000, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 64.221069, 1768.216919, 17.943428, 0.0000, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 53.486244, 1773.079346, 21.137917, 17.1887, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 57.652000, 1773.014038, 21.077822, 17.1887, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 61.613495, 1772.972168, 20.901991, 17.1887, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 64.891861, 1773.204102, 20.843960, 17.1887, 2.5783, 0.0000, 500);
  CreateStreamObject(1634, 68.551010, 1773.647949, 20.721622, 17.1887, 2.5783, 0.0000, 500);
  CreateStreamObject(13641, 59.325195, 1777.762695, 22.738605, 0.0000, 333.3575, 90.0000, 500);
  CreateStreamObject(13641, 58.695480, 1794.144409, 25.063604, 0.0000, 318.7470, 90.0000, 500);
  CreateStreamObject(7422, 9.103392, 2002.948120, 15.606234, 0.0000, 0.0000, 1.7189, 500);
  CreateStreamObject(1225, 58.809341, 1787.222656, 31.989607, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 62.159645, 1787.034790, 32.961475, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 54.127647, 1786.392334, 34.140522, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 55.855415, 1787.308472, 32.566216, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 53.998421, 1799.947876, 37.725487, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 55.928234, 1800.756836, 36.853844, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 58.443035, 1800.984985, 36.508549, 0.0000, 0.0000, 0.0000, 500);
  CreateStreamObject(1225, 61.684315, 1800.289673, 37.637177, 0.0000, 0.0000, 0.0000, 500);
  AddStaticZVehicle(0,487,57.0916,1992.3953,19.1995,181.7676,26,57); // Helicopter Castle
  AddStaticZVehicle(0,487,-30.5593,1996.9034,19.2032,178.7091,26,57); // Helicopter Castle2
  AddStaticZVehicle(0,429,71.4983,1926.0675,17.4491,118.0152,13,13); // Bansshe Castle
  SetTimer("LoadFiles", 4000, false);
}
function(castleMove())
{
    if(IsAnyoneNearCastle())
	{
        MoveStreamObject(Gate_Castle[0],-24.016531, 1930.344604, -1.0,1.5);
        MoveStreamObject(Gate_Castle[1], -35.556183, 1930.352905,-1.0,1.5);
        MoveStreamObject(Gate_Castle[2],-35.561935, 1930.384888,-6.0,1.5);
        MoveStreamObject(Gate_Castle[3],-24.022949, 1930.422852,-6.0,1.5);
        MoveStreamObject(Gate_Castle[4],50.298721, 1930.268433,-1.0,1.5);
        MoveStreamObject(Gate_Castle[5],38.752174, 1930.255493,-1.0,1.5);
        MoveStreamObject(Gate_Castle[6],50.266106, 1930.419067,-6.0,1.5);
        MoveStreamObject(Gate_Castle[7],38.804054, 1930.417358,-6.0,1.5);

    }
    else
    {
        MoveStreamObject(Gate_Castle[0],-24.016531, 1930.344604, 19.414017,1.5);
        MoveStreamObject(Gate_Castle[1],-35.556183, 1930.352905, 19.414017,1.5);
        MoveStreamObject(Gate_Castle[2],-35.561935, 1930.384888, 24.945974,1.5);
        MoveStreamObject(Gate_Castle[3], -24.022949, 1930.422852, 24.958113,1.5);
        MoveStreamObject(Gate_Castle[4], 50.298721, 1930.268433, 19.414017,1.5);
        MoveStreamObject(Gate_Castle[5],38.752174, 1930.255493, 19.414017,1.5);
        MoveStreamObject(Gate_Castle[6],50.266106, 1930.419067, 24.888933,1.5);
        MoveStreamObject(Gate_Castle[7], 38.804054, 1930.417358, 24.888990,1.5);
    }
    return 1;
}
stock IsAnyoneNearCastle()
{
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) if(PlayerToPoint(i, 7.0, 41.8856, 1923.9934, 17.7694) || PlayerToPoint(i, 7.0, -28.5766, 1923.8281, 18.0194)) return 1;
   return 0;
}
stock Update3D(vid, b)
{
   new string[256], Float:pos[3];
   GetVehiclePos(vid, pos[0], pos[1], pos[2]);
   if(vid < xvehicles)
   {
       if(_:Text3DVehicle[vid] == -1 || !_:Text3DVehicle[vid]) Text3DVehicle[vid] = Create3DTextLabel("!רכב זה הינו רכב מיוחד להשכרה בלבד", yellow, pos[0], pos[1], pos[2]+0.8, 8.0, 0, 0);
       Attach3DTextLabelToVehicle(Text3DVehicle[vid], vid, 0.0, 0.0, 0.8);
	   return 1;
   }
   if(!b && !strcmp(VehicleInfo[vid][CarOwner], "None", true))
   {
	   format(string, sizeof string, isHQVehicle(vid)? (".הינו רכב ששייך למפקדה %s - הרכב") : (".הינו רכב ששייך לזכות הציבור %s -הרכב"), VehicleInfo[vid][CarName]);
       if(_:Text3DVehicle[vid] == -1 || !_:Text3DVehicle[vid]) Text3DVehicle[vid] = Create3DTextLabel(string, red, pos[0], pos[1], pos[2]+0.9, 8.0, 0, 0);
       Attach3DTextLabelToVehicle(Text3DVehicle[vid], vid, 0.0, 0.0, 0.8);
	   Update3DTextLabelText(Text3DVehicle[vid], red, string);
   }
   if(VehicleInfo[vid][CarOwned] && strcmp(VehicleInfo[vid][CarOwner], "None", true))
   {
       if(VehicleInfo[vid][SaleV] > 0) format(string, sizeof string, "!%s$ - השחקן מציע אותו למכירה במחיר של  !%s - שייך ל ,%s - הרכב", VehicleInfo[vid][SaleV], VehicleInfo[vid][CarOwner], VehicleInfo[vid][CarName]);
	   else format(string, sizeof string, "!%s - שייך ל ,%s - הרכב", VehicleInfo[vid][CarOwner], VehicleInfo[vid][CarName]);
	   if(_:Text3DVehicle[vid] == -1 || !_:Text3DVehicle[vid]) Text3DVehicle[vid] = Create3DTextLabel(string, orange, pos[0], pos[1], pos[2]+0.9, 8.0, 0, 0);
	   Attach3DTextLabelToVehicle(Text3DVehicle[vid], vid, 0.0, 0.0, 0.8);
	   Update3DTextLabelText(Text3DVehicle[vid], orange, string);
   }
   if(b && !VehicleInfo[vid][CarOwned] && !strcmp(VehicleInfo[vid][CarOwner], "None", true))
   {
       format(string, sizeof string, "!$%d :ניתן לקניה במחיר של ,%s :רכב זה מסוג\n/Vehicle(/v) - פקודות רכב", VehicleInfo[vid][Price],VehicleInfo[vid][CarName]);
	   if(_:Text3DVehicle[vid] == -1 || !_:Text3DVehicle[vid]) Text3DVehicle[vid] = Create3DTextLabel(string, pink, pos[0], pos[1], pos[2]+0.9, 8.0, 0, 0);
	   Attach3DTextLabelToVehicle(Text3DVehicle[vid], vid, 0.0, 0.0, 0.9);
	   Update3DTextLabelText(Text3DVehicle[vid], green, string);
   }
   return 1;
}
function(Text:CreateStarTD( starnum ))
{
	new Text:tStar = TextDrawCreate( 503.5 - ( 18 * ( starnum - 7 ) ), 102.1, "]" );
	TextDrawColor          ( tStar, 0x906210FF );
	TextDrawBackgroundColor( tStar, 0x000000AA );
	TextDrawFont           ( tStar,          2 );
	TextDrawSetShadow      ( tStar,          0 );
	TextDrawSetProportional( tStar,       true );
	TextDrawLetterSize     ( tStar,  0.6,  2.4 );
	TextDrawAlignment      ( tStar,          3 );
	TextDrawSetOutline     ( tStar,          1 );
	return tStar;
}
function(DoInit())
{
	if (gme) DoInit();
	gme = false;
	for (new playerid = 0; playerid < MAX_PLAYERS; playerid++ ) SetPlayerWantedLevel(playerid, 0);
	tStar7  = CreateStarTD(7);
	tStar8  = CreateStarTD(8);
	tStar9  = CreateStarTD(9);
	tStar10 = CreateStarTD(10);
	tStar11 = CreateStarTD(11);
	tStar12 = CreateStarTD(12);
	tStar13 = CreateStarTD(13);
	tStar14 = CreateStarTD(14);
	tStar15 = CreateStarTD(15);
	SetTimer("Wlevel_UPD", 3000, true);
}
function(Wlevel_UPD())
{
   for(new playerid = 0; playerid < MAX_PLAYERS; playerid++ )
   {
       WLCheck(7);
       WLCheck(8);
       WLCheck(9);
       WLCheck(10);
       WLCheck(11);
       WLCheck(12);
       WLCheck(13);
       WLCheck(14);
       WLCheck(15);
   }
}
