defmodule NavbarWeb.ActiveAssigns do
  @moduledoc """
  Module for managing active navigation tabs in a Phoenix LiveView component.
  """

  import Phoenix.LiveView
  import Phoenix.Component
  import Phoenix.VerifiedRoutes

  def on_mount(:select_active, _params, _session, socket) do
    active = "bg-[bisque] text-[midnightblue] px-1 py-1"

    socket =
      assign(socket,
        menus: [
          {"Home", path(socket, NavbarWeb.Router, ~p"/")},
          {"Page 1", path(socket, NavbarWeb.Router, ~p"/page1")},
          {"Page 2", path(socket, NavbarWeb.Router, ~p"/page2")}
        ],
        active: active
      )

    {:cont,
     socket
     |> attach_hook(:set_menu_path, :handle_params, &manage_active_tabs/3)}
  end

  defp manage_active_tabs(_params, url, socket) do
    {:cont, assign(socket, current_path: URI.parse(url).path)}
  end
end
