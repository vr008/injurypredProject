defmodule Injury.Playersparser do
  def load_data(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&parse_row/1)
  end

  defp parse_row(row) do
    columns = String.split(row, ",")

    %{
      player_key: Enum.at(columns, 0),
      player_name: Enum.at(columns, 1),
      ruled_out: Enum.at(columns, 2)
    }
  end

  def select_random_value(path) do
    data = load_data(path)
    yes_players = Enum.filter(data, fn %{ruled_out: ruled_out} -> ruled_out == "Yes" end)
    no_players = Enum.filter(data, fn %{ruled_out: ruled_out} -> ruled_out == "No" end)
    selected_yes = Enum.take_random(yes_players, 5)
    selected_no = Enum.take_random(no_players, 5)

    selected_players = selected_yes ++ selected_no
    {:ok, counter} = Agent.start_link(fn -> 1 end)

    Enum.map(Enum.shuffle(selected_players), fn map ->
      s_no = Agent.get_and_update(counter, fn count -> {count, count + 1} end)
      Map.put(map, :s_no, s_no)
    end)
  end

  def predict_score(data, picks) do
    k = length(Enum.filter(data, fn %{player_key: _, player_name: _, ruled_out: a,s_no: s_no} -> s_no in picks and a == "Yes"  end))
    k * 10
  end
end
