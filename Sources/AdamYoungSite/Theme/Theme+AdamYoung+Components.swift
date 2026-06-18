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
    var publishedDate: Date? = nil
    var lastModifiedDate: Date? = nil
    var tags: [String] = []
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
            imageAlt: item.title,
            publishedDate: item.date,
            lastModifiedDate: item.date,
            tags: item.tags.map(\.string)
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
        // Ensure trailing slash so canonical matches the served URL (GH Pages serves index.html at /slug/)
        let canonicalURL: String = {
            var s = pageURL.absoluteString
            if !s.hasSuffix("/") { s += "/" }
            return s
        }()
        let imageURL = info.imagePath.map { site.url.absoluteString + $0.absoluteString }

        // Markdown twin for AI agents: present for blog posts and the content
        // pages that AIFriendly.generateMarkdownTwins() emits a .md for.
        let markdownTwinURL: String? = {
            let hasTwin = info.kind == .article
                || PublishingStep<AdamYoungSite>.twinnablePages.contains(info.path.string)
            return hasTwin ? "\(site.url.absoluteString)/\(info.path.string).md" : nil
        }()

        let articleOGMeta: String = {
            guard info.kind == .article, let pubDate = info.publishedDate else { return "" }
            let modDate = info.lastModifiedDate ?? pubDate
            var parts = [
                #"<meta property="article:published_time" content="\#(DateRendering.iso(pubDate))">"#,
                #"<meta property="article:modified_time" content="\#(DateRendering.iso(modDate))">"#,
                #"<meta property="article:author" content="\#(site.url.absoluteString)/about/">"#,
                #"<meta property="article:section" content="Blog">"#
            ]
            for tag in info.tags {
                parts.append(#"<meta property="article:tag" content="\#(escapeHTMLAttribute(tag))">"#)
            }
            return parts.joined(separator: "\n        ")
        }()

        return .head(
            .meta(.charset(.utf8)),
            .meta(.name("viewport"), .content("width=device-width, initial-scale=1, viewport-fit=cover")),
            .raw(##"<meta name="theme-color" content="#f5f7fa" media="(prefers-color-scheme: light)">"##),
            .raw(##"<meta name="theme-color" content="#0a0a0a" media="(prefers-color-scheme: dark)">"##),
            .meta(.name("format-detection"), .content("telephone=no")),
            .title(info.fullTitle),
            .meta(.name("description"), .content(info.description)),
            .meta(.name("author"), .content(site.name)),
            .raw(#"<link rel="canonical" href="\#(canonicalURL)">"#),

            // RSS auto-discovery — lets feed readers and tools find the feed.
            .raw(#"<link rel="alternate" type="application/rss+xml" title="\#(escapeHTMLAttribute(site.name)) — Blog" href="\#(site.url.absoluteString)/feed.rss">"#),

            // Markdown twin auto-discovery — lets AI agents fetch clean Markdown instead of scraping HTML.
            .if(markdownTwinURL != nil,
                .raw(#"<link rel="alternate" type="text/markdown" title="Markdown source" href="\#(markdownTwinURL ?? "")">"#)),

            .meta(.name("apple-mobile-web-app-title"), .content(site.name)),
            .meta(.name("apple-mobile-web-app-capable"), .content("yes")),
            .meta(.name("apple-mobile-web-app-status-bar-style"), .content("black-translucent")),

            .link(.rel(.stylesheet), .href("/styles.css")),
            .raw(#"<link rel="icon" href="/assets/images/favicon-32.png" type="image/png" sizes="32x32">"#),
            .raw(#"<link rel="apple-touch-icon" href="/assets/images/apple-touch-icon.png">"#),

            // Open Graph (Plot's `.title(...)` already emits og:title and twitter:title.)
            .raw(#"<meta property="og:type" content="\#(info.kind == .article ? "article" : "website")">"#),
            .raw(#"<meta property="og:site_name" content="\#(site.name)">"#),
            .raw(#"<meta property="og:description" content="\#(escapeHTMLAttribute(info.description))">"#),
            .raw(#"<meta property="og:url" content="\#(canonicalURL)">"#),
            .raw(#"<meta property="og:locale" content="en_GB">"#),
            .if(imageURL != nil, .group([
                .raw(#"<meta property="og:image" content="\#(imageURL ?? "")">"#),
                .raw(#"<meta property="og:image:alt" content="\#(escapeHTMLAttribute(info.imageAlt ?? site.name))">"#)
            ])),

            // Article-specific OG tags (published_time, modified_time, author, section, per-tag)
            .raw(articleOGMeta),

            // Twitter
            .raw(#"<meta name="twitter:card" content="summary_large_image">"#),
            .raw(#"<meta name="twitter:site" content="@\#(site.twitterUsername)">"#),
            .raw(#"<meta name="twitter:creator" content="@\#(site.twitterUsername)">"#),

            // JSON-LD schemas
            .raw(jsonLDPerson(for: site)),
            .if(info.kind == .article, .raw(jsonLDBlogPosting(for: info, on: site))),
            .if(info.kind == .article, .raw(jsonLDBreadcrumbs(for: info, on: site))),
            .if(info.kind == .home, .raw(jsonLDWebSite(for: site)))
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

private func escapeJSONString(_ string: String) -> String {
    var result = string
    result = result.replacingOccurrences(of: "\\", with: "\\\\")
    result = result.replacingOccurrences(of: "\"", with: "\\\"")
    result = result.replacingOccurrences(of: "/", with: "\\/")  // prevents </script> injection
    result = result.replacingOccurrences(of: "\n", with: "\\n")
    result = result.replacingOccurrences(of: "\r", with: "\\r")
    result = result.replacingOccurrences(of: "\t", with: "\\t")
    return result
}

private func jsonLDPerson(for site: AdamYoungSite) -> String {
    """
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "Person",
      "@id": "\(site.url.absoluteString)/#person",
      "name": "\(escapeJSONString(site.name))",
      "email": "mailto:\(site.authorEmail)",
      "url": "\(site.url.absoluteString)",
      "jobTitle": "\(escapeJSONString(site.tagline))",
      "image": "\(site.url.absoluteString)/assets/images/apple-touch-icon.png",
      "sameAs": [
        "https://github.com/\(site.githubUsername)",
        "https://www.linkedin.com/in/\(site.linkedinUsername)"
      ]
    }
    </script>
    """
}

private func jsonLDBlogPosting(for info: PageInfo, on site: AdamYoungSite) -> String {
    guard let publishedDate = info.publishedDate else { return "" }
    var pageURL = site.url(for: info.path).absoluteString
    if !pageURL.hasSuffix("/") { pageURL += "/" }
    let imageURL = info.imagePath.map { site.url.absoluteString + $0.absoluteString }
        ?? "\(site.url.absoluteString)/assets/images/me.jpg"
    let modifiedDate = info.lastModifiedDate ?? publishedDate
    let keywordsLine = info.tags.isEmpty ? "" : """
    ,
      "keywords": "\(escapeJSONString(info.tags.joined(separator: ", ")))"
    """
    return """
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      "headline": "\(escapeJSONString(info.title))",
      "description": "\(escapeJSONString(info.description))",
      "datePublished": "\(DateRendering.iso(publishedDate))",
      "dateModified": "\(DateRendering.iso(modifiedDate))",
      "url": "\(pageURL)",
      "image": "\(imageURL)",
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "\(pageURL)"
      },
      "author": {
        "@type": "Person",
        "@id": "\(site.url.absoluteString)/#person",
        "name": "\(escapeJSONString(site.name))",
        "url": "\(site.url.absoluteString)/about/"
      }\(keywordsLine)
    }
    </script>
    """
}

private func jsonLDBreadcrumbs(for info: PageInfo, on site: AdamYoungSite) -> String {
    var pageURL = site.url(for: info.path).absoluteString
    if !pageURL.hasSuffix("/") { pageURL += "/" }
    return """
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": [
        {"@type": "ListItem", "position": 1, "name": "Home", "item": "\(site.url.absoluteString)/"},
        {"@type": "ListItem", "position": 2, "name": "Blog", "item": "\(site.url.absoluteString)/blog/"},
        {"@type": "ListItem", "position": 3, "name": "\(escapeJSONString(info.title))", "item": "\(pageURL)"}
      ]
    }
    </script>
    """
}

private func jsonLDWebSite(for site: AdamYoungSite) -> String {
    """
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "url": "\(site.url.absoluteString)/",
      "name": "\(escapeJSONString(site.name))",
      "potentialAction": {
        "@type": "SearchAction",
        "target": "\(site.url.absoluteString)/blog/?q={search_term_string}",
        "query-input": "required name=search_term_string"
      }
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
    static let menu = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 6h16"/><path d="M4 12h16"/><path d="M4 18h16"/></svg>"#
    static let close = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>"#
    static let arrowRight = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"/><path d="m13 6 6 6-6 6"/></svg>"#
    static let about = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>"#
    static let books = #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4.5A1.5 1.5 0 0 1 5.5 3H10v15H5.5A1.5 1.5 0 0 0 4 19.5z"/><path d="M20 4.5A1.5 1.5 0 0 0 18.5 3H14v15h4.5a1.5 1.5 0 0 1 1.5 1.5"/><path d="M4 19.5A1.5 1.5 0 0 0 5.5 21H10"/><path d="M14 21h4.5a1.5 1.5 0 0 0 1.5-1.5"/></svg>"#
}

// MARK: - Shell

struct ShellOptions {
    var activePath: String
    var loadBlogFilter: Bool

    init(
        activePath: String,
        loadBlogFilter: Bool = false
    ) {
        self.activePath = activePath
        self.loadBlogFilter = loadBlogFilter
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
            // Mobile sticky header — hidden on desktop via CSS
            .element(
                named: "header",
                nodes: [
                    .attribute(named: "class", value: "mobile-header"),
                    .attribute(named: "aria-label", value: "Site header"),
                    .element(
                        named: "button",
                        nodes: [
                            .attribute(named: "type", value: "button"),
                            .attribute(named: "class", value: "nav-toggle-btn"),
                            .attribute(named: "aria-label", value: "Open navigation"),
                            .attribute(named: "aria-expanded", value: "false"),
                            .attribute(named: "aria-controls", value: "nav-rail"),
                            .raw(Icons.menu)
                        ]
                    ),
                    .a(
                        .class("mobile-brand"),
                        .href("/"),
                        .img(
                            .class("mobile-brand-avatar"),
                            .src("/assets/images/me.jpg"),
                            .alt("")
                        ),
                        .span(.class("mobile-brand-name"), .text(site.name))
                    )
                ]
            ),
            .div(
                .class("shell"),
                // Backdrop — clicking closes the drawer
                .div(
                    .class("nav-overlay"),
                    .attribute(named: "aria-hidden", value: "true")
                ),
                .sidebarRail(for: site, activePath: options.activePath),
                .div(
                    .class("main-area"),
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
            ),
            // Mobile nav: toggle open/close, aria-expanded, focus management, Escape key
            .raw(#"""
            <script>
            (function(){
              var btn=document.querySelector('.nav-toggle-btn');
              var closeBtn=document.querySelector('.nav-close-btn');
              var overlay=document.querySelector('.nav-overlay');
              var html=document.documentElement;
              function openNav(){html.setAttribute('data-nav-open','');btn.setAttribute('aria-expanded','true');if(closeBtn)closeBtn.focus();}
              function closeNav(){html.removeAttribute('data-nav-open');btn.setAttribute('aria-expanded','false');if(btn)btn.focus();}
              if(btn){btn.addEventListener('click',openNav);}
              if(closeBtn){closeBtn.addEventListener('click',closeNav);}
              if(overlay){overlay.addEventListener('click',closeNav);}
              document.addEventListener('keydown',function(e){if(e.key==='Escape'&&html.hasAttribute('data-nav-open'))closeNav();});
            })();
            </script>
            """#)
        )
    }

    static func sidebarRail(for site: AdamYoungSite, activePath: String) -> Node {
        .element(
            named: "aside",
            nodes: [
                .attribute(named: "class", value: "rail"),
                .attribute(named: "id", value: "nav-rail"),
                .attribute(named: "aria-label", value: "Site navigation"),
                // Mobile close button (hidden on desktop)
                .div(
                    .class("rail-mobile-head"),
                    .element(
                        named: "button",
                        nodes: [
                            .attribute(named: "type", value: "button"),
                            .attribute(named: "class", value: "nav-close-btn"),
                            .attribute(named: "aria-label", value: "Close navigation"),
                            .raw(Icons.close)
                        ]
                    )
                ),
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
                    railLink(href: "https://github.com/\(site.githubUsername)", icon: Icons.github, label: "GitHub", activePath: activePath, external: true, identity: true),
                    railLink(href: "https://www.linkedin.com/in/\(site.linkedinUsername)", icon: Icons.linkedin, label: "LinkedIn", activePath: activePath, external: true, identity: true),
                    railLink(href: "mailto:\(site.authorEmail)", icon: Icons.mail, label: "Email", activePath: activePath, external: true, identity: true)
                )
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

private func railLink(href: String, icon: String, label: String, activePath: String, external: Bool = false, identity: Bool = false) -> Node<HTML.BodyContext> {
    let isActive = !external && href == activePath
    var attrs: [Node<HTML.AnchorContext>] = [
        .class(isActive ? "rail-link active" : "rail-link"),
        .href(href),
        .span(.class("rail-link-icon"), .raw(icon)),
        .span(.class("rail-link-label"), .text(label))
    ]
    if isActive { attrs.append(.attribute(named: "aria-current", value: "page")) }
    if external {
        let relValue = identity ? "me noopener" : "noopener"
        attrs.append(.attribute(named: "rel", value: relValue))
    }
    return .a(.group(attrs))
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
