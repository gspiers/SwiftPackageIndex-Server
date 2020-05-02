import Fluent
import Vapor
import ShellOut


struct AnalyzerCommand: Command {
    let defaultLimit = 1

    struct Signature: CommandSignature {
        @Option(name: "limit", short: "l")
        var limit: Int?
    }

    var help: String { "Run package analysis (fetching git repository and inspecting content)" }

    func run(using context: CommandContext, signature: Signature) throws {
        let limit = signature.limit ?? defaultLimit
        context.console.info("Analyzing (limit: \(limit)) ...")

        try analyze(application: context.application, limit: limit).wait()
    }
}


func analyze(application: Application, limit: Int) throws -> EventLoopFuture<Void> {
    // get or create directory
    let checkoutDir = application.directory.checkouts
    application.logger.info("Checkout directory: \(checkoutDir)")
    if !Current.fileManager.fileExists(atPath: checkoutDir) {
        application.logger.info("Creating checkout directory at path: \(checkoutDir)")
        try Current.fileManager.createDirectory(atPath: checkoutDir,
                                                  withIntermediateDirectories: false,
                                                  attributes: nil)
    }

    let checkouts = Package.fetchUpdateCandidates(application.db, limit: limit)
        .flatMapEach(on: application.eventLoopGroup.next()) { pkg in
            refreshCheckout(application: application, package: pkg)
    }

    // reconcile versions
    let versions = checkouts
        .flatMapEach(on: application.eventLoopGroup.next()) {
            reconcileVersions(application: application, result: $0)
    }

    // TODO: get manifests (per version)
    // - checkout at version
    // - if Package.swift exists: run dump-package and decode
    // - if Package.swift exists: run tools-version

    // TODO: get products (per version, from manifest)

    // TODO: update version data:
    // - name
    // - swift version
    // - supported platforms

    // TODO: update version.products
    // - set up `products` model
    // - delete and recreate

    return versions.transform(to: ())
}


func refreshCheckout(application: Application, package: Package) -> EventLoopFuture<Result<Package, Error>>  {
    do {
        return try pullOrClone(application: application, package: package)
            .map { .success($0) }
            .flatMapErrorThrowing { .failure($0) }
    } catch {
        return application.eventLoopGroup.next().makeSucceededFuture(.failure(error))
    }
}


func pullOrClone(application: Application, package: Package) throws -> EventLoopFuture<Package> {
    guard let path = application.directory.cacheDirectoryPath(for: package) else {
        throw AppError.invalidPackageUrl(package.id, package.url)
    }
    return application.threadPool.runIfActive(eventLoop: application.eventLoopGroup.next()) {
        if Current.fileManager.fileExists(atPath: path) {
            application.logger.info("pulling \(package.url) in \(path)")
            try Current.shell.run(command: .gitPull(), at: path)
        } else {
            application.logger.info("cloning \(package.url) to \(path)")
            try Current.shell.run(command: .gitClone(url: URL(string: package.url)!, to: path))
        }
        return package
    }
}


/// Wrapper around _reconcileVersions to create a non-throwing version (mainly to ensure
/// that failed futures don't slip through and break the pipeline).
func reconcileVersions(application: Application, result: Result<Package, Error>) -> EventLoopFuture<[Version]> {
    do {
        let pkg = try result.get()
        return try _reconcileVersions(application: application, package: pkg)
    } catch {
        return application.eventLoopGroup.next().makeFailedFuture(error)
    }
}


func _reconcileVersions(application: Application, package: Package) throws -> EventLoopFuture<[Version]> {
    // fetch tags
    guard let path = application.directory.cacheDirectoryPath(for: package) else {
        throw AppError.invalidPackageUrl(package.id, package.url)
    }
    guard let pkgId = package.id else {
        throw AppError.genericError(nil, "PANIC: package id nil for package \(package.url)")
    }
    let tags: EventLoopFuture<[String]> = application.threadPool.runIfActive(eventLoop: application.eventLoopGroup.next()) {
        application.logger.info("listing tags for package \(package.url)")
        let tags = try Current.shell.run(command: .init(string: "git tag"), at: path)
        return tags.split(separator: "\n").map(String.init)
    }

    // TODO: sas 2020-05-02: is is necessary to reconcile versions or is delete and recreate ok?
    // It certainly is simpler.
    // Delete ...
    let delete = Version.query(on: application.db)
        .filter(\.$package.$id == pkgId)
        .delete()
    // ... and insert versions
    let insert: EventLoopFuture<[Version]> = tags
        .flatMapEachThrowing { try Version(package: package, tagName: $0) }
        .flatMap { versions in
            versions.create(on: application.db)
                .map { versions }
        }

    return delete.flatMap { insert }
}
