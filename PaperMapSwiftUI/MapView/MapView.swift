//
//  ContentView.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 17/11/23.
//

import SwiftUI
import CoreLocation // Для определения пользовательских координат
import MapKit // Для использоватения встроенной карты от Apple

struct MapView: View {
    @State private var mapImage: Image = Image(systemName: "pencil")
    
    @StateObject var locationDataManager = MyAppLogic.instance.locationDataManager
    
    @State var coord: CLLocationCoordinate2D?
    
    @State var followLocation: Bool = true
    @State var sliderValue: Double = 1
    
    @State var positionOfCameraOnRealMap = MapCameraPosition.region(
        MKCoordinateRegion(center: .init(latitude: 60,longitude: 30),
                           span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
    )
    @State var scrollHelper = ScrollHelper.zero
    
    @State private var lastSpanOfRealMap = MKCoordinateSpan(latitudeDelta: 0.01,                                                         longitudeDelta: 0.01)
    
    
    @State private var centerPointOnMyMap: CGPoint = .zero
    @State var geoCoordinatesOnMyMap: GeoCoordinates?
    @State var geoCoordinatesOnRealMap: CLLocationCoordinate2D?
    
    
    private let pointOnMap = PointOnMapCalculator(corners: MyAppLogic.instance.corners)
    
    private let mapSpanCalculator = MapSpanCalculator(corners: MyAppLogic.instance.corners)
    
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
    
    private func repaintRealMapAccordingMyMap() {
        if let location = geoCoordinatesOnMyMap {
            
            let correction = MyAppLogic.instance.mapCorrection
            
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
