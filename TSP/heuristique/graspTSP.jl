"""
Heuristique de GRASP sur TSP.
@param C matrice de coût.   
@param alpha parametre alpha.  
@return (solution amélioré, valeur de la solution amélioré)
"""
function grasp(C, alpha)
    (n, _)=size(C)
    indices = Vector{Int64}(undef,n)#liste des villes non visités
    solution = Vector{Int64}(undef,n)
    candidat = Vector{Tuple{Int64, Int64}}(undef,n)#liste de candidat
    minVal=typemax(Int64)
    for i in 1:n#initialisation indices
        indices[i]=i
    end
    curr=1
    for i in 1:n
        pop!(candidat)
        solution[i]=curr
        minVal=typemax(Int64)
        maxVal=0
        deleteat!(indices, findall(x->x==curr, indices))#supprime la ville actuelle de la liste des villes non visités
        cpt=0
        if length(indices)!=0
            for j in indices#trouve la cout maximum et la distance minimal
                cpt+=1
                candidat[cpt]=(C[curr, j], j)
                if C[curr, j]<minVal
                    minVal=C[curr, j]
                end
                if C[curr, j]>maxVal
                    maxVal=C[curr, j]
                end
            end
            limit=minVal+alpha*(maxVal-minVal)
            RCL=findall(x->x[1]>=limit, candidat)
            (_, curr)=candidat[rand(RCL)]
        end
    end
    return (solution, toZ(solution, C))#TODO calculer à la volé z
end