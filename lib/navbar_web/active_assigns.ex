defmodule NavbarWeb.ActiveAssigns do
  @moduledoc """
  Module for managing active navigation tabs in a Phoenix LiveView component.
  """

  import Phoenix.LiveView
  import Phoenix.Component
  import Phoenix.VerifiedRoutes

  def on_mount(:set_path_in_socket, _params, _session, socket) do
    active = "bg-[bisque] text-[midnightblue] px-1 py-1"

    socket =
      assign(socket,
        menus: [
          {"Home", path(socket, NavbarWeb.Router, ~p"/")},
          {"Chart", path(socket, NavbarWeb.Router, ~p"/chart")},
          {"Page 2", path(socket, NavbarWeb.Router, ~p"/page2")}
        ],
        menus2: [
          {"Home", path(socket, NavbarWeb.Router, ~p"/"), "/"},
          {"P1", path(socket, NavbarWeb.Router, ~p"/?page=p1"), "/p1"},
          {"P2", path(socket, NavbarWeb.Router, ~p"/?page=p2"), "/p2"}
        ],
        active: active
      )

    {:cont,
     socket
     |> attach_hook(:set_path_in_socket, :handle_params, &manage_active_tabs/3)}
  end

  defp manage_active_tabs(_params, url, socket) do
    {:cont, assign(socket, current_path: URI.parse(url).path)}
  end
end
