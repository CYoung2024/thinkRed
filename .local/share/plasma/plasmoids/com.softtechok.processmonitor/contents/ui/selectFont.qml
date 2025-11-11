/*
 * Copyright 2023 Barry Strong <bstrong@softtechok.com>
 *
 * This file is part of Process Monitor Plasmoid
 *
 * Process Monitor Plasmoid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Process Monitor Plasmoid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with System Monitor Plasmoid.  If not, see <https://www.gnu.org/licenses/>.
*/
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Processes

Item {
    property alias cfg_systemFont: systemFont.checked
    property alias cfg_fontFamily: fontList.currentText
    property alias cfg_fontSize: sizeList.currentText
    property font sysFont: pinfo.getSystemFont()
    PInfo {
        id: pinfo
    }
    QtObject {
        id: data
        property var fontFamily
        property var fontSize
    }
    ColumnLayout {
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            CheckBox {
                id: systemFont
                text: i18n("Use System Font: " + sysFont.family + i18n("    Size: ") +
                    sysFont.pointSize)
            }
        }
        ListModel {
            id: fontModel
        }
        ListModel {
            id: sizeModel
        }
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            Label {
                text: i18n("Font:")
            }
            ComboBox {
                id: fontList
                model: fontModel
                enabled: !systemFont.checked
                onActivated: {
                    var sizes
                    var prevIdx

                    sizes = pinfo.getFontSizes(currentText)
                    prevIdx = sizeList.currentIndex;
                    for (var idx = 0; idx < sizes.length; idx ++)
                        if (idx < sizes.length) {
                            sizeModel.set(idx, {size: sizes[idx]})
                        } else {
                            sizeModel.append({size: sizes[idx]});
                        }
                    if (prevIdx < sizes.length) {
                        sizeList.currentIndex = prevIdx;
                    } else {
                        for (var idx = 0; idx < sizeModel.count; idx++) {
                            if (sizeModel.get(idx).size == sysFont.pointSize) {
                                sizeList.currentIndex = idx;
                                break;
                            }
                        }
                    }
                }
            }
            Label {
                text: i18n("Size:")
            }
            ComboBox {
                id: sizeList
                model: sizeModel
                enabled: !systemFont.checked
            }
            Component.onCompleted: {
                var fonts
                var sizes
                var curFont;

                fontModel.clear();
                fonts = pinfo.getFixedFonts();
                for (var idx = 0; idx < fonts.length; idx++)
                    fontModel.append({fontFamily: fonts[idx]});
                fontList.currentIndex = 0;
                for (var idx = 0; idx < fontModel.count; idx++) {
                    if (fontModel.get(idx).fontFamily == plasmoid.configuration.fontFamily) {
                        fontList.currentIndex = idx;
                        break;
                    }
                }
                sizes = pinfo.getFontSizes(fontList.currentText)
                sizeModel.clear();
                for (var idx = 0; idx < sizes.length; idx ++)
                    sizeModel.append({fontSize: sizes[idx]});
                sizeList.currentIndex = 0;
                for (var idx = 0; idx < sizeModel.count; idx++) {
                    if (sizeModel.get(idx).fontSize == plasmoid.configuration.fontSize) {
                        sizeList.currentIndex = idx;
                        break;
                    }
                }
            }
        }
        Label {
            id: sampleText
            property var fontFamily: systemFont.checked ? sysFont.family : fontList.currentText
            property var fontSize: systemFont.checked ? sysFont.pointSize : sizeList.currentText
            font.family: fontFamily
            font.pointSize: fontSize
            font.bold: false
            text: "Sample text for chosen font 10.0%"
        }
    }
}
