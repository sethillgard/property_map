/*
  Copyright (C) 2012 Daniel Rodriguez <seth.illgard@gmail.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of property_map;

/**
 * Base class for PropertyList and PropertyMap.
 * Implements common functionality.
 */
abstract class PropertyContainer implements Serializable {

  // Configuration data object.
  PropertyContainerConfig _configuration = null;

  // Internally used to mark that raw elements where added to the collection,
  // so we can no longer guarantee serialization.
  bool _hasRawElements = false;

  /**
   * Returns the passed value if it is a an acceptable entry for a
   * PropertyContainer. If the value is a Map or a List, it will be converted
   * into a PropertyMap or a PropertyList (recursively), unless specified
   * otherwise onto the config object. If the value is not a Map, List, String,
   * bool, num, null, or an instance implementing Serializable and the config
   * does not allow nonSerializable objects, it throws an exception.
   */
  static dynamic validate(dynamic value,
                          PropertyContainerConfig configuration) {
    if (value is num ||
        value is bool ||
        value is String ||
        value == null ||
        value is Serializable) {
      return value;
    }
    else if (value is List) {
      if (configuration.autoConvertLists) {
        return new PropertyList.from(value, configuration);
      }
      else {
        return value;
      }
    }
    else if (value is Map) {
      if (configuration.autoConvertMaps) {
        return new PropertyMap.from(value, configuration);
      }
      else {
        return value;
      }
    }

    // If this is set to true, just let it go. Users know what they are doing.
    if (configuration.allowNonSerializables) {
      return value;
    }

    var mirror = reflect(value);
    throw 'Value not supported on a PropertyContainer. Trying to save an '
    'instance of ${mirror.type.simpleName}. Only numbers, booleans, Strings, '
    'Lists(recursive), Maps(recursive) and types that implement Serializable '
    'are allowed as entries on a PropertyContainer, unless _allowAnyObject '
    'is set to true.';
    return null;
  }

  /**
   * Internal non static version of validate(). Needed because classes that
   * extend this class may implement noSuchMethod.
   */
  dynamic _validate(dynamic value) => validate(value, this._configuration);
}

/**
 * Configuration data holder.
 */
class PropertyContainerConfig {

  // If set to true, any object can be added to this container.
  bool allowNonSerializables = false;

  // If set to true, List objects will be turned into PropertyLists when added.
  bool autoConvertLists = true;

  // If set to true, Map objects will be turned into PropertyMaps when added.
  bool autoConvertMaps = true;

  /**
   * Returns true if we can guarantee that all of the objects the containers
   * using this configuration are holding are serializable.
   *
   * This is only true with the default configuration.
   */
  bool canGuaranteeSerialization() {
    return !allowNonSerializables && autoConvertLists && autoConvertMaps;
  }

  // Cached default for everybody to use.
  static final PropertyContainerConfig defaultValue =
      new PropertyContainerConfig();
}
