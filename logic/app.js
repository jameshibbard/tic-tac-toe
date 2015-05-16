// Generated by CoffeeScript 1.9.0
(function() {
  $(function() {
    var Tic;
    Tic = {
      data: {
        turns: 0,
        x: {},
        o: {},
        gameOver: false
      },
      initialize: function() {
        this.data.gameOver = false;
        this.setPlayerNames();
        this.retrieveStats();
        this.prepareBoard();
        this.assignRoles();
        this.setUpNotifications();
        return this.addListeners();
      },
      setPlayerNames: function() {
        this.data.player1 = $("input[name='pl-1']").val();
        return this.data.player2 = $("input[name='pl-2']").val();
      },
      retrieveStats: function() {
        this.data.p1stats = localStorage[this.data.player1] || {
          wins: 0,
          loses: 0
        };
        if (typeof this.data.p1stats === "string") {
          this.data.p1stats = JSON.parse(this.data.p1stats);
        }
        this.data.p2stats = localStorage[this.data.player2] || {
          wins: 0,
          loses: 0
        };
        if (typeof this.data.p2stats === "string") {
          return this.data.p2stats = JSON.parse(this.data.p2stats);
        }
      },
      prepareBoard: function() {
        var square, _i, _results;
        $("form").hide();
        $("#board").empty();
        $(".alerts").removeClass("welcome").show().text("X Goes First");
        $(".notifications").empty().show();
        _results = [];
        for (square = _i = 0; _i <= 8; square = ++_i) {
          _results.push($("<div>", {
            "class": "square"
          }).appendTo("#board"));
        }
        return _results;
      },
      assignRoles: function() {
        var roles;
        roles = ["X", "O"].sort(function() {
          return 0.5 - Math.random();
        });
        this.data.rolep1 = roles[0];
        return this.data.rolep2 = roles[1];
      },
      setUpNotifications: function() {
        this.addNotification(this.data.player1 + " is playing " + this.data.rolep1);
        this.addNotification(this.data.player2 + " is playing " + this.data.rolep2);
        this.addNotification(this.data.player1 + " has " + this.data.p1stats.wins + " wins and " + this.data.p1stats.loses + " loses");
        return this.addNotification(this.data.player2 + " has " + this.data.p2stats.wins + " wins and " + this.data.p2stats.loses + " loses");
      },
      addNotification: function(msg) {
        return $(".notifications").append($("<p>", {
          text: msg
        }));
      },
      addListeners: function() {
        return $(".square").click(function() {
          if (Tic.data.gameOver === false && !$(this).text().length) {
            if (Tic.data.turns % 2 === 0) {
              $(this).html("X").addClass("x moved");
            } else if (Tic.data.turns % 2 !== 0) {
              $(this).html("O").addClass("o moved");
            }
            Tic.data.turns++;
            Tic.checkEnd();
            if (Tic.data.gameOver !== true && $(".moved").length >= 9) {
              return Tic.addToScore("none");
            }
          }
        });
      },
      addToScore: function(winningParty) {
        this.data.turns = 0;
        this.data.x = {};
        this.data.o = {};
        this.data.gameOver = true;
        $(".notifications").append("<a class='play-again'>Play Again?</a>");
        if (winningParty === "none") {
          this.showAlert("The game was a tie");
          return false;
        }
        if (this.data.rolep1[winningParty] != null) {
          ++this.data.p1stats.wins;
        } else {
          ++this.data.p1stats.loses;
        }
        if (this.data.rolep2[winningParty] != null) {
          ++this.data.p2stats.wins;
        } else {
          ++this.data.p2stats.loses;
        }
        localStorage[this.data.player1] = JSON.stringify(this.data.p1stats);
        return localStorage[this.data.player2] = JSON.stringify(this.data.p2stats);
      },
      checkWin: function() {
        var key, value, _ref, _ref1, _results;
        _ref = this.data.x;
        for (key in _ref) {
          value = _ref[key];
          if (value >= 3) {
            localStorage.x++;
            this.showAlert("X wins");
            this.data.gameOver = true;
            this.addToScore("X");
          }
        }
        _ref1 = this.data.o;
        _results = [];
        for (key in _ref1) {
          value = _ref1[key];
          if (value >= 3) {
            localStorage.o++;
            this.showAlert("O wins");
            this.data.gameOver = true;
            _results.push(this.addToScore("O"));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      },
      checkEnd: function() {
        var col, column, diagonal, diagonals, end, middle, row, start, _i, _j, _k, _l, _len, _len1, _results;
        this.data.x = {};
        this.data.o = {};
        diagonals = [[0, 4, 8], [2, 4, 6]];
        for (_i = 0, _len = diagonals.length; _i < _len; _i++) {
          diagonal = diagonals[_i];
          for (_j = 0, _len1 = diagonal.length; _j < _len1; _j++) {
            col = diagonal[_j];
            this.checkField(col, 'diagonal');
          }
          this.checkWin();
          this.emptyStorageVar('diagonal');
        }
        _results = [];
        for (row = _k = 0; _k <= 2; row = ++_k) {
          start = row * 3;
          end = (row * 3) + 2;
          middle = (row * 3) + 1;
          this.checkField(start, 'start');
          this.checkField(middle, 'middle');
          this.checkField(end, 'end');
          this.checkWin();
          for (column = _l = start; start <= end ? _l <= end : _l >= end; column = start <= end ? ++_l : --_l) {
            this.checkField(column, 'horizontal');
          }
          this.checkWin();
          _results.push(this.emptyStorageVar('horizontal'));
        }
        return _results;
      },
      emptyStorageVar: function(storageVar) {
        this.data.x[storageVar] = null;
        return this.data.o[storageVar] = null;
      },
      checkField: function(field, storageVar) {
        if ($(".square").eq(field).hasClass("x")) {
          if (this.data.x[storageVar] != null) {
            return this.data.x[storageVar]++;
          } else {
            return this.data.x[storageVar] = 1;
          }
        } else if ($(".square").eq(field).hasClass("o")) {
          if (this.data.o[storageVar] != null) {
            return this.data.o[storageVar]++;
          } else {
            return this.data.o[storageVar] = 1;
          }
        }
      },
      showAlert: function(msg) {
        return $(".alerts").text(msg).slideDown();
      }
    };
    $("form").on("submit", function(evt) {
      var $inputs, namesIndentical, namesNotEntered;
      evt.preventDefault();
      $inputs = $("input[type='text']");
      namesNotEntered = $inputs.filter(function() {
        return this.value.trim() !== "";
      }).length !== 2;
      namesIndentical = $inputs[0].value === $inputs[1].value;
      if (namesNotEntered) {
        return Tic.showAlert("Player names cannot be empty");
      } else if (namesIndentical) {
        return Tic.showAlert("Player names cannot be identical");
      } else {
        return Tic.initialize();
      }
    });
    return $("body").on("click", ".play-again", function() {
      return Tic.initialize();
    });
  });

}).call(this);
