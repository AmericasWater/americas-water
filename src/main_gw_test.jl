workspace()
using Mimi

include("Groundwater.jl")

println("Creating model...")
m = Model()

setindex(m, :time, collect(1:10))
setindex(m, :aquifers, collect(1:5))

# Add all of the components
#reservoir = addcomponent(m, Reservoir);
#waternetwork = initwaternetwork(m);
aquifer = initaquifer(m);

# Run it and time it!
@time run(m)

println("Piezohead :")
println(round(m[:Aquifer, :piezohead],2))

println("Lateral flows: :")
println(round(m[:Aquifer, :lateralflows],2))

println("Optimizing...")

# Set up the constraints
constraints = Function[]
for aa in 1:m.indices_counts[:aquifers]
    for tt in 1:m.indices_counts[:time]
        limitbelow(m) = m[:Aquifer, :piezohead][aa, tt] - m.components[:Aquifer].Parameters.layerthick[aa] - m.components[:Aquifer].Parameters.depthaquif[aa] # piezohead < layerthick
        limitabove(m) = -m[:Aquifer, :piezohead][aa, tt] # piezohead > 0
        constraints = [constraints; limitbelow; limitabove]
    end
end

# Make sure that all constraints are currently satisifed
# All must be < 0
map(constraint -> constraint(m), constraints)

function objective(m)
    # Benfits from withdrawal, but costs for pumping from depth
    return sum(m.components[:Aquifer].Parameters.withdrawal) + 1e6 * sum(m[:Aquifer, :piezohead] + repmat(m.components[:Aquifer].Parameters.depthaquif, 1, m.indices_counts[:time]))
end

using OptiMimi

optprob = problem(m, [:Aquifer], [:withdrawal], [0.], [5e5], objective, constraints=constraints, algorithm=:GUROBI_LINPROG);

println("Solving...")
@time sol = solution(optprob);
println(sol)

setparameters(m, [:Aquifer], [:withdrawal], sol)
objective(m)
