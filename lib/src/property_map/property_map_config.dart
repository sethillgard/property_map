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
 * Configuration data holder for PropertyContainers.
 */
class PropertyMapConfig {

  // If set to true, any object can be added to this container.
  bool allowNonSerializables = false;

  // If set to true, List objects will be turned into PropertyLists when added.
  bool autoConvertLists = true;

  // If set to true, Map objects will be turned into PropertyMaps when added.
  bool autoConvertMaps = true;

  // If set to true, when deserializing, PropertyMaps with a _type_ property will
  // use a custom deserializer for that type, if it was registered using
  // registerCustomDeserializer()
  bool useCustomDeserializers = true;

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
  static final PropertyMapConfig defaultValue = new PropertyMapConfig();
}

