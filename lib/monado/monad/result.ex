defmodule Monado.Monad.Result do
  @moduledoc """
  Implementation of the Result (Either) monad in Elixir.
  
  The Result monad represents computations that can succeed or fail.
  It's useful for error handling without exceptions, providing context
  about what went wrong.
  
  ## Structure
  - `{:ok, value}` - Represents a successful computation
  - `{:error, reason}` - Represents a failed computation with an error reason
  
  This aligns with Elixir's idiomatic `{:ok, value}` and `{:error, reason}` tuples.
  """

  @type result(a, e) :: {:ok, a} | {:error, e}

  @doc """
  Wraps a value in a successful Result.
  
  ## Examples
  
      iex> Monado.Monad.Result.return(42)
      {:ok, 42}
  """
  @spec return(a) :: result(a, any()) when a: any()
  def return(value), do: {:ok, value}

  @doc """
  Creates an Ok value directly.
  
  ## Examples
  
      iex> Monado.Monad.Result.ok(42)
      {:ok, 42}
  """
  @spec ok(a) :: result(a, any()) when a: any()
  def ok(value), do: {:ok, value}

  @doc """
  Creates an Error value.
  
  ## Examples
  
      iex> Monado.Monad.Result.error("Something went wrong")
      {:error, "Something went wrong"}
  """
  @spec error(e) :: result(any(), e) when e: any()
  def error(reason), do: {:error, reason}

  @doc """
  Monadic bind operation (>>=).
  Applies a function to the value inside the Result if it's Ok.
  
  ## Examples
  
      iex> Monado.Monad.Result.bind({:ok, 5}, fn x -> {:ok, x * 2} end)
      {:ok, 10}
      
      iex> Monado.Monad.Result.bind({:error, "failed"}, fn x -> {:ok, x * 2} end)
      {:error, "failed"}
  """
  @spec bind(result(a, e), (a -> result(b, e))) :: result(b, e) when a: any(), b: any(), e: any()
  def bind({:error, _} = error, _func), do: error
  def bind({:ok, value}, func), do: func.(value)

  @doc """
  Operator version of bind for chaining.
  
  ## Examples
  
      iex> {:ok, 5}
      ...> |> Monado.Monad.Result.then_bind(fn x -> {:ok, x * 2} end)
      ...> |> Monado.Monad.Result.then_bind(fn x -> {:ok, x + 3} end)
      {:ok, 13}
  """
  @spec then_bind(result(a, e), (a -> result(b, e))) :: result(b, e) when a: any(), b: any(), e: any()
  def then_bind(result, func), do: bind(result, func)

  @doc """
  Maps a function over a Result value (functor operation).
  
  ## Examples
  
      iex> Monado.Monad.Result.map({:ok, 5}, fn x -> x * 2 end)
      {:ok, 10}
      
      iex> Monado.Monad.Result.map({:error, "failed"}, fn x -> x * 2 end)
      {:error, "failed"}
  """
  @spec map(result(a, e), (a -> b)) :: result(b, e) when a: any(), b: any(), e: any()
  def map({:error, _} = error, _func), do: error
  def map({:ok, value}, func), do: {:ok, func.(value)}

  @doc """
  Maps a function over the error value.
  
  ## Examples
  
      iex> Monado.Monad.Result.map_error({:error, "failed"}, &String.upcase/1)
      {:error, "FAILED"}
      
      iex> Monado.Monad.Result.map_error({:ok, 5}, &String.upcase/1)
      {:ok, 5}
  """
  @spec map_error(result(a, e1), (e1 -> e2)) :: result(a, e2) when a: any(), e1: any(), e2: any()
  def map_error({:ok, _} = ok, _func), do: ok
  def map_error({:error, reason}, func), do: {:error, func.(reason)}

  @doc """
  Extracts the value from a Result, providing a default if it's an Error.
  
  ## Examples
  
      iex> Monado.Monad.Result.from_result({:ok, 42}, 0)
      42
      
      iex> Monado.Monad.Result.from_result({:error, "failed"}, 0)
      0
  """
  @spec from_result(result(a, any()), a) :: a when a: any()
  def from_result({:error, _}, default), do: default
  def from_result({:ok, value}, _default), do: value

  @doc """
  Checks if a Result is Ok.
  
  ## Examples
  
      iex> Monado.Monad.Result.is_ok?({:ok, 42})
      true
      
      iex> Monado.Monad.Result.is_ok?({:error, "failed"})
      false
  """
  @spec is_ok?(result(any(), any())) :: boolean()
  def is_ok?({:ok, _}), do: true
  def is_ok?({:error, _}), do: false

  @doc """
  Checks if a Result is an Error.
  
  ## Examples
  
      iex> Monado.Monad.Result.is_error?({:error, "failed"})
      true
      
      iex> Monado.Monad.Result.is_error?({:ok, 42})
      false
  """
  @spec is_error?(result(any(), any())) :: boolean()
  def is_error?({:error, _}), do: true
  def is_error?({:ok, _}), do: false

  @doc """
  Converts a Maybe to a Result with a provided error reason.
  
  ## Examples
  
      iex> Monado.Monad.Result.from_maybe({:just, 42}, "no value")
      {:ok, 42}
      
      iex> Monado.Monad.Result.from_maybe(:nothing, "no value")
      {:error, "no value"}
  """
  @spec from_maybe({:just, a} | :nothing, e) :: result(a, e) when a: any(), e: any()
  def from_maybe(:nothing, error_reason), do: {:error, error_reason}
  def from_maybe({:just, value}, _error_reason), do: {:ok, value}

  @doc """
  Chains multiple Result operations together.
  Stops at the first Error encountered.
  
  ## Examples
  
      iex> Monado.Monad.Result.chain({:ok, 5}, [
      ...>   fn x -> {:ok, x * 2} end,
      ...>   fn x -> {:ok, x + 3} end
      ...> ])
      {:ok, 13}
      
      iex> Monado.Monad.Result.chain({:ok, 5}, [
      ...>   fn x -> {:ok, x * 2} end,
      ...>   fn _ -> {:error, "failed"} end,
      ...>   fn x -> {:ok, x + 3} end
      ...> ])
      {:error, "failed"}
  """
  @spec chain(result(a, e), [(a -> result(a, e))]) :: result(a, e) when a: any(), e: any()
  def chain(result, functions) do
    Enum.reduce(functions, result, fn func, acc ->
      bind(acc, func)
    end)
  end
end

