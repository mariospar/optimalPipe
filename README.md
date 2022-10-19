# Optimal Pipe Diameter

## Installation

___

### Prerequisites

Firstly, you have to install the Julia programming language and you can find everything related to
that to its website [here](https://julialang.org/downloads/).

You will also need to install the following packages:

* CSV
* DataFrames
* JuMP
* NLopt
* Unitful
* Plots

You can very quickly install them by typing on the REPL `using Pkg; Pkg.add("{name}")` whereas {name} corresponds
to the name of the package you haven't already installed.

If you've done all these then simply run the Julia REPL on `src/main.jl` and you are good to go.

## Theory

___

### Symbols and Units

|       **Description**      | **Symbol** |      **Unit**      |
|:--------------------------:|:----------:|:------------------:|
|       Flow Resistance      |    $F_d$   |         $N$        |
|       Pump Efficiency      |     $η$    |                    |
|      Reynold's Number      |    $Re$    |                    |
|          Diameter          |     $D$    |         $m$        |
|        Pressure Drop       |    $ΔP$    |        $Pa$        |
|       Minor Head Loss      |    $η_ε$   |     $Jkg^{-1}$     |
|      Investment Costs      |  $C_{inv}$ | $€year^{-1}m^{-1}$ |
|      Operational Costs     |  $C_{op}$  | $€year^{-1}m^{-1}$ |
|      External Diameter     |  $D_{ext}$ |         $m$        |
| Gravitational Acceleration |     $g$    |      $ms^{-2}$     |
|          Viscosity         |     $μ$    |        $Pas$       |
|      Vertical Position     |     $z$    |         $m$        |
|       Molar Flow Rate      |     $G$    |     $kgs^{-1}$     |
|       Major Head Loss      |    $h_μ$   |     $Jkg^{-1}$     |
|   Average Speed of Fluid   |     $v$    |      $ms_{-1}$     |
|         Pipe Length        |     $L$    |         $m$        |
|    Volumetric Flow Rate    |     $F$    |     $m^3s^{-1}$    |
|          Pressure          |     $P$    |        $Pa$        |
|           Density          |     $ρ$    |     $kgm^{-3}$     |
|         Total Costs        |  $C_{tot}$ | $€year^{-1}m^{-1}$ |
|    Flow Type Coefficient   |     $α$    |                    |
|   Fanning Friction Factor  |     $f$    |                    |

### Piping

For pipes of fixed circular cross-section, hereinafter referred to as pipes, the driving force that causes the fluid to flow is the pressure difference at the ends of the pipe. This can be easily demonstrated by means of the Bernoulli equation:

$$ P_1/ρ +1/2 a_1 v_1^2+gz_1=  P_2/ρ+1/2 a_2 v_2^2+gz_2+h_μ+h_ε $$
$$(1.1)$$

Considering a general case with assumptions of incompressible fluid, constant pipeline cross-section, fully developed flow without altitude differences or components causing minor head losses, Equation 1.1 is simplified to the following form:

$$ ΔP/ρg=h_μ $$
$$(1.2)$$

Hydrostatic head losses are due to the friction between a fluid and the pipe walls. As the fluid performs inertially smooth motion between two sections of the pipeline, the resultant force will be equal to zero, so the resistance at the walls will be equal to the difference in force applied at the ends of the sections. That is:

$$ P_1 A-P_2 A=F_d=f'πDLv^2 ⟺ $$
$$ΔP=(f'πDLv^2)/A ⇔ h_μ= (4f'Lv^2)/ρgD⟺h_μ=(2fLv^2)/D $$
$$(1.3)$$

In the above equation, f is called the Fanning friction factor and is a function of the relative roughness of the tube and the Reynolds number, i.e. f(Re,k/D). The Fanning coefficient for turbulent flow in a circular cross-section pipe is equal to:

$$ f=0.0791Re^{-0.025}=(0.0791μ^{0.025}/(ρ^{0.025}v^{0.025}D^{0.025}) $$
$$(1.4)$$

The mass flow of the fluid G is given as a function of the diameter by:

$$ G=Fρ⟺G=vAρ⟺G=((πD^2)/4)vρ $$
$$(1.5)$$

### Cost Function

There are two components that overlap to form the costs of a pipe. The purchase costs and the operating costs. The purpose of this paragraph will be to create a model for these costs.

The purchase costs $C_{inv}$, will be assumed to be due linearly with the quantity of manufacturing material. For a circular cross-section pipe, as shown in Picture 1, the material cost required for 1 meter of pipe per year is:

$$C_{inv}=c_1π(D_{ext}^2-D^2)$$
$$c_1 [=] (€ material)/(kg∙year)$$
$$(1.6)$$

<p align="center">
  <img src="static/pipe_cross_section.png" />
</p>

<p align="center">
  <span>Picture 1</span>
</p>

In order to simplify Equation 1.6 to be a function of the inside diameter only, we can take into account the standard construction dimensions for pipes. For this problem we will assume that the material is stainless steel with known standards [2]

$$ D^n=D_{ext}^2-D^2⟺n∙ln⁡(D^n )=ln⁡(D_{ext}+D)+ln⁡(D_{ext}-D)⟺ $$

$$ (n_i)=(ln⁡(D_{ext,i}+D_i )+ln⁡(D_{ext,i}-D_i ))/ln⁡(D_i ) ⟹ $$

$$\therefore \overline{n}=1.2435≅1.24$$
$$(1.7)$$

The value of $n$ was obtained by taking the average of $n_i$ for various values of internal and external diameters of standard stainless steel circular duct construction dimensions.

Combining Equation 1.6 and Equation 1.7:
$$C_{inv}=c_1πD^{1.24}$$
$$(1.8)$$

For $C_{op}$ operating costs, we must consider the cost of energy to transport the fluid in 1 meter of pipeline per year. As is obvious, we are referring to the operating costs of the pump.

$$C_{op}=c_2∙GΔP/ρη$$
$$c_2[=](€ energy∙s^3)/(m^2∙kg∙year)$$
$$(1.9)$$

The objective function to be minimized is assumed to be the following:

$$C_{tot}=C_{op}+C_{inv}=c_1πD^{1.24}+c_2GΔP/ρη$$
$$(1.10)$$

## Results

___

### Optimization

Equation 1.10 is a non-linear function so Julia's software was used to solve it numerically [3]. Summarizing the findings of the theory, we have a nonlinear optimization problem with an independent variable diameter, objective function Equation 1.10 and 3 equality constraints Equation 1.3, Equation 1.4 and Equation 1.5.

To simplify the problem, we assume that the fluid is water and make the following assumptions:

* $ρ_{ss}=7950$ $kg/m^3$
* $ρ=997$  $kg/m^3$
* $η=85$ $\%$
* $μ=8.90x10^{-4}$ $Pa∙s$
* $G=5$  $kg/s$
* $8760$ $operational$ $hours$ $(1$ $year)$
* $0.117$  $€/kWh$
* $3.74$ $€/(kg_{ss})$ $[5]$

The problem is solved and it is found that the objective function exhibits a minimum for D=0.2011 m=7.918 inches. The diagram below shows the dependence of the components of the objective function.

<p align="center">
  <img src="plots/Costs vs Diameter.png"/>
</p>

<p align="center">
  <span>Diagram 1</span>
</p>

The manufacturing standard with the closest nominal diameter is that of 8 inch which gives the following manufacturing options:

|     NPS (inch)    |     External D (mm)    |     Sch 5S (mm)    |     Sch 10S (mm)    |     Sch 40S (mm)    |     Sch 80S (mm)    |
|-------------------|------------------------|--------------------|---------------------|---------------------|---------------------|
|     8.0           |     219.1              |     2.77           |     3.76            |     8.18            |     12.7            |

Table 1

### Conclusions

Optimization for the problem pipeline was feasible and it was found that for the aforementioned data, a pipe with a diameter of 8 inches minimizes the total cost. As shown in Figure 1, the purchase costs after a critical diameter value are identical to the total costs because the operating cost component tends asymptotically to zero. This is because the head losses decrease with increasing diameter and the same is true for the Fanning friction coefficient.

Finally, it is important to state that many assumptions have been made in the problem of the paper which contribute to answers for real data. For example, no component corresponding to the purchase costs of the pump has been added to the total cost, it has been assumed that the fluid is homogeneous throughout the control volume, the gross purchase price of Greece's National Distributer has been chosen as the price per kilowatt-hour and no components for maintenance costs have been included.

```latex
[1] Ι. Κ. Κούκος, Εισαγωγή στον Σχεδιασμό Χημικών Εργοστασίων, Εκδόσεις Τζιόλα, 2021. 
[2] «Engineering Toolbox,» [Online]. Available: https://amesweb.info/Materials/Specific-Heat-Capacity-of-Water.aspx. [Accessed 18 10 2022].
[3] "Julia Docs" [Online]. Available: https://docs.julialang.org/en/v1/manual/getting-started/.
[4] «Greece electricity prices,» [Online]. Available: https://www.globalpetrolprices.com/Greece/electricity_prices/. [Accessed 18 10 2022].
[5] «Steel Tube - SS 304 price per kg,» [Online]. Available: https://steeltube.co.in/ss-304-price-per-kg/. [Accessed 18 10 2022].
```
