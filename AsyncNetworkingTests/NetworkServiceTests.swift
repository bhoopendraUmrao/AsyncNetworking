//
//  NetworkServiceTests.swift
//  AsyncNetworking
//
//  Created by Bhoopendra Umrao on 02/04/23.
//

import XCTest
@testable import AsyncNetworking

final class NetworkServiceTests: XCTestCase {

    class NetworkErrorLoggerMock: NetworkErrorLogger {
        var loggedErrors: [Error] = []
        func log(request: URLRequest) { }
        func log(responseData data: Data?, response: URLResponse?) { }
        func log(error: Error) { loggedErrors.append(error) }
    }

    private enum NetworkErrorMock: Error {
        case someError
    }

    func test_whenMockDataPassed_shouldReturnProperResponse() async {
        // given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return correct data")

        let expectedResponseData = "Response data".data(using: .utf8)!
        let sut = DefaultNetworkService(config: config,
                                        sessionManager: NetworkSessionManagerMock(response: nil,
                                                                                  data: expectedResponseData,
                                                                                  error: nil))
        // when
        do {
            let result = try await sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get))
            XCTAssertEqual(result, expectedResponseData)
            expectation.fulfill()
        } catch {
            XCTFail("Should return proper response")
        }
        // then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenErrorWithNSURLErrorCancelledReturned_shouldReturnCancelledError() async {
        // given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return hasStatusCode error")

        let cancelledError = NSError(domain: "network", code: NSURLErrorCancelled, userInfo: nil)
        let sut = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(response: nil,
                                                      data: nil,
                                                      error: cancelledError as Error)
        )
        // when
        do {
            _ = try await sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get))
            XCTFail("Should not happen")
        } catch let error {
            guard case NetworkError.cancelled = error else {
                XCTFail("NetworkError.cancelled not found")
                return
            }

            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenErrorWithNSURLErrorNotConnectedToInternetReturned_shouldReturnNotConnectedError() async {
        // given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return hasStatusCode error")

        let error = NSError(domain: "network", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let sut = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(response: nil,
                                                      data: nil,
                                                      error: error as Error)
        )
        // when
        do {
            _ = try await sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get))
            XCTFail("Should not happen")
        } catch let error {
            guard case NetworkError.notConnected = error else {
                XCTFail("NetworkError.notConnected not found")
                return
            }

            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenhasStatusCodeUsedWithWrongError_shouldReturnFalse() {
        // when
        let sut = NetworkError.notConnected
        // then
        XCTAssertFalse(sut.hasStatusCode(200))
    }

    func test_whenhasStatusCodeUsed_shouldReturnCorrectStatusCode_() {
        // when
        let sut = NetworkError.error(statusCode: 400, data: nil)
        // then
        XCTAssertTrue(sut.hasStatusCode(400))
        XCTAssertFalse(sut.hasStatusCode(399))
        XCTAssertFalse(sut.hasStatusCode(401))
    }

    func test_whenErrorWithNSURLErrorNotConnectedToInternetReturned_shouldLogThisError() async {
        // given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return hasStatusCode error")

        let error = NSError(domain: "network", code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        let networkErrorLogger = NetworkErrorLoggerMock()
        let sut = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(response: nil,
                                                      data: nil,
                                                      error: error as Error),
            logger: networkErrorLogger
        )
        // when
        do {
            _ = try await sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get))
            XCTFail("Should not happen")
        } catch let error {
            guard case NetworkError.notConnected = error else {
                XCTFail("NetworkError.notConnected not found")
                return
            }

            expectation.fulfill()
        }

        // then
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(networkErrorLogger.loggedErrors.contains {
            guard case NetworkError.notConnected = $0 else { return false }
            return true
        })
    }
}
