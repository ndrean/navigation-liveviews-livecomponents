defmodule Navbar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      NavbarWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Navbar.PubSub},
      # Start Finch
      {Finch, name: Navbar.Finch},
      # Start the Endpoint (http/https)
      NavbarWeb.Endpoint,
      {DynamicSupervisor, name: MyDynSup, strategy: :one_for_one},
      {Task, fn -> shutdown_when_inactive(:timer.minutes(10)) end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Navbar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NavbarWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp shutdown_when_inactive(every_ms) do
    Process.sleep(every_ms)

    if :ranch.procs(AppWeb.Endpoint.HTTP, :connections) == [] do
      System.stop(0)
    else
      shutdown_when_inactive(every_ms)
    end
  end
end
