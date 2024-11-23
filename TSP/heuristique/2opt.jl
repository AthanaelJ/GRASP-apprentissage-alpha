"""
Heuristique de descente 2opt sur TSP.
@param C matrice de coût.  
@param solution solution sur laquel effecter la descente. 
@return (solution amélioré, valeur de la solution amélioré)
"""
function opt(C, solution)
	amelio=true
    n=size(C, 1)
    while amelio
        amelio=false
        for i in 0:n-1#On est obligé de mettre des +1 partout car julia commence c'est tableau à 1 et pas à 0
            for j in i+1:n-1
                if j!=mod(i-1, n) #on exclut les couples d'arcs consécutif
                    if C[solution[i+1], solution[mod(i+1, n)+1]]+C[solution[j+1], solution[mod(j+1, n)+1]]>C[solution[i+1], solution[j+1]]+C[solution[mod(i+1, n)+1], solution[mod(j+1, n)+1]]
                        #si la solution est améliorante
                        for k in 0:div((j+1-mod(i+1, n))+1, 2)-1 #on "met à l'enver" toute la route entre les deux arcs échangé
                            stockVar=solution[mod(i+1, n)+1+k]
                            solution[mod(i+1, n)+1+k]=solution[j+1-k]
                            solution[j+1-k]=stockVar
                        end
                        amelio=true
                    end
                end
            end
        end
    end
    return (solution, toZ(solution, C))#TODO calculer à la volé z
end