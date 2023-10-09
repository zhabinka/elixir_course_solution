defmodule ChatRoom do
  alias ChatRoomModel, as: M
  alias ChatRoom.Errors, as: E

  @spec join_room(M.user_name(), M.room_name()) :: :ok | {:error, atom}
  def join_room(user_name, room_name) do
    try do
      user = validate_user!(user_name)
      room = validate_room!(room_name)
      validate_access!(room, user)
      validate_room_reach_limit!(room)
    rescue
      error ->
        message =
          Exception.message(error)
          |> String.downcase()
          |> String.split()
          |> Enum.join("_")
          |> String.to_atom()

        {:error, message}
    end
  end

  def validate_user!(user_name) do
    case get_user(user_name) do
      {:ok, user} -> user
      {:error, _} -> raise E.UserNotFoundError
    end
  end

  def validate_room!(room_name) do
    case get_room(room_name) do
      {:ok, room} -> room
      {:error, _} -> raise E.RoomNotFoundError
    end
  end

  def validate_access!(room, user) do
    if public?(room) do
      :ok
    else
      case member?(user, room) do
        true -> :ok
        false -> raise E.NotAllowedError
      end
    end
  end

  def validate_room_reach_limit!(room) do
    case reached_limit?(room) do
      false -> :ok
      true -> raise E.RoomReachedLimit
    end
  end

  @users [
    %M.User{name: "User 1"},
    %M.User{name: "User 2"},
    %M.User{name: "User 3"}
  ]

  @rooms [
    %M.Room{name: "Room 1", type: :public},
    %M.Room{name: "Room 2", type: :private, members: ["User 1", "User 2"]},
    %M.Room{name: "Room 3", type: :public, limit: 10}
  ]

  @online %{
    "Room 1" => 60,
    "Room 2" => 30,
    "Room 3" => 10
  }

  @spec get_user(M.user_name()) :: {:ok, M.User.t()} | {:error, :not_found}
  def get_user(name) do
    res =
      Enum.find(
        @users,
        fn user -> user.name == name end
      )

    if res, do: {:ok, res}, else: {:error, :not_found}
  end

  @spec get_room(M.room_name()) :: {:ok, M.Room.t()} | {:error, :not_found}
  def get_room(name) do
    res =
      Enum.find(
        @rooms,
        fn %M.Room{name: room_name} -> room_name == name end
      )

    if res, do: {:ok, res}, else: {:error, :not_found}
  end

  @spec public?(M.Room.t()) :: boolean
  def public?(room), do: room.type == :public

  @spec member?(M.User.t(), M.Room.t()) :: boolean
  def member?(user, room) do
    Enum.member?(room.members, user.name)
  end

  @spec reached_limit?(M.Room.t()) :: boolean
  def reached_limit?(room) do
    room.limit <= @online[room.name]
  end
end
