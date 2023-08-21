defmodule NavbarWeb.Page1Live do
  use NavbarWeb, :live_view
  # on_mount Navbar.ChartRequireSymbol
  require Logger

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      case params do
        %{"symbol" => symbol} ->
          :ok = NavbarWeb.Endpoint.subscribe("price")
          Logger.info("______________connected")
          {:ok, assign(socket, :symbol, symbol)}

        _ ->
          {:ok, redirect(socket, to: ~p"/")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-bold p-4 text-3xl"><%= @symbol %></h1>
    <div id="chart" phx-hook="StockChart" class="h-screen flex items-center justify-center"></div>
    """
  end

  @impl true
  def handle_params(_p, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "price", event: _event, payload: payload}, socket) do
    {:noreply, push_event(socket, "price_update", payload)}
  end
end
