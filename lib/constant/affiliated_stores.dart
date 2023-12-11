import 'package:google_maps_flutter/google_maps_flutter.dart';

List<AfiliatedStore> afiliatedStoresList = [
  AfiliatedStore(
      id: "cX9aQZhmDn",
      name: "Night Sunrise",
      address: "東京都杉並区高円寺南1-2-3",
      location: const LatLng(
        35.705,
        39.649,
      )),
  AfiliatedStore(
      id: "pS6G0K7A8V",
      name: "Neon",
      address: "東京都杉並区阿佐ヶ谷北4-5-6",
      location: const LatLng(35.704, 139.635)),
  AfiliatedStore(
      id: "Pz1WpY3NbK",
      name: "Club Breeze",
      address: "東京都立川市錦町1-1-1",
      location: const LatLng(35.699, 139.407)),
  AfiliatedStore(
      id: "LdFs2W3FsA",
      name: "ナイトStar",
      address: "東京都立川市曙町2-2-2",
      location: const LatLng(35.698, 139.415)),
  AfiliatedStore(
      id: "1IgEyjXGoi",
      name: "Club Neon",
      address: "東京都武蔵野市吉祥寺本町3-3-3",
      location: const LatLng(35.703, 139.579)),
  AfiliatedStore(
      id: "KpAhRUCG4q",
      name: "Star",
      address: "東京都武蔵野市中町",
      location: const LatLng(35.718, 139.566)),
  AfiliatedStore(
      id: "SbdpRgfs9P",
      name: "Bar Shadow",
      address: "東京都三鷹市新川5-5-5",
      location: const LatLng(35.684, 139.559)),
  AfiliatedStore(
      id: "1yKgydG3hw",
      name: "バーEcho",
      address: "東京都三鷹市井の頭6-6-6",
      location: const LatLng(35.683, 139.574)),
  AfiliatedStore(
      id: "wO19tbXcgh",
      name: "Club Shadow",
      address: "東京都青梅市新町1-7-7",
      location: const LatLng(35.788, 139.276)),
  AfiliatedStore(
      id: "FvMhqUu47N",
      name: "ラウンジShadow",
      address: "東京都青梅市河辺町8-8-8",
      location: const LatLng(35.785, 139.290)),
  AfiliatedStore(
      id: "qekdso0C14",
      name: "Lounge Shine",
      address: "東京都府中市宮町9-9-9",
      location: const LatLng(35.672, 139.480)),
  AfiliatedStore(
      id: "6w3Q6vbsHu",
      name: "ラウンジNeon",
      address: "東京都府中市緑町10-10-10",
      location: const LatLng(35.663, 139.468)),
  AfiliatedStore(
      id: "PVKfbWeZVm",
      name: "Disco Star",
      address: "東京都昭島市昭和町11-11-11",
      location: const LatLng(35.714, 139.353)),
  AfiliatedStore(
      id: "R53YI5m2J2",
      name: "バーStar13",
      address: "東京都昭島市松原町12-12-12",
      location: const LatLng(35.708, 139.361)),
  AfiliatedStore(
      id: "ekt6x6X3Oe",
      name: "Disco Glow",
      address: "東京都調布市布田13-13-13",
      location: const LatLng(35.652, 139.541)),
  AfiliatedStore(
      id: "Wu17Ab5NdF",
      name: "ナイトBreeze",
      address: "東京都調布市国領町14-14-14",
      location: const LatLng(35.646, 139.546)),
  AfiliatedStore(
      id: "uP3s5oDQt9",
      name: "クラブShine",
      address: "東京都町田市原町田15-15-15",
      location: const LatLng(35.543, 139.445)),
  AfiliatedStore(
      id: "5WfjKvGhR4",
      name: "ナイトMoon",
      address: "東京都町田市金森16-16-16",
      location: const LatLng(35.552, 139.468)),
  AfiliatedStore(
      id: "H1sn7xZVXC",
      name: "Disco Breeze",
      address: "東京都小金井市本町5-17-17",
      location: const LatLng(35.701, 139.506)),
  AfiliatedStore(
      id: "MfLdB2CpeB",
      name: "ラウンジBreeze",
      address: "東京都小金井市梶野町18-18-18",
      location: const LatLng(35.708, 139.524)),
  AfiliatedStore(
      id: "GnAeVYQ6Kd",
      name: "ナイトGlow",
      address: "東京都小平市花小金井19-19-19",
      location: const LatLng(35.728, 139.523)),
  AfiliatedStore(
      id: "CMV9MXfSAj",
      name: "Night Echo",
      address: "東京都小平市小川東町20-20-20",
      location: const LatLng(35.736, 139.481)),
  AfiliatedStore(
      id: "T8bGALp24a",
      name: "ディスコStar",
      address: "東京都日野市日野本町21-21-21",
      location: const LatLng(35.673, 139.394)),
  AfiliatedStore(
      id: "d3kUqO3cjy",
      name: "Night Echo 32",
      address: "東京都日野市多摩平2-22-22",
      location: const LatLng(35.660, 139.408)),
  AfiliatedStore(
      id: "VFL55DSW9s",
      name: "Bar Mirage ",
      address: "東京都東村山市本町23-23-23",
      location: const LatLng(35.754, 139.468)),
  AfiliatedStore(
      id: "TEWKhtJsYm",
      name: "Night Moon",
      address: "東京都東村山市青葉町24-24-24",
      location: const LatLng(35.759, 139.477)),
  AfiliatedStore(
      id: "UurVHzfI5Z",
      name: "バーGlow27",
      address: "東京都国分寺市本町25-25-25",
      location: const LatLng(35.699, 139.481)),
  AfiliatedStore(
      id: "uDwitjp1ZD",
      name: "Disco Star 26",
      address: "東京都国分寺市東元町26-26-26",
      location: const LatLng(35.706, 139)),
  AfiliatedStore(
      id: "ysM8z3pPXs",
      name: "クラブSunrise25",
      address: "東京都国立市中1-27-27",
      location: const LatLng(35.6830, 139.4425)),
  AfiliatedStore(
      id: "QEWxsXiFb4",
      name: "Lounge Sunrise 24",
      address: "東京都国立市西2-28-28",
      location: const LatLng(35.6797, 139.4285)),
  AfiliatedStore(
      id: "eACGRRdVYk",
      name: "ラウンジShine23",
      address: "東京都福生市福生29-29-29",
      location: const LatLng(35.7380, 139.3266)),
  AfiliatedStore(
      id: "94BuWZrt97",
      name: "Glow 22",
      address: "東京都福生市東町30-30-30",
      location: const LatLng(35.7428, 139.3363)),
  AfiliatedStore(
      id: "frQArZ0S00",
      name: "ラウンジGlow21",
      address: "東京都狛江市和泉本町31-31-31",
      location: const LatLng(35.6205, 139.5787)),
  AfiliatedStore(
      id: "eihT1Xii3i",
      name: "Night Shine 20",
      address: "東京都狛江市中和泉32-32-32",
      location: const LatLng(35.6246, 139.5828)),
  AfiliatedStore(
      id: "BvHdFQ7HBD",
      name: "ar Shadow",
      address: "東京都東大和市桜が丘33-33-33",
      location: const LatLng(35.7450, 139.4260)),
  AfiliatedStore(
      id: "79oQ8Lvt49",
      name: "Breeze15",
      address: "東京都東大和市清36-36-36",
      location: const LatLng(35.7518, 139.4336)),
  AfiliatedStore(
      id: "unYxwYvrEW",
      name: "ar Shadow",
      address: "東京都清瀬市松山37-37-37",
      location: const LatLng(35.7851, 139.5263)),
  AfiliatedStore(
      id: "gBIuWMCDso",
      name: "Club Breeze",
      address: "東京都清瀬市旭が丘38-38-38",
      location: const LatLng(35.7793, 139.5188)),
  AfiliatedStore(
      id: "SqeP2QrUcX",
      name: "Breeze15",
      address: "東京都東久留米市本",
      location: const LatLng(35.7540, 139.5293)),
  AfiliatedStore(
      id: "TXby22Rkxt",
      name: "ar Shadow",
      address: "東京都足立区西新井1-2-3",
      location: const LatLng(35.7839, 139.7903)),
  AfiliatedStore(
      id: "9uyrZiQjUX",
      name: "Club Breeze",
      address: "東京都荒川区荒川7-8-9",
      location: const LatLng(35.7375, 139.7834)),
  AfiliatedStore(
      id: "dt4VmPabLy",
      name: "Breeze15",
      address: "東京都板橋区志村3-4-5",
      location: const LatLng(35.7781, 139.6819)),
  AfiliatedStore(
      id: "aGmBI02xy7",
      name: "Club Breeze",
      address: "東京都江戸川区小岩6-7-8",
      location: const LatLng(35.7335, 139.8814)),
  AfiliatedStore(
      id: "hB4m6gVd1H",
      name: "Breeze15",
      address: "東京都大田区羽田9-10-11",
      location: const LatLng(35.5493, 139.7536)),
  AfiliatedStore(
      id: "4hDQYLUqYs",
      name: "Club Breeze",
      address: "東京都葛飾区新小岩12-13-14",
      location: const LatLng(35.7166, 139.8580)),
  AfiliatedStore(
      id: "zKezbTt5AM",
      name: "Disco Star 12",
      address: "東京都北区王子15-16-17",
      location: const LatLng(35.7536, 139.7369)),
  AfiliatedStore(
      id: "UJCEXhJRri",
      name: "Breeze15",
      address: "東京都江東区豊洲18-19-2011",
      location: const LatLng(35.6552, 139.7966)),
  AfiliatedStore(
      id: "VrVpQGjlyw",
      name: "Club Breeze",
      address: "東京都品川区五反田21-22-23",
      location: const LatLng(35.6256, 139.7234)),
  AfiliatedStore(
      id: "stS5zUEvJ7",
      name: "ar Shadow",
      address: "東京都渋谷区代官山4-5-6",
      location: const LatLng(35.6484, 139.7030)),
  AfiliatedStore(
      id: "Ftk5i6M60E",
      name: "Club Breeze",
      address: "東京都渋谷区原宿7-8-9",
      location: const LatLng(35.6693, 139.7027)),
  AfiliatedStore(
      id: "iaGzwGmpMb",
      name: "ar Shadow",
      address: "東京都新宿区早稲田10-11-12",
      location: const LatLng(35.7094, 139.7217)),
  AfiliatedStore(
      id: "KH0h4NYQ83",
      name: "Breeze15",
      address: "東京都新宿区四谷13-14-15",
      location: const LatLng(35.6874, 139.7293)),
  AfiliatedStore(
      id: "7m49jqveWV",
      name: "Disco Star 12",
      address: "東京都中央区月島16-17-18",
      location: const LatLng(35.6627, 139.7842)),
  AfiliatedStore(
      id: "zomdsGDDIR",
      name: "William",
      address: "東京都中央区築地市場19-20-21",
      location: const LatLng(35.6652, 139.7693)),
  AfiliatedStore(
      id: "iGTTy3TINw",
      name: "Matthew",
      address: "東京都千代田区皇居外苑22-23-24",
      location: const LatLng(35.6839, 139.7536)),
  AfiliatedStore(
      id: "KAXT16woxL",
      name: "Rober",
      address: "東京都千代田区有楽町25-26-27",
      location: const LatLng(35.6751, 139.7637)),
  AfiliatedStore(
      id: "Yx6b6NiTVM",
      name: "Benjamin",
      address: "東京都世田谷区経堂28-29-30",
      location: const LatLng(35.6425, 139.6532)),
  AfiliatedStore(
      id: "n3kCBm8GtU",
      name: "Rober",
      address: "東京都世田谷区用賀31-32-33",
      location: const LatLng(35.6312, 139.6372)),
  AfiliatedStore(
      id: "LEzeMwghq6",
      name: "Daniel",
      address: "東京都港区芝公園34-35-36",
      location: const LatLng(35.6547, 139.7474)),
  AfiliatedStore(
      id: "dOorrpk1cP",
      name: "Rober",
      address: "東京都港区麻布十番37-38-39",
      location: const LatLng(35.6561, 139.7352)),
  AfiliatedStore(
      id: "xYpovhp2SR",
      name: "Joseph",
      address: "東京都目黒区中目黒40-41-42",
      location: const LatLng(35.6437, 139.6981)),
  AfiliatedStore(
      id: "hiX5sFXOnD",
      name: "Rober",
      address: "東京都練馬区桜台43-44-45",
      location: const LatLng(35.7492, 139.6517)),
  AfiliatedStore(
      id: "dmOZCSjEQA",
      name: "William",
      address: "東京都文京区湯島46-47-48",
      location: const LatLng(35.7079, 139.7694)),
  AfiliatedStore(
      id: "AimGUIhi0D",
      name: "Rober",
      address: "東京都墨田区押上49-50-51",
      location: const LatLng(35.7101, 139.8133)),
  AfiliatedStore(
      id: "IpDHf9J1QT",
      name: "John",
      address: "東京都台東区浅草52-53-54",
      location: const LatLng(35.7148, 139.7967)),
  AfiliatedStore(
      id: "kkr3KySQj7",
      name: "James",
      address: "東京都豊島区駒込55-56-57",
      location: const LatLng(35.7363, 139.7469)),
  AfiliatedStore(
      id: "nMZduRLumT",
      name: "Michael",
      address: "東京都中野区中野坂上58-59-60",
      location: const LatLng(35.6977, 139.6735)),
];

class AfiliatedStore {
  String id;
  String name;
  String address;
  LatLng location;
  AfiliatedStore(
      {required this.id,
      required this.location,
      required this.address,
      required this.name});
}
