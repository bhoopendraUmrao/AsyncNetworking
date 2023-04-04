//
//  EndPointMock.swift
//  AsyncNetworking
//
//  Created by Bhoopendra Umrao on 02/04/23.
//
import Foundation
@testable import AsyncNetworking

struct EndpointMock: Requestable {

    var path: String
    var isFullPath: Bool = false
    var method: HTTPMethodType
    var headerParamaters: [String: String] = [:]
    var queryParametersEncodable: Encodable?
    var queryParameters: [String: Any] = [:]
    var bodyParamatersEncodable: Encodable?
    var bodyParamaters: [String: Any] = [:]
    var bodyEncoding: BodyEncoding = .stringEncodingAscii

    init(path: String, method: HTTPMethodType) {
        self.path = path
        self.method = method
    }
}

