defmodule Injury.Main do
  def run(file_path, output_path) do
    data = Injury.Injury.load_data(file_path)
    model = Injury.NaiveBayesClassifier.train(data)


     mod=Injury.NaiveBayesClassifier.calculate_probabilities(model)


     s=Enum.sum(Enum.map(data,fn entry ->
      Injury.NaiveBayesClassifier.average(mod, entry.days, entry.part)


    end))


    tot=Injury.NaiveBayesClassifier.get_total_count(model)
   
    predictions = Enum.map(data, fn entry ->
      prediction = Injury.NaiveBayesClassifier.predict(mod, entry.days, entry.part,(s/tot))
      %{
        player_key: entry.player_key,
        player_name: entry.player_name,
        prediction: prediction
      }
    end)

    Injury.Injury.save_predictions(predictions, output_path)
    l="wrtitten to the file#{output_path}"
    l

  end
end
