defmodule Monado.Monad.Maybe do
  @moduledoc """
  Implementation of the Maybe monad in Elixir.
  
  The Maybe monad represents computations that might fail or return nothing.
  It's useful for handling operations that may not produce a value without
  using exceptions or complex error handling.
  
  ## Structure
  - `{:just, value}` - Represents a value
  - `:nothing` - Represents the absence of a value
  
  ## Laws
  The Maybe monad follows the three monad laws:
  1. Left identity: `return(a) >>= f` ≡ `f(a)`
  2. Right identity: `m >>= return` ≡ `m`
  3. Associativity: `(m >>= f) >>= g` ≡ `m >>= (fn x -> f(x) >>= g)`
  """

  @type maybe(a) :: {:just, a} | :nothing

  @doc """
  Wraps a value in the Maybe monad.
  Returns `:nothing` if the value is `nil`, otherwise returns `{:just, value}`.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.return(42)
      {:just, 42}
      
      iex> Monado.Monad.Maybe.return(nil)
      :nothing
  """
  @spec return(any()) :: maybe(any())
  def return(nil), do: :nothing
  def return(value), do: {:just, value}

  @doc """
  Creates a Just value directly.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.just(42)
      {:just, 42}
  """
  @spec just(any()) :: maybe(any())
  def just(value), do: {:just, value}

  @doc """
  Returns the Nothing value.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.nothing()
      :nothing
  """
  @spec nothing() :: maybe(any())
  def nothing, do: :nothing

  @doc """
  Monadic bind operation (>>=).
  Applies a function to the value inside the Maybe if it exists.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.bind({:just, 5}, fn x -> {:just, x * 2} end)
      {:just, 10}
      
      iex> Monado.Monad.Maybe.bind(:nothing, fn x -> {:just, x * 2} end)
      :nothing
  """
  @spec bind(maybe(a), (a -> maybe(b))) :: maybe(b) when a: any(), b: any()
  def bind(:nothing, _func), do: :nothing
  def bind({:just, value}, func), do: func.(value)

  @doc """
  Operator version of bind (>>= in Haskell).
  Can be used with the pipe operator for chaining.
  
  ## Examples
  
      iex> {:just, 5}
      ...> |> Monado.Monad.Maybe.then_bind(fn x -> {:just, x * 2} end)
      ...> |> Monado.Monad.Maybe.then_bind(fn x -> {:just, x + 3} end)
      {:just, 13}
  """
  @spec then_bind(maybe(a), (a -> maybe(b))) :: maybe(b) when a: any(), b: any()
  def then_bind(maybe, func), do: bind(maybe, func)

  @doc """
  Maps a regular function over a Maybe value (functor operation).
  
  ## Examples
  
      iex> Monado.Monad.Maybe.map({:just, 5}, fn x -> x * 2 end)
      {:just, 10}
      
      iex> Monado.Monad.Maybe.map(:nothing, fn x -> x * 2 end)
      :nothing
  """
  @spec map(maybe(a), (a -> b)) :: maybe(b) when a: any(), b: any()
  def map(:nothing, _func), do: :nothing
  def map({:just, value}, func), do: {:just, func.(value)}

  @doc """
  Extracts the value from a Maybe, providing a default if it's Nothing.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.from_maybe({:just, 42}, 0)
      42
      
      iex> Monado.Monad.Maybe.from_maybe(:nothing, 0)
      0
  """
  @spec from_maybe(maybe(a), a) :: a when a: any()
  def from_maybe(:nothing, default), do: default
  def from_maybe({:just, value}, _default), do: value

  @doc """
  Checks if a Maybe is Just.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.is_just?({:just, 42})
      true
      
      iex> Monado.Monad.Maybe.is_just?(:nothing)
      false
  """
  @spec is_just?(maybe(any())) :: boolean()
  def is_just?({:just, _}), do: true
  def is_just?(:nothing), do: false

  @doc """
  Checks if a Maybe is Nothing.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.is_nothing?(:nothing)
      true
      
      iex> Monado.Monad.Maybe.is_nothing?({:just, 42})
      false
  """
  @spec is_nothing?(maybe(any())) :: boolean()
  def is_nothing?(:nothing), do: true
  def is_nothing?({:just, _}), do: false

  @doc """
  Filters a Maybe based on a predicate.
  Returns Nothing if the predicate returns false.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.filter({:just, 5}, fn x -> x > 3 end)
      {:just, 5}
      
      iex> Monado.Monad.Maybe.filter({:just, 2}, fn x -> x > 3 end)
      :nothing
  """
  @spec filter(maybe(a), (a -> boolean())) :: maybe(a) when a: any()
  def filter(:nothing, _predicate), do: :nothing
  def filter({:just, value} = maybe, predicate) do
    if predicate.(value), do: maybe, else: :nothing
  end

  @doc """
  Chains multiple Maybe operations together using a list of functions.
  Stops at the first Nothing encountered.
  
  ## Examples
  
      iex> Monado.Monad.Maybe.chain({:just, 5}, [
      ...>   fn x -> {:just, x * 2} end,
      ...>   fn x -> {:just, x + 3} end,
      ...>   fn x -> {:just, x - 1} end
      ...> ])
      {:just, 12}
  """
  @spec chain(maybe(a), [(a -> maybe(a))]) :: maybe(a) when a: any()
  def chain(maybe, functions) do
    Enum.reduce(functions, maybe, fn func, acc ->
      bind(acc, func)
    end)
  end
end

