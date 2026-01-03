class Room {
  final String name;

  Room(this.name);
}

class Floor {
  final String name;
  final List<Room> rooms;

  Floor(this.name, this.rooms);
}

class Location {
  final String name;
  final List<Floor> floors;

  Location(this.name, this.floors);

  List<String> getFloors() => floors.map((f) => f.name).toList();

  List<String> getRooms() =>
      floors.expand((floor) => floor.rooms.map((r) => r.name)).toList();
}

class PositionPathParser {

  static List<Location> parse(List<String> positionPaths) {
    Map<String, Location> locationsMap = {};

    for (var path in positionPaths) {
      List<String> parts = path.split('/');
      if (parts.length != 3) continue;

      String locName = parts[0];
      String floorName = parts[1];
      String roomName = parts[2];

      if (!locationsMap.containsKey(locName)) {
        locationsMap[locName] = Location(locName, []);
      }
      Location loc = locationsMap[locName]!;

      Floor? floor = loc.floors.firstWhere(
            (f) => f.name == floorName,
        orElse: () {
          var newFloor = Floor(floorName, []);
          loc.floors.add(newFloor);
          return newFloor;
        },
      );

      if (!floor.rooms.any((r) => r.name == roomName)) {
        floor.rooms.add(Room(roomName));
      }
    }

    return locationsMap.values.toList();
  }
}
