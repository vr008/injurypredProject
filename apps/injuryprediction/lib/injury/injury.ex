defmodule Injury.Injury do
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
      days: String.to_integer(Enum.at(columns, 9)),
      part: Enum.at(columns, 3),
      player_name: Enum.at(columns, 2)
    }
  end

  def categorize_days(days) do
    cond do
      days <= 7 -> "1"
      days <= 28 -> "2"
      days <= 42 -> "3"
      true -> "4"
    end
  end

  def save_predictions(predictions, file_path) do
    File.write!(file_path, "player_key,playername,ruled_out\n" <> Enum.map_join(predictions, "\n", fn %{player_key: player_key,player_name: player_name, prediction: prediction} -> "#{player_key},#{player_name},#{prediction}" end))
  end
end

defmodule Injury.NaiveBayesClassifier do
  defstruct counts: %{}, total_count: 0

  def train(data) do
    data
    |> Enum.reduce(%Injury.NaiveBayesClassifier{}, fn entry, model ->
      days_category = Injury.Injury.categorize_days(entry.days)
      update_model(model, days_category, entry.part)
    end)
  end


  def calculate_probabilities(%Injury.NaiveBayesClassifier{counts: counts, total_count: total_count}) do
    {days_category_counts, part_counts} =
      Enum.split_with(counts, fn {{category, _}, _} -> category == :days_category end)

    days_category_probabilities = Enum.reduce(days_category_counts, %{}, fn {{_, value}, count}, acc ->
      probability = count / total_count
      Map.put(acc, value, probability)
    end)

    part_probabilities = Enum.reduce(part_counts, %{}, fn {{_, value}, count}, acc ->
      probability = count / total_count
      Map.put(acc, value, probability)
    end)

    %{
      days_category_probabilities: days_category_probabilities,
      part_probabilities: part_probabilities
    }
  end
  def get_total_count(%Injury.NaiveBayesClassifier{total_count: total_count}) do
    total_count
  end
  defp update_model(%Injury.NaiveBayesClassifier{counts: counts, total_count: total_count} = model, days_category, part) do
    new_counts =
      counts
      |> update_count({:days_category,days_category}, 1)
      |> update_count({:part, part}, 1)

    %Injury.NaiveBayesClassifier{model | counts: new_counts, total_count: total_count + 1}
  end


  def calculate_ruled_out_probability(probabilities, players) do
    Enum.map(players, fn player ->
      days_category_prob = Map.get(probabilities.days_category_probabilities, player.days_category, 0)
      part_prob = Map.get(probabilities.part_probabilities, player.part, 0)
      ruled_out_prob = days_category_prob * part_prob

      Map.put(player, :ruled_out_probability, ruled_out_prob)
    end)
  end
  defp update_count(counts, key, value) do
    Map.update(counts, key, value, &(&1 + value))
  end
  def average(model, days, part) do
    days_category = Injury.Injury.categorize_days(days)

    days_prob = Map.get(model.days_category_probabilities,days_category)
    part_prob=Map.get(model.part_probabilities,part)


    ruledoout=days_prob*part_prob
    ruledoout




  end
  def predict(model, days, part,avg) do
    days_category = Injury.Injury.categorize_days(days)

    days_prob = Map.get(model.days_category_probabilities,days_category)
    part_prob=Map.get(model.part_probabilities,part)


    ruledoout=days_prob*part_prob
    if ruledoout>avg, do: to_string("Yes"), else: to_string("No")
  end
end
