import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import "utils.js" as Utils

FocusScope {
id: root

    property var collectionData
    property alias menu: navView

    function activated(name) {
        collections.focus = true;
        switch (name) {
            case "Home":
                homeScreen();
                break;
            case "All Games":
                allGamesScreen();
                break;
            case "Top Rated":
                topGamesScreen();
                break;
            case "Search":
                searchScreen();
                break;
        }
    }

    Keys.onRightPressed: {
        sfxNav.play();
        currentView.focus = true;
    }
    
    // Logo
    Image {
    id: logo

        anchors {
            left: parent.left;
            right: parent.right;
            top: parent.top;
            margins: vpx(15)
        }
        height: width
        source: "assets/images/logo.png"
        sourceSize { width: vpx(100); height: vpx(100) }
        fillMode: Image.PreserveAspectFit 
        smooth: true
    }

    Rectangle {
    id: separator

        anchors {
            right: parent.right;
            top: parent.top;
            bottom: parent.bottom
        }
        width: 2
        opacity: 0.05
        color: "black"
    }

    function setIndex(idx) {
        root.focus = true;
        navView.currentIndex = idx;
    }

    ObjectModel {
    id: navModel

        NavigationButton {
            selected: PathView.isCurrentItem
            icon: "assets/images/navigation/Platforms.png"
            label: (currentCollection != -1) ? api.collections.get(currentCollection).name : "All Games"
            showLabel: selected && root.focus
            width: vpx(46)
            anchors { top: parent.top; }
            onActivated: {
                setIndex(ObjectModel.index);
                if (!collectionMenuOpen)
                    openCollectionsMenu(root);
                else
                    closeCollectionsMenu(true);
            }
        }
        NavigationButton {
            selected: PathView.isCurrentItem
            icon: "assets/images/navigation/Home.png"
            label: "Home"
            showLabel: selected && root.focus
            width: vpx(46)
            onActivated: {
                setIndex(ObjectModel.index);
                closeCollectionsMenu();
                homeScreen();
            }
        }
        NavigationButton {
            selected: PathView.isCurrentItem
            icon: "assets/images/navigation/All Games.png"
            label: "All Games"
            showLabel: selected && root.focus
            width: vpx(46)
            onActivated: {
                setIndex(ObjectModel.index);
                closeCollectionsMenu();
                allGamesScreen();
            }
        }
        NavigationButton {
            selected: PathView.isCurrentItem
            icon: "assets/images/navigation/Top Rated.png"
            label: "Top Rated Games"
            showLabel: selected && root.focus
            width: vpx(46)
            onActivated: {
                setIndex(ObjectModel.index);
                closeCollectionsMenu();
                topGamesScreen();
            }
        }
        NavigationButton {
            selected: PathView.isCurrentItem
            icon: "assets/images/navigation/Search.png"
            label: "Search"
            showLabel: selected && root.focus
            width: vpx(46)
            onActivated: {
                setIndex(ObjectModel.index);
                closeCollectionsMenu();
                searchScreen();
            }
        }
        NavigationButton {
            selected: PathView.isCurrentItem
            icon: "assets/images/navigation/Settings.png"
            label: "Settings"
            showLabel: selected && root.focus
            anchors { bottom: parent.bottom; bottomMargin: vpx(25)}
            width: vpx(46)
            onActivated: {
                setIndex(ObjectModel.index);
                closeCollectionsMenu();
                mainMenu.focus = true;
            }
        }
    }

    PathView {
    id: navView

        anchors {
            top: logo.bottom; 
            left: parent.left;
            right: parent.right
            bottom: parent.bottom
        }
        focus: true
        interactive: false
        highlightRangeMode: PathView.NoHighlightRange
        
        Component.onCompleted: currentIndex = 1 // Set "Home" to be default selected
        
        model: navModel
        path: Path {
            startX: vpx(50); startY: vpx(100)
            PathLine { x: vpx(50); y: vpx(540); }
        }

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex(); }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex(); }
    }
}
