defmodule NavbarWeb.HomePageLive do
  use NavbarWeb, :live_view
  import Phoenix.VerifiedRoutes
  alias Navbar.StreamSymbolSup

  require Logger

  @curr_symbols ~w(bitcoin litecoin ethereum)

  @impl true
  def mount(params, _session, socket) do
    socket =
      case params do
        %{"symbol" => symbol} ->
          assign(socket, :symbol, symbol)

        _ ->
          socket
      end

    field = %{"symbol" => ""}

    {:ok, assign(socket, symbols: @curr_symbols, form: to_form(field))}
  end

  attr :symbol, :string, required: true
  attr :current_path, :string

  # phx-change="stop_stream"
  @impl true
  def render(%{current_path: "/p1", symbol: _symbol} = assigns) do
    ~H"""
    <.live_component module={NavbarWeb.P1Comp} id={1} symbol={@symbol} />
    """
  end

  def render(%{current_path: "/p2"} = assigns) do
    ~H"""
    <.live_component module={NavbarWeb.P2Comp} id={2} />
    """
  end

  def render(assigns) do
    ~H"""
    <h1>Home page</h1>
    <.simple_form id="symbol-form" for={@form} phx-submit="stream" phx-change="set_symbol">
      <.input
        type="select"
        prompt="please select a symbol"
        autofocus
        required
        options={@symbols}
        field={@form[:symbol]}
      >
      </.input>
      <:actions>
        <.button>Go to chart</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case params do
      %{"page" => page} ->
        case Map.get(socket.assigns, :symbol) do
          nil ->
            {:noreply, push_patch(socket, to: ~p"/")}

          _ ->
            {:noreply, assign(socket, current_path: "/#{page}")}
        end

      _ ->
        {:noreply, socket}
    end
  end

  # menu2: select a symbol, then navigate to page
  @impl true
  def handle_event("set_symbol", %{"symbol" => symbol}, socket) do
    clean_and_stream(symbol)
    {:noreply, assign(socket, :symbol, symbol)}
  end

  # menu1: select a symbol, submit and push_navigate
  def handle_event("stream", %{"symbol" => symbol}, socket) do
    clean_and_stream(symbol)
    socket = assign(socket, :symbol, symbol)
    {:noreply, push_navigate(socket, to: ~p"/chart?symbol=#{symbol}", replace: true)}
  end

  @doc """
  Capture the broadcasted
  """
  @impl true
  def handle_info(%{topic: "price", event: _event, payload: payload}, socket) do
    send_update(NavbarWeb.P1Comp, id: 1, price_update: payload)
    {:noreply, socket}
  end

  @doc """
  Collect all dynamically supervised streaming process, stop them, and start a new one
  """
  def clean_and_stream(symbol) do
    res = DynamicSupervisor.which_children(MyDynSup)

    :ok =
      case length(res) do
        0 ->
          :ok

        _ ->
          Enum.each(res, fn {_, pid, :worker, [Navbar.StreamSymbol]} ->
            DynamicSupervisor.terminate_child(MyDynSup, pid)
          end)
      end

    {:ok, _pid} = StreamSymbolSup.start(symbol)
  end
end
