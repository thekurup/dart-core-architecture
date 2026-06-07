// =============================================================================
// main.dart — program starts here
// =============================================================================
//
// FLOW:
//   [1] run: dart run main.dart
//   [2] loop: user enters amount → adds to balance
//   [3] type "done" → stop loop
//   [4] hello.dart prints name + balance (getter)
//
//   main.dart  ──part──►  hello.dart   (two files, one program)
//
// =============================================================================

import 'dart:io'; // keyboard input (stdin)

// Connect hello.dart to this file — needed so hello can read _accountbalance
part 'hello.dart';

class bankaccount {
  String? name; // account holder name

  // _ prefix = private (hidden). Only this file + hello.dart can see it
  double _accountbalance = 0.0;

  bankaccount(this.name); // create account with a name

  // SETTER — runs when you write: account.balance = amount
  set balance(double amount) {
    if (amount > 0) {
      _accountbalance += amount; // add to existing balance
    } else {
      print("invalid"); // zero or negative not allowed
    }
  }
}

final account = bankaccount("arjun"); // one account used by both files

void main() {
  while (true) {
    // keep asking until user types "done"
    stdout.write("\nenter the amount (type done to finish): ");

    // ?. = if readLineSync() is null, skip trim (null-safe)
    var input = stdin.readLineSync()?.trim();

    if (input == null || input.toLowerCase() == "done") {
      break; // exit loop
    }

    final amount = double.tryParse(input); // text → number
    if (amount == null) {
      print("not a number — try again");
      continue; // skip this round, ask again
    }

    account.balance = amount; // SET — goes to setter above
  }
  display(); // print result — code lives in hello.dart
}
