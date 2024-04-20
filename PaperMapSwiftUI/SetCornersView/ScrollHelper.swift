//
//  ScrollHelper.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 15/11/23.
//

import SwiftUI

struct ScrollHelper: CustomStringConvertible {
    private(set) var contentSize: CGSize
    private(set) var scrollSize: CGSize
    
    private var scrollViewLeadinsTopPoint: CGPoint
    private var scrollViewTrailingBottomPoint: CGPoint
    
    init() {
        contentSize = .zero
        scrollSize = .zero
        
        scrollViewLeadinsTopPoint = .zero
        scrollViewTrailingBottomPoint = .zero
    }
    
    public static var zero: ScrollHelper {
        var sZero = ScrollHelper()
        sZero.contentSize = .zero
        sZero.scrollSize = .zero
        return sZero
    }
    
    
    func getUnitPoint(from pos: CGPoint) -> UnitPoint {
        let testX = (contentSize.width / 2  - pos.x + 0) / scrollSize.width + 0.5
        let testY = (contentSize.height / 2  - pos.y + 0) / scrollSize.height + 0.5
        return UnitPoint(x: testX, y: testY)
    }
    
    var description: String {
        "contentSize: \(contentSize); scrollSize: \(scrollSize)"
    }
    
    /**
     This function sets `scrollSize` and corners to get then Visible Area's coordinates corners
     */
    mutating func setScrollSizeFromIncludedInsetValue(value: CGPoint, inFrmae frame: CGRect, withInsets safeAreaInsets: EdgeInsets) {
        let scroolViewSize = frame.size - CGSize(safeAreaInsets, 
                                                 corner: .bottomTrailing)
        self.scrollSize = scroolViewSize
        
        let scrollOffset = value - CGSize(safeAreaInsets, 
                                          corner: .topTrailing)
        
        scrollViewLeadinsTopPoint = -scrollOffset
        scrollViewTrailingBottomPoint = -scrollOffset + self.scrollSize
    }
    
    mutating func setScrollSize(_ size: CGSize) {
        scrollSize = size
    }
    
    mutating func setContentSize(_ size: CGSize) {
        contentSize = size
    }
    
    func getCornerPointOfVisibleArea(corner: RectCorner) -> CGPoint {
        switch corner {
        case .topLeading:
            CGPoint(x: scrollViewLeadinsTopPoint.x, y: scrollViewLeadinsTopPoint.y)
        case .topTrailing:
            CGPoint(x: scrollViewTrailingBottomPoint.x, y: scrollViewLeadinsTopPoint.y)
        case .bottomLeading:
            CGPoint(x: scrollViewLeadinsTopPoint.x, y: scrollViewTrailingBottomPoint.y)
        case .bottomTrailing:
            CGPoint(x: scrollViewTrailingBottomPoint.x, y: scrollViewTrailingBottomPoint.y)
        }
    }
    
    func getCenterPointOfVisibleArea() -> CGPoint {
        // the next operation is getting a mean value
        scrollViewLeadinsTopPoint ~~ scrollViewTrailingBottomPoint
    }
}
