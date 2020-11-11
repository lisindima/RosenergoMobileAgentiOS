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
        Picker(selection: $selectedSeries, label: Text("\(selectedSeries.rawValue)").foregroundColor(.primary)) {
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
        .frame(width: 70)
    }
}
