#
# Testfunktionen für die Chromosomen
#
# Die folgenden Funktionen testen die Chromosomen auf die Einhaltung der Constraints.
#
# Argumente:
#     chrom: Das Chromosom, das getestet werden soll.
#     V: Ein Vektor von Vektoren, der die Vorgänger jeder Aktivität enthält.
#     D: Ein Vektor von Vektoren, der die Ausführungszeiten für jede Aktivität und jeden Modus enthält.
#     MI: Die maximale Anzahl von Mitarbeitern.
#     Lag: Ein Vektor von Vektoren, der die anteiligen Bearbeitungsfortschritte der Vorgängerbeziehungen enthält.
#
function test_constraints(
    chrom::Chromosome,
    V::Vector{Vector{Int}},
    D::Vector{Vector{Int}},
    MI::Int,
    Lag::Vector{Vector{Float64}}
)
    # 1. Überprüfung, ob alle Vorgänger abgeschlossen sind bevor eine Aktivität startet
    for i in 1:length(chrom.A)
        a = chrom.A[i]
        for pred in V[a]
            pred_idx = findfirst(x -> x == pred, chrom.A)
            
            if pred == 0
                pred_start, pred_end = 0, 0
            else
                pred_start = chrom.S[pred_idx]
                mitarbeiteranzahl = sum(chrom.M[pred_idx])
                pred_duration = D[pred][mitarbeiteranzahl]
                pred_end = pred_start + pred_duration * Lag[pred][a]
            end
            
            if pred_end > chrom.S[i]
                error("Fehler: Vorgänger endet nachdem Nachfolger beginnt")
            end
        end
    end


    # 2. Überprüfung, ob Mitarbeiter auf mehreren Jobs gleichzeitig arbeitet
    durations = [D[chrom.A[i]][sum(chrom.M[i])] for i in 1:length(chrom.A)]

    for t in 1:maximum(chrom.S)
        for m in 1:MI
            jobs = [a for (i, a) in enumerate(chrom.A) if chrom.S[i] < t <= chrom.S[i] + durations[i] && chrom.M[i][m] == 1]
            if length(jobs) > 1
                println("Mitarbeiter $m arbeitet zu Zeitpunkt $t an mehreren Jobs: $jobs")
                error("Fehler: Mitarbeiter arbeitet an mehreren Jobs gleichzeitig")
            end
        end
    end

end
