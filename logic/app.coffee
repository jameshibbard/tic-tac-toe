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
      playerData.rolep1 = {}
      playerData.rolep2 = {}
      playerData.rolep1[randomRole] = true
      playerData.rolep2[randomRole2] = true


      template = "<p>X starts first!</p>"
      template += "<p>#{playerData.player1} is playing #{randomRole}</p>"
      template += "<p>#{playerData.player2} is playing #{randomRole2}</p>"
      template += "<p>#{playerData.player1} has #{playerData.p1stats.wins} wins and #{playerData.p1stats.loses} loses</p>"
      template += "<p>#{playerData.player2} has #{playerData.p2stats.wins} wins and #{playerData.p2stats.loses} loses</p>"
      @addMessage(template, "div", "game-data")

    initialize: ->
      playerData.player1 = $("input[name='pl-1']").val()
      playerData.player2 = $("input[name='pl-2']").val()
      playerData.p1stats = localStorage[playerData.player1] || wins: 0, loses: 0
      if typeof playerData.p1stats is "string" then playerData.p1stats = JSON.parse playerData.p1stats
      playerData.p2stats = localStorage[playerData.player2] || wins: 0, loses: 0
      if typeof playerData.p2stats is "string" then playerData.p2stats = JSON.parse playerData.p2stats
      $("form").hide 'slow'
      $("#tic").html("")
      $(".alerts").slideUp 900
      @data.gameOver = false
      $("<div class='tic'>").appendTo("#tic") for tic in [0..8]
      @.addListeners()
      @.assignRoles()
    addToScore: (winningParty) ->
      @.data =
        turns: 0
        x: {}
        o: {}
        gameOver: true

      @addMessage "Play Again?"
      if winningParty is "none"
        @.addAlert "The game was a tie."

        return false

      if playerData.rolep1[winningParty]? then ++playerData.p1stats.wins else ++playerData.p1stats.loses
      if playerData.rolep2[winningParty]? then ++playerData.p2stats.wins else ++playerData.p2stats.loses

      localStorage[playerData.player1] = JSON.stringify playerData.p1stats
      localStorage[playerData.player2] = JSON.stringify playerData.p2stats
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
    addAlert: (msg) ->
      $("p.gameAlert").slideUp('slow').remove()
      $(".alerts").append "<p class='gameAlert'> #{msg} </p>"
      $(".alerts").slideDown "slow"
      $("body").animate(
        scrollTop: $(".alerts").offset().top
        ,  'slow'
      )
    addMessage: (msg = "", nonVoidTag = "a" , classes = "play-again", replaceContents = true,  voidAnchor = true) ->
      messagesContainer = $("#messages")
      messagesContainer.hide()
      if replaceContents then messagesContainer.html ""
      if msg then messagesContainer.append("<#{nonVoidTag} #{voidAnchor && nonVoidTag is 'a' ? 'href=\'JavaScript:void(0)\'' : ''} class='#{classes}'> #{msg} </#{nonVoidTag}>")
      else messagesContainer.html ""
      messagesContainer.fadeIn 700


  playerData = {}

  $("form").on "submit", (evt) ->
    evt.preventDefault()
    namesValid = $("input:text").filter(->
      return @value.trim() is not ""
    ).length is 2
    if namesValid then Tic.initialize() else Tic.addAlert("Player names cannot be empty")
  $(".close").click ->
    $(@).parents(".alerts").slideUp 'slow'
  $("body").on("click",".play-again", -> Tic.initialize())