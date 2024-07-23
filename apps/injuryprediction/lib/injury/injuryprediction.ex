defmodule Injury.Injuryprediction do

  require Logger

  def accept(port) do

    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    serve(client)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.send(socket,"The file you want to read and write the prediction\n")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    a=Injury.Main.run("apps/injuryprediction/lib/injury/" <> data |> String.trim(), "apps/injuryprediction/lib/injury/predictions.csv")
    a
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

end
