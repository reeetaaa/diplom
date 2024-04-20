//
//  ScrollableMapForSetting.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 15/11/23.
//

import SwiftUI
import CoreLocation
import CoreLocationUI


struct ScrollableMap: View {
    
    // MARK: - Bindings
    @Binding var mapImage: Image
    @Binding var coord: CLLocationCoordinate2D?  // <<< in
    @Binding var centerPoint: CGPoint            // >>> out
    @Binding var followLocation: Bool
    @Binding var scrollHelper: ScrollHelper // >>> out
    
//    @Binding var frameOfScrollableMap: CGRect
    
    // MARK: - States
    @GestureState private var zoom = 1.0
    
//    @State private var scrollHelper = ScrollHelper.zero
    @State private var scrollOffset: CGPoint = .zero
    
    @State private var userPointOnMap: CGPoint = .zero
    
    @StateObject var locationManager = LocationManager()
    
    @State var correction = GeoCoordinates()
    
    
    private let scrollerId = 22222
    
    private let pointOnMap = PointOnMapCalculator(corners: MyAppViewModel.instance.getCorners())
    
    private let padding: EdgeInsets = EdgeInsets(top: UIScreen.main.bounds.height / 2, leading: UIScreen.main.bounds.width / 2, bottom: UIScreen.main.bounds.height / 2, trailing: UIScreen.main.bounds.width / 2)
    
    private let userImage = "location.circle.fill" // "circle.fill" // smallcircle.filled.circle  location.circle.fill
    
    
    var body: some View {
        ScrollViewReader { reader in
            ZStack {
                GeometryReader { scrollGeoProxy in
                    ScrollView ([.horizontal, .vertical]) {
                        ZStack {
                            
                            VStack {
                                mapImage
                                    .scaleEffect(zoom)
                                    .gesture(
                                        MagnifyGesture()
                                            .updating($zoom) { value, gestureState, transaction in
                                                gestureState = value.magnification
                                            }
                                    )
                                    .padding(padding)
                                    .backgroundStyle(.white)
                            }
                            
                            Spacer().frame(width: 0, height: 0).id(scrollerId).background(.clear)
                            
                            
                            if userPointOnMap.isInsideTheSize(scrollHelper.contentSize) {
                                Image(systemName: userImage)
                                    .foregroundStyle(.blue)
                                    .position(userPointOnMap)
                            }
                            
                        }
                        .scrollTargetLayout()
                        .background(
                            GeometryReader { contentGeoProxy in
                                Color.white
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: contentGeoProxy.frame(in: .named("scroll")).origin)
                                    .preference(key: IntrinsicContentSizePreferenceKey.self, value: contentGeoProxy.size)
                                    .onPreferenceChange(IntrinsicContentSizePreferenceKey.self) { value in
                                        scrollHelper.setContentSize(value)
                                        if followLocation {
                                            scrollToPoint(userPointOnMap, reader: reader)
                                        }
                                    }
                            }
                        )
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offsetValue in
                            let frame = scrollGeoProxy.frame(in: .named("MyScrollViewCoordSpace"))
                            
                            scrollHelper.setScrollSizeFromIncludedInsetValue(value: offsetValue,
                                                                             inFrmae: frame,
                                                                             withInsets:  scrollGeoProxy.safeAreaInsets)
                            
                            centerPoint = scrollHelper.getCenterPointOfVisibleArea()
                        }
                        
                    }
                    .simultaneousGesture( // normal .gesture will not work here because there is .gesture on mapImage above
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                followLocation = false // if user starts scrolling, don't follow location
                            }
                    )
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                    .onDisappear {
                        UIScrollView.appearance().bounces = true
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
                if followLocation {
                    scrollToPoint(userPointOnMap, reader: reader)
                }
            }
            .onAppear() {
                correction = MyAppViewModel.instance.getMapCorrection()
                if let coord = coord {
                    correctAndFindPointOnMapAndScrollIfNeeded(from: coord, reader: reader)
                } else if let coord = MyAppViewModel.instance.lastSavedCoord {
                    correctAndFindPointOnMapAndScrollIfNeeded(from: coord, reader: reader)
                }
            }
            .onChange(of: coord) {
                correctAndFindPointOnMapAndScrollIfNeeded(from: coord!, reader: reader)
            }
            .onChange(of: followLocation) {
                if followLocation {
                    scrollToPoint(userPointOnMap, reader: reader)
                }
            }
        }
    }
    
    private func scrollToPoint(_ pointOnMap: CGPoint, reader: ScrollViewProxy) {
        withAnimation {
            reader.scrollTo(scrollerId, anchor: scrollHelper.getUnitPoint(from: userPointOnMap))
        }
    }
    
    private func correctAndFindPointOnMapAndScrollIfNeeded(from coord: CLLocationCoordinate2D, reader: ScrollViewProxy) {
        let correctedCoord = GeoCoordinates(from: coord, coordType: DataSource.instance.coordinateType) 
                                - correction
        
        if let pointOnMap = pointOnMap.getPointFrom(geoPos: correctedCoord)?.pointOnMap {
            userPointOnMap = pointOnMap
            if followLocation {
                scrollToPoint(userPointOnMap, reader: reader)
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR OF LOCATION: ", error)
    }
}


final class ScrollDelegate: NSObject, UITableViewDelegate, UIScrollViewDelegate {
    var isScrolling: Binding<Bool>?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let isScrolling = isScrolling?.wrappedValue,!isScrolling {
            self.isScrolling?.wrappedValue = true
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let isScrolling = isScrolling?.wrappedValue, isScrolling {
            self.isScrolling?.wrappedValue = false
        }
    }
    // When the user slowly drags the scrollable control, decelerate is false after the user releases their finger, so the scrollViewDidEndDecelerating method is not called.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let isScrolling = isScrolling?.wrappedValue, isScrolling {
                self.isScrolling?.wrappedValue = false
            }
        }
    }
}



