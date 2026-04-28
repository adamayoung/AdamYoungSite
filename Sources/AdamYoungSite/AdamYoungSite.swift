import Foundation
import Publish
import Plot

struct AdamYoungSite: Website {
    enum SectionID: String, WebsiteSectionID {
        case blog
    }

    struct ItemMetadata: WebsiteItemMetadata {}

    var url = URL(string: "https://adam-young.co.uk")!
    var name = "Adam Young"
    var description = "iOS Engineer based in Oakham, UK. Personal site, projects, and writing."
    var language: Language { .english }
    var imagePath: Path? { "/assets/images/me.jpg" }

    let tagline = "iOS Engineer"
    let location = "Oakham, UK"
    let authorEmail = "me@adam-young.co.uk"
    let githubUsername = "adamayoung"
    let linkedinUsername = "adamayoung"
    let twitterUsername = "adamayoung"
    let googleAnalyticsID = "G-ETGHS44KVE"
}
