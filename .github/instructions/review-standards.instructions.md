---
description: "Use when performing code reviews, security analysis, vulnerability scanning, or JS anti-pattern detection. Covers severity levels, OWASP/CWE references, output formatting, and remediation patterns."
applyTo: "**/*.js"
---

# Review Standards

## Severity Levels

Use a unified severity scale for all findings:

| Level | Icon | When to use |
|-------|------|-------------|
| CRITICAL | 🔴 | Exploitable vulnerabilities, data loss risk |
| HIGH | 🟠 | Significant weakness, hardcoded secrets, broken auth |
| MEDIUM | 🟡 | Defense-in-depth gaps, missing validation |
| LOW | 🟢 | Best-practice deviations, minor style issues |
| Suggestion | 💡 | Optional improvements, readability tweaks |

## Code Quality Checks

- Enforce naming conventions and consistency
- Flag Single Responsibility Principle violations
- Detect DRY violations — duplicated logic across functions
- Replace magic numbers with named constants
- Require error handling and edge-case coverage
- Flag `console.log` left in production code
- Flag callback nesting deeper than 2 levels
- Require input validation at API boundaries

## JS Anti-Pattern Detection

- `var` → `const` / `let`
- `==` / `!=` → `===` / `!==`
- Callback hell (>2 nested levels) → `async/await`
- Missing `'use strict'`
- `for` loops on arrays → `.map()`, `.filter()`, `.reduce()`
- String concatenation → template literals
- Flag prototype pollution risks

## Security Analysis (OWASP Top 10)

- **A01 Broken Access Control** — missing auth checks, IDOR
- **A02 Cryptographic Failures** — weak hashing (MD5/SHA1), hardcoded keys
- **A03 Injection** — SQL injection, `eval()`, command injection, XSS
- **A04 Insecure Design** — missing rate limiting, no input size limits
- **A05 Security Misconfiguration** — verbose errors, default credentials
- **A06 Vulnerable Components** — outdated dependencies
- **A07 Authentication Failures** — weak password storage, missing MFA
- **A08 Data Integrity Failures** — unsigned data, insecure deserialization
- **A09 Logging Failures** — secrets in logs, missing audit trail
- **A10 SSRF** — unvalidated URLs, internal resource access

Include CWE identifiers (e.g., CWE-89, CWE-79) with every security finding.

## Output Format

Every finding must include:

1. **Line number** — exact location in the file
2. **Severity** — from the scale above
3. **Description** — what's wrong and *why* it matters
4. **Remediation** — before/after code showing the fix

```markdown
### [SEVERITY] Finding Title — CWE-XXX (if security)
**Line:** N | **OWASP:** AXX (if security)

// Before (vulnerable / problematic)
<bad code>

// After (safe / improved)
<fixed code>
```

## Tone

- Be constructive and educational — explain *why*, not just what
- Provide actionable remediation with concrete code fixes
- Group findings by severity, most critical first
