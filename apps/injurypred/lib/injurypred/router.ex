defmodule Injurypred.Router do
  @doc """
  Dispatch request
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    first = :binary.first(bucket)

    # Try to find an entry in the table() or raise
    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    # If the entry node is the current node
    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      {Injurypred.Router, elem(entry, 1)}
      |> Task.Supervisor.async(Injurypred.Router, :route, [bucket, mod, fun, args])
      |> Task.await()
    end
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect(bucket)} in table #{inspect(table())}"
  end

  @doc """
  The routing table.
  """
  def table do
    # Replace computer-name with your local machine name
    Application.fetch_env!(:injurypred, :routing_table)
  end
end
