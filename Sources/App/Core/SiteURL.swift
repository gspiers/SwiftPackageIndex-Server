import Plot
import Vapor


// MARK: - Resource declaration


// The following are all the routes we support and reference from various places, some of them
// static routes (images), others dynamic ones for use in controller definitions.
//
// Introduce nesting by declaring a new type conforming to Resourceable and embed it in the
// parent resource.
//
// Enums based on String are automatically Resourceable via RawRepresentable.


enum Api: String, Resourceable {
    case version
    case search
}


enum SiteURL: Resourceable {

    case admin
    case api(Api)
    case faq
    case home
    case images(String)
    case packages
    case package(_ owner: Parameter<String>, _ repository: Parameter<String>)
    case privacy

    var path: String {
        switch self {
            case .admin:
                return "admin"

            case .api:
                return "api"

            case .faq:
                return "faq"

            case .home:
                return ""

            case let .images(name):
                return "images/\(name)"

            case let .package(.value(owner), .value(repo)):
                let owner = owner.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? owner
                let repo = repo.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? repo
                return "\(owner)/\(repo)"

            case .package:
                fatalError("invalid path: \(self)")

            case .packages:
                return "packages"

            case .privacy:
                return "privacy"
        }
    }

    var pathComponents: [PathComponent] {
        switch self {
            case .admin, .faq, .home, .packages, .privacy:
                return [.init(stringLiteral: path)]

            case let .api(res):
                return ["api"] + res.pathComponents

            case let .package(.name(owner), .name(repository)):
                return [":\(owner)", ":\(repository)"].map(PathComponent.init(stringLiteral:))

            case .package:
                fatalError("pathComponents must not be called with a value parameter")

            case .images:
                fatalError("invalid resource path for routing - only use in static HTML (DSL)")
        }
    }

}


// MARK: - Types for use in resource declaration


protocol Resourceable {
    func absoluteURL(anchor: String?) -> String
    func relativeURL(anchor: String?) -> String
    var path: String { get }
    var pathComponents: [PathComponent] { get }
}


extension Resourceable {
    func absoluteURL(anchor: String? = nil) -> String {
        "\(Current.siteURL())/\(path)" + (anchor.map { "#\($0)" } ?? "")
    }

    func relativeURL(anchor: String? = nil) -> String {
        "/" + path + (anchor.map { "#\($0)" } ?? "")
    }
}


extension Resourceable where Self: RawRepresentable, RawValue == String {
    var path: String { rawValue }
    var pathComponents: [PathComponent] { [.init(stringLiteral: path)] }
}


enum Parameter<T> {
    case name(String)
    case value(T)
}
