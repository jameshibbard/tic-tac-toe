$ ->
  Tic =
    data:
      turns: 0
      x: {}
      o: {}
      gameOver: false
    assignRoles: ->
      roles = ["X","O"]
      randomRole = roles[Math.floor(Math.random() * roles.length)]
      if randomRole is "X" then randomRole2 = "O" else randomRole2 = "X"
      @data.rolep1 = {}
      @data.rolep2 = {}
      @data.rolep1[randomRole] = true
      @data.rolep2[randomRole2] = true


      tpl = "<p>X starts first!</p>"
      tpl += "<p>#{@data.player1} is playing #{randomRole}</p>"
      tpl += "<p>#{@data.player2} is playing #{randomRole2}</p>"
      tpl += "<p>#{@data.player1} has #{@data.p1stats.wins} wins and #{@data.p1stats.loses} loses</p>"
      tpl += "<p>#{@data.player2} has #{@data.p2stats.wins} wins and #{@data.p2stats.loses} loses</p>"
      @addMessage(tpl)

    initialize: ->
      @data.player1 = $("input[name='pl-1']").val()
      @data.player2 = $("input[name='pl-2']").val()
      @data.p1stats = localStorage[@data.player1] || wins: 0, loses: 0
      if typeof @data.p1stats is "string" then @data.p1stats = JSON.parse @data.p1stats
      @data.p2stats = localStorage[@data.player2] || wins: 0, loses: 0
      if typeof @data.p2stats is "string" then @data.p2stats = JSON.parse @data.p2stats
      $("form").hide 'slow'
      $("#tic").html("")
      $(".notice, header div").slideUp 'slow'
      @data.gameOver = false
      $("<div class='tic'>").appendTo("#tic") for tic in [0..8]
      @.addListeners()
      @.assignRoles()
    addToScore: (winningParty) ->
      @data.turns = 0
      @data.x = {}
      @data.o = {}
      @data.gameOver = yes

      @addMessage "<a href='JavaScript:void(0)' class='play-again'>Play Again?</a>"
      if winningParty is "none"
        @.addAlert "The game was a tie."
        return false
      if @data.rolep1[winningParty]? then ++@data.p1stats.wins else ++@data.p1stats.loses
      if @data.rolep2[winningParty]? then ++@data.p2stats.wins else ++@data.p2stats.loses

      localStorage[@data.player1] = JSON.stringify @data.p1stats
      localStorage[@data.player2] = JSON.stringify @data.p2stats
    checkWin: ->

      for key,value of @.data.x
        if value >= 3
          localStorage.x++; @.addAlert "X wins"
          @.data.gameOver = true
          @addToScore("X")
      for key,value of @.data.o
        if value >= 3
          localStorage.o++; @.addAlert "O wins"
          @.data.gameOver = true
          @addToScore("O")





    checkEnd : ->
      @.data.x = {}
      @.data.o = {}
      #diagonal check
      diagonals = [[0,4,8], [2,4,6]]
      for diagonal in diagonals
         for col in diagonal
           @.checkField(col, 'diagonal')
         @.checkWin()
         @.emptyStorageVar('diagonal')
      for row in [0..2]

        start = row * 3
        end = (row * 3) + 2
        middle = (row * 3) + 1

        #vertical check
        @.checkField(start, 'start')
        @.checkField(middle, 'middle')

        @.checkField(end, 'end')
        @.checkWin()
        for column in [start..end]
        # horizontal check
          @.checkField(column, 'horizontal')

        @.checkWin()
        @.emptyStorageVar('horizontal')



    emptyStorageVar: (storageVar) ->
      @.data.x[storageVar] = null
      @.data.o[storageVar] = null
    checkField: (field, storageVar) ->
      if $(".tic").eq(field).hasClass("x")
        if @.data.x[storageVar]? then @.data.x[storageVar]++ else @.data.x[storageVar] = 1
      else if $(".tic").eq(field).hasClass("o")
        if @.data.o[storageVar]? then @.data.o[storageVar]++ else @.data.o[storageVar] = 1


    addListeners  : ->
      $(".tic").click ->

        if Tic.data.gameOver is no and not $(@).text().length
          if Tic.data.turns % 2 is 0 then $(@).html("X").addClass("x moved")
          else if Tic.data.turns % 2 isnt 0 then $(@).html("O").addClass("o moved")
          Tic.data.turns++
          Tic.checkEnd()
          if Tic.data.gameOver isnt yes and $(".moved").length >= 9 then Tic.addToScore("none")
    addAlert: (msg, position = '') ->
      if (position is 'center')
        $("header div").html("")
        .append "<p class='gameAlert'> #{msg} </p>"
        .slideDown 'slow'
      else
        $("div.notice")
        .children().remove()
        $("div.notice").append "<p class='gameAlert'> #{msg} </p>"
        .slideDown 'slow'
        $("body").animate(
          scrollTop: $("div.notice").offset().top
          ,  'slow'
      )
    addMessage: (msg = "", replaceContents = true) ->
      messagesContainer = $(".board")
      if replaceContents then messagesContainer.children().not("div").remove()
      if msg then messagesContainer.append msg
      messagesContainer.css("display" : "inline-block").show()

  $("form").on "submit", (evt) ->
    evt.preventDefault()
    namesValid = $("input[type='text']").filter(->
      return @.value.trim() isnt ""
    ).length is 2 and $("input:text").eq(0).val() isnt $("input:text").eq(1).val()
    if namesValid then Tic.initialize() else Tic.addAlert("Player names cannot be empty or the same", 'center')
  $(".close").click ->
    $(@).parent().slideUp 'slow'
  $("body").on("click",".play-again", -> Tic.initialize())