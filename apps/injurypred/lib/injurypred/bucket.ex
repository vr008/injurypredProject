defmodule Injurypred.Bucket do
  use Agent, restart: :temporary

  def start_link(opts) do
    Agent.start_link(fn -> opts end)
  end

  def get(state) do
    Agent.get(state, fn data -> data end)
  end

  def put(state, value) do
    Agent.update(state, fn _data -> value end)
  end

  def putscore(state, key, value) do
    Agent.update(state, fn state -> Map.put(state, key, value) end)
  end

  def delete(state) do
    Agent.update(state, fn _data -> [] end)
  end

  def getscores(state, key) do
    Agent.get(state, fn state -> Map.fetch(state, key) end)
  end

  def updatefinishedgame(state, key, value) do
    Agent.update(state, fn state ->
      {:ok, va} = Map.fetch(state, key)
      Map.put(state, key, [value | va])
    end)
  end

  def getfinishedgame(state, key) do
    Agent.get(state, fn state ->
      case Map.fetch(state, key) do
        :error ->
          false

        val ->
          if key in val do
            true
          else
            false
          end
      end
    end)
  end
end
