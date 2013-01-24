property_map
============

## Introduction ##

PropertyMap allows you to quickly implement property bags in dart. It consists
of 2 main classes: PropertyMap and PropertyList.

PropertyMap is a wrapper around Map<String, dynamic>.
PropertyList is a wrapper around List<dynamic>.

The benefit of using them is that they can restrict the data that is added to 
them, for example, they can only take simple objects and Serializable objects.
This way, we can ensure that everything inside a PropertyMap (or PropertyList)
is indeed, serializable.

## Features ##

* Rapid implementation of property bags.
* Only accepts simple types (as defined in dart:json) and Serializable objects.

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
```