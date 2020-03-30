import 'dart:math';

class Item {
  String name;

  Item(this.name);
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

class _PurelyRandomSelectionTechnique extends _BaseRandomSelectionTechnique {
  final Random _rng = Random();

  _PurelyRandomSelectionTechnique(int count) : super(count);

  @override
  int next() {
    return _rng.nextInt(count());
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
  String name;
  List<Item> items = [];
  _BaseRandomSelectionTechnique _technique =
      _PermutationRandomSelectionTechnique(0);

  Collection(this.name);
  Collection.withItems(this.name, this.items) {
    _technique.setCount(items.length);
  }

  void addItem(Item item) {
    items.add(item);
    _technique.setCount(items.length);
  }

  void removeItem(Item item) {
    items.remove(item);
    _technique.setCount(items.length);
  }

  void clearItems() {
    items.clear();
    _technique.setCount(0);
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Item randomItem() {
    if (items.isNotEmpty) {
      return items[_technique.next()];
    }
    return null;
  }
}
