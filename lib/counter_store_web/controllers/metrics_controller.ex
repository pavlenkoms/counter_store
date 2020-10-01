defmodule CounterStoreWeb.MetricsController do
  alias CounterStore.Operation.{Create, Show}
  use CounterStoreWeb, :controller

  def create(conn, params) do
    case Create.run(params) do
      :ok ->
        conn
        |> put_status(:created)
        |> render(:create)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def show(conn, params) do
    case Show.run(params) do
      {:ok, {labels, count}} ->
        conn
        |> put_status(:ok)
        |> render(:show, labels: labels, count: count)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
