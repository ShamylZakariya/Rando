
class Item {
  String name;

  Item(this.name);
}

class Collection {
  String name;
  List<Item> items = [];

  Collection(this.name);
  Collection.withItems(this.name, this.items);

  void addItem(Item item) {
    items.add(item);
  }

  void removeItem(Item item) {
    items.remove(item);
  }

  void clearItems() {
    items.clear();
  }
}