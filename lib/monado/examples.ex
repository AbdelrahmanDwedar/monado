defmodule Monado.Examples do
  @moduledoc """
  Real-world code examples from this very website!
  
  This module showcases actual monad usage in the Monado application,
  demonstrating how monads solve real problems in production code.
  """

  @doc """
  Returns real code examples from the Monado website showing how we use the Maybe monad.
  """
  def maybe_real_world_examples do
    [
      %{
        title: "Language Parameter Validation",
        location: "MonadoWeb.MonadController.maybe/2",
        problem: "User can pass any language via URL param, including invalid ones. We need to safely handle this without crashes.",
        without_monad: ~S"""
        # ❌ Traditional approach - lots of nested checks
        def maybe(conn, params) do
          lang = Map.get(params, "lang", "elixir")
          
          if lang != nil do
            lower = String.downcase(lang)
            if lower in ["elixir", "haskell", "rust", "ocaml", "golang"] do
              selected = lower
            else
              selected = "elixir"
            end
          else
            selected = "elixir"
          end
          
          render(conn, :maybe, selected_language: selected)
        end
        """,
        with_monad: ~S"""
        # ✅ With Maybe monad - clean, composable pipeline
        def maybe(conn, params) do
          selected_language = 
            params
            |> Map.get("lang", "elixir")      # Get param or default
            |> Maybe.return()                  # Wrap in Maybe context
            |> Maybe.map(&String.downcase/1)   # Transform safely
            |> Maybe.filter(fn lang ->         # Validate
                 lang in ["elixir", "haskell", "rust", "ocaml", "golang"]
               end)
            |> Maybe.from_maybe("elixir")      # Extract with fallback
          
          render(conn, :maybe, selected_language: selected_language)
        end
        """,
        benefits: [
          "No nested if statements",
          "Clear data transformation pipeline",
          "Each step is independent and testable",
          "Impossible to forget the nil case - handled by monad",
          "Easy to add more validation steps"
        ]
      },
      %{
        title: "Safe Number Parsing in Demo",
        location: "MonadoWeb.MonadController.parse_number_demo/1",
        problem: "User input might not be a valid number. Need to parse and transform safely.",
        without_monad: ~S"""
        # ❌ Traditional approach with exceptions or nil checks
        defp parse_number_demo(input) do
          trimmed = String.trim(input)
          
          case Integer.parse(trimmed) do
            {num, ""} -> 
              doubled = num * 2
              {:success, doubled}
            _ -> 
              {:error, "Not a number"}
          end
        end
        """,
        with_monad: ~S"""
        # ✅ With Maybe monad - declarative and safe
        defp parse_number_demo(input) do
          result = 
            input
            |> String.trim()
            |> parse_integer()           # Returns Maybe
            |> Maybe.map(fn n -> n * 2 end)
          
          case result do
            {:just, value} -> {:success, value}
            :nothing -> {:error, "Not a number"}
          end
        end
        
        defp parse_integer(str) do
          case Integer.parse(str) do
            {num, ""} -> {:just, num}
            _ -> :nothing
          end
        end
        """,
        benefits: [
          "Separation of concerns - parsing vs. transformation",
          "Can chain more operations easily",
          "Clear intent: this might not succeed",
          "No exception handling needed"
        ]
      },
      %{
        title: "Validation Chain",
        location: "MonadoWeb.MonadController.chain_demo/1",
        problem: "Need to validate input through multiple steps. Should stop at first failure.",
        without_monad: ~S"""
        # ❌ Traditional approach - nested conditions
        defp chain_demo(input) do
          case parse_int(input) do
            {:ok, n} ->
              if n > 0 do
                if n < 100 do
                  doubled = n * 2
                  {:success, doubled}
                else
                  {:error, "Number too large"}
                end
              else
                {:error, "Not positive"}
              end
            :error ->
              {:error, "Not a number"}
          end
        end
        """,
        with_monad: ~S"""
        # ✅ With Maybe monad - linear pipeline
        defp chain_demo(input) do
          result = 
            input
            |> String.trim()
            |> parse_integer()                    # Maybe
            |> Maybe.bind(&validate_positive/1)   # Chain: stops if :nothing
            |> Maybe.bind(&validate_less_than_100/1)
            |> Maybe.map(fn n -> n * 2 end)
          
          case result do
            {:just, value} -> {:success, value}
            :nothing -> {:error, "Validation failed"}
          end
        end
        
        defp validate_positive(n) when n > 0, do: {:just, n}
        defp validate_positive(_), do: :nothing
        
        defp validate_less_than_100(n) when n < 100, do: {:just, n}
        defp validate_less_than_100(_), do: :nothing
        """,
        benefits: [
          "Linear flow - easy to read top to bottom",
          "Automatically stops at first Nothing",
          "Easy to add/remove validation steps",
          "Each validator is pure and testable",
          "No deeply nested conditionals"
        ]
      }
    ]
  end

  @doc """
  Returns real code examples from the Monado website showing how we use the Result monad.
  """
  def result_real_world_examples do
    [
      %{
        title: "Parameter Validation with Error Context",
        location: "MonadoWeb.MonadController.result/2",
        problem: "Need to validate request parameters and provide specific error messages.",
        without_monad: ~S"""
        # ❌ Traditional approach - exception-based or complex returns
        def result(conn, params) do
          try do
            if is_map(params) do
              case Map.get(params, "lang") do
                nil -> 
                  raise "Language not specified"
                "" -> 
                  raise "Language cannot be empty"
                lang -> 
                  selected = String.downcase(lang)
                  render(conn, :result, selected_language: selected)
              end
            else
              raise "Invalid parameters"
            end
          rescue
            e -> 
              conn
              |> put_status(:bad_request)
              |> render(:error, message: e.message)
          end
        end
        """,
        with_monad: ~S"""
        # ✅ With Result monad - explicit error handling
        def result(conn, params) do
          result = 
            params
            |> validate_params()           # Returns Result
            |> Result.bind(&get_language/1)
            |> Result.map(&String.downcase/1)
          
          selected = Result.from_result(result, "elixir")
          render(conn, :result, selected_language: selected)
        end
        
        defp validate_params(params) when is_map(params), do: {:ok, params}
        defp validate_params(_), do: {:error, "Invalid parameters"}
        
        defp get_language(params) do
          case Map.get(params, "lang") do
            nil -> {:error, "Language not specified"}
            "" -> {:error, "Language cannot be empty"}
            lang -> {:ok, lang}
          end
        end
        """,
        benefits: [
          "No exceptions - errors are values",
          "Specific error messages for each failure",
          "Type-safe error handling",
          "Easy to test each validation step",
          "Clear separation: happy path vs. error path"
        ]
      },
      %{
        title: "Safe Division in Demo",
        location: "MonadoWeb.MonadController.safe_divide_demo/1",
        problem: "Division by zero must be handled. User needs to know what went wrong.",
        without_monad: ~S"""
        # ❌ Traditional approach
        defp safe_divide_demo(input) do
          parts = String.split(input, ",")
          
          if length(parts) == 2 do
            try do
              a = String.to_float(Enum.at(parts, 0))
              b = String.to_float(Enum.at(parts, 1))
              
              if b == 0 do
                {:error, "Cannot divide by zero"}
              else
                {:success, a / b}
              end
            rescue
              _ -> {:error, "Invalid numbers"}
            end
          else
            {:error, "Need exactly 2 numbers"}
          end
        end
        """,
        with_monad: ~S"""
        # ✅ With Result monad
        defp safe_divide_demo(input) do
          result = 
            input
            |> parse_numbers()              # Result monad
            |> Result.bind(fn [a, b] -> 
                 safe_divide(a, b)
               end)
          
          case result do
            {:ok, value} -> {:success, value}
            {:error, reason} -> {:error, reason}
          end
        end
        
        defp parse_numbers(input) do
          # Returns {:ok, [a, b]} or {:error, specific_reason}
          # ... parsing logic with detailed errors
        end
        
        defp safe_divide(_, 0.0), do: {:error, "Cannot divide by zero"}
        defp safe_divide(a, b), do: {:ok, a / b}
        """,
        benefits: [
          "Every error has context - we know WHY it failed",
          "No exceptions thrown",
          "Composable error handling",
          "Each function returns Result - consistent interface"
        ]
      },
      %{
        title: "Form Processing Pipeline",
        location: "Example for contact forms or user input",
        problem: "Process multi-step form validation where any step can fail.",
        with_monad: ~S"""
        # ✅ Real-world form processing with Result monad
        def process_contact_form(params) do
          params
          |> validate_email()                    # {:ok, params} or {:error, reason}
          |> Result.bind(&validate_message/1)    # Chain validations
          |> Result.bind(&check_spam/1)
          |> Result.bind(&save_to_database/1)
          |> Result.map(&send_confirmation/1)
          |> case do
               {:ok, _} -> 
                 {:success, "Form submitted successfully"}
               {:error, reason} -> 
                 {:error, "Submission failed: #{reason}"}
             end
        end
        
        defp validate_email(%{"email" => email} = params) do
          if String.contains?(email, "@") do
            {:ok, params}
          else
            {:error, "Invalid email format"}
          end
        end
        defp validate_email(_), do: {:error, "Email is required"}
        
        defp validate_message(%{"message" => msg} = params) do
          if String.length(msg) >= 10 do
            {:ok, params}
          else
            {:error, "Message too short (min 10 characters)"}
          end
        end
        """,
        benefits: [
          "Pipeline stops at first error",
          "User gets specific error message",
          "Easy to add/remove validation steps",
          "Each validator is independent",
          "No try-catch blocks needed"
        ]
      }
    ]
  end

  @doc """
  Comparison: Solving the same problem with and without monads
  """
  def before_after_comparison do
    %{
      scenario: "User Search and Profile Update",
      without_monads: ~S"""
      # ❌ Without monads - defensive coding, many checks
      def update_user_email(user_id, new_email) do
        user = Repo.get(User, user_id)
        
        if user != nil do
          if String.contains?(new_email, "@") do
            if String.length(new_email) <= 100 do
              case Repo.update(user, %{email: new_email}) do
                {:ok, updated_user} ->
                  case send_verification_email(updated_user) do
                    :ok -> {:ok, "Email updated"}
                    :error -> {:error, "Failed to send email"}
                  end
                {:error, changeset} ->
                  {:error, "Database error"}
              end
            else
              {:error, "Email too long"}
            end
          else
            {:error, "Invalid email"}
          end
        else
          {:error, "User not found"}
        end
      end
      """,
      with_monads: ~S"""
      # ✅ With monads - clean pipeline
      def update_user_email(user_id, new_email) do
        user_id
        |> find_user()                        # Result monad
        |> Result.bind(&validate_email(&1, new_email))
        |> Result.bind(&update_email/1)
        |> Result.bind(&send_verification/1)
        |> Result.map(fn _ -> "Email updated" end)
      end
      
      defp find_user(id) do
        case Repo.get(User, id) do
          nil -> {:error, "User not found"}
          user -> {:ok, user}
        end
      end
      
      defp validate_email(user, email) do
        cond do
          not String.contains?(email, "@") ->
            {:error, "Invalid email"}
          String.length(email) > 100 ->
            {:error, "Email too long"}
          true ->
            {:ok, {user, email}}
        end
      end
      
      defp update_email({user, email}) do
        case Repo.update(user, %{email: email}) do
          {:ok, user} -> {:ok, user}
          {:error, _} -> {:error, "Database error"}
        end
      end
      
      defp send_verification(user) do
        case send_verification_email(user) do
          :ok -> {:ok, user}
          :error -> {:error, "Failed to send email"}
        end
      end
      """,
      improvements: [
        "Reduced nesting from 6 levels to 1",
        "Each function has single responsibility",
        "Clear error messages at each step",
        "Easy to test each function independently",
        "Pipeline reads like natural language",
        "Adding new steps is trivial"
      ]
    }
  end
end
