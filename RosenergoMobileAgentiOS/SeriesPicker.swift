//
//  SeriesPicker.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 05.08.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct SeriesPicker: View {
    @Binding var selectedSeries: Series

    var body: some View {
        Picker(selection: $selectedSeries, label:
            Text("\(selectedSeries.rawValue)")
                .frame(width: 70)
                .foregroundColor(Color.secondary.opacity(0.6))) {
            Text("ХХХ").tag(Series.XXX)
            Text("ССС").tag(Series.CCC)
            Text("РРР").tag(Series.PPP)
            Text("ННН").tag(Series.HHH)
            Text("МММ").tag(Series.MMM)
            Text("ККК").tag(Series.KKK)
            Text("ЕЕЕ").tag(Series.EEE)
            Text("ВВВ").tag(Series.BBB)
        }
        .pickerStyle(MenuPickerStyle())
    }
}

enum Series: String, CaseIterable, Identifiable {
    case XXX
    case CCC
    case PPP
    case HHH
    case MMM
    case KKK
    case EEE
    case BBB

    var id: String { rawValue }
}
