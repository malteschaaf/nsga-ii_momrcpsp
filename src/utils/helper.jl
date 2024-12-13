include("../function/chromosome.jl")
include("../function/population.jl")

#
# Funktion zur Erstellung eines DataFrames aus den Ergebnissen
#
# Funktion zur Erstellung eines DataFrames einer Population. Die Funktion erstellt eine Tabelle mit
# den Spalten Dauer, Kosten, Belastung, Rang, Modus, Dauer_pro_AE, Schedule und Allokation.
#
# Argumente:
#     pop: Die Population, die in einen DataFrame umgewandelt werden soll.
#
# Rückgabewert:
#     Ein DataFrame, das die Population repräsentiert.
#
function get_df(pop::Population)
    individuals = pop.population

    for ind in individuals
        sort_by_act_no(ind)
    end

    # Erstelle die Spalten für den DataFrame
    durations = [ind.fitness[3] for ind in individuals]
    costs = [ind.fitness[2] for ind in individuals]
    belastungen = [ind.fitness[1] for ind in individuals]
    ranks = [ind.rank + 1.0 for ind in individuals]
    modi = [
        string(count(x -> x == 0, ind.exo[1:ind.MI])) * " Ma; " *
        string(count(x -> x == 1, ind.exo[1:ind.MI])) * " MaEx"
        for ind in individuals
    ]
    dauer_ae = [
        [D[act][sum(ind.M[indexin(act, ind.A)[1]])] for act in ind.A] .* 1.0
        for ind in individuals
    ]
    starts = [ind.S .* 1.0 for ind in individuals]
    schedule_matrix = [
        [
            i >= starts[idx][j] + 1 && i < starts[idx][j] + 1 + dauer_ae[idx][j] ? 1.0 : 0.0
            for i in 1:(ind.fitness[3] / Periodenlänge), j in 1:length(ind.A)
        ]
        for (idx, ind) in enumerate(individuals)
    ]
    allocs = [
        reshape(
            [
                ind.M[i][j] * (ind.exo[j] + 1 == o ? 1.0 : 0.0)
                for o in 1:O, i in 1:AE, j in 1:MI
            ],
            O, AE, MI
        )
        for ind in individuals
    ]

    # Erstelle den DataFrame
    df = DataFrame(
        Dauer = durations,
        Kosten = costs,
        Belastung = belastungen,
        Rang = ranks,
        Modus = modi,
        Dauer_pro_AE = dauer_ae,
        Schedule = schedule_matrix,
        Allokation = allocs,
        start = starts
    )
end
