import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class Item extends ChangeNotifier {
  String _name;

  Item(this._name);
  Item.fromJson(Map<String, dynamic> json) : _name = json['name'];

  set name(newName) {
    _name = newName;
    notifyListeners();
  }

  String get name => _name;

  Map<String, dynamic> toJson() => {'name': _name};
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

class Collection extends ChangeNotifier {
  String _name;
  List<Item> _items = [];

  _BaseRandomSelectionTechnique _technique =
      _PermutationRandomSelectionTechnique(0);

  Collection(this._name);
  Collection.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _items = json['items'].map<Item>((ij) => Item.fromJson(ij)).toList();
    _technique.setCount(_items.length);
  }
  Collection.withItems(this._name, this._items) {
    _technique.setCount(_items.length);
  }

  Map<String, dynamic> toJson() =>
      {'name': _name, 'items': _items.map((i) => i.toJson()).toList()};

  String get name => _name;
  set name(String newName) {
    _name = newName;
    notifyListeners();
  }

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  void add(Item item) {
    _items.add(item);
    _technique.setCount(_items.length);
    notifyListeners();
  }

  void insert(int index, Item item) {
    _items.insert(index, item);
    _technique.setCount(_items.length);
    notifyListeners();
  }

  void remove(Item item) {
    _items.remove(item);
    _technique.setCount(_items.length);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _technique.setCount(0);
    notifyListeners();
  }

  int indexOf(Item item) {
    return _items.indexOf(item);
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  Item randomItem() {
    if (_items.isNotEmpty) {
      return _items[_technique.next()];
    }
    return null;
  }
}

enum LoadState {
  Unloaded,
  Loading,
  Loaded
}

class CollectionStore extends ChangeNotifier {
  List<Collection> _collections = [];
  LoadState _loadState = LoadState.Unloaded;
  VoidCallback _saveCb;

  UnmodifiableListView<Collection> get collections => UnmodifiableListView(_collections);
  bool get isEmpty => _collections.isEmpty;
  bool get isNotEmpty => _collections.isNotEmpty;
  LoadState get loadState => _loadState;


  CollectionStore() {
    _saveCb = ()=>_save();

    _load().then((collections) {
      _collections = collections;
      for (var c in _collections) {
        c.addListener(_saveCb);
      }
      notifyListeners();
    });
  }

  void add(Collection collection) {
    _collections.add(collection);
    collection.addListener(_saveCb);
    notifyListeners();
    _save();
  }

  void insert(int index, Collection collection) {
    _collections.insert(index, collection);
    collection.addListener(_saveCb);
    notifyListeners();
    _save();
  }

  void remove(Collection collection) {
    _collections.remove(collection);
    collection.removeListener(_saveCb);
    notifyListeners();
    _save();
  }

  int indexOf(Collection collection) {
    return _collections.indexOf(collection);
  }

  void clear() {
    for (var c in _collections) {
      c.removeListener(_saveCb);
    }
    _collections.clear();
    notifyListeners();
    _save();
  }

  Future<File> _storeFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/store.json');
  }

  Future<List<Collection>> _load() async {
    _loadState = LoadState.Loading;
    notifyListeners();

    try {
      final file = await _storeFile();
      String contents = await file.readAsString();
      final collectionStoreJson = jsonDecode(contents);

      List<Collection> collections = collectionStoreJson.map<Collection>((cj) {
        Collection c = Collection.fromJson(cj);
        return c;
      }).toList();

      return collections;
    } catch (e) {
      print("_load failed, error: $e");
      return [];
    } finally {
      _loadState = LoadState.Loaded;
      notifyListeners();
    }
  }

  void _save() async {
    List<Map<String, dynamic>> collectionsJsonData =
        collections.map((c) => c.toJson()).toList();
    String collectionsJson = jsonEncode(collectionsJsonData);

    File store = await _storeFile();
    store.writeAsString(collectionsJson);

    print("CollectionStore::_save wrote:\n$collectionsJson\n");
  }
}
