//
//  ContentView.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 17/11/23.
//

import SwiftUI
import CoreLocation // Для определения пользовательских координат
import MapKit // Для использоватения встроенной карты от Apple

// Окно для навигации по готовому изображению карты
struct MapView: View {
    @State private var mapImage: Image = Image(systemName: "pencil") // Изображение карты
    
    // Экземпляр класса получения координат пользователя от системы
    @StateObject var locationDataManager = AppLogic.instance.locationDataManager
    
    @State var coord: CLLocationCoordinate2D? // Координаты местоположения пользователя
    
    @State var followLocation: Bool = true // Следование за местоположением пользователя
    @State var sliderValue: Double = 1 // Значение ползунка прозрачности слоя
    
    // Положение реальной карты
    @State var positionOfCameraOnRealMap = MapCameraPosition.region(
        MKCoordinateRegion(center: .init(latitude: 60,longitude: 30),
                           span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    )
    @State var scrollHelper = ScrollHelper.zero
    
    // Переменная для соотношения масштаба реальной карты с изображением
    @State private var lastSpanOfRealMap = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    @State private var centerPointOnMyMap: CGPoint = .zero // Центральная точка на изображении карты
    @State var geoCoordinatesOnMyMap: GeoCoordinates? // Геокоординаты на изображении карты
    @State var geoCoordinatesOnRealMap: CLLocationCoordinate2D? // Геокоординаты на реальной карте
    
    // Калькулятор расчета точки на карте
    private let pointOnMap = PointOnMapCalculator(corners: DataSource.instance.corners)
    
    // Определение масштаба для встроенной карты
    private let mapSpanCalculator = MapSpanCalculator(corners: DataSource.instance.corners)
    
    var body: some View {
        VStack {
            ZStack {
                Map(position: $positionOfCameraOnRealMap)
                    .mapStyle(.hybrid)
                    .scrollDisabled(true)
                
                ScrollableMap(mapImage: $mapImage,
                              coord: $coord, // <<< in
                              centerPoint: $centerPointOnMyMap, // >>> out
                              followLocation: $followLocation,
                              scrollHelper: $scrollHelper
                )
                .opacity(sliderValue)
                .onChange(of: scrollHelper.scrollSize) {
                    let minLength = min(scrollHelper.scrollSize.width, scrollHelper.scrollSize.height)
                    if let span = mapSpanCalculator.getSpanFrom(deltaX: minLength, deltaY: minLength) {
                        lastSpanOfRealMap = span
                    }
                }
                .onChange(of: centerPointOnMyMap) {
                    geoCoordinatesOnMyMap = pointOnMap.getCoordinatesFrom(point: centerPointOnMyMap)
                    
                    repaintRealMapAccordingMyMap()
                }
            }
            Slider(value: $sliderValue,
                   in: 0.1...1)
        }
        .toolbar {
            Button(" ", systemImage: followLocation ? "location.fill" : "location") {
                followLocation = !followLocation
            }
        }
        .onAppear {
            mapImage = DataSource.instance.mapImage ?? Image(systemName: "pencil")
            locationDataManager.startUpdatingLocation()
        }
        .onDisappear {
            locationDataManager.stopUpdatingLocation()
        }
        .onChange(of: locationDataManager.coord) {
            coord = locationDataManager.coord!
            
            positionOfCameraOnRealMap = MapCameraPosition.region(
                MKCoordinateRegion(center: coord!,
                                   span: lastSpanOfRealMap)
            )
        }
    }
    
    // Переопределить реальную карту в соответствии с изображением карты и ее коррекцией
    private func repaintRealMapAccordingMyMap() {
        if let location = geoCoordinatesOnMyMap {
            
            let correction = DataSource.instance.mapCorrection
            
            positionOfCameraOnRealMap = MapCameraPosition.region(
                MKCoordinateRegion(center: .init(latitude: (location.lat + correction.lat).coordInDeg,
                                                 longitude: (location.long + correction.long).coordInDeg),
                                   span: lastSpanOfRealMap)
            )
        }
    }
}

#Preview {
    MapView()
}

struct MapView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            MapView()
        }
    }
}
