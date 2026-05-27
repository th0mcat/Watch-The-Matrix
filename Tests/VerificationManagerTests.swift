import XCTest
@testable import Watch_The_Matrix_WatchKit_App

final class VerificationManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "deviceVerified")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "deviceVerified")
        super.tearDown()
    }
    
    func testInitialStateWhenNotVerified() {
        let verificationManager = VerificationManager()
        
        if case .unverified = verificationManager.state {
            XCTAssertTrue(verificationManager.canVerify)
        } else {
            XCTFail("Expected unverified state")
        }
    }
    
    func testConfirmVerificationPersistsFlag() {
        let verificationManager = VerificationManager()
        
        verificationManager.confirmVerification()
        let persistedVerificationManager = VerificationManager()
        
        guard case .verified = verificationManager.state else {
            XCTFail("Expected verified state")
            return
        }
        XCTAssertTrue(VerificationManager.isVerified)
        
        guard case .verified = persistedVerificationManager.state else {
            XCTFail("Expected persisted verified state")
            return
        }
        XCTAssertFalse(persistedVerificationManager.canVerify)
    }
    
    func testInitialStateWhenPersistedAsVerified() {
        UserDefaults.standard.set(true, forKey: "deviceVerified")
        
        let verificationManager = VerificationManager()
        
        if case .verified = verificationManager.state {
            XCTAssertFalse(verificationManager.canVerify)
        } else {
            XCTFail("Expected verified state")
        }
    }
}
