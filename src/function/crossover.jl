#
# Funktion zur Durchführung eines 2-Punkt-Crossovers.
#
# Diese Funktion erzeugt zwei Nachkommen (Sohn und Tochter) durch 2-Punkt-Crossover zweier
# Elternchromosomen. Dazu werden zwei zufällige Crossover-Punkte erzeugt und die Nachkommen
# entsprechend generiert.
#
# Argumente:
#     chrom1: Das erste Elternchromosom.
#     chrom2: Das zweite Elternchromosom.
#     MI: Die maximale Anzahl von Mitarbeitern.
#
function crossover(chrom1::Chromosome, chrom2::Chromosome, MI)
    n = length(chrom1.A)
    if n == 0 || n != length(chrom2.A)
        error("Activity Lists have different lengths or are empty.")
    end

    # Zwei zufällige Crossover-Punkte erzeugen
    cp1 = rand(1:n-1)
    cp2 = rand(cp1+1:n)

    # Erzeuge das erste Nachkommenchromosom (Sohn) durch Aufruf der generate_offspring Funktion
    son = generate_offspring(chrom1, chrom2, cp1, cp2, MI)

    # Erzeuge das zweite Nachkommenchromosom (Tochter) durch Aufruf der generate_offspring Funktion
    daughter = generate_offspring(chrom2, chrom1, cp1, cp2, MI)

    # Gib die beiden erzeugten Chromosomen zurück
    return son, daughter
end


#
# Hilfsfunktion zur Generierung eines Nachkommenchromosoms durch Crossover. 
#
# Es wird ausgehend von den beiden Elternchromosomen und den beiden Crossover-Punkten ein neues
# Chromosom erzeugt. Dabei werden die Aktivitäten und Moduszuweisung des ersten Elternchromosoms
# bis zum ersten Crossover-Punkt und ab dem zweiten Crossover-Punkt übernommen. Die Aktivitäten
# und Moduszuweisungen zwischen den beiden Crossover-Punkten werden vom zweiten Elternchromosom
# übernommen.
#
# Argumente:
#   parent1: Das erste Elternchromosom.
#   parent2: Das zweite Elternchromosom.
#   cp1: Der erste Crossover-Punkt.
#   cp2: Der zweite Crossover-Punkt.
#   MI: Die maximale Anzahl von Mitarbeitern.
#
function generate_offspring(
    parent1::Chromosome,
    parent2::Chromosome,
    cp1::Int,
    cp2::Int,
    MI::Int
)
    n = length(parent1.A)

    # Überprüfe, ob die Aktivitätslisten unterschiedliche Längen haben oder leer sind
    if n == 0 || n != length(parent2.A)
        error("Activity Lists have different lengths or are empty.")
    end

    # Initialisierung des Nachkommens
    offspring_A = zeros(Int, n)
    offspring_M = deepcopy(parent1.M)

    # Kopiere die ersten child1 Positionen von parent1
    offspring_A[1:cp1] .= parent1.A[1:cp1]
    offspring_M[1:cp1] .= parent1.M[1:cp1]

    # Übernehme die letzten Werte von Parent1
    offspring_A[cp2+1:end] .= parent1.A[cp2+1:end]
    offspring_M[cp2+1:end] .= parent1.M[cp2+1:end]

    # Übernehme alle Werte von parent2 die noch nicht in offspring_A enthalten sind
    offspring_A[cp1+1:cp2] .= filter(x -> !(in(x, offspring_A[1:cp1]) || in(x, offspring_A[cp2+1:end])), parent2.A)
    offspring_M[cp1+1:cp2] .= [parent2.M[findfirst(x -> x == value, parent2.A)] for value in offspring_A[cp1+1:cp2]]

    # Erzeuge das Nachkommenchromosom und gib es zurück
    child = Chromosome(offspring_A, offspring_M, parent1.exo, MI)
    i = 0
    while sum(row[end-i] for row in offspring_M) == 0
        i += 1
        child.MI -= 1
    end
    return child
end