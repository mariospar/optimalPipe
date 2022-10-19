using JuMP, NLopt, Plots, Unitful, DataFrames, CSV
include(joinpath("..","utils", "findnearest.jl"))

# Building the optimization Model
model = Model(NLopt.Optimizer)
set_optimizer_attribute(model, "algorithm", :AUGLAG)
set_optimizer_attribute(model, "local_optimizer", :LD_LBFGS)

#=========== Variables Decleration ===========#

n = 1.24 # Capital Investment Pipe Diameter Cost Correlation Exponent 
C_inv = 3.74*7950*pi/(4*8760) # Investment Capital Coefficient per Annum [=] €/year
ρ = 997 # Water Density [=] kg/m³
G = 5 # Molar Flow [=] kg/s
μ = 8.90e-4 # Water Viscocity [=] Pa⋅s 
η = 0.85 # Pump Efficiency
C_op = 0.117*8760/1000 # Operational Costs Coefficient per Annum [=] €⋅s³/m²⋅kg⋅year


#=========== Optimization ===========#

#= Declare Diameter `D` as the variable to be optimized. We constrain diameter values >= 0.01 because
D=0 => Cost -> ∞ and has no physical significance either. =#
@variable(model, 0.01 <= D)

# Setting the Non-Linear Objective Cost function and specifying we want the Minimum value of it
@NLobjective(model, Min, C_inv*(D^n) + 0.2548*(C_op*(η^-1)*(G^2.975)*(μ^0.025)*(ρ^-2)*(D^-4.975)))

# Running the optimization  
JuMP.optimize!(model)

println("✅ The diameter that minimizes total costs is $(round(value(D), digits=4)) m.")

#=========== Plotting ===========#

investmentCosts(d) = C_inv*(d^n)
operationalCosts(d) = 0.2548*(C_op*(η^-1)*(G^2.975)*(μ^0.025)*(ρ^-2)*(d^-4.975))
totalCosts(d) = investmentCosts(d) + operationalCosts(d)

# Using plotly.js as backend. If you don't want to use it you can just comment it out.
plotlyjs()

plot(investmentCosts, 0.1, 1,
        legend_position=:right, ls=:dash, label="Investment Costs", size=(1200,800), 
        dpi=1000, title = "Costs per Annum vs Diameter for a SS Pipe", lw = 2,
        xlabel="Diameter (m)", ylabel="Annual Costs (€/m⋅year)", xlims = (0.1,1), xticks=0.1:0.1:1
    )
plot!(operationalCosts, 0.1, 1, ls=:dash, lw = 2, label="Operational Costs")
plot!(totalCosts, 0.1, 1, lw = 2, label="Total Costs")
scatter!([value(D)], [totalCosts(value(D))], label="Minimum")

# Exports the total plot
savefig(joinpath("plots","Costs vs Diameter.png"))

println("📉 A plot has been saved under the `plots` directtory")

#=========== Nearest standard ===========#

D_inch = value(D)u"m" |> u"inch" # Converting m -> inches so as to match the standard

# Reading the standard dimenstions
df = CSV.read(joinpath("data", "schedules.csv"), DataFrame)
schedules = copy(df)

try
    # If optimal diameter is 5" bigger than the bigger entry in the pipe standards something went wrong
    if schedules.NPS[end] - ustrip(D_inch) < -5
        throw(error())
    end
    matching = findnearest(schedules.NPS, ustrip(D_inch))
    println("🔧 The following pipe standards are seemingly fitting your case:\n")
    println(view(schedules, matching, :))
catch
    println("❌ Unfortunately there is no standard dimension that matches your optimal diameter.")
    println("↪ DISCLAIMER: The above calculations have been for SS 306 pipe and water as the fluid.")
    println("↪ Make sure the properties match your application.")
end