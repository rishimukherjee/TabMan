#TabMan

#### This is a table manager for restaurants. Restaurants can:

1. Create floors and add tables of 4 types on them.
2. The app makes sure the tables do not overlap.
3. Floors can be saved and can be edited.
4. Tables can change position on editiing of saved `floor` but more tables cannot be added.

#### To install the app:

1. Install Cocoapods
2. clone the repo
3. Do a `pod install`
4. Start the app from `TabMan.xcworkspace`
5. `iOS 9.2` is minimum version needed to run the app.
6. Use `Xcode 7.2`

#### How the code is organized:

The project is divided into the following:

1. `Utils`
  * `DragDropManager`: Manages the whole drag and drop in the system. Takes decision on adding and delete of Tables based on its start and destination superviews. Also, puts back a view to its picked up location if it ended on invalid location. It uses `UIPanGestureRecognizer` to handle drag gestures. 
  * `DragContext`: The current drag context. It has all information of the current dragged view.

2. `Views`
  * `TableImageView`: Subclass of `UIImageView` which changes image based on the type of the table.

3. `Models`
  * `Table`: Stores information about a table like table type, table location on floor, area and number.
  * `Floor`: It stores the floor `id` and a list of `Table` which are kept on the floor.

4. `ViewController`: Handles the button press actions, decides what to do based on when the save button was pressed, decides when to show the saved floor selector `UITableView` and when to show the table type selector.

5. `Main.storyboard`: Autolayout is used to layout views. The size of the table picker is kept constant and the size of the floor changes in different screen sizes.


#### Design Decisions
1. I used `realm` for percistance because of its simplicity and readability.
2. The drag and drop is handled in a separate class `DragDropManager` to avoid large viewController.

#### Trade-offs
1. Currently the app does not support adding tables while editing saved floors.


#### Third Party Library
1. [Realm](https://realm.io/)
2. Took idea on how to drag and drop from view to another [here](http://www.ancientprogramming.com/2012/04/05/drag-and-drop-between-multiple-uiviews-in-ios/)
