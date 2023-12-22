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
        print(bounds)
        print(dump(proposal))
        let assignedWidths = getAssignedWidths(from: bounds, subviews: subviews)
        var xPos = 0.0
        let yPos = alignment == .center ? bounds.height/2 : alignment == .bottom ? bounds.height : 0.0
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
        
        var usedWidth: CGFloat = 0.0
        var assignedWidths: [CGFloat] = Array(repeating: 0.0, count: subviews.count)
        
        for (index, proportion) in widthProportions.enumerated() {
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

@available(macOS 13.0, iOS 16.0, *)
public struct ProportionalVStack: Layout {
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let subviewHeights = subviews.map {
            let newProposal = ProposedViewSize(width: proposal.width, height: proposal.height ?? 0 * $0[ViewProportion.self])
            return $0.sizeThatFits(newProposal).height
        }
        
        var newProposal = ProposedViewSize(bounds.size.applying(.init(scaleX: subviews.first?[ViewProportion.self] ?? 1.0, y: 1.0)))
        var yPos: CGFloat = 0
        for i in subviewHeights.indices {
            newProposal = ProposedViewSize(bounds.size.applying(.init(scaleX: 1.0, y: subviews[i][ViewProportion.self])))
            let dimensions = subviews[i].dimensions(in: newProposal)
            yPos += dimensions.height / 2
            let point = CGPoint(x: subviews[i].dimensions(in: newProposal).width/2, y: yPos)
            subviews[i].place(at: point, anchor: .center, proposal: newProposal)
            
            yPos += dimensions.height / 2
        }
    }
    
    private func getSpacing(_ subviews: Subviews) -> [CGFloat] {
        var spacing: [CGFloat] = []
        for index in subviews.indices {
            if index == subviews.endIndex - 1 { break }
            spacing.append(subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal))
        }
        return spacing
    }
}

private struct ViewProportion: LayoutValueKey {
    static let defaultValue: CGFloat = 0.0
}

@available(macOS 13.0, iOS 16.0, *)
extension View {
    public func proportion(_ proportion: CGFloat) -> some View {
        layoutValue(key: ViewProportion.self, value: proportion)
    }
}

@available(macOS 13.0, iOS 16.0, *)
struct Preview_ProportionalLayout: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal) {
        ProportionalHStack(alignment: .center) {
                Text("Hello")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.purple)
                    .proportion(0.25)
                Text("Yessir")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.blue)
                    .proportion(0.5)
                Color(.gray)
                Color(.lightGray)
        }
        }
    }
}
