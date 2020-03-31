import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

class Item {
  String name;

  Item(this.name);
  Item.fromJson(Map<String, dynamic> json) : name = json['name'];

  Map<String, dynamic> toJson() => {'name': name};
}

class _BaseRandomSelectionTechnique {
  int _count;

  _BaseRandomSelectionTechnique(this._count);

  void setCount(int count) {
    _count = count;
  }

  int count() {
    return _count;
  }

  int next() {
    return 0;
  }
}

class _PermutationRandomSelectionTechnique
    extends _BaseRandomSelectionTechnique {
  final Random _rng = Random();
  List<int> _indices = [];
  int _idx = 0;

  _PermutationRandomSelectionTechnique(int count) : super(count) {
    _shuffle(count);
  }

  @override
  void setCount(int count) {
    super.setCount(count);
    _shuffle(count);
  }

  @override
  int next() {
    if (count() == 0) {
      return -1;
    }

    if (_idx == count()) {
      _shuffle(count());
    }

    return _indices[_idx++];
  }

  void _shuffle(int count) {
    _indices.clear();
    for (int i = 0; i < count; i++) {
      _indices.add(i);
    }
    _indices.shuffle(_rng);
    _idx = 0;
  }
}

class Collection {
  String _name;
  List<Item> _items = [];
  Function(Collection) _onChanged;

  _BaseRandomSelectionTechnique _technique =
      _PermutationRandomSelectionTechnique(0);

  Collection(this._name);
  Collection.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    List<Map<String, dynamic>> itemJson =
        json['items'] as List<Map<String, dynamic>>;
    _items = itemJson.map((ij) => Item.fromJson(ij));
  }
  Collection.withItems(this._name, this._items) {
    _technique.setCount(_items.length);
  }

  Map<String, dynamic> toJson() =>
      {'name': _name, 'items': _items.map((i) => i.toJson()).toList() };

  String get name => _name;
  set name(String newName) {
    _name = newName;
    _notifyChange();
  }

  List<Item> get items => _items;

  void addItem(Item item) {
    items.add(item);
    _technique.setCount(items.length);
    _notifyChange();
  }

  void removeItem(Item item) {
    items.remove(item);
    _technique.setCount(items.length);
    _notifyChange();
  }

  void clearItems() {
    items.clear();
    _technique.setCount(0);
    _notifyChange();
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Item randomItem() {
    if (items.isNotEmpty) {
      return items[_technique.next()];
    }
    return null;
  }

  void _notifyChange() {
    if (_onChanged != null) {
      _onChanged(this);
    }
  }
}

class CollectionsStore {
  List<Collection> _collections = [];

  CollectionsStore() {
    _collections = [
      Collection.withItems("Numbers", [
        Item("0"),
        Item("1"),
        Item("2"),
        Item("3"),
        Item("4"),
        Item("5"),
        Item("6"),
        Item("7"),
        Item("8"),
        Item("9"),
      ]),
      Collection.withItems("Proglangs", [
        Item("C"),
        Item("CXX"),
        Item("C#"),
        Item("Dart"),
        Item("Python"),
        Item("Java"),
        Item("Rust"),
      ]),
      Collection.withItems("Styles", [
        Item("Shaolin"),
        Item("Wing Chun"),
        Item("Tai Chi"),
        Item("Northern Praying Mantis"),
        Item("Baguazhang"),
        Item("Xingyiquan"),
        Item("Bajiquan")
      ])
    ];

    for (Collection c in _collections) {
      c._onChanged = (c) {
        _save();
      };
    }
  }

  List<Collection> get collections => _collections;
  bool get isEmpty => _collections.isEmpty;
  bool get isNotEmpty => _collections.isNotEmpty;

  void add(Collection collection) {
    _collections.add(collection);
    _save();
  }

  void remove(Collection collection) {
    _collections.remove(collection);
    _save();
  }

  void clear() {
    _collections.clear();
    _save();
  }

  void load(Function() onComplete) {
    _load((collections){
      _collections = collections;
      onComplete();
    });
  }

  Future<File> _collectionsStoreFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/store.json');
  }

  Future<List<Collection>> _load(Function(List<Collection>) onComplete) async {
    try {
      final file = await _collectionsStoreFile();
      String contents = await file.readAsString();
      List<dynamic> collectionDataJson = jsonDecode(contents);
      List<Collection> collections =
          collectionDataJson.map((j) => Collection.fromJson(j)).toList();
      onComplete(collections);
      return collections;
    } catch (e) {
      print("loadCollectionsFromStore failed, error: $e");
      return [];
    }
  }

  void _save() async {
    List<dynamic> collectionsJsonData =
        collections.map((c) => c.toJson()).toList();
    String collectionsJson = jsonEncode(collectionsJsonData);

    File store = await _collectionsStoreFile();
    store.writeAsString(collectionsJson);

    print("CollectionStore::_save wrote:\n$collectionsJson\n");
  }
}
