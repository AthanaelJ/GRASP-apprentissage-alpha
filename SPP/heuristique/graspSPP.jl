"""
Heuristique de GRASP sur SPP.
@param C matrice de coût.
@param A matrice indiquant quelles activités consomment quelles ressources.
@param alpha parametre alpha.  
@return (solution construit, valeur de la solution construit)
"""
function grasp(C, A, alpha)
	(n, m)=size(A)
	S::Vector{Int64}=[]
	u=Vector{Tuple{Float64, Int64}}(undef, m) #(cout/occurence activité, num activité)
	possible=Vector{Bool}(undef, m)
	z::Int64=0
	for j in 1:m #pour chaque variables
		possible[j]=true
		u[j]=((C[j]/sum(A[:, j])),j) #cout divisé par l'occurence 
	end
    uInC=u[1]
    while (uInC!=[])#tant qu'il y a des candidats
        uInC=u[findall(x->possible[x], 1:m)] #on sélectionne tout les candidats
        RCL=[]
        if uInC!=[]
            (min, _)=uInC[argmin(uInC)]
            (max, _)=uInC[argmax(uInC)]
            limit=min+alpha*(max-min) #calcule de la limite
            for (valeur, elt) in uInC #selection de la RCL
                if (valeur>=limit)
                    push!(RCL, elt)
                end
            end
            if RCL!=[]
                elt=rand(RCL)
                push!(S, elt)
                z+=C[elt]
                for i in findall(x->A[x, elt]==1, 1:n) #on parcourt les activités qui utilisent les ressources 
                    for j in findall(x->A[i, x]==1, 1:m)
                        possible[j]=false
                    end
                end
            end
        end
    end
	return (S, z)
end