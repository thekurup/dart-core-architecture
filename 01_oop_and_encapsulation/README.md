# 01. OOP & Encapsulation (Advanced Bank Management)

This project shows how to use Encapsulation and multi-file code splitting using `part` and `part of` in Dart.

---

## Summary 

If you are new to Dart, here is a simple breakdown of what this project does:
1. **Security (`_` Private Variable):** We made the bank balance private (`_accountbalance`). This means no one can accidentally change the balance from outside without typing a valid amount.
2. **Validation (The Guard):** If someone tries to deposit a negative amount or enters text instead of numbers, our code catches it immediately and says "Invalid".
3. **Code Splitting (`part` & `part of`):** Instead of writing a massive file, we split our code into two files: `main.dart` and `hello.dart`. Because they are linked as "parts", they can still share private data safely without exposing it to the entire application.

---

## 🛠️ Data Integrity & Encapsulation Mechanisms

### 1. Keeping the Balance Safe (Encapsulation)
The `_accountbalance` field is made private. The system stops anyone from changing the balance directly from outside.
* **Read Balance:** Anyone can see the balance, but they cannot rewrite it directly.
* **Change Balance:** If we want to add a withdraw feature later, we will write a separate function with safety checks (like checking if there is enough money in the account).

### 2. Checking Inputs Early (Null-Safety)
User input can sometimes be wrong or empty. We check and validate the input **before** making any changes to the account:

```dart
var input = stdin.readLineSync()?.trim();
final amount = double.tryParse(input);

if (amount == null) { 
  /* Reject immediately if it is not a valid number */ 
}

account.balance = amount;  // Only valid numbers are sent to the account
