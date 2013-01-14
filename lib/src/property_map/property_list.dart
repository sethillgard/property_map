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
 * Wrapper around List<dynamic>
 */
class PropertyList extends PropertyContainer implements List<dynamic> {

  // The actual list that holds the elements.
  List _objectData;

  /// Default constructor.
  PropertyList() {
    _objectData = new List();
  }

  /// Contructor from Iterable.
  PropertyList.from(Iterable other) {
    _objectData = new List.from(other);
    for (var i = 0; i < _objectData.length; i++) {
      _objectData[i] = _validate(_objectData[i]);
    }
  }

  // Implementation of List
  forEach(func(dynamic value)) => _objectData.forEach(func);
  int get length => _objectData.length;
  bool get isEmpty => _objectData.isEmpty;
  clear() => _objectData.clear();
  Collection map(f(element)) => _objectData.map(f);
  Collection filter(bool f(element)) => _objectData.filter(f);
  bool every(bool f(element)) => _objectData.every(f);
  bool some(bool f(element)) => _objectData.some(f);
  reduce(initialValue, combine(prevValue, element)) =>
      _objectData.reduce(initialValue, combine);
  bool contains(dynamic element) => _objectData.contains(element);
  Iterator iterator() => _objectData.iterator();
  void set length(int value) { _objectData.length = value; }
  dynamic get first => _objectData.first;
  dynamic get last => _objectData.last;
  void add(dynamic value) => _objectData.add(_validate(value));
  void addLast(dynamic value) => _objectData.addLast(_validate(value));
  void addAll(Collection<dynamic> collection) {
    for (var item in collection) {
      _objectData.add(_validate(item));
    }
  }
  void sort([Comparator compare = Comparable.compare]) =>
      _objectData.sort(compare);
  int indexOf(dynamic element, [int start = 0]) =>
      _objectData.indexOf(element, start);
  int lastIndexOf(dynamic element, [int start = 0]) =>
      _objectData.lastIndexOf(element, start);
  dynamic removeAt(int index) => _objectData.removeAt(index);
  dynamic removeLast() => _objectData.removeLast();
  List<dynamic> getRange(int start, int length) =>
      _objectData.getRange(start, length);
  void setRange(int start, int length, List<dynamic> from, [int startFrom]) =>
      _objectData.setRange(start, length, _validate(from), startFrom);
  void removeRange(int start, int length) =>
      _objectData.removeRange(start, length);
  void insertRange(int start, int length, [dynamic initialValue]) =>
      _objectData.insertRange(start, length, _validate(initialValue));
  operator [](int index) => _objectData[index];
  operator []=(int index, dynamic value) {
    _objectData[index] = _validate(value);
  }

  /**
   * Serialize.
   */
  String toJson() {
    var buffer = new StringBuffer();
    buffer.add('[');
    for (var i = 0; i < _objectData.length ; i++) {
      if (i > 0) {
        buffer.add(',');
      }
      var value = _objectData[i];
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
        throw 'Unexpected value found on a PropertyList. Type found: '
        '${mirror.type.simpleName}.';
      }
    }
    buffer.add(']');
    return buffer.toString();
  }

  /**
   * Deserialize.
   */
  void fromJson(dynamic json) {
    assert(json is List);
    _objectData = new List.from(json);
    for (var i = 0; i < _objectData.length; i++) {
      _objectData[i] = _validate(_objectData[i]);
    }
  }

  String toString() {
    return 'PropertyMap:${_objectData.toString()}';
  }
}
