import XCTest
import MapKit
@testable import Argonaut

class TestShooter:XCTestCase {
    private var map:Map!
    
    override func setUp() {
        map = Map()
        map.path = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("test")
        map.shooterType = MockShooter.self
        map.zooms = [Zoom(level:2)]
    }
    
    override func tearDown() {
        MockShooter.image = nil
        MockShooter.error = nil
        try? FileManager.default.removeItem(at:map.path)
    }
    
    func testHappyPath() {
        let expect = expectation(description:String())
        MockShooter.image = makeImage(width:1, height:1)
        map.onSuccess = { url in expect.fulfill() }
        map.makeMap(points:[MKPointAnnotation()])
        waitForExpectations(timeout:1)
    }
    
    func testUpdateProgress() {
        let expect = expectation(description:String())
        MockShooter.image = makeImage(width:1, height:1)
        map.onProgress = { progress in
            XCTAssertEqual(Thread.main, Thread.current)
            XCTAssertGreaterThanOrEqual(progress, 0)
            XCTAssertLessThanOrEqual(progress, 1)
            if progress == 1 {
                expect.fulfill()
            }
        }
        DispatchQueue.global(qos:.background).async { self.map.makeMap(points:[MKPointAnnotation()]) }
        waitForExpectations(timeout:1)
    }
    
    private func makeImage(width:Double, height:Double) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width:width, height:height))
        let image = UIImage(cgImage:UIGraphicsGetCurrentContext()!.makeImage()!)
        UIGraphicsEndImageContext()
        return image
    }
}
