import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rando/ui/about_screen.dart';

import 'package:rando/ui/collection_editor.dart';
import 'package:rando/ui/dice_roll_result.dart';
import 'package:rando/ui/util.dart';
import 'package:rando/model.dart';
import 'package:rando/common/theme.dart';

class CollectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(
            "rando",
            style: Theme.of(context).textTheme.headline6,
          ),
          onTap: () => _showAboutScreen(context),
        ),
        elevation: 0,
        actions: <Widget>[],
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

  void _showAboutScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AboutScreen(),
        ));
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

  Widget _bodyForLoadedEmptyState(BuildContext context, CollectionStore store) {
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
    return ListView(children: collections.toList());
  }

  Widget _buildCollectionRow(BuildContext context, Collection collection) {
    return ChangeNotifierProvider.value(
      value: collection,
      child: Consumer<Collection>(
        builder: (context, collection, _) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: Container(
              color: ThemeColors.canvasColorLight,
              child: Dismissible(
                background: dismissibleBackground(
                    context, DismissibleBackgroundIconPlacement.Left),
                secondaryBackground: dismissibleBackground(
                    context, DismissibleBackgroundIconPlacement.Right),
                key: Key(collection.name),
                onDismissed: (direction) =>
                    _deleteCollection(context, collection),
                child: ListTile(
                  title: Text(collection.name,
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showCollection(context, collection),
                  ),
                  onTap: () {
                    _rollDiceFor(context, collection);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteCollection(BuildContext context, Collection collection) {
    CollectionStore store =
        Provider.of<CollectionStore>(context, listen: false);
    int idx = store.indexOf(collection);
    store.remove(collection);

    ScaffoldMessenger.of(context).showSnackBar(
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
    _bottomSheet(context, collection, CollectionEditor());
  }

  void _rollDiceFor(BuildContext context, Collection collection) {
    _bottomSheet(context, collection, DiceRollResult());
  }

  void _bottomSheet(BuildContext context, Collection collection, Widget view) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            // layer a drag handle atop the sheet content view
            child: Stack(
              children: <Widget>[
                ChangeNotifierProvider.value(
                  value: collection,
                  child: view,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: Center(
                    heightFactor: 1,
                    child: SizedBox(
                      height: 3,
                      width: 48,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: ThemeColors.textColor.withAlpha(64)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
