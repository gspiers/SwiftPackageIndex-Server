@testable import App

import SnapshotTesting
import XCTVapor


class RSSTests: AppTestCase {

    func test_render_item() throws {
        let item = RSSFeed.Item(title: "title",
                                link: "link",
                                packageName: "bar",
                                packageSummary: "This is package bar")
        assertSnapshot(matching: item.node.render(indentedBy: .spaces(2)),
                       as: .init(pathExtension: "xml", diffing: .lines))
    }

    func test_render_feed() throws {
        // Test generated feed. The result should validate successfully
        // on https://validator.w3.org/feed/check.cgi
        let feed = RSSFeed(title: "feed title", description: "feed description",
                           link: "https://SwiftPackageIndex.com",
                           maxItemCount: 100,
                           items: [
                            RSSFeed.Item(title: "title",
                                         link: "https://SwiftPackageIndex.com/foo/bar",
                                         packageName: "bar",
                                         packageSummary: "This is package bar"),
                            RSSFeed.Item(title: "title",
                                         link: "https://SwiftPackageIndex.com/bar/baz",
                                         packageName: "baz",
                                         packageSummary: "This is package baz")]
        )
        assertSnapshot(matching: feed.rss.render(indentedBy: .spaces(2)),
                       as: .init(pathExtension: "xml", diffing: .lines))
    }

    func test_feed_RecentPackages() throws {
        // setup
        try (1...10).forEach {
            let pkg = Package(id: UUID(), url: "\($0)".asGithubUrl.url)
            try pkg.save(on: app.db).wait()
            try Repository(package: pkg, name: "pkg-\($0)", owner: "owner-\($0)").create(on: app.db).wait()
            try Version(package: pkg, packageName: "pkg-\($0)").save(on: app.db).wait()
        }
        // make sure to refresh the materialized view
        try RecentPackage.refresh(on: app.db).wait()


    }

}
