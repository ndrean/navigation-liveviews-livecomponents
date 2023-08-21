defmodule NavbarWeb.HomePageLive do
  use NavbarWeb, :live_view
  import Phoenix.VerifiedRoutes
  alias Navbar.StreamSymbolSup

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

  # <%!-- phx-click={JS.push("symbol", value: %{symbol: @symbol})}> --%>
  attr :symbol, :string, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Home page</h1>
    <.simple_form id="symbol-form" for={@form} phx-submit="stream" phx-change="stop_stream">
      <.input
        type="select"
        prompt="please select a symbol"
        autofocus
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
  def handle_params(_p, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop_stream", msg, socket) do
    res = DynamicSupervisor.which_children(MyDynSup)

    case length(res) do
      0 ->
        :ok

      _ ->
        res
        |> Enum.each(fn {_, pid, :worker, [Navbar.StreamSymbol]} ->
          DynamicSupervisor.terminate_child(MyDynSup, pid)
        end)
    end

    {:noreply, socket}
  end

  def handle_event("stream", %{"symbol" => symbol}, socket) do
    case symbol do
      "" ->
        {:noreply, socket}

      _ ->
        {:ok, _pid} = StreamSymbolSup.start(symbol)
        {:noreply, push_navigate(socket, to: ~p"/chart?symbol=#{symbol}")}
    end
  end
end
