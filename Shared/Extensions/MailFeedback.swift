//
//  MailFeedback.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 15.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

#if os(iOS)
import MessageUI
#endif
import SwiftUI

#if os(iOS)
struct MailFeedback: UIViewControllerRepresentable {
    @Binding var alertItem: AlertItem?
    
    let deviceInfo = UIDevice.current
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailFeedback>) -> MFMailComposeViewController {
        let mailFeedback = MFMailComposeViewController()
        mailFeedback.setToRecipients(["lisinde@rosen.ttb.ru"])
        mailFeedback.setSubject("Сообщение об ошибке")
        mailFeedback.setMessageBody(
            """
                Добрый день!<br>
                <br>Версия системы: <b>\(deviceInfo.systemName) \(deviceInfo.systemVersion)</b>
                <br>Версия приложения: <b>\(getVersion())</b>
                <br><br>Опишите, какая ошибка произошла в приложении:
            """,
            isHTML: true
        )
        mailFeedback.mailComposeDelegate = context.coordinator
        return mailFeedback
    }
    
    func updateUIViewController(_: MFMailComposeViewController, context _: UIViewControllerRepresentableContext<MailFeedback>) {}
    
    func makeCoordinator() -> MailFeedback.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailFeedback
        
        init(_ parent: MailFeedback) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
            switch result {
            case .sent:
                parent.alertItem = AlertItem(title: "Сообщение отправлено", message: "Я отвечу на него в ближайшее время.")
            case .saved:
                parent.alertItem = AlertItem(title: "Сообщение сохранено", message: "Сообщение ждет вас в черновиках.")
            case .failed:
                parent.alertItem = AlertItem(title: "Ошибка", message: "Повторите попытку позже.\n\(error?.localizedDescription ?? "")")
            case .cancelled:
                log("Отменено пользователем")
            @unknown default:
                log("Отправка почты: ошибка")
            }
        }
    }
}
#endif

struct MailFeedbackModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var alertItem: AlertItem?
    
    func body(content: Content) -> some View {
        #if os(iOS)
        return content
            .sheet(isPresented: $isPresented) {
                MailFeedback(alertItem: $alertItem)
                    .ignoresSafeArea(edges: .bottom)
            }
        #else
        return content
        #endif
    }
}

extension View {
    func mailFeedback(isPresented: Binding<Bool>, alertItem: Binding<AlertItem?>) -> some View {
        modifier(MailFeedbackModifier(isPresented: isPresented, alertItem: alertItem))
    }
}