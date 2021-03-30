# viper
An amalgamation of our favourite programming language traits

See misc/proposal.md for more details

## Samples
Code samples for common Viper programs may be found under `examples/`

## Testing
Viper runs integration tests in order to ensure that nothing's horribly broken.

### Running Tests
* `./runtests.sh` for a general overview of LLVM tests
* `./runtests.sh -t ast` for tests that specifically check AST generation
* `./runtests.sh -v 1` for verbose outputs

### Case Creation
* Create a new test case in `test/tests`
* Create a corresponding output file in `test/tests` as well. For example, if your case is `testo.vp`, your output file for the same would be `testo.vp.out`
* If these steps are correctly implemented, then `runtests.sh` should pick your test and the output case up, and compare the two. Empty outputs are permitted, and are represented by an empty `.out` file.
