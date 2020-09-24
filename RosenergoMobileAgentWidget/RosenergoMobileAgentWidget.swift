//
//  RosenergoMobileAgentWidget.swift
//  RosenergoMobileAgentWidget
//
//  Created by Дмитрий Лисин on 24.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct RosenergoMobileAgentWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Осмотры")
                    .fontWeight(.bold)
                    .padding(.bottom, 1)
                    .foregroundColor(.white)
                Text("Осмотры не отправлены на сервер")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                Spacer()
                HStack {
                    Image(systemName: "tray.circle.fill")
                        .imageScale(.large)
                    Spacer()
                    Text("\(4) осмотра")
                        .fontWeight(.bold)
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            .padding()
        }
    }
}

@main
struct RosenergoMobileAgentWidget: Widget {
    let kind: String = "RosenergoMobileAgentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RosenergoMobileAgentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Не отправленные осмотры")
        .description("Виджет поможет вам не забыть отправить осмотр на сервер!")
        .supportedFamilies([.systemSmall])
    }
}

struct RosenergoMobileAgentWidget_Previews: PreviewProvider {
    static var previews: some View {
        RosenergoMobileAgentWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
