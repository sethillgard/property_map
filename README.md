property_map
============

## Introduction ##

PropertyMap allows you to quickly implement property bags in dart. It consists
of 2 main classes: PropertyMap and PropertyList.

PropertyMap is a wrapper around Map<String, dynamic>.
PropertyList is a wrapper around List<dynamic>.

By default, they can only take simple objects (as defined in dart:json)
and Serializable objects. The configuration object passed to the constructor
allows you to modify this behavior if needed.

## Features ##

* Rapid implementation of property bags.
* Can restrict contents to simple types (as defined in dart:json) and
    Serializable objects. This is the default.

## Getting Started ##

1\. Add the following to your project's **pubspec.yaml** and run
```pub install```.

```yaml
dependencies:
  property_map:
    git: https://github.com/sethillgard/property_map.git
```

2\. Add the correct import for your project.

```dart
import 'package:property_map/property_map.dart';
```

## Example ##

1\. Initialize an AssetManager:

```dart
main() {
  // Create a PropertyMap
  var data = new PropertyMap();

  // Just add properties.
  data.name = "Daniel";
  data.age = 25;

  // [] works too, if you prefer it.
  data['phone'] = "621-222-1155";

  // Add a List. It will be automatically converted to a PropertyList 
  // (recursively).
  data.enemies = ['Lucia', 'John', 'Alex'];

  // But exposes the same API.
  data.enemies.add('Susan');

  // Maps are converted to PropertyMaps (also recursively).
  data.games = {'important': true, 'fun':true, 'numberOwned':9999};

  // You can simply keep adding properties to nested maps.
  data.games.favorites = ['Braid', 'Portal'];
  
  // Add nested maps and lists. Values get validated and converted automatically.
  data.test = {'a':{'b':[0,1,2]}};

  // Read values.
  print(data.name);				    // Daniel
  print(data.games.favorites[0]);	// Braid
  print(data.test.a.b[1]);	        // 1

  // Serialize them all.
  print(data.toJson());
}
```