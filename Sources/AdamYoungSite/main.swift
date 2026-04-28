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
    .generateSiteMap()
])
