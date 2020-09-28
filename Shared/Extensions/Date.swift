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
        dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        dateFormatter.timeZone = .autoupdatingCurrent
        return dateFormatter.string(from: self)
    }
}

func stringDate() -> String {
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let createStringDate = dateFormatter.string(from: currentDate)
    return createStringDate
}
