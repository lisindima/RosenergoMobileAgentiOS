//
//  LocalInspectionsWidget.swift
//  Widget
//
//  Created by Дмитрий Лисин on 24.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import CoreData
import SwiftUI
import WidgetKit

@main
struct LocalInspectionsWidget: Widget {
    let persistenceController = PersistenceController.shared
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RosenergoMobileAgentWidget", provider: Provider()) { _ in
            LocalInspectionsWidgetEntryView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .configurationDisplayName("Осмотры")
        .description("Виджет поможет вам не забыть отправить осмотр на сервер!")
        .supportedFamilies([.systemSmall])
    }
}

extension LocalInspectionsWidget {
    struct Provider: TimelineProvider {
        func placeholder(in _: Context) -> Entry {
            Entry(date: Date())
        }
        
        func getSnapshot(in _: Context, completion: @escaping (Entry) -> Void) {
            let entry = Entry(date: Date())
            completion(entry)
        }
        
        func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            var entries: [Entry] = []
            
            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = Entry(date: entryDate)
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

extension LocalInspectionsWidget {
    struct Entry: TimelineEntry {
        let date: Date
    }
}

struct LocalInspectionsWidgetEntryView: View {
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var localInspections: FetchedResults<LocalInspections>
    
    var body: some View {
        ZStack {
            Color.rosenergo
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Осмотры")
                    .fontWeight(.bold)
                Text("Не отправленные")
                    .fontWeight(.semibold)
                    .font(.caption2)
                Divider()
                if localInspections.isEmpty {
                    Text("Вы отправили все осмотры!")
                        .font(.caption2)
                } else {
                    Text("У вас есть не отправленные осмотры")
                        .font(.caption2)
                }
                Spacer()
                HStack {
                    Image(systemName: "tray.circle.fill")
                        .imageScale(.large)
                    Spacer()
                    if !localInspections.isEmpty {
                        Text("\(localInspections.count) осмотров")
                            .fontWeight(.bold)
                            .font(.caption)
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct LocalInspectionsWidget_Previews: PreviewProvider {
    static var previews: some View {
        LocalInspectionsWidgetEntryView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .colorScheme(.dark)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
