require 'src/Dependencies'

function love.load()

  love.graphics.setDefaultFilter('nearest', 'nearest')

  math.randomseed(os.time())

  love.window.setTitle('CS50 Breakout')

  gFonts = {
    ['small'] = love.graphics.newFont('assets/fonts/Retron2000.ttf', 8),
    ['medium'] = love.graphics.newFont('assets/fonts/Retron2000.ttf', 16),
    ['large'] = love.graphics.newFont('assets/fonts/Retron2000.ttf', 32)
  }
  love.graphics.setFont(gFonts['small'])

  gTextures =  {
    ['background'] = love.graphics.newImage('assets/sprites/background.png'),
    ['main'] = love.graphics.newImage('assets/sprites/breakout.png'),
    ['arrows'] = love.graphics.newImage('assets/sprites/arrows.png'),
    ['hearts'] = love.graphics.newImage('assets/sprites/hearts.png'),
    ['particle'] = love.graphics.newImage('assets/sprites/particle.png')
  }

  gFrames = {
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
  }

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  gSounds = {
    ['paddle-hit'] = love.audio.newSource('assets/sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('assets/sounds/score.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('assets/sounds/wall_hit.wav', 'static'),
    ['confirm']  = love.audio.newSource('assets/sounds/confirm.wav', 'static'),
    ['select']  = love.audio.newSource('assets/sounds/select.wav', 'static'),
    ['no-select'] = love.audio.newSource('assets/sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('assets/sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('assets/sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('assets/sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('assets/sounds/victory.wav', 'static'),
    ['recover'] = love.audio.newSource('assets/sounds/recover.wav', 'static'),
    ['high-score'] = love.audio.newSource('assets/sounds/high_score.wav', 'static'),
    ['pause'] = love.audio.newSource('assets/sounds/pause.wav', 'static'),
    ['music'] = love.audio.newSource('assets/sounds/music.wav', 'static')
  }

  lowerSoundsVolume()

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return PlayState() end,
    ['serve'] = function() return ServeState() end,
    ['victory'] = function() return VictoryState() end,
    ['high-scores'] = function() return HighScoreState() end,
    ['game-over'] = function() return GameOverState() end
  }
  gStateMachine:change('start', {
    highScores = loadHighScores()
  })

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  gStateMachine:update(dt)

  love.keyboard.keysPressed = {}
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end
end

function renderHealth(health)
  local healthX = VIRTUAL_WIDTH - 100

  for i = 1, health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX,4)
    healthX = healthX + 11
  end

  for i = 1, 3 - health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
    healthX = healthX + 11
  end
end

function renderScore(score)
  love.graphics.setFont(gFonts['small'])
  love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
  love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function love.draw()
  push:apply('start')

  local backgroundWidth = gTextures['background']:getWidth()
  local backgroundHeight = gTextures['background']:getHeight()

  love.graphics.draw(gTextures['background'],
    0, 0,
    0,
    VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1)
  )

  gStateMachine:render()

  displayFPS()

  push:apply('end')
end

function lowerSoundsVolume()
  for _, sound in pairs(gSounds) do
    sound:setVolume(0.2)
  end
end

function loadHighScores()
  love.filesystem.setIdentity('CS50Breakout')

  local fileInfo = love.filesystem.getInfo('breakout.lst')

  if fileInfo.FileType == nil then
    local scores = ''
    for i = 10, 1, -1 do
      scores = scores .. 'CTO\n'
      scores = scores .. tostring(i * 1000) .. '\n'
    end

    love.filesystem.write('breakout.lst', scores)
  else
    local name = true
    local currentName = nil
    local counter = 1

    local scores = {}

    for i = 1, 10 do
      scores[i] = {
        name = nil,
        score = nil
      }
    end

    for line in love.filesystem.lines('breakout.lst') do
      if name then
        scores[counter].name = string.sub(line, 1, 3)
      else
        scores[counter].score = tonumber(line)
        counter = counter + 1
      end

      name = not name
    end
  end

  return scores
end

function displayFPS()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end
