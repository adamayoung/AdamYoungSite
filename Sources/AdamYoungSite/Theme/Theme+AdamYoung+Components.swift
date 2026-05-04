import Foundation
import Publish
import Plot

enum PageKind {
    case home
    case article
    case other
}

struct PageInfo {
    var title: String
    var fullTitle: String
    var description: String
    var path: Path
    var kind: PageKind
    var imagePath: Path?
    var imageAlt: String?
}

extension PageInfo {
    static func forIndex(_ index: Index, on site: AdamYoungSite) -> PageInfo {
        PageInfo(
            title: site.name,
            fullTitle: "\(site.name) · \(site.tagline)",
            description: index.description.isEmpty ? site.description : index.description,
            path: index.path,
            kind: .home,
            imagePath: index.imagePath ?? site.imagePath,
            imageAlt: site.name
        )
    }

    static func forSection(_ section: Section<AdamYoungSite>, on site: AdamYoungSite) -> PageInfo {
        PageInfo(
            title: section.title,
            fullTitle: "\(section.title) · \(site.name)",
            description: section.description.isEmpty ? site.description : section.description,
            path: section.path,
            kind: .other,
            imagePath: section.imagePath ?? site.imagePath,
            imageAlt: section.title
        )
    }

    static func forItem(_ item: Item<AdamYoungSite>, on site: AdamYoungSite) -> PageInfo {
        PageInfo(
            title: item.title,
            fullTitle: "\(item.title) · \(site.name)",
            description: item.description.isEmpty ? site.description : item.description,
            path: item.path,
            kind: .article,
            imagePath: item.imagePath ?? site.imagePath,
            imageAlt: item.title
        )
    }

    static func forPage(_ page: Page, on site: AdamYoungSite) -> PageInfo {
        PageInfo(
            title: page.title,
            fullTitle: "\(page.title) · \(site.name)",
            description: page.description.isEmpty ? site.description : page.description,
            path: page.path,
            kind: .other,
            imagePath: page.imagePath ?? site.imagePath,
            imageAlt: page.title
        )
    }
}

extension Node where Context == HTML.DocumentContext {
    static func adamYoungHead(for info: PageInfo, on site: AdamYoungSite) -> Node {
        let pageURL = site.url(for: info.path)
        let imageURL = info.imagePath.map { site.url.absoluteString + $0.absoluteString }

        return .head(
            .meta(.charset(.utf8)),
            .meta(.name("viewport"), .content("width=device-width, initial-scale=1, viewport-fit=cover")),
            .raw(##"<meta name="theme-color" content="#f5f7fa" media="(prefers-color-scheme: light)">"##),
            .raw(##"<meta name="theme-color" content="#0a0a0a" media="(prefers-color-scheme: dark)">"##),
            .meta(.name("format-detection"), .content("telephone=no")),
            .title(info.fullTitle),
            .meta(.name("description"), .content(info.description)),

            .meta(.name("apple-mobile-web-app-title"), .content(site.name)),
            .meta(.name("apple-mobile-web-app-capable"), .content("yes")),
            .meta(.name("apple-mobile-web-app-status-bar-style"), .content("black-translucent")),

            .link(.rel(.stylesheet), .href("/styles.css")),

            // Open Graph (Plot's `.title(...)` already emits og:title and twitter:title.)
            .raw(#"<meta property="og:type" content="\#(info.kind == .article ? "article" : "website")">"#),
            .raw(#"<meta property="og:site_name" content="\#(site.name)">"#),
            .raw(#"<meta property="og:description" content="\#(escapeHTMLAttribute(info.description))">"#),
            .raw(#"<meta property="og:url" content="\#(pageURL.absoluteString)">"#),
            .if(imageURL != nil, .group([
                .raw(#"<meta property="og:image" content="\#(imageURL ?? "")">"#),
                .raw(#"<meta property="og:image:alt" content="\#(escapeHTMLAttribute(info.imageAlt ?? site.name))">"#)
            ])),

            // Twitter
            .raw(#"<meta name="twitter:card" content="summary_large_image">"#),
            .raw(#"<meta name="twitter:site" content="@\#(site.twitterUsername)">"#),
            .raw(#"<meta name="twitter:creator" content="@\#(site.twitterUsername)">"#),

            // JSON-LD Person schema
            .raw(jsonLDPerson(for: site)),

            // Google Analytics
            .if(!site.googleAnalyticsID.isEmpty, .group([
                .link(
                    .rel(.preconnect),
                    .href("https://www.googletagmanager.com"),
                    .attribute(named: "crossorigin", value: nil)
                ),
                .raw(#"<link rel="dns-prefetch" href="https://www.google-analytics.com">"#),
                .raw(#"<script async src="https://www.googletagmanager.com/gtag/js?id=\#(site.googleAnalyticsID)"></script>"#),
                .raw("""
                <script>
                window.dataLayer = window.dataLayer || [];
                function gtag(){dataLayer.push(arguments);}
                gtag('js', new Date());
                gtag('config', '\(site.googleAnalyticsID)');
                </script>
                """)
            ]))
        )
    }
}

private func escapeHTMLAttribute(_ string: String) -> String {
    string
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
}

private func jsonLDPerson(for site: AdamYoungSite) -> String {
    """
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "Person",
      "name": "\(site.name)",
      "email": "mailto:\(site.authorEmail)",
      "url": "\(site.url.absoluteString)",
      "jobTitle": "\(site.tagline)",
      "image": "\(site.url.absoluteString)/assets/images/me.jpg",
      "sameAs": [
        "https://github.com/\(site.githubUsername)",
        "https://www.linkedin.com/in/\(site.linkedinUsername)"
      ]
    }
    </script>
    """
}

// MARK: - Icons

enum Icons {
    static let home = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 11.5 12 4l9 7.5"/><path d="M5 10.5V20a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1v-9.5"/></svg>"#
    static let blog = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 5a2 2 0 0 1 2-2h8l6 6v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><path d="M14 3v5a1 1 0 0 0 1 1h5"/><path d="M8 13h8"/><path d="M8 17h6"/></svg>"#
    static let projects = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>"#
    static let github = #"<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .5C5.7.5.5 5.7.5 12c0 5.1 3.3 9.4 7.8 10.9.6.1.8-.2.8-.6v-2c-3.2.7-3.9-1.4-3.9-1.4-.5-1.3-1.3-1.7-1.3-1.7-1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1 1.8 2.8 1.3 3.5 1 .1-.8.4-1.3.8-1.6-2.6-.3-5.3-1.3-5.3-5.7 0-1.3.5-2.3 1.2-3.1-.1-.3-.5-1.5.1-3.2 0 0 1-.3 3.3 1.2.9-.3 2-.4 3-.4s2 .1 3 .4c2.3-1.5 3.3-1.2 3.3-1.2.7 1.6.2 2.9.1 3.2.8.8 1.2 1.9 1.2 3.1 0 4.4-2.7 5.4-5.3 5.7.4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.6 4.5-1.5 7.8-5.8 7.8-10.9C23.5 5.7 18.3.5 12 .5z"/></svg>"#
    static let linkedin = #"<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.4 20.4h-3.5v-5.5c0-1.3 0-3-1.8-3s-2.1 1.4-2.1 2.9v5.6H9.5V9h3.4v1.6h.1c.5-.9 1.6-1.8 3.4-1.8 3.6 0 4.3 2.4 4.3 5.5v6.1zM5.5 7.4c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm1.8 13H3.7V9h3.6v11.4zM22.2 0H1.8C.8 0 0 .8 0 1.7v20.5C0 23.2.8 24 1.8 24h20.4c1 0 1.8-.8 1.8-1.8V1.7C24 .8 23.2 0 22.2 0z"/></svg>"#
    static let mail = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>"#
    static let search = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>"#
    static let arrowRight = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m13 6 6 6-6 6"/></svg>"#
    static let about = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>"#
    static let books = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4.5A1.5 1.5 0 0 1 5.5 3H10v15H5.5A1.5 1.5 0 0 0 4 19.5z"/><path d="M20 4.5A1.5 1.5 0 0 0 18.5 3H14v15h4.5a1.5 1.5 0 0 1 1.5 1.5"/><path d="M4 19.5A1.5 1.5 0 0 0 5.5 21H10"/><path d="M14 21h4.5a1.5 1.5 0 0 0 1.5-1.5"/></svg>"#
}

// MARK: - Shell

struct ShellOptions {
    var activePath: String
    var allTags: [Tag]
    var loadBlogFilter: Bool
    var showSearch: Bool

    init(
        activePath: String,
        allTags: [Tag] = [],
        loadBlogFilter: Bool = false,
        showSearch: Bool = false
    ) {
        self.activePath = activePath
        self.allTags = allTags
        self.loadBlogFilter = loadBlogFilter
        self.showSearch = showSearch
    }
}

extension Node where Context == HTML.BodyContext {
    static func siteShell(
        for site: AdamYoungSite,
        options: ShellOptions,
        content: [Node<HTML.BodyContext>]
    ) -> Node {
        .group(
            .a(.class("skip-link"), .href("#main"), .text("Skip to content")),
            .div(
                .class("shell"),
                .sidebarRail(for: site, activePath: options.activePath, allTags: options.allTags),
                .div(
                    .class("main-area"),
                    .if(options.showSearch, .topBar()),
                    .main(
                        .id("main"),
                        .class("content"),
                        .group(content)
                    ),
                    .siteFooter(for: site)
                )
            ),
            .if(options.loadBlogFilter,
                .raw(#"<script src="/blog-filter.js" defer></script>"#)
            )
        )
    }

    static func sidebarRail(for site: AdamYoungSite, activePath: String, allTags: [Tag]) -> Node {
        .element(
            named: "aside",
            nodes: [
                .attribute(named: "class", value: "rail"),
                .attribute(named: "aria-label", value: "Site navigation"),
                .a(
                    .class("rail-brand"),
                    .href("/"),
                    .img(
                        .class("rail-brand-avatar"),
                        .src("/assets/images/me.jpg"),
                        .alt("")
                    ),
                    .div(
                        .class("brand-text"),
                        .span(.class("brand-name"), .text(site.name)),
                        .span(.class("brand-pill"), .text(site.tagline))
                    )
                ),
                .nav(
                    .class("rail-nav rail-nav-primary"),
                    .attribute(named: "aria-label", value: "Primary"),
                    railLink(href: "/", icon: Icons.home, label: "Home", activePath: activePath),
                    railLink(href: "/about/", icon: Icons.about, label: "About", activePath: activePath),
                    railLink(href: "/blog/", icon: Icons.blog, label: "Blog", activePath: activePath),
                    railLink(href: "/projects/", icon: Icons.projects, label: "Projects", activePath: activePath)
                ),
                .div(.class("rail-divider"), .attribute(named: "aria-hidden", value: "true")),
                .nav(
                    .class("rail-nav rail-nav-tertiary"),
                    .attribute(named: "aria-label", value: "Reading"),
                    railLink(href: "/books/", icon: Icons.books, label: "Books", activePath: activePath)
                ),
                .div(.class("rail-divider"), .attribute(named: "aria-hidden", value: "true")),
                .nav(
                    .class("rail-nav rail-nav-secondary"),
                    .attribute(named: "aria-label", value: "Elsewhere"),
                    railLink(href: "https://github.com/\(site.githubUsername)", icon: Icons.github, label: "GitHub", activePath: activePath, external: true),
                    railLink(href: "https://www.linkedin.com/in/\(site.linkedinUsername)", icon: Icons.linkedin, label: "LinkedIn", activePath: activePath, external: true),
                    railLink(href: "mailto:\(site.authorEmail)", icon: Icons.mail, label: "Email", activePath: activePath, external: true)
                ),
                .if(!allTags.isEmpty, .group([
                    .div(.class("rail-divider"), .attribute(named: "aria-hidden", value: "true")),
                    .div(
                        .class("rail-topics"),
                        .span(.class("rail-section-label"), .text("Topics")),
                        .ul(
                            .class("rail-tag-list"),
                            .forEach(allTags) { tag in
                                .li(.a(
                                    .class("rail-tag"),
                                    .href("/blog/?tag=\(slugify(tag.string))"),
                                    .text(tag.string)
                                ))
                            }
                        )
                    )
                ]))
            ]
        )
    }

    static func topBar() -> Node {
        .header(
            .class("topbar"),
            .form(
                .class("search"),
                .action("/blog/"),
                .attribute(named: "method", value: "get"),
                .attribute(named: "role", value: "search"),
                .label(
                    .class("visually-hidden"),
                    .for("topbar-search"),
                    .text("Search posts")
                ),
                .span(.class("search-icon"), .raw(Icons.search)),
                .input(
                    .id("topbar-search"),
                    .name("q"),
                    .type(.search),
                    .attribute(named: "autocomplete", value: "off"),
                    .placeholder("Search posts, topics…")
                )
            )
        )
    }

    static func siteFooter(for site: AdamYoungSite) -> Node {
        let year = Calendar.current.component(.year, from: Date())
        return .footer(
            .class("site-footer"),
            .span(.text("© \(year) \(site.name)"))
        )
    }
}

private func railLink(href: String, icon: String, label: String, activePath: String, external: Bool = false) -> Node<HTML.BodyContext> {
    let isActive = !external && href == activePath
    var attrs: [Node<HTML.AnchorContext>] = [
        .class(isActive ? "rail-link active" : "rail-link"),
        .href(href),
        .span(.class("rail-link-icon"), .raw(icon)),
        .span(.class("rail-link-label"), .text(label))
    ]
    if isActive { attrs.append(.attribute(named: "aria-current", value: "page")) }
    if external {
        attrs.append(.attribute(named: "rel", value: "noopener"))
    }
    return .a(.group(attrs))
}

private func slugify(_ s: String) -> String {
    s.lowercased()
        .replacingOccurrences(of: " ", with: "-")
        .filter { $0.isLetter || $0.isNumber || $0 == "-" }
}

enum DateRendering {
    static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(identifier: "Europe/London")
        f.dateFormat = "d MMMM yyyy"
        return f
    }()

    static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func display(_ date: Date) -> String {
        displayFormatter.string(from: date)
    }

    static func iso(_ date: Date) -> String {
        isoFormatter.string(from: date)
    }
}
