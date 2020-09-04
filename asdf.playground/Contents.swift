
import UIKit

class RestManager {

    var requestHttpHeaders = RestEntity()

    var urlQueryParameters = RestEntity()

    var httpBodyParameters = RestEntity()
    private func addURLQueryParameters(toURL url: URL) -> URL {
        if urlQueryParameters.totalItems() > 0 {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            var queryItems = [URLQueryItem]()
            for (key, value) in urlQueryParameters.allValues() {
                let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                queryItems.append(item)
            }

            urlComponents.queryItems = queryItems

            guard let updatedURL = urlComponents.url else { return url }
            return updatedURL
        }

        return url
    }
    var httpBody: Data?

 private func getHttpBody() -> Data? {
     guard let contentType = requestHttpHeaders.value(forKey: "Content-Type") else { return nil }

     if contentType.contains("application/json") {
         return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [.prettyPrinted, .sortedKeys])
     } else if contentType.contains("application/x-www-form-urlencoded") {
         let bodyString = httpBodyParameters.allValues().map { "\($0)=\(String(describing: $1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))" }.joined(separator: "&")
         return bodyString.data(using: .utf8)
     } else {
         return httpBody
     }
 }
}


extension RestManager {
    enum HttpMethod: String {
        case get
        case post
        case put
        case patch
        case delete
    }
    struct RestEntity {
        private var values: [String: String] = [:]
        mutating func add(value: String, forKey key: String) {
            values[key] = value
        }
        func value(forKey key: String) -> String? {
            return values[key]
        }
        func allValues() -> [String: String] {
            return values
        }
        func totalItems() -> Int {
            return values.count
        }
        struct Results {
            var data: Data?
            var response: Response?
            var error: Error?
            init(withData data: Data?, response: Response?, error: Error?) {
                self.data = data
                self.response = response
                self.error = error
            }

            init(withError error: Error) {
                self.error = error
            }
        }
    }
    struct Response {
        var response: URLResponse?
        var httpStatusCode: Int = 0
        var headers = RestEntity()
        init(fromURLResponse response: URLResponse?) {
            guard let response = response else { return }
            self.response = response
            httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
                for (key, value) in headerFields {
                    headers.add(value: "\(value)", forKey: "\(key)")
                }
            }
        }
    }
    
    enum CustomError: Error {
        case failedToCreateRequest

    }
    
    //test1234

}

extension RestManager.CustomError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .failedToCreateRequest: return NSLocalizedString("Unable to create the URLRequest object", comment: "")
        }
    }
}


//TEST FOR GIT Practice
//Test2
