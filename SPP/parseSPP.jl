"""
Parseur SPP.
@param String nom du fichier à parser.
@return C la matrice de coût, A matrice indiquant quelles activités consomment quelles ressources.
"""
function parseSPP(fname)
    f=open(fname)
    # lecture du nbre de contraintes (m) et de variables (n)
    m, n = parse.(Int, split(readline(f)) )
    # lecture des n coefficients de la fonction economique et cree le vecteur d'entiers c
    C = parse.(Int, split(readline(f)) )
    # lecture des m contraintes et reconstruction de la matrice binaire A
    A=zeros(Int, m, n)
    for i=1:m
        # lecture du nombre d'elements non nuls sur la contrainte i (non utilise)
        readline(f)
        # lecture des indices des elements non nuls sur la contrainte i
        for valeur in split(readline(f))
          j = parse(Int, valeur)
          A[i,j]=1
        end
    end
    close(f)
    return C, A
end


"""
Transforme la solution en sa valeur z.
@param S la solution.
@param C la matrice de coût.
@return z.
"""
function toZ(S::Vector{Int64}, C::Vector{Int64})
	sum=0
	for i in S
		sum+=C[i]
	end
	return sum
end

"""
Verifie si la solution est admissible.
@param A matrice indiquant quelles activités consomment quelles ressources.
@param S la solution.
"""
function validationSolution(A, S)
	(n, _)=size(A)
	stock=[]
	for i in S
		for j in findall(x->A[x, i]==1, 1:n)
			if j in stock
				return false
			end
			push!(stock, j)
		end
	end
	return true
end