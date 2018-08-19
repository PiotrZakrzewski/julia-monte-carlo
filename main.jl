using StatsBase
include("./duelLogic.jl")

const SAMPLE_SIZE = 100
const SAMPLES = 100
const WINNING_REWARD = -1e7 # less is better, objective is to minimize
const LOSING_PENALTY = 1e7
const POINT_LIMIT = 0
const OVER_THE_POINT_LIMIT_PENALTY = 1e7


function costFun(x)
    topRes = [
    begin
        results = [begin 
        # initial hitpoints = stregth
        p1 = Player(2, x[1], x[2], x[3], 2, x[1], false, false, "P1")
        p2 = Player(2, 10, 10, 10, 2, 10, false, false, "P2")
        duel(p1, p2)[1] 
        end
        for i in 1:SAMPLE_SIZE]
        count(results) / length(results)
    end
    for j in 1:SAMPLES]
    points = (x[1] - 10) * 10 + (x[2] - 10) * 10 + (x[3] - 10) * 20
    if points > POINT_LIMIT
        pointLimitPenalty = OVER_THE_POINT_LIMIT_PENALTY
    else
        pointLimitPenalty = 0
    end
    av = round(sum(topRes) /length(topRes), digits=2)
    if av < 0.5
        winningFactor = LOSING_PENALTY * (1 - av)# less than 0.5 means you are losing
    else
        winningFactor = WINNING_REWARD * av
    end
    infoStr = `winning factor: $winningFactor points: $points winning %: $av`
    (points + winningFactor + pointLimitPenalty, infoStr)
end

function monteCarlo(;iters=1000, temp=2, eps=1)
    IV = [10, 10, 10]
    currentCost, info = costFun(IV)
    println(info)
    getSwitch() = begin 
        can = rand(1:10) <= temp
        if !can
            return 0
        elseif rand(Bool)
            return 1
        else
            return -1
        end
    end
    for i in 1:iters
        switchVec = [getSwitch() for i in 1:3]
        newIV = [0,0,0]
        for j in 1:3
            newIV[j] = max(switchVec[j] + IV[j], 1)
        end
        newCost, info = costFun(newIV)
        if newCost < currentCost
            currentCost = newCost
            IV = newIV
            println(info)
            println(`$IV cost:$currentCost`)
        end
    end
    IV, currentCost
end

IV, cost = monteCarlo(iters=1000, temp=5)
println(`Optimal stats: Strength: $(IV[1]) Dexterity: $(IV[2]) Health: $(IV[3])  cost:$cost`)
