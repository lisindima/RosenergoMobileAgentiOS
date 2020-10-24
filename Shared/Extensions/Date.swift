//
//  Date.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 05.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

extension Date {
    func convertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM yyyy HH:mm")
        dateFormatter.timeZone = .autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
}
