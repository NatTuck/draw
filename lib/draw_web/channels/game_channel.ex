defmodule DrawWeb.GameChannel do
  use DrawWeb, :channel

  def join("game:draw", payload, socket) do
    if authorized?(payload) do
      user = socket.assigns[:user]
      Draw.GameAgent.user_join(user)
      game = Draw.Game.view_for(Draw.GameAgent.get(), user)
      {:ok, %{ "game" => game }, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("draw", %{"x" => x, "y" => y}, socket) do
    game = Draw.GameAgent.get()
    if socket.assigns[:user] == game.active do
      Draw.GameAgent.update fn(game) ->
        Draw.Game.add_point(game, x, y)
      end
      broadcast(socket, "draw", %{x: x, y: y})
      IO.puts "draw broadcast"
    end
    {:noreply, socket}
  end

  def handle_in("line_done", %{"points" => points}, socket) do
    game = Draw.GameAgent.get()
    if socket.assigns[:user] == game.active do
      Draw.GameAgent.update fn(game) ->
        Draw.Game.line_done(game)
      end
      broadcast(socket, "line_done", %{points: points})
    end
    {:noreply, socket}
  end

  def handle_in("clear", _payload, socket) do
    game = Draw.GameAgent.get()
    if socket.assigns[:user] == game.active do
      Draw.GameAgent.update fn(game) ->
        Draw.Game.clear(game)
      end
      broadcast(socket, "clear", %{})
    end
    {:noreply, socket}
  end

  def handle_in("guess", %{"word" => word}, socket) do
    # FIXME: Should reply to user (with draw_view if correct)

    user = socket.assigns[:user]
    game = Draw.GameAgent.get()
    if user != game.active do
      # Player can guess
      if word == game.word do
        game1 = Draw.GameAgent.new_game(user)
        guess_view = Draw.Game.guess_view(game1)
        draw_view = Draw.Game.draw_view(game1)
        broadcast(socket, "good_guess", %{user: user, word: word, game: guess_view})
        {:reply, {:ok, %{game: draw_view}}, socket}
      else
        broadcast(socket, "bad_guess", %{user: user, word: word, correct: game.word})
        {:reply, {:error, %{msg: "bad guess"}}, socket}
      end
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  #def handle_in("ping", payload, socket) do
  #  {:reply, {:ok, payload}, socket}
  #end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  #def handle_in("shout", payload, socket) do
  #  broadcast socket, "shout", payload
  #  {:noreply, socket}
  #end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
