defmodule Draw.Game do
  defstruct active: nil, word: "boat", lines: [], points: []

  # A Game is a map with:
  #  - active: String - name of active user
  #  - word: String - word to be drawn/guessed
  #  - lines: List<List<Num>> - Lines drawn so far.
  #  - points: List<Num> - Points added to current line.

  def new(active_user) do
    %Draw.Game{active: active_user, word: random_word()}
  end

  def add_point(game, x, y) do
    %Draw.Game{ game | points: ([x, y] ++ game.points) }
  end

  def line_done(game) do
    %Draw.Game{ game | lines: [game.points | game.lines], points: [] }
  end

  def clear(game) do
    %Draw.Game{ game | lines: [], points: [] }
  end

  def view_for(game, user) do
    if user == game.active do
      draw_view(game)
    else
      guess_view(game)
    end
  end

  def draw_view(game) do
    game
    |> Map.drop([:__struct__])
    |> Map.put(:mode, "draw")
  end

  def guess_view(game) do
    game
    |> Map.drop([:__struct__, :word])
    |> Map.put(:mode, "guess")
  end

  def random_word() do
    Enum.random(~w{
      clock pizza donut bagel cookie
      dog cat horse frog snake
      house car train sandwich
      pumpkin book bucket dolphin
      egg baseball giraffe tire
      bread toast truck bus
      owl penguin bear panda
    })
  end
end
