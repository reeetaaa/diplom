//
//  ScrollHelper.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 15/11/23.
//

import SwiftUI

// Помощник перемещения по изображению карты
struct ScrollHelper {
    private(set) var contentSize: CGSize // Полный размер содержимого области прокрутки
    private(set) var scrollSize: CGSize // Размер видимой части области прокрутки
    
    private var scrollViewLeadinsTopPoint: CGPoint // Левая верхняя точка полной части области прокрутки
    private var scrollViewTrailingBottomPoint: CGPoint // Правая нижняя точка
    
    init() {
        contentSize = .zero
        scrollSize = .zero
        
        scrollViewLeadinsTopPoint = .zero
        scrollViewTrailingBottomPoint = .zero
    }
    
    // Нулевая позиция ScrollHelper
    public static var zero: ScrollHelper {
        var sZero = ScrollHelper()
        sZero.contentSize = .zero
        sZero.scrollSize = .zero
        return sZero
    }
    
    // Сдвиг центра области прокрутки относительно переданной позиции
    func getUnitPoint(from pos: CGPoint) -> UnitPoint {
        let testX = (contentSize.width / 2  - pos.x + 0) / scrollSize.width + 0.5
        let testY = (contentSize.height / 2  - pos.y + 0) / scrollSize.height + 0.5
        return UnitPoint(x: testX, y: testY)
    }
    
    // Устанавливает scrollSize и углы, чтобы получить координаты углов видимой области
    mutating func setScrollSizeFromIncludedInsetValue(value: CGPoint, inFrmae frame: CGRect, withInsets safeAreaInsets: EdgeInsets) {
        let scroolViewSize = frame.size - CGSize(safeAreaInsets, corner: .bottomTrailing)
        self.scrollSize = scroolViewSize
        
        let scrollOffset = value - CGSize(safeAreaInsets, corner: .topTrailing)
        
        scrollViewLeadinsTopPoint = -scrollOffset
        scrollViewTrailingBottomPoint = -scrollOffset + self.scrollSize
    }
    
    // Установка размера области прокрутки
    mutating func setScrollSize(_ size: CGSize) {
        scrollSize = size
    }
    
    // Установка размера содержимого
    mutating func setContentSize(_ size: CGSize) {
        contentSize = size
    }
    
    // Получить конкретную координату угла видимой области прокрутки
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
    
    // Получить координату центра видимой области прокрутки
    func getCenterPointOfVisibleArea() -> CGPoint {
        // Получение среднего значения
        scrollViewLeadinsTopPoint ~~ scrollViewTrailingBottomPoint
    }
}
