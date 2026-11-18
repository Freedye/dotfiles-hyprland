// Config created by Keyitdev https://github.com/Keyitdev/sddm-astronaut-theme
// Copyright (C) 2022-2025 Keyitdev
// Based on https://github.com/MarianArlt/sddm-sugar-dark
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Column {
    id: inputContainer
    
    Layout.fillWidth: true

    property ComboBox exposeSession: sessionSelect.exposeSession
    property bool failed
    property string errorText: ""

    Item {
        id: errorMessageField

        // change also in selectSession
        height: root.font.pointSize * 2
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: errorMessage

            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            
            text: failed ? errorText || config.translateLoginFailedWarning || textConstants.loginFailed + "!" : ""
            font.pointSize: root.font.pointSize * 0.8
            font.italic: true
            color: config.warningColor
            opacity: 0
            
            states: [
                State {
                    name: "fail"
                    when: failed
                    PropertyChanges {
                        target: errorMessage
                        opacity: 1
                    }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "opacity"
                        duration: 100
                    }
                }
            ]
        }
    }

    Item {
        id: usernameField

        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        ComboBox {
            id: selectUser

            width: parent.height
            height: parent.height
            anchors.left: parent.left
            z: 2

            model: userModel
            currentIndex: model.lastIndex
            textRole: "name"
            hoverEnabled: true
            contentItem: Item {}
            onActivated: {
                username.text = currentText
            }

            property var popkey: config.rightToLeftLayout == "true" ? Qt.Key_Right : Qt.Key_Left
            Keys.onPressed: function(event) {
                if (event.key == Qt.Key_Down && !popup.opened)
                    username.forceActiveFocus();
                if ((event.key == Qt.Key_Up || event.key == popkey) && !popup.opened)
                    popup.open();
                }
            KeyNavigation.down: username
            KeyNavigation.right: username

            delegate: ItemDelegate {
                //  minus padding
                width: popupHandler.width - 20
                anchors.horizontalCenter: popupHandler.horizontalCenter
                
                contentItem: Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    text: model.name
                    font.pointSize: root.font.pointSize * 0.8
                    font.capitalization: Font.AllLowercase
                    font.family: root.font.family
                    color: config.dropdownTextColor
                }
                
                background: Rectangle {
                    color: selectUser.highlightedIndex === index ? config.dropdownSelectedBackgroundColor : "transparent"
                }
            }

            indicator: Button {
                id: usernameIcon
                    
                width: selectUser.height * 1
                height: parent.height
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: selectUser.height * 0
                
                icon.height: parent.height * 0.25
                icon.width: parent.height * 0.25
                enabled: false
                icon.color: config.userIconColor
                icon.source: Qt.resolvedUrl("../Assets/User.svg")
                    
                background: Rectangle {
                    color: "transparent"
                    border.color: "transparent"
                }
            }

            background: Rectangle {
                color: "transparent"
                border.color: "transparent"
            }

            popup: Popup {
                id: popupHandler

                implicitHeight: contentItem.implicitHeight
                width: usernameField.width
                y: parent.height - username.height / 3
                x: 0
                rightMargin: config.rightToLeftLayout == "true" ? root.padding + usernameField.width / 2 : undefined
                padding: 10

                contentItem: ListView {
                    implicitHeight: contentHeight + 20
                    
                    clip: true
                    model: selectUser.popup.visible ? selectUser.delegateModel : null
                    currentIndex: selectUser.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    radius: config.roundCorners / 2
                    color: config.dropdownBackgroundColor
                    layer.enabled: true
                }

                enter: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1 }
                }
            }

            states: [
                State {
                    name: "pressed"
                    when: selectUser.down
                    PropertyChanges {
                        target: usernameIcon
                        icon.color: Qt.lighter(config.hoverUserIconColor, 1.1)
                    }
                },
                State {
                    name: "hovered"
                    when: selectUser.hovered
                    PropertyChanges {
                        target: usernameIcon
                        icon.color: Qt.lighter(config.hoverUserIconColor, 1.2)
                    }
                },
                State {
                    name: "focused"
                    when: selectUser.activeFocus
                    PropertyChanges {
                        target: usernameIcon
                        icon.color: config.hoverUserIconColor
                    }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "color, border.color, icon.color"
                        duration: 150
                    }
                }
            ]

        }

        TextField {
            id: username

            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            horizontalAlignment: TextInput.AlignHCenter
            z: 1

            text: config.forceLastUser == "true" ? selectUser.currentText : null
            color: config.loginFieldTextColor
            font.bold: true
            font.capitalization: config.allowUppercaseLettersInUsernames == "false" ? Font.AllLowercase : Font.MixedCase
            placeholderText: config.translatePlaceholderUsername || textConstants.userName
            placeholderTextColor: config.placeholderTextColor
            selectByMouse: true
            readOnly: auth.busy
            renderType: Text.QtRendering
            
            onFocusChanged:{
                if(focus)
                    selectAll()
            }

            background: Rectangle {
                color: config.loginFieldBackgroundColor
                opacity: 0.2
                border.color: "transparent"
                border.width: parent.activeFocus ? 2 : 1
                radius: config.roundCorners || 0
            }
            
            onAccepted: config.allowUppercaseLettersInUsernames == "false" ? auth.login(username.text.toLowerCase(), password.text, sessionSelect.selectedSession) : auth.login(username.text, password.text, sessionSelect.selectedSession)
            KeyNavigation.down: passwordIcon

            states: [
                State {
                    name: "focused"
                    when: username.activeFocus
                    PropertyChanges {
                        target: username.background
                        border.color: config.highlightBorderColor
                    }
                    PropertyChanges {
                        target: username
                        color: Qt.lighter(config.loginFieldTextColor, 1.15)
                    }
                }
            ]
        }
    }
    
    Item {
        id: passwordField

        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        
        Button {
            id: passwordIcon
            
            height: parent.height
            width: selectUser.height * 1
            anchors.left: parent.left
            anchors.leftMargin: selectUser.height * 0
            anchors.verticalCenter: parent.verticalCenter
            z: 2
            
            icon.height: parent.height * 0.25
            icon.width: parent.height * 0.25
            icon.color: config.passwordIconColor
            icon.source: Qt.resolvedUrl("../Assets/Password2.svg")

            background: Rectangle {
                color: "transparent"
                border.color: "transparent"
            }

            states: [
                State {
                    name: "visiblePasswordFocused"
                    when: passwordIcon.checked && passwordIcon.activeFocus
                    PropertyChanges {
                        target: passwordIcon
                        icon.source: Qt.resolvedUrl("../Assets/Password.svg")
                        icon.color: config.hoverPasswordIconColor
                    }
                },
                State {
                    name: "visiblePasswordHovered"
                    when: passwordIcon.checked && passwordIcon.hovered
                    PropertyChanges {
                        target: passwordIcon
                        icon.source: Qt.resolvedUrl("../Assets/Password.svg")
                        icon.color: config.hoverPasswordIconColor
                    }
                },
                State {
                    name: "visiblePassword"
                    when: passwordIcon.checked
                    PropertyChanges {
                        target: passwordIcon
                        icon.source: Qt.resolvedUrl("../Assets/Password.svg")
                    }
                },
                State {
                    name: "hiddenPasswordFocused"
                    when:  passwordIcon.enabled && passwordIcon.activeFocus
                    PropertyChanges {
                        target: passwordIcon
                        icon.source: Qt.resolvedUrl("../Assets/Password2.svg")
                        icon.color: config.hoverPasswordIconColor
                    }
                },
                State {
                    name: "hiddenPasswordHovered"
                    when: passwordIcon.hovered
                    PropertyChanges {
                        target: passwordIcon
                        icon.source: Qt.resolvedUrl("../Assets/Password2.svg")
                        icon.color: config.hoverPasswordIconColor
                    }
                }
            ]

            onClicked: toggle()
            Keys.onReturnPressed: toggle()
            Keys.onEnterPressed: toggle()
            KeyNavigation.down: password

        }

        TextField {
            id: password

            height: root.font.pointSize * 3
            width: parent.width
            anchors.centerIn: parent
            horizontalAlignment: TextInput.AlignHCenter
            
            font.bold: true
            color: config.passwordFieldTextColor
            focus: config.passwordFocus == "true" ? true : false
            echoMode: passwordIcon.checked ? TextInput.Normal : TextInput.Password
            placeholderText: config.translatePlaceholderPassword || textConstants.password
            placeholderTextColor: config.placeholderTextColor
            passwordCharacter: "•"
            passwordMaskDelay: config.hideCompletePassword == "true" ? undefined : 1000
            renderType: Text.QtRendering
            selectByMouse: true
            readOnly: auth.busy
            
            background: Rectangle {
                color: config.passwordFieldBackgroundColor
                opacity: 0.2
                border.color: "transparent"
                border.width: parent.activeFocus ? 2 : 1
                radius: config.roundCorners || 0
            }
            onAccepted: config.allowUppercaseLettersInUsernames == "false" ? auth.login(username.text.toLowerCase(), password.text, sessionSelect.selectedSession) : auth.login(username.text, password.text, sessionSelect.selectedSession)
        }

        states: [
            State {
                name: "focused"
                when: password.activeFocus
                PropertyChanges {
                    target: password.background
                    border.color: config.highlightBorderColor
                }
                PropertyChanges {
                    target: password
                    color: Qt.lighter(config.loginFieldTextColor, 1.15)
                }
            }
        ]
        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color, border.color"
                    duration: 150
                }
            }
        ]        
    }

    Connections {
        target: auth
        function onLoginSucceeded() {}
        function onLoginFailed(message) {
            errorText = message
            password.text = ""
            password.forceActiveFocus()
            failed = true
            resetError.running ? resetError.stop() && resetError.start() : resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 2000
        onTriggered: { failed = false; errorText = "" }
        running: false
    }
}
