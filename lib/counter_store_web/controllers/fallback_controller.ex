defmodule CounterStoreWeb.FallbackController do
  use CounterStoreWeb, :controller

  def call(conn, {:error, error}) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: message(error)
    })
  end

  def call(_conn, error) do
    raise "Unknown controller action return value\n#{inspect(error)}"
  end

  defp message(error) when is_binary(error), do: error
  defp message(error), do: inspect(error)
end
