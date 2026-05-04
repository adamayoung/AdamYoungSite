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
        let tags = sortedTags(in: context)

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .siteShell(
                    for: site,
                    options: ShellOptions(activePath: "/", allTags: tags),
                    content: [
                        .pageHeader(title: "Home"),
                        .heroCard(),
                        .latestBlogSection(items: latestPosts),
                        .projectsSection(),
                        .elsewhereSection(site: site),
                        .stackSection()
                    ]
                )
            )
        )
    }

    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forSection(section, on: site)
        let tags = sortedTags(in: context)

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .siteShell(
                    for: site,
                    options: ShellOptions(
                        activePath: "/blog/",
                        allTags: tags,
                        loadBlogFilter: section.id == .blog
                    ),
                    content: [
                        .pageHeader(title: section.title, subtitle: section.description),
                        .if(section.items.isEmpty,
                            .div(.class("empty-state"), .p(.text("No posts yet — check back soon."))),
                            else: .div(
                                .class("post-list"),
                                .attribute(named: "data-blog-list", value: ""),
                                .forEach(section.items) { item in
                                    .postRow(for: item)
                                },
                                .div(
                                    .class("empty-state hidden"),
                                    .attribute(named: "data-blog-empty", value: ""),
                                    .p(.text("No posts match that search."))
                                )
                            )
                        )
                    ]
                )
            )
        )
    }

    func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forItem(item, on: site)
        let tags = sortedTags(in: context)

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .siteShell(
                    for: site,
                    options: ShellOptions(activePath: "/blog/", allTags: tags),
                    content: [.postArticle(for: item)]
                )
            )
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        let site = context.site
        let info = PageInfo.forPage(page, on: site)
        let tags = sortedTags(in: context)
        let pathString = page.path.absoluteString
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let activePath = pathString.isEmpty ? "/" : "/\(pathString)/"

        let pageContent: [Node<HTML.BodyContext>]
        switch pathString {
        case "projects":
            pageContent = [
                .pageHeader(title: page.title, subtitle: page.description),
                .div(
                    .class("project-list"),
                    .group(allProjects.map { Node.projectFullRow(for: $0) })
                )
            ]
        default:
            pageContent = [
                .pageHeader(title: page.title, subtitle: page.description),
                .div(.class("page-body"), .contentBody(page.body))
            ]
        }

        return HTML(
            .attribute(named: "lang", value: "en-GB"),
            .adamYoungHead(for: info, on: site),
            .body(
                .siteShell(
                    for: site,
                    options: ShellOptions(activePath: activePath, allTags: tags),
                    content: pageContent
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

private func sortedTags(in context: PublishingContext<AdamYoungSite>) -> [Tag] {
    Array(context.allTags).sorted { $0.string.lowercased() < $1.string.lowercased() }
}

// MARK: - Body sections

private extension Node where Context == HTML.BodyContext {

    static func pageHeader(title: String, subtitle: String = "") -> Node {
        .header(
            .class("page-header"),
            .h1(.text(title)),
            .if(!subtitle.isEmpty, .p(.class("page-subtitle"), .text(subtitle)))
        )
    }

    static func heroCard() -> Node {
        .section(
            .class("hero-card"),
            .h2(
                .class("hero-title"),
                .text("Hi, I'm "),
                .span(.class("hero-name"), .text("Adam."))
            ),
            .p(
                .class("hero-tagline"),
                .text("Sixteen years on Apple platforms — Swift, SwiftUI, clean architecture, TDD and CI/CD.")
            ),
            .p(
                .class("hero-sub"),
                .text("Happy deep in a complex codebase or leading technical strategy, and a fan of growing engineering culture through mentoring and tech talks.")
            ),
            .div(
                .class("hero-actions"),
                .a(
                    .class("btn-primary"),
                    .href("/blog/"),
                    .text("Read the blog"),
                    .span(.class("btn-arrow"), .raw(Icons.arrowRight))
                ),
                .a(
                    .class("btn-secondary"),
                    .href("/#projects"),
                    .text("See projects")
                )
            )
        )
    }

    static func sectionHead(title: String, link: (label: String, href: String)? = nil) -> Node {
        .div(
            .class("section-head"),
            .h2(.text(title)),
            .if(link != nil,
                .a(
                    .class("section-link"),
                    .href(link?.href ?? "#"),
                    .text(link?.label ?? ""),
                    .span(.class("section-link-arrow"), .raw(Icons.arrowRight))
                )
            )
        )
    }

    static func latestBlogSection(items: [Item<AdamYoungSite>]) -> Node {
        .section(
            .class("section"),
            .sectionHead(title: "Latest writing", link: (label: "All posts", href: "/blog/")),
            .div(
                .class("post-grid"),
                .forEach(items) { item in
                    .postCard(for: item)
                }
            )
        )
    }

    static func projectsSection() -> Node {
        .section(
            .class("section"),
            .attribute(named: "id", value: "projects"),
            .sectionHead(title: "Projects", link: (label: "All projects", href: "/projects/")),
            .div(
                .class("project-grid"),
                .group(allProjects.map { Node.projectCompactCard(for: $0) })
            )
        )
    }

    static func projectCompactCard(for project: Project) -> Node {
        .a(
            .class("project-card \(project.cssClass)"),
            .href(project.url),
            .attribute(named: "rel", value: "noopener"),
            projectArt(for: project),
            .div(
                .class("project-body"),
                .h3(.text(project.name)),
                .p(.text(project.blurb)),
                .span(.class("project-link"), .text(project.linkLabel))
            )
        )
    }

    static func projectFullRow(for project: Project) -> Node {
        .a(
            .class("project-row \(project.cssClass)"),
            .href(project.url),
            .attribute(named: "rel", value: "noopener"),
            projectArt(for: project),
            .div(
                .class("project-body"),
                .h3(.text(project.name)),
                .p(.text(project.blurb)),
                .if(!project.tech.isEmpty,
                    .div(
                        .class("project-tech"),
                        .forEach(project.tech) { item in
                            .span(.class("chip"), .text(item))
                        }
                    )
                ),
                .span(
                    .class("project-link"),
                    .text(project.linkLabel),
                    .span(.class("section-link-arrow"), .raw(Icons.arrowRight))
                )
            )
        )
    }

    static func elsewhereSection(site: AdamYoungSite) -> Node {
        .section(
            .class("section"),
            .attribute(named: "id", value: "contact"),
            .sectionHead(title: "Get in touch"),
            .div(
                .class("contact-grid"),
                .a(
                    .class("contact-card"),
                    .href("https://github.com/\(site.githubUsername)"),
                    .attribute(named: "rel", value: "noopener"),
                    .span(.class("contact-icon gh"), .raw(Icons.github)),
                    .span(.class("contact-label"), .text("GitHub")),
                    .span(.class("contact-handle"), .text("@\(site.githubUsername)"))
                ),
                .a(
                    .class("contact-card"),
                    .href("https://www.linkedin.com/in/\(site.linkedinUsername)"),
                    .attribute(named: "rel", value: "noopener"),
                    .span(.class("contact-icon li"), .raw(Icons.linkedin)),
                    .span(.class("contact-label"), .text("LinkedIn")),
                    .span(.class("contact-handle"), .text("in/\(site.linkedinUsername)"))
                ),
                .a(
                    .class("contact-card"),
                    .href("mailto:\(site.authorEmail)"),
                    .span(.class("contact-icon mail"), .raw(Icons.mail)),
                    .span(.class("contact-label"), .text("Email")),
                    .span(.class("contact-handle"), .text(site.authorEmail))
                )
            )
        )
    }

    static func stackSection() -> Node {
        let chips = [
            "Swift 6", "SwiftUI", "UIKit", "Swift Concurrency", "Swift Testing",
            "TCA", "SPM", "Tuist", "CoreML", "Vapor"
        ]
        return .section(
            .class("section stack"),
            .sectionHead(title: "Working with"),
            .div(
                .class("chips"),
                .forEach(chips) { chip in
                    .span(.class("chip"), .text(chip))
                }
            )
        )
    }

    static func postCard(for item: Item<AdamYoungSite>) -> Node {
        let href = postHref(for: item)
        let tagString = item.tags.map(\.string).joined(separator: ", ")
        return .a(
            .class("post-card"),
            .href(href),
            .attribute(named: "data-title", value: item.title.lowercased()),
            .attribute(named: "data-description", value: item.description.lowercased()),
            .attribute(named: "data-tags", value: tagString.lowercased()),
            .div(
                .class("post-card-media"),
                .if(item.imagePath != nil,
                    .img(
                        .src(item.imagePath!.absoluteString),
                        .alt(""),
                        .attribute(named: "loading", value: "lazy")
                    ),
                    else: .div(.class("post-card-fallback"), .text("AY"))
                )
            ),
            .div(
                .class("post-card-body"),
                .div(
                    .class("post-card-meta"),
                    .element(named: "time", nodes: [
                        .attribute(named: "datetime", value: DateRendering.iso(item.date)),
                        .text(DateRendering.display(item.date))
                    ]),
                    .if(!item.tags.isEmpty,
                        .span(.class("post-card-meta-tag"), .text("· \(tagString)"))
                    )
                ),
                .h3(.text(item.title)),
                .p(.text(item.description))
            )
        )
    }

    static func postRow(for item: Item<AdamYoungSite>) -> Node {
        let href = postHref(for: item)
        let tagString = item.tags.map(\.string).joined(separator: ", ")
        return .a(
            .class("post-row"),
            .href(href),
            .attribute(named: "data-title", value: item.title.lowercased()),
            .attribute(named: "data-description", value: item.description.lowercased()),
            .attribute(named: "data-tags", value: tagString.lowercased()),
            .div(
                .class("post-row-media"),
                .if(item.imagePath != nil,
                    .img(
                        .src(item.imagePath!.absoluteString),
                        .alt(""),
                        .attribute(named: "loading", value: "lazy")
                    ),
                    else: .div(.class("post-card-fallback"), .text("AY"))
                )
            ),
            .div(
                .class("post-row-body"),
                .div(
                    .class("post-card-meta"),
                    .element(named: "time", nodes: [
                        .attribute(named: "datetime", value: DateRendering.iso(item.date)),
                        .text(DateRendering.display(item.date))
                    ]),
                    .if(!item.tags.isEmpty,
                        .span(.class("post-card-meta-tag"), .text("· \(tagString)"))
                    )
                ),
                .h3(.text(item.title)),
                .p(.text(item.description)),
                .span(.class("post-row-read"), .text("Read"), .span(.class("section-link-arrow"), .raw(Icons.arrowRight)))
            )
        )
    }

    static func postArticle(for item: Item<AdamYoungSite>) -> Node {
        .article(
            .class("post"),
            .a(.class("back-link"), .href("/blog/"), .text("← Back to blog")),
            .header(
                .class("post-header"),
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
}

private func projectArt(for project: Project) -> Node<HTML.AnchorContext> {
    if let imagePath = project.imagePath {
        return .div(
            .class("project-art has-image"),
            .img(
                .src(imagePath),
                .alt(""),
                .attribute(named: "loading", value: "lazy")
            )
        )
    } else {
        return .div(
            .class("project-art"),
            .span(.class("project-icon"), .raw(project.iconSVG))
        )
    }
}

private func postHref(for item: Item<AdamYoungSite>) -> String {
    let raw = item.path.absoluteString
    let prefix = raw.hasPrefix("/") ? "" : "/"
    let suffix = raw.hasSuffix("/") ? "" : "/"
    return "\(prefix)\(raw)\(suffix)"
}

// MARK: - Projects data

struct Project {
    let name: String
    let blurb: String
    let url: String
    let cssClass: String
    let iconSVG: String
    let imagePath: String?
    let tech: [String]

    var linkLabel: String {
        url.replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
    }
}

let allProjects: [Project] = [
    Project(
        name: "TMDb",
        blurb: "Open source Swift Package for The Movie Database API. Used across iOS, macOS, watchOS, tvOS, visionOS and Linux.",
        url: "https://github.com/adamayoung/TMDb",
        cssClass: "tmdb",
        iconSVG: #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.8 20.5 7.5v9L12 21.2 3.5 16.5v-9z"/><path d="M3.5 7.5 12 12.2l8.5-4.7"/><path d="M12 12.2V21.2"/></svg>"#,
        imagePath: "/assets/images/projects/tmdb.png",
        tech: ["Swift", "async/await", "SPM", "iOS", "macOS", "watchOS", "tvOS", "visionOS", "Linux"]
    ),
    Project(
        name: "Popcorn",
        blurb: "Personal iOS, macOS & visionOS app for browsing movies and TV. TCA, SwiftData + CloudKit, Apple Intelligence.",
        url: "https://github.com/adamayoung/popcorn",
        cssClass: "popcorn",
        iconSVG: ##"<svg viewBox="3.5 4.5 17 17" xmlns="http://www.w3.org/2000/svg"><g fill="#FFC404"><circle cx="6.2" cy="11" r="1.6"/><circle cx="8" cy="9" r="2.1"/><circle cx="11" cy="7.4" r="2.2"/><circle cx="13.8" cy="7.6" r="2.1"/><circle cx="16.2" cy="9.2" r="2"/><circle cx="17.6" cy="11" r="1.5"/><circle cx="11.5" cy="10.4" r="2"/><circle cx="14.6" cy="10.6" r="1.9"/></g><path d="M5 12 L9.67 12 L10.33 21 L7 21 Z" fill="#E11D2C" fill-opacity="0.92"/><path d="M9.67 12 L14.33 12 L13.67 21 L10.33 21 Z" fill="#FFFFFF" fill-opacity="0.96"/><path d="M14.33 12 L19 12 L17 21 L13.67 21 Z" fill="#E11D2C" fill-opacity="0.92"/></svg>"##,
        imagePath: "/assets/images/projects/popcorn.png",
        tech: ["Swift", "TCA", "SwiftData", "CloudKit", "Apple Intelligence", "iOS", "macOS", "visionOS"]
    )
]
