//
//  ProportionalHStack.swift
//  
//
//  Created by Matthew Braniff on 12/21/23.
//

import SwiftUI

@available(macOS 13.0, iOS 16.0, *)
public struct ProportionalHStack: Layout {
    let alignment: VerticalAlignment
    public init(alignment: VerticalAlignment = .center) {
        self.alignment = alignment
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let assignedWidths = getAssignedWidths(from: bounds, subviews: subviews)
        var xPos = bounds.origin.x
        let yPos = bounds.origin.y + (alignment == .center ? bounds.height/2 : alignment == .bottom ? bounds.height : 0.0)
        for (index, width) in assignedWidths.enumerated() {
            xPos += width / 2
            let newProposal = ProposedViewSize(width: width, height: proposal.height)
            let dimensions = subviews[index].dimensions(in: newProposal)
            let heightOffset = alignment == .top ? dimensions.height / 2 : alignment == .bottom ? -dimensions.height / 2 : 0.0
            let point = CGPoint(x: xPos, y: yPos + heightOffset)
            
            subviews[index].place(at: point, anchor:.center, proposal: newProposal)
            xPos += width / 2
        }
    }
    
    private func getAssignedWidths(from bounds: CGRect, subviews: Subviews) -> [CGFloat] {
        let widthProportions = subviews.map { $0[ViewProportion.self] }
        let priorityIndex = subviews.enumerated().sorted { $0.element.priority > $1.element.priority }.map { $0.offset }
        
        var usedWidth: CGFloat = 0.0
        var assignedWidths: [CGFloat] = Array(repeating: 0.0, count: subviews.count)
        
        for index in priorityIndex {
            let proportion = widthProportions[index]
            if usedWidth + proportion > 1.0 {
                break
            }
            if proportion == 0.0 {
                continue
            }
            
            usedWidth += proportion
            assignedWidths[index] = bounds.width * proportion
        }
        
        let unassignedIndexes = assignedWidths.enumerated().compactMap { $0.element == 0.0 ? $0.offset : nil }
        let fixedProportion: CGFloat = (1.0 - usedWidth) / CGFloat(unassignedIndexes.count)
        
        for offset in unassignedIndexes {
            assignedWidths[offset] = bounds.width * fixedProportion
        }
        
        return assignedWidths
    }
}
