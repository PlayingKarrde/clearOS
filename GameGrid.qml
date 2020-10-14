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

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;        max: 0 }
    ListAllGames    { id: listAllGames; }
    ListFavorites   { id: listFavorites; }
    ListLastPlayed  { id: listLastPlayed; }
    ListTopGames    { id: listTopGames; }

    property var currentList: {
        switch (currentState) {
            case "allgames":
                return listAllGames;
                break;
            case "topgames": 
                return listTopGames;
                break;
            default:
                return listAllGames;
        }
    }
    Component {
    id: gridHeader 

        Item {
            
            height: vpx(90)
            Text {
            id: collectionName

                property string collectionTitle: currentCollection != -1 ? " - " + api.collections.get(currentCollection).name : ""
                property string pageTitle: currentState == "topgames" ? "Top games" : "All games"
                text: pageTitle + collectionTitle
                font.family: titleFont.name
                font.pixelSize: vpx(26)
                font.bold: true
                color: theme.text
                anchors { bottom: parent.bottom; bottomMargin: vpx(20)}
            }//*/
        }
    }

    GridView {
    id: gamegrid

        focus: true
        cellWidth: width / 4
        cellHeight: vpx(235)
        anchors { left: parent.left; leftMargin: vpx(25) }
        anchors { 
            top: parent.top;
            bottom: parent.bottom;
            left: parent.left; right: parent.right
        }
        preferredHighlightBegin: vpx(15)
        preferredHighlightEnd: parent.height
        header: gridHeader
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
            moveCurrentIndexUp();
        }
        Keys.onDownPressed: {
            sfxNav.play();
            moveCurrentIndexDown();
        }
    }
}