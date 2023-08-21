defmodule NavbarWeb.Page1Live do
  use NavbarWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    Here you can find page 1
    """
  end

  @impl true
  def handle_params(_p, _uri, socket) do
    {:noreply, socket}
  end
end
