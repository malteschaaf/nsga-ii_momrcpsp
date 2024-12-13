#
# Funktion zur Umwandlung von Dauer_Arbeitselementen (D) in einen Vektor von Vektoren.
#
# Dadurch wird eine einfachere Iteration ermöglicht.
#
# Argumente:
#     D: Ein Vektor von Matrizen, die die Dauer der Arbeitselemente für verschiedene Modi enthalten.
#
# Rückgabewert:
#     Ein Vektor von Vektoren, der die Dauer der Arbeitselemente für verschiedene Modi enthält.
function convert_D(D::Vector{Matrix{Int}})
    # Initialisiere einen leeren Vektor für das Ergebnis
    result = Vector{Vector{Int}}()

    # Durchlaufe jede Matrix in D
    for matrix in D
        # Durchlaufe jede Zeile in der aktuellen Matrix
        for row in eachrow(matrix)
            # Füge jede Zahl in der aktuellen Zeile in den Ergebnisvektor ein
            push!(result, collect(row))
        end
    end

    return result
end


#
# Eine Funktion die aus Dauer_Arbeitselemente (D) für jedes Arbeitselement die möglichen Mitarbeiterzahlen zurückgibt
#
# Funktion zur Bestimmung der minimalen und maximalen Mitarbeiteranzahl, die für die Ausführung
# eines Arbeitselements benötigt wird. Die Funktion gibt eine Liste von Vektoren zurück, wobei
# jeder Vektor die möglichen Mitarbeiterzahlen für ein Arbeitselement enthält.
#
# Argumente:
#     D: Ein Vektor von Vektoren, der die Dauer der Arbeitselemente für verschieden Anzahlen
#        bearbeitender Mitarbeiter enthält.
#
# Rückgabewert:
#     Ein Vektor von Vektoren, der die möglichen Mitarbeiterzahlen für jedes Arbeitselement enthält.
#
function get_d_info(D::Vector{Vector{Int}}, AE::Int)
    # Initialisiere eine leere Liste für D_info
    D_info = Vector{Vector{Int}}(undef, AE)

    # Initialisiere jede Zeile als leerer Vector{Int}
    for i in 1:AE
        D_info[i] = Int[]
    end

    # Durchlaufe jede Zeile in D
    for (index, row) in enumerate(D)
        # Durchlaufe jede Spalte in der aktuellen Zeile
        for (idx, value) in enumerate(row)
            if value < M
                push!(D_info[index], idx)
            end
        end
    end
    
    return D_info
end


#
# Bestimme die minimale Mitarbeiteranzahl.
#
# Funktion zur Bestimmung der minimalen Mitarbeiteranzahl, die für die Ausführung eines Arbeitselements
# benötigt wird.
#
# Argumente:
#     d_info: Ein Vektor von Vektoren, der die möglichen Mitarbeiterzahlen für jedes Arbeitselement enthält.
#
# Rückgabewert:
#     Die minimale Mitarbeiteranzahl, die für die Ausführung eines Arbeitselements benötigt wird.
#
function get_min_MI(d_info::Vector{Vector{Int}})
    # Finde die maximale der minimalen Werte in jedem Vektor von d_info
    min_MI = maximum(minimum(info) for info in d_info)
    return min_MI
end


#
# Funktion zur Umwandlung der anteiligen Bearbeitungsfortschritte der Vorgängerbeziehungen von einer
# Matrix in einen Vektor von Vektoren.
#
# Argumente:
#     matrix: Eine Matrix, die die anteiligen Bearbeitungsfortschritte der Vorgängerbeziehungen enthält.
#
# Rückgabewert:
#     Ein Vektor von Vektoren, der die anteiligen Bearbeitungsfortschritte der Vorgängerbeziehungen enthält.
#
function convert_Lag(matrix::Matrix{T}) where T
    result = Vector{Vector{T}}()
    for row in eachrow(matrix)
        push!(result, collect(row))
    end
    return result
end


#
# Funktion zur Berechnung der Vorgänger einer Aktivität.
#
# Funktion zur Berechnung der Vorgänger einer Aktivität basierend auf der Vorgänger-Matrix. Die
# Funktion gibt eine Matrix zurück, die für jede Aktivität die Vorgänger enthält.
#
# Argumente:
#     V: Ein Vektor von Vektoren, der die Vorgänger jeder Aktivität enthält.
#
# Rückgabewert:
#     Eine Matrix, die für jede Aktivität die Vorgänger enthält.
#
function calc_preds(V::Vector{Vector{Int}})
    # Initialisiere die Nachfolger-Matrix mit leeren Arrays
    N = [Int[] for _ in 1:length(V)]

    # Fülle die Nachfolger-Matrix basierend auf der Vorgänger-Matrix
    for (i, predecessors) in enumerate(V)
        for predecessor in predecessors
            if predecessor != 0
                push!(N[predecessor], i)
            end
        end
    end

    return N
end
