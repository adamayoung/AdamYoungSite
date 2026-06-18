import Foundation
import Publish

// Make the site friendly to AI agents (Claude, Claude Code, ChatGPT, Codex, etc.).
//
// Three outputs, all generated at build time from the same Markdown that drives
// the HTML, so they can never drift from the rendered site:
//
//   1. Markdown twins  — /blog/<slug>.md, /about.md, /projects.md, /books.md
//      The raw source of each page, so an agent reads clean Markdown instead of
//      scraping HTML. Mirrors the convention Anthropic's own docs use (append
//      .md to a page to get its Markdown).
//   2. /llms.txt        — the llmstxt.org index: an H1 + summary + linked list of
//      every page, pointing at the .md twins. A map of the site in one fetch.
//   3. /llms-full.txt   — every post concatenated, for agents that want it all at
//      once.
//
// The set of pages that get a twin is defined once here (`twinnablePages`) and
// reused by the <head> discovery link in Theme+AdamYoung+Components.swift.

extension PublishingStep where Site == AdamYoungSite {
    /// Top-level content pages (not in a section) that get a Markdown twin.
    static var twinnablePages: [String] { ["about", "projects", "books"] }

    /// Copy the raw Markdown source of each post and content page into the
    /// output at `<path>.md` (e.g. `/blog/canon-tdd.md`, `/about.md`).
    static func generateMarkdownTwins() -> Self {
        .step(named: "Emit Markdown twins for AI agents") { context in
            func writeTwin(from sourcePath: String, to outputPath: String) throws {
                let markdown = try context.file(at: Path(sourcePath)).readAsString()
                try context.createOutputFile(at: Path(outputPath)).write(markdown)
            }

            for item in context.sections[.blog].items {
                try writeTwin(from: "Content/\(item.path.string).md",
                              to: "\(item.path.string).md")
            }
            for name in PublishingStep.twinnablePages {
                try writeTwin(from: "Content/\(name).md", to: "\(name).md")
            }
        }
    }

    /// Generate `/llms.txt`: an llmstxt.org-format index of the whole site.
    static func generateLLMsText() -> Self {
        .step(named: "Generate llms.txt") { context in
            let site = context.site
            let base = site.url.absoluteString

            var out = "# \(site.name)\n\n"
            out += "> \(site.description)\n\n"
            out += "Markdown index of \(base) for AI agents. "
            out += "Each link below is the clean Markdown source of a page; "
            out += "drop the `.md` and add a trailing slash for the rendered HTML.\n\n"

            out += "## Pages\n\n"
            for name in PublishingStep.twinnablePages {
                guard let page = context.pages[Path(name)] else { continue }
                out += "- [\(page.title)](\(base)/\(name).md): \(page.description)\n"
            }

            out += "\n## Blog\n\n"
            for item in context.sections[.blog].items {
                out += "- [\(item.title)](\(base)/\(item.path.string).md): \(item.description)\n"
            }
            out += "\n"

            try context.createOutputFile(at: "llms.txt").write(out)
        }
    }

    /// Generate `/llms-full.txt`: every post concatenated into one document.
    static func generateLLMsFullText() -> Self {
        .step(named: "Generate llms-full.txt") { context in
            let site = context.site

            var out = "# \(site.name): full blog content\n\n"
            out += "> \(site.description)\n\n"
            out += "Every post on \(site.url.absoluteString), concatenated. "
            out += "Source: \(site.url.absoluteString)/llms.txt\n"

            for item in context.sections[.blog].items {
                let markdown = try context.file(at: Path("Content/\(item.path.string).md")).readAsString()
                out += "\n\n---\n\n"
                out += markdown
            }

            try context.createOutputFile(at: "llms-full.txt").write(out)
        }
    }
}
