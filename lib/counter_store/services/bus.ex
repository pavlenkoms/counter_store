defmodule CounterStore.Bus do
  alias Phoenix.PubSub
  alias CounterStore.Storage
  use GenServer

  require Logger

  @max_messages 64
  @message_topic "message"
  @pubsub CounterStore.PubSub

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def publish_metric(labels, increment) do
    message = {:message, {labels, increment}}
    Logger.debug("Publish message #{inspect(message)}")
    PubSub.broadcast(@pubsub, @message_topic, message)
  end

  def flush_messages() do
    GenServer.call(__MODULE__, :flush_messages)
  end

  def init(_) do
    PubSub.subscribe(@pubsub, @message_topic)

    state = %{
      messages: [],
      message_count: 0
    }

    {:ok, state}
  end

  def handle_call(:flush_messages, _, state) do
    {:reply, {:ok, state.messages}, %{state | messages: [], message_count: 0}}
  end

  def handle_info(
        {:message, {labels, increment}} = message,
        %{message_count: @max_messages} = state
      ) do
    Logger.debug("Recieve message then flush #{inspect(message)}")
    Storage.save([{labels, increment} | state.messages])
    {:noreply, %{state | messages: [], message_count: 0}}
  end

  def handle_info({:message, {labels, increment}} = message, state) do
    Logger.debug("Recieve message #{inspect(message)}")

    {:noreply,
     %{
       state
       | messages: [{labels, increment} | state.messages],
         message_count: state.message_count + 1
     }}
  end
end
