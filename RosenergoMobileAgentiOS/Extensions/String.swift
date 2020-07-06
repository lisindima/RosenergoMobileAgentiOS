//
//  String.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 05.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

extension String {
    func dataInspection(local: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = local ? "yyyy-MM-dd HH:mm:ss" : "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        let date = dateFormatter.date(from: self)
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
        let dataInspection = newDateFormatter.string(from: date!)
        return dataInspection
    }
}
