defmodule ChatRoom do
  alias ChatRoomModel, as: M

  @spec join_room(M.user_name(), M.room_name()) :: :ok | {:error, atom}
  def join_room(user_name, room_name) do
    with(
      {:ok, user} <- validate_user(user_name),
      {:ok, room} <- validate_room(room_name),
      :ok <- validate_access(room, user),
      :ok <- validate_room_reach_limit(room)
    ) do
      :ok
    end
  end

  def validate_user(user_name) do
    case get_user(user_name) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> {:error, :user_not_found}
    end
  end

  def validate_room(room_name) do
    case get_room(room_name) do
      {:ok, room} -> {:ok, room}
      {:error, :not_found} -> {:error, :room_not_found}
    end
  end

  def validate_access(room, user) do
    if public?(room) do
      :ok
    else
      case member?(user, room) do
        true -> :ok
        false -> {:error, :not_allowed}
      end
    end
  end

  def validate_room_reach_limit(room) do
    case reached_limit?(room) do
      false -> :ok
      true -> {:error, :room_reached_limit}
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
