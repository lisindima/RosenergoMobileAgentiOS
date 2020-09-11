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
    
    func calenderTimeSinceNow() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        let years = components.year!
        let months = components.month!
        let days = components.day!
        let hours = components.hour!
        let minutes = components.minute!
        let seconds = components.second!

        if years > 0 {
            return "\(years) г. назад"
        } else if months > 0 {
            return "\(months) мес. назад"
        } else if days >= 7 {
            let weeks = days / 7
            return "\(weeks) нед. назад"
        } else if days > 0 {
            return "\(days) д. назад"
        } else if hours > 0 {
            return "\(hours) ч. назад"
        } else if minutes > 0 {
            return "\(minutes) мин. назад"
        } else {
            return "\(seconds) сек. назад"
        }
    }
}

