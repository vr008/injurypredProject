defmodule Injurypred.User do
  defstruct name: nil, password: nil

  def data() do
    [
      %Injurypred.User{name: "Neil", password: 1234},
      %Injurypred.User{name: "hakash", password: 1234},
      %Injurypred.User{name: "vignesh", password: 1234},
      %Injurypred.User{name: "aswanth", password: 1234},
      %Injurypred.User{name: "random", password: 1234}
    ]
  end

  def exists(uname, pass) do
    k =
      Enum.filter(data(), fn %Injurypred.User{name: name, password: password} ->
        name == uname and password == pass
      end)

    if k == [] do
      true
    else
      false
    end
  end
end
