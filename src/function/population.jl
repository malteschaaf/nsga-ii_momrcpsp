# Funktionen zur Verwaltung von Populationen

#
# Struktur für eine Population
#
mutable struct Population
    generation::Int
    population::Vector{Chromosome}
    fronts::Vector{Vector{Chromosome}}

    function Population(
        generation::Int,
        population::Vector{Chromosome},
        fronts::Vector{Vector{Chromosome}}
    )
        new(generation, population, fronts)
    end
end


#
# Funktion, die die Anfangspopulation erstellt
# 
# Diese Funktion erstellt eine Population, setzt die Generation auf 0 und fügt `size` viele
# Chromosomen hinzu.
#
# Argumente:
#   size: Die Größe der zu initialisierenden Population.
#   d_info: Ein Vektor von Vektoren, der die möglichen Mitarbeiterzahlen für jedes Arbeitselement enthält.
#   MI: Die maximale Anzahl von Mitarbeitern, die für ein Chromosom zugelassen sind.
#   AE: Die Anzahl der Aktivitäten, die in einem Chromosom enthalten sein sollen.
#   K: Ein Vektor, der für jede Aktivität angibt ob ein Kollonenführer benötigt wird.
#
# Rückgabewert:
#   Eine initialisierte Population mit der angegebenen Größe.
#
function init_population(
    size::Int,
    d_info::Vector{Vector{Int}},
    MI::Int,
    AE::Int,
    K::Vector{Int}
)
    # create an empty vector of chromosomes
    pop = Vector{Chromosome}()
    for _ in 1:size
        chrom = init_chromosome(MI, AE, d_info, K)
        push!(pop, chrom)
    end
    return Population(0, pop, Vector{Vector{Chromosome}}())
end


# Importiere die Funktionen length und iterate aus Base
import Base: length, iterate


# Implementiere die Funktionen length und iterate für Populationen
function length(pop::Population)
    return length(pop.population)
end

function iterate(pop::Population)
    return iterate(pop.population)
end


# Funktion zum hinzufügen eines Individuums zur Population
function append!(pop::Population, chrom::Chromosome)
    push!(pop.population, chrom)
end
