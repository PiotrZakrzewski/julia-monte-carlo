using StatsBase
include("./duelLogic.jl")

const SAMPLE_SIZE = 100
const SAMPLES = 100
const WINNING_REWARD = 100
const LOSING_PENALTY = 1e7


function costFun(x)
    topRes = [
    begin
        results = [begin 
        # initial hitpoints = stregth
        p1 = Player(2, x[1], x[2], x[3], 2, x[1], false, false)
        p2 = Player(2, 10, 10, 10, 2, 10, false, false)
        duel(p1, p2)[1] 
        end
        for i in 1:SAMPLE_SIZE]
        count(results) / length(results)
    end
    for j in 1:SAMPLES]
    points = (x[1] - 10) * 10 + (x[2] - 10) * 10 + (x[3] - 10) * 20
    av = round(sum(topRes) /length(topRes), digits=2)
    println(av)
    if av < 0.5
        winningFactor = LOSING_PENALTY * (1 - av)# less than 0.5 means you are losing
    else
        winningFactor = WINNING_REWARD * av
    end
    println(`winning factor: $winningFactor points: $points`)
    points + winningFactor
end

function monteCarlo(;iters=1000, temp=2, eps=1)
    IV = [10, 10, 10]
    currentCost = costFun(IV)
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
        switchVec = [getSwitch() for i in 1:4]
        newIV = [0,0,0]
        for j in 1:3
            newIV[j] = max(switchVec[j] + IV[j], 1)
        end
        newCost = costFun(newIV)
        if newCost < currentCost
            currentCost = newCost
            IV = newIV
        end
        println(`$IV cost:$currentCost`)
    end
    IV, currentCost
end

IV, cost = monteCarlo(iters=1000, temp=5)
println(`$IV  cost:$cost`)
