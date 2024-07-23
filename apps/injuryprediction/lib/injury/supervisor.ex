defmodule Injury.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    port=4321
    children = [
      {Task, fn -> Injury.Injuryprediction.accept(port) end},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
