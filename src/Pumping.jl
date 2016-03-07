using Mimi
using Distributions

include("world.jl")

@defcomp Pumping begin
    regions = Index()

    conversion = Parameter() # to kWh, include efficiency
    depth = Parameter(index=[region, time])
    withdraws = Parameter(index=[region, time])

    kwh = Variable(index=[regions, time])

    elecvsfuel = Parameter(index=[regions, time])

    eleckwh = Variable(index=[regions, time])

    generatorefficiency = Parameter()
    fuelkwh = Variable(index=[regions, time])
end

function timestep(c::Pumping, tt::Int)
    v = c.Variables
    p = c.Parameters
    d = c.Dimensions

    for rr in d.regions
        v.kwh[rr, tt] = p.conversion * p.depth[rr, tt] * p.withdraws[rr, tt]
        v.eleccons[rr, tt] = p.elecvsfuel[rr, tt] * v.kwh[rr, tt]
        v.fuelcons[rr, tt] = (1 - p.elecvsfuel[rr, tt]) * v.kwh[rr, tt] / p.generatorefficiency
    end
end
