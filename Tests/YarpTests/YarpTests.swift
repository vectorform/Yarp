import XCTest
@testable import Yarp

final class YarpTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Yarp().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
