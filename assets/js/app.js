// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket";
import game_init from './game';

window.addEventListener("load", (_ev) => {
  let root = document.getElementById('root');
  if (root) {
    socket.connect();
    let channel = socket.channel("game:draw", {});
    let on_join = (resp) => {
      console.log("join", resp);
      game_init(root, resp.game, channel);
    };
    channel.join()
      .receive("ok", on_join)
      .receive("error", resp => { console.log("Unable to join", resp); });
  }
});

