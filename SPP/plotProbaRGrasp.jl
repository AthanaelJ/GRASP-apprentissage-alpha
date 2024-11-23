"""
plot des probas d'une run Reactive-GRASP.
@param pourcent liste des pourcentages des classes alphas pour chaque raffréchissement.
"""
function plotProbaRGrasp(pourcent)

    @assert length(La) <= 9 "Stop : trop de classes de valeurs de α demandé"

    nClasses = length(pourcent)
    nAjustement = length(pourcent[1])
    data = Array{Float64}(undef,nAjustement,nClasses)
    for i=1 : nClasses
		for j = 1 : nAjustement
      data[j,i]= pourcent[i][j]
		end
    end
    X = collect(1:nAjustement)

    #@show nAjustement
    #@show pourcent
    #@show data

    figure("Examen des valeurs de α pour 1 run",figsize=(8,5)) # Create a new figure

    name = "Set1" # https://matplotlib.org/gallery/color/colormap_reference.html
    cmap = get_cmap(name)
    colors = cmap.colors

    refBottom = zeros(nAjustement)
    for niveau=1:nClasses
        if niveau > 1
            refBottom = refBottom + data[:,niveau-1]
        end
        plt.barh(X, data[:,niveau], height=0.6, edgecolor="white", label= La[niveau], color=colors[niveau], left=refBottom)
    end

    ylabel("Itérations d'ajustement de α par classe")
    xlabel("Probabilités")
    plt.yticks([1,nAjustement])
    legend(ncol=length(La), bbox_to_anchor=(0,1), loc="lower left", fontsize="small")
    savefig("output")
end