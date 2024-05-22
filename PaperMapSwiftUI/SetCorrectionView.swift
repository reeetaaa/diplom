//
//  ContentView.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 21/10/23.
//
//

// https://www.hackingwithswift.com/forums/swiftui/centre-coordinates-from-visible-map/23052

import SwiftUI
import MapKit

// Окно настройки коррекции карты
struct SetCorrectionView: View {
    
    @Binding var showCorrectionPage: Bool
    
    @State private var mode: SettingPointMode = .editingCornerCoordinates(.center) // Режим работы окна
    
    @State private var mapImage: Image = Image(systemName: "map") // Изображение карты
    
    // Переменная для отслеживания был ли заведен угол изображения карты
    @State private var isPinLocked:         [CornerType: Bool]? = [.center: false]
    @State private var cornerPointsOnImage: [CornerType: CGPoint]? = [.center: .zero]
    
    // Точка центра изображения карты
    @State private var centerPointOnMyMap: CGPoint = .zero
    // Точка, к которой необходимо переместить метку
    @State private var explicitlyScrollMapToThisPoint: CGPoint = .zero
    
    // Координаты коррекции
    @State private var correction = GeoCoordinates(coordType: .minDecimals(1))
    
    // Положение реальной карты
    @State var positionOfCameraOnRealMap = MapCameraPosition.region(
        MKCoordinateRegion(center: .init(latitude: 60,longitude: 30),
                           span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    )
    
    @State var geoCoordinatesOnMyMap: GeoCoordinates? // Геокоординаты на изображении карты
    @State var geoCoordinatesOnRealMap: CLLocationCoordinate2D? // Геокоординаты на реальной карте
    
    @State private var lastSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    @State private var iDidScroll = false
    
    // Калькулятор расчета точки на карте
    private let pointOnMap = PointOnMapCalculator(corners: DataSource.instance.corners)
    
    // Изображение метки
    private let unlockedImageName = "smallcircle.filled.circle"
    
    var body: some View {
        VStack {
            ScrollableMapForSettingPoints(mapImage: $mapImage,
                                          mode: $mode,
                                          isPinLocked: $isPinLocked,
                                          cornerPointsOnImage: $cornerPointsOnImage,
                                          centerPoint: $centerPointOnMyMap,
                                          explicitlyScrollToThisPoint: $explicitlyScrollMapToThisPoint)
            .onChange(of: centerPointOnMyMap) {
                geoCoordinatesOnMyMap = pointOnMap.getCoordinatesFrom(point: centerPointOnMyMap)
                
                repaintRealMapAccordingMyMap()
            }
            
            Text("Координаты изображения карты: \(geoCoordinatesOnMyMap?.getCoordinatesString(separator: "; ") ?? "-")" )
            
            Text("Коррекция: \(correction.getCoordinatesString(separator: "; "))")
                .bold()
            
            let realCoord = geoCoordinatesOnRealMap?.getCoordinatesString(coordType: correction.geoCoordType, separator: "; ")
            Text("Истинные коорд.: \(realCoord ?? "-")")
            
            ZStack {
                Map(position: $positionOfCameraOnRealMap)
                    .mapStyle(.hybrid)
                    .onMapCameraChange { mapCameraUpdateContext in
                        geoCoordinatesOnRealMap = mapCameraUpdateContext.camera.centerCoordinate
                        updateCorrection()
                        
                        if iDidScroll {
                            iDidScroll = false
                        } else {
                            lastSpan = mapCameraUpdateContext.region.span
                        }
                    }
                
                Image(systemName: unlockedImageName)
                    .foregroundStyle(.red)
                
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            ZoomButton(title: "+",
                                       zoomMultiplier: 0.6,
                                       lastSpan: $lastSpan) {
                                repaintRealMapAccordingMyMap()
                            }
                            ZoomButton(title: "-",
                                       zoomMultiplier: 1 / 0.6,
                                       lastSpan: $lastSpan) {
                                repaintRealMapAccordingMyMap()
                            }
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        
                        .padding(EdgeInsets(top: 80, leading: 10, bottom: 0, trailing: 10))
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            mapImage = DataSource.instance.mapImage ?? Image(systemName: "map")
            correction = GeoCoordinates(coordType: DataSource.instance.coordinateType)
        }
        .toolbar {
            Button("Save") {
                DataSource.instance.mapCorrection = correction
                showCorrectionPage = false // This will close the window
            }
        }
    }
    
    // Обновление координат коррекции карты
    private func updateCorrection() {
        if let geoCoordinatesOnRealMap = geoCoordinatesOnRealMap, 
            let geoCoordinatesOnMyMap = geoCoordinatesOnMyMap {
            correction = GeoCoordinates(from: geoCoordinatesOnRealMap, coordType: correction.geoCoordType) - geoCoordinatesOnMyMap
        }
    }
    
    // Переопределить реальную карту в соответствии с коррекцией изображения карты
    private func repaintRealMapAccordingMyMap() {
        if let location = geoCoordinatesOnMyMap {
            positionOfCameraOnRealMap = MapCameraPosition.region(
                MKCoordinateRegion(center: .init(latitude: (location.lat + correction.lat).coordInDeg,
                                                 longitude: (location.long + correction.long).coordInDeg),
                                   span: lastSpan)
            )
            iDidScroll = true
        }
    }
}

#Preview {
    SetCorrectionView(showCorrectionPage: .constant(true))
}

struct SetCorrectionView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SetCorrectionView(showCorrectionPage: .constant(true))
        }
    }
}

// Кнопка для масштабирования реальной карты
struct ZoomButton: View {
    var title: String
    var zoomMultiplier: Double
    
    @Binding var lastSpan: MKCoordinateSpan
    
    var action: () -> Void
    
    var body: some View {
        Button(title) {
            lastSpan.latitudeDelta *= zoomMultiplier
            lastSpan.longitudeDelta *= zoomMultiplier
            action()
        }
        .padding(EdgeInsets(top: 0,
                            leading: 0,
                            bottom: 3,
                            trailing: 0))
        .frame(maxWidth: .infinity)
        .buttonStyle(.bordered)
        .background(Color.cyan)
        .border(Color.cyan)
        .foregroundColor(.black)
        .cornerRadius(5)
    }
}
