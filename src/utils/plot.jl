function plot_3d_scatter(df1::DataFrame, df2::Union{DataFrame, Nothing}=nothing, color1::String="blue", color2::String="red")
    # Scatter plot für das erste DataFrame
    trace1 = scatter(
        x = df1[:, :Belastung],
        y = df1[:, :Dauer],
        z = df1[:, :Kosten],
        text = [string(modus, "<br>ID: ", id) for (modus, id) in zip(df1[:, :Modus], df1[:, :ID])],
        mode = "markers",
        marker = attr(size=2, opacity=0.8, color=color1),  # Farbe für df1
        name = "Gurobi",
        type = "scatter3d",
        dpi = 1000
    )

    # Scatter plot für den zweiten DataFrame, falls vorhanden
    if df2 !== nothing
        trace2 = scatter(
            x = df2[:, :Belastung],
            y = df2[:, :Dauer],
            z = df2[:, :Kosten],
            text = [string(modus, "<br>ID: ", id) for (modus, id) in zip(df2[:, :Modus], df2[:, :ID])],
            mode = "markers",
            marker = attr(size=2, opacity=0.8, color=color2),  # Farbe für df2
            name = "NSGA-II",
            type = "scatter3d",
            dpi = 1000
        )
        traces = [trace1, trace2]
    else
        traces = [trace1]
    end

    # Berechnung von Ideal- und Nadir-Punkt
    Ideal_Kosten = findmin(df1[:, :Kosten])[1]
    Ideal_Belastung = findmin(df1[:, :Belastung])[1]
    Ideal_Dauer = findmin(df1[:, :Dauer])[1]
    Nadir_Kosten = findmax(df1[:, :Kosten])[1]
    Nadir_Belastung = findmax(df1[:, :Belastung])[1]
    Nadir_Dauer = findmax(df1[:, :Dauer])[1]

    # Ideal-Punkt hinzufügen
    trace_ideal = scatter(
        x = [Ideal_Belastung],
        y = [Ideal_Dauer],
        z = [Ideal_Kosten],
        text = ["Ideal-Punkt"],
        mode = "markers",
        marker = attr(size=4, color="green", opacity=0.8), 
        name = "Ideal-Punkt",
        type = "scatter3d",
        dpi = 1000
    )
    push!(traces, trace_ideal)

    # Nadir-Punkt hinzufügen
    trace_nadir = scatter(
        x = [Nadir_Belastung],
        y = [Nadir_Dauer],
        z = [Nadir_Kosten],
        text = ["Nadir-Punkt"],
        mode = "markers",
        marker = attr(size=4, color="orange", opacity=0.8),
        name = "Nadir-Punkt",
        type = "scatter3d",
        dpi = 1000
    )
    push!(traces, trace_nadir)

    # Layout für den Plot
    layout = Layout(
        scene = attr(
            xaxis = attr(
                title = "Beanspruchung [kJ/min.]",
                range = (5, 16),
                backgroundcolor = "rgba(255, 255, 255, 0)",   # Hintergrundfarbe für die Achsen
                mirror = true,
                ticks = "outside",
                showline = true,
                linecolor = "black",
                gridcolor = "lightgrey",
                linewidth = 3,
                gridwidth = 2
            ),
            yaxis = attr(
                title = "Zeit [min.]",
                range = (280, 650),
                backgroundcolor = "rgba(255, 255, 255, 0)",   # Hintergrundfarbe für die Achsen
                mirror = true,
                ticks = "outside",
                showline = true,
                linecolor = "black",
                gridcolor = "lightgrey",
                linewidth = 3, 
                gridwidth = 2
            ),
            zaxis = attr(
                title = "Kosten [€]",
                range = (690, 1800),
                backgroundcolor = "rgba(255, 255, 255, 0)",  # Hintergrundfarbe für die Achsen
                mirror = true,
                ticks = "outside",
                showline = true,
                linecolor = "black",
                gridcolor = "lightgrey",
                linewidth = 3,
                gridwidth = 2
            ),
            camera = attr(  # Kameraansicht wird definiert
                eye = attr(x=1.42, y=-1.42, z=1.0),  # Kamera entlang der z-Achse verschoben
                center=attr(x=0, y=0, z=-0.29)
            ),
            dragmode = "pan",
            width = 10000,
            margin = attr(l=0, r=0, b=0, t=0)
        ),
        paper_bgcolor = "white",  # Hintergrundfarbe für den gesamten Plotbereich
        plot_bgcolor = "rgba(255, 255, 255, 0)",   # Hintergrundfarbe für den Plot
        legend = attr(
            font = attr(size=14),
            bordercolor = "Black",
            itemsizing = "constant",
            borderwidth = 2
        )
    )

    # Erstellen des Plots
    plot = Plot(traces, layout)

    return plot
end



# Funktion zur Bestimmung, ob ein Punkt dominiert wird
function dominates(point, other_point)
    # Runden der Werte auf 5 Nachkommastellen
    rounded_point = round.(point, digits=5)
    rounded_other_point = round.(other_point, digits=5)

    # Punkt dominiert, wenn alle Bedingungen erfüllt sind
    and_conditions = all(rounded_point .<= rounded_other_point)
    # Mindestens ein Wert von point muss strikt kleiner sein
    or_condition = any(rounded_point .< rounded_other_point)
    
    return and_conditions && or_condition
end

# Berechnung der Dominanzbeziehungen für alle Punkte
function non_dominated_sort(df)
    n = nrow(df)
    domination_count = zeros(Int, n)
    dominated_points = [[] for _ in 1:n]
    rank = fill(-1, n)
    fronts = [[]]

    # Bestimme Dominanzbeziehungen
    for i in 1:n
        for j in 1:n
            if i != j
                if dominates(collect(df[i, [:Dauer, :Kosten, :Belastung]]), collect(df[j, [:Dauer, :Kosten, :Belastung]]))
                    push!(dominated_points[i], j)
                elseif dominates(collect(df[j, [:Dauer, :Kosten, :Belastung]]), collect(df[i, [:Dauer, :Kosten, :Belastung]]))
                    domination_count[i] += 1
                end
            end
        end
        if domination_count[i] == 0
            rank[i] = 1  # Rang 1 für die erste Front
            push!(fronts[1], i)
        end
    end

    current_front = 1
    while !isempty(fronts[current_front])
        next_front = []
        for ind_no in fronts[current_front]
            for other_ind_no in dominated_points[ind_no]
                domination_count[other_ind_no] -= 1
                if domination_count[other_ind_no] == 0
                    rank[other_ind_no] = current_front + 1  # Nächste Front (Rang +1)
                    push!(next_front, other_ind_no)
                end
            end
        end
        push!(fronts, next_front)
        current_front += 1
    end

    return rank
end


function plot_3d_scatter_zoom(df1::DataFrame, df2::Union{DataFrame, Nothing}=nothing, color1::String="blue", color2::String="red")
    # Scatter plot für das erste DataFrame
    trace1 = scatter(
        x = df1[:, :Belastung],
        y = df1[:, :Dauer],
        z = df1[:, :Kosten],
        text = [string(modus, "<br>ID: ", id) for (modus, id) in zip(df1[:, :Modus], df1[:, :ID])],
        mode = "markers",
        marker = attr(size=4, opacity=0.8, color=color1),  # Farbe für df1
        name = "Gurobi",
        type = "scatter3d",
        dpi = 1000
    )

    # Scatter plot für den zweiten DataFrame, falls vorhanden
    if df2 !== nothing
        trace2 = scatter(
            x = df2[:, :Belastung],
            y = df2[:, :Dauer],
            z = df2[:, :Kosten],
            text = [string(modus, "<br>ID: ", id) for (modus, id) in zip(df2[:, :Modus], df2[:, :ID])],
            mode = "markers",
            marker = attr(size=4, opacity=0.8, color=color2),  # Farbe für df2
            name = "NSGA-II",
            type = "scatter3d",
            dpi = 1000
        )
        traces = [trace1, trace2]
    else
        traces = [trace1]
    end

    # Berechnung von Ideal- und Nadir-Punkt
    Ideal_Kosten = findmin(df1[:, :Kosten])[1]
    Ideal_Belastung = findmin(df1[:, :Belastung])[1]
    Ideal_Dauer = findmin(df1[:, :Dauer])[1]
    Nadir_Kosten = findmax(df1[:, :Kosten])[1]
    Nadir_Belastung = findmax(df1[:, :Belastung])[1]
    Nadir_Dauer = findmax(df1[:, :Dauer])[1]

    # Ideal-Punkt hinzufügen
    trace_ideal = scatter(
        x = [Ideal_Belastung],
        y = [Ideal_Dauer],
        z = [Ideal_Kosten],
        text = ["Ideal-Punkt"],
        mode = "markers",
        marker = attr(size=4, color="green", opacity=0.8), 
        name = "Ideal-Punkt",
        type = "scatter3d",
        dpi = 1000
    )
    push!(traces, trace_ideal)

    # Nadir-Punkt hinzufügen
    trace_nadir = scatter(
        x = [Nadir_Belastung],
        y = [Nadir_Dauer],
        z = [Nadir_Kosten],
        text = ["Nadir-Punkt"],
        mode = "markers",
        marker = attr(size=4, color="orange", opacity=0.8),
        name = "Nadir-Punkt",
        type = "scatter3d",
        dpi = 1000
    )
    push!(traces, trace_nadir)

    # Layout für den Plot
    layout = Layout(
        scene = attr(
            xaxis = attr(
                title = "Beanspruchung [kJ/min.]",
                range = (5, 16),
                backgroundcolor = "rgba(255, 255, 255, 0)",   # Hintergrundfarbe für die Achsen
                mirror = true,
                ticks = "outside",
                showline = true,
                linecolor = "black",
                gridcolor = "lightgrey",
                linewidth = 3,
                gridwidth = 2
            ),
            yaxis = attr(
                title = "Zeit [min.]",
                range = (280, 650),
                backgroundcolor = "rgba(255, 255, 255, 0)",   # Hintergrundfarbe für die Achsen
                mirror = true,
                ticks = "outside",
                showline = true,
                linecolor = "black",
                gridcolor = "lightgrey",
                linewidth = 3, 
                gridwidth = 2
            ),
            zaxis = attr(
                title = "Kosten [€]",
                range = (690, 1800),
                backgroundcolor = "rgba(255, 255, 255, 0)",  # Hintergrundfarbe für die Achsen
                mirror = true,
                ticks = "outside",
                showline = true,
                linecolor = "black",
                gridcolor = "lightgrey",
                linewidth = 3,
                gridwidth = 2
            ),
            camera = attr(  # Kameraansicht wird definiert
                eye = attr(x=1.42, y=-1.42, z=1.0), 
                center=attr(x=0, y=0, z=-0.35)
            ),
            aspectratio=attr(x=3, y=3, z=3),
            dragmode = "pan",
            width = 10000,
            margin = attr(l=0, r=0, b=0, t=0)
        ),
        paper_bgcolor = "white",  # Hintergrundfarbe für den gesamten Plotbereich
        plot_bgcolor = "rgba(255, 255, 255, 0)",   # Hintergrundfarbe für den Plot
        legend = attr(
            font = attr(size=14),
            bordercolor = "Black",
            itemsizing = "constant",
            borderwidth = 2
        )
    )

    # Erstellen des Plots
    plot = Plot(traces, layout)

    return plot
end