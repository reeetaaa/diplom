//
//  ScrollableMapForSetting.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 15/11/23.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

// Прокручиваемое изображение карты
struct ScrollableMap: View {
    
    @Binding var mapImage: Image                 // Изображение карты
    @Binding var coord: CLLocationCoordinate2D?  // Координата <<< in
    @Binding var centerPoint: CGPoint            // Центральная точка >>> out
    @Binding var followLocation: Bool            // Флаг следования за местоположением
    @Binding var scrollHelper: ScrollHelper      // Помощник прокрутки >>> out
    
    @GestureState private var zoom = 1.0         // Состояние жеста масштабирования
    
    @State private var scrollOffset: CGPoint = .zero // Смещение прокрутки
    
    @State private var userPointOnMap: CGPoint = .zero // Точка пользователя на карте
    
    @StateObject var locationManager = LocationManager() // Менеджер местоположения
    
    @State var correction = GeoCoordinates() // Коррекция географических координат
    
    private let scrollerId = 22222 // Идентификатор прокрутки
    
    // Калькулятор расчета точки на карте
    private let pointOnMap = PointOnMapCalculator(corners: DataSource.instance.corners)
    
    private let padding: EdgeInsets = EdgeInsets(top: UIScreen.main.bounds.height / 2, leading: UIScreen.main.bounds.width / 2, bottom: UIScreen.main.bounds.height / 2, trailing: UIScreen.main.bounds.width / 2)
    
    private let userImage = "location.circle.fill"
    
    // Отображение
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
                    .simultaneousGesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                followLocation = false 
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
                correction = DataSource.instance.mapCorrection
                if let coord = coord {
                    correctAndFindPointOnMapAndScrollIfNeeded(from: coord, reader: reader)
                } else if let coord = DataSource.instance.lastSavedCoord {
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
    
    // Прокрутка до указанной точки на карте
    private func scrollToPoint(_ pointOnMap: CGPoint, reader: ScrollViewProxy) {
        withAnimation {
            reader.scrollTo(scrollerId, anchor: scrollHelper.getUnitPoint(from: userPointOnMap))
        }
    }
    
    // Коррекция и поиск точки на карте и, при необходимости, прокрутка
    private func correctAndFindPointOnMapAndScrollIfNeeded(from coord: CLLocationCoordinate2D, reader: ScrollViewProxy) {
        let correctedCoord = GeoCoordinates(from: coord, coordType: DataSource.instance.coordinateType) - correction
        
        if let pointOnMap = pointOnMap.getPointFrom(geoPos: correctedCoord)?.pointOnMap {
            userPointOnMap = pointOnMap
            if followLocation {
                scrollToPoint(userPointOnMap, reader: reader)
            }
        }
    }
}

// Класс для управления местоположением
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    // Запрос местоположения
    func requestLocation() {
        manager.requestLocation()
    }

    // Обработчик обновления местоположения
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    // Обработчик ошибки местоположения
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR OF LOCATION: ", error)
    }
}




