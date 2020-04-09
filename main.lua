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
    ['paddles'] = GenerateQuadsPaddles(gTextures['main'])
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

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return PlayState() end
  }
  gStateMachine:change('start')

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

function displayFPS()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end
