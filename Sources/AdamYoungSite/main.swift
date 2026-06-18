import Foundation
import Publish
import SplashPublishPlugin

try AdamYoungSite().publish(using: [
    .installPlugin(.splash(withClassPrefix: "")),
    .copyResources(),
    .addMarkdownFiles(at: "Content"),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: .adamYoung),
    .generateRSSFeed(including: [.blog]),
    .generateSiteMap(),
    .generateMarkdownTwins(),
    .generateLLMsText(),
    .generateLLMsFullText(),
    .step(named: "Canonicalize sitemap URLs with trailing slash") { context in
        // GitHub Pages serves /foo/index.html as canonical /foo/ and 301-redirects /foo.
        // Publish's default sitemap emits the bare /foo, which Google flags as
        // "Page with redirect" in Search Console. Rewrite <loc> values to match
        // the canonical trailing-slash URL.
        let file = try context.outputFile(at: "sitemap.xml")
        let original = try file.readAsString()
        let updated = original.replacingOccurrences(
            of: #"<loc>(https?://[^<]*[^/])</loc>"#,
            with: "<loc>$1/</loc>",
            options: .regularExpression
        )
        try file.write(updated)
    }
])
