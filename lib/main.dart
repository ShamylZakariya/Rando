import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rando/model.dart';

void main() {
  // since we're loading from data dir *before* starting
  // the app, this call is needed to get the bindings ready
  WidgetsFlutterBinding.ensureInitialized();
  CollectionsStore store = CollectionsStore();
  store.load(() {
    runApp(MyApp(store));
  });
}

class MyApp extends StatelessWidget {
  final CollectionsStore _store;

  MyApp(this._store);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rando",
      home: CollectionsScreen(store: _store),
      theme: ThemeData(primaryColor: Colors.yellow),
    );
  }
}

class CollectionsScreen extends StatefulWidget {
  final CollectionsStore store;
  CollectionsScreen({Key key, this.store}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CollectionsScreenState();
}

class CollectionsScreenState extends State<CollectionsScreen> {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rando"),
      ),
      body: widget.store.isEmpty
          ? _placeholderCollectionsList()
          : _collectionsList(),
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
        widget.store.add(newCollection);

        _showCollection(newCollection);
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
    final Iterable<Widget> collections =
        widget.store.collections.map((Collection c) {
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
          widget.store.remove(collection);
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
    showModalBottomSheet(context: context, builder: (BuildContext){
      return CollectionEditor(
        collection: collection,
        onCollectionEdited: (c){
          setState(() {
            // something?
          });
        },
      );
    });
  }

  void _rollDiceFor(Collection collection) {
    Item item = collection.randomItem();
    print("_rollDiceFor: ${collection.name} item: ${item.name}");
    showDialog(
      context: context,
      builder: (BuildContext context) => AvatarDialog(
        buttonText: "Ok",
        description: collection.name,
        title: item.name)
    );
  }
}

//
//  CollectionEditor
//  TODO: Show collection editor as a bottom sheet or some other modal
//  appearance - it's confusing to have the collection editor show
//  immediately, it looks like nothing happened.
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

class AvatarDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  static const double _padding = 16.0;
  static const double _avatarRadius = 66.0;

  AvatarDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  _dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        _card(context),
        _circle(context),
      ],
    );
  }

  Widget _circle(BuildContext context) {
    return Positioned(
      left: _padding,
      right: _padding,
      child: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        radius: _avatarRadius,
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: _avatarRadius + _padding,
        bottom: _padding,
        left: _padding,
        right: _padding,
      ),
      margin: EdgeInsets.only(top: _avatarRadius),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(_padding),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 24.0),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
