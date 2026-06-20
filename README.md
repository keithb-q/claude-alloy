# claude-alloy
Demonstrating use of Claude Code with Alloy 6

## Disclaimer

This project is a **demonstration and educational resource** showing how Claude Code
(Anthropic's AI-assisted development tool) can be used alongside Alloy 6 for
formal specification and iterative software development. It is not production software.

**AI-generated content.** Substantial portions of the code, formal specifications,
tests, and documentation in this repository were generated or co-authored by Claude
(Anthropic). AI-generated content may contain errors, omissions, or subtleties that
have not been fully reviewed by a human. Do not rely on any part of this project
without independent verification appropriate to your use case.

**Bounded formal verification.** The Alloy 6 models in `specification/alloy/` have
been checked only within small, finite scopes (typically `for 4`). Alloy's
small-scope hypothesis gives confidence that errors would be found in small instances,
but a clean check result within a given scope is not a proof of correctness for all
possible inputs or system states. No claim of full formal verification is made.

**Integer arithmetic in Alloy.** This project encountered a non-obvious pitfall: the
`-` operator between two `sum` expressions in Alloy is parsed as set difference, not
integer subtraction. Integer subtraction requires the built-in `minus[a, b]` form.
Users adapting the Alloy models here should be aware of this behaviour.

**No warranty.** This software and all associated artefacts are provided "as is",
without warranty of any kind, express or implied, including but not limited to the
warranties of merchantability, fitness for a particular purpose, and non-infringement.
In no event shall the authors or copyright holders be liable for any claim, damages,
or other liability, whether in an action of contract, tort, or otherwise, arising
from, out of, or in connection with the software or the use or other dealings in the
software.

**Not professional advice.** Nothing in this repository constitutes professional
engineering, legal, security, or architectural advice.

---

## Licence

This project is released under the **GNU General Public License v3.0** (GPL-3.0).
See the [LICENSE](LICENSE) file for the full text.

### Third-party licences

This project depends on, or makes use of, the following third-party tools and
libraries. Their licences apply to their respective components and are not altered
by the GPL-3.0 licence of this project.

| Component | Role | Licence |
| --- | --- | --- |
| [Alloy 6 / alloytools](https://github.com/AlloyTools/org.alloytools.alloy) | Formal specification analyser | MIT |
| [Claude Code](https://claude.ai/code) (Anthropic) | AI-assisted development tool | Proprietary — [Anthropic Terms of Service](https://www.anthropic.com/legal/consumer-terms) |
| [Express](https://expressjs.com) | HTTP server framework | MIT |
| [cors](https://github.com/expressjs/cors) | Express CORS middleware | MIT |
| [Playwright](https://playwright.dev) | End-to-end test framework | Apache-2.0 |
| [concurrently](https://github.com/open-cli-tools/concurrently) | Run npm scripts in parallel | MIT |
| [IntelliJ Platform Plugin SDK](https://plugins.jetbrains.com/docs/intellij/intellij-platform.html) | IDE plugin development API | Apache-2.0 |
| [Kotlin](https://kotlinlang.org) | Plugin implementation language | Apache-2.0 |
| [Gradle](https://gradle.org) | Build tool | Apache-2.0 |
| [Node.js](https://nodejs.org) | JavaScript runtime | MIT |

Licence texts for third-party components are available in their respective upstream
repositories. This list is provided for informational purposes and may not be
exhaustive — refer to each component's own licence file for authoritative terms.
