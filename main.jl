using StatsBase

mutable struct Player
    basicSpeed::Float16
    pistols::UInt8
    dmgMultiplier::Float16
    strength::UInt8
    dexterity::UInt8
    health::UInt8
    intelligence::UInt8
    damageDice::UInt8
    damageMod::Int8
    hitPoints::Int64
    dodge::Int64
    disabled::Bool
    reeling::Bool
    dr::UInt8
end

function genericCharacter()
    st = 10
    dex = 10
    ht = 10
    int = 10
    basicSpeed = (ht + dex) / 4
    pistols = 2
    HP = st
    dod = round(3 + basicSpeed)
    Player(basicSpeed, pistols, 1.0, st, dex, ht, int, 2, 1, HP, dod, false, false, 0)
end

function roll6()::UInt8
    a = rand(UInt8) % 6 # 1x k6
    a + 1
end

function basicRoll()
    a = rand(UInt8, 3).%6 # 3x k6
    a.+1 # UInt8 starts at 0
    sum(a)
end

function attackRoll(effectiveSkill)
    s =basicRoll()
    success = false
    critical = false
    if s < 5 # always a success
        success = true
        critical = true
    elseif s <= effectiveSkill
        success = true
    end
    if s == 5 || s == 6 # possible critical hit
        critical = effectiveSkill - 10 >= s
    end
    (success=success, critical=critical)
end

function dodge(threshold)
    s = basicRoll()
    if s < 5
        return true
    elseif s > 16
        return false
    elseif s < threshold
        return true
    else
        return false
    end
end

function getDmg(character::Player)::Int64
    dmgRolls =  [roll6() for i in 0:character.damageDice]
    sum(dmgRolls) + character.damageMod
end

function checkHP(character::Player)
    if character.hitPoints < character.strength / 3 && !character.reeling
        character.dodge =  character.dodge / 2
        character.reeling = true
    elseif character.hitPoints < 0 && basicRoll() > character.health
            character.disabled = true
    end        
end


function duelAttackPhase(attacker::Player, defender::Player)
    res = attackRoll(attacker.pistols + attacker.dexterity )
    if res.success
        dres = dodge(defender.basicSpeed)
        if !dres
            dm = getDmg(attacker)
            dm = max(dm - defender.dr, 0)
            defender.hitPoints = defender.hitPoints - dm
        end
    end
end

function duel(player1::Player, player2::Player)
    if player1.basicSpeed < player2.basicSpeed
        p1 = player2
        p2 = player1
    else
        p1 = player1
        p2 = player2
    end
    rounds = 0
    while (!player1.disabled && !player2.disabled)
        duelAttackPhase(p1, p2)
        checkHP(p2)
        duelAttackPhase(p2, p1)
        checkHP(p1)
        rounds = rounds + 1
    end
    (!player1.disabled, rounds) # player one won true/false
end


results = [begin 
    p1 = genericCharacter()
    p2 = genericCharacter()
    duel(p1, p2)[1] 
    end
    for i in 1:5000]
prop = count(results) / length(results)
println(prop)


