//
//  Pasteboard.swift
//  RosenergoMobileAgent
//
//  Created by Дмитрий Лисин on 07.12.2020.
//  Copyright © 2020 Дмитрий Лисин. All rights reserved.
//

import SwiftUI

func copyPasteboard(_ string: String, completion: @escaping () -> Void) {
    #if os(macOS)
    NSPasteboard.general.setString(string, forType: .URL)
    #else
    UIPasteboard.general.url = URL(string: string)
    #endif
    completion()
}
