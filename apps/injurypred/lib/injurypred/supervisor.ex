defmodule Injurypred.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {Injurypred.Registry, name: Injurypred.Registry},
      {DynamicSupervisor, name: Injurypred.BucketSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Injurypred.RouterTasks},
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
