//
//  Widget.swift
//  Widget
//
//  Created by Дмитрий Лисин on 03.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    public typealias Entry = SimpleEntry

    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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
    public let date: Date
}

struct PlaceholderView: View {
    var body: some View {
        ProgressView()
    }
}

struct WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

struct Test: View {
    var body: some View {
        ZStack {
            Color("rosenergo")
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Осмотры")
                    .fontWeight(.bold)
                    .padding(.bottom, 6)
                    .foregroundColor(.white)
                Text("Осмотры не отправлены на серввер")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .padding(.bottom, 6)
                Text("\(4) осмотра")
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "tray.circle.fill")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }.padding()
        }
    }
}

@main
struct WidgetApp: Widget {
    private let kind: String = "Widget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(), placeholder: PlaceholderView()) { entry in
            Test()
        }
        .configurationDisplayName("Мобильный агент")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
