import QtQuick 2.0
import QtQuick.Layouts 1.11
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import "utils.js" as Utils

FocusScope {
    id: root

    FontLoader { id: titleFont; source: "assets/fonts/HelveticaNowText-Bold.ttf" }
    FontLoader { id: subtitleFont; source: "assets/fonts/HelveticaNowText-Light.ttf" }
    FontLoader { id: bodyFont; source: "assets/fonts/HelveticaNowText-Regular.ttf" }
    
    property int currentGameIndex: 0
    property int currentCollection: -1
    property int nextCollection: -1

    //onNextCollectionChanged: { collectionChangeAnim.start() }
    
    function changeCollection() {
        if (nextCollection != currentCollection) {
            currentCollection = nextCollection;
        }
    }

    // Launch the current game
    function launchGame(game) {
        api.memory.set('Last Collection', currentCollection);
        if (game != null)
            game.launch();
        else
            currentGame.launch();
    }

    property bool darkMode: api.memory.has('Dark Mode') ? api.memory.get('Dark Mode') : false
    onDarkModeChanged: api.memory.set('Dark Mode', darkMode)

    // Theme settings
    property var theme: {
        if (darkMode) {
            return {
                main:       "#1c1c1c",
                secondary:  "#202a44",
                accent:     "#f00980",
                highlight:  "#f00980",
                text:       "#ffffff",
                button:     "#f00980"
            }
        } else {
            return {
                main:       "#ffffff",
                secondary:  "#202a44",
                accent:     "#f00980",
                highlight:  "#f00980",
                text:       "#212121",
                button:     "#f00980"
            }
        }
    }

    // State settings
    states: [
        State {
            name: "homescreen";
        },
        State {
            name: "allgames";
        },
        State {
            name: "topgames";
        },
        State {
            name: "settings";
        },
        State {
            name: "collections";
        },
        State {
            name: "search";
        },
        State {
            name: "navigation";
        }
    ]

    property var lastState: []
    property var currentView: collectionView
    property var nextView: collectionView
    property string nextState: "homescreen"
    property bool collectionMenuOpen
    
    //onNextStateChanged: { collectionChangeAnim.start() }

    function changeState() {
        if (nextState != root.state) {
            lastState.push(root.state);
            root.state = nextState;
            currentView = nextView;
            resetLists();
            currentView.focus = true
        }
    }

    function homeScreen() {
        nextView = collectionView;
        nextState = "homescreen";
        currentView.focus = true
        navigationList.menu.currentIndex = 1;
        collectionChangeAnim.start()
    }

    function allGamesScreen() {
        nextView = gameGrid;
        nextState = "allgames";
        collectionChangeAnim.start();
        currentView.focus = true
    }

    function topGamesScreen() {
        nextView = gameGrid;
        nextState = "topgames";
        collectionChangeAnim.start();
        currentView.focus = true
    }

    function searchScreen() {
        nextView = searchGrid;
        nextState = "search";
        collectionChangeAnim.start();
        currentView.focus = true
    }

    property var savedFocus;

    function openCollectionsMenu(savedFocusElement) {
        collectionList.width = vpx(300);
        collectionList.focus = true;
        currentView.opacity = 0.1;
        collectionMenuOpen = true;
        navigationList.menu.currentIndex = 0;
        if (savedFocusElement)
            savedFocus = savedFocusElement;
    }

    function closeCollectionsMenu(cancel) {
        collectionList.width = 0;
        currentView.opacity = 1;
        collectionMenuOpen = false;
        if (cancel)
            savedFocus.focus = true;
    }

    function navigationMenu() {
        navigationList.focus = true;
    }

    function resetLists() {
        gameGrid.menu.currentIndex = 0;
        collectionView.menu.currentIndex = 0;
    }

    Component.onCompleted: {
        currentView.focus = true
    }

    // List specific input
    Keys.onPressed: {
        // Open collections menu
        if (api.keys.isFilters(event) && !event.isAutoRepeat) {
            event.accepted = true;
            if (collectionMenuOpen)
                closeCollectionsMenu(true);
            else
                openCollectionsMenu(currentView);
        }

        // Cycle collection forward
        if (api.keys.isNextPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            if (currentCollection < api.collections.count-1) {
                nextCollection++;
            } else {
                nextCollection = -1;
            }
            collectionChangeAnim.start();
        }

        // Cycle collection back
        if (api.keys.isPrevPage(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            if (currentCollection == -1) {
                nextCollection = api.collections.count-1;
            } else{ 
                nextCollection--;
            }
            collectionChangeAnim.start();
        }
    }

    // Background
    Rectangle {
    id: background
        
        anchors.fill: parent
        color: theme.main

        Image {
        id: blurBG

            source: "assets/images/131.jpg"
            sourceSize { width: 1280; height: 720 }
            anchors.fill: parent
            opacity: darkMode ? 0.1 : 0.4
        }
    }

    Navigation {
    id: navigationList

        width: vpx(100)
        height: parent.height
        collectionData: api.collections
        z: 100
    }

    CollectionView {
    id: collectionView

        anchors {
            left: collectionList.right;
            top: parent.top;
            bottom: parent.bottom
        }
        width: root.width - navigationList.width
        visible: opacity != 0
    }

    GameGrid {
    id: gameGrid

        anchors {
            left: collectionList.right;
            top: parent.top;
            bottom: parent.bottom
        }
        width: root.width - navigationList.width
        opacity: 0
        visible: opacity != 0
        currentState: root.state
    }

    Search {
    id: searchGrid

        anchors {
            left: collectionList.right;
            top: parent.top;
            bottom: parent.bottom
        }
        width: root.width - navigationList.width
        opacity: 0
        visible: opacity != 0
    }

    CollectionList {
    id: collectionList

        width: vpx(0)
        Behavior on width { PropertyAnimation { duration: 150; easing.type: Easing.OutQuart; easing.amplitude: 2.0; easing.period: 1.5 } }
        height: parent.height
        anchors {
            left: navigationList.right;
            top: parent.top;
            bottom: parent.bottom
        }
    }

    /*transitions: [
        Transition {
            from: "*"; to: "allgames"
            SequentialAnimation {
                NumberAnimation { target: currentView; property: "opacity"; to: 0.0; duration: 100 }
                PauseAnimation  { duration: 100 }
                NumberAnimation { target: gameGrid; property: "opacity"; to: 1.0; duration: 200 }
            }
        }, 
        Transition {
            from: "*"; to: "homescreen"
            SequentialAnimation {
                NumberAnimation { target: currentView; property: "opacity"; to: 0.0; duration: 100 }
                PauseAnimation  { duration: 100 }
                NumberAnimation { target: collectionView; property: "opacity"; to: 1.0; duration: 200 }
            }
        }, 
        Transition {
            from: "*"; to: "topgames"
            SequentialAnimation {
                NumberAnimation { target: currentView; property: "opacity"; to: 0.0; duration: 100 }
                PauseAnimation  { duration: 100 }
                NumberAnimation { target: gameGrid; property: "opacity"; to: 1.0; duration: 200 }
            }
        }
    ]//*/
    
    SequentialAnimation {
    id: collectionChangeAnim

        running: false
        NumberAnimation { target: currentView; property: "opacity"; to: 0.0; duration: 100 }
        ScriptAction    { script: changeCollection(); }
        ScriptAction    { script: changeState(); }
        PauseAnimation  { duration: 100 }
        NumberAnimation { target: nextView; property: "opacity"; to: 1.0; duration: 200 }
    }

    ///////////////////
    // SOUND EFFECTS //
    ///////////////////
    SoundEffect {
        id: sfxNav
        source: "assets/sfx/navigation.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxBack
        source: "assets/sfx/back.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxAccept
        source: "assets/sfx/accept.wav"
    }

    SoundEffect {
        id: sfxToggle
        source: "assets/sfx/toggle.wav"
    }

}