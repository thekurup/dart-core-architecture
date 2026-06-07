# 01. OOP & Encapsulation (Advanced Bank Management)

This module demonstrates advanced encapsulation, intra-library state distribution using `part`/`part of`, and strict domain boundary validation in Dart.

---

## 👶 Beginner-Friendly Summary (ലളിതമായി പറഞ്ഞാൽ)

If you are new to Dart, here is a simple breakdown of what this project does:
1. **Security (`_` Private Variable):** We made the bank balance private (`_accountbalance`). This means no one can accidentally change the balance from outside without typing a valid amount.
2. **Validation (The Guard):** If someone tries to deposit a negative amount or enters text instead of numbers, our code catches it immediately and says "Invalid".
3. **Code Splitting (`part` & `part of`):** Instead of writing a massive file, we split our code into two files: `main.dart` and `hello.dart`. Because they are linked as "parts", they can still share private data safely without exposing it to the entire application.

---

## 🛠️ Data Integrity & Encapsulation Mechanisms

### 1. Controlled Mutation Paths
The `_accountbalance` field is strictly encapsulated. The system prevents direct external modification, ensuring that state changes can only happen through authorised business logic.

* **Read Access:** The getter exposes a **read snapshot** without granting write access.
* **Write Access:** Regulated via dedicated setters. Extending this module with withdrawals would add a dedicated debit path with its own guards (e.g., insufficient-funds check against `_accountbalance`). The encapsulation model constrains *where* that logic must live.

### 2. Null-Safety at the System Edge
User input is the highest-entropy layer in any mobile application. Parsing and null-handling occur **before** domain mutation to ensure data safety:

```dart
var input = stdin.readLineSync()?.trim();
final amount = double.tryParse(input);

if (amount == null) { 
  /* Reject immediately at the boundary */ 
}

account.balance = amount;  // Domain receives ONLY validated numerics
