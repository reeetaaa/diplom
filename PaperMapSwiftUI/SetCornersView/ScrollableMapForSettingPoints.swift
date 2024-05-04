//
//  ScrollableMapForSetting.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 15/11/23.
//

import SwiftUI

struct ScrollableMapForSettingPoints: View {
    
    @Binding var mapImage: Image
    @Binding var mode: SettingPointMode
    
    @Binding var isPinLocked: [CornerType: Bool]?
    @Binding var cornerPointsOnImage: [CornerType: CGPoint]?
    
    @Binding var centerPoint: CGPoint
    
    @Binding var explicitlyScrollToThisPoint: CGPoint
    
    @GestureState private var zoom = 1.0
    
    @State private var scrollHelper = ScrollHelper.zero
    
    private let scrollerId = 22222
    private let unlockedImageName = "smallcircle.filled.circle" // "record.circle"
    private let lockedImageName = "link.circle.fill" // "circle.hexagongrid.circle" // "command", "circle.hexagongrid.fill"
    
    
    private let padding: EdgeInsets = EdgeInsets(top: UIScreen.main.bounds.height / 2, leading: UIScreen.main.bounds.width / 2, bottom: UIScreen.main.bounds.height / 2, trailing: UIScreen.main.bounds.width / 2)
    private let pointOnMap = PointOnMapCalculator(corners: MyAppLogic.instance.corners)

    
    var body: some View {
        ScrollViewReader { reader in
            ZStack {
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
                                            //let defaultPosToScroll = scrollHelper.contentSize.middlePoint(relatedTo: padding)
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
                            
                            // MARK: - Calculate deltas of Lat and Long
                            
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


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct IntrinsicContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

