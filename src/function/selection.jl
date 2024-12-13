#
# Deterministische Turnierselektion zur Auswahl eines Chromosoms aus einer Population.
#
# Dabei werden k Individuen zufällig aus der Population ausgewählt und das Chromosom mit der besten
# Fitness ausgewählt. Falls zwei Individuen die gleiche Fitness haben, wird das Chromosom mit der
# größeren Crowding-Distance ausgewählt. Im Falle von k=2 handelt es sich um die binäre
# Turnierselektion.
#
# Argumente:
#     pop: Die Population, aus der ein Chromosom ausgewählt werden soll.
#     k: Die Anzahl der Teilnehmer des Turniers.
#
function deterministic_tournament_selection(pop::Population, k::Int)
    participants = [pop.population[rand(1:end)] for _ in 1:k]
    winner = participants[1]
    for chrom in participants
        if chrom.rank < winner.rank || 
           (chrom.rank == winner.rank && chrom.crowding_distance > winner.crowding_distance)
            winner = chrom
        end
    end
    return winner
end
