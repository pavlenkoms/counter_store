defmodule CounterStoreWeb.MetricsControllerTest do
  use CounterStoreWeb.ConnCase

  describe "POST" do
    test "success", %{conn: conn} do
      conn
      |> post("/metrics", %{"labels" => ["post", "b", "c"], "increment" => 2})
      |> json_response(201)

      conn
      |> post("/metrics", %{"labels" => ["post", "b", "c"], "increment" => 2})
      |> json_response(201)

      {:ok, [{["post", "b", "c"], 2}, {["post", "b", "c"], 2}]} =
        CounterStore.Bus.flush_messages()
    end

    test "failure - bad label", %{conn: conn} do
      conn
      |> post("/metrics", %{"labels" => ["a", "b", 1], "increment" => 2})
      |> json_response(400)

      conn
      |> post("/metrics", %{"labels" => "abc", "increment" => 2})
      |> json_response(400)

      conn
      |> post("/metrics", %{"labels" => 1, "increment" => 2})
      |> json_response(400)

      conn
      |> post("/metrics", %{"label" => ["a", "b", "c"], "increment" => 2})
      |> json_response(400)
    end

    test "failure - bad increment", %{conn: conn} do
      conn
      |> post("/metrics", %{"labels" => ["a", "b", 1], "increment" => "2"})
      |> json_response(400)

      conn
      |> post("/metrics", %{"labels" => "abc", "increment" => -1})
      |> json_response(400)

      conn
      |> post("/metrics", %{"labels" => 1, "incrementt" => 2})
      |> json_response(400)
    end
  end

  describe "GET" do
    test "success", %{conn: conn} do
      messages = [{["get1", "a", "b"], 2}, {["get1", "b", "b"], 3}, {["get1", "a", "b"], 2}]
      CounterStore.Storage.save(messages)

      resp1 =
        conn
        |> get("/query?expression=get1,a,b")
        |> json_response(200)

      resp2 =
        conn
        |> get("/query?expression=get1,b,b")
        |> json_response(200)

      assert %{"labels" => ["get1", "a", "b"], "count" => 4} == resp1
      assert %{"labels" => ["get1", "b", "b"], "count" => 3} == resp2
    end

    test "failure", %{conn: conn} do
      messages = [{["get2", "a", "b"], 2}]
      CounterStore.Storage.save(messages)

      resp =
        conn
        |> get("/query?expression=get2,b,a")
        |> json_response(400)

      assert %{"error" => "not found"} == resp
    end
  end
end
