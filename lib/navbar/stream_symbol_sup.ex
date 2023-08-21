defmodule Navbar.StreamSymbolSup do
  @moduledoc """
  Starts a DynamicSupervisor to persist the Websocket connection
  """
  def start(symbol) do
    DynamicSupervisor.start_child(MyDynSup, {Navbar.StreamSymbol, [symbol: symbol]})
  end

  def stop_sup(pid) do
    DynamicSupervisor.terminate_child(MyDynSup, pid)
  end
end
