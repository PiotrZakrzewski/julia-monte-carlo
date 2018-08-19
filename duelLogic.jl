const MAX_ROUNDS = 10

mutable struct Player
    pistols::UInt8
    strength::UInt8
    dexterity::UInt8
    health::UInt8
    damageDice::UInt8
    hitPoints::Int64
    disabled::Bool
    reeling::Bool
    name::String
end

function basicRoll()
    sum(rand(1:6, 3))
end

function basicTest(threshold, debug)
    s = basicRoll()
    debug && println(`Rolled: $s against threshold of $threshold`)
    if s < 5 # always a success
        return true
    elseif s > 16 # always a failure
        return false
    elseif s <= threshold
        return true
    else
        return false
    end
end

function getDmg(damageDice)
    dmgRolls =  [rand(1:6) for i in 1:damageDice]
    sum(dmgRolls)
end

function checkHP(character::Player, debug=false)
    timesSt = abs(character.hitPoints / character.strength)
    debug && println(`timesSt: $timesSt hp:$(character.hitPoints) st:$(character.strength)`)
    if character.hitPoints < (character.strength / 3) && !character.reeling
        debug && println(`Reeling`)
        character.reeling = true
    end
    if character.hitPoints < 0 && basicRoll() > (character.health - timesSt)
        debug && println(`Disabled`)
            character.disabled = true
    else
        debug && println("still fighting")
    end        
end


function duelAttackPhase(attacker::Player, defender::Player, debug= false)
    if basicTest(attacker.pistols + attacker.dexterity, debug )
        debug && println(`Attacker $(attacker.name): shot successfull`)
        basicSpeed = (defender.health + defender.dexterity) / 4
        dodge = round(3 + basicSpeed)
        if defender.reeling
            dodge = round(dodge / 2)
        end
        if !basicTest(dodge, debug)
            dmg = getDmg(attacker.damageDice)
            debug && println(`Defender $(defender.name) failed to dodge. Received dmg: $dmg`)
            debug && println(`current hp: $(defender.hitPoints)`)
            defender.hitPoints -= dmg
            debug && println(`new hp: $(defender.hitPoints)`)
        else
            debug && println("Dodge successfull")
        end
    else
        debug && println("Failed attack")
    end
end

function duel(player1::Player, player2::Player, debug=false)
    p1BasicSpeed = (player1.health + player1.dexterity) / 4
    p2BasicSpeed = (player2.health + player2.dexterity) / 4
    if p1BasicSpeed == p2BasicSpeed
        if rand(Bool)
            debug && println(`Player2 goes first`)
            p1 = player2
            p2 = player1
        else    
            debug && println(`Player1 goes first`)
            p1 = player1
            p2 = player2
        end
    elseif p1BasicSpeed < p2BasicSpeed
        debug && println(`Player2 goes first`)
        p1 = player2
        p2 = player1
    else
        debug && println(`Player1 goes first`)
        p1 = player1
        p2 = player2
    end
    rounds = 0
    while (!player1.disabled && !player2.disabled)
        duelAttackPhase(p1, p2, debug)
        checkHP(p2, debug)
        if p2.disabled
            break
        end
        duelAttackPhase(p2, p1, debug)
        checkHP(p1, debug)
        debug && println(`Round $rounds`)
        debug && println(`Player1: $p1`)
        debug && println(`Player2: $p2`)
        rounds += 1
        if rounds > MAX_ROUNDS
            return (false, rounds)
        end
    end
    (!player1.disabled, rounds) # player one won true/false
end
