//
//  ScrollableMapForSetting.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 15/11/23.
//

import SwiftUI

// Прокрутка карты для установки точек
struct ScrollableMapForSettingPoints: View {
    
    @Binding var mapImage: Image // Изображение карты
    @Binding var mode: SettingPointMode // Режим работы установки углов изображения карты
    
    @Binding var isPinLocked: [CornerType: Bool]? // Заблокированы ли точки
    @Binding var cornerPointsOnImage: [CornerType: CGPoint]? // Координаты углов карты на изображении
    
    @Binding var centerPoint: CGPoint // Центр изображения карты
    
    @Binding var explicitlyScrollToThisPoint: CGPoint // Прокрутка к определенной точке
    
    @GestureState private var zoom = 1.0 // Масштаб карты
    
    @State private var scrollHelper = ScrollHelper.zero // Помощник прокрутки
    
    private let scrollerId = 22222 // Уникальный идентификатор для прокрутки
    private let unlockedImageName = "smallcircle.filled.circle"
    private let lockedImageName = "link.circle.fill"
    
    // Внутренние отступы для карты
    private let padding: EdgeInsets = EdgeInsets(top: UIScreen.main.bounds.height / 2, leading: UIScreen.main.bounds.width / 2, bottom: UIScreen.main.bounds.height / 2, trailing: UIScreen.main.bounds.width / 2)
    private let pointOnMap = PointOnMapCalculator(corners: DataSource.instance.corners) // Переменная для расчета координат на карте

    
    var body: some View {
        // Позволяет получать доступ к информации о прокрутке ScrollView и взаимодействовать с ней
        ScrollViewReader { reader in
            ZStack {
                // Позволяет получать информацию о геометрии и размерах представления, в котором он находится
                GeometryReader { scrollGeoProxy in
                    ScrollView ([.horizontal, .vertical]) {
                        ZStack {
                            mapImage
                                .scaleEffect(zoom)
                                .gesture(
                                    MagnifyGesture()
                                        .updating($zoom) { value, gestureState, transaction in
                                            gestureState = value.magnification
                                        }
                                )
                                .padding(padding)
                                .backgroundStyle(.clear)
                            
                            Spacer().frame(width: 0, height: 0).id(scrollerId).background(.clear)
                            
                            ForEach(CornerType.allCases) { cornerType in
                                if let pinLocked = isPinLocked?[cornerType], pinLocked, let cornerPointOnImage = cornerPointsOnImage?[cornerType] {
                                    Image(systemName: lockedImageName)
                                        .foregroundStyle(.blue)
                                        .position(cornerPointOnImage)
                                        .onTapGesture {
                                            withAnimation {
                                                reader.scrollTo(scrollerId, anchor: scrollHelper.getUnitPoint(from: cornerPointOnImage))
                                            }
                                        }
                                }
                            }
                        }
                        .scrollTargetLayout()
                        .background(
                            GeometryReader { contentGeoProxy in
                                Color.blue
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: contentGeoProxy.frame(in: .named("scroll")).origin)
                                    .preference(key: IntrinsicContentSizePreferenceKey.self, value: contentGeoProxy.size)
                                    .onPreferenceChange(IntrinsicContentSizePreferenceKey.self) { value in
                                        scrollHelper.setContentSize(value)
                                        
                                        if let isPinLocked = isPinLocked?[.NW], !isPinLocked {
                                            cornerPointsOnImage?[.NW] = scrollHelper.contentSize.upperLeftPoint(relatedTo: padding)
                                        }
                                        if let isPinLocked = isPinLocked?[.NE], !isPinLocked {
                                            cornerPointsOnImage?[.NE] = scrollHelper.contentSize.upperRightPoint(relatedTo: padding)
                                        }
                                        if let isPinLocked = isPinLocked?[.SW], !isPinLocked {
                                            cornerPointsOnImage?[.SW] = scrollHelper.contentSize.lowerLeftPoint(relatedTo: padding)
                                        }
                                        if let isPinLocked = isPinLocked?[.SE], !isPinLocked {
                                            cornerPointsOnImage?[.SE] = scrollHelper.contentSize.lowerRightPoint(relatedTo: padding)
                                        }
                                        if let isPinLocked = isPinLocked?[.center], !isPinLocked {
                                            cornerPointsOnImage?[.center] = scrollHelper.contentSize.centerPoint(relatedTo: padding)
                                        }
                                        
                                        
                                        withAnimation {
                                            if let cornerType = mode.getCornerType(), let corner = cornerPointsOnImage?[cornerType] {
                                                reader.scrollTo(scrollerId, anchor: scrollHelper.getUnitPoint(from: corner))
                                            }
                                        }
                                    }
                            }
                        )
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            let frame = scrollGeoProxy.frame(in: .named("MyScrollViewCoordSpace"))
                            scrollHelper.setScrollSizeFromIncludedInsetValue(value: value, 
                                                       inFrmae: frame,
                                                       withInsets: scrollGeoProxy.safeAreaInsets)
                            
                            centerPoint = scrollHelper.getCenterPointOfVisibleArea()
                            
                            // Вычислить дельты широты и долготы
                            let coordOfTopLeading = pointOnMap.getCoordinatesFrom(point: scrollHelper.getCornerPointOfVisibleArea(corner: .topLeading))
                            let coordOfBottomTrailing = pointOnMap.getCoordinatesFrom(point: scrollHelper.getCornerPointOfVisibleArea(corner: .bottomTrailing))
                        }
                    }
                }
                
                if case .showingButtons(_) = mode {}
                else {
                    if let cornerType = mode.getCornerType() {
                        if let isPinLocked = isPinLocked?[cornerType], !isPinLocked {
                            Image(systemName: unlockedImageName)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .coordinateSpace(name: "MyScrollViewCoordSpace")
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self) { value in
                scrollHelper.setScrollSize(value)
                
                withAnimation {
                    if let cornerType = mode.getCornerType(), let point = cornerPointsOnImage?[cornerType] {
                        reader.scrollTo(scrollerId, anchor: scrollHelper.getUnitPoint(from: point))
                    }
                }
            }
            .onChange(of: explicitlyScrollToThisPoint) {
                withAnimation {
                    reader.scrollTo(scrollerId, anchor: scrollHelper.getUnitPoint(from: explicitlyScrollToThisPoint))
                }
            }
        }
    }
}

// Определяет ключ предпочтений для отслеживания смещения прокрутки
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

// Передача размера встроенного содержимого представления
struct IntrinsicContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// Передача размера представления
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

