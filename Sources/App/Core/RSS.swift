import Fluent
import Foundation
import Plot


struct RSSFeed {
    struct Item {
        var title: String
        var link: String
        var packageName: String
        var packageSummary: String

        var node: Node<RSS.ChannelContext> {
            .item(
                .guid(.text(link), .isPermaLink(true)),
                .title(title),
                .link(link),
                .content(
                    .h2(.a(.href(link), .text(packageName))),
                    .p(.text(packageSummary)),
                    // FIXME: should be `small` but I need to figure out how to do that
                    .p(.a(.href(link), .text(packageName)))
                )
            )
        }
    }

    var title: String
    var description: String
    var link: URL
    var items: [Item]

    var rss: RSS {
        RSS(
            .title(title),
            .description(description),
            .link(link),
            //  .language(language),
            //  .lastBuildDate(date, timeZone: context.dateFormatter.timeZone),
            //  .pubDate(date, timeZone: context.dateFormatter.timeZone),
            //  .ttl(Int(config.ttlInterval)),
            //  .atomLink(context.site.url(for: config.targetPath)),
            .forEach(items, \.node)
        )
    }
}


extension RSSFeed {
    static func recentPackages(on database: Database, maxItemCount: Int = 100) -> EventLoopFuture<Self> {
        RecentPackage.fetch(on: database, limit: maxItemCount)
            .mapEach(RSSFeed.Item.init)
            .map {
                RSSFeed(title: "Swift Package Index – Recently Added",
                        description: "List of recently added Swift packages",
                        link: URL(string: "feed")!,  // FIXME
                    items: $0)
        }
    }
}


extension RSSFeed.Item {
    init(_ recentPackage: RecentPackage) {
        title = recentPackage.packageName
        link = SiteURL.package(.value(recentPackage.repositoryOwner),
                               .value(recentPackage.repositoryName)).absoluteURL()
        packageName = recentPackage.packageName
        packageSummary = recentPackage.packageSummary ?? ""
    }
}
