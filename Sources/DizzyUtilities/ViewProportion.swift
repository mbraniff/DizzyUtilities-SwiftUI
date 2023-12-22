//
//  ViewProportion.swift
//  
//
//  Created by Matthew Braniff on 12/21/23.
//

import SwiftUI

struct ViewProportion: LayoutValueKey {
    static let defaultValue: CGFloat = 0.0
}

@available(macOS 13.0, iOS 16.0, *)
public extension View {
    func proportion(_ proportion: CGFloat) -> some View {
        layoutValue(key: ViewProportion.self, value: proportion)
    }
}

