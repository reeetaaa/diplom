//
//  GeoCoordinateTests.swift
//  PaperMapTests
//
//  Created by Margarita Babukhadia on 20/02/24.
//  Copyright © 2024 Margarita Babukhadia. All rights reserved.
//

import XCTest
@testable import PaperMapSwiftUI

final class GeoCoordinateTests: XCTestCase {
    
    var coord: GeoCoordinate!
    
    override func setUpWithError() throws {
        coord = GeoCoordinate(coordType: .degDecimals(5))
    }
    
    func testCheckSettingCoordinate1() {
        // Given (Arange)
        coord.coordInDeg = 41
        coord.geoCoordType = .minDecimals(1)
        
        // When (Act)
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 0)
        XCTAssertEqual(coord.decimalsOfMinutes, 0)
        XCTAssertTrue(coord.isNorthOrEast)
    }
    
    func testCheckSettingCoordinate2() {
        // Given (Arange)
        coord.coordInDeg = -41
        coord.geoCoordType = .minDecimals(1)
        
        // When (Act)
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 0)
        XCTAssertEqual(coord.decimalsOfMinutes, 0)
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckSettingCoordinate3() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        
        // When (Act)
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 22)
        XCTAssertEqual(coord.seconds, 11)
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckSettingCoordinate4() {
        // Given (Arange)
        coord.coordInDeg = -41.3333
        coord.geoCoordType = .secDecimals(0)

        // When (Act)
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 20)
        XCTAssertEqual(coord.decimalsOfMinutes, 0)
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckChangeDeg() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .secDecimals(0)
        
        // When (Act)
        coord.deg = 38
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 38)
        XCTAssertEqual(coord.min, 22)
        XCTAssertEqual(coord.seconds, 11)
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckChangeMin() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .secDecimals(0)
        
        // When (Act)
        coord.min = 33
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 33)
        XCTAssertEqual(coord.seconds, 11)
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckChangeSec() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .secDecimals(0)
        
        // When (Act)
        coord.seconds = 44
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 22)
        XCTAssertEqual(coord.seconds, 44)
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckDecimalsOfMinutes() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .minDecimals(2)
        
        // When (Act)
        
        // Then (Assert)
        XCTAssertEqual(coord.deg, 41)
        XCTAssertEqual(coord.min, 22)
        XCTAssertLessThanOrEqual(abs(coord.decimalsOfMinutes - 0.183332), 0.01 )
        XCTAssertFalse(coord.isNorthOrEast)
    }
    
    func testCheckPrints1() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .degDecimals(4)
        // When (Act)
        let text = coord.getString(isLatitude: true)
        // Then (Assert)
        XCTAssertEqual(text, "41.3697°S")
    }
        
    func testCheckPrints2() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .degDecimals(5)
        // When (Act)
        let text = coord.getString(isLatitude: true)
        // Then (Assert)
        XCTAssertEqual(text, "41.36972°S")
    }
    
    func testCheckPrints3() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11", 41°22.183'S
        coord.geoCoordType = .minDecimals(2)
        // When (Act)
        let text = coord.getString(isLatitude: true)
        // Then (Assert)
        XCTAssertEqual(text, "41°22.18'S")
    }
    
    func testCheckPrints4() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22.11", 41°22.183'S
        coord.geoCoordType = .minDecimals(3)
        // When (Act)
        let text = coord.getString(isLatitude: true)
        // Then (Assert)
        XCTAssertEqual(text, "41°22.183'S")
    }
    
    func testCheckPrints5() {
        // Given (Arange)
        coord.coordInDeg = -41.3697222 // 41°22'11"
        coord.geoCoordType = .secDecimals(0)
        // When (Act)
        let text = coord.getString(isLatitude: true)
        // Then (Assert)
        XCTAssertEqual(text, "41°22'11\"S")
    }
    
    func testCheckPrints6() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22'11.6"
        coord.geoCoordType = .secDecimals(1)
        // When (Act)
        let text = coord.getString(isLatitude: true)
        // Then (Assert)
        XCTAssertEqual(text, "41°22'11.6\"S")
    }
    
    func testCheckPrints7() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22'11.6"
        coord.geoCoordType = .secDecimals(1)
        // When (Act)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "041°22'11.6\"W")
    }
    
    func testCheckPrints8() {
        // Given (Arange)
        coord.coordInDeg = 41.3698889 // 41°22'11.6"
        coord.geoCoordType = .secDecimals(1)
        // When (Act)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "041°22'11.6\"E")
    }
    
    func testDecimalsOfDeg() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22'11.6"
        coord.geoCoordType = .degDecimals(7)
        // When (Act)
        let dec = coord.decimalsOfDegrees
        // Then (Assert)
        XCTAssertEqual(dec, 0.3698889)
    }
    
    func testDecimalsOfMin() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22.193'
        coord.geoCoordType = .minDecimals(3)
        // When (Act)
        let min = coord.decimalsOfMinutes
        // Then (Assert)
        XCTAssertEqual(min, 0.193)
    }
    
    func testDecimalsOfSec() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22'11.6"
        coord.geoCoordType = .secDecimals(1)
        // When (Act)
        let sec = coord.decimalsOfSeconds
        // Then (Assert)
        XCTAssertEqual(sec, 0.6)
    }
    
    func testSettingDecimalsOfDeg() {
        // Given (Arange)
        coord.coordInDeg = 4.3698889
        coord.geoCoordType = .degDecimals(7)
        // When (Act)
        coord.setDecimal(at: 1, value: 1)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "04.1698889°E")
    }
    
    func testSettingDecimalsOfDeg2() {
        // Given (Arange)
        coord.coordInDeg = 4.3698889456
        coord.geoCoordType = .degDecimals(7)
        // When (Act)
        coord.setDecimal(at: 4, value: 1)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "04.3691889°E")
    }
    
    func testSettingDecimalsOfMins() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22.183'W
        coord.geoCoordType = .minDecimals(3)
        // When (Act)
        coord.setDecimal(at: 2, value: 1)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "041°22.113'W")
    }
    
    func testSettingDecimalsOfSecs() {
        // Given (Arange)
        coord.coordInDeg = -41.3698889 // 41°22'11.6"
        coord.geoCoordType = .secDecimals(1)
        // When (Act)
        coord.setDecimal(at: 1, value: 2)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "041°22'11.2\"W")
    }
    
    func testDegMinSecs() {
        // Given (Arange)
        coord.coordInDeg = 3.4333333 // 03°26'00"
        coord.geoCoordType = .secDecimals(0)
        // When (Act)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "003°26'00\"E")
    }
    
    func testDegMinSecs2() {
        // Given (Arange)
        coord.coordInDeg = 60.0333333 // 60°02'00"
        coord.geoCoordType = .secDecimals(0)
        // When (Act)
        let text = coord.getString(isLatitude: false)
        // Then (Assert)
        XCTAssertEqual(text, "060°02'00\"E")
    }
}
