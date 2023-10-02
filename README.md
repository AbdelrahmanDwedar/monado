# Monado

> **Warning**
> This website is still under development.

---

## About

This is a simple website that explains monads and their applications like *maybe monad*.

The target is to make people familiar with monads and be able to understand their cases and be able to apply them as well with any functional language.

### Gaols
- Explain monads in functional programming
- Add examples for it
- Make implementations for the examples in multiple languages (like *Golang*, *Elixir*, *OCaml*, *Rust*, *Haskell*, etc...)

### Non-goals
- Making a code editor for people to try code samples

---

## Contribution

Every new PR needs to have an issue to explain the problem or feature it's going to implement, and for the PR description you add all the implementation details and how you solved the problem, etc...

- Clone the repository
- Create a new branch for the feature or fix you will add
- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`  
  Now you can visit [`localhost:4000`](http://localhost:4000) from your browser
- Make your changes to the branch you made
- Make the PR with a descriptive name following the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/)  
  E.x.
  ```gitcommit
  feat(maybe monad): add the just atom
  ```

Make sure if you're adding a feature to add the tests for it.
