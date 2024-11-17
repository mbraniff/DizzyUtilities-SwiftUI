//
//  EqualWidthHStack.swift
//
//
//  Created by Matthew Braniff on 12/23/23.
//

import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
public struct EqualWidthHStack: Layout {
    private let fitToView: Bool
    
    public init(fitToView: Bool = true) {
        self.fitToView = fitToView
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxSize = getMaxSize(subviews: subviews, proposal: proposal)
        let spacing = getSpacing(subviews: subviews)
        
        return CGSize(width: (maxSize.width * CGFloat(subviews.count)) + spacing.reduce(.zero) { $0 + $1 } , height: maxSize.height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxSize = getMaxSize(subviews: subviews, proposal: proposal)
        let spacing = getSpacing(subviews: subviews)
        
        let sizeProposal = ProposedViewSize(maxSize)
        var x = bounds.minX + maxSize.width / 2
        
        for index in subviews.indices {
            subviews[index].place(at: CGPoint(x: x, y: bounds.midY),
                                  anchor: .center,
                                  proposal: sizeProposal)
            if index != subviews.endIndex - 1 {
                x += maxSize.width + spacing[index]
            }
        }
    }
    
    private func getMaxSize(subviews: Subviews, proposal: ProposedViewSize) -> CGSize {
        var (maxSizeIndex, maxSize) = subviews.enumerated().map { (index, subview) -> (index: Int, size: CGSize) in (index, subview.sizeThatFits(.unspecified)) }
            .reduce((0, CGSize.zero)) {
                ($0.1.width > $1.1.width ? $0.0 : $1.0,
                CGSize(width: max($0.1.width, $1.1.width),
                       height: max($0.1.height, $1.1.height))
                )
            }
        
        if fitToView, let width = proposal.width {
            let maxWidth = (width - getSpacing(subviews: subviews).reduce(0) { $0 + $1 }) / CGFloat(subviews.count)
            guard maxSize.width > maxWidth else { return maxSize }
            let newProspoal = ProposedViewSize(width: maxWidth, height: nil)
            let maxHeight = subviews[maxSizeIndex].sizeThatFits(newProspoal).height
            maxSize = CGSize(width: maxWidth, height: maxHeight)
        }
        
        return maxSize
    }
    
    private func getSpacing(subviews: Subviews) -> [CGFloat] {
        return subviews.indices.dropLast().map {
            subviews[$0].spacing.distance(to: subviews[$0+1].spacing, along: .horizontal)
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
public struct EqualWidthVStack: Layout {
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxSize = getMaxSize(subviews: subviews, proposal: proposal)
        let spacing = getSpacing(subviews: subviews)
        
        return CGSize(width: maxSize.width , height: (maxSize.height * CGFloat(subviews.count)) + spacing.reduce(.zero) { $0 + $1 })
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxSize = getMaxSize(subviews: subviews, proposal: proposal)
        let spacing = getSpacing(subviews: subviews)
        
        let sizeProposal = ProposedViewSize(maxSize)
        var y = bounds.minY + maxSize.height / 2
        
        for index in subviews.indices {
            subviews[index].place(at: CGPoint(x: bounds.midX, y: y),
                                  anchor: .center,
                                  proposal: sizeProposal)
            if index != subviews.endIndex - 1 {
                y += maxSize.height + spacing[index]
            }
        }
    }
    
    private func getMaxSize(subviews: Subviews, proposal: ProposedViewSize) -> CGSize {
        return subviews.map { ($0, $0.sizeThatFits(.unspecified)) }
            .map {
                guard let width = proposal.width else { return $0.1 }
                if $0.1.width > width {
                    let newProposal = ProposedViewSize(width: width, height: nil)
                    return $0.0.sizeThatFits(newProposal)
                }
                return $0.1
            }
            .reduce(.zero) {
                CGSize(width: max($0.width, $1.width),
                       height: max($0.height, $1.height)
                )
            }
    }
    
    private func getSpacing(subviews: Subviews) -> [CGFloat] {
        return subviews.indices.dropLast().map {
            subviews[$0].spacing.distance(to: subviews[$0+1].spacing, along: .vertical)
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
#Preview {
    ScrollView {
        EqualWidthVStack {
            Button {} label: { Text("How").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Button {} label: { Text("Are").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Button {} label: { Text("You My Dude!").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Button {} label: { Text("You My Dude!").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Button {} label: { Text("You My Dude!").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Button {} label: { Text("You My Dude!").frame(maxWidth: .infinity, maxHeight: .infinity) }
            Button {} label: { Text("You My Dude! hahahahahahhaahhaahahahahhahahahah HAHAHAH").frame(maxWidth: .infinity, maxHeight: .infinity) }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.green)
        .buttonStyle(.borderedProminent)
        .lineLimit(3)
    }
    .frame(maxWidth: .infinity)
}
