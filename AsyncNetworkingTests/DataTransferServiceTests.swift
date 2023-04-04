//
//  DataTransferServiceTests.swift
//  AsyncNetworking
//
//  Created by Bhoopendra Umrao on 02/04/23.
//

import XCTest
@testable import AsyncNetworking

private struct MockModel: Decodable {
    let name: String
}

final class DataTransferServiceTests: XCTestCase {

    private enum DataTransferErrorMock: Error {
        case someError
    }

    func test_SuccessResponse() async throws {
        // given
        let expectation = self.expectation(description: "Should decode mock object")

        let responseData = #"{"name": "Hello"}"#.data(using: .utf8)

        let config = NetworkConfigurableMock()
        let networkServiceSpy = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(response: nil, data: responseData, error: nil)
        )

        let sut = DefaultDataTransferService(with: networkServiceSpy)

        let result = try await sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)
        )
        XCTAssertEqual(result?.name, "Hello")
        expectation.fulfill()
        // then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_FailureWithInvalidDecoding() async {
        // given
        let expectation = self.expectation(description: "Should not decode mock object")

        let responseData = #"{"age": 20}"#.data(using: .utf8)
        let config = NetworkConfigurableMock()
        let networkServiceSpy = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(response: nil, data: responseData, error: nil)
        )

        let sut = DefaultDataTransferService(with: networkServiceSpy)
        // when
        do {
            _ = try await sut.request(
                with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)
            )
            XCTFail("Should not happen")
        } catch {
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_FailureWithBadRequest() async {
        // given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should throw network error")

        let responseData = #"{"invalidStructure": "Nothing"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: nil)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: response,
                data: responseData,
                error: DataTransferErrorMock.someError
            )
        )

        let sut = DefaultDataTransferService(with: networkService)
        // when
        do {
            _ = try await sut.request(
                with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)
            )
            XCTFail("Should not happen")
        } catch let error {
            if case DataTransferError.networkFailure(
                .generic(DataTransferErrorMock.someError)
            ) = error {
                expectation.fulfill()
            } else {
                XCTFail("Wrong error")
            }
        }

        // then
        wait(for: [expectation], timeout: 0.1)
    }

    func test_FailureDataNotReceived() async {
        // given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should throw no data error")

        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: response,
                data: nil,
                error: nil
            )
        )

        let sut = DefaultDataTransferService(with: networkService)
        // when
        do {
            _ = try await sut.request(
                with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)
            )
            XCTFail("Should not happen")
        } catch let error {
            if case DataTransferError.noResponse = error {
                expectation.fulfill()
            } else {
                XCTFail("Wrong error")
            }
        }
        // then
        wait(for: [expectation], timeout: 0.1)
    }
}
