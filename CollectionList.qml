import QtQuick 2.12
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import "utils.js" as Utils

FocusScope {
id: collectionList
    
    Rectangle {
        
        anchors.fill: parent
        
        color: theme.main

        // Build the collections list but with "All Games" as starting element
        ListModel {
        id: collectionsModel

            ListElement { name: "All Games"; shortName: "allgames"; games: "0" }

            Component.onCompleted: {
                for(var i=0; i<api.collections.count; i++) {
                    append(createListElement(i));
                }
            }
            
            function createListElement(i) {
                return {
                    name:       api.collections.get(i).name,
                    shortName:  api.collections.get(i).shortName,
                    games:      api.collections.get(i).games.count.toString()
                }
            }
        }

        ListView {
        id: collList

            anchors.fill: parent
            spacing: vpx(5)
            model: collectionsModel
            keyNavigationWraps: true
            preferredHighlightBegin: parent.height/2 - vpx(45)
            preferredHighlightEnd: parent.height/2
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 100
            Component.onCompleted: { currentIndex = currentCollection + 1; }
            focus: true
                
            Keys.onLeftPressed: { sfxNav.play(); closeCollectionsMenu(true); }
            Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex(); } 
            Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex(); }

            delegate: 
            Item {
                property var selected: ListView.isCurrentItem
                property var highlighted
                width: collList.width
                height: vpx(40)

                Rectangle {
                id: buttonBG

                    radius: vpx(15)
                    anchors.fill: parent
                    anchors { leftMargin: vpx(10); rightMargin: vpx(10) }

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: selected ? "#f34225" : "transparent" }
                        GradientStop { position: 1.0; color: selected ? "#bb2960" : "transparent" }
                    }
                }

                Text {
                id: collectionName

                    text: name
                    anchors.fill: buttonBG
                    anchors.margins: vpx(15)
                    font.family: bodyFont.name
                    font.pixelSize: vpx(16)
                    elide: Text.ElideRight
                    color: selected ? "white" : theme.text
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    visible: collectionList.width != 0
                }

                // List specific input
                Keys.onPressed: {
                    // Accept
                    if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                        event.accepted = true;
                        sfxAccept.play();
                        closeCollectionsMenu();
                        nextCollection = collList.currentIndex -1;
                        homeScreen();
                    }
                    
                    // Back
                    if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                        sfxBack.play();
                        event.accepted = true;
                        closeCollectionsMenu(true);
                    }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { highlighted = true }
                    onExited: { highlighted = false }
                    onClicked: {
                        collList.currentIndex = index;
                        closeCollectionsMenu();
                        sfxAccept.play();
                        nextCollection = collList.currentIndex -1;
                        homeScreen();
                    }
                }
            }
            
            header: spacer
            footer: spacer
            Component {
            id: spacer 
                Item {
                    width: 1
                    height: vpx(15)
                }
            }
        }
    }
}