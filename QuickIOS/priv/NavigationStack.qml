/**
    NavigationStack provides a stackbased navigation model used within NavigationView

    Author: Ben Lau (benlau)
    License: Apache License
    Project: https://github.com/hilarycheng/quickios
 */

import QtQuick 2.0
import QtQuick.Controls 1.2
import "../util.js" as Util

Item {
    id: navigationView

    property ListModel views : ListModel {}
    property var initialView

    signal pushed(var view)

    function push(source,options) {        
        var container = containerFactory.createObject(navigationView);
        var view = Util.createObject(source,container,options);
        if (view === undefined) {
            container.destroy();
            return;
        }

        view.anchors.fill = container;

        stack.push(container);
        views.append({object: view});
        pushed(view);
    }

    function pop() {
        if (stack.depth == 1)
            return;
        stack.pop();
        views.remove(views.count - 1,1);
    }

    width: 100
    height: 62

    StackView {
        id : stack
        anchors.fill: parent
        delegate: NavigationViewTransition {}        
    }

    Component {
        id: containerFactory

        Item {

            Stack.onStatusChanged:  {
                var child = children[0];
                switch (Stack.status) {
                case Stack.Inactive :
                    if (child.hasOwnProperty("viewDidDisappear"))
                        child.viewDidDisappear(true);
                    break;
                case Stack.Activating :
                    if (child.hasOwnProperty("viewWillAppear"))
                        child.viewWillAppear(true);
                    break;
                case Stack.Active :
                    if (child.hasOwnProperty("viewDidAppear"))
                        child.viewDidAppear(true);
                    break;
                case Stack.Deactivating :
                    if (child.hasOwnProperty("viewWillDisappear"))
                        child.viewDidDisappear(true);
                    break;
                }
            }

        }
    }

    onInitialViewChanged: {
        if (initialView) {
            var container = containerFactory.createObject(navigationView);
            initialView.parent = container;
            initialView.anchors.fill = container;
            stack.initialItem = container;
            views.append({ object: initialView })
            pushed(initialView);
        }
    }

}
