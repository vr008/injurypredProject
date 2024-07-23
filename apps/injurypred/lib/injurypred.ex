defmodule Injurypred do
  use Application

  @impl true
  def start(_type, _args) do
    Injurypred.Supervisor.start_link(name: Injurypred.Supervisor)
  end
end
