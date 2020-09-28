//
//  RosenergoMobileAgentWidget.swift
//  RosenergoMobileAgentWidget
//
//  Created by Дмитрий Лисин on 24.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreData
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
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

struct SystemLarge: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Group {
                colorScheme == .light ? Color.blue : Color(.secondarySystemBackground)
            }
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Осмотры")
                    .fontWeight(.bold)
                Text("Не отправленные")
                    .fontWeight(.semibold)
                    .font(.caption2)
                Divider()
                ForEach(0 ..< 4) { _ in
                    HStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Group {
                                Text("ННН3123123".uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text("ННН3ВЫВ41В".uppercased())
                                    .fontWeight(.bold)
                                    .font(.caption)
                                Text(Date(), style: .date)
                                    .font(.caption)
                            }
                            .font(.footnote)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Image(systemName: "tray.circle.fill")
                        .imageScale(.large)
                    Spacer()
                    Text("\(4) осмотра")
                        .fontWeight(.bold)
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct SystemSmall: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var localInspections: FetchedResults<LocalInspections>
    
    var inspections: Int
    
    var body: some View {
        ZStack {
            Group {
                colorScheme == .light ? Color.blue : Color(.secondarySystemBackground)
            }
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Осмотры")
                    .fontWeight(.bold)
                Text("Не отправленные")
                    .fontWeight(.semibold)
                    .font(.caption2)
                Divider()
                Text("У вас есть не отправленные осмотры")
                    .font(.caption2)
                Spacer()
                HStack {
                    Image(systemName: "tray.circle.fill")
                        .imageScale(.large)
                    Spacer()
                    Text("\(localInspections.count) осмотров")
                        .fontWeight(.bold)
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct RosenergoMobileAgentWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall: SystemSmall(inspections: 5)
        case .systemLarge: SystemLarge()
        default: SystemSmall(inspections: 5)
        }
    }
}

@main
struct RosenergoMobileAgentWidget: Widget {
    let persistenceController = PersistenceController.shared
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RosenergoMobileAgentWidget", provider: Provider()) { entry in
            RosenergoMobileAgentWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .configurationDisplayName("Осмотры")
        .description("Виджет поможет вам не забыть отправить осмотр на сервер!")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct RosenergoMobileAgentWidget_Previews: PreviewProvider {
    static var previews: some View {
        SystemLarge()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .colorScheme(.dark)
        SystemLarge()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .colorScheme(.light)
    }
}
