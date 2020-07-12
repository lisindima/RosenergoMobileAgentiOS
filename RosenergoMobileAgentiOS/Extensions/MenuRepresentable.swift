//
//  MenuRepresentable.swift
//  RosenergoMobileAgentiOS
//
//  Created by Дмитрий Лисин on 12.07.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

struct MenuRepresentable: UIViewRepresentable {
    
    typealias UIViewType = UIButton

    let saveMenu = UIMenu(title: "", children: [
        UIAction(title: "Изменить", image: UIImage(systemName: "pencil.circle")) { action in
            //code action for menu item
        },
        UIAction(title: "Удалить", image: UIImage(systemName: "trash.circle")) { action in
            //code action for menu item
        }
    ])

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.showsMenuAsPrimaryAction = true
        button.menu = saveMenu
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        
        
    }
}
