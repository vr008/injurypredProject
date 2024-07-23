defmodule Injury.Application do
  use Application
  def start(_type, _args) do
    children = [
      {Injury.Supervisor,[]}
    ]

    opts = [strategy: :one_for_one, name: Injury.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
