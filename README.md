# AsyncNetworking

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
    static func getCurrentWeather(with request: WeatherRequest) -> Endpoint<RealtimeWeatherResponse> {
        let endpoint = Endpoint<RealtimeWeatherResponse>(
            path: "/weather/realtime",
            method: .get,
            queryParametersEncodable: ["location": request.city]
        )
    }
}
```

**API Data (Data Transfer Objects)**:

```swift
struct WeatherRequest: Encodable {
    let city: String
}

struct RealtimeWeatherResponse: Decodable {

    struct WeatherData: Decodable {
        let time: String?
        let values: Weather?
    }

    struct Location: Decodable {
        let name: String?
        let lat: Double?
        let lon: Double?
    }
    
    struct Weather: Decodable {
        let temperature: Float?
        let windSpeed: Float?
        let windDirection: Float?
        let pressureSurfaceLevel: Float?
        let precipitationProbability: Float?
        let humidity: Float?
        let cloudCover: Float?
        let uvIndex: Float?
        let visibility: Float?
    }
    
    private enum CodingKeys: String, CodingKey {
        case location
        case weather = "data"
    }
    let location: Location?
    let weather: WeatherData?
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
let endpoint = Endpoint<RealtimeWeatherResponse>(
            path: "/weather/realtime",
            method: .get,
            queryParametersEncodable: ["location": query]
        )
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
