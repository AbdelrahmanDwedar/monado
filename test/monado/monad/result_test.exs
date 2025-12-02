defmodule Monado.Monad.ResultTest do
  use ExUnit.Case, async: true
  
  alias Monado.Monad.Result

  doctest Monado.Monad.Result

  describe "return/1 and ok/1" do
    test "wraps value in Ok" do
      assert Result.return(42) == {:ok, 42}
      assert Result.ok("hello") == {:ok, "hello"}
    end
  end

  describe "error/1" do
    test "creates Error value" do
      assert Result.error("failed") == {:error, "failed"}
      assert Result.error(:not_found) == {:error, :not_found}
    end
  end

  describe "bind/2" do
    test "applies function to Ok value" do
      result = Result.bind({:ok, 5}, fn x -> {:ok, x * 2} end)
      assert result == {:ok, 10}
    end

    test "returns Error when input is Error" do
      result = Result.bind({:error, "failed"}, fn x -> {:ok, x * 2} end)
      assert result == {:error, "failed"}
    end

    test "chains multiple operations" do
      result =
        {:ok, 10}
        |> Result.bind(fn x -> {:ok, x + 5} end)
        |> Result.bind(fn x -> {:ok, x * 2} end)
      
      assert result == {:ok, 30}
    end

    test "stops at first Error" do
      result =
        {:ok, 10}
        |> Result.bind(fn x -> {:ok, x + 5} end)
        |> Result.bind(fn _ -> {:error, "something failed"} end)
        |> Result.bind(fn x -> {:ok, x * 100} end)
      
      assert result == {:error, "something failed"}
    end
  end

  describe "map/2" do
    test "applies function to Ok value" do
      result = Result.map({:ok, 5}, fn x -> x * 2 end)
      assert result == {:ok, 10}
    end

    test "returns Error for Error input" do
      result = Result.map({:error, "failed"}, fn x -> x * 2 end)
      assert result == {:error, "failed"}
    end
  end

  describe "map_error/2" do
    test "transforms error value" do
      result = Result.map_error({:error, "failed"}, &String.upcase/1)
      assert result == {:error, "FAILED"}
    end

    test "leaves Ok unchanged" do
      result = Result.map_error({:ok, 5}, &String.upcase/1)
      assert result == {:ok, 5}
    end
  end

  describe "from_result/2" do
    test "extracts value from Ok" do
      assert Result.from_result({:ok, 42}, 0) == 42
    end

    test "returns default for Error" do
      assert Result.from_result({:error, "failed"}, 0) == 0
    end
  end

  describe "is_ok?/1 and is_error?/1" do
    test "correctly identifies Ok values" do
      assert Result.is_ok?({:ok, 42})
      refute Result.is_ok?({:error, "failed"})
    end

    test "correctly identifies Error values" do
      assert Result.is_error?({:error, "failed"})
      refute Result.is_error?({:ok, 42})
    end
  end

  describe "from_maybe/2" do
    test "converts Just to Ok" do
      result = Result.from_maybe({:just, 42}, "no value")
      assert result == {:ok, 42}
    end

    test "converts Nothing to Error" do
      result = Result.from_maybe(:nothing, "no value found")
      assert result == {:error, "no value found"}
    end
  end

  describe "chain/2" do
    test "applies all functions in sequence" do
      functions = [
        fn x -> {:ok, x * 2} end,
        fn x -> {:ok, x + 3} end,
        fn x -> {:ok, x - 1} end
      ]

      result = Result.chain({:ok, 5}, functions)
      assert result == {:ok, 12}
    end

    test "stops at first Error" do
      functions = [
        fn x -> {:ok, x * 2} end,
        fn _ -> {:error, "computation failed"} end,
        fn x -> {:ok, x + 100} end
      ]

      result = Result.chain({:ok, 5}, functions)
      assert result == {:error, "computation failed"}
    end
  end

  describe "monad laws" do
    test "left identity: return(a) >>= f ≡ f(a)" do
      f = fn x -> {:ok, x * 2} end
      a = 5

      left = Result.bind(Result.return(a), f)
      right = f.(a)

      assert left == right
    end

    test "right identity: m >>= return ≡ m" do
      m = {:ok, 42}

      left = Result.bind(m, &Result.return/1)
      right = m

      assert left == right
    end

    test "associativity: (m >>= f) >>= g ≡ m >>= (x -> f(x) >>= g)" do
      m = {:ok, 5}
      f = fn x -> {:ok, x * 2} end
      g = fn x -> {:ok, x + 3} end

      left = 
        m
        |> Result.bind(f)
        |> Result.bind(g)

      right = Result.bind(m, fn x -> Result.bind(f.(x), g) end)

      assert left == right
    end
  end

  describe "practical examples" do
    test "validation pipeline" do
      parse_age = fn str ->
        case Integer.parse(str) do
          {age, ""} -> {:ok, age}
          _ -> {:error, "Invalid number format"}
        end
      end

      validate_age = fn age ->
        cond do
          age < 0 -> {:error, "Age cannot be negative"}
          age > 150 -> {:error, "Age too large"}
          true -> {:ok, age}
        end
      end

      # Valid input
      result =
        "25"
        |> parse_age.()
        |> Result.bind(validate_age)

      assert result == {:ok, 25}

      # Invalid format
      result =
        "invalid"
        |> parse_age.()
        |> Result.bind(validate_age)

      assert result == {:error, "Invalid number format"}

      # Invalid value
      result =
        "-5"
        |> parse_age.()
        |> Result.bind(validate_age)

      assert result == {:error, "Age cannot be negative"}
    end

    test "multi-step computation with error handling" do
      divide = fn a, b ->
        if b == 0 do
          {:error, "Division by zero"}
        else
          {:ok, a / b}
        end
      end

      sqrt = fn x ->
        if x < 0 do
          {:error, "Cannot take square root of negative number"}
        else
          {:ok, :math.sqrt(x)}
        end
      end

      # Success path
      result =
        {:ok, 16}
        |> Result.bind(fn x -> divide.(x, 4) end)
        |> Result.bind(sqrt)

      assert result == {:ok, 2.0}

      # Division by zero error
      result =
        {:ok, 16}
        |> Result.bind(fn x -> divide.(x, 0) end)
        |> Result.bind(sqrt)

      assert result == {:error, "Division by zero"}

      # Negative square root error
      result =
        {:ok, -4}
        |> Result.bind(fn x -> divide.(x, 2) end)
        |> Result.bind(sqrt)

      assert result == {:error, "Cannot take square root of negative number"}
    end
  end
end

