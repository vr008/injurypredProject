defmodule InjuryPred.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Injurypred.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert Injurypred.Bucket.get(bucket) == []

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

    Injurypred.Bucket.delete(bucket)
  end
end
