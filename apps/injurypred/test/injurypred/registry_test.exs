defmodule Injurypred.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({Injurypred.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert Injurypred.Registry.get(registry, "clients") == :error

    Injurypred.Registry.create(registry, "clients")
    assert {:ok, bucket} = Injurypred.Registry.get(registry, "clients")

    Injurypred.Bucket.put(bucket, [
      %{player_key: "44449", player_name: "Keisean Nixon+"},
      %{player_key: "43518", player_name: "James Mitchell"},
      %{player_key: "47287", player_name: "Mike White"},
      %{player_key: "35611", player_name: "Rodney McLeod"},
      %{player_key: "46394", player_name: "Tariq Woolen"}
    ])

    assert Injurypred.Bucket.get(bucket) == [
             %{player_key: "44449", player_name: "Keisean Nixon+"},
             %{player_key: "43518", player_name: "James Mitchell"},
             %{player_key: "47287", player_name: "Mike White"},
             %{player_key: "35611", player_name: "Rodney McLeod"},
             %{player_key: "46394", player_name: "Tariq Woolen"}
           ]
  end

  test "bucket removed on exit", %{registry: registry} do
    Injurypred.Registry.create(registry, "Haks")
    {:ok, pid} = Injurypred.Registry.get(registry, "Haks")
    Agent.stop(pid)
    _ = Injurypred.Registry.create(registry,"Random")
    assert Injurypred.Registry.get(registry, "Haks") == :error
  end

  test "bucket removed on crash", %{registry: registry} do
    Injurypred.Registry.create(registry, "Haks")
    {:ok, pid} = Injurypred.Registry.get(registry, "Haks")
    Agent.stop(pid, :shutdown)
    _ = Injurypred.Registry.create(registry,"Random")
    assert Injurypred.Registry.get(registry, "Haks") == :error
  end

end
