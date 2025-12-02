defmodule MonadoWeb.MonadController do
  use MonadoWeb, :controller
  
  alias Monado.Monad.{Maybe, Result}
  alias Monado.Examples

  @doc """
  Shows the Maybe monad explanation page.
  
  This controller itself uses the Maybe monad to safely handle
  optional query parameters!
  """
  def maybe(conn, params) do
    # Use Maybe monad to handle optional language parameter
    selected_language = 
      params
      |> Map.get("lang", "elixir")
      |> Maybe.return()
      |> Maybe.map(&String.downcase/1)
      |> Maybe.filter(fn lang -> 
        lang in ["elixir", "haskell", "rust", "ocaml", "golang"]
      end)
      |> Maybe.from_maybe("elixir")
    
    examples = Examples.maybe_real_world_examples()
    
    render(conn, :maybe,
      examples: examples,
      selected_language: selected_language
    )
  end

  @doc """
  Shows the Result monad explanation page.
  
  This controller uses the Result monad for error handling!
  """
  def result(conn, params) do
    # Use Result monad to validate and process parameters
    result = 
      params
      |> validate_params()
      |> Result.bind(&get_language/1)
      |> Result.map(&String.downcase/1)
    
    selected_language = Result.from_result(result, "elixir")
    examples = Examples.result_real_world_examples()
    
    render(conn, :result,
      examples: examples,
      selected_language: selected_language
    )
  end

  @doc """
  Interactive demo page where users can try monad operations.
  
  Uses both Maybe and Result monads to process user input safely!
  """
  def demo(conn, params) do
    demo_result = process_demo_input(params)
    
    render(conn, :demo,
      input: Map.get(params, "input", ""),
      operation: Map.get(params, "operation", ""),
      result: demo_result
    )
  end

  @doc """
  Shows a comparison of different monads.
  """
  def comparison(conn, _params) do
    before_after = Examples.before_after_comparison()
    render(conn, :comparison, before_after: before_after)
  end

  # Private helper functions that use monads

  defp validate_params(params) when is_map(params) do
    {:ok, params}
  end
  defp validate_params(_), do: {:error, "Invalid parameters"}

  defp get_language(params) do
    case Map.get(params, "lang") do
      nil -> {:error, "Language not specified"}
      "" -> {:error, "Language cannot be empty"}
      lang -> {:ok, lang}
    end
  end

  @doc """
  Process demo input using monads - this is used in the interactive demo!
  """
  def process_demo_input(%{"input" => input, "operation" => operation}) 
      when input != "" and operation != "" do
    
    case operation do
      "safe_divide" -> safe_divide_demo(input)
      "parse_number" -> parse_number_demo(input)
      "chain" -> chain_demo(input)
      _ -> %{type: :error, message: "Unknown operation"}
    end
  end
  def process_demo_input(_), do: nil

  # Demo operations using monads

  defp safe_divide_demo(input) do
    result = 
      input
      |> parse_numbers()
      |> Result.bind(fn [a, b] -> safe_divide(a, b) end)
    
    case result do
      {:ok, value} -> 
        %{
          type: :success,
          message: "Result: #{value}",
          steps: [
            "Parsed input: #{input}",
            "Performed division",
            "Returned result wrapped in Result monad"
          ]
        }
      {:error, reason} -> 
        %{
          type: :error,
          message: reason,
          steps: [
            "Parsed input: #{input}",
            "Error occurred: #{reason}",
            "Returned error wrapped in Result monad"
          ]
        }
    end
  end

  defp parse_number_demo(input) do
    result = 
      input
      |> String.trim()
      |> parse_integer()
      |> Maybe.map(fn n -> n * 2 end)
    
    case result do
      {:just, value} ->
        %{
          type: :success,
          message: "Parsed and doubled: #{value}",
          steps: [
            "Input: '#{input}'",
            "Parsed to integer using Maybe monad",
            "Doubled the value using Maybe.map",
            "Result: {:just, #{value}}"
          ]
        }
      :nothing ->
        %{
          type: :error,
          message: "Could not parse '#{input}' as a number",
          steps: [
            "Input: '#{input}'",
            "Failed to parse as integer",
            "Returned :nothing from Maybe monad"
          ]
        }
    end
  end

  defp chain_demo(input) do
    result = 
      input
      |> String.trim()
      |> parse_integer()
      |> Maybe.bind(fn n -> validate_positive(n) end)
      |> Maybe.bind(fn n -> validate_less_than_100(n) end)
      |> Maybe.map(fn n -> n * 2 end)
    
    case result do
      {:just, value} ->
        %{
          type: :success,
          message: "Valid! Result: #{value}",
          steps: [
            "1. Parsed '#{input}' as integer ✓",
            "2. Validated number is positive ✓",
            "3. Validated number is less than 100 ✓",
            "4. Doubled the value ✓",
            "Final result: {:just, #{value}}"
          ]
        }
      :nothing ->
        %{
          type: :error,
          message: "Validation failed",
          steps: get_chain_error_steps(input)
        }
    end
  end

  defp get_chain_error_steps(input) do
    case parse_integer(String.trim(input)) do
      :nothing -> 
        ["1. Failed to parse '#{input}' as integer ✗", "Chain stopped at first :nothing"]
      {:just, n} when n <= 0 ->
        ["1. Parsed to #{n} ✓", "2. Failed: number is not positive ✗", "Chain stopped"]
      {:just, n} when n >= 100 ->
        ["1. Parsed to #{n} ✓", "2. Validated positive ✓", "3. Failed: number >= 100 ✗", "Chain stopped"]
      _ ->
        ["Unknown error in chain"]
    end
  end

  # Helper functions using monads

  defp parse_numbers(input) do
    parts = String.split(input, ",")
    
    if length(parts) == 2 do
      case Enum.map(parts, fn s -> 
        case Float.parse(String.trim(s)) do
          {num, _} -> {:ok, num}
          :error -> {:error, "Invalid number: #{s}"}
        end
      end) do
        [{:ok, a}, {:ok, b}] -> {:ok, [a, b]}
        [{:error, reason}, _] -> {:error, reason}
        [_, {:error, reason}] -> {:error, reason}
      end
    else
      {:error, "Please provide two numbers separated by comma (e.g., '10, 2')"}
    end
  end

  defp safe_divide(a, 0.0), do: {:error, "Cannot divide by zero"}
  defp safe_divide(a, b), do: {:ok, a / b}

  defp parse_integer(str) do
    case Integer.parse(str) do
      {num, ""} -> {:just, num}
      _ -> :nothing
    end
  end

  defp validate_positive(n) when n > 0, do: {:just, n}
  defp validate_positive(_), do: :nothing

  defp validate_less_than_100(n) when n < 100, do: {:just, n}
  defp validate_less_than_100(_), do: :nothing
end

