# 
# Struktur für ein Chromosom, das die Informationen über die Aktivitäten, die Modusliste,
# die Startzeitpunkte, die Ausstattung der Mitarbeiter, die Anzahl der zugewiesenen Mitarbeiter und
# die Fitness-Werte enthält.
#
mutable struct Chromosome
    A::Union{Vector{Int}, Nothing}          # Aktivitätenliste
    M::Union{Vector{Vector{Int}}, Nothing}  # Modusliste
    S::Union{Vector{Int}, Nothing}          # Startzeitpunkte der Aktivitäten
    exo::Union{Vector{Int}, Nothing}        # Ausstattung der Mitarbeiter
    MI::Union{Int, Nothing}                 # Zugewiesene Mitarbeiter Anzahl

    fitness::Vector{Float64}                # Fitness-Werte

    
    domination_count::Union{Nothing, Int}   # Anzahl der dominierten Lösungen
    dominated_solutions::Union{Nothing, Vector{Chromosome}}     # Dominierte Lösungen
    rank::Union{Nothing, Int}              # Rang des Chromosoms
    crowding_distance::Float64             # Crowding-Distance

    function Chromosome(
        A::Vector{Int},
        M::Vector{Vector{Int}},
        exo::Vector{Int},
        MI::Int,
    )
        new(
            A,          # A
            M,          # M
            nothing,    # S
            exo,        # exo
            MI,         # MI
            [0, 0, 0],  # fitness
            nothing,    # domination_count
            nothing,    # dominated_solutions
            nothing,    # rank
            0.0,        # crowding_distance
        )
    end
end


#
# Überschreiben des "=="-Vergleichs zweier Chromosomen
#
# Zwei Chromosomen sind gleich, wenn ihre Aktivitäten, Moduslisten und Exoskelett-Ausstattungen
# gleich sind.
#
# Argumente:
#     self: Das erste Chromosom.
#     other: Das zweite Chromosom.
#
import Base: ==
function ==(self::Chromosome, other::Chromosome)
    if isnothing(self.A) || isnothing(self.M) || isnothing(self.exo) || isnothing(other.M) || isnothing(other.exo) || isnothing(other.A)
        return false
    end
    return self.A == other.A && self.M == other.M && self.exo == other.exo
end


#
# Prüfe, ob ein Chromosom ein anderes dominiert.
#
# Ein Chromosom dominiert ein anderes, wenn es in allen Fitness-Werten mindestens so gut ist wie das
# andere Chromosom und in mindestens einem Fitness-Wert besser ist.
#
# Argumente:
#     self: Das Chromosom, das geprüft wird.
#     other: Das Chromosom, gegen das geprüft wird.
function dominates(self::Chromosome, other::Chromosome)
    # Prüfe, ob die Fitness-Werte der Chromosomen nicht leer sind
    if isnothing(self.fitness) || isnothing(other.fitness)
        return false
    end
    
    # Runden der Fitness-Werte auf 5 Nachkommastellen
    rounded_self_fitness = round.(self.fitness, digits=5)
    rounded_other_fitness = round.(other.fitness, digits=5)
    
    # Prüfe, ob self mindestens in einem Fitness-Wert besser und in keinem schlechter ist als other.
    and_conditions = [
        rounded_self_fitness[i] <= rounded_other_fitness[i] 
        for i in 1:length(rounded_self_fitness)
    ]
    or_condition = [
        rounded_self_fitness[i] < rounded_other_fitness[i] 
        for i in 1:length(rounded_self_fitness)
    ]
    return all(and_conditions) && any(or_condition)
end


#
# Generiere einen zufälligen Modus für eine Aktivität.
#
# Ein Modus ist eine binäre Zuweisung von Mitarbeitern zu einer Aktivität. Der Modus enthält eine 1
# an der Position i, wenn der Mitarbeiter i für die Aktivität benötigt wird, und eine 0, wenn der
# Mitarbeiter nicht benötigt wird. Der Modus wird zufällig generiert, wobei die Anzahl der aktiven
# Mitarbeiter und die Anzahl der Mitarbeiter, die für die Aktivität benötigt werden, berücksichtigt
# werden. Wenn der Kollonenführer für die Aktivität benötigt wird, wird die erste Position im Modus
# mit einer 1 belegt.
#
# Argumente:
#   MI: Die maximale Anzahl von Mitarbeitern, die für ein Chromosom zugelassen sind.
#   ind_MI: Die Anzahl der Mitarbeiter, die für die Aktivität benötigt werden.
#   active_MI: Ein Vektor von möglichen aktiven Mitarbeitern.
#   kolonnenführer: Ein Boolescher Wert, der angibt, ob ein Kollonenführer für die Aktivität benötigt wird.
#   skip: Die Anzahl der Mitarbeiter, die nicht für die Aktivität benötigt werden.
#
function generate_mode(
    MI::Int,
    ind_MI::Int,
    active_MI::Vector{Int},
    kolonnenführer::Bool,
    skip::Int
)
    # Initialisiere ein leeres Array für den Modus
    mode = Int[]
        
    # Wähle einen zufälligen Wert aus dem Vektor der möglichen aktiven Mitarbeiter
    active_MI_value = rand(active_MI)

    # Wenn kolonnenführer wahr ist, füge eine 1 am Anfang der binären Zahl hinzu
    # reduziere active_MI_value um 1
    if kolonnenführer == true
        push!(mode, 1)
        active_MI_value -= 1
    elseif rand() <= active_MI_value / ind_MI
        push!(mode, 1)
        active_MI_value -= 1
    else
        push!(mode, 0)
    end
    
    # Durchlaufe alle Positionen von 2 bis MI
    for i in 2:MI
        # Entscheide, ob an der aktuellen Position eine 1 oder 0 hinzugefügt wird
        if active_MI_value > 0 && rand() <= active_MI_value / (MI - i + 1 - skip) && i <= MI-skip
            # Füge eine 1 hinzu und reduziere active_MI_value um 1
            push!(mode, 1)
            active_MI_value -= 1
        else
            # Füge eine 0 hinzu
            push!(mode, 0)
        end
    end
    
    # Gib den berechneten Modus zurück
    return mode
end


#
# Erstellen eines zufälligen Chromosoms basierend auf den übergebenen Parametern. 
#
# Zufällige Chromosomen enthalten zufällige Aktivitäten, Moduszuweisungen, Mitarbeiteranzahlen und
# Exoskelett-Ausstattungen. Die Anzahl der Mitarbeiter wird zufällig zwischen der minimalen Anzahl
# von Mitarbeitern, die für ein Chromosom benötigt werden, und der maximalen Anzahl von verfügbaren
# Mitarbeitern gewählt.
#
# Argumente:
#   MI: Die maximale Anzahl von Mitarbeitern, die für ein Chromosom zugelassen sind.
#   AE: Die Anzahl der Aktivitäten, die in einem Chromosom enthalten sein sollen.
#   d_info: Ein Vektor von Vektoren, der zusätzliche Informationen für die Initialisierung enthält.
#   K: Ein Vektor, der für jede Aktivität angibt ob ein Kollonenführer benötigt wird.
#
function init_chromosome(MI::Int, AE::Int, d_info::Vector{Vector{Int}}, K::Vector{Int})
    # Zufällige Aktivitätenliste
    A = shuffle(1:AE) 

    # Zufällige Mitarbeiteranzahl
    selected_MI = rand(get_min_MI(d_info):MI)

    # Random Modes
    M = [
        if K[i] == 1
            generate_mode(MI, selected_MI, d_info[i], true, MI - selected_MI)
        else
            generate_mode(MI, selected_MI, d_info[i], false, MI - selected_MI)
        end
        for i in A
    ]

    # Zufällige Exo-Ausstattung
    exo = rand(0:1, MI)

    return Chromosome(A, M, exo, selected_MI)
end


#
# Plane die Aktivitäten eines Chromosoms.
#
# Diese Funktion plant die Aktivitäten eines Chromosoms basierend auf den übergebenen Vorgänger- und
# Nachfolgermatrizen, den Dauer-Arbeitselementen, der minimalen Mitarbeiteranzahl, der Anzahl der
# Arbeitselemente und der Lag-Funktion. 
#
# Argumente:
#   chrom: Das Chromosom, dessen Aktivitäten geplant werden
#   V: Liste mit den Vorgängern der Aktivitäten
#   D: Matrix mit der Dauer der Arbeitselemente in Abhängigkeit der eingesetzten Mitarbeiter
#   MI: Die maximale Anzahl von Mitarbeitern die eingesetzt werden können
#   AE: Die Anzahl der Arbeitselemente
#   Lag: Matrix mit den anteiligen Bearbeitungsfortschritten abhängiger Vorrangbeziehungen 
#
function schedule_chromosome(
    chrom::Chromosome,
    V::Vector{Vector{Int}},
    D::Vector{Vector{Int}},
    MI::Int,
    AE::Int,
    Lag::Vector{Vector{Float64}}
)
    # Lade Aktivitäten und Ressourcenzuweisungen des Chromosoms
    A, M = chrom.A, chrom.M
    num_activities = length(A)

    # Initialisiere Ressourcenverfügbarkeit (Kapa) und Startzeiten (S)
    Kapa = fill(ones(Int, MI), sum(D[A[i]][sum(M[i])] for i in 1:AE))  # Maschinenkapazitäten
    S = fill(0, num_activities)  # Startzeit jeder Aktivität
    Scheduled = Set{Int}()       # Geplante Aktivitäten (Menge)

    # Solange nicht alle Aktivitäten eingeplant sind
    while length(Scheduled) < num_activities
        # Finde Aktivitäten, die geplant werden können (alle Vorgänger sind eingeplant)
        feasible_idx = [
            i for i in 1:num_activities 
            if A[i] ∉ Scheduled && (sum(V[A[i]]) == 0 || all(pred in Scheduled for pred in V[A[i]]))
        ]

        # Wähle die erste ausführbare Aktivität
        job_idx = feasible_idx[1]   # Index der Aktivität in `A`
        job_nr = A[job_idx]         # Nummer der Aktivität

        # Füge die Aktivität zur Liste der geplanten Aktivitäten hinzu
        push!(Scheduled, job_nr)

        # Finde die späteste Endzeit aller Vorgängeraktivitäten
        preds = V[job_nr]
        preds_end_times = []
        for pred in preds
            pred_idx = findfirst(x -> x == pred, A)
            if pred == 0
                pred_end = 1  # Keine Vorgänger: Setze Endzeit auf 1
            else
                pred_start = S[pred_idx]  # Startzeit des Vorgängers
                pred_duration = D[pred][sum(M[pred_idx])]  # Dauer des Vorgängers
                pred_end = pred_start + pred_duration * Lag[pred][job_nr]  # Endzeit mit Verzögerung
            end
            push!(preds_end_times, pred_end)
        end
        max_pred_end = maximum(preds_end_times)  # Maximale Endzeit aller Vorgänger

        # Finde den frühesten Zeitpunkt, an dem Ressourcen verfügbar sind
        needed_resources = M[job_idx]  # Benötigte Ressourcen
        duration = D[job_nr][sum(needed_resources)]  # Dauer der Aktivität
        found = false  # Kontrollvariable, ob ein Startzeitpunkt gefunden wurde
        start_job = 0  # Startzeitpunkt der Aktivität

        # Iteriere über mögliche Startzeiten und prüfe die Ressourcenkapazitäten
        for t in Int(ceil(max_pred_end)):length(Kapa) - duration + 1
            duration_range = Kapa[t:t+duration-1]  # Ressourcenkapazität für die Dauer
            for (i, k) in enumerate(duration_range)
                if (needed_resources .& k) == needed_resources && i == length(duration_range)
                    start_job = t
                    found = true
                    break 
                elseif (needed_resources .& k) == needed_resources
                    continue  # Prüfe nächste Periode
                else
                    break  # Ressourcenkapazität nicht erfüllt, Abbruch
                end
            end
            if found
                break  # Beende äußere Schleife, wenn ein Zeitpunkt gefunden wurde
            end
            if isempty(duration_range)
                start_job = t
                found = true
                break
            end
        end

        # Speichere den frühesten Startzeitpunkt im Zeitplan
        S[job_idx] = start_job

        # Aktualisiere Ressourcenkapazität während der Aktivität
        Kapa[start_job:start_job + duration - 1] -= fill(copy(M[job_idx]), duration)

        # Aktualisiere die Fitness des Chromosoms (z. B. Endzeit multipliziert mit Periodenlänge)
        chrom.fitness[3] = (start_job + duration - 1) * Periodenlänge
    end

    # Sortiere die Aktivitäten basierend auf den Startzeiten
    S = S .- 1  # Zeitplan anpassen (optional)
    sorted_indices = sortperm(S)  # Sortierreihenfolge
    chrom.A = chrom.A[sorted_indices]  # Aktivitäten sortieren
    chrom.M = chrom.M[sorted_indices]  # Ressourcenzuweisungen sortieren
    chrom.S = S[sorted_indices]        # Startzeiten sortieren
end



# 
# Soriere die in den Array A, M und S gespeicherten Informationen zu den Aktivitäten eines Chromosoms
# nach den Startzeitpunkten S.
# 
# Argumente:
#     ind: Das Chromosom, dessen Aktivitäten sortiert werden sollen.
#
function sort_by_s(chrom::Chromosome)
    sorted_indices = sortperm(chrom.S)

    chrom.A = chrom.A[sorted_indices]
    chrom.M = chrom.M[sorted_indices]
    chrom.S = chrom.S[sorted_indices]
end


#
# Soriere die in den Array A, M und S gespeicherten Informationen zu den Aktivitäten eines Chromosoms
# nach den Aktivitätsnummern A.
#
# Argumente:
#     ind: Das Chromosom, dessen Aktivitäten sortiert werden sollen.
#
function sort_by_act_no(chrom::Chromosome)
    sorted_indices = sortperm(chrom.A)

    chrom.A = chrom.A[sorted_indices]
    chrom.M = chrom.M[sorted_indices]
    chrom.S = chrom.S[sorted_indices]
end
