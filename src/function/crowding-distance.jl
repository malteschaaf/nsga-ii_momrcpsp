#
# Funktion zur Berechnung der Crowding-Distanz für eine Front von Chromosomen
#
# Diese Funktion berechnet die Crowding-Distanz für jedes Chromosom in einer Front von Chromosomen.
# Dabei wird die Crowding-Distanz als Summe der Distanzen zu den benachbarten Chromosomen in jeder
# Fitnessdimension berechnet.
#
# Argumente:
#     front: Die Front von Chromosomen, für die die Crowding-Distanz berechnet werden soll.
#
function calculate_crowding_distance!(front::Vector{Chromosome})
    n = length(front)
    if n == 0
        return
    end

    # Initialisiere die Crowding-Distanz für jedes Chromosom auf 0
    for chrom in front
        chrom.crowding_distance = 0.0
    end

    # Anzahl der Zielfunktionen
    num_objectives = length(front[1].fitness)

    for i in 1:num_objectives
        # Sortiere die Chromosomen nach dem i-ten Fitnesswert
        sort!(front, by=chrom -> chrom.fitness[i])

        # Setze die Crowding-Distanz der Randchromosomen auf unendlich
        front[1].crowding_distance = Inf
        front[end].crowding_distance = Inf

        # Bestimme den Wertebereich der i-ten Fitnessdimension
        min_fitness = front[1].fitness[i]
        max_fitness = front[end].fitness[i]

        if max_fitness > min_fitness
            # Berechne die Crowding-Distanz für jedes Chromosom c im Inneren
            for c in 2:n-1
                front[c].crowding_distance += 
                (front[c+1].fitness[i] - front[c-1].fitness[i]) / (max_fitness - min_fitness)
            end
        end
    end
end