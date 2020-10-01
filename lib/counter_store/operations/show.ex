defmodule CounterStore.Operation.Show do
  alias CounterStore.Storage

  def run(%{"expression" => expr}) when is_bitstring(expr) do
    with [_ | _] = labels <- String.split(expr, ",", trim: true),
         {:ok, count} <- Storage.query(labels) do
      {:ok, {labels, count}}
    else
      [] -> {:error, "not_found"}
      {:error, _reason} = err -> err
    end
  end

  def run(query) do
    {:error, {:bad_query, query}}
  end
end
