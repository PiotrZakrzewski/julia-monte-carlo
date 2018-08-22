include("./duelLogic.jl")

p1 = Player(2,1,10,10,2,1,false,false, "P1")
p2 = Player(2,10,10,10,2,10,false,false, "P2")
duel(p1, p2, 10, true)
wins = [begin
    p1 = Player(2,10,10,10,2,10,false,false, "P1")
    p2 = Player(2,1,10,10,2,1,false,false, "P2")
    duel(p1, p2, 10)[1]
end for i in 1:100]
ratio = count(wins) / length(wins)
println(`win ratio of P1 against P2: $ratio`)
