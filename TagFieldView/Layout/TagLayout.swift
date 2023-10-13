//
//  TagLayout.swift
//  TagFieldView
//
//  Created by Lakshaya Sachdeva on 13/10/23.
//

import Foundation
import SwiftUI

struct TagLayout: Layout {
    var alignment: Alignment = .leading
    // both horizontal and vertical
    var spacing: CGFloat = 10
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for (index, row) in rows.enumerated() {
            // Finding max height for each row and adding it to the total height of the view
            if index == (rows.count - 1) {
                // Since there is no spacing needed for the last item
                height += row.maxHeight(proposal)
            } else{
                height += row.maxHeight(proposal) + spacing
            }
        }
        return .init(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        // placing views
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            // Changing origin X based on alignment
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                if view == row.last {
                    return partialResult + width
                }
                return partialResult + width + spacing
            })
            let center = (trailing + leading) / 2
            // resetting origin x to 0 for each row
            origin.x = (alignment == .leading ? leading : alignment == .trailing ? trailing : center)
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                // updating X of origin
                origin.x += viewSize.width + spacing
                // updating origin Y
            }
            origin.y += row.maxHeight(proposal) + spacing // Move to the next row
        }
    }
    
    // Generating rows on the basis of size available (i.e. screen width)
    
    func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        // origin
        var origin = CGRect.zero.origin
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            // pushing to new row
            if (origin.x + viewSize.width + spacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                // Resetting X origin since it needs to start from the left to right
                origin.x = 0
                row.append(view)
                // updating origin x
                origin.x += (viewSize.width + spacing)
            } else{
                // adding item to same row
                row.append(view)
                origin.x += (viewSize.width + spacing)
            }
        }
        // checking for any exhaust row
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        return rows
    }
    
}


extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
