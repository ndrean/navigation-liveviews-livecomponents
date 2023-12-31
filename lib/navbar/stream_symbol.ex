defmodule Navbar.StreamSymbol do
  use WebSockex
  require Logger
  @url "wss://ws.coincap.io/prices"
  @json_lib Phoenix.json_library()

  # Constructs the WebSocket URL for a given symbol.
  defp ws_url(symbol) do
    @url
    |> URI.new!()
    |> URI.append_query(URI.encode_query(%{assets: symbol}))
    |> URI.to_string()
  end

  def start_sup(symbol: symbol) do
    DynamicSupervisor.start_child(MyDynSup, {Navbar.StreamSymbol, [symbol: symbol]})
  end

  @doc """
  Starts the WebSocket connection for the given symbol.
  """
  def start_link(symbol: symbol) do
    symbol
    |> ws_url()
    |> WebSockex.start_link(__MODULE__, {:symbol, symbol})
  end

  @doc """
  Handles the WebSocket connection event.
  """
  @impl true
  def handle_connect(_conn, {:symbol, symbol} = state) do
    Logger.info("Connected______: #{symbol}")
    {:ok, state}
  end

  @doc """
  Handles the WebSocket disconnection event.
  """
  @impl true
  def handle_disconnect(_conn, {:symbol, symbol} = state) do
    Logger.warning("Disconnected from #{inspect(ws_url(symbol))} for #{symbol}")
    {:reconnect, state}
  end

  @doc """
  Handles incoming WebSocket frames.
  """
  @impl true
  def handle_frame({:text, msg}, {:symbol, symbol} = state) do
    case @json_lib.decode(msg) do
      {:ok, event} ->
        process(event, symbol)
        {:ok, state}

      {:error, reason} ->
        Logger.error("Error #{inspect(reason)}")
        {:close, state}
    end

    {:ok, state}
  end

  @doc """
  Processes incoming events and broadcasts them.
  """
  def process(event, symbol) do
    event |> dbg()
    event_with_time = Map.put(event, :time, DateTime.utc_now())

    :ok = NavbarWeb.Endpoint.broadcast_from(self(), "price", "new_#{symbol}", event_with_time)
  end
end
