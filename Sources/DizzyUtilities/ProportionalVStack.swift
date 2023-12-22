//
//  ProportionalVStack.swift
//  
//
//  Created by Matthew Braniff on 12/21/23.
//

import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
public struct ProportionalVStack: Layout {
    let alignment: HorizontalAlignment
    public init(alignment: HorizontalAlignment = .center) {
        self.alignment = alignment
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let assignedHeights = getAssignedHeights(from: bounds, subviews: subviews)
        let xPos = alignment == .center ? bounds.width/2 : alignment == .trailing ? bounds.width : 0.0
        var yPos = 0.0
        for (index, height) in assignedHeights.enumerated() {
            yPos += height / 2
            let newProposal = ProposedViewSize(width: proposal.width, height: height)
            let dimensions = subviews[index].dimensions(in: newProposal)
            let widthOffset = alignment == .leading ? dimensions.width / 2 : alignment == .trailing ? -dimensions.width / 2 : 0.0
            let point = CGPoint(x: xPos + widthOffset, y: yPos)
            
            subviews[index].place(at: point, anchor:.center, proposal: newProposal)
            yPos += height / 2
        }
    }
    
    private func getAssignedHeights(from bounds: CGRect, subviews: Subviews) -> [CGFloat] {
        let heightProportions = subviews.map { $0[ViewProportion.self] }
        
        var usedHeight: CGFloat = 0.0
        var assignedHeights: [CGFloat] = Array(repeating: 0.0, count: subviews.count)
        
        for (index, proportion) in heightProportions.enumerated() {
            if usedHeight + proportion > 1.0 {
                break
            }
            if proportion == 0.0 {
                continue
            }
            
            usedHeight += proportion
            assignedHeights[index] = bounds.height * proportion
        }
        
        let unassignedIndexes = assignedHeights.enumerated().compactMap { $0.element == 0.0 ? $0.offset : nil }
        let fixedProportion: CGFloat = (1.0 - usedHeight) / CGFloat(unassignedIndexes.count)
        
        for offset in unassignedIndexes {
            assignedHeights[offset] = bounds.height * fixedProportion
        }
        
        return assignedHeights
    }
}
