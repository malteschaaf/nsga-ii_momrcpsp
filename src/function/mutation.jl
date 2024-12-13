#
# Funktion zur Mutation eines Chromosoms. 
#
# Diese Funktion mutiert ein Chromosom, indem es zufällig eine Aktivität auswählt und an einer
# anderen Position einfügt. Zusätzlich wird die Moduszuweisung der Aktivitäten, sowie die Exoskelett
# Ausstattung der Mitarbeiter mutiert. Die Wahrscheinlichkeit für eine Mutation wird durch den
# Parameter `p` bestimmt.
#
# Argumente:
#     chrom: Das zu mutierende Chromosom.
#     p: Die Wahrscheinlichkeit für eine Mutation.
#     V: Ein Vektor von Vektoren, der die Vorgänger jeder Aktivität enthält.
#     N: Ein Vektor von Vektoren, der die Nachfolger jeder Aktivität enthält.
#     K: Ein Vektor, der für jede Aktivität angibt ob ein Kollonenführer benötigt wird.
#     d_info: Ein Vektor von Vektoren, der zusätzliche Informationen für die Mutation enthält.
#     MI: Die maximal verfügbare Anzahl von Mitarbeitern.
#
function mutate!(
    chrom::Chromosome,
    p::Float64,
    V::Vector{Vector{Int}},
    N::Vector{Vector{Int}},
    K::Vector{Int},
    d_info::Vector{Vector{Int}},
    MI::Int
)
    # Mutation für die Reihenfolge der Aktivitäten
    for i in 1:length(chrom.A)
        if rand() < p
            activity = chrom.A[i]
            mode = chrom.M[i]
            preds = V[chrom.A[i]]
            succs = N[chrom.A[i]]

            # Finde die Positionen der letzten Vorgänger und ersten Nachfolger
            last_pred_index = findlast(pred -> pred in preds, chrom.A)
            first_succ_index = findfirst(succ -> succ in succs, chrom.A)

            # Bestimme den Start- und Endindex für den Zufallszahlbereich
            start_index = last_pred_index !== nothing ? last_pred_index + 1 : 1
            end_index = first_succ_index !== nothing ? first_succ_index : length(chrom.A)

            # Wähle eine zufällige Position in dem Bereich
            if start_index < end_index
                new_pos = rand(start_index:end_index)

                # Einfügen an neuer Position
                deleteat!(chrom.A, i)
                deleteat!(chrom.M, i)
                insert!(chrom.A, new_pos, activity)
                insert!(chrom.M, new_pos, mode)
            end
        end
    end
    
    # Mutation für Moduszuweisungen
    for i in 1:length(chrom.M)
        if rand() < p
            chrom.M[i] = (K[chrom.A[i]] == 1 ? 
                generate_mode(MI, chrom.MI, d_info[chrom.A[i]], true, MI-chrom.MI) : 
                generate_mode(MI, chrom.MI, d_info[chrom.A[i]], false, MI-chrom.MI))
        end
    end

    # Mutation für Exo-Ausstattung
    if rand() < p
        chrom.exo = rand(0:1, MI)
    end
end