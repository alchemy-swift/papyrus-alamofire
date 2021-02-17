import Alamofire
import Papyrus
import Foundation

extension Endpoint {
    /// Request an endpoint.
    ///
    /// - Parameters:
    ///   - request: The request data of this endpoint.
    ///   - session: The `Alamofire.Session` with which to request
    ///     this. Defaults to `Session.default`.
    ///   - completion: A completion that will be called when the
    ///     request is complete. Contains the raw `AFDataResponse<Data>`
    ///     as well as a `Result` containing either the parsed
    ///   `Response` or an `Error`.
    /// - Throws: any errors encountered while encoding the request
    ///   parameters.
    public func request(
        _ request: Request,
        session: Session = .default,
        completion: @escaping (AFDataResponse<Data?>?, Result<Response, Error>) -> Void
    ) {
        do {
            let requestParameters = try self.parameters(dto: request)
            session
                .request(
                    self.baseURL + requestParameters.fullPath,
                    method: requestParameters.method.af,
                    parameters: requestParameters.body,
                    encoder: requestParameters.bodyEncoding == .json ?
                        JSONParameterEncoder(encoder: self.jsonEncoder) :
                        URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(keyEncoding: self.keyMapping.urlEncoding)),
                    headers: HTTPHeaders(requestParameters.headers)
                )
                .handleResponse(endpoint: self, completion: completion)
        } catch {
            completion(nil, .failure(error))
        }
    }
}

extension Endpoint where Request == Papyrus.Empty {
    /// Request an endpoint where `Request` is `Empty`.
    ///
    /// - Parameter session: the `Alamofire.Session` with which to
    ///   request this. Defaults to `Session.default`.
    /// - Parameter completion: the completion handler.
    public func request(
        session: Session = .default,
        completion: @escaping (AFDataResponse<Data?>?, Result<Response, Error>) -> Void
    ) {
        session.request(self.baseURL + self.path, method: self.method.af)
            .handleResponse(endpoint: self, completion: completion)
    }
}

extension DataRequest {
    func handleResponse<Request: EndpointRequest,Response: Codable>(
        endpoint: Endpoint<Request, Response>,
        completion: @escaping (AFDataResponse<Data?>, Result<Response, Error>) -> Void
    ) {
        self
            .validate(statusCode: 200..<300)
            .response { afResponse in
                switch afResponse.result {
                case .success(let data):
                    if Response.self == Papyrus.Empty.self {
                        return completion(afResponse, .success(Papyrus.Empty.value as! Response))
                    }
                    do {
                        guard let data = data else {
                            throw PapyrusError("Error parsing `\(Response.self)`; body was empty.")
                        }
                        let dto = try endpoint.jsonDecoder.decode(Response.self, from: data)
                        completion(afResponse, .success(dto))
                    } catch {
                        completion(afResponse, .failure(error))
                    }
                case .failure(let error):
                    completion(afResponse, .failure(error))
                }
            }
    }
}

private extension EndpointMethod {
    /// The Alamofire equivalent of this `EndpointMethod`.
    var af: HTTPMethod {
        HTTPMethod(rawValue: self.rawValue.uppercased())
    }
}

private extension KeyMapping {
    var urlEncoding: URLEncodedFormEncoder.KeyEncoding {
        switch self {
        case .snakeCase:
            return .convertToSnakeCase
        case .useDefaultKeys:
            return .useDefaultKeys
        case .custom(let closure):
            return .custom(closure)
        }
    }
}
