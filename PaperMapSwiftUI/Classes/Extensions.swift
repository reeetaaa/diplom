//
//  Extensions.swift
//  PaperMap
//
//  Created by Margarita Babukhadia on 04/10/23.
//  Copyright © 2023 Margarita Babukhadia. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

infix operator ~~ 

extension CGRect {
    func shiftedRect(to point: CGPoint) -> CGRect {
        return CGRect(origin: point, size: self.size)
    }
}

extension UILabel {
    class func textSize(font: UIFont,
                        text: String,
                        width: CGFloat = .greatestFiniteMagnitude,
                        height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }
}

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

extension Int {
    var doubleValue: Double {
        Double(self)
    }
}

extension CGPoint: Hashable {
    
    /**
     Oposites of coordinates
     */
    static prefix func - (p: CGPoint) -> CGPoint {
        CGPoint(x: -p.x, y: -p.y)
    }
    
    static func + (leftP: CGPoint, rigthP: CGPoint) -> CGPoint {
        return CGPoint(x: leftP.x + rigthP.x, y: leftP.y + rigthP.y)
    }
    
    static func + (p: CGPoint, s: CGSize) -> CGPoint {
        CGPoint(x: p.x + s.width, y: p.y + s.height)
    }
    
    static func - (lP: CGPoint, rP: CGPoint) -> CGPoint {
        return CGPoint(x: lP.x - rP.x, y: lP.y - rP.y)
    }
    
    static func - (lP: CGPoint, rP: CGSize) -> CGPoint {
        return CGPoint(x: lP.x - rP.width, y: lP.y - rP.height)
    }
    
    static func / (p: CGPoint, divider: CGFloat) -> CGPoint {
        CGPoint(x: p.x / divider, y: p.y / divider)
    }
    
    // Среднее значение между 2 точками
    static func ~~ (lP: CGPoint, rP: CGPoint) -> CGPoint {
        lP + (rP - lP) / 2
    }
    
    func isInsideTheSize(_ size: CGSize) -> Bool {
        self.x > 0 && self.y > 0 && self.x < size.width && self.y < size.height
    }
    
    func getShiftedBy(dX: CGFloat, dY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dX, y: self.y + dY)
    }
    
    func getShiftedBy(length: CGFloat, angle: CGFloat) -> CGPoint {
        let dX = length * sin(angle)
        let dY = length * cos(angle)
        return CGPoint(x: self.x + dX, y: self.y - dY)
    }
    
    func getShiftedBy(length: CGFloat, angleInDeg: CGFloat) -> CGPoint {
        return getShiftedBy(length: length, angle: angleInDeg * Double.pi / 180)
    }
    
    // https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
    // Cравнение положения с линией в горизонтальной плоскости
    public func getPointSideToTheLineHorisintaly(startOfLine: CGPoint, endOfLine: CGPoint) -> PointSideFromLine {
        let result = (endOfLine.x - startOfLine.x)*(self.y - startOfLine.y) - (endOfLine.y - startOfLine.y)*(self.x - startOfLine.x)
        return result == 0 ? .onTheLine : (result > 0 ? .toTheLeft : .toTheRight)
    }
    
    // https://www.cuemath.com/geometry/two-point-form/
    // Cравнение положения с линией в вертикальной плоскости
    public func getPointSideToTheLineVerticaly(startOfLine: CGPoint, endOfLine: CGPoint) -> PointSideFromLine {
        let yOnTheLine = startOfLine.y + (endOfLine.y - startOfLine.y) / (endOfLine.x - startOfLine.x) * (self.x - endOfLine.x)
        return yOnTheLine == self.y ? .onTheLine : (yOnTheLine > self.y ? .above : .below)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGSize {
    init(_ ei: EdgeInsets, corner: RectCorner) {
        switch corner {
        case .topLeading:
            self.init(width: ei.leading, height: ei.top)
        case .topTrailing:
            self.init(width: ei.trailing, height: ei.top)
        case .bottomLeading:
            self.init(width: ei.leading, height: ei.bottom)
        case .bottomTrailing:
            self.init(width: ei.trailing, height: ei.bottom)
        }
    }
    
    static func - (lS: CGSize, rS: CGSize) -> CGSize {
        CGSize(width: lS.width - rS.width,
               height: lS.height - rS.height)
    }
    
    static func / (lS: CGSize, divider: CGFloat) -> CGPoint {
        let x = lS.width / divider
        let y = lS.height / divider
        return CGPoint(x: x, y: y)
    }
    
    func middlePoint(relatedTo edgeInsets: EdgeInsets? = nil) -> CGPoint {
        if let edgeInsets = edgeInsets {
            return CGPoint(x: edgeInsets.leading + (self.width - edgeInsets.leading - edgeInsets.trailing) / 2, y: edgeInsets.top + (self.height - edgeInsets.top - edgeInsets.bottom) / 2)
        } else {
            return CGPoint(x: self.width / 2, y: self.height / 2)
        }
    }
    
    func upperLeftPoint(relatedTo edgeInsets: EdgeInsets? = nil) -> CGPoint {
        if let edgeInsets = edgeInsets {
            return CGPoint(x: edgeInsets.leading + 0, y: edgeInsets.top + 0)
        } else {
            return CGPoint(x: 0, y: 0)
        }
    }
    
    func upperRightPoint(relatedTo edgeInsets: EdgeInsets? = nil) -> CGPoint {
        if let edgeInsets = edgeInsets {
            return CGPoint(x: self.width - edgeInsets.trailing, y: edgeInsets.top + 0)
        } else {
            return CGPoint(x: self.width , y: 0)
        }
    }
    
    func lowerLeftPoint(relatedTo edgeInsets: EdgeInsets? = nil) -> CGPoint {
        if let edgeInsets = edgeInsets {
            return CGPoint(x: edgeInsets.leading + 0, y: self.height - edgeInsets.bottom)
        } else {
            return CGPoint(x: 0, y: self.height)
        }
    }
    
    func lowerRightPoint(relatedTo edgeInsets: EdgeInsets? = nil) -> CGPoint {
        if let edgeInsets = edgeInsets {
            return CGPoint(x: self.width - edgeInsets.trailing, y: self.height - edgeInsets.bottom)
        } else {
            return CGPoint(x: self.width, y: self.height)
        }
    }
    
    func centerPoint(relatedTo edgeInsets: EdgeInsets? = nil) -> CGPoint {
        let lowerMiddle = self.lowerRightPoint(relatedTo: edgeInsets) ~~ self.lowerLeftPoint(relatedTo: edgeInsets)
        let upperMiddle = self.upperRightPoint(relatedTo: edgeInsets) ~~ self.upperLeftPoint(relatedTo: edgeInsets)
        let middle = lowerMiddle ~~ upperMiddle
        return middle
    }
}



