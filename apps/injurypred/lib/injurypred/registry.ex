defmodule Injurypred.Registry do
  @moduledoc """
  This module uses GenServer to make key-value pair buckets
  """
  use GenServer
  alias Injurypred.Bucket, as: Buck

  @doc """
  Starts the client
  """
  def start_link(opts \\ %{}) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  to get the pid of the registered bucket
  """
  def get(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] ->
        {:ok, pid}

      [] ->
        :error
    end
  end

  @doc """
  Creates a new bucket
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  @doc """
  Put picks into bucket
  """
  def put(server, name, picks) do
    GenServer.call(server, {:put, name, picks})
  end

  @doc """
  delete bucket
  """
  def delete(server, name) do
    GenServer.call(server, {:delete, name})
  end

  @doc """
  To get the score of the client
  """
  def getscores(server, name) do
    case get(server, "scores") do
      {:ok, pid} ->
        Buck.getscores(pid, name)

      :error ->
        :error
    end
  end

  @doc """
  To update client's score
  """
  def putscores(server, name, score) do
    case get(server, "scores") do
      {:ok, pid} ->
        Buck.putscore(pid, name, score)

      :error ->
        create(server, "scores")
        {:ok, pid} = get(server, "scores")
        Buck.putscore(pid, name, score)
    end
  end

  def gameflow(server) do
    case get(server, "gameflow") do
      {:ok, pid} ->
        pid

      :error ->
        create(server, "gameflow")
        {:ok, pid} = get(server, "gameflow")
        Buck.putscore(pid, "usersonline", [])
        Buck.putscore(pid, "usersfinished", [])
        pid
    end
  end

  def finishedgame(server, name) do
    {:ok, pid} = get(server, "gameflow")

    case Buck.getfinishedgame(pid, name) do
      true ->
        Buck.updatefinishedgame(pid, "usersfinished", name)

      false ->
        :error
    end
  end

  def findwinner(server) do
    {:ok, pid} = get(server, "scores")
    map = Buck.get(pid)
    Enum.reduce(map, {[], nil}, fn {key, value}, {keys, max_value} ->
      cond do
        max_value == nil ->
          {[key], value}

        value > max_value ->
          {[key], value}

        value == max_value ->
          {[key | keys], max_value}

        true ->
          {keys, max_value}
      end
    end)

  end

  def endgame(server) do
    {:ok, pid} = get(server, "gameflow")
    {:ok, l1} = Buck.getscores(pid, "usersonline")
    {:ok, l2} = Buck.getscores(pid, "usersfinished")
    if length(l1) == length(l2) do
      true
    else
      false
    end
  end

  @doc """
  Server-side implementation
  """
  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case get(names, name) do
      {:ok, pid} ->
        {:reply, pid, {names, refs}}

      :error ->
        {:ok, pid} =
          DynamicSupervisor.start_child(Injurypred.BucketSupervisor, {Buck, %{}})

        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:reply, pid, {names, refs}}
    end
  end

  @impl true
  def handle_call({:put, name, picks}, _from, {names, refs}) do
    case get(names, name) do
      {:ok, pid} ->
        Buck.put(pid, picks)
        {:reply, :ok, {names, refs}}

      :error ->
        {:reply, "Not found", {names, refs}}
    end
  end

  @impl true
  def handle_call({:delete, name}, _from, {names, refs}) do
    case get(names, name) do
      {:ok, _pid} ->
        :ets.delete(names, name)
        {:reply, :ok, {names, refs}}

      :error ->
        {:reply, "Not found", {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
