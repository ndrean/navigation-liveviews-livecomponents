defmodule NavbarWeb.HomePageLive do
  use NavbarWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    Home page
    """
  end

  @impl true
  def handle_params(_p, _uri, socket) do
    binding() |> dbg()
    {:noreply, socket}
  end
end
