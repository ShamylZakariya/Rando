import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rando/model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CollectionsStore(),
      child: RandoApp(),
    ),
  );
}

class RandoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rando",
      home: CollectionsScreen(),
      theme: ThemeData(primaryColor: Colors.yellow),
    );
  }
}

class CollectionsScreen extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rando"),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onNewCollection(context),
        tooltip: "New Collection",
        child: Icon(Icons.add),
      ),
    );
  }

  void _onNewCollection(BuildContext context) async {
    String name =
        await _showInputDialog(context, "New collection...", "Name", null);

    if (name != null && name.isNotEmpty) {
      Collection newCollection = Collection(name);
      Provider.of<CollectionsStore>(context, listen: false).add(newCollection);

      _showCollection(context, newCollection);
    }
  }

  Widget _body() {
    return Consumer<CollectionsStore>(
      builder: (context, store, child) {
        switch (store.loadState) {
          case LoadState.Unloaded:
            return _bodyForUnloadedState(context, store);
          case LoadState.Loading:
            return _bodyForLoadingState(context, store);
          case LoadState.Loaded:
            return store.isEmpty
                ? _bodyForLoadedEmptyState(context, store)
                : _bodyForLoadedState(context, store);
        }
        return null;
      },
    );
  }

  Widget _bodyForUnloadedState(BuildContext context, CollectionsStore store) {
    return Container();
  }

  Widget _bodyForLoadingState(BuildContext context, CollectionsStore store) {
    return Container();
  }

  Widget _bodyForLoadedEmptyState(
      BuildContext context, CollectionsStore store) {
    return Center(
      child: Column(
        children: <Widget>[
          MaterialButton(
            child: Text("Create a Collection..."),
            onPressed: () => _onNewCollection(context),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _bodyForLoadedState(BuildContext context, CollectionsStore store) {
    // show our list of Collections
    final Iterable<Widget> collections = store.collections.map((Collection c) {
      return _buildCollectionRow(context, c);
    });
    final List<Widget> divided =
        ListTile.divideTiles(context: context, tiles: collections).toList();
    return ListView(
      children: divided,
    );
  }

  Widget _buildCollectionRow(BuildContext context, Collection collection) {
    return ChangeNotifierProvider.value(
      value: collection,
      child: Consumer<Collection>(
        builder: (context, collection, _) {
          return Dismissible(
            background: Container(
              // TODO: Embed a delete icon
              color: Colors.red,
            ),
            key: Key(collection.name),
            onDismissed: (direction) {
              Provider.of<CollectionsStore>(context, listen: false)
                  .remove(collection);

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
                        _rollDiceFor(context, collection);
                      },
                    )
                  : null,
              onTap: () {
                _showCollection(context, collection);
              },
            ),
          );
        },
      ),
    );
  }

  void _showCollection(BuildContext context, Collection collection) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => ChangeNotifierProvider.value(
              value: collection,
              child: CollectionEditor(),
            ));
  }

  void _rollDiceFor(BuildContext context, Collection collection) {
    Item item = collection.randomItem();
    print("_rollDiceFor: ${collection.name} item: ${item.name}");
    showDialog(
        context: context,
        builder: (BuildContext context) => ShowDiceRollResultDialog(
            buttonText: "Ok", description: collection.name, title: item.name));
  }
}

//
//  CollectionEditor
//  TODO: Show collection editor as a bottom sheet or some other modal
//  appearance - it's confusing to have the collection editor show
//  immediately, it looks like nothing happened.
//

class CollectionEditor extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(collection.name),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editTitle(context, collection),
              )
            ],
          ),
          body: _itemList(context, collection),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addItem(context, collection),
            tooltip: "Add item...",
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _itemList(BuildContext context, Collection collection) {
    if (collection.isEmpty) {
      return Center(
        child: Column(
          children: <Widget>[
            MaterialButton(
              child: Text("Add some items..."),
              onPressed: () => _addItem(context, collection),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      );
    }

    final Iterable<Widget> items = collection.items.map((Item i) {
      return _buildItemRow(context, collection, i);
    });

    final List<Widget> divided =
        ListTile.divideTiles(context: context, tiles: items).toList();

    return ListView(
      children: divided,
    );
  }

  void _editTitle(BuildContext context, Collection collection) async {
    String value = await _showInputDialog(
        context, "Edit collection name:", "Collection name", collection.name);
    if (value != null && value.isNotEmpty) {
      collection.name = value;
    }
  }

  Widget _buildItemRow(BuildContext context, Collection collection, Item item) {
    return ChangeNotifierProvider.value(
      value: item,
      child: Consumer<Item>(
        builder: (context, item, _) {
          return Dismissible(
            background: Container(
              // TODO: Embed a delete icon
              color: Colors.red,
            ),
            key: Key(item.name),
            onDismissed: (direction) {
              collection.removeItem(item);
            },
            child: ListTile(
              title: Text(item.name, style: _biggerFont),
            ),
          );
        },
      ),
    );
  }

  void _addItem(BuildContext context, Collection collection) async {
    String value = await _showInputDialog(context, "Item", "Item Name", null);
    if (value != null && value.isNotEmpty) {
      collection.addItem(Item(value));
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

class ShowDiceRollResultDialog extends StatelessWidget {
  final String title, description, buttonText;

  static const double _padding = 16.0;
  static const double _avatarRadius = 66.0;

  ShowDiceRollResultDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _card(context),
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
