/*
  Copyright (C) 2012 Daniel Rodr√≠guez <seth.illgard@gmail.com>

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
 * Wrapper around a Map<String, dynamic>.
 *
 * Only numbers, booleans, Strings, Lists(recursive), Maps(recursive) and types
 * that implement Serializable are allowed as entries on a PropertyContainer,
 * unless _allowNonSerializables is set to true ont he configuration object,
 * in which case, serialization is disabled.
 */
class PropertyMap extends PropertyContainer implements Map<String, dynamic> {

  // The actual map that holds the elements.
  Map<String, dynamic> _objectData;

  /**
   *  Default constructor.
   */
  PropertyMap([PropertyContainerConfig configuration = null]) {
    if (configuration == null) {
      configuration = PropertyContainerConfig.defaultValue;
    }
    _configuration = configuration;
    _objectData = new Map();
  }

  /**
   * Contructs a PropertyMap from another Map, creating a copy of it.
   */
  PropertyMap.from(Map<String, dynamic> other,
                   [PropertyContainerConfig configuration = null]) {
    if (configuration == null) {
      configuration = PropertyContainerConfig.defaultValue;
    }
    _configuration = configuration;
    _objectData = new Map.from(other);
    for (var key in _objectData.keys) {
      assert(key is String);
      _objectData[key] = _validate(_objectData[key]);
    }
  }

  // Implementation of Map<String, dynamic>
  bool containsValue(dynamic value) => _objectData.containsValue(value);
  bool containsKey(String key) => _objectData.containsKey(key);
  forEach(func(String key, dynamic value)) => _objectData.forEach(func);
  Iterable<String> get keys => _objectData.keys;
  Iterable<dynamic> get values => _objectData.values;
  int get length => _objectData.length;
  bool get isEmpty => _objectData.isEmpty;
  putIfAbsent(String key,ifAbsent()) {
    _objectData.putIfAbsent(key, () {
      _validate(ifAbsent());
    });
  }
  clear() => _objectData.clear();
  remove(String key) => _objectData.remove(key);
  operator [](String key) => _objectData[key];
  operator []=(String key, dynamic value) {
    _objectData[key] = _validate(value);
  }

  /**
   * Adds an element at to this PropertyMap.
   *
   * Use this to override the configuration object. Bear in mind that calling
   * this method will change the configuration to indicate that we can longer
   * guarantee serialization.
   */
  void addRawElement(String key, dynamic value) {
    _hasRawElements = true;
    _objectData[key] = value;
  }

  /**
   * Implementing noSuchMethod allows invocations on this object in a more
   * natural way:
   *  - print(data.propertyName);
   *  - data.propertyName = value;
   * instead of:
   *  - print(data.get('propertyName'));
   *  - data.set('propertyName', value);
   */
  noSuchMethod(InvocationMirror mirror) {
    if (mirror.isGetter) {
      var property = mirror.memberName;
      if (this.containsKey(property)) {
        return this[property];
      }
    } else if (mirror.isSetter) {
      // Remove a nasty '=' that is always added at the end for some reason.
      var property = mirror.memberName.slice(0, -1);
      this[property] = mirror.positionalArguments[0];
      return this[property];
    }

    // The property does not exist.
    print("Not found: ${mirror.memberName} in $this");
    print("IsGetter: ${mirror.isGetter}");
    print("IsSetter: ${mirror.isSetter}");
    print("isAccessor: ${mirror.isAccessor}");
    super.noSuchMethod(mirror);
  }

  /**
   * Serialize.
   */
  String toJson() {
    if (_hasRawElements || !_configuration.canGuaranteeSerialization()) {
      throw 'Calling toString() on a PropertyMap that allows arbitrary '
      'objects is not supported because we cannot gurantee that they will be '
      'Serializable. If you want Serialization enabled, make sure you are '
      'using the default configuration and not calling addRawElement()';
    }

    var buffer = new StringBuffer();
    buffer.add('{');
    var first = true;
    for (var key in _objectData.keys) {
      first ? first = false : buffer.add(',');
      buffer.add('"${key}":');
      var value = _objectData[key];
      if (value is num || value is bool) {
        buffer.add(value);
      }
      else if (value is String) {
        buffer.add('"${value}"');
      }
      else if (value is Serializable) {
        buffer.add(value.toJson());
      }
      else {
        var mirror = reflect(value);
        throw 'Unexpected value found on a PropertyMap. Type found: '
        '${mirror.type.simpleName}.';
      }
    }
    buffer.add('}');
    return buffer.toString();
  }

  /**
   * Deserialize.
   */
  void fromJson(dynamic json) {
    assert(json is Map);
    _objectData = new Map.from(json);
    for (var key in _objectData.keys) {
      assert(key is String);
      _objectData[key] = _validate(_objectData[key]);
    }
  }

  dynamic toString() {
    return 'PropertyMap:${_objectData.toString()}';
  }
}