import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rando/ui/collection_editor.dart';
import 'package:rando/ui/util.dart';
import 'package:rando/model.dart';


class CollectionScreen extends StatelessWidget {
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
        await showInputDialog(context, "New collection...", "Name", null);

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
            background: dismissibleBackground(context),
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
    showDiceRollResultDialog(context, collection, item);
  }
}