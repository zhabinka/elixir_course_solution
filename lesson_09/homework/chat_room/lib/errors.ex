defmodule ChatRoom.Errors do
  defmodule UserNotFoundError do
    defexception []

    @impl true
    def exception(_), do: %UserNotFoundError{}

    @impl true
    def message(_), do: "User not found"
  end

  defmodule RoomNotFoundError do
    defexception []

    @impl true
    def exception(_), do: %RoomNotFoundError{}

    @impl true
    def message(_), do: "Room not found"
  end

  defmodule NotAllowedError do
    defexception []

    @impl true
    def exception(_), do: %NotAllowedError{}

    @impl true
    def message(_), do: "Not allowed"
  end

  defmodule RoomReachedLimit do
    defexception []

    @impl true
    def exception(_), do: %RoomReachedLimit{}

    @impl true
    def message(_), do: "Room reached limit"
  end
end
