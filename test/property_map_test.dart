library property_map_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import '../lib/property_map.dart';

void main() {

  useHtmlEnhancedConfiguration();

  group('PropertyContainer tests: ', () {

    PropertyMap data;

    setUp(() {
      data = new PropertyMap();
    });

    test('Map base test', () {
      data.field = "value";
      expect(data.field, data['field']);
    });

    test('List to PropertyList conversion', () {
      data.list = ['a', 3];
      expect(data.list, new isInstanceOf<PropertyList>());
      expect(data.list, orderedEquals(['a', 3]));
    });

    test('Map to PropertyMap conversion', () {
      data.map = {'a': 'aaa', 'b': 'bbb'};
      expect(data.map, new isInstanceOf<PropertyMap>());
      expect(data.map.keys, unorderedEquals(['a', 'b']));
      expect(data.map.values, unorderedEquals(['aaa', 'bbb']));
      expect(data.map.a, 'aaa');
    });

    test('Data types', () {
      data.map = {'a': 'aaa', 'b': 'bbb'};
      data.num = 5.34;
      data.str = "String";
      data.boolean = false;
      data.none = null;
      data.map = {};
      data.map.list = [1,2,3,4,5];
      data.map.list.add(6);
      data.map.name = 'Dan';
      expect(data.map.name, 'Dan');
      expect(data.map.list, orderedEquals([1,2,3,4,5,6]));
    });

    test('Arbitrary data types when allowNonSerializables = false', () {
      // StringBuffer is not Serializable and thus it's not supported.
      expect(() => data.whatever = new StringBuffer(), throws);
    });

    test('Arbitrary data types when allowNonSerializables = true', () {
      var c = new PropertyContainerConfig();
      c.allowNonSerializables = true;
      var data = new PropertyMap(c);
      data.unsupportedType = new StringBuffer();
      expect(() => data.toJson(), throws);
    });

    test('Serialization disabled when autoConvertLists = false', () {
      var c = new PropertyContainerConfig();
      c.autoConvertLists = false;
      var data = new PropertyMap(c);
      data.whatever = 4;
      expect(() => data.toJson(), throws);
    });

    test('Serialization disabled when autoConvertMaps = false', () {
      var c = new PropertyContainerConfig();
      c.autoConvertMaps = false;
      var data = new PropertyMap(c);
      data.whatever = 4;
      expect(() => data.toJson(), throws);
    });

    test('PropertyMap: Add raw elements', () {
      data.addRawElement('test', new StringBuffer());
      expect(() => data.toJson(), throws);
    });

    test('PropertyList: Add raw elements', () {
      var data = new PropertyList();
      data.addRawElement(new StringBuffer());
      expect(() => data.toJson(), throws);
    });

    test('Lists not being promoted when autoConvertLists = false', () {
      var c = new PropertyContainerConfig();
      c.autoConvertLists = false;
      var data = new PropertyMap(c);
      data.whatever = [1,2,4,5];
      expect(data.whatever, new isInstanceOf<List>());
    });

    test('Maps not being promoted when autoConvertMaps = false', () {
      var c = new PropertyContainerConfig();
      c.autoConvertMaps = false;
      var data = new PropertyMap(c);
      data.whatever = {'a': 'aaa', 'b': 'bbb'};
      expect(data.whatever, new isInstanceOf<Map>());
    });
  });
}
