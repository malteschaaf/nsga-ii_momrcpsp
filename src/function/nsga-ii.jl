#
# Implementierung des NSGA-II Algorithmus
#
# Der NSGA-II Algorithmus wird in dieser Funktion implementiert. Dabei wird eine Population von
# Chromosomen erzeugt, die durch eine gegebene Anzahl von Generationen iteriert. In jeder Generation
# werden die Chromosomen selektiert, gekreuzt und mutiert, um eine neue Population zu erzeugen. Die
# Fitness der Individuen wird berechnet und die Population wird nach dem nicht-dominanten Sortieren
# und der Berechnung der Crowding-Distanz aktualisiert.
#
# Argumente:
#   pop_size: Die Größe der Population.
#   generations: Die Anzahl der Generationen.
#   selection_k: Die Anzahl der Individuen im Turnier für die Selektion.
#   p_mutate: Die Wahrscheinlichkeit einer Mutation.
#
# Globale Variablen:
#   d_info: Ein Vektor von Vektoren, der die möglichen Mitarbeiterzahlen für jedes Arbeitselement enthält.
#   MI: Die maximale Anzahl von Mitarbeitern, die für ein Chromosom zugelassen sind.
#   AE: Die Anzahl der Aktivitäten, die in einem Chromosom enthalten sein sollen.
#   K: Ein Vektor, der für jede Aktivität angibt ob ein Kollonenführer benötigt wird.
#   V: Ein Vektor von Vektoren, der die Vorgänger jeder Aktivität enthält.
#   N: Ein Vektor von Vektoren, der die Nachfolger jeder Aktivität enthält.
#   Kosten_MA: Die Kosten für einen Mitarbeiter ohne Exoskelett pro Periode.
#   Kosten_MAEx: Die Kosten für einen Mitarbeiter mit Exoskelett pro Periode.
#   Kosten_KO: Die Kosten für einen Kollonenführer ohne Exoskelett pro Periode.
#   Kosten_KOEx: Die Kosten für einen Kollonenführer mit Exoskelett pro Periode.
#   BEL: Ein Vektor von Vektoren, der die Belastung der Mitarbeiter für jede Aktivität und jeden Modus enthält.
#   D: Ein Vektor von Vektoren, der die Ausführungszeiten für jede Aktivität und jeden Modus enthält.
#   Periodenlänge: Die Länge einer Periode in Zeiteinheiten.
#   Lag: Ein Vektor von Vektoren der die anteiligen Bearbeitungsfortschritte abhängiger Vorrangbeziehungen enthält
#
# Rückgabewert:
#   Die letzte Population nach der angegebenen Anzahl von Generationen.
#
function nsga_ii(
    pop_size::Int,                 # Größe der Population
    generations::Int,              # Anzahl der Generationen
    selection_k::Int,              # Anzahl der Individuen im Turnier für die Selektion
    p_mutate::Float64,             # Wahrscheinlichkeit einer Mutation
)
    # Initialisiere die Population
    pop = init_population(pop_size, d_info, MI, AE, K)

    # Fitness der Individuen berechnen
    for chrom in pop.population
        schedule_chromosome(chrom, V, D, MI, AE, Lag)  # Zeitplan für das Chromosom erstellen
        fitness(chrom, Kosten_MA, Kosten_MAEx, Kosten_KO, Kosten_KOEx, BEL, D, Periodenlänge) 
    end

    # Schnelles nicht-dominantes Sortieren
    fast_nondominated_sort(pop)

    # Berechne Crowding-Distanz für jede Front
    for front in pop.fronts
        calculate_crowding_distance!(front)
    end

    # Wiederhole für die angegebene Anzahl von Generationen
    for gen in 1:generations
        # Erzeuge eine neue Population
        next_gen = Population(gen, Vector{Chromosome}(), Vector{Vector{Chromosome}}())

        # Erzeuge Nachkommen, bis die neue Population die gewünschte Größe erreicht
        while length(next_gen) < pop_size
            parent1 = deterministic_tournament_selection(pop, selection_k)  # Wähle erstes Elternteil
            parent2 = deterministic_tournament_selection(pop, selection_k)  # Wähle zweites Elternteil
            offspring1, offspring2 = crossover(parent1, parent2, MI)        # Erzeuge Nachkommen durch Crossover
            mutate!(offspring1, p_mutate, V, N, K, d_info, MI)              # Mutation für ersten Nachkommen
            mutate!(offspring2, p_mutate,  V, N, K, d_info, MI)             # Mutation für zweiten Nachkommen
            push!(next_gen.population, offspring1, offspring2)              # Füge Nachkommen zur neuen Population hinzu
        end

        # Fitness der neuen Population berechnen
        for chrom in next_gen.population
            schedule_chromosome(chrom, V, D, MI, AE, Lag)  # Zeitplan für das Chromosom erstellen
            fitness(chrom, Kosten_MA, Kosten_MAEx, Kosten_KO, Kosten_KOEx, BEL, D, Periodenlänge)  # Fitness berechnen
        end

        # Kombiniere alte und neue Population
        next_gen.population = vcat(pop.population, next_gen.population)

        # Schnelles nicht-dominantes Sortieren für kombinierte Population
        fast_nondominated_sort(next_gen)

        # Berechne Crowding-Distanz für jede Front
        for front in next_gen.fronts
            calculate_crowding_distance!(front)
        end

        # Wähle Individuen für die nächste Generation aus
        next_population = []
        next_fronts = []

        for (i, front) in enumerate(next_gen.fronts)
            # Wenn die gesamte Front in die nächste Generation passt
            if length(next_population) + length(front) <= pop_size
                push!(next_fronts, [])
                for chrom in front
                    push!(next_population, chrom)
                    push!(next_fronts[i], chrom)
                end
            else
                # Sortiere die Front nach Crowding-Distanz
                sort!(front, by = x -> x.crowding_distance, rev=true)
                needed = pop_size - length(next_population)  # Anzahl der noch benötigten Individuen
                push!(next_fronts, [])
                for chrom in front[1:needed]
                    push!(next_population, chrom)
                    push!(next_fronts[i], chrom)
                end
                next_gen.fronts = next_fronts
                next_gen.population = next_population
                break
            end
        end

        # Aktualisiere die Population
        pop = next_gen
    end

    # Gib die letzte Population zurück
    return pop
end
