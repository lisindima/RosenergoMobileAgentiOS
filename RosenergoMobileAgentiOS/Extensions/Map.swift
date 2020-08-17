//
//  Map.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 07.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import MapKit
import SwiftUI

struct Pin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
