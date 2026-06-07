# 01. OOP & Encapsulation (Bank Management System)

A reference implementation demonstrating **library-level encapsulation**, **controlled mutation**, and **read/write separation** in Dart — structured for mobile-grade modularity using `part` / `part of`.

| Module | Role |
|--------|------|
| `main.dart` | Domain model, I/O orchestration, mutation via setter |
| `hello.dart` | Read-side projection & presentation (`display`) |

```bash
dart run main.dart
```

---

## 📌 Architectural Overview

In Dart, **`import` creates a library boundary**. Any identifier prefixed with `_` is **library-private** — invisible to other libraries, even if they import the declaring file. That is correct for encapsulation, but it forces a trade-off: a separate presentation file cannot observe private domain state without either **widening the public API** (public fields/getters) or **merging everything into one monolithic source file**.

This module resolves that trade-off with **`part` / `part of`**, which splits source across files while compiling to a **single library unit**.

```
┌─────────────────────────────────────────────────────────┐
│  Library: main.dart                                     │
│  ┌─────────────────────┐    ┌─────────────────────────┐ │
│  │  main.dart (root)   │    │  hello.dart (part)      │ │
│  │  • bankaccount      │    │  • balance getter       │ │
│  │  • _accountbalance  │◄───│  • display()            │ │
│  │  • setter (write)   │    │  (read / present)       │ │
│  └─────────────────────┘    └─────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
         ▲                              ▲
    part 'hello.dart'            part of 'main.dart'
```

**Why this matters in modular mobile systems**

| Approach | Cross-file `_` visibility | API surface | Typical use |
|----------|---------------------------|-------------|-------------|
| `import` | ❌ Blocked | Must expose public accessors | Inter-package boundaries |
| `part` / `part of` | ✅ Shared within one library | Keeps internals private to the module | Intra-module file splits |

For a banking feature slice inside a Flutter app (e.g. `features/accounts/domain/`), `part` allows **physical separation of concerns** — domain mutation in one file, UI-adjacent read logic in another — **without publishing `_accountbalance` as a public contract**. External modules still interact through the library's public API; internal parts collaborate on encapsulated state.

This is deliberately **not** a substitute for package-level boundaries (`import` remains correct between features). It is an **intra-library composition pattern**: one cohesive module, multiple maintainable files, zero leakage of private identifiers across library borders.

---

## 🛠️ Data Integrity & Encapsulation Mechanisms

### Private state as the single source of truth

`_accountbalance` is the authoritative balance store. It is **not directly assignable** from consumer code. All writes funnel through the `balance` setter — a deliberate **mutation choke point**.

```dart
double _accountbalance = 0.0;  // library-private; not part of the public contract

set balance(double amount) {
  if (amount > 0) {
    _accountbalance += amount;
  } else {
    print("invalid");
  }
}
```

### Guard clauses & invariant enforcement

| Threat | Mechanism | Outcome |
|--------|-----------|---------|
| Negative or zero deposit | Setter guard (`amount > 0`) | Mutation rejected; balance unchanged |
| Malformed user input | `double.tryParse` at I/O boundary | Non-numeric strings never reach the domain layer |
| Null stdin (EOF) | `readLineSync()?.trim()` | Null-safe chain; no runtime throw on `.trim()` |
| Uncontrolled direct writes | Private `_accountbalance` | External libraries cannot bypass the setter |

The **write path** (main) and **read path** (hello) are asymmetric by design — a pattern aligned with real banking systems where **commands** (credit/debit) and **queries** (balance inquiry) follow different pipelines.

```dart
// hello.dart — read-only projection; no mutation path from presentation
double get balance => account._accountbalance;
```

The getter exposes a **read snapshot** without granting write access. Extending this module with withdrawals would add a dedicated debit path with its own guards (e.g. insufficient-funds check against `_accountbalance`) — the encapsulation model already constrains *where* that logic must live.

### Null-safety at the system edge

User input is the highest-entropy layer. Parsing and null-handling occur **before** domain mutation:

```dart
var input = stdin.readLineSync()?.trim();
final amount = double.tryParse(input);
if (amount == null) { /* reject at boundary */ }
account.balance = amount;  // domain receives only validated numerics
```

This **fail-fast at the perimeter** approach prevents ambiguous defaults (e.g. coercing parse failures to `0.0`) from silently triggering domain rejection or corrupting invariants.

---

## 💼 Technical Interview Q&A (Senior Mobile Level)

### Q1. You used `part` / `part of` so `hello.dart` can read `_accountbalance`. Why not expose a public `double get balance` on `bankaccount` and use a normal `import` — isn't that cleaner?

**Answer:** A public getter on the domain class is valid and often preferred at **package boundaries**. The `part` pattern is chosen here to demonstrate **intra-library modularity**: file-level separation without expanding the **published API surface**.

Once `balance` is a public getter on `bankaccount`, every consumer of that class — repositories, serializers, test fakes, analytics hooks — can depend on it. That coupling is fine when balance read access *is* the contract. When presentation is an **internal concern** of the same feature module, a top-level read projection in a `part` file keeps the class API minimal (write via setter only) while still allowing controlled observation of library-private state.

In a Swedish product engineering context, the decision reduces to: **Is balance read part of the module's external contract, or an internal implementation detail?** `import` + public getter = external contract. `part` + private field = internal collaboration. Production Flutter codebases typically use `import` between features and reserve `part` for generated code (`.g.dart`, `.freezed.dart`) or tightly scoped internal splits — but the encapsulation principle is identical.

---

### Q2. In Dart, `_accountbalance` is private to the library, not the class. How does that differ from Java or Kotlin visibility, and what bug class does your setter-centric design prevent in a concurrent mobile app?

**Answer:** Dart has **library-private** visibility (`_`), not class-private. Any code in the same library — including other classes in other part files — can access `_accountbalance`. Privacy is enforced at the **compilation unit** (library), not the OOP instance boundary. This differs from Java's `private` fields, which are class-scoped regardless of file placement (within one package).

The banking-relevant implication: **encapsulation is a library design decision**, not merely a class decorator. Splitting one library across `part` files shares private state intentionally; splitting into separate libraries via `import` hardens that boundary.

The setter-centric model mitigates the ** invariant bypass** bug class: any code path that could assign `_accountbalance` directly would skip validation (negative amounts, future overdraft rules, audit logging, currency rounding). Centralising mutation in the setter creates a single **policy enforcement point** — the same rationale behind repository/command layers in Clean Architecture on mobile. In concurrent scenarios, the next evolution would wrap `_accountbalance` mutation in an isolate, database transaction, or synchronised bloc/cubit reducer — but the guard clause remains authoritative; parallelism changes *how* you call the setter, not *whether* validation runs.

---

<p align="center">
  <sub>Part of <strong>dart-core-architecture</strong> — structured Dart patterns for production mobile systems.</sub>
</p>
