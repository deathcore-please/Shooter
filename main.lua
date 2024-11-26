function love.load()
    sprites = {}

    math.randomseed(os.time())

    sprites.zombie = love.graphics.newImage('Sprites/zombie.png')
    sprites.bullet = love.graphics.newImage('Sprites/bullet.png')
    sprites.background = love.graphics.newImage('Sprites/background.png')
    sprites.player = love.graphics.newImage('Sprites/player.png')

    player = {}
    zombies = {}
    projectiles = {}
    player.x = (love.graphics.getWidth()-60)/2
    player.y = (love.graphics.getHeight()-60)/2
    player.r = 0
    player.speed = 200
    
    timer1 = 2
    gameSpeed = 1
    score = 0

    gameState = 0

    gameFont = love.graphics.newFont(40)
    scoreFont = love.graphics.newFont(20)
    gameOverFont = love.graphics.newFont(60)
end

function love.update(dt)
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end

    if gameState == 1  or gameState == 4 then
        
        player.r = math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX())+ math.pi

        if player.y <= 5 then
            player.y = 5
        elseif love.keyboard.isDown("w") then
            player.y = player.y - player.speed*dt
        end

        if player.y >= love.graphics.getHeight()-5 then
            player.y = love.graphics.getHeight()-5
        elseif love.keyboard.isDown("s") then
            player.y = player.y + player.speed*dt
        end

        if player.x <= 5 then
            player.x = 5
        elseif love.keyboard.isDown("a") then
            player.x = player.x - player.speed*dt
        end

        if player.x >= love.graphics.getWidth()-5 then
            player.x = love.graphics.getWidth()-5
        elseif love.keyboard.isDown("d") then
            player.x = player.x + player.speed*dt
        end

        for i, z in ipairs(zombies) do
            if distanceBetween(z.x, z.y, player.x, player.y) < 35 then
                z.dead = true 
                if gameState == 4 then
                    gameState = 2
                elseif gameState == 1 then
                    gameState = 4
                    player.speed = 320
                end
            else
                    z.r = math.atan2(player.y - z.y, player.x - z.x)
                    z.x = z.x + (math.cos(z.r)*z.speed*dt)
                    z.y = z.y + (math.sin(z.r)*z.speed*dt)
                
            end
        end

        for i, p in ipairs(projectiles) do
            p.x = p.x + (math.cos(p.r)*p.speed*dt)
            p.y = p.y + (math.sin(p.r)*p.speed*dt)
        end

        for i = #projectiles, 1, -1 do
            local p = projectiles[i]
            if p.x<0 or p.y<0 or p.x>love.graphics.getWidth() or p.y>love.graphics.getHeight() then
                table.remove(projectiles, i)
            end
        end

        for i, z in ipairs(zombies) do
            for j, p in ipairs(projectiles) do
                if distanceBetween(z.x, z.y, p.x, p.y)<20 then
                    p.dead = true
                    z.dead = true
                    score = score + 5
                end
            end
        end
        
        score = score + dt

        for i = #zombies, 1, -1 do
            local z = zombies[i]
            if z.dead == true then
                table.remove(zombies, i)
            end
        end


        if gameState == 1 then
            gameSpeed = gameSpeed + 0.05*dt
        elseif gameState == 4 then
            gameSpeed = gameSpeed + 0.13*dt
        end

        timer1 = timer1 + gameSpeed*dt
        if timer1 > 3 then
            timer1 = 0
            spawnZombie()
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background)

    if gameState == 0 then
        love.graphics.setFont(gameFont)
        love.graphics.printf("Welcome to Shooter!", 0, 100, love.graphics.getWidth(), "center")
        love.graphics.setFont(scoreFont)
        love.graphics.printf("Press space to start!", 0, 250, love.graphics.getWidth(), "center")
    elseif gameState == 1 or gameState == 2 or gameState == 3 or gameState == 4 then
        love.graphics.print("Score: " .. math.ceil(score), 0, 0)
        for i, p in ipairs(projectiles) do
            love.graphics.draw(sprites.bullet, p.x, p.y, nil, 0.5, nil, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
        end
        if gameState == 4 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.draw(sprites.player, player.x, player.y, player.r, nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.draw(sprites.player, player.x, player.y, player.r, nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
        end
        for i, z in ipairs(zombies) do
            love.graphics.draw(sprites.zombie, z.x, z.y, z.r, nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
        end
        --love.graphics.print(timer)
    end
    if gameState == 2 then
        love.graphics.setFont(gameOverFont)
        love.graphics.printf("GAME OVER", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setFont(gameFont)
        love.graphics.printf("Score: " .. math.ceil(score), 0, 260, love.graphics.getWidth(), "center")
        love.graphics.setFont(scoreFont)
        love.graphics.printf("Press space to start again", 0, 350, love.graphics.getWidth(), "center")
        --love.graphics.print(score)
    end
    if gameState == 3 then
        love.graphics.printf("Press P to resume", 0, 250, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "space" then
        if gameState == 0 then
            gameState = 1
        elseif gameState == 1 or gameState == 4 then
            spawnProjectile()
        elseif gameState == 2 then
            timer1 = 0
            gameSpeed = 1
            gameState = 1
            score = 0
            for i = #zombies, 1, -1 do
                local z = zombies[i]
                table.remove(zombies, i)
            end
        end
    elseif key == "p" then
        if gameState == 1 or gameState == 4 then
            gameState = 3
        elseif gameState == 3 then
            gameState = 1
        end
    end
end

function distanceBetween(x1, y1, x2, y2)
    d = math.sqrt(((y2-y1)^2)+((x2-x1)^2))
    return d
end

function spawnZombie()
    local zombie = {}
    local x = math.random(1,2)
    local y = math.random(1,2)
    if x == 1 then
        zombie.x = love.math.random(0, player.x-80)
    else
        zombie.x = love.math.random(player.x+80, love.graphics.getWidth())
    end
    if y == 1 then
        zombie.y = love.math.random(0, player.y-80)
    else
        zombie.y = love.math.random(player.y+80, love.graphics.getHeight())
    end
    zombie.r = 0
    zombie.speed = 100
    zombie.dead = false
    table.insert(zombies, zombie)
end

function spawnProjectile()
    local projectile = {}
    projectile.x = player.x
    projectile.y = player.y
    projectile.r = player.r
    projectile.speed = 300
    projectile.dead = false
    table.insert(projectiles, projectile)
end
