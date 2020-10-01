defmodule CounterStoreWeb.MetricsView do
  use CounterStoreWeb, :view

  def render("create.json", _) do
    %{result: "ok"}
  end

  def render("show.json", %{labels: labels, count: count}) do
    %{labels: labels, count: count}
  end
end
