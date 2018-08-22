include("./duelLogic.jl")

const SAMPLES = 1000 # number of duels in the simulation
const WINNING_REWARD = -1e4 # less is better, objective is to minimize
const LOSING_PENALTY = 1e4 # how many points it cost to be below 50% winning rate
const POINT_LIMIT = 0 # how many GURPS character points do we allow
const OVER_THE_POINT_LIMIT_PENALTY = 1e7 # penalty for characters exceeding the above limit
const TEMPERATURE = 4 # randomness in each step
const ITERATIONS = 1000 # number of iterations before stopping the sim and annuncing result
const STARTING_VECTOR = [10, 10, 10] # values for Strength, Dexterity and Health the sim will start with
const OPPONENT = [10, 10, 10] # values for Strength, Dexterity and Health of the opponent. The sim does not mutate these values
const DMG_DICE = 2 # how many D6 dice will be rolled to determine the dmg dealt on successfull hit
const PISTOL_SKILL = 2 # how much GURPS bonus to basic skill in pistol the duelists have. This is not mutated by the sim.
const MAX_ROUNDS = 10 # after that many rounds the duel is considered lost if the opponent (P2) is not disabled

function costFun(x)
    duels = [begin 
            # initial hitpoints = stregth
            p1 = Player(PISTOL_SKILL, x[1], x[2], x[3], DMG_DICE, x[1], false, false, "P1")
            p2 = Player(PISTOL_SKILL, OPPONENT[1], OPPONENT[2], OPPONENT[3], DMG_DICE, OPPONENT[1], false, false, "P2")
            duel(p1, p2, MAX_ROUNDS)[1] 
        end for i in 1:SAMPLES]
    points = 10(x[1] - 10) + 20(x[2]-10) + 10(x[3]-10) # Strength and Health cost 10 GURPS points, Dex 20
    if points > POINT_LIMIT
        pointLimitPenalty = OVER_THE_POINT_LIMIT_PENALTY
    else
        pointLimitPenalty = 0
    end
    winningRate = round(count(duels) / length(duels), digits=2)
    if winningRate < 0.5
        winningFactor = LOSING_PENALTY * (1 - winningRate)# less than 0.5 means you are losing
    else
        winningFactor = WINNING_REWARD * winningRate
    end
    infoStr = `winning factor: $(round(winningFactor, digits=2)) points: $points winning %: $winningRate`
    (points + winningFactor + pointLimitPenalty, infoStr)
end

function monteCarlo(;iters=1000, temp=2, eps=1)
    IV = STARTING_VECTOR
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
            println(`$IV cost:$(round(currentCost, digits=2))`)
        end
    end
    IV, currentCost
end

IV, cost = monteCarlo(iters=ITERATIONS, temp=TEMPERATURE)
println(`Optimal stats: Strength: $(IV[1]) Dexterity: $(IV[2]) Health: $(IV[3])  cost:$(round(cost, digits=2))`)
