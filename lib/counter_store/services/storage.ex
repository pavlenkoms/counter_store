defmodule CounterStore.Storage do
  alias CounterStore.Bus
  use GenServer

  @timeout 60000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def save(messages) do
    GenServer.cast(__MODULE__, {:save, messages})
  end

  def query(labels) do
    GenServer.call(__MODULE__, {:query, labels}, @timeout)
  end

  def init([]) do
    :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    {:ok, %{}}
  end

  def handle_call({:query, labels}, _, state) do
    case Bus.flush_messages() do
      {:ok, messages} ->
        save_messages(messages)

      _ ->
        :ok
    end

    resp =
      case :ets.lookup(__MODULE__, labels) do
        [{_, count}] ->
          {:ok, count}

        _ ->
          {:error, "not found"}
      end

    {:reply, resp, state}
  end

  def handle_cast({:save, messages}, state) do
    save_messages(messages)
    {:noreply, state}
  end

  defp save_messages(messages) do
    await_list =
      Enum.map(messages, fn {labels, incr} ->
        Task.async(fn -> :ets.update_counter(__MODULE__, labels, {2, incr}, {labels, 0}) end)
      end)

    Enum.map(await_list, &Task.await(&1, :infinity))
  end
end
