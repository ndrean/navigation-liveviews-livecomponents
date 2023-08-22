defmodule NavbarWeb.P1Comp do
  @moduledoc """
  Livecomponent to render chart
  """
  use Phoenix.LiveComponent

  use Phoenix.VerifiedRoutes, endpoint: NavbarWeb.Endpoint, router: NavbarWeb.Router

  require Logger

  @impl true
  def(render(assigns)) do
    ~H"""
    <div>
      <p>Component p1</p>
      <h1 class="font-bold p-4 text-3xl"><%= @symbol %></h1>
      <div id="chart" phx-hook="StockChart" class="h-screen flex items-center justify-center"></div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    if connected?(socket) do
      :ok = NavbarWeb.Endpoint.subscribe("price")
      Logger.info("______________connected P1Comp")
      {:ok, socket}
    end
  end

  @impl true
  # first update
  def update(%{id: 1, symbol: symbol}, socket) do
    {:ok, assign(socket, :symbol, symbol)}
  end

  # update after parent component received pubsub and "send_update"
  def update(%{id: 1, price_update: payload}, socket) do
    {:ok, push_event(socket, "price_update", payload)}
  end
end
