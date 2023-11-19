import Foundation
import SwiftOpenAPIMacros

public protocol OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? { get }
}

public extension OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? {
        nil
    }
}

/// `OpenAPIAutoDescriptable`: An automatic implementation macro for the `OpenAPIDescriptable` protocol.
///
/// This macro facilitates the automatic implementation of the `OpenAPIDescriptable` protocol
/// for any Swift type, utilizing both standard comments (`//`) and documentation comments (`///`)
/// for the type and its stored properties. It's particularly useful for generating comprehensive
/// OpenAPI documentation directly from your source code.
///
/// - Parameters:
///   - codingKeys: The Bool value indicating whether to use a `CodingKeys` enum for properties names.
///   - docCommentsOnly: The Bool value indicating whether to use only documentation comments (`///` and `/**`).
///
/// Features:
/// - Automatically extracts and synthesizes descriptions from comments on types and stored properties.
/// - Simplifies the process of conforming to `OpenAPIDescriptable` by generating necessary implementation details.
///
/// - Warning: This macro does not process properties with attributes, as it's currently not feasible
///   to distinguish between stored and computed properties in such cases.
///
/// Example:
/// ```swift
/// /// Description of MyType.
/// @OpenAPIAutoDescriptable
/// struct MyType: Codable {
///
///     /// Description of myProperty.
///     var myProperty: String
/// }
/// ```
///
/// The `OpenAPIAutoDescriptable` significantly reduces the need for boilerplate code in
/// API documentation, streamlining the process of maintaining up-to-date and accurate OpenAPI docs.
@attached(member, conformances: OpenAPIDescriptable, names: arbitrary)
@attached(extension, conformances: OpenAPIDescriptable, names: arbitrary)
public macro OpenAPIAutoDescriptable(
    codingKeys: Bool = true,
    docCommentsOnly: Bool = false
) = #externalMacro(
    module: "SwiftOpenAPIMacros",
    type: "OpenAPIDescriptionMacro"
)
