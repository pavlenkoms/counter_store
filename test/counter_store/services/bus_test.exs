defmodule CounterStore.BusTest do
  alias CounterStore.Bus
  use ExUnit.Case

  test "success" do
    Bus.publish_metric(["bus1", "a", "b"], 2)
    Bus.publish_metric(["bus1", "b", "b"], 3)
    Bus.publish_metric(["bus1", "a", "b"], 2)

    :timer.sleep(100)

    {:ok, [{["bus1", "a", "b"], 2}, {["bus1", "b", "b"], 3}, {["bus1", "a", "b"], 2}]} =
      Bus.flush_messages()
  end
end
