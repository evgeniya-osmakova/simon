<template>
  <div class="container">
    <h1 class="header">Simon Says</h1>
    <div class="simon">
      <ul>
        <li class="red" v-on:click="checkPermission($event.target.dataset)"
            v-bind:class="{ hoverable: this.state === 'playerTurn' }"
            v-bind:style="redIsActivated" data-color="red"></li>
        <li class="blue" v-on:click="checkPermission($event.target.dataset)"
            v-bind:class="{ hoverable: this.state === 'playerTurn' }"
            v-bind:style="blueIsActivated" data-color="blue"></li>
        <li class="round" v-bind:style="isNewRoundStart">New round!</li>
        <li class="yellow" v-on:click="checkPermission($event.target.dataset)"
            v-bind:class="{ hoverable: this.state === 'playerTurn' }"
            v-bind:style="yellowIsActivated" data-color="yellow"></li>
        <li class="green" v-on:click="checkPermission($event.target.dataset)"
            v-bind:class="{ hoverable: this.state === 'playerTurn' }"
            v-bind:style="greenIsActivated" data-color="green"></li>
      </ul>
    </div>
    <div class="game-info">
      <h2>Round: <span>{{ isPlayerAnswerCorrect ? round : 0}}</span></h2>
      <button class="button" v-bind:class="{ hoverable: !isBtnDisable }"
              v-bind:disabled="isBtnDisable" v-on:click="onStart">Start</button>
      <p v-bind:style="toggledFailedDisplay">
        Sorry, you lost after
        <span>{{ round }}</span>
        rounds!
      </p>
    </div>
    <div class="game-options">
      <h2>Game Mode:</h2>
      <div>
        <input  id="user-data-normal" v-on:click="changeMode($event.target.value)"
                type="radio" name="mode" value="normal" checked="">
        <label for="user-data-normal">Normal</label>
      </div>
      <div>
        <input id="user-data-sound-only" v-on:click="changeMode($event.target.value)"
               type="radio" name="mode" value="sound-only">
        <label for="user-data-sound-only">Sound Only</label>
      </div>
      <div>
        <input id="user-data-light-only" v-on:click="changeMode($event.target.value)"
               type="radio" name="mode" value="light-only">
        <label for="user-data-light-only">Light Only</label>
      </div>
      <div>
        <input id="user-data-free-board" v-on:click="changeMode($event.target.value)" type="radio"
               name="mode" value="free-board" v-bind:disabled="this.state === 'simonTurn'" >
        <label for="user-data-free-board">Free board</label>
      </div>
      <h2>Game Speed:</h2>
      <div>
        <input id="user-data-free-low" v-on:click="changeSpeed($event.target.value)"
             type="radio" name="speed" value="low" checked="">
        <label for="user-data-free-low">Low</label>
      </div>
      <div>
        <input id="user-data-free-medium" v-on:click="changeSpeed($event.target.value)"
               type="radio" name="speed" value="medium">
        <label for="user-data-free-medium">Medium</label>
      </div>
      <div>
        <input id="user-data-free-high" v-on:click="changeSpeed($event.target.value)"
             type="radio" name="speed" value="high">
        <label for="user-data-free-high">High</label>
      </div>
    </div>
    <div data-action="sound">
      <span v-html="audio"></span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      state: 'beforeStart',
      speed: 1500,
      mode: 'normal',
      round: 0,
      currentTask: [],
      currentColor: '',
      currentCorrectAnswerIndex: 0,
      isPlayerAnswerCorrect: true,
      pause: 400,
      newRound: false,

    };
  },
  computed: {
    audio() {
      if (this.mode === 'light-only') {
        return '';
      }
      const mapping = {
        red: '1',
        blue: '2',
        yellow: '3',
        green: '4',
      };
      const code = mapping[this.currentColor];
      return `<audio autoplay>
        <source src="http://www.kellyking.me/projects/simon/sounds/${code}.ogg" type="audio/ogg">
        <source src="http://www.kellyking.me/projects/simon/sounds/${code}.mp3" type="audio/mp3">
      </audio>`;
    },
    isBtnDisable() {
      switch (this.state) {
        case 'beforeStart': {
          return false;
        }
        case 'simonTurn': {
          return true;
        }
        case 'playerTurn': {
          return this.mode === 'free-board';
        }
        case 'losing': {
          return false;
        }
        default:
          throw new Error(`Unknown game state ${this.state}`);
      }
    },
    isNewRoundStart() {
      return (this.newRound) ? 'display: block' : 'display: none';
    },
    toggledFailedDisplay() {
      return (this.state === 'losing') ? 'display: block' : 'display: none';
    },
    redIsActivated() {
      return (this.currentColor === 'red' && this.mode !== 'sound-only') ? 'opacity: 1;' : 'opacity: 0.6;';
    },
    blueIsActivated() {
      return (this.currentColor === 'blue' && this.mode !== 'sound-only') ? 'opacity: 1;' : 'opacity: 0.6;';
    },
    yellowIsActivated() {
      return (this.currentColor === 'yellow' && this.mode !== 'sound-only') ? 'opacity: 1;' : 'opacity: 0.6;';
    },
    greenIsActivated() {
      return (this.currentColor === 'green' && this.mode !== 'sound-only') ? 'opacity: 1;' : 'opacity: 0.6;';
    },
  },
  methods: {
    resetSettings() {
      this.state = 'simonTurn';
      this.round = 0;
      this.currentTask = [];
      this.currentColor = '';
      this.currentCorrectAnswerIndex = 0;
      this.isPlayerAnswerCorrect = true;
    },
    onStart() {
      if (this.mode !== 'free-board') {
        this.resetSettings();
        this.generateTask();
      }
    },
    generateTask() {
      this.newRound = true;
      this.round += 1;
      const colors = ['red', 'blue', 'yellow', 'green'];
      this.currentTask.push(colors[Math.floor(Math.random() * colors.length)]);
      this.executeTask();
    },
    executeTask() {
      const changeColor = (colors) => {
        if (colors.length === 0) {
          this.state = 'playerTurn';
          this.currentColor = '';
        }
        this.currentColor = '';
        setTimeout(() => {
          const [first, ...rest] = colors;
          this.currentColor = first;
          setTimeout(() => changeColor(rest), this.speed);
        }, this.pause);
      };

      setTimeout(() => {
        this.newRound = false;
        changeColor(this.currentTask);
      }, this.speed);
    },
    checkPermission(value) {
      // eslint-disable-next-line no-unused-expressions
      (this.state === 'playerTurn') ? this.checkPlayerAnswer(value) : this.currentColor = '';
    },
    checkPlayerAnswer(value) {
      const { color } = value;
      this.currentColor = color;
      setTimeout(() => {
        this.currentColor = '';
        if (this.mode !== 'free-board') {
          const correctAnswer = this.currentTask[this.currentCorrectAnswerIndex];
          if (correctAnswer === color) {
            this.isPlayerAnswerCorrect = true;
            // eslint-disable-next-line no-unused-expressions
            (this.currentCorrectAnswerIndex < this.currentTask.length - 1)
              ? this.currentCorrectAnswerIndex += 1
              : this.updateRound();
          } else {
            this.isPlayerAnswerCorrect = false;
            this.state = 'losing';
          }
        }
      }, this.pause);
    },
    changeMode(mode) {
      if (this.mode === 'free-board') {
        this.state = 'beforeStart';
      }
      this.mode = mode;
      if (this.mode === 'free-board') {
        this.resetSettings();
        this.state = 'playerTurn';
      }
    },
    updateRound() {
      this.currentCorrectAnswerIndex = 0;
      this.state = 'simonTurn';
      this.generateTask();
    },
    changeSpeed(speed) {
      const speedValue = {
        low: 1500,
        medium: 1000,
        high: 400,
      };
      this.speed = speedValue[speed];
    },
  },
};
</script>

<style>
  .container {
    display: grid;
    grid-template-areas: "header header" "simon info" "simon options" "footer footer";
    grid-template-columns: 6fr 4fr;
    grid-template-rows: 1fr 2fr 6fr 1fr;
  }

  .header {
    margin-left: auto;
    margin-right: auto;
    grid-area: header;
  }

  .simon {
    grid-area: simon;
    background: #fff;
    margin-left: auto;
    margin-right: 100px;
    margin-top: 60px;
    width: 302px;
    height: 295px;
    border-radius: 150px 150px 150px 150px;
    box-shadow: 2px 1px 12px #aaa;
  }

  .game-info {
    grid-area: info;
  }

  .game-options {
    grid-area: options;
  }

  footer {
    grid-area: footer;
    position: absolute;
    bottom: 20px;
  }

  .game-info button {
    width: 5em;
    box-sizing: border-box;
    font-size: 1.4em;
    border-radius: 10px 10px 10px 10px;
    background: #6DABE8;
    border: none;
    padding: 0.3em 0.6em;
  }

  .round {
    position: absolute;
    top: 250px;
    left: 600px;
    width: 100%;
  }

  .red, .blue, .yellow, .green {
    opacity: 0.6;
    height: 290px;
    border-radius: 150px 150px 150px 150px;
    position: absolute;
    text-indent: 10000px;
  }

  ul, li {
    padding: 0;
    margin: 0;
  }

  .red hoverable:hover {
    cursor: pointer;
    border: 2px solid black;
  }
  .blue hoverable:hover {
    cursor: pointer;
    border: 2px solid black;
  }
  .yellow hoverable:hover {
    cursor: pointer;
    border: 2px solid black;
  }
  .green hoverable:hover {
    cursor: pointer;
    border: 2px solid black;
  }
  .button hoverable:hover {
    cursor: pointer;
    border: 2px solid black;
  }

  .game-info button hoverable:hover {
    border: 2px solid black;
  }

  .red {
    background: #FF5643;
    clip: rect(0px, 300px, 150px, 150px);
    width: 296px;
  }

  .blue {
    background: dodgerblue;
    clip: rect(0px, 150px, 150px, 0px);
    width: 300px;
  }

  .yellow {
    background: #FEEF33;
    clip: rect(150px, 150px, 300px, 0px);
    width: 300px;
  }

  .green {
    background: #BEDE15;
    clip: rect(150px,300px, 300px, 150px);
    width: 296px;
  }
</style>
