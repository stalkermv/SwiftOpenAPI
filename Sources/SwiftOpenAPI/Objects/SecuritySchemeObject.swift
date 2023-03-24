import Foundation

/// Defines a security scheme that can be used by the operations.
///
/// Supported schemas are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), mutual TLS (use of a client certificate), OAuth2's common flows (implicit, password, client credentials and authorization code) as defined in RFC6749, and OpenID Connect Discovery. Please note that as of 2020, the implicit flow is about to be deprecated by OAuth 2.0 Security Best Current Practice. Recommended for most use case is Authorization Code Grant flow with PKCE.
public struct SecuritySchemeObject: Codable, Equatable, SpecificationExtendable {
    
    /// The type of the security scheme.
    public var type: SecuritySchemeObjectType
    
    /// A description for security scheme. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    /// The name of the header, query or cookie parameter to be used.
    public var name: String?
    
    ///  The location of the API key
    public var `in`: Location?
    
    /// The name of the HTTP Authorization scheme to be used in the Authorization header as defined in RFC7235. The values used SHOULD be registered in the IANA Authentication Scheme registry.
    public var scheme: HTTPAuthScheme?
    
    /// A hint to the client to identify how the bearer token is formatted. Bearer tokens are usually generated by an authorization server, so this information is primarily for documentation purposes.
    public var bearerFormat: String?
    
    /// An object containing configuration information for the flow types supported.
    public var flows: OAuthFlowsObject?
    
    /// OpenId Connect URL to discover OAuth2 configuration values. The OpenID Connect standard requires the use of TLS.
    public var openIdConnectUrl: String?
    
    /// It's don't recommended to use init directly, use static methods
    public init(
        type: SecuritySchemeObjectType,
        description: String? = nil,
        name: String? = nil,
        in location: SecuritySchemeObject.Location? = nil,
        scheme: HTTPAuthScheme? = nil,
        bearerFormat: String? = nil,
        flows: OAuthFlowsObject? = nil,
        openIdConnectUrl: String? = nil
    ) {
        self.type = type
        self.description = description
        self.name = name
        self.`in` = location
        self.scheme = scheme
        self.bearerFormat = bearerFormat
        self.flows = flows
        self.openIdConnectUrl = openIdConnectUrl
    }
    
    public func described(_ description: String) -> SecuritySchemeObject {
        var result = self
        result.description = description
        return result
    }
}

extension SecuritySchemeObject {
    
    public enum Location: String, Codable {
        
        case query, header, cookie
    }
}

public enum SecuritySchemeObjectType: String, Codable {
    
    case apiKey, http, mutualTLS, oauth2, openIdConnect
}

public struct HTTPAuthScheme: LosslessStringConvertible, ExpressibleByStringLiteral, RawRepresentable, Hashable, Codable {
    
    public var rawValue: String
    public var description: String { rawValue }
    
    public init(_ string: String) {
        self.rawValue = string.lowercased()
    }
    
    public init(rawValue: String) {
        self.init(rawValue)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
    
    public static let basic: HTTPAuthScheme = "basic"
    public static let bearer: HTTPAuthScheme = "bearer"
    public static let digest: HTTPAuthScheme = "digest"
    
    /// The HOBA scheme can be used with either HTTP servers or proxies. When used in response to a 407 Proxy Authentication Required indication, the appropriate proxy authentication header fields are used instead, as with any other HTTP authentication scheme.
    public static let hoba: HTTPAuthScheme = "hoba"
    public static let mutual: HTTPAuthScheme = "mutual"
    public static let oauth: HTTPAuthScheme = "oauth"
    public static let scramSHA1: HTTPAuthScheme = "scram-sha-1"
    public static let scramSHA256: HTTPAuthScheme = "scram-sha-256"
    public static let vapid: HTTPAuthScheme = "vapid"
}

public extension SecuritySchemeObject {
    
    /// Basic authentication is a simple authentication scheme built into the HTTP protocol. The client sends HTTP requests with the Authorization header that contains the word Basic word followed by a space and a base64-encoded string username:password. For example, to authorize as demo / p@55w0rd the client would send
    static var basic: SecuritySchemeObject {
        SecuritySchemeObject(
            type: .http,
            description: "[Basic authentication](https://en.wikipedia.org/wiki/Basic_access_authentication) is a simple authentication scheme built into the HTTP protocol. The client sends HTTP requests with the Authorization header that contains the word Basic word followed by a space and a base64-encoded string username:password. For example, to authorize as demo / p@55w0rd the client would send",
            scheme: .basic
        )
    }
    
    /// An API key is a token that a client provides when making API calls
    static func apiKey(
        name: String = "X-API-Key",
        in location: Location = .header
    ) -> SecuritySchemeObject {
        SecuritySchemeObject(
            type: .apiKey,
            description: "An API key is a token that a client provides when making API calls",
            name: name,
            in: location
        )
    }
    
    /// Bearer authentication (also called token authentication) is an HTTP authentication scheme that involves security tokens called bearer tokens. The name “Bearer authentication” can be understood as “give access to the bearer of this token.” The bearer token is a cryptic string, usually generated by the server in response to a login request. The client must send this token in the Authorization header when making requests to protected resources
    static func bearer(format: String? = nil) -> SecuritySchemeObject {
        SecuritySchemeObject(
            type: .http,
            description: "Bearer authentication (also called token authentication) is an HTTP authentication scheme that involves security tokens called bearer tokens. The name “Bearer authentication” can be understood as “give access to the bearer of this token.” The bearer token is a cryptic string, usually generated by the server in response to a login request. The client must send this token in the Authorization header when making requests to protected resources",
            scheme: .bearer,
            bearerFormat: format
        )
    }
    
    /// OAuth 2.0 is an authorization protocol that gives an API client limited access to user data on a web server. GitHub, Google, and Facebook APIs notably use it. OAuth relies on authentication scenarios called flows, which allow the resource owner (user) to share the protected content from the resource server without sharing their credentials. For that purpose, an OAuth 2.0 server issues access tokens that the client applications can use to access protected resources on behalf of the resource owner. For more information about OAuth 2.0, see oauth.net and RFC 6749.
    static func oauth2(
        _ type: OAuth2,
        refreshUrl: String? = nil,
        scopes: [String: String] = [:]
    ) -> SecuritySchemeObject {
        SecuritySchemeObject(
            type: .oauth2,
            description: "OAuth 2.0 is an authorization protocol that gives an API client limited access to user data on a web server. GitHub, Google, and Facebook APIs notably use it. OAuth relies on authentication scenarios called flows, which allow the resource owner (user) to share the protected content from the resource server without sharing their credentials. For that purpose, an OAuth 2.0 server issues access tokens that the client applications can use to access protected resources on behalf of the resource owner. For more information about OAuth 2.0, see oauth.net and RFC 6749.",
            flows: type.flow(refreshUrl: refreshUrl, scopes: scopes)
        )
    }
    
    enum OAuth2: Equatable {
        
        case implicit(authorizationUrl: String)
        case password(tokenUrl: String)
        case clientCredentials(tokenUrl: String)
        case authorizationCode(authorizationUrl: String, tokenUrl: String)
        
        public func flow(
            refreshUrl: String? = nil,
            scopes: [String: String] = [:]
        ) -> OAuthFlowsObject {
            switch self {
            case let .implicit(authorizationUrl):
                return OAuthFlowsObject(
                    implicit: OAuthFlowObject(authorizationUrl: authorizationUrl, refreshUrl: refreshUrl, scopes: scopes)
                )
            case let .password(tokenUrl):
                return OAuthFlowsObject(
                    password: OAuthFlowObject(tokenUrl: tokenUrl, refreshUrl: refreshUrl, scopes: scopes)
                )
            case let .clientCredentials(authorizationUrl):
                return OAuthFlowsObject(
                    clientCredentials: OAuthFlowObject(authorizationUrl: authorizationUrl, refreshUrl: refreshUrl, scopes: scopes)
                )
            case let .authorizationCode(authorizationUrl, tokenURL):
                return OAuthFlowsObject(
                    authorizationCode: OAuthFlowObject(authorizationUrl: authorizationUrl, tokenUrl: tokenURL, refreshUrl: refreshUrl, scopes: scopes)
                )
            }
        }
    }
    
    /// OpenID Connect (OIDC) is an identity layer built on top of the OAuth 2.0 protocol and supported by some OAuth 2.0 providers, such as Google and Azure Active Directory. It defines a sign-in flow that enables a client application to authenticate a user, and to obtain information (or "claims") about that user, such as the user name, email, and so on. User identity information is encoded in a secure JSON Web Token (JWT), called ID token.
    static func openIDConnect(url: String) -> SecuritySchemeObject {
        SecuritySchemeObject(
            type: .openIdConnect,
            description: "OpenID Connect (OIDC) is an identity layer built on top of the OAuth 2.0 protocol and supported by some OAuth 2.0 providers, such as Google and Azure Active Directory. It defines a sign-in flow that enables a client application to authenticate a user, and to obtain information (or claims) about that user, such as the user name, email, and so on. User identity information is encoded in a secure JSON Web Token (JWT), called ID token.",
            openIdConnectUrl: url
        )
    }
}
