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

typedef dynamic Deserializer(Map map, PropertyContainerConfig config);

/**
 * Base class for PropertyList and PropertyMap.
 * Implements common functionality.
 */
abstract class PropertyContainer implements Serializable {

  // Configuration data object.
  PropertyContainerConfig _configuration = null;
  PropertyContainerConfig get configuration => _configuration;

  // Internally used to mark that raw elements where added to the collection,
  // so we can no longer guarantee serialization.
  bool _hasRawElements = false;

  // Map of registered custom deserializers. Keys are strings specifying the
  // types (_type_) and keys are the deserializer functions.
  static Map<String, Deserializer> _customDeserializers = {};

  /**
   * Registers a new custom deserializer for a _type_
   */
  static void _registerCustomDeserializer(String type,
                                          Deserializer deserializer) {
    _customDeserializers[type] = deserializer;
  }

  /**
   * Returns the passed value if it is a an acceptable entry for a
   * PropertyContainer given the specified configuration, a 'promoted' version
   * of the passed value (List->PropertyList, Map->PropertyMap), or a custom
   * object constructed using the passed value if a custom deserializer was
   * registred for its type.
   *
   * If the value is a Map or a List, it will be converted into a PropertyMap or
   * a PropertyList (recursively), unless specified otherwise onto the config
   * object.
   *
   * If the value is a Map with a '_type_' field, it will execute the registred
   * customDeserializer for that type, unless specified otherwise in the config
   * object.
   *
   * If the value is not a Map, List, String, bool, num, null, or an instance
   * implementing Serializable and the config does not allow nonSerializable
   * objects, it throws an exception.
   */
  static dynamic _promote(dynamic value,
                          [PropertyContainerConfig configuration = null]) {
    if (configuration == null) {
      configuration = PropertyContainerConfig.defaultValue;
    }
    if (value is num ||
        value is bool ||
        value is String ||
        value == null ||
        value is Serializable) {
      return value;
    }
    else if (value is List) {
      if (configuration.autoConvertLists) {
        return new PropertyList._from(value, configuration);
      } else {
        return value;
      }
    }
    else if (value is Map) {
      if (configuration.autoConvertMaps) {

        // If this map has a '_type_' key, check if we should use a custom
        // deserializer.
        if (configuration.useCustomDeserializers &&
            value.keys.contains("_type_")) {
          var type = value["_type_"];
          if (_customDeserializers.keys.contains(type)) {
            var deserializer = _customDeserializers[type];

            // Why do we call validate on the result? Excellent question.
            // The deserializer could return literally anything, including
            // invalid types for the current configuration. Often, it will be
            // a Serializable object, and validate() will return it
            // immeadiately, but it could also return an invalid type, so we
            // have to check it. We make sure the returned object is not the
            // same value we sent to prevent infinite loops.
            var result = deserializer(value, configuration);
            if (result == value) {
              throw 'Custom deserializer for type "$type" returned same object.'
                  'This is not allowed. Custom deserializers must return a '
                  'different object, generally an instance of a Serializable '
                  'class.';
            }
            return _promote(result, configuration);
          } else {
            throw 'Custom deserializer not found for type "$type". Use '
            'PropertyContainer.registerCustomDeserializer() to add it.';
          }
        } else {
          return new PropertyMap._from(value, configuration);
        }
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
  dynamic _validate(dynamic value) => _promote(value, this._configuration);
}
