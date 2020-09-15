//
//  MailFeedback.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 15.05.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import MessageUI
import SwiftUI

struct MailFeedback: UIViewControllerRepresentable {
    @Binding var alertItem: AlertItem?
    
    let deviceInfo = UIDevice.current
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailFeedback>) -> MFMailComposeViewController {
        let mailFeedback = MFMailComposeViewController()
        mailFeedback.setToRecipients(["lisinde@rosen.ttb.ru"])
        mailFeedback.setSubject("Сообщение об ошибке")
        mailFeedback.setMessageBody(
            """
                Добрый день!<br>
                <br>Версия системы: <b>\(deviceInfo.systemName) \(deviceInfo.systemVersion)</b>
                <br>Версия приложения: <b>\(version) (\(build))</b>
                <br><br>Опишите, какая ошибка произошла в приложении:
            """, isHTML: true
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
                playHaptic(.success)
                parent.alertItem = AlertItem(title: "Сообщение отправлено", message: "Я отвечу на него в ближайшее время.")
            case .saved:
                playHaptic(.warning)
                parent.alertItem = AlertItem(title: "Сообщение сохранено", message: "Сообщение ждет вас в черновиках.")
            case .failed:
                playHaptic(.error)
                parent.alertItem = AlertItem(title: "Ошибка", message: "Повторите попытку позже.\n\(error?.localizedDescription ?? "")")
            case .cancelled:
                log("Отменено пользователем")
            @unknown default:
                log("Отправка почты: ошибка")
            }
        }
    }
}
