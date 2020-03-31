import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rando/model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rando",
      home: CollectionsScreen(),
      theme: ThemeData(primaryColor: Colors.yellow),
    );
  }
}

class CollectionsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CollectionsScreenState();
}

class CollectionsScreenState extends State<CollectionsScreen> {
  final CollectionsStore _store = CollectionsStore();

  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rando"),
      ),
      body: _store.isEmpty ? _placeholderCollectionsList() : _collectionsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _newCollection,
        tooltip: "New Collection",
        child: Icon(Icons.add),
      ),
    );
  }

  void _newCollection() async {
    String name =
        await _showInputDialog(context, "New collection...", "Name", null);

    if (name != null && name.isNotEmpty) {
      setState(() {
        Collection newCollection = Collection(name);
        _store.add(newCollection);

        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return CollectionEditor(
            collection: newCollection,
          );
        }));
      });
    }
  }

  Widget _placeholderCollectionsList() {
    return Center(
      child: Column(
        children: <Widget>[
          MaterialButton(
            child: Text("Create a Collection..."),
            onPressed: _newCollection,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _collectionsList() {
    final Iterable<Widget> collections = _store.collections.map((Collection c) {
      return _buildRow(c);
    });
    final List<Widget> divided =
        ListTile.divideTiles(context: context, tiles: collections).toList();
    return ListView(
      children: divided,
    );
  }

  Widget _buildRow(Collection collection) {
    return Dismissible(
      background: Container(
        color: Colors.red,
      ),
      key: Key(collection.name),
      onDismissed: (direction) {
        setState(() {
          _store.remove(collection);
        });
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted ${collection.name}"),
          ),
        );
      },
      child: ListTile(
        title: Text(collection.name, style: _biggerFont),
        trailing: collection.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.radio),
                onPressed: () {
                  _rollDiceFor(collection);
                },
              )
            : null,
        onTap: () {
          _showCollection(collection);
        },
      ),
    );
  }

  void _showCollection(Collection collection) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return CollectionEditor(
        collection: collection,
        onCollectionEdited: null,
      );
    }));
  }

  void _rollDiceFor(Collection collection) {
    Item item = collection.randomItem();
    print("_rollDiceFor: ${collection.name} item: ${item.name}");
  }
}

//
//  CollectionEditor
//

class CollectionEditor extends StatefulWidget {
  final Collection collection;
  final Function(Collection) onCollectionEdited;
  const CollectionEditor({Key key, this.collection, this.onCollectionEdited})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CollectionEditorState();
}

class CollectionEditorState extends State<CollectionEditor> {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editTitle,
          )
        ],
      ),
      body: widget.collection.items.isEmpty
          ? _placeholderItemList()
          : _itemList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: "Add item...",
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _placeholderItemList() {
    return Center(
      child: Column(
        children: <Widget>[
          MaterialButton(
            child: Text("Add some items..."),
            onPressed: _addItem,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _itemList() {
    final Iterable<Widget> items = widget.collection.items.map((Item i) {
      return _buildRow(i);
    });
    final List<Widget> divided =
        ListTile.divideTiles(context: context, tiles: items).toList();
    return ListView(
      children: divided,
    );
  }

  void _editTitle() async {
    String value = await _showInputDialog(context, "Edit collection name:",
        "Collection name", widget.collection.name);
    if (value != null && value.isNotEmpty) {
      setState(() {
        widget.collection.name = value;
        if (widget.onCollectionEdited != null) {
          widget.onCollectionEdited(widget.collection);
        }
      });
    }
  }

  Widget _buildRow(Item item) {
    return Dismissible(
      background: Container(
        color: Colors.red,
      ),
      key: Key(item.name),
      onDismissed: (direction) {
        setState(() {
          widget.collection.removeItem(item);
          if (widget.onCollectionEdited != null) {
            widget.onCollectionEdited(widget.collection);
          }
        });
      },
      child: ListTile(
        title: Text(item.name, style: _biggerFont),
      ),
    );
  }

  void _addItem() async {
    String value = await _showInputDialog(context, "Item", "Item Name", null);
    if (value != null && value.isNotEmpty) {
      setState(() {
        widget.collection.addItem(Item(value));
        if (widget.onCollectionEdited != null) {
          widget.onCollectionEdited(widget.collection);
        }
      });
    }
  }
}

//
//  Util
//

Future<String> _showInputDialog(BuildContext context, String title,
    String valueTitle, String initialValue) async {
  String text;
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: TextEditingController()
                    ..text = initialValue != null ? initialValue : "",
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: valueTitle,
                  ),
                  onChanged: (value) {
                    text = value;
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop(text);
              },
            ),
          ],
        );
      });
}
