# rando

Simple app for making collections of stuff and easily rolling a die to pick one at random. You could have, for example, a list of restaraunts, and just tap the associated dice icon to pick one at random.

## TODO

1) ~~Need to rename from `com.example.rando` to `org.zakariya.rando`~~
2) ~~[Refactor state flow](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)~~
3) Refactor/cleanup UI
    - [Make collection editor scroll to dismiss](https://pub.dev/packages/stopper#-example-tab-)
        - https://pub.dev/packages/sliding_sheet
    - [use a grid for main list](https://flutter.dev/docs/cookbook/lists/grid-lists)
    - the modal sheets are draggable, so put a handle on top?
    - add another button to the Add Item... dialog, "Add ANother" or something which indicates to add the current, but keep dialog open to add another item
    - be smarter about sheet height; it is too tall
    - if I monitor dismiss direction, I can show the trashcan icon only on left or right, instead of both, which looks weird.
        - possibly use dragStart
    - ~~how to make bottom bar area transparent on android (when using gestural nav)?~~
        - not supported by Flutter. :(
    - ~~word wrap long collection names~~
    - ~~need dice icon for the catalog list~~
    - ~~need to make the dice roll dialog not suck~~
    - ~~need an about screen which attributes flaticon.com~~

Icon Sources:
    [Freepic](https://www.flaticon.com/authors/freepik)
