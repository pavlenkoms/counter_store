defmodule CounterStore.Operation.Create do
  alias CounterStore.Bus

  def run(%{"labels" => labels, "increment" => increment} = params) do
    with [_ | _] <- labels,
         true <- Enum.all?(labels, &is_bitstring(&1)),
         true <- is_integer(increment),
         true <- increment >= 0 do
      Bus.publish_metric(labels, increment)
      :ok
    else
      _ -> {:error, {:bad_params, params}}
    end
  end

  def run(params) do
    {:error, {:bad_params, params}}
  end
end
