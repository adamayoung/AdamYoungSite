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
                        .heroCard(),
                        .latestBlogSection(items: latestPosts),
                        .projectsSection()
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
                        loadBlogFilter: section.id == .blog,
                        showSearch: section.id == .blog
                    ),
                    content: [
                        .pageHeader(title: section.title, subtitle: section.description),
                        .if(section.items.isEmpty,
                            .div(.class("empty-state"), .p(.text("No posts yet — check back soon."))),
                            else: .div(
                                .class("post-list"),
                                .forEach(section.items) { item in
                                    .postRow(for: item)
                                },
                                .div(
                                    .class("empty-state hidden"),
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
                    options: ShellOptions(activePath: "/blog/", allTags: tags, showSearch: true),
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
        case "about":
            pageContent = aboutPageContent(title: page.title, subtitle: page.description)
        case "books":
            pageContent = booksPageContent(title: page.title, subtitle: page.description)
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
            .a(
                .class("hero-availability"),
                .href("mailto:me@adam-young.co.uk"),
                .span(.class("hero-availability-dot")),
                .text("Available for new Senior/Staff iOS roles · UK / Remote")
            ),
            .h2(
                .class("hero-title"),
                .text("Hi, I'm "),
                .span(.class("hero-name"), .text("Adam."))
            ),
            .p(
                .class("hero-tagline"),
                .text("16 years on Apple platforms — recently at Monzo, Bumble and PokerStars, shipping features used by tens of millions.")
            ),
            .p(
                .class("hero-sub"),
                .text("Drawn to engineering craft — clean architecture, TDD, and the practices that make teams ship work they're proud of.")
            ),
            .div(
                .class("hero-actions"),
                .a(
                    .class("btn-primary"),
                    .href("/blog/"),
                    .text("Read my blog"),
                    .span(.class("btn-arrow"), .raw(Icons.arrowRight))
                ),
                .a(
                    .class("btn-secondary"),
                    .href("/projects/"),
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
                    ])
                ),
                .h3(.text(item.title)),
                .p(.text(item.description)),
                .if(!item.tags.isEmpty,
                    .div(
                        .class("post-card-tags"),
                        .forEach(item.tags) { tag in
                            .span(.class("tag"), .text(tag.string))
                        }
                    )
                )
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
                    ])
                ),
                .h3(.text(item.title)),
                .p(.text(item.description)),
                .if(!item.tags.isEmpty,
                    .div(
                        .class("post-card-tags"),
                        .forEach(item.tags) { tag in
                            .span(.class("tag"), .text(tag.string))
                        }
                    )
                ),
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

private func careerRow(for entry: CareerEntry) -> Node<HTML.ListContext> {
    let totalDuration = formatDuration(from: entry.earliestStart, to: entry.latestEnd)
    let listClass = entry.roles.count > 1 ? "sub-role-list multi" : "sub-role-list"
    let roleNodes: [Node<HTML.ListContext>] = entry.roles.map { role in
        .li(
            .class("sub-role"),
            .div(
                .class("sub-role-body"),
                .span(.class("primary-line"), .text(role.title)),
                .span(.class("date-line"), .text(roleDateLine(start: role.start, end: role.end)))
            )
        )
    }
    return .li(
        .class("career-row"),
        companyLogo(for: entry),
        .div(
            .class("career-body"),
            .h3(.class("primary-line"), .text(entry.company)),
            .p(.class("company-description"), .text(entry.companyDescription)),
            .span(.class("secondary-line"), .text("\(entry.workMode) · \(totalDuration)")),
            .span(.class("location-line"), .text(entry.location)),
            .ul(.class(listClass), .group(roleNodes))
        )
    )
}

private func companyLogo(for entry: CareerEntry) -> Node<HTML.BodyContext> {
    .div(
        .class("company-logo"),
        .img(
            .src(entry.logoPath),
            .alt("\(entry.company) logo"),
            .attribute(named: "loading", value: "lazy")
        )
    )
}

private func roleDateLine(start: Date, end: Date?) -> String {
    let endActual = end ?? Date()
    let endLabel = end == nil ? "Present" : formatMonth(endActual)
    let duration = formatDuration(from: start, to: endActual)
    return "\(formatMonth(start)) - \(endLabel) · \(duration)"
}

private func educationRow(for entry: EducationEntry) -> Node<HTML.ListContext> {
    .li(
        .class("education-row"),
        .div(
            .class("company-logo"),
            .img(
                .src(entry.logoPath),
                .alt("\(entry.institution) logo"),
                .attribute(named: "loading", value: "lazy")
            )
        ),
        .div(
            .class("career-body"),
            .h3(.class("primary-line"), .text(entry.institution)),
            .span(.class("secondary-line"), .text(entry.qualification)),
            .span(.class("date-line"), .text(entry.dates))
        )
    )
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
        blurb: "Open source Swift Package for The Movie Database API.",
        url: "https://github.com/adamayoung/TMDb",
        cssClass: "tmdb",
        iconSVG: #"<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.8 20.5 7.5v9L12 21.2 3.5 16.5v-9z"/><path d="M3.5 7.5 12 12.2l8.5-4.7"/><path d="M12 12.2V21.2"/></svg>"#,
        imagePath: "/assets/images/projects/tmdb.png",
        tech: ["Swift", "async/await", "SPM", "iOS", "macOS", "watchOS", "tvOS", "visionOS", "Linux"]
    ),
    Project(
        name: "Popcorn",
        blurb: "Personal iOS, macOS & visionOS app for browsing movies and TV.",
        url: "https://github.com/adamayoung/popcorn",
        cssClass: "popcorn",
        iconSVG: ##"<svg viewBox="3.5 4.5 17 17" xmlns="http://www.w3.org/2000/svg"><g fill="#FFC404"><circle cx="6.2" cy="11" r="1.6"/><circle cx="8" cy="9" r="2.1"/><circle cx="11" cy="7.4" r="2.2"/><circle cx="13.8" cy="7.6" r="2.1"/><circle cx="16.2" cy="9.2" r="2"/><circle cx="17.6" cy="11" r="1.5"/><circle cx="11.5" cy="10.4" r="2"/><circle cx="14.6" cy="10.6" r="1.9"/></g><path d="M5 12 L9.67 12 L10.33 21 L7 21 Z" fill="#E11D2C" fill-opacity="0.92"/><path d="M9.67 12 L14.33 12 L13.67 21 L10.33 21 Z" fill="#FFFFFF" fill-opacity="0.96"/><path d="M14.33 12 L19 12 L17 21 L13.67 21 Z" fill="#E11D2C" fill-opacity="0.92"/></svg>"##,
        imagePath: "/assets/images/projects/popcorn.png",
        tech: ["Swift", "TCA", "SwiftData", "CloudKit", "Apple Intelligence", "iOS", "macOS", "visionOS"]
    )
]

// MARK: - Career data

struct CareerRole {
    let title: String
    let start: Date
    let end: Date?
}

struct CareerEntry {
    let company: String
    let companyDescription: String
    let logoPath: String
    let location: String
    let workMode: String
    let roles: [CareerRole]

    var earliestStart: Date {
        roles.map(\.start).min() ?? Date()
    }

    var latestEnd: Date {
        if roles.contains(where: { $0.end == nil }) { return Date() }
        return roles.compactMap(\.end).max() ?? Date()
    }
}

struct EducationEntry {
    let institution: String
    let logoPath: String
    let qualification: String
    let dates: String
}

private func ymd(_ year: Int, _ month: Int) -> Date {
    var c = DateComponents()
    c.year = year
    c.month = month
    c.day = 1
    return Calendar(identifier: .gregorian).date(from: c)!
}

private let monthFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_GB")
    f.dateFormat = "MMM yyyy"
    return f
}()

private func formatMonth(_ date: Date) -> String {
    monthFormatter.string(from: date)
}

private func formatDuration(from start: Date, to end: Date) -> String {
    let cal = Calendar(identifier: .gregorian)
    let comps = cal.dateComponents([.year, .month], from: start, to: end)
    let totalMonths = (comps.year ?? 0) * 12 + (comps.month ?? 0) + 1
    let years = totalMonths / 12
    let months = totalMonths % 12
    var parts: [String] = []
    if years > 0 { parts.append("\(years) \(years == 1 ? "yr" : "yrs")") }
    if months > 0 { parts.append("\(months) \(months == 1 ? "mo" : "mos")") }
    if parts.isEmpty { return "1 mo" }
    return parts.joined(separator: " ")
}

let careerHistory: [CareerEntry] = [
    CareerEntry(
        company: "Monzo Bank",
        companyDescription: "UK digital bank built mobile-first, with over 12 million customers.",
        logoPath: "/assets/images/companies/monzo.svg",
        location: "London / Remote",
        workMode: "Full-time",
        roles: [
            CareerRole(title: "Senior iOS Engineer", start: ymd(2025, 11), end: ymd(2026, 4))
        ]
    ),
    CareerEntry(
        company: "Bumble Inc.",
        companyDescription: "Owner of Bumble and Badoo — connection apps where women make the first move.",
        logoPath: "/assets/images/companies/bumble.svg",
        location: "London / Hybrid",
        workMode: "Full-time",
        roles: [
            CareerRole(title: "Senior iOS Engineer", start: ymd(2024, 11), end: ymd(2025, 8))
        ]
    ),
    CareerEntry(
        company: "Flutter Entertainment / PokerStars",
        companyDescription: "Global online sports betting and iGaming group; PokerStars is its market-leading poker brand.",
        logoPath: "/assets/images/companies/flutter-entertainment.svg",
        location: "Leeds / Remote",
        workMode: "Full-time",
        roles: [
            CareerRole(title: "Principal iOS Engineer", start: ymd(2023, 1), end: ymd(2024, 10)),
            CareerRole(title: "Lead iOS Engineer", start: ymd(2021, 10), end: ymd(2023, 1)),
            CareerRole(title: "Senior iOS Engineer", start: ymd(2021, 2), end: ymd(2021, 9))
        ]
    ),
    CareerEntry(
        company: "MHR",
        companyDescription: "UK provider of HR, payroll and finance software and services.",
        logoPath: "/assets/images/companies/mhr.svg",
        location: "Nottingham",
        workMode: "Full-time",
        roles: [
            CareerRole(title: "Lead Mobile Developer", start: ymd(2018, 11), end: ymd(2021, 2)),
            CareerRole(title: "Research Engineering Manager", start: ymd(2017, 2), end: ymd(2018, 10)),
            CareerRole(title: "Research Engineer", start: ymd(2015, 10), end: ymd(2017, 1)),
            CareerRole(title: "Lead Web Application Developer", start: ymd(2015, 1), end: ymd(2015, 9)),
            CareerRole(title: "Senior Web Developer", start: ymd(2014, 10), end: ymd(2014, 12)),
            CareerRole(title: "Senior Mobile Software Engineer", start: ymd(2014, 4), end: ymd(2014, 9)),
            CareerRole(title: "Senior Web Developer", start: ymd(2013, 10), end: ymd(2014, 3)),
            CareerRole(title: "Software Engineer", start: ymd(2011, 11), end: ymd(2013, 10)),
            CareerRole(title: "Web Architect", start: ymd(2003, 4), end: ymd(2011, 11))
        ]
    )
]

let education: [EducationEntry] = [
    EducationEntry(
        institution: "University of Nottingham",
        logoPath: "/assets/images/companies/nottingham.svg",
        qualification: "BSc (Hons) Computer Science · 2:1",
        dates: "1999–2002"
    )
]

// MARK: - Books data

struct Book {
    let title: String
    let subtitle: String?
    let authors: [String]
    let coverPath: String
}

struct BookGroup {
    let title: String
    let books: [Book]
}

let allBookGroups: [BookGroup] = [
    BookGroup(
        title: "Mobile & Swift",
        books: [
            Book(
                title: "AI Driven Swift Architecture",
                subtitle: "Build modern iOS SwiftUI apps with Foundation Models, MCP agents, Clean Architecture, and TDD",
                authors: ["Walid SASSI", "Dave Poirier"],
                coverPath: "/assets/images/books/ai-driven-swift-architecture.png"
            ),
            Book(
                title: "Mobile System Design Interview",
                subtitle: "An Insider's Guide",
                authors: ["Manuel Vicente Vivo"],
                coverPath: "/assets/images/books/mobile-system-design-interview.webp"
            )
        ]
    ),
    BookGroup(
        title: "Software craftsmanship",
        books: [
            Book(
                title: "Tidy First?",
                subtitle: "A Personal Exercise in Empirical Software Design",
                authors: ["Kent Beck"],
                coverPath: "/assets/images/books/tidy-first.jpg"
            ),
            Book(
                title: "Clean Code",
                subtitle: "A Handbook of Agile Software Craftsmanship",
                authors: ["Robert C. Martin"],
                coverPath: "/assets/images/books/clean-code.jpg"
            ),
            Book(
                title: "Clean Architecture",
                subtitle: "A Craftsman's Guide to Software Structure and Design",
                authors: ["Robert C. Martin"],
                coverPath: "/assets/images/books/clean-architecture.jpg"
            ),
            Book(
                title: "The Clean Coder",
                subtitle: "A Code of Conduct for Professional Programmers",
                authors: ["Robert C. Martin"],
                coverPath: "/assets/images/books/the-clean-coder.jpg"
            )
        ]
    ),
    BookGroup(
        title: "DevOps",
        books: [
            Book(
                title: "The Phoenix Project",
                subtitle: "A Novel about IT, DevOps, and Helping Your Business Win",
                authors: ["Gene Kim", "Kevin Behr", "George Spafford"],
                coverPath: "/assets/images/books/the-phoenix-project.jpg"
            ),
            Book(
                title: "The DevOps Handbook",
                subtitle: "How to Create World-Class Agility, Reliability, and Security in Technology Organizations",
                authors: ["Gene Kim", "Jez Humble", "Patrick Debois", "John Willis"],
                coverPath: "/assets/images/books/the-devops-handbook.jpg"
            ),
            Book(
                title: "The Unicorn Project",
                subtitle: "A Novel about Developers, Digital Disruption, and Thriving in the Age of Data",
                authors: ["Gene Kim"],
                coverPath: "/assets/images/books/the-unicorn-project.jpg"
            )
        ]
    )
]

private func bookCard(for book: Book) -> Node<HTML.BodyContext> {
    .article(
        .class("book-card"),
        .div(
            .class("book-cover"),
            .img(
                .src(book.coverPath),
                .alt("\(book.title) book cover"),
                .attribute(named: "loading", value: "lazy")
            )
        ),
        .div(
            .class("book-body"),
            .h3(.class("book-title"), .text(book.title)),
            .if(book.subtitle != nil,
                .p(.class("book-subtitle"), .text(book.subtitle ?? ""))
            ),
            .p(.class("book-authors"), .text(book.authors.joined(separator: ", ")))
        )
    )
}

private func bookGroupSection(for group: BookGroup) -> Node<HTML.BodyContext> {
    .section(
        .class("book-group"),
        .h2(.class("book-group-title"), .text(group.title)),
        .div(
            .class("book-grid"),
            .group(group.books.map { bookCard(for: $0) })
        )
    )
}

func booksPageContent(title: String, subtitle: String) -> [Node<HTML.BodyContext>] {
    [
        .pageHeader(title: title, subtitle: subtitle),
        .div(
            .class("book-groups"),
            .group(allBookGroups.map { bookGroupSection(for: $0) })
        )
    ]
}

// MARK: - About page rendering

func aboutPageContent(title: String, subtitle: String) -> [Node<HTML.BodyContext>] {
    [
        .pageHeader(title: title),
        .section(
            .class("about-hero"),
            .span(
                .class("about-hero-eyebrow"),
                .span(.class("eyebrow-dot")),
                .text("Senior iOS Engineer · Oakham, UK")
            ),
            .p(
                .class("about-hero-lead"),
                .text("Hi, I'm Adam. I've been writing software for over two decades, and the last sixteen of those have been on "),
                .span(.class("about-hero-highlight"), .text("Apple platforms")),
                .text(".")
            ),
            .p(.text("What pulls me in is engineering craft: clean architecture, well-designed APIs, the kind of code that's a pleasure to come back to six months later. Most of that's played out in mobile, but I'm equally at home in a server-side codebase, a CI pipeline, or a meeting room making the case for an architecture change.")),
            .p(.text("The bit I enjoy most is helping engineering teams ship work they're proud of, through mentoring, tech talks, and championing the practices that compound, from TDD to thoughtful AI-assisted development. Outside of work I maintain an open source Swift package, build personal projects for the joy of it, and write here. The thread running through all of it: build things properly, and build things people actually use.")),
            .div(
                .class("about-hero-chips chips"),
                .span(.class("chip"), .text("Swift")),
                .span(.class("chip"), .text("Architecture")),
                .span(.class("chip"), .text("Engineering craft")),
                .span(.class("chip"), .text("AI-assisted development"))
            )
        ),
        .section(
            .class("about-section"),
            .h2(.text("Experience")),
            .ol(
                .class("career-list"),
                .group(careerHistory.map { careerRow(for: $0) })
            )
        ),
        .section(
            .class("about-section"),
            .h2(.text("Education")),
            .ul(
                .class("education-list"),
                .group(education.map { educationRow(for: $0) })
            )
        )
    ]
}
