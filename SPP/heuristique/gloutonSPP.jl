"""
Heuristique de construction gloutonne sur SPP.
@param C matrice de coût.
@param A matrice indiquant quelles activités consomment quelles ressources.
@return (solution construit, valeur de la solution construit)
"""
function glouton(C::Vector{Int64}, A::Matrix{Int64})
	(n, m)=size(A)
	S::Vector{Int64}=[]
	u=Vector{Tuple{Float64, Int64}}(undef, m) #(cout/occurence activité, num activité)
	possible=Vector{Bool}(undef, m)
	z::Int64=0
	for j in 1:m #pour chaque variables
		possible[j]=true
		u[j]=((C[j]/sum(A[:, j])),j) #cout divisé par l'occurence 
	end
	sort!(u, rev=true) #on priorise les plus hautes valeurs
	for (_, elt) in u
		if (possible[elt])
			push!(S, elt)
			z+=C[elt]
			for i in findall(x->A[x, elt]==1, 1:n) #on parcourt les activités qui utilisent les ressources 
				for j in findall(x->A[i, x]==1, 1:m)
					possible[j]=false
				end
			end
		end
	end
	return (S, z)
end