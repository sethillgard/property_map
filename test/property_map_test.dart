library property_map_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import '../lib/property_map.dart';

class Mock extends Serializable{
    String messageField;

    Mock(this.messageField) {
    }

    String toJson() {
      return '{"_type_":"Test", "message":"${messageField}"}';
    }
}

void main() {

  useHtmlEnhancedConfiguration();

  group('PropertyContainer tests: ', () {

    PropertyMap data;

    setUp(() {
      data = new PropertyMap();

      PropertyMap.registerCustomDeserializer('Mock', (value, config) {
        return new Mock(value['message']);
      });
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

    test('Custom deserializers', () {
      data.mock = {'_type_': 'Mock', 'message':'secret message!'};
      expect(data.mock, new isInstanceOf<Mock>());
      expect(data.mock.messageField, equals('secret message!'));
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

    test('Top level promotion of Maps', () {
      var map = PropertyMap.promote({'aaa': 'Test', 'message':'secret'});
      expect(map, new isInstanceOf<PropertyMap>());
      expect(map.message, equals('secret'));
    });

    test('Top level promotion of Lists', () {
      var list = PropertyMap.promote([0,1,2,3,'hey','you']);
      expect(list, new isInstanceOf<PropertyList>());
      expect(list[4], equals('hey'));
    });

    test('Top level promotion using custom deserializers', () {
      var mock = PropertyMap.promote({'_type_': 'Mock',
                                      'message':'secret message!'});
      expect(mock, new isInstanceOf<Mock>());
      expect(mock.messageField, equals('secret message!'));
    });

    test('PropertyMap -> Json string', () {
      var map = PropertyMap.promote({'name': 'Test',
                                     'message':'secret message!!!',
                                     'nested':[1,2,3,4,'test',['a','b','c']]});
      var json = map.toJson();
      expect(json, equals('{"name":"Test","nested":[1,2,3,4,"test",'
                          '["a","b","c"]]'
                          ',"message":"secret message!!!"}'));
    });

    test('Json string -> PropertyMap', () {
      var map = PropertyMap.parseJson('{"name":"Test","nested":[1,2,3,4,'
                                      '"test",["a","b","c"]]'
                                      ',"message":"secret message!!!"}');

      expect(map.name, equals('Test'));
      expect(map.nested[5][1], equals('b'));
    });

  });
}
