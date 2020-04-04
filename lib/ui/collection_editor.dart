import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rando/ui/util.dart';
import 'package:rando/model.dart';


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
    String value = await showInputDialog(
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
            background: dismissibleBackground(context),
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
    String value = await showInputDialog(context, "Add item", "Name", null);
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