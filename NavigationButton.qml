import QtQuick 2.12
import QtGraphicalEffects 1.0

FocusScope {
id: root 

    property bool selected
    property bool highlighted
    property bool active
    property bool showLabel
    property alias icon: systemImage.source
    property alias label: label.text
    width: parent.width
    height: width

    signal activated

    scale: selected ? 1 : 0.95
    Behavior on scale { NumberAnimation { duration: 100 } }

    Rectangle {
    id: selectionBorder

        width: Math.round(parent.width * 1.2)
        height: width
        
        anchors.centerIn: systemImage
        
        opacity: selected || highlighted ? 1 : 0
        radius: width/2

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#f34225" }
            GradientStop { position: 1.0; color: "#bb2960" }
        }
        visible: selected || highlighted
    }

    Rectangle {
    id: selectionmask

        anchors.fill: selectionBorder
        radius: width/2
        anchors.margins: vpx(2)
        color: theme.main
        visible: !showLabel && selected
    }
    
    Image {
    id: systemImage

        width: vpx(36)
        height: width
        anchors.centerIn: parent
        sourceSize { width: vpx(64); height: vpx(64) }
        fillMode: Image.PreserveAspectFit
        smooth: true
        visible: false
    }

    ColorOverlay {
        anchors.fill: systemImage
        source: systemImage
        color: (selected && showLabel) || (highlighted && !selected) ? "white" : theme.secondary
    }

    Rectangle {
    id: labelContainer

        width: label.paintedWidth + vpx(30)
        height: vpx(50)
        anchors { 
            left: selectionBorder.right; leftMargin: vpx(10)
            verticalCenter: selectionBorder.verticalCenter
        }
        radius: height/2
        visible: showLabel
        color: theme.main
        
        Text {
        id: label

            text: ""
            anchors.fill: parent
            anchors { left: parent.left; leftMargin: vpx(15)}
            font.family: subtitleFont.name
            font.pixelSize: vpx(16)
            font.bold: true
            color: theme.text
            verticalAlignment: Text.AlignVCenter
        }
    }

    // List specific input
    Keys.onPressed: {
        // Accept
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            sfxToggle.play();
            activated();
        }
    }

    // Mouse/touch functionality
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: { highlighted = true }
        onExited: { highlighted = false }
        onClicked: {
            activated();
        }
    }
}