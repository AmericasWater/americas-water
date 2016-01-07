using Mimi
using Distributions

include("world.jl")

@defcomp Pumping begin
    regions = Index()

    conversion = Parameter() # mgh to
    elecvsfuel = Parameter(index=[regions, time])
    depth = Parameter(index=[region, time])
    withdraws = Parameter(index=[region, time])

    elecwatts = Variable(index=[regions, time])
    fuelwatts = Variable(index=[regions, time])
end

function timestep(c::Pumping, tt::Int)
    v = c.Variables
    p = c.Parameters
    d = c.Dimensions

    for rr in d.regions
        v.eleccons[rr, tt] = p.elecvsfuel[rr, tt] * p.conversion * p.depth[rr, tt] * p.withdraws[rr, tt]
        v.fuelcons[rr, tt] = (1 - p.elecvsfuel[rr, tt]) * p.conversion * p.depth[rr, tt] * p.withdraws[rr, tt]
    end
end
