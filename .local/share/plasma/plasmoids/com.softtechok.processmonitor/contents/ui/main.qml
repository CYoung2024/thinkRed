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
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.StandardBackground | PlasmaCore.Types.ConfigurableBackground
    fullRepresentation: FullRepresentation {}
    function setForm() {
        switch (Plasmoid.formFactor) {
            case PlasmaCore.Types.Vertical:
                switchWidth = Kirigami.Units.gridUnit * 5;
                switchHeight = 1;
                break;
            case PlasmaCore.Types.Horizontal:
                switchWidth =  1;
                switchHeight = Kirigami.Units.gridUnit * 5;
                break;
            default:
                switchWidth =  Kirigami.Units.gridUnit * 5;
                switchHeight = Kirigami.Units.gridUnit * 5;
        }
    }
    Component.onCompleted: {
        setForm();
    }
    Plasmoid.onFormFactorChanged: {
        setForm();
    }
}
