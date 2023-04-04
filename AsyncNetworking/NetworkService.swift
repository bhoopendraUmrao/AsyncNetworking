//
//  NetworkService.swift
//  AsyncNetworking
//
//  Created by Bhoopendra Umrao on 3/31/23.
//

import Foundation

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

extension NetworkError {
    func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _): return code == codeError
        default: return false
        }
    }
}

public protocol NetworkService {
    func request(endpoint: Requestable) async throws -> Data?
}

public protocol NetworkSessionManager {
    func request(_ request: URLRequest) async throws -> (Data?, URLResponse?)
}

public protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

public final class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() { }
    public func request(_ request: URLRequest) async throws -> (Data?, URLResponse?) {
        try await URLSession.shared.data(for: request)
    }
}

public final class DefaultNetworkService: NetworkService {

    private let config: NetworkConfigurable
    private let logger: NetworkErrorLogger
    private let sessionManager: NetworkSessionManager

    public init(
        config: NetworkConfigurable,
        sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = logger
    }

    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension DefaultNetworkService {
    public func request(endpoint: Requestable) async throws -> Data? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            let (data, response) = try await sessionManager.request(urlRequest)
            self.logger.log(responseData: data, response: response)
            return data
        } catch let requestError {
            var error: NetworkError
            error = self.resolve(error: requestError)
            self.logger.log(error: error)
            throw error
        }
    }
}

// MARK: - Logger

public final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    public init() { }
    public func log(request: URLRequest) {
        printIfDebug("-------------")
        printIfDebug("request: \(request.url!)")
        printIfDebug("headers: \(request.allHTTPHeaderFields!)")
        printIfDebug("method: \(request.httpMethod!)")
        if
            let httpBody = request.httpBody,
            let result = try? JSONSerialization.jsonObject(with: httpBody) as? [String: AnyObject] {
            printIfDebug("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("body: \(String(describing: resultString))")
        }
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("responseData: \(String(describing: dataDict))")
        }
    }

    public func log(error: Error) {
        printIfDebug("\(error)")
    }

    func printIfDebug(_ string: String) {
        #if DEBUG
        print(string)
        #endif
    }
}
