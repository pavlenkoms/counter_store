defmodule CounterStore.StorageTest do
  use ExUnit.Case

  test "success" do
    messages = [
      {["storage1", "a", "b"], 2},
      {["storage1", "b", "b"], 3},
      {["storage1", "a", "b"], 2}
    ]

    CounterStore.Storage.save(messages)
    {:ok, 4} = CounterStore.Storage.query(["storage1", "a", "b"])
    {:ok, 3} = CounterStore.Storage.query(["storage1", "b", "b"])
  end
end
