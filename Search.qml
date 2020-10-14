import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils

FocusScope {
id: root

    property var currentState
    property alias menu: gamegrid
    property string search

    // Pull in our custom lists and define
    ListAllGames    { id: listAllGames; searchTerm: search}

    property var currentList: listAllGames
    
    Item {
    id: searchBar

        anchors {
            left: parent.left;
            right: parent.right;
            top: parent.top;
        }
        height: vpx(200)
        z: 100
        
        Rectangle {
            anchors {
                left: parent.left;
                right: parent.right;
                top: parent.top;
                bottom: parent.bottom;
                margins: vpx(70)
            }
            color: "white"
            radius: height/2
            border.width: vpx(2)
            border.color: "#d9d9d9"

            TextInput {
            id: searchInput

                focus: true
                anchors {
                    left: parent.left; leftMargin: vpx(25)
                    right: parent.right; rightMargin: vpx(25)
                    top: parent.top;
                    bottom: parent.bottom;
                    margins: vpx(10)
                }
                verticalAlignment: Text.AlignVCenter
                color: theme.text
                font.family: bodyFont.name
                font.pixelSize: vpx(24)
                onTextEdited: {
                    search = searchInput.text
                }

                Keys.onDownPressed: { sfxNav.play(); gamegrid.focus = true; gamegrid.currentIndex = 0 }
            }

            Text {
            id: searchDefault

                focus: true
                anchors {
                    left: parent.left; leftMargin: vpx(25)
                    right: parent.right; rightMargin: vpx(25)
                    top: parent.top;
                    bottom: parent.bottom;
                    margins: vpx(10)
                }
                text: "Search..."
                verticalAlignment: Text.AlignVCenter
                color: theme.text
                opacity: searchInput.length > 0 ? 0 : 0.3
                Behavior on opacity { NumberAnimation { duration: 50 } }
                font.family: bodyFont.name
                font.pixelSize: vpx(24)
            }

            Rectangle {
            id: highlightborder

                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#f34225" }
                    GradientStop { position: 1.0; color: "#bb2960" }
                }
                visible: false
            }

            Rectangle {
            id: highlightbordermask

                anchors.fill: parent
                color: "transparent"
                radius: height/2
                border.width: vpx(2)
                border.color: "white"
                visible: false
            }

            OpacityMask {
                anchors.fill: highlightborder
                source: highlightborder
                maskSource: highlightbordermask
                opacity: searchInput.focus
                Behavior on opacity { NumberAnimation { duration: 50 } }
            }
        }
        
    }

    GridView {
    id: gamegrid

        focus: true
        cellWidth: width / 4
        cellHeight: vpx(235)
        anchors { 
            top: searchBar.bottom;
            bottom: parent.bottom;
            left: parent.left; leftMargin: vpx(25) 
            right: parent.right
        }
        preferredHighlightBegin: vpx(15)
        preferredHighlightEnd: parent.height
        model: currentList.games
        delegate: boxartDelegate

        // We need to set to -1 so there are no selections in the grid
        currentIndex: focus ? currentGameIndex : -1
        onCurrentIndexChanged: {
            // Ensure that the game index is never set to -1
            if (currentIndex != -1)
                currentGameIndex = currentIndex;
        }

        Component {
        id: boxartDelegate

            GridItem {
            id: delegatecontainer

                selected:   GridView.isCurrentItem && root.focus
                gameData:   modelData
                width:      GridView.view.cellWidth
                height:     GridView.view.cellHeight

                // List specific input
                Keys.onPressed: {                    
                    // Back
                    if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        sfxBack.play();
                        navigationMenu();
                    }

                    // Favorites
                    if (api.keys.isDetails(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        sfxToggle.play();
                        modelData.favorite = !modelData.favorite;
                    }
                }
            }
        }

        property int col: currentIndex % 4;
        Keys.onLeftPressed: {
            sfxNav.play();
            if (col == 0)
                navigationMenu();
            else
                moveCurrentIndexLeft();
        }
        Keys.onRightPressed: {
            sfxNav.play();
            if (col != 3)
                moveCurrentIndexRight();
        }
        Keys.onUpPressed: { 
            sfxNav.play();
            if (gamegrid.currentIndex < 4) {
                searchInput.focus = true;
                gamegrid.currentIndex = -1;
            } else {
                moveCurrentIndexUp();
            }
        }
        Keys.onDownPressed: {
            sfxNav.play();
            moveCurrentIndexDown();
        }
    }
}