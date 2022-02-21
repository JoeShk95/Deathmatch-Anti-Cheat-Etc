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
	Vunoccupied[MAX_VEHICLES];

OnPlayerConnect -
Vehicle_Info[playerid][CarID] = 0;
Vehicle_Info[playerid][OwnCar] = 0;
|
OnGameModeInit -
SetTimer("LoadFiles",4000,0);
|
OnPlayerEntervehicle
  new string[128], file[64];
  format(file,sizeof file,"Vehicle/%i.ini",GetPlayerVehicleID(playerid));
  if(vehicleid < xvehicles)
  {
       format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",vehicleid);
       SendClientMessage(playerid,COLOR_WHITE,"--- Rent Vehicle - רכב להשכרה ---");
       format(string,sizeof string, Vunoccupied[vehicleid]? (".%s :משכיר הרכב") : (".אין משכיר לרכב זה, אתה יכול/ה להשכיר את הרכב"),dini_Get(rent_file,"Owner"));
       SendClientMessage(playerid,0x16EB43FF,string);
       format(string,sizeof string,"%d$ :מחיר רכב זה ליום",PriceRentVehicle[vehicleid]);
       SendClientMessage(playerid,0x16EB43FF,string);
       format(string,sizeof string,"%i :איידי",vehicleid);
       SendClientMessage(playerid,0x16EB43FF,string);
       format(string,sizeof string,"%s :סוג רכב",VehiclesName[GetVehicleModel(vehicleid)-400]);
       SendClientMessage(playerid,0x16EB43FF,string);
       SendClientMessage(playerid,0x16EB43FF, RentInfo[playerid][CarID] == vehicleid? ("/RentHelp :אתה משכיר רכב זה כעת, על מנת לקבל עזרה עם המערכת השכרות") :("/RentCar [Days: 1-10] :על מנת להשכיר את הרכב בצע/י"));
       SendClientMessage(playerid,COLOR_WHITE,"-------------------------------------------------------");
       return 0;
  }
  if(GetPlayerVehicleID(playerid) >= VCount) return 0;
  if(VehicleInfo[vehicleid][CarOwned])
  {
      if(!strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner], false))
	  {
	     format(string, sizeof string,"!%s \"%s\" ברוך הבא לרכב שלך מסוג",VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
	     SendClientMessage(playerid,ORANGE,string);
	     if(VehicleInfo[vehicleid][SaleV] > 0 && VehicleInfo[vehicleid][PayTax] > 0) SendClientMessage(playerid,red,"> /StopSale :הרכב שלך, עדיין מוצע לקניה, על מנת להפסיק את מכירת הרכב בצע/י");
	     if(VehicleInfo[vehicleid][SaleV] > 0 && VehicleInfo[vehicleid][PayTax] < 1) SendClientMessage(playerid,red,"> /PayTax :לא שילמת מס' על הרכב שלך, אם לא תשלם, רכבך ימכר, אנא שלם");
      }
	  if(strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner], false) && strcmp(VehicleInfo[vehicleid][CarOwner],"None", true))
	  {
          format(string, sizeof string," • !ולכן לא ניתן לקנייה ,%s רכב זה הינו בבעלות [%s] • ",VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
          SendClientMessage(playerid,COLOR_PINK,string);
          if(VehicleInfo[vehicleid][SaleV] > 0)
          {
              format(string, sizeof string,VehicleInfo[vehicleid][PayTax] > 0? (" • .%s :בעלים [%s] :הצעה רכב זה מסוג • ") : (".%s :בעלים [%s] :הצעה ממס' הכנסה, רכב זה מסוג • "),VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
              SendClientMessage(playerid,COLOR_PINK,string);
              format(string, sizeof string,VehicleInfo[vehicleid][PayTax] > 0? (" • .[$%d] :הציע את הרכב שלו לציבור במחיר של כ") :(".[$%d] :המס' הכנסה מציע את הרכב שלו למכירה במחיר של • ") ,VehicleInfo[vehicleid][SaleV]);
              SendClientMessage(playerid,COLOR_PINK,string);
          }
	  }
  }
  if(!VehicleInfo[vehicleid][Buyable] && !strcmp(VehicleInfo[vehicleid][CarOwner], "None", true))
  {
    format(string, sizeof string," • !הינו רכב ציבורי שלא ניתן לקניה ,%s רכב זה • ",VehicleInfo[vehicleid][CarName]);
    error(playerid, string);
  }
  if(VehicleInfo[vehicleid][Buyable])
  {
    format(string, sizeof string, " • !$%d :ניתן לקניה במחיר של ,%s :רכב זה מסוג • ", VehicleInfo[vehicleid][Price],VehicleInfo[vehicleid][CarName]);
    SendClientMessage(playerid, lblue, string);
    format(string, sizeof string, "/BuyCar - :לקניה הרכב, בצע/י <~> /Car - :לפרטי הרכב, בצע/י");
    SendClientMessage(playerid, lblue, string);
  }
|
Vehicles()
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
        if(!getRentVehicleCount()) return 0;
		for(new i = 0; i < xvehicles+1; i++)
		{
		           format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",i);
			       new string[128], date[3];
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
	                     for(new o = o; o < GetMaxPlayers(); o++) if(i == RentInfo[o][CarID]) RentInfo[o][CarID] = 0;
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

/*
function(isAPlane(vid)) return vid == 592 || vid == 577 || vid == 511 || vid == 512 || vid == 593 || vid == 520 || vid == 553 || vid == 476 || vid == 519 || vid == 460 || vid == 513? 1 : 0;
function(isABoat(vid)) return vid == 472 || vid == 473 || vid == 493 || vid == 595 || vid == 484 || vid == 430 || vid == 453 || vid == 452 || vid == 446 || vid == 454? 1 : 0;
function(isAHeli(vid)) return vid == 548 || vid == 425 || vid == 417 || vid == 487 || vid == 488 ||vid == 497 ||vid == 563 || vid == 447 ||vid == 469? 1 : 0;
function(isAMoto(vid)) return vid == 522 || vid == 468 || vid == 463? 1 : 0;
*/
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
   if(IsAPlane(vid)) PriceRentVehicle[vid] = 6000;
   if(IsABoat(vid)) PriceRentVehicle[vid] = 5000;
   if(IsAMoto(vid)) PriceRentVehicle[vid] = 8000;
   if(!IsAPlane(vid) && !IsABoat(vid) && !IsAMoto(vid)) PriceRentVehicle[vid] = 8000;
   return 1;
}
OnPlayerCommmands -
	createCommand("/rentcar")
	{
        
   		new vid = GetPlayerVehicleID(playerid), rent_tmp[256],date[3];
   		format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",vid);
        rent_tmp = strtok(cmdtext,idx);
   		if(!IsPlayerInAnyVehicle(playerid)) return error(playerid,".אתה לא נמצא בשום רכב");
    	if(RentInfo[playerid][CarID] != 0) return error(playerid,".יש לך כבר רכב מושכר");
    	if(Vunoccupied[vid]) return error(playerid,!strcmp(dini_Get(rent_file,"Owner"),GetName(playerid),true)? (".רכב זה כבר מושכר על ידך") : (".רכב זה מושכר כבר על ידי מישהו אחר"));
    	if(!CarToRent[vid]) return error(playerid,".רכב זה אינו להשכרה");
    	if(!strlen(rent_tmp) || strval(rent_tmp) < 1 || strval(rent_tmp) > 10) return error(playerid,"Usage: /RentCar [Days: 1-10]");
    	new Days = strval(rent_tmp);
    	if(GetPlayerMoney(playerid) < PriceRentVehicle[vid]*Days)
		{
		    format(string,sizeof string,".%d - על מנת להשכיר רכב זה למספר ימים של כ",Days);
		    SendClientMessage(playerid,COLOR_ORANGE,string);
		    format(string,sizeof string,".%d$ :אתה צריך לפחות סכום כסף של כ",PriceRentVehicle[vid]*Days);
		    SendClientMessage(playerid,COLOR_YELLOW,string);
		    return 1;
		}
        Vunoccupied[vid] = 1;
	    RentInfo[playerid][CarID] = vid;
    	strmid(dini_Get(rent_file,"Owner") , GetName(playerid), 0, strlen(GetName(playerid)), 255);
    	dini_Set(rent_file, "Owner", GetName(playerid));
		format(string,sizeof string,".%d$ :שכרת רכב זה תמורת",PriceRentVehicle[vid]*Days);
		SendClientMessage(playerid,COLOR_ORANGE,string);
		format(string,sizeof string,".%s :סוג הרכב",VehiclesName[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
		SendClientMessage(playerid,COLOR_YELLOW,string);
		SendClientMessage(playerid,0x16EB43FF,"/RentHelp :על מנת לקבל עזרה מורכת על המערכת השכרה רכבים");
		LACY_GiveMoney(playerid,-PriceRentVehicle[vid]*Days);
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
		     SendClientMessage(playerid,COLOR_YELLOW,"!הפסקת את השכרת הרכב שלך בהצלחה");
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
		SendClientMessage(playerid,COLOR_YELLOW,"...עוד 5 שניות הרכב המושכר שלך יאופס, אנא המתן/י");
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
		for (new i = 0 ;i < GetMaxPlayers(); i++) if(i != playerid) SetVehicleParamsForPlayer(RentInfo[playerid][CarID],i, 0, 1);
		SendClientMessage(playerid,COLOR_ORANGE,".המכונית המושכרת שלך ננעלה בהצלחה");
		VLocked[RentInfo[playerid][CarID]] = 1;
		return 1;
	}
	createCommand("/runlockv")
	{
    	if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
		if(!VLocked[RentInfo[playerid][CarID]]) return error(playerid,".הרכב שלך פתוח כבר פתוח");
		for (new i = 0 ;i < GetMaxPlayers(); i++) if(i != playerid) SetVehicleParamsForPlayer(RentInfo[playerid][CarID],i, 0, 0);
		SendClientMessage(playerid,COLOR_ORANGE,".המכונית המושכרת שלך נפתחה בהצלחה");
		VLocked[RentInfo[playerid][CarID]] = 0;
		return 1;
	}
    createCommand("/rcallcar")
	{
		if(!RentInfo[playerid][CarID]) return error(playerid,".אין לך שום רכב מושכר");
		if(GetPlayerVehicleID(playerid) == RentInfo[playerid][CarID]) return error(playerid,".אתה נמצא ברכב המשוכר שלך");
		if(IsPlayerInAnyVehicle(playerid)) return error(playerid,".אנא צא מהרכב על מנת לזמן את הרכב המושכר שלך");
		for(new o = 0; o < GetMaxPlayers(); o++) if(IsPlayerInVehicle(o,RentInfo[playerid][CarID]))
		{
	    	GetPlayerPos(playerid,RentInfo[o][vPosv][0],RentInfo[o][vPosv][1],RentInfo[o][vPosv][2]);
	    	SetPlayerPos(o,RentInfo[o][vPosv][0]+3.0,RentInfo[o][vPosv][1]-1.0,RentInfo[o][vPosv][2]);
	    	format(string,sizeof string,".שיגר אליו את הרכב שלו, הליכה נעימה %s - השחקן",GetName(playerid));
	    	SendClientMessage(o,COLOR_WHITE,string);
		}
		GetPlayerPos(playerid,RentInfo[playerid][vPosv][0],RentInfo[playerid][vPosv][1],RentInfo[playerid][vPosv][2]);
		PutPlayerInVehicle(playerid,RentInfo[playerid][CarID],0);
		SetTimerEx("BackVehicleToPos",800,0,"i",playerid);
		format(string,sizeof string,".המושכר שלך בהצלחה %s - שיגרת את הרכב ה",VehicleName[RentInfo[playerid][CarID]]);
		SendClientMessage(playerid,COLOR_ORANGE,string);
		SendClientMessage(playerid,COLOR_YELLOW,"/RResetCar :במידה והרכב לא הגיע, אפס את הרכב המושכר שלך");
		return 1;
	}
	createCommand("/RentList")
	{
		new count_vehicle = 0, date[3], dstring[128], days_e = 0;
    	if(!getRentVehicleCount()) return error(playerid,".אף אחד בשרת לא השכיר רכב");
    	format(string,sizeof string,"--- %d :רכבים המושכרים בשרת ---",getRentVehicleCount());
    	SendClientMessage(playerid,WHITE,string);
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
if(!strcmp(cmd, "/carinfo", true))
{
  if(vehicleid < xvehicles)
  {
       format(rent_file,sizeof rent_file,"/Rent/Car%d.ini",vehicleid);
       SendClientMessage(playerid,WHITE,"--- :רכב להשכרה ---");
       format(string,sizeof string,Vunoccupied[vehicleid]? (" •.%s :משכיר הרכב") : (" •.אין משכיר לרכב זה, אתה יכול/ה להשכיר את הרכב"),dini_Get(rent_file,"Owner"));
       SendClientMessage(playerid,0x16EB43FF,string);
       format(string,sizeof string," • %d$ :מחיר רכב זה ליום",PriceRentVehicle[vehicleid]);
       SendClientMessage(playerid,0x16EB43FF,string);
       format(string,sizeof string," • %i :איידי",vehicleid);
       SendClientMessage(playerid,0x16EB43FF,string);
       format(string,sizeof string," • %s :סוג רכב",VehiclesName[GetVehicleModel(vehicleid)-400]);
       SendClientMessage(playerid,0x16EB43FF,string);
       SendClientMessage(playerid,0x16EB43FF,RentInfo[playerid][CarID] == vehicleid? ("/RentHelp :אתה משכיר רכב זה כעת, על מנת לקבל עזרה עם המערכת השכרות") :("/RentCar [Days: 1-10] :על מנת להשכיר את הרכב בצע/י"));
       return 1;
  }
  if(VehicleInfo[vehicleid][CarOwned])
  {
      if(strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner],true))
	  {
            format(string, sizeof string,"----- [ %s :פרטים עבור הרכב] -----",VehicleInfo[vehicleid][CarName]);
			SendClientMessage(playerid,WHITE,string);
			format(string, sizeof string," • .%s - הרכב אשר את/ה נמצא בוא הוא הרכב שלך",VehicleInfo[vehicleid][CarName]);
			SendClientMessage(playerid,0x00FFFFAA,string);
			format(string, sizeof string," • .%d :האיידי של הרכב",GetVehicleModel(GetPlayerVehicleID(playerid)));
			SendClientMessage(playerid,0x00FFFFAA,string);
			format(string, sizeof string," • .%d :האיידי של הרכב במוד",GetPlayerVehicleID(playerid));
			SendClientMessage(playerid, yellow,string);
			format(string, sizeof string," • .%d$ :תשלום מס' על הרכב",VehicleInfo[vehicleid][MoneyTax]);
			SendClientMessage(playerid, yellow,string);
			if(VehicleInfo[vehicleid][PayTax] > 1)
			{
			  format(string, sizeof string, " • .%d :'מספר ימים שנשארו עד לשילום המס",VehicleInfo[vehicleid][PayTax]);
			  SendClientMessage(playerid,COLOR_ORANGE, string);
            }
		    if(VehicleInfo[vehicleid][SaleV] > 0 && VehicleInfo[vehicleid][PayTax] > 1) SendClientMessage(playerid,COLOR_ORANGE," • /StopSale :הרכב שלך, עדיין מוצע לקניה, על מנת להפסיק את מכירת הרכב בצע/י");
		    else if(VehicleInfo[vehicleid][PayTax] < 1) SendClientMessage(playerid,COLOR_ORANGE," • /PayTax :הרכב שלך מוצע למכירה בגלל שלא שילמת מס' על מנת לשלם בצע/י");
	  }
	  else if(strcmp(GetName(playerid),VehicleInfo[vehicleid][CarOwner],true) == 1)
	  {
	      if(VehicleInfo[vehicleid][SaleV] != 0)
		  {
			   format(string, sizeof string,"----- [ %s :פרטים עבור הרכב] -----",VehicleInfo[vehicleid][CarName]);
			   SendClientMessage(playerid,WHITE,string);
			   format(string, sizeof string," • .$%d :שים לב, בעל הרכב הציע על הרכב מחיר של כ",VehicleInfo[vehicleid][SaleV]);
			   SendClientMessage(playerid,0x00FFFFAA,string);
			   format(string, sizeof string," • .%s :הבעלים",VehicleInfo[vehicleid][CarOwner]);
			   SendClientMessage(playerid,0x00FFFFAA,string);
			   SendClientMessage(playerid,COLOR_YELLOW," • /BuyCar :לקניית הרכב בצע/י");
			   format(string, sizeof string," • .%d :האיידי של הרכב",GetVehicleModel(GetPlayerVehicleID(playerid)));
			   SendClientMessage(playerid,COLOR_YELLOW, string);
			   format(string, sizeof string," • .%d :האיידי של הרכב במוד",GetPlayerVehicleID(playerid));
			   SendClientMessage(playerid,COLOR_YELLOW, string);
			   format(string, sizeof string," • .%d$ :תשלום מס' על הרכב",VehicleInfo[vehicleid][MoneyTax]);
			   SendClientMessage(playerid,COLOR_YELLOW, string);
			   format(string, sizeof string," • .%d :'מספר ימים שנשארו עד לשילום המס",VehicleInfo[vehicleid][PayTax]);
			   SendClientMessage(playerid,COLOR_YELLOW, string);
		  }
		  else
		  {
		  format(string, sizeof string," • .ולכן לא ניתן לקנייה %s רכב זה הינו בבעלות [%s] • ",VehicleInfo[vehicleid][CarOwner],VehicleInfo[vehicleid][CarName]);
		  SendClientMessage(playerid,lblue,string);
	  }
	}
  }
  else if(!VehicleInfo[vehicleid][Buyable])
  {
     format(string, sizeof string," • !לא ניתן לקניה, רכב זה הוא ציבורי ,%s :רכב זה • ",VehicleInfo[vehicleid][CarName], VehicleInfo[vehicleid][CarOwner]);
	 SendClientMessage(playerid,lblue,string);
  }
  else if(VehicleInfo[vehicleid][Buyable])
  {
      format(string, sizeof string,"----- [ %s :פרטים עבור הרכב] -----",VehicleInfo[vehicleid][CarName]);
      SendClientMessage(playerid, white,string);
      format(string, sizeof string," • .$%d :הרכב פנוי לרכישה, מחיר הרכב",VehicleInfo[vehicleid][Price]);
      SendClientMessage(playerid,0x16EB43FF,string);
      SendClientMessage(playerid,0x16EB43FF," • /BuyCar :לקניית הרכב בצע/י");
      format(string, sizeof string," • .%d :האיידי של הרכב",GetVehicleModel(GetPlayerVehicleID(playerid)));
      SendClientMessage(playerid,0x16EB43FF, string);
      format(string, sizeof string," • .%d :האיידי של הרכב במוד",GetPlayerVehicleID(playerid));
      SendClientMessage(playerid,0x16EB43FF, string);
      format(string, sizeof string," • .%d$ :תשלום מס' על הרכב",VehicleInfo[vehicleid][MoneyTax]);
      SendClientMessage(playerid,0x16EB43FF, string);
  }
  return 1;
}
if(!strcmp(cmd, "/sellcar", true))
{
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
	   dini_IntSet(GetPlayerFile(playerid),"Vehicle_ID",0);
	   SendClientMessage(playerid, orange, "  Updates: !מכרת הרכב שלך, מחיר הרכב הועבר לחשבון בנק שלך");
	   dini_IntSet(GetPlayerFile(playerid),"Bank",PlayerInfo[playerid][Bank]+VehicleInfo[vehicleid][Price] / 2);
	   dini_Set(GetPlayerFile(playerid),"Car","None");
   }
   return 1;
}
if(!strcmp(cmd, "/PayTax", true))
{
    if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין לך שום רכב בבעלותך");
	if(VehicleInfo[idcar][PayTax] > 5) return error(playerid,"/Car - אינך צריך עוד לשלם מס', לפרטים בצע/י");
	format(FileCar,sizeof(FileCar),"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
	if(GetPlayerMoney(playerid) < VehicleInfo[idcar][MoneyTax])
	{
        format(string,sizeof string,"!%i$ :אין לך מספיק כסף כדי לשלם את המס', תשלום המס' הינו",VehicleInfo[idcar][MoneyTax]);
		SendClientMessage(playerid,COLOR_ORANGE,string);
		return 1;
    }
	_GivePlayerMoney(playerid,-VehicleInfo[Vehicle_Info[playerid][CarID]][MoneyTax]);
    VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] = 14;
    VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] = 0;
	dini_IntSet(FileCar,"SaleV",0);
	dini_IntSet(FileCar,"PayTax",14);
	format(string, sizeof string," • !%d :שילמת מס' על הרכב בהצלחה, תשלום הבא בעוד מספר ימים של כ • ",VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax]);
	SendClientMessage(playerid, orange, string);
	SendClientMessage(playerid, yellow, "!רכבך לא מוצע יותר למכירה, תהנה עם רכבך המחודש");
	return 1;
}
if(!strcmp(cmd, "/Buycar", true))
{
   new vehicleid = GetPlayerVehicleID(playerid);
   format(file, sizeof file,"Vehicle/%i.ini", vehicleid);
   if(GetPlayerInterior(playerid) > 0 || GetPlayerVirtualWorld(playerid) > 0) return error(playerid,".לא תוכל לקנות רכב זה");
   if(CarToRent[car]) return error(playerid,".רכב זה הינו להשכרה ולא למכירה");
   if(!dini_Exists(file))
   {
      if(!VehicleInfo[vehicleid][SaleV])
	  {
          if(strcmp(VehicleInfo[vehicleid][CarOwner], "None", true)) return error(playerid,strcmp(VehicleInfo[vehicleid][CarOwner], GetName(playerid), false)? (".המכונית הזאתי שייכת למישהו אחר ") : (".המכונית הזאתי כבר שייכת לך"));
          if(GetPlayerMoney(playerid) < VehicleInfo[vehicleid][Price]) return error(playerid,".אין לך מספיק כסף בשביל ליקנות את המכונית הזאתי ");
          if(!(IsPlayerInAnyVehicle(playerid))) return error(playerid,".את/ה צריך להיות במכונית שאת/ה רוצה ליקנות ");
          if(GetPlayerVehicleID(playerid) >= VCount) return error(playerid,".זהו רכב ציבורי, אינו ניתן לקניה");
          if(VehicleInfo[vehicleid][CarOwned]) return error(playerid,".המכונית הזאתי שייכת למישהו אחר ");
          if(Vehicle_Info[playerid][CarID] > 0) return error(playerid,".יש לך כבר מכונית");
          if(!VehicleInfo[vehicleid][Buyable])
          {
              format(string , sizeof string," • !הינו רכב ציבור שלא ניתן למכירה ,%s הרכב • ",VehicleInfo[vehicleid][CarName]);
			  error(playerid,string);
			  return 1;
          }
		  VehicleInfo[vehicleid][PayTax] = 14;
		  dini_IntSet(file,"PayTax",14);
		  dini_IntSet(file,"CarOwned",1);
		  dini_Set(file,"CarOwner",GetName(playerid));
		  dini_IntSet(file,"Buyable",0);
		  dini_Set(file,"CarOwner",GetName(playerid));
		  VehicleInfo[vehicleid][CarOwned] = 1;
		  strmid(VehicleInfo[vehicleid][CarOwner], GetName(playerid), 0, strlen(GetName(playerid)), 255);
		  VehicleInfo[vehicleid][Buyable] = 0;
		  Vehicle_Info[playerid][CarID] = GetPlayerVehicleID(playerid);
		  Vehicle_Info[playerid][OwnCar] = 1;
		  dini_IntSet(GetPlayerFile(playerid),"Vehicle_ID",Vehicle_Info[playerid][CarID]);
		  format(string,sizeof string," • /Vehicle :מזל טוב, על מנת לקבל עזרה !%s :קנית את הרכב ,%s שלום לך • ",VehNames[GetVehicleModel(vehicleid)-400],GetName(playerid));
		  SendClientMessage(playerid, green, string);
		  _GivePlayerMoney(playerid,-VehicleInfo[vehicleid][Price]);
		  return 1;
      }
      if(VehicleInfo[vehicleid][SaleV] > 0)
      {
		  new id = GetPlayerID(dini_Get(file, "CarOwner");
          if(GetPlayerMoney(playerid) < VehicleInfo[vehicleid][SaleV]) return error(playerid,".אין לך מספיק כסף בשביל ליקנות את המכונית הזאתי ");
		  if(!(IsPlayerInAnyVehicle(playerid))) return error(playerid,".את/ה צריך להיות במכונית שאת/ה רוצה ליקנות ");
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
		  dini_IntSet(string, "Bank", dini_Int(string,"Bank")+VehicleInfo[car][SaleV]);
		  dini_IntSet(getPlayerFile(playerid, _filestats), "Vehicle_ID", 0);
		  dini_IntSet(file,"PayTax",14);
		  dini_IntSet(file,"SaleV",0);
		  dini_IntSet(file,"CarOwned",1);
		  dini_IntSet(file,"Buyable", 0);
		  dini_Set(file,"CarOwner",GetName(playerid));
		  VehicleInfo[vehicleid][CarOwned] = 1;
   		  VehicleInfo[car][SaleV] = 0;
		  VehicleInfo[car][PayTax] = 14;
		  VehicleInfo[vehicleid][Buyable] = 0;
		  Vehicle_Info[playerid][CarID] = GetPlayerVehicleID(playerid);
		  Vehicle_Info[playerid][OwnCar] = 1;
		  dini_IntSet(GetPlayerFile(playerid),"Vehicle_ID",Vehicle_Info[playerid][CarID]);
		  format(string , sizeof string," • /Vehicle :מזל טוב, לקבלת עזרה ,%s קנית את הרכב ,%s שלום לך",VehNames[GetVehicleModel(vehicleid)-400],GetName(playerid));
		  SendClientMessage(playerid,lblue,string);
		  _GivePlayerMoney(playerid, -VehicleInfo[car][SaleV]);
		  strmid(VehicleInfo[vehicleid][CarOwner], GetName(playerid), 0, strlen(GetName(playerid)), 255);
		  return 1;
      }
   }
   return 1;
}
if(!strcmp(cmd,"/setprice",true))
{
   new anOcmd[256];
   anOcmd = strtok(cmdtext, idx);
   format(string,sizeof string,"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
   if(strval(anOcmd) > 100000000 || strval(anOcmd) < 1) return SendClientMessage(playerid, white, "Usage: /SetPrice [1$ - 1,000,000$]");
   if(Vehicle_Info[playerid][CarID] == 0) return error(playerid,".אין בבעלותך שום רכב");
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/PayTax :את/ה לא יכול/ה לעצור את מכירת הרכב, לא שילמת מס' על הרכב, על מנת לשלם");
   format(FileCar,sizeof(FileCar),"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
   if(Vehicle_Info[playerid][CarID] == 0) return error(playerid,".אין לך שום רכב בבעלותך");
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] > 0) return error(playerid,"/StopSale - הרכב שלך כבר מוצע למכירה");
   dini_IntSet(FileCar,"SaleV",strval(anOcmd));
   VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] = dini_Int(FileCar,"SaleV");
   format(string , sizeof string," • !%d$ - הצעת את הרכב שלך לציבור במחיר של כ • ",strval(anOcmd));
   SendClientMessage(playerid, yellow, string);
   SendClientMessage(playerid, orange,"/StopSale :על מנת לעצור את מכירת הרכב בצע/י");
   return 1;
}



if(strcmp(cmd,"/stopsale",true) == 0)
{
   if(!Vehicle_Info[playerid][CarID]) return error(playerid,".אין בבעלותך שום רכב");
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/PayTax - לפני תשתמש בפקודה זאת תשלם אגרה על הרכב");
   format(string,sizeof string,"Vehicle/%i.ini", Vehicle_Info[playerid][CarID]);
   if(Vehicle_Info[playerid][CarID] == 0) return error(playerid,".אין לך שום רכב בבעלותך");
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] < 1) return error(playerid,".הרכב שלך אינו מוצע לרכישה");
   dini_IntSet(string,"SaleV",0);
   VehicleInfo[Vehicle_Info[playerid][CarID]][SaleV] = 0;
   SendClientMessage(playerid,COLOR_ORANGE,".הפסקת את מכירת הרכב שלך");
   return 1;
}


//==============================================================================
if(!strcmp(cmd,"/callcar", true))
{
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][CarOwned] != 1 && Vehicle_Info[playerid][OwnCar] != 1) return error(playerid,".אין בבעלותך שום רכב");
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/PayTax - לפני תשתמש בפקודה זאת תשלם אגרה על הרכב");
   if(GetPlayerInterior(playerid) != 0) return error(playerid,".אתה לא יכול לזמן את הרכב שלך לתוך מקום סגור");
   for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerInVehicle(i, Vehicle_Info[playerid][CarID]))
   {
      RemovePlayerFromVehicle(i);
      format(string , sizeof string,"  Updates: !זימן את הרכב שלו, הליכה נעימה ,%s", GetName(playerid));
      SendClientMessage(i, orange,string);
   }
   GetPlayerPos(playerid, Pos[playerid][0], Pos[playerid][1], Pos[playerid][2]);
   PutPlayerInVehicle(playerid, Vehicle_Info[playerid][CarID], 0);
   GetVehicleZAngle(GetPlayerVehicleID(playerid), Angle[playerid]);
   SetTimerEx("TeleCar",1000,0,"i",playerid);
   SendClientMessage(playerid,COLOR_YELLOW,".שיגרת את הרכב שלך בהצלחה");
   SendClientMessage(playerid,COLOR_ORANGE,"/ResetCar :זימנה את הרכב שלך בהצלחה, אם הוא לא הגיע, בצע/י");
   return 1;
}
//=======================


if(!strcmp(cmd, "/ResetCar", true))
{
   new vehicleid = GetPlayerVehicleID(playerid);
   if(Vehicle_Info[playerid][CarID] == 0) return error(playerid,".אין בבעלותך שום רכב");
   if(VehicleInfo[Vehicle_Info[playerid][CarID]][PayTax] < 1) return error(playerid,"/PayTax - לפני תשתמש בפקודה זאת תשלם אגרה על הרכב");
   if((IsPlayerInAnyVehicle(playerid))) return error(playerid,".אנא צא/י מהרכב על מנת לאפס אותו");
   if(strcmp(GetName(playerid), VehicleInfo[vehicleid][CarOwner], true) != 0)return error(playerid,".זו לא המכונית שלך אז אינך יכול/ה לתקן אותה");
   SetVehicleToRespawn(Vehicle_Info[playerid][CarID]);
   SetVehicleHealth(Vehicle_Info[playerid][CarID],1000.0);
   SendClientMessage(playerid,COLOR_YELLOW,"...עוד 5 שניות הרכב שלך יאופס, אנא המתן/י");
   SetTimerEx("RepairCar",5000, false,"i",playerid);
   GetVehiclePos(Vehicle_Info[playerid][CarID],vPos[playerid][0],vPos[playerid][1],vPos[playerid][2]);
   SetPlayerPos(playerid, 346.8638, 309.1008, 999.1557);
   SetPlayerFacingAngle(playerid, 180);
   SetPlayerInterior(playerid,6);
   TogglePlayerControllable(playerid,0);
   return 1;
}
functio(Tax())
{
    new dbs[128], dbs2[128], datep[3], string[256];
    getdate(datep[2],datep[1],datep[0]);
	format(dbs2,sizeof dbs2,"%d.%d.%d",datep[0],datep[1],datep[2]);
    if(DaysBetweenDates(dbs,dbs2) > 0)
    {
	    for (new car = 1; car < VCount; car++)
	    {
		    format(file,sizeof(file),"Vehicle/%i.ini",car);
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
	for(new i = 0; i < MAX_PLAYERS i++)
	{
        new idcar = Vehicle_Info[i][CarID]
        if(VehicleInfo[idcar][PayTax] < 1 && idcar != 0)
        {
           format(string, sizeof string,"  Updats: !%d$ :שים לב, אתה חייב לשלם מס' על הרכב שלך, עליך לשלם",VehicleInfo[idcar][MoneyTax]);
           SendClientMessage(i, orange,string);
           SendClientMessage(i, yellow,"/PayTax - אם לא תשלם על המס' הרכב שלך ימכר ללא הודעה מוקדמת, על מנת לשלם");
        }
	}
	return 1;
}
function(LoadFiles())
{

	new VPrice[MAX_VEHICLES];
	VCount = CreateVehicle(411,0,0,0,0,0,0,-1);
	DestroyVehicle(VCount);
	printf(" || - Car In The Mode %d || - Car System - Roy. ",VCount-1);
	for (new car = 1; car < VCount; car++)
	{
		format(file,sizeof(file),"Vehicle/%i.ini",car);
		if(!dini_Exists(file))
		{
			  dini_Create(file); CreateCount++;
			  dini_IntSet(file,"CarID",car);
			  dini_Set(file,"CarName",VehNames[GetVehicleModel(car)-400] );
			  dini_IntSet(file,"CarModel",GetVehicleModel(car));
		      dini_IntSet(file,"CarOwned",0);
		      dini_Set(file,"CarOwner","None");
		      dini_IntSet(file,"Buyable",1);
		      dini_IntSet(file,"Price",200000);
		      dini_IntSet(file,"LevelCar",0);
		      dini_IntSet(file,"SaleV",0);
		      dini_IntSet(file,"PayTax",14);
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
			  VehicleInfo[car][MoneyTax] = random(5000)+1000;
			  dini_IntSet(file,"MoneyTax",VehicleInfo[car][MoneyTax]);
			  VPrice[car] = 100000;
              for(new v=0; v < sizeof(boat); v++) if(VehicleInfo[car][CarModel] == boat[v][0]) VPrice[car] = 100000;
              for(new v=0; v < sizeof(bike); v++) if(VehicleInfo[car][CarModel] == bike[v][0]) VPrice[car] = 260000;
              for(new v=0; v < sizeof(plane); v++) if(VehicleInfo[car][CarModel] == plane[v][0]) VPrice[car] = 150000;
              for(new v=0; v < sizeof(expensive); v++) if(VehicleInfo[car][CarModel] == expensive[v][0]) VPrice[car] = 200000;
              for(new v=0; v < sizeof(Vexpensive); v++) if(VehicleInfo[car][CarModel] == Vexpensive[v][0]) VPrice[car] = 250000;
			  VehicleInfo[car][Price] = VPrice[car];
			  dini_IntSet(file,"Price",VehicleInfo[car][Price]);
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
			  if(dini_Int(file,"CarOwned")) printf("           %d       Owner: %s",car,VehicleInfo[car][CarOwner]);

		}
	}
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) OnPlayerConnect(i);
}
//==============================================================================
function(SaveFiles())
{
    for (new car = 1; car < VCount; car++)
	{
         format(file,sizeof(file),"Vehicle/%i.ini",car);
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
   SetVehicleZAngle(GetPlayerVehicleID(playerid), Angle[playerid]);
   SetCameraBehindPlayer(playerid);
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
}
new count_v = 1;
stock AddStaticZVehicle(b,modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z,Float:spawn_angle, color1, color2)
{
  AddStaticVehicle(modelid, Float:spawn_x, Float:spawn_y, Float:spawn_z,Float:spawn_angle, color1, color2);
  format(file,sizeof(file),"Vehicle/%i.ini",count_v);
  count_v++;
  CarToRent[count_v] = 0;
  if(dini_Exists(file))
  {
	   dini_IntSet(file,"Buyable",b);
	   VehicleInfo[count_v][Buyable] = b;
  }
  else
  {
       VCount++;
       format(file,sizeof(file),"Vehicle/%i.ini",VCount);
	   dini_Create(file);
	   dini_IntSet(file,"CarID",VCount);
	   dini_Set(file,"CarName",VehNames[GetVehicleModel(VCount)-400] );
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
	   VehicleInfo[VCount][MoneyTax] = random(9000)+1000;
	   dini_IntSet(file,"MoneyTax",VehicleInfo[VCount][MoneyTax]);
  }
  return 1;
}

