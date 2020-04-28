import Vapor


#if DEBUG

extension AppEnvironment {
    static let mock: Self = .init(
        fetchMasterPackageList: { _ in
            .just(value: ["https://github.com/finestructure/Gala",
                          "https://github.com/finestructure/SwiftPMLibrary-Server"].urls)
        },
        fetchMetadata: { _, _ in .just(value: .mock) },
        githubToken: { ProcessInfo.processInfo.environment["GITHUB_TOKEN"] }
    )

    static let e2eTestingShort: Self = .init(
        fetchMasterPackageList: { _ in .just(value: testUrls) },
        fetchMetadata: { _, pkg in .just(value: .mock(for: pkg)) },
        githubToken: { nil }
    )

    static let e2eTestingFull: Self = .init(
        fetchMasterPackageList: liveFetchMasterPackageList,
        fetchMetadata: { _, pkg in .just(value: .mock(for: pkg)) },
        githubToken: { nil }
    )
}


let testUrls100 = [
    "https://github.com/mw99/OhhAuth.git",
    "https://github.com/quanvo87/GroupWork.git",
    "https://github.com/detroit-labs/BottomSheetPresentation.git",
    "https://github.com/perfectlysoft/perfect-thread.git",
    "https://github.com/roible/rlayoutkit.git",
    "https://github.com/BiAtoms/Socket.swift.git",
    "https://github.com/jianstm/Once.git",
    "https://github.com/johnsusek/fluxus.git",
    "https://github.com/cpageler93/swiftyhawk.git",
    "https://github.com/perfectlysoft/perfect-xml.git",
    "https://github.com/eman6576/SGCircuitBreaker.git",
    "https://github.com/rockfordwei/perfect-pcre2.git",
    "https://github.com/bjtj/swift-upnp-tools.git",
    "https://github.com/givip/telegrammer.git",
    "https://github.com/sobotics/swiftredunda.git",
    "https://github.com/wolfmcnally/WolfOSBridge.git",
    "https://github.com/norio-nomura/ObjectEncoder.git",
    "https://github.com/ArtSabintsev/Siren.git",
    "https://github.com/crelies/uikit-modifiers.git",
    "https://github.com/k-o-d-e-n/CGLayout.git",
    "https://github.com/MKGitHub/MessageBox-Concept.git",
    "https://github.com/zweigraf/fakebundle.git",
    "https://github.com/CypherPoet/CypherPoetNetStack.git",
    "https://github.com/thii/HTTPMethod.git",
    "https://github.com/Zewo/Venice.git",
    "https://github.com/Kuniwak/MultipartFormDataKit.git",
    "https://github.com/maddthesane/swiftmactypes.git",
    "https://github.com/twostraws/swiftgd.git",
    "https://github.com/bizz84/SwiftyStoreKit.git",
    "https://github.com/Boilertalk/Keystore.swift.git",
    "https://github.com/einstore/einstorecore.git",
    "https://github.com/istvan-kreisz/CombineReachability.git",
    "https://github.com/vapor-community/lingo-vapor.git",
    "https://github.com/koher/resultk.git",
    "https://github.com/CharlesJS/CSAuthSample.git",
    "https://github.com/kelvin13/swiftxml.git",
    "https://github.com/gotranseo/vapor-recaptcha.git",
    "https://github.com/carekit-apple/carekit.git",
    "https://github.com/q231950/commands.git",
    "https://github.com/querykit/querykit-cli.git",
    "https://github.com/rwbutler/typographykitpalette.git",
    "https://github.com/seanparsons/swifttrycatch.git",
    "https://github.com/devxoul/Then.git",
    "https://github.com/amadeu01/atlas.git",
    "https://github.com/JohnSundell/files.git",
    "https://github.com/JanGorman/Agrume.git",
    "https://github.com/vinhnx/vintage.git",
    "https://github.com/hjuraev/vapornotifications.git",
    "https://github.com/mavisbroadcast/amf.git",
    "https://github.com/shareup/sqlite.git",
    "https://github.com/kishikawakatsumi/swiftpowerassert.git",
    "https://github.com/hootsuite/emit.git",
    "https://github.com/aphelionapps/swaggerparser.git",
    "https://github.com/poulpix/PXGoogleDirections.git",
    "https://github.com/kittymo/MoRegex.git",
    "https://github.com/e-sites/Natrium.git",
    "https://github.com/davecom/SwiftPriorityQueue.git",
    "https://github.com/koher/swift-image.git",
    "https://github.com/LuizZak/JelloSwift.git",
    "https://github.com/ggruen/swiftnetrc.git",
    "https://github.com/cats-oss/cujira.git",
    "https://github.com/dougzilla32/CancelForPromiseKit.git",
    "https://github.com/MiniDOM/MiniDOM.git",
    "https://github.com/nixzhu/baby.git",
    "https://github.com/readdle/swift-java.git",
    "https://github.com/bermudadigitalstudio/cerberus.git",
    "https://github.com/IBAnimatable/IBAnimatable.git",
    "https://github.com/sendyhalim/swort.git",
    "https://github.com/apple/swift-log.git",
    "https://github.com/kishikawakatsumi/swiftsyntax.git",
    "https://github.com/Alamofire/Alamofire.git",
    "https://github.com/krugazor/credentialstoken.git",
    "https://github.com/perfectlysoft/perfect-session-postgresql.git",
    "https://github.com/Zewo/zewo.git",
    "https://github.com/cpageler93/quack.git",
    "https://github.com/JohnSundell/identity.git",
    "https://github.com/graycampbell/GCCountryPicker.git",
    "https://github.com/OakCityLabs/RealmCoder.git",
    "https://github.com/devxoul/URLNavigator.git",
    "https://github.com/nodes-ios/Serpent.git",
    "https://github.com/rwbutler/ipauploader.git",
    "https://github.com/elegantchaos/TokenView.git",
    "https://github.com/fcanas/hlscore.git",
    "https://github.com/raywenderlich/spm-tutorial.git",
    "https://github.com/optionalvalue/koba.git",
    "https://github.com/RxSwiftCommunity/RxSwiftExt.git",
    "https://github.com/SwiftORM/SQLite-StORM.git",
    "https://github.com/t-ae/simpledownloader.git",
    "https://github.com/vapor-community/postman-provider.git",
    "https://github.com/kirilltitov/fdbswift.git",
    "https://github.com/llvm-swift/symbolic.git",
    "https://github.com/jhoogstraat/standardrouting.git",
    "https://github.com/mono0926/vapor-cloud-storage.git",
    "https://github.com/hirotakan/MessagePacker.git",
    "https://github.com/perfectlysoft/perfect.git",
    "https://github.com/SomeRandomiOSDev/Half.git",
    "https://github.com/corekit/vipera.git",
    "https://github.com/haekelmeister/MacAddress.git",
    "https://github.com/SDWebImage/SDWebImagePDFCoder.git",
    "https://github.com/hallee/dotfiles.git",
    ].urls


let testUrls = Array(testUrls100[..<20])


extension Array where Element == String {
    var urls: [URL] { compactMap(URL.init(string:)) }
}


extension Github.Metadata {
    static let mock: Self = .init(
        defaultBranch: "master",
        description: "desc",
        forksCount: 1,
        license: .init(key: "mit"),
        stargazersCount: 2,
        parent: nil
    )

    static func mock(for package: Package) -> Self {
        // populate with some mock data derived from the package
        .init(defaultBranch: "master",
              description: "This is package " + package.url.dropFirst("https://github.com/".count),
              forksCount: package.url.count,
              license: .init(key: "mit"),
              stargazersCount: package.url.count + 1,
              parent: nil)
    }
}

#endif
