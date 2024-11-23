"""
Heuristique de construction nearest neighbors sur TSP.
@param C matrice de coût.   
@return (solution construit, valeur de la solution construit)
"""
function nearestNeighbors(C)
    (n, _)=size(C)
    indices = Vector{Int64}(undef,n)#liste des villes non visités
    solution = Vector{Int64}(undef,n)
    minVal=typemax(Int64)
    for i in 1:n#initialisation indices
        indices[i]=i
    end
    curr=1
    for i in 1:n
        solution[i]=curr
        minVal=typemax(Int64)
        deleteat!(indices, findall(x->x==curr, indices))#supprime la ville actuelle de la liste des villes non visités
        for j in indices#trouve la ville la plus proche de la ville actuelle
            if C[curr, j]<minVal
                minVal=C[curr, j]
                curr=j
            end
        end
    end
    return (solution, toZ(solution, C))#TODO calculer à la volé z
end