defmodule NavbarWeb.Page2Live do
  use NavbarWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    That is page 2
    """
  end

  @impl true
  def handle_params(_p, _uri, socket) do
    {:noreply, socket}
  end
end
