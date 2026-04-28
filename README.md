# Adam's Web Site

My personal web site.

[https://adam-young.co.uk](https://adam-young.co.uk)

Built with [Publish](https://github.com/JohnSundell/Publish), John Sundell's Swift static site generator. Hosted on GitHub Pages.

## Development

### Build the site

```bash
swift run AdamYoungSite
```

The generated site is written to `Output/`.

### Preview locally

```bash
swift run AdamYoungSite && python3 -m http.server -d Output 8080
```

Then open <http://localhost:8080/>.

### Update dependencies

```bash
swift package update
```
