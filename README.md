# AsyncNetworking
# SENetworking

[![CocoaPods](https://img.shields.io/cocoapods/v/SENetworking)](https://cocoapods.org/pods/AsyncAwaitNetworking)
[![Swift 5](https://img.shields.io/badge/compatible-swift%205.0%20-orange.svg)](https://cocoapods.org/pods/AsyncAwaitNetworking)


**A**sync **A**wait **Networking** is  simple and convenient wrapper around URLSession that supports common needs. It is fully tested framework for iOS

- Super Minimal and Light implementation
- Latest async/await implementation
- Easy network configuration
- Works with Decodable for responses and Encodable for Requests
- Friendly API which makes declarations of Endpoints super easy
- Easy use of Data Trasfer Objects and Mappings
- No Singletons
- No external dependencies
- Optimized for unit testing
- Fully tested
- Ideal for code challenges

## Example

**Endpoint definitions**:

```swift
struct APIEndpoints {
    static func getMovies(with moviesRequestDTO: MoviesRequest) -> Endpoint<MoviesResponse> {
        return Endpoint(path: "search/movie/",
                        method: .get,
                        headerParamaters: ["Content-Type": "application/json"], // Optional
                        queryParametersEncodable: moviesRequestDTO)
    }
}
```

**API Data (Data Transfer Objects)**:

```swift
struct MoviesRequest: Encodable {
    let query: String
    let page: Int
}

struct MoviesResponse: Decodable {
    struct Movie: Decodable {
        private enum CodingKeys: String, CodingKey {
            case title
            case overview
            case posterPath = "poster_path"
        }
        let title: String
        let overview: String
        let posterPath: String
    }

    private enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
    let movies: [Movie]
}
```
**API Networking Configuration**:

```swift
struct AppConfiguration {
    var apiKey: String = "xxxxxxxxxxxxxxxxxxxxxxxxx"
    var apiBaseURL: String = "xxxxxxxxxxxxxxxxxxxxxxxxx"
}

class DIContainer {
    static let shared = DIContainer()

    lazy var appConfiguration = AppConfiguration()

    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseURL)!,
                                          queryParameters: ["api_key": appConfiguration.apiKey,
                                                            "language": NSLocale.preferredLanguages.first ?? "en"])

        let apiDataNetwork = DefaultNetworkService(config: config)
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
}
```

**Making API call**:

```swift
let endpoint = APIEndpoints.getMovies(with: MoviesRequest(query: "Batman Begins", page: 1))
return try await dataTransferService.request(with: endpoint)
```


## Installation

### [CocoaPods](https://cocoapods.org): To install it with CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'AsyncAwaitNetworking'
```
Then **pod install** and **import SFNetworking** in files where needed


## Author

Bhoopendra Umrao, umrao16091994@gmail.com

## License

MIL License, Open Source License
