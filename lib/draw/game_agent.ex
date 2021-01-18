defmodule Draw.GameAgent do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def user_join(user) do
    Agent.update __MODULE__, fn(game) ->
      if is_nil(game) do
        Draw.Game.new(user)
      else
        game
      end
    end
  end

  def get() do
    Agent.get(__MODULE__, &(&1))
  end

  def new_game(user) do
    game = Draw.Game.new(user)
    Agent.update __MODULE__, fn(_game) ->
      game
    end
    game
  end

  def update(func) do
    Agent.update(__MODULE__, func)
  end
end
