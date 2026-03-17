---
name: js-antipattern-detection
description: 'Detect JavaScript anti-patterns and suggest modern ES6+ fixes. Use when scanning JS files for: var usage, loose equality (== instead of ===), callback hell deeper than 2 levels, missing use strict in CommonJS, for loops replaceable by map/filter/reduce, string concatenation instead of template literals, and prototype pollution risks from bracket notation on user input.'
argument-hint: 'Provide the file path(s) to scan for JS anti-patterns'
---

# JS Anti-Pattern Detection

Scan JavaScript files for common anti-patterns and produce a severity-sorted findings table with before/after code fixes using modern ES6+ alternatives.

## When to Use

- Reviewing `.js` files for outdated or risky patterns
- Modernizing legacy JavaScript to ES6+
- Detecting prototype pollution risks from untrusted input
- Enforcing strict mode in CommonJS modules

## Anti-Pattern Checklist

### 1. `var` Instead of `let`/`const` — Severity: MEDIUM 🟡

`var` is function-scoped and hoisted, leading to subtle bugs. Use `const` by default, `let` only when reassignment is needed.

**Before:**
```js
var count = 0;
var name = "admin";
```

**After:**
```js
let count = 0;
const name = "admin";
```

### 2. Loose Equality (`==` / `!=`) — Severity: MEDIUM 🟡

Loose equality performs type coercion, producing unexpected results (`0 == ""` is `true`). Always use strict equality.

**Before:**
```js
if (status == "active") { /* ... */ }
if (value != null) { /* ... */ }
```

**After:**
```js
if (status === "active") { /* ... */ }
if (value !== null) { /* ... */ }
```

### 3. Callback Nesting Deeper Than 2 Levels — Severity: HIGH 🟠

Deeply nested callbacks ("callback hell") reduce readability, make error handling fragile, and complicate testing. Refactor to `async/await`.

**Before:**
```js
getUser(id, function (err, user) {
  getOrders(user.id, function (err, orders) {
    getDetails(orders[0].id, function (err, details) {
      // 3 levels deep — hard to read and maintain
      callback(details);
    });
  });
});
```

**After:**
```js
async function getUserOrderDetails(id) {
  const user = await getUser(id);
  const orders = await getOrders(user.id);
  const details = await getDetails(orders[0].id);
  return details;
}
```

### 4. Missing `'use strict'` in CommonJS Modules — Severity: LOW 🟢

CommonJS files without `'use strict'` allow silent errors like assigning to undeclared variables. ES modules enable strict mode automatically, but CommonJS requires an explicit directive.

**Detection rule:** Flag `.js` files that use `require()` or `module.exports` but lack `'use strict'` at the top.

**Before:**
```js
const fs = require("fs");
// missing 'use strict' — silent errors possible
```

**After:**
```js
"use strict";

const fs = require("fs");
```

### 5. `for` Loops Replaceable by `.map()` / `.filter()` / `.reduce()` — Severity: LOW 🟢

Imperative `for` loops that build a new array or accumulate a value are clearer as functional array methods.

**Before:**
```js
const results = [];
for (let i = 0; i < items.length; i++) {
  results.push(items[i].name.toUpperCase());
}
```

**After:**
```js
const results = items.map((item) => item.name.toUpperCase());
```

**Before (filter pattern):**
```js
const active = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].active) {
    active.push(users[i]);
  }
}
```

**After:**
```js
const active = users.filter((user) => user.active);
```

### 6. String Concatenation Instead of Template Literals — Severity: LOW 🟢

String concatenation with `+` is harder to read than template literals, especially with multiple variables or expressions.

**Before:**
```js
const message = "Hello, " + user.name + "! You have " + count + " items.";
const url = baseUrl + "/api/" + version + "/users/" + id;
```

**After:**
```js
const message = `Hello, ${user.name}! You have ${count} items.`;
const url = `${baseUrl}/api/${version}/users/${id}`;
```

### 7. Prototype Pollution via Bracket Notation on User Input — Severity: CRITICAL 🔴

Using bracket notation with unsanitized user input to set object properties allows attackers to inject `__proto__`, `constructor`, or `prototype` keys, polluting the object prototype chain.

**CWE:** CWE-1321 (Improperly Controlled Modification of Object Prototype Attributes)

**Before:**
```js
function setProperty(obj, key, value) {
  obj[key] = value; // key from user input — prototype pollution risk
}
```

**After:**
```js
function setProperty(obj, key, value) {
  if (["__proto__", "constructor", "prototype"].includes(key)) {
    throw new Error("Invalid property name");
  }
  if (!Object.prototype.hasOwnProperty.call(obj, key)) {
    throw new Error("Property does not exist");
  }
  obj[key] = value;
}
```

**Alternative — use `Map` for dynamic keys from user input:**
```js
const store = new Map();
store.set(key, value);
```

## Procedure

1. **Read the target file(s)** using search and read tools
2. **Scan for each anti-pattern** in the checklist above
3. **Record each finding** with exact file path, line number, and severity
4. **Generate the findings table** sorted by severity (CRITICAL → HIGH → MEDIUM → LOW → Suggestion)
5. **Provide before/after fixes** for every finding

## Output Format

```markdown
## JS Anti-Pattern Report

### Summary
- Files scanned: N
- Total findings: N
- Critical: N | High: N | Medium: N | Low: N | Suggestions: N

### Findings Table

| # | Severity | Anti-Pattern | File:Line | Modern Alternative |
|---|----------|-------------|-----------|-------------------|
| 1 | 🔴 CRITICAL | Prototype pollution via bracket notation | file.js:42 | Allowlist keys or use Map |
| 2 | 🟠 HIGH | Callback hell (3 levels deep) | file.js:87-102 | async/await |
| 3 | 🟡 MEDIUM | var declaration | file.js:5 | const |
| 4 | 🟡 MEDIUM | Loose equality (==) | file.js:22 | === |
| 5 | 🟢 LOW | for loop → .map() | file.js:33-37 | Array.map() |
| 6 | 🟢 LOW | String concatenation | file.js:15 | Template literals |
| 7 | 🟢 LOW | Missing 'use strict' | file.js:1 | Add "use strict" |

### Detailed Findings

#### [🔴 CRITICAL] Prototype Pollution — CWE-1321
**File:** file.js, Line 42

**Description:** User-controlled key used in bracket notation to set
object properties, allowing __proto__ injection.

**Before:**
\```js
obj[userInput] = value;
\```

**After:**
\```js
if (["__proto__", "constructor", "prototype"].includes(userInput)) {
  throw new Error("Invalid property name");
}
obj[userInput] = value;
\```
```

Sort all findings by severity: CRITICAL → HIGH → MEDIUM → LOW → Suggestion. Within the same severity, order by line number (ascending).
