# Monado

> **Warning**
> This website is still under development.

---

## About

This is an educational website that **explains monads** and **uses them in its own code**. It teaches functional programming concepts through real-world examples.

The site demonstrates the **Maybe monad** and **Result monad** by:

- 🎓 Explaining concepts clearly with visual examples
- 💻 **Showing actual code from THIS website** - before and after monads
- 🔍 Using monads in every controller and function
- 🎮 Providing interactive demos to experiment with
- 📊 Comparing code with and without monads side-by-side

### Key Philosophy

**"Learn by seeing real usage, not toy examples"**

Every example shows:

- ❌ **Before**: Messy code without monads (nested ifs, complex error handling)
- ✅ **After**: Clean code with monads (pipelines, composable functions)
- 💡 **Benefits**: Specific improvements gained
- 📍 **Location**: Actual file in this codebase

## Features Implemented

### Monad Modules

- ✅ **Maybe Monad** (`lib/monado/monad/maybe.ex`)
  - Full implementation with `bind`, `map`, `filter`, `chain`
  - Type-safe optional value handling
  - Comprehensive test coverage

- ✅ **Result Monad** (`lib/monado/monad/result.ex`)
  - Complete error handling without exceptions
  - `map_error` for error transformation
  - Conversion utilities (Maybe ↔ Result)

### Web Pages

- ✅ **Home Page** (`/`) - Overview with example code snippets
- ✅ **Maybe Monad Page** (`/maybe`) - Real-world examples from this codebase
- ✅ **Result Monad Page** (`/result`) - Error handling with actual code
- ✅ **Interactive Demo** (`/demo`) - Try monad operations in real-time
- ✅ **Before/After Page** (`/comparison`) - See dramatic improvements

### Real-World Usage

The controllers (`lib/monado_web/controllers/monad_controller.ex`) **actually use monads**:

- Query parameter validation with Maybe monad
- Error handling with Result monad
- Chained operations for safe data processing
- Filter operations for validation

### Multi-Language Examples

Code samples provided for:

- 🟣 Elixir (with the actual running implementation)
- 🟤 Haskell
- 🟠 Rust  
- 🟡 OCaml
- 🔵 Go

### Goals

- Explain monads in functional programming ✅
- Add examples for it ✅
- Make implementations for the examples in multiple languages (like *Golang*, *Elixir*, *OCaml*, *Rust*, *Haskell*, etc...) ✅
- Use monads in the actual website code ✅
- Provide interactive demos ✅

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

## Project Structure

```
lib/
├── monado/
│   ├── monad/
│   │   ├── maybe.ex          # Maybe monad implementation
│   │   └── result.ex         # Result monad implementation
│   ├── examples.ex           # Multi-language code examples
│   └── ...
├── monado_web/
│   ├── controllers/
│   │   ├── monad_controller.ex     # Controller using monads
│   │   └── monad_html/
│   │       ├── maybe.html.heex     # Maybe monad page
│   │       ├── result.html.heex    # Result monad page
│   │       ├── demo.html.heex      # Interactive demo
│   │       └── comparison.html.heex # Monad comparison
│   └── router.ex             # Routes for all pages
test/
├── monado/
│   └── monad/
│       ├── maybe_test.exs    # Maybe monad tests
│       └── result_test.exs   # Result monad tests
└── ...
```

## Running Tests

```bash
mix test
```

All monad implementations include:

- Unit tests for each function
- Monad law verification tests
- Practical usage examples
- Edge case handling

## Key Implementation Highlights

### Maybe Monad Usage in Controllers

```elixir
def maybe(conn, params) do
  selected_language = 
    params
    |> Map.get("lang", "elixir")
    |> Maybe.return()
    |> Maybe.map(&String.downcase/1)
    |> Maybe.filter(fn lang -> 
         lang in ["elixir", "haskell", "rust", "ocaml", "golang"]
       end)
    |> Maybe.from_maybe("elixir")
  
  render(conn, :maybe, selected_language: selected_language)
end
```

### Result Monad for Validation

```elixir
def process_contact_form(params) do
  params
  |> validate_email()
  |> Result.bind(&validate_message/1)
  |> Result.bind(&save_to_database/1)
  |> Result.map(&send_confirmation_email/1)
end
```

## Learning Path

1. **Start at Home** - Get an overview of monads
2. **Explore Maybe** - Learn optional value handling
3. **Understand Result** - Master error handling
4. **Try the Demo** - Experiment interactively
5. **Compare** - See differences between monads
6. **Read the Code** - Inspect actual implementations
