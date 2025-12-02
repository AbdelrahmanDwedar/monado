defmodule Monado.Monad.MaybeTest do
  use ExUnit.Case, async: true
  
  alias Monado.Monad.Maybe

  doctest Monado.Monad.Maybe

  describe "return/1" do
    test "wraps non-nil value in Just" do
      assert Maybe.return(42) == {:just, 42}
      assert Maybe.return("hello") == {:just, "hello"}
      assert Maybe.return([1, 2, 3]) == {:just, [1, 2, 3]}
    end

    test "returns Nothing for nil" do
      assert Maybe.return(nil) == :nothing
    end
  end

  describe "bind/2" do
    test "applies function to Just value" do
      result = Maybe.bind({:just, 5}, fn x -> {:just, x * 2} end)
      assert result == {:just, 10}
    end

    test "returns Nothing when input is Nothing" do
      result = Maybe.bind(:nothing, fn x -> {:just, x * 2} end)
      assert result == :nothing
    end

    test "chains multiple operations" do
      result =
        {:just, 10}
        |> Maybe.bind(fn x -> {:just, x + 5} end)
        |> Maybe.bind(fn x -> {:just, x * 2} end)
        |> Maybe.bind(fn x -> {:just, x - 3} end)
      
      assert result == {:just, 27}
    end

    test "stops at first Nothing" do
      result =
        {:just, 10}
        |> Maybe.bind(fn x -> {:just, x + 5} end)
        |> Maybe.bind(fn _ -> :nothing end)
        |> Maybe.bind(fn x -> {:just, x * 100} end)
      
      assert result == :nothing
    end
  end

  describe "map/2" do
    test "applies function to Just value" do
      result = Maybe.map({:just, 5}, fn x -> x * 2 end)
      assert result == {:just, 10}
    end

    test "returns Nothing for Nothing input" do
      result = Maybe.map(:nothing, fn x -> x * 2 end)
      assert result == :nothing
    end

    test "chains multiple maps" do
      result =
        {:just, 5}
        |> Maybe.map(fn x -> x * 2 end)
        |> Maybe.map(fn x -> x + 3 end)
        |> Maybe.map(fn x -> x - 1 end)
      
      assert result == {:just, 12}
    end
  end

  describe "from_maybe/2" do
    test "extracts value from Just" do
      assert Maybe.from_maybe({:just, 42}, 0) == 42
      assert Maybe.from_maybe({:just, "hello"}, "") == "hello"
    end

    test "returns default for Nothing" do
      assert Maybe.from_maybe(:nothing, 0) == 0
      assert Maybe.from_maybe(:nothing, "default") == "default"
    end
  end

  describe "is_just?/1" do
    test "returns true for Just values" do
      assert Maybe.is_just?({:just, 42})
      assert Maybe.is_just?({:just, nil})
      assert Maybe.is_just?({:just, []})
    end

    test "returns false for Nothing" do
      refute Maybe.is_just?(:nothing)
    end
  end

  describe "is_nothing?/1" do
    test "returns true for Nothing" do
      assert Maybe.is_nothing?(:nothing)
    end

    test "returns false for Just values" do
      refute Maybe.is_nothing?({:just, 42})
      refute Maybe.is_nothing?({:just, nil})
    end
  end

  describe "filter/2" do
    test "keeps Just value when predicate is true" do
      result = Maybe.filter({:just, 5}, fn x -> x > 3 end)
      assert result == {:just, 5}
    end

    test "returns Nothing when predicate is false" do
      result = Maybe.filter({:just, 2}, fn x -> x > 3 end)
      assert result == :nothing
    end

    test "returns Nothing for Nothing input" do
      result = Maybe.filter(:nothing, fn x -> x > 3 end)
      assert result == :nothing
    end
  end

  describe "chain/2" do
    test "applies all functions in sequence" do
      functions = [
        fn x -> {:just, x * 2} end,
        fn x -> {:just, x + 3} end,
        fn x -> {:just, x - 1} end
      ]

      result = Maybe.chain({:just, 5}, functions)
      assert result == {:just, 12}
    end

    test "stops at first Nothing in chain" do
      functions = [
        fn x -> {:just, x * 2} end,
        fn _ -> :nothing end,
        fn x -> {:just, x + 100} end
      ]

      result = Maybe.chain({:just, 5}, functions)
      assert result == :nothing
    end
  end

  describe "monad laws" do
    test "left identity: return(a) >>= f ≡ f(a)" do
      f = fn x -> {:just, x * 2} end
      a = 5

      left = Maybe.bind(Maybe.return(a), f)
      right = f.(a)

      assert left == right
    end

    test "right identity: m >>= return ≡ m" do
      m = {:just, 42}

      left = Maybe.bind(m, &Maybe.return/1)
      right = m

      assert left == right
    end

    test "associativity: (m >>= f) >>= g ≡ m >>= (x -> f(x) >>= g)" do
      m = {:just, 5}
      f = fn x -> {:just, x * 2} end
      g = fn x -> {:just, x + 3} end

      left = 
        m
        |> Maybe.bind(f)
        |> Maybe.bind(g)

      right = Maybe.bind(m, fn x -> Maybe.bind(f.(x), g) end)

      assert left == right
    end
  end

  describe "practical examples" do
    test "safe division" do
      safe_divide = fn a, b ->
        if b == 0, do: :nothing, else: {:just, a / b}
      end

      # Success case
      result =
        {:just, 10}
        |> Maybe.bind(fn x -> safe_divide.(x, 2) end)
        |> Maybe.map(fn x -> x * 3 end)

      assert result == {:just, 15.0}

      # Failure case
      result =
        {:just, 10}
        |> Maybe.bind(fn x -> safe_divide.(x, 0) end)
        |> Maybe.map(fn x -> x * 3 end)

      assert result == :nothing
    end

    test "parsing chain" do
      parse_int = fn str ->
        case Integer.parse(str) do
          {num, ""} -> {:just, num}
          _ -> :nothing
        end
      end

      validate_positive = fn n ->
        if n > 0, do: {:just, n}, else: :nothing
      end

      # Valid input
      result =
        "42"
        |> parse_int.()
        |> Maybe.bind(validate_positive)
        |> Maybe.map(fn x -> x * 2 end)

      assert result == {:just, 84}

      # Invalid number
      result =
        "abc"
        |> parse_int.()
        |> Maybe.bind(validate_positive)
        |> Maybe.map(fn x -> x * 2 end)

      assert result == :nothing

      # Negative number
      result =
        "-5"
        |> parse_int.()
        |> Maybe.bind(validate_positive)
        |> Maybe.map(fn x -> x * 2 end)

      assert result == :nothing
    end
  end
end

