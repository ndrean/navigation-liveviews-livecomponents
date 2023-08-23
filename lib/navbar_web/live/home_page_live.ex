defmodule NavbarWeb.HomePageLive do
  use NavbarWeb, :live_view
  import Phoenix.VerifiedRoutes
  alias Navbar.StreamSymbolSup

  require Logger

  @curr_symbols ~w(bitcoin litecoin ethereum)

  @impl true
  def mount(_params, _session, socket) do
    field = %{"symbol" => ""}

    {:ok, assign(socket, symbols: @curr_symbols, form: to_form(field))}
  end

  @doc """
  3 versions of the render:
  1) at url="/p1", we render a chart if there is a symbol
  2) at url="/p2", we render a Livecomponent
  3) the rest, url="/", we render the HomePage with the form to select a symbol
  """
  attr :symbol, :string, required: true
  attr :current_path, :string
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

  @doc """
  Navigate to "/p1" only if a symbol is selected,  redirect to "/" if not.
  Clean streaming subscription and reset symbol when leaving "/p1".
  """
  @impl true

  def handle_params(%{"page" => "p1"}, uri, socket) do
    {uri, socket.assigns} |> dbg()

    if Map.get(socket.assigns, :symbol) == nil,
      do: {:noreply, push_patch(socket, to: ~p"/")},
      else: {:noreply, assign(socket, current_path: "/p1")}
  end

  def handle_params(%{"page" => page}, _uri, socket) do
    clean_stream()
    {:noreply, assign(socket, current_path: "/#{page}", symbol: nil)}
  end

  def handle_params(_, _, socket), do: {:noreply, socket}

  # "on change" for menu2:
  # select a symbol, then navigate to page
  @impl true
  def handle_event("set_symbol", %{"symbol" => symbol}, socket) do
    :ok = clean_stream()
    {:ok, _} = stream_it(symbol)
    {:noreply, assign(socket, :symbol, symbol)}
  end

  # "on submit" for menu1:
  # select a symbol, submit and push_navigate
  def handle_event("stream", %{"symbol" => symbol}, socket) do
    :ok = clean_stream()
    {:ok, _} = stream_it(symbol)
    socket = assign(socket, :symbol, symbol)

    # path =
    #   URI.new!("/chart")
    #   |> URI.append_query(URI.encode_query(%{symbol: symbol}))
    #   |> URI.to_string()

    {:noreply, push_navigate(socket, to: ~p"/chart?symbol=#{symbol}", replace: true)}
  end

  @doc """
  Capture the broadcasted data when "/p1" subscribed
  """
  @impl true
  def handle_info(%{topic: "price", event: _event, payload: payload}, socket) do
    if Map.get(socket.assigns, :current_path) == "/p1",
      do: send_update(NavbarWeb.P1Comp, id: 1, price_update: payload)

    {:noreply, socket}
  end

  @doc """
  Collect all dynamically supervised streaming process, stop them, and start a new one
  """
  def clean_stream do
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
  end

  def stream_it(symbol) do
    StreamSymbolSup.start(symbol)
  end
end
