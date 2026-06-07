// =============================================================================
// hello.dart — read balance and print (linked to main.dart)
// =============================================================================
//
// FLOW (when main calls display()):
//
//   display() → print name → print balance → getter reads _accountbalance
//
// SET vs GET:
//   main.dart   account.balance = 500   →  SET (write)
//   hello.dart  print($balance)         →  GET (read)
//
// =============================================================================

part of 'main.dart'; // same program as main.dart — not run alone

// GETTER — when code reads "balance", return hidden _accountbalance
double get balance => account._accountbalance;

void display() {
  print("user name is ${account.name}");
  print("balnce is $balance"); // uses getter above
}
