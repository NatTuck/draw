
import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Rect, Line } from 'react-konva';
import deepFreeze from 'deep-freeze';
import _ from 'lodash';

export default function game_init(root, game, channel) {
  ReactDOM.render(<Game game={game} channel={channel} />, root);
}

class Game extends React.Component {
  constructor(props) {
    super(props);
    this.btn_down = false;
    this.channel = props.channel;
    this.state = {
      name: window.user_name,
      guess: "",
      last_guess: "",
      game: props.game,
    };

    this.channel.on("draw", ({x, y}) => {
      if (this.state.game.mode == "guess") {
        this.draw(x, y);
      }
    });

    this.channel.on("line_done", ({points}) => {
      if (this.state.game.mode == "guess") {
        this.line_done(points);
      }
    });

    this.channel.on("clear", (_payload) => {
      if (this.state.game.mode == "guess") {
        this.update_game({ points: [], lines: [] });
      }
    });

    this.channel.on("good_guess", ({user, word, game}) => {
      let game1 = this.state.game;

      if (this.state.name !== user) {
        game1 = game;
      }

      let msg = `${user} guessed ${word} (correct)`;
      let state1 = _.assign({}, this.state, { game: game1, last_guess: msg });
      this.setState(state1);
      console.log(msg);
    });

    this.channel.on("bad_guess", ({user, word, correct}) => {
      window.correct_word = correct;
      let msg = `${user} guessed ${word} (wrong)`;
      let state1 = _.assign({}, this.state, { last_guess: msg });
      this.setState(state1);
      console.log(msg);
    });
  }

  update_state(pairs) {
    let state1 = _.assign({}, this.state, pairs);
    this.setState(deepFreeze(state1));
  }

  update_game(pairs) {
    let game1 = _.assign({}, this.state.game, pairs);
    this.update_state({game: game1});
  }

  draw(x, y) {
    let points1 = _.concat(this.state.game.points, [x, y]);
    this.update_game({points: points1});
  }

  line_done(_points) {
    let game = this.state.game;
    let lines1 = game.lines;
    if (game.points.length > 0) {
      lines1 = _.concat(game.lines, [game.points]);
    }
    this.update_game({ lines: lines1, points: [] });
  }

  mouse_move(ev) {
    if (this.state.game.mode != "draw") {
      return;
    }

    if ((ev.evt.buttons & 1) === 0) {
      return;
    }

    let local_draw = () => {
      if (this.btn_down) {
        let x = ev.evt.layerX;
        let y = ev.evt.layerY;
        this.draw(x, y);
        this.channel.push("draw", {x: x, y: y});
      }
    }

    _.debounce(local_draw, 50)();
  }

  mouse_down(ev) {
    if (this.state.game.mode != "draw") {
      return;
    }

    this.setState(_.assign(this.state, { points: [] }));
    this.btn_down = true;
  }

  mouse_up(ev) {
    if (this.state.game.mode != "draw") {
      return;
    }

    let points1 = this.state.game.points;
    this.line_done();
    this.channel.push("line_done", {points: points1});
    this.btn_down = false;
  }

  update_guess(ev) {
    this.update_state({ guess: ev.target.value });
  }

  guessed_right({game}) {
    console.log("server says guess right", game)
    this.update_state({ game: game });
  }

  send_guess(_ev) {
    let guess = this.state.guess;
    this.channel.push("guess", { word: guess })
        .receive("ok", this.guessed_right.bind(this))
        .receive("error", (err) => console.log("guess error", err));
    this.update_state({ guess: "" });
  }

  guess_key_press(ev) {
    if (ev.key == "Enter") {
      this.send_guess(ev);
    }
  }

  send_clear(_ev) {
    this.channel.push("clear", {})
        .receive("ok", (msg) => console.log("clear ok", msg))
        .receive("error", (err) => console.log("clear err", err));
    this.update_game({ points: [], lines: [] });
  }

  render() {
    let ww = 1024;
    let hh = 768;

    let controls = null;
    if (this.state.game.mode == "draw") {
      controls = <div className="controls draw-controls row">
        <div className="column">
          <p>Draw word: {this.state.game.word}</p>
        </div>
        <div className="column">
          <button onClick={this.send_clear.bind(this)}>Clear</button>
        </div>
      </div>;
    }
    else {
      controls = <div className="controls guess-controls row">
        <div className="column">
          <p>{this.state.game.active} is drawing.</p>
        </div>
        <div className="column">
          <input type="text" name="word" value={this.state.guess}
                 onChange={this.update_guess.bind(this)}
                 onKeyPress={this.guess_key_press.bind(this)} />
        </div>
        <div className="column">
          <button onClick={this.send_guess.bind(this)}>Guess</button>
        </div>
      </div>;
    }

    let lines = _.map(this.state.game.lines, (line, ii) =>
      <Line key={ii} points={line} tension={0} stroke="black" strokeWidth={2} />);

    return <div>
      { controls }
      <div className="row">
        <div className="column">
          <p>Last guess: { this.state.last_guess }</p>
        </div>
      </div>
      <div className="row">
        <div className="drawbox column">
          <Stage width={ww} height={hh}
                 onContentMousemove={this.mouse_move.bind(this)}
                 onContentMouseUp={this.mouse_up.bind(this)}
                 onContentMouseDown={this.mouse_down.bind(this)}>
            <Layer>
              <Rect x={0} y={0} width={ww} height={hh} />
              <Line points={this.state.game.points} tension={0}
                    stroke="black" strokeWidth={2} />
              { lines }
            </Layer>
          </Stage>
        </div>
      </div>
    </div>;
  }
}

