//
//  ButtonWidget.swift
//  RosenergoMobileAgent (Widget)
//
//  Created by Дмитрий Лисин on 29.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
import WidgetKit


struct ButtonWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ButtonWidget", provider: Provider()) { entry in
            ButtonWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Быстрый доступ")
        .description("Быстрый доступ к необходимым функциям приложения!")
        .supportedFamilies([.systemMedium])
    }
}

extension ButtonWidget {
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
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
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

extension ButtonWidget {
    struct Entry: TimelineEntry {
        let date: Date
    }
}

struct SystemMedium: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            Group {
                colorScheme == .light ? Color.blue : Color(.secondarySystemBackground)
            }
            VStack {
                GeometryReader { proxy in
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 8) {
                        WidgetButton(title: "Новый\nосмотр", systemImage: "gear", color: .blue, height: proxy.size.height / 2)
                        WidgetButton(title: "Осмотры", systemImage: "gear", color: .blue, height: proxy.size.height / 2)
                        WidgetButton(title: "Новое выплатное дело", systemImage: "gear", color: .blue, height: proxy.size.height / 2)
                        WidgetButton(title: "Выплатные дела", systemImage: "gear", color: .blue, height: proxy.size.height / 2)
                    }
                }
            }
        }
    }
}

struct ButtonWidgetEntryView: View {
    var entry: ButtonWidget.Entry
    
    var body: some View {
        SystemMedium()
    }
}

struct RosenergoMobileAgentWidget_Previews: PreviewProvider {
    static var previews: some View {
        SystemMedium()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .colorScheme(.dark)
        SystemMedium()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .colorScheme(.light)
    }
}

struct WidgetButton: View {
    var title: String
    var systemImage: String
    var color: Color
    var height: CGFloat? = nil
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .imageScale(.large)
                .foregroundColor(color)
                .padding(.bottom, 3)
            Text(title)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: height)
        .background(
            ContainerRelativeShape()
                .fill(color.opacity(0.2))
        )
    }
}
