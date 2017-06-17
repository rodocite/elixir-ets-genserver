defmodule Eg do
  use GenServer

  @name Mango

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: Mango])
  end

  def write(key, term) do
    GenServer.call(@name, {:insert_term, key, term})
  end

  def read(key) do
    GenServer.call(@name, {:read_term, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete_term, key})
  end

  def clear do
  end

  def exists?(key) do
    GenServer.call(@name, {:check_term, key})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Callbacks
  def init(:ok) do
    state = :ets.new(:terms, [:set, :protected, :named_table])
    {:ok, state}
  end

  def handle_call({:insert_term, key, term}, _from, state) do
    insert_term(key, term)
    |> case do
      true ->
        {:reply, "Term inserted.", state}
      false ->
        {:reply, "Key already exists.", state}
    end
  end

  def handle_call({:read_term, key}, _from, state) do
    find_term(key)
    |> case do
      [] ->
        {:reply, "Key not found.", state}
      term ->
        {:reply, term, state}
    end
  end

  def handle_call({:check_term, key}, _from, state) do
    term_exists?(key)
    |> case do
      true ->
        {:reply, "Term exists.", state}
      false ->
        {:reply, "Term not found", state}
    end
  end

  def handle_cast({:delete_term, key}, state) do
    delete_term(key)
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    IO.puts("Server terminated - #{inspect reason}")
    :ok
  end

  ## Helpers
  defp insert_term(key, term) do
    :ets.insert_new(:terms, {key, term})
  end

  defp find_term(key) do
    :ets.lookup(:terms, key)
    |> case do
      [] ->
        []
      found ->
        [term | _] = found
        term
    end
  end

  defp term_exists?(key) do
    :ets.lookup(:terms, key)
    |> case do
      [] ->
        false
      found ->
        true
    end
  end

  defp delete_term(key) do
    :ets.delete(:terms, key)
  end
end
