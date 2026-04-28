import Foundation
import Publish
import Plot

extension Theme where Site == AdamYoungSite {
    static var adamYoung: Self {
        Theme(htmlFactory: AdamYoungHTMLFactory())
    }
}

private struct AdamYoungHTMLFactory: HTMLFactory {
    typealias Site = AdamYoungSite

    func makeIndexHTML(for index: Index, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forIndex(index, on: site)
        let latestPosts = Array(
            context.allItems(sortedBy: \.date, order: .descending).prefix(2)
        )

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .ambientBlobs(),
                .topNav(),
                .main(
                    .heroSection(),
                    .latestBlogSection(items: latestPosts),
                    .projectsSection(),
                    .elsewhereSection(site: site),
                    .stackSection(),
                    .siteFooter()
                )
            )
        )
    }

    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forSection(section, on: site)

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .ambientBlobs(),
                .topNav(),
                .main(
                    .div(
                        .class("container"),
                        .header(
                            .class("blog-header"),
                            .h1(.text(section.title)),
                            .if(!section.description.isEmpty,
                                .p(.class("sub"), .text(section.description)))
                        ),
                        .if(section.items.isEmpty,
                            .div(.class("empty glass"), .p(.text("No posts yet — check back soon."))),
                            else: .ul(
                                .class("posts-list"),
                                .forEach(section.items) { item in
                                    .li(.postLinkCard(for: item))
                                }
                            )
                        )
                    ),
                    .siteFooter()
                )
            )
        )
    }

    func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forItem(item, on: site)

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .ambientBlobs(),
                .topNav(),
                .main(
                    .postArticle(for: item),
                    .siteFooter()
                )
            )
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forPage(page, on: site)

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .ambientBlobs(),
                .topNav(),
                .main(
                    .div(
                        .class("container"),
                        .header(
                            .class("blog-header"),
                            .h1(.text(page.title)),
                            .if(!page.description.isEmpty,
                                .p(.class("sub"), .text(page.description)))
                        ),
                        .div(.class("post-body"), .contentBody(page.body))
                    ),
                    .siteFooter()
                )
            )
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        nil
    }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        nil
    }
}

// MARK: - Body sections

private extension Node where Context == HTML.BodyContext {

    static func heroSection() -> Node {
        .section(
            .class("hero"),
            .div(.class("avatar"), .text("AY")),
            .div(
                .class("pill glass"),
                .span(.class("dot")),
                .text("iOS Engineer · Oakham, UK")
            ),
            .h1(
                .text("Hi, I'm "),
                .span(.class("grad"), .text("Adam."))
            ),
            .p(
                .class("sub"),
                .text("Sixteen years on Apple platforms — Swift, SwiftUI, clean architecture, TDD and CI/CD. Happy deep in a complex codebase or leading technical strategy, and a fan of growing engineering culture through mentoring and tech talks.")
            )
        )
    }

    static func latestBlogSection(items: [Item<AdamYoungSite>]) -> Node {
        .group([
            .div(
                .class("section-head"),
                .h2(.text("Blog")),
                .a(.class("hint"), .href("/blog/"), .text("View all →"))
            ),
            .section(
                .class("cards"),
                .forEach(items) { item in
                    .postLinkCard(for: item)
                }
            )
        ])
    }

    static func projectsSection() -> Node {
        .group([
            .div(
                .class("section-head"),
                .id("projects"),
                .h2(.text("Projects")),
                .span(.class("hint"), .text("Things I tinker with"))
            ),
            .section(
                .class("cards"),
                .a(
                    .class("card glass tmdb"),
                    .href("https://github.com/adamayoung/TMDb"),
                    .div(
                        .class("body"),
                        .div(
                            .class("icon"),
                            .raw(#"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.8 20.5 7.5v9L12 21.2 3.5 16.5v-9z"/><path d="M3.5 7.5 12 12.2l8.5-4.7"/><path d="M12 12.2V21.2"/></svg>"#)
                        ),
                        .h3(.text("TMDb")),
                        .p(.text("Open source Swift Package for The Movie Database API. Used across iOS, macOS, watchOS, tvOS, visionOS and Linux."))
                    ),
                    .span(.class("arrow"), .text("github.com/adamayoung/TMDb →"))
                ),
                .a(
                    .class("card glass popcorn"),
                    .href("https://github.com/adamayoung/popcorn"),
                    .div(
                        .class("body"),
                        .div(
                            .class("icon"),
                            .raw(##"<svg viewBox="3.5 4.5 17 17" xmlns="http://www.w3.org/2000/svg"><g fill="#FFC404"><circle cx="6.2" cy="11" r="1.6"/><circle cx="8" cy="9" r="2.1"/><circle cx="11" cy="7.4" r="2.2"/><circle cx="13.8" cy="7.6" r="2.1"/><circle cx="16.2" cy="9.2" r="2"/><circle cx="17.6" cy="11" r="1.5"/><circle cx="11.5" cy="10.4" r="2"/><circle cx="14.6" cy="10.6" r="1.9"/></g><path d="M5 12 L9.67 12 L10.33 21 L7 21 Z" fill="#E11D2C" fill-opacity="0.92"/><path d="M9.67 12 L14.33 12 L13.67 21 L10.33 21 Z" fill="#FFFFFF" fill-opacity="0.96"/><path d="M14.33 12 L19 12 L17 21 L13.67 21 Z" fill="#E11D2C" fill-opacity="0.92"/></svg>"##)
                        ),
                        .h3(.text("Popcorn")),
                        .p(.text("Personal iOS, macOS & visionOS app for browsing movies and TV. TCA, SwiftData + CloudKit, Apple Intelligence."))
                    ),
                    .span(.class("arrow"), .text("github.com/adamayoung/popcorn →"))
                )
            )
        ])
    }

    static func elsewhereSection(site: AdamYoungSite) -> Node {
        .group([
            .div(
                .class("section-head"),
                .id("contact"),
                .h2(.text("Elsewhere")),
                .span(.class("hint"), .text("Say hello"))
            ),
            .section(
                .class("cards"),
                .a(
                    .class("card glass gh"),
                    .href("https://github.com/\(site.githubUsername)"),
                    .div(
                        .class("body"),
                        .div(
                            .class("icon"),
                            .raw(#"<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 .5C5.7.5.5 5.7.5 12c0 5.1 3.3 9.4 7.8 10.9.6.1.8-.2.8-.6v-2c-3.2.7-3.9-1.4-3.9-1.4-.5-1.3-1.3-1.7-1.3-1.7-1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1 1.8 2.8 1.3 3.5 1 .1-.8.4-1.3.8-1.6-2.6-.3-5.3-1.3-5.3-5.7 0-1.3.5-2.3 1.2-3.1-.1-.3-.5-1.5.1-3.2 0 0 1-.3 3.3 1.2.9-.3 2-.4 3-.4s2 .1 3 .4c2.3-1.5 3.3-1.2 3.3-1.2.7 1.6.2 2.9.1 3.2.8.8 1.2 1.9 1.2 3.1 0 4.4-2.7 5.4-5.3 5.7.4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.6 4.5-1.5 7.8-5.8 7.8-10.9C23.5 5.7 18.3.5 12 .5z"/></svg>"#)
                        ),
                        .h3(.text("GitHub")),
                        .p(.text("Open source & experiments"))
                    ),
                    .span(.class("arrow"), .text("@\(site.githubUsername) →"))
                ),
                .a(
                    .class("card glass li"),
                    .href("https://www.linkedin.com/in/\(site.linkedinUsername)"),
                    .div(
                        .class("body"),
                        .div(
                            .class("icon"),
                            .raw(#"<svg viewBox="0 0 24 24" fill="currentColor"><path d="M20.4 20.4h-3.5v-5.5c0-1.3 0-3-1.8-3s-2.1 1.4-2.1 2.9v5.6H9.5V9h3.4v1.6h.1c.5-.9 1.6-1.8 3.4-1.8 3.6 0 4.3 2.4 4.3 5.5v6.1zM5.5 7.4c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm1.8 13H3.7V9h3.6v11.4zM22.2 0H1.8C.8 0 0 .8 0 1.7v20.5C0 23.2.8 24 1.8 24h20.4c1 0 1.8-.8 1.8-1.8V1.7C24 .8 23.2 0 22.2 0z"/></svg>"#)
                        ),
                        .h3(.text("LinkedIn")),
                        .p(.text("Professional history"))
                    ),
                    .span(.class("arrow"), .text("in/\(site.linkedinUsername) →"))
                ),
                .a(
                    .class("card glass mail"),
                    .href("mailto:\(site.authorEmail)"),
                    .div(
                        .class("body"),
                        .div(
                            .class("icon"),
                            .raw(#"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>"#)
                        ),
                        .h3(.text("Email")),
                        .p(.text("For work or hello"))
                    ),
                    .span(.class("arrow"), .text("\(site.authorEmail) →"))
                )
            )
        ])
    }

    static func stackSection() -> Node {
        let chips = [
            "Swift 6", "SwiftUI", "UIKit", "Swift Concurrency", "Swift Testing",
            "TCA", "SPM", "Tuist", "CoreML", "Vapor"
        ]
        return .section(
            .class("stack"),
            .div(.class("label"), .text("Working with")),
            .div(
                .class("chips"),
                .forEach(chips) { chip in
                    .span(.class("chip"), .text(chip))
                }
            )
        )
    }

    static func postArticle(for item: Item<AdamYoungSite>) -> Node {
        .article(
            .class("post container"),
            .header(
                .class("post-header"),
                .a(.class("back"), .href("/blog/"), .text("← Back to blog")),
                .h1(.class("post-title"), .text(item.title)),
                postMetaParagraph(for: item)
            ),
            .div(
                .class("post-body"),
                .contentBody(item.body)
            )
        )
    }

    static func postMetaParagraph(for item: Item<AdamYoungSite>) -> Node {
        var children: [Node<HTML.BodyContext>] = [
            .element(named: "time", nodes: [
                .attribute(named: "datetime", value: DateRendering.iso(item.date)),
                .text(DateRendering.display(item.date))
            ])
        ]

        if !item.tags.isEmpty {
            children.append(.text(" · "))
            for (index, tag) in item.tags.enumerated() {
                children.append(.span(.class("tag"), .text(tag.string)))
                if index < item.tags.count - 1 {
                    children.append(.text(" "))
                }
            }
        }

        return .p(.class("post-meta"), .group(children))
    }

    static func postLinkCard(for item: Item<AdamYoungSite>) -> Node {
        let href = postHref(for: item)
        return .a(
            .class("post-link glass"),
            .href(href),
            .div(
                .class("body"),
                .div(
                    .class("meta"),
                    .element(named: "time", nodes: [
                        .attribute(named: "datetime", value: DateRendering.iso(item.date)),
                        .text(DateRendering.display(item.date))
                    ]),
                    .if(!item.tags.isEmpty,
                        .text(" · " + item.tags.map(\.string).joined(separator: ", "))
                    )
                ),
                .h3(.text(item.title)),
                .p(.text(item.description)),
                .span(.class("read"), .text("Read →"))
            )
        )
    }
}

private func postHref(for item: Item<AdamYoungSite>) -> String {
    let raw = item.path.absoluteString
    let prefix = raw.hasPrefix("/") ? "" : "/"
    let suffix = raw.hasSuffix("/") ? "" : "/"
    return "\(prefix)\(raw)\(suffix)"
}
