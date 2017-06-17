defmodule Eg do
  use GenServer

  @name Mango

  ## Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: Mango])
  end

  def stop do
    GenServer.cast(@name, :stop)
  end
  ## Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    IO.puts("Server terminated - #{inspect reason}")
    :ok
  end
  ## Helpers
end
