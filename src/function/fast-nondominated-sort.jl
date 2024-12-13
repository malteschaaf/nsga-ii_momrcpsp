#
# Sortiere die Individuen in pop in nicht-dominierte Fronten.
#
# Diese Funktion sortiert die Individuen in der gegebenen Population in nicht-dominierte Fronten.
# Jedes Chromosom wird mit jedem anderen Chromosom in der Population verglichen, um
# Dominanzbeziehungen zu bestimmen. Ein Chromosom `A` dominiert ein anderes Chromosom `B`, wenn
# `A` in allen Zielen besser ist als `B`.
# 
# Argumente:
#     pop: Die Population der zu sortierenden Individuen.
#
function fast_nondominated_sort(pop::Population)
    pop.fronts = [[]]
    for chrom in pop.population
        chrom.domination_count = 0
        chrom.dominated_solutions = []
        for other_chrom in pop.population
            if dominates(chrom, other_chrom)
                push!(chrom.dominated_solutions, other_chrom)
            elseif dominates(other_chrom, chrom)
                chrom.domination_count += 1
            end
        end
        if chrom.domination_count == 0
            chrom.rank = 0
            push!(pop.fronts[1], chrom)
        end
    end
    
    i = 1
    while length(pop.fronts[i]) > 0
        temp = []
        for chrom in pop.fronts[i]
            for other_chrom in chrom.dominated_solutions
                other_chrom.domination_count -= 1
                if other_chrom.domination_count == 0
                    other_chrom.rank = i
                    push!(temp, other_chrom)
                end
            end
        end
        i += 1
        push!(pop.fronts, temp)
    end
end
