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

abstract class PropertyContainer implements Serializable {

  /**
   * Returns the passed value if it is a an acceptable entry for a
   * PropertyContainer. If the value is a Map or a List, it will be converted
   * into a PropertyMap or a PropertyList (recursively). If the value is
   * not a Map, List, String, bool, num, null, or an instance implementing
   * Serializable, it throws an exception.
   */
  static dynamic validate(dynamic value) {
    if (value is num ||
        value is bool ||
        value is String ||
        value == null ||
        value is Serializable) {
      return value;
    }
    else if (value is List) {
      return new PropertyList.from(value);
    }
    else if (value is Map) {
      return new PropertyMap.from(value);
    }

    var mirror = reflect(value);
    throw 'Value not supported on a PropertyContainer. Trying to save an '
    'instance of ${mirror.type.simpleName}. Only numbers, booleans, Strings, '
    'classes that implement Serializable and Lists and Maps of those '
    'types are allowed as entries on a PropertyContainer.';
    return null;
  }

  /**
   * Internal non static version of validate(). Needed because classes that
   * extend this class may implement noSuchMethod.
   */
  dynamic _validate(dynamic value) => validate(value);
}
