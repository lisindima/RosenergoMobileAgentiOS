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

struct LocalInspectionsWidget: Widget {
    let persistenceController = PersistenceController.shared
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RosenergoMobileAgentWidget", provider: Provider()) { entry in
            LocalInspectionsWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .configurationDisplayName("Осмотры")
        .description("Виджет поможет вам не забыть отправить осмотр на сервер!")
        .supportedFamilies([.systemSmall, .systemLarge])
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

struct LocalInspectionsSystemLarge: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var localInspections: FetchedResults<LocalInspections>
    
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
                ForEach(localInspections, id: \.id) { item in
                    HStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Group {
                                Text(item.insuranceContractNumber.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                if let insuranceContractNumber2 = item.insuranceContractNumber2 {
                                    Text(insuranceContractNumber2.uppercased())
                                        .fontWeight(.bold)
                                        .font(.caption)
                                }
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
                    Image(systemName: "\(localInspections.count).circle.fill")
                        .imageScale(.large)
                }
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct LocalInspectionsSystemSmall: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var localInspections: FetchedResults<LocalInspections>
    
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

struct LocalInspectionsWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: LocalInspectionsWidget.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall: LocalInspectionsSystemSmall()
        case .systemLarge: LocalInspectionsSystemLarge()
        default: LocalInspectionsSystemSmall()
        }
    }
}

struct LocalInspectionsWidget_Previews: PreviewProvider {
    static var previews: some View {
        LocalInspectionsSystemSmall()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .colorScheme(.dark)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        LocalInspectionsSystemLarge()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .colorScheme(.light)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
