#
# Funktion zur Berechnung der Fitness eines Chromosoms
# 
# Diese Funktion berechnet die Fitness eines Chromosoms anhand der Kosten und Belastungsparameter.
# 
# Argumente:
#     chrom: Das Chromosom, dessen Fitness berechnet werden soll.
#     Kosten_MA: Die Kosten für einen Mitarbeiter ohne Exoskelett pro Periode.
#     Kosten_MA_Ex: Die Kosten für einen Mitarbeiter mit Exoskelett pro Periode.
#     Kosten_KO: Die Kosten für einen Kollonenführer ohne Exoskelett pro Periode.
#     Kosten_KO_Ex: Die Kosten für einen Kollonenführer mit Exoskelett pro Periode.
#     BEL: Ein Vektor von Vektoren, der die Belastung der Mitarbeiter für jede Aktivität und jeden
#          Modus enthält.
#     D: Ein Vektor von Vektoren, der die Ausführungszeiten für jede Aktivität und jeden Modus
#        enthält.
#     Periodenlänge: Die Länge einer Periode in Zeiteinheiten.
#
function fitness(
    chrom::Chromosome,
    Kosten_MA::Float64,
    Kosten_MA_Ex::Float64,
    Kosten_KO::Float64,
    Kosten_KO_Ex::Float64,
    BEL::Vector{Vector{Float64}},
    D::Vector{Vector{Int}},
    Periodenlänge::Int
)
    # Anzahl der benötigten Mitarbeiter
    chrom.MI = count(col -> any(col .!= 0), Iterators.zip(chrom.M...))

    # Anzahl der eingestzten Exosklette
    exo = sum(chrom.exo[1:chrom.MI])
    if chrom.exo[1] == 1
        KO_Ex = 1
    else
        KO_Ex = 0
    end
    MA_Ex = exo - KO_Ex
    MA = chrom.MI - MA_Ex - 1
    KO = 1 - KO_Ex

    MA_cost = MA * Kosten_MA
    MA_Ex_cost = MA_Ex * Kosten_MA_Ex
    KO_cost = KO * Kosten_KO
    KO_Ex_cost = KO_Ex * Kosten_KO_Ex
    total_cost = MA_cost + MA_Ex_cost + KO_cost + KO_Ex_cost
    cost = (chrom.fitness[3] / Periodenlänge) * total_cost

    chrom.fitness[2] = cost

    Belastung = fill(0, length(chrom.M[1]))
    
    for i in 1:length(chrom.A)
        RB = D[chrom.A[i]][sum(chrom.M[i])]
        Belastung += chrom.M[i] * RB * Periodenlänge * BEL[2][chrom.A[i]] .* chrom.exo
        Belastung += chrom.M[i] * RB * Periodenlänge * BEL[1][chrom.A[i]] .* (1 .- chrom.exo)
    end
    
    chrom.fitness[1] = maximum(Belastung)/chrom.fitness[3]
    
end