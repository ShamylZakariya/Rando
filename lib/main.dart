import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rando/common/theme.dart';
import 'package:rando/model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CollectionStore(),
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
      theme: appTheme(context),
    );
  }
}

class CollectionsScreen extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "rando",
          style: Theme.of(context).textTheme.title,
        ),
        elevation: 0,
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
      Provider.of<CollectionStore>(context, listen: false).add(newCollection);

      _showCollection(context, newCollection);
    }
  }

  Widget _body() {
    return Consumer<CollectionStore>(
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

  Widget _bodyForUnloadedState(BuildContext context, CollectionStore store) {
    return Container();
  }

  Widget _bodyForLoadingState(BuildContext context, CollectionStore store) {
    return Container();
  }

  Widget _bodyForLoadedEmptyState(
      BuildContext context, CollectionStore store) {
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

  Widget _bodyForLoadedState(BuildContext context, CollectionStore store) {
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
            background: _dismissibleBackground(context),
            key: Key(collection.name),
            onDismissed: (direction) => _deleteCollection(context, collection),
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

  void _deleteCollection(BuildContext context, Collection collection) {
    CollectionStore store = Provider.of<CollectionStore>(context, listen: false);
    int idx = store.indexOf(collection);
    store.remove(collection);

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted ${collection.name}"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            // re-insert the item at its original index
            store.insert(idx, collection);
          },
        ),
      ),
    );
  }

  void _showCollection(BuildContext context, Collection collection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: ChangeNotifierProvider.value(
              value: collection,
              child: CollectionEditor(),
            ),
          ),
        );
      },
    );
  }

  void _rollDiceFor(BuildContext context, Collection collection) {
    Item item = collection.randomItem();
    print("_rollDiceFor: ${collection.name} item: ${item.name}");
    _showDiceRollResultDialog(context, collection, item);
  }
}

//
//  CollectionEditor
//

class CollectionEditor extends StatelessWidget {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Consumer<Collection>(
      builder: (context, collection, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              collection.name,
              style: Theme.of(context).textTheme.subtitle,
            ),
            iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editTitle(context, collection),
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).canvasColor,
          ),
          body: _body(context, collection),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addItem(context, collection),
            tooltip: "Add item...",
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, Collection collection) {
    return _itemList(context, collection);
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
        context, "Rename", "Collection name", collection.name);
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
            background: _dismissibleBackground(context),
            key: Key(item.name),
            onDismissed: (direction) => _deleteItem(context, collection, item),
            child: ListTile(
              title: Text(item.name, style: _biggerFont),
            ),
          );
        },
      ),
    );
  }

  void _addItem(BuildContext context, Collection collection) async {
    String value = await _showInputDialog(context, "Add item", "Name", null);
    if (value != null && value.isNotEmpty) {
      collection.add(Item(value));
    }
  }

  void _deleteItem(BuildContext context, Collection collection, Item item) {
    int idx = collection.indexOf(item);
    collection.remove(item);
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted ${item.name}"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            // re-insert the item at its original index
            collection.insert(idx, item);
          },
        ),
      ),
    );
  }
}

//
//  DiceRollResultDialog
//

class DiceRollResultDialog extends StatelessWidget {
  final String title, description, buttonText;

  static const double _cornerRadius = 8;
  static const double _padding = 32;

  DiceRollResultDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      child: _card(context),
    );
  }

  Widget _card(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: _padding,
        bottom: _padding / 2,
        left: _padding,
        right: _padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            description,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.start,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

//
//  Helpers
//

void _showDiceRollResultDialog(
    BuildContext context, Collection collection, Item item) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "You got",
            style: Theme.of(context).textTheme.display1,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                style: Theme.of(context).textTheme.display3,
                textAlign: TextAlign.start,
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Future<String> _showInputDialog(BuildContext context, String title,
    String valueTitle, String initialValue) async {
  String text;
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context).textTheme.display1,
          ),
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

Widget _dismissibleBackground(BuildContext context) => Container(
      color: Colors.red,
      child: Row(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.delete,
              color: Colors.white.withAlpha(194),
            ),
          ),
          Spacer(),
          AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.delete,
              color: Colors.white.withAlpha(194),
            ),
          ),
        ],
      ),
    );
