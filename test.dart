
import 'lib/property_map.dart';

class Test {

}

void main() {
  // Create a PropertyMap
  var data = new PropertyMap();

  // Just add properties.
  data.name = "Daniel";
  data.age = 25;

  // [] works too, if you prefer it.
  data['phone'] = 621-222-1155;

  // Add a List. It will be automatically converted to a PropertyList.
  data.enemies = ['Lucia', 'John', 'Alex'];

  // But exposes the same API.
  data.enemies.add('Susan');

  // Maps are converted to PropertyMaps so you can compose them.
  data.games = {'important': true, 'fun':true, 'numberOwned':9999};

  // You can simply keep adding properties to nested maps.
  data.games.favorites = ['Braid', 'Portal'];

  // Read values.
  print(data.name);
  print(data.games.favorites[0]);

  // Serialize them all.
  print(data.toJson());
}
