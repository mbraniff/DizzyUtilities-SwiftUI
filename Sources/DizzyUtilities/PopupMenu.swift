//
//  SwiftUIView.swift
//  
//
//  Created by Matthew Braniff on 2/21/24.
//

import SwiftUI

@available(macOS 13.0, iOS 16.4, *)
struct PopoverLayout<T>: _VariadicView_MultiViewRoot {
    @Binding var selection: T
    @Binding var isShowing: Bool
    
    func body(children: _VariadicView.Children) -> some View {
        ForEach(children) { child in
            Button {
                if let tag = child[MenuTagTrait<T>.self] {
                    selection = tag
                }
                isShowing = false
            } label: {
                child
            }
        }
    }
}

@available(macOS 13.3, iOS 16.4, *)
public struct PopupMenu<T, Content>: View where Content: View {
    var title: String
    var selection: Binding<T>
    @ViewBuilder var content: Content
    
    @State private var showMenu: Bool = false
    
    public init(title: String, selection: Binding<T>, @ViewBuilder content: () -> Content) {
        self.title = title
        self.selection = selection
        self.content = content()
    }
    
    public var body: some View {
        Button {
            showMenu = true
        } label: {
            Text(title)
                .frame(minWidth: 100)
        }
        .buttonStyle(BorderedButtonStyle())
        .popover(isPresented: $showMenu, attachmentAnchor: .point(.center)) {
            ScrollView {
                VStack {
                    _VariadicView.Tree(PopoverLayout(selection: selection, isShowing:  $showMenu)) {
                        content
                            .frame(minWidth: 125, maxWidth: 300, idealHeight: 65)
                    }
                }
            }
            .frame(maxWidth: 350, maxHeight: 225)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct MenuTagTrait<T>: _ViewTraitKey {
    static var defaultValue: T? { nil }
}

@available(macOS 13.0, iOS 13.0, *)
extension View {
    public func menuTag<T>(_ tag: T?) -> some View {
        _trait(MenuTagTrait<T>.self, tag)
    }
}

@available(macOS 13.3, iOS 16.4, *)
#Preview {
    @State var selection = 0
    return VStack {
        Color.blue
        PopupMenu(title: "Menu", selection: $selection) {
            Text("Option 1").menuTag(1)
            Text("Option 2").menuTag(2)
            Text("Option 3").menuTag(3)
            Text("Another Option With A Long Name").menuTag(4)
        }
        Color.black
    }
}
