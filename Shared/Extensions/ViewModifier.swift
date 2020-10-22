//
//  ViewModifier.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 08.09.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI
#if os(iOS)
import MessageUI
#endif

struct TabViewBackgroundMode: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        content
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        #endif
    }
}

struct ListStyle: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(watchOS)
        content
        #else
        content
            .listStyle(InsetGroupedListStyle())
        #endif
    }
}

struct MailFeedbackModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var alertItem: AlertItem?
    
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        if MFMailComposeViewController.canSendMail() {
            content
                .sheet(isPresented: $isPresented) {
                    MailFeedback(alertItem: $alertItem)
                        .ignoresSafeArea(edges: .bottom)
                }
        } else {
            content
                .alert(isPresented: $isPresented) {
                    Alert(title: Text("Не установлено приложение \"Почта\""), message: Text("Для отправки сообщений об ошибках вам понадобится официальное приложение \"Почта\", установите его из App Store."), dismissButton: .cancel(Text("Закрыть")))
                }
        }
        #else
        content
        #endif
    }
}

extension View {
    func mailFeedback(isPresented: Binding<Bool>, alertItem: Binding<AlertItem?>) -> some View {
        modifier(MailFeedbackModifier(isPresented: isPresented, alertItem: alertItem))
    }
}

extension Text {
    @ViewBuilder
    func messageTitle() -> Text {
        #if os(watchOS)
        fontWeight(.bold)
        #else
        font(.title)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
        #endif
    }
    
    @ViewBuilder
    func messageSubtitle() -> Text {
        #if os(watchOS)
        font(.footnote)
            .foregroundColor(.secondary)
        #else
        foregroundColor(.secondary)
        #endif
    }
}
