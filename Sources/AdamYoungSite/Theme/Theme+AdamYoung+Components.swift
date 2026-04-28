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
            .raw(##"<meta name="theme-color" content="#eef3f8" media="(prefers-color-scheme: light)">"##),
            .raw(##"<meta name="theme-color" content="#050810" media="(prefers-color-scheme: dark)">"##),
            .meta(.name("format-detection"), .content("telephone=no")),
            .title(info.fullTitle),
            .meta(.name("description"), .content(info.description)),

            .link(.rel(.icon), .type("image/jpeg"), .href("/assets/images/me.jpg")),
            .link(.rel(.appleTouchIcon), .href("/assets/images/me.jpg")),
            .meta(.name("apple-mobile-web-app-title"), .content(site.name)),
            .meta(.name("apple-mobile-web-app-capable"), .content("yes")),
            .meta(.name("apple-mobile-web-app-status-bar-style"), .content("black-translucent")),

            .link(.rel(.stylesheet), .href("/styles.css")),
            .link(
                .rel(.alternate),
                .type("application/rss+xml"),
                .href("/feed.rss"),
                .attribute(named: "title", value: site.name)
            ),

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

extension Node where Context == HTML.BodyContext {
    static func ambientBlobs() -> Node {
        .div(
            .class("ambient"),
            .attribute(named: "aria-hidden", value: "true"),
            .div(.class("blob b1")),
            .div(.class("blob b2")),
            .div(.class("blob b3"))
        )
    }

    static func topNav() -> Node {
        .nav(
            .class("nav"),
            .div(
                .class("nav-inner glass"),
                .a(.class("name"), .href("/"), .text("Adam Young")),
                .div(
                    .class("links"),
                    .a(.href("/blog/"), .text("Blog")),
                    .a(.href("/#projects"), .text("Projects")),
                    .a(.href("/#contact"), .text("Contact"))
                )
            )
        )
    }

    static func siteFooter() -> Node {
        let year = Calendar.current.component(.year, from: Date())
        return .footer(
            .class("site-footer"),
            .text("© \(year) Adam Young")
        )
    }
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
