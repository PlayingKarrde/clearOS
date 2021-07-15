import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtQml.Models 2.10
import QtMultimedia 5.9
import "Lists"
import "utils.js" as Utils

FocusScope {
id: root

    // Pull in our custom lists and define
    ListAllGames    { id: listNone;         max: 0 }
    ListAllGames    { id: listAllGames;     max: 15 }
    ListFavorites   { id: listFavorites;    max: 15 }
    ListLastPlayed  { id: listLastPlayed;   max: 15 }
    ListTopGames    { id: listTopGames;     max: 15 }

    property var gameData: (currentCollection != -1) ? api.collections.get(currentCollection).games.get(Math.floor(Math.random() * api.collections.get(currentCollection).games.count)) : api.allGames.get(Math.floor(Math.random() * api.allGames.count))
    property alias menu: mainList

    ObjectModel {
    id: mainModel

        Item {
        id: featuredRecentGame

            width: parent.width
            height: vpx(350)
            property bool selected: ListView.isCurrentItem && root.focus

            Image {
            id: gamebg

                width: vpx(750)
                height: vpx(750)
                anchors {
                    right: parent.right; rightMargin: vpx(-75)
                    top: parent.top; topMargin: vpx(-275)
                }
                property var screenshotImage: (gameData && (gameData.collections.get(0).shortName === "retropie" || gameData.collections.get(0).shortName === "android")) ? gameData.assets.boxFront : (gameData.collections.get(0).shortName === "steam") ? Utils.fanArt(gameData) : gameData.assets.screenshots[0]
                source: gameData.assets.screenshots[0] ? gameData.assets.screenshots[0] : ""//screenshotImage
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(parent.width, parent.height)
                smooth: true
                asynchronous: true
                visible: false
            }

            // NOTE: Video Preview
            Component {
            id: videoPreviewWrapper

                Video {
                id: videocomponent

                    anchors.fill: parent
                    source: gameData.assets.videoList.length ? gameData.assets.videoList[0] : ""
                    fillMode: VideoOutput.PreserveAspectCrop
                    muted: true
                    loops: MediaPlayer.Infinite
                    autoPlay: true

                    //onPlaying: videocomponent.seek(5000)
                }

            }

            Item {
            id: videocontainer

                anchors.fill: gamebg

                // Video
                Loader {
                id: videoPreviewLoader

                    asynchronous: true
                    anchors { fill: parent }
                    sourceComponent: gameData.assets.videoList.length ? videoPreviewWrapper : undefined
                }
                visible: false
            }

            Image {
            id: gamemask

                anchors.fill: gamebg
            
                visible: false
                /*property string bgmask: {
                    if (currentCollection == -1) {
                        return "assets/images/bgmask.png";
                    } else {
                        var collectionName = Utils.processPlatformName(api.collections.get(currentCollection).shortName);
                        return "assets/images/logos/" + Utils.processPlatformName(api.collections.get(currentCollection).shortName) + ".svg"
                    }
                }*/
                source: "assets/images/bgmask.png"//bgmask
                sourceSize: Qt.size(parent.width, parent.height)
                fillMode: Image.PreserveAspectFit
            }

            OpacityMask {
                property bool video: gameData.assets.videoList.length
                anchors.fill: gamebg
                source: video ? videocontainer : gamebg
                maskSource: gamemask
                opacity: video ? 0.4 : 0.2
            }

            /*Image {
            id: favelogo

                width: height
                height: parent.height
                anchors { 
                    top: parent.top; topMargin: vpx(0)
                    right: parent.right; rightMargin: vpx(130)
                }
                property var logoImage: (gameData && gameData.collections.get(0).shortName === "retropie") ? gameData.assets.boxFront : (gameData.collections.get(0).shortName === "steam") ? Utils.logo(gameData) : gameData.assets.logo
                source: gameData ? logoImage || "" : ""
                sourceSize { width: vpx(350); height: vpx(350) }
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }//*/

            Text {
            id: collectionName

                text: gameData.collections.get(0).name//(gameData.playTime > 0) ? "Continue playing" : "Start playing"
                font.pixelSize: vpx(24)
                font.family: subtitleFont.name
                anchors {
                    top: parent.top; topMargin: vpx(90)
                    left: parent.left;
                }
                color: theme.text
                opacity: 0.7
            }

            Text {
            id: gameName

                text: gameData.title
                font.pixelSize: vpx(40)
                font.family: titleFont.name
                color: theme.text
                anchors {
                    top: collectionName.bottom; topMargin: vpx(-10)
                    left: parent.left;
                }
            }
            
            Rectangle {
            id: playButton

                width: playIcon.width + playText.paintedWidth + vpx(56)
                height: vpx(50)
                radius: vpx(15)
                anchors { top: gameName.bottom; topMargin: vpx(5)}
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: featuredRecentGame.selected ? "#f34225" : theme.secondary }
                    GradientStop { position: 1.0; color: featuredRecentGame.selected ? "#bb2960" : theme.secondary }
                }

                // Mouse/touch functionality
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {  }
                    onExited: {  }
                    onClicked: {
                        launchGame(gameData);
                    }
                }
            }

            Item {
            id: buttonContents

                anchors { 
                    verticalCenter: playButton.verticalCenter
                    left: playButton.left; leftMargin: vpx(25)
                }
                height: playIcon.height

                Image {
                id: playIcon

                    width: vpx(22)
                    height: width
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(playIcon.width, playIcon.height)
                    source: "assets/images/navigation/Play.png"
                }

                Text {
                id: playText

                    text: (gameData.playTime > 0) ? "Continue playing" : "Start playing"//"Play"
                    font.pixelSize: vpx(18)
                    font.family: bodyFont.name
                    font.bold: true
                    color: featuredRecentGame.selected ? "white" : theme.main
                    anchors {
                        left: playIcon.right; leftMargin: vpx(10)
                        top: parent.top
                        bottom: parent.bottom
                    }

                    verticalAlignment: Text.AlignVCenter
                }
            }
          
            // List specific input
            Keys.onPressed: {
                // Accept
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                    event.accepted = true;
                    sfxAccept.play();
                    launchGame(gameData);
                }
            }
            Keys.onLeftPressed: { sfxNav.play(); navigationMenu(); }
        }

        GameList {
        id: recentList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listLastPlayed.games

            height: vpx(285)

            title: "Recent"

            focus: selected
            anchors { left: parent.left; right: parent.right }

            
        }

        GameList {
        id: favouriteList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listFavorites.games

            height: vpx(300)

            title: "Favorites"

            focus: selected
            anchors { left: parent.left; right: parent.right }
        }

        GameList {
        id: topList

            property bool selected: ListView.isCurrentItem && root.focus
            property var currentList
            collectionData: listTopGames.games

            height: vpx(300)

            title: "Recommended"

            focus: selected
            anchors { left: parent.left; right: parent.right }
        }
    }

    ListView {
    id: mainList
        
        anchors.fill: parent
        anchors.margins: vpx(25)
        model: mainModel
        focus: true

        preferredHighlightBegin: vpx(0)
        preferredHighlightEnd: parent.height - vpx(60)
        highlightRangeMode: ListView.ApplyRange
        snapMode: ListView.SnapOneItem 
        highlightMoveDuration: 100

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
    }
}