"""
Parseur StPP.
@param String nom du fichier à parser.
@return (n nombre de rectangle, W largeur de la bande, P liste des dimentions des rectangles, Q liste du nombre de chaque rectangles).
"""
function parserStPP(fname)
    f=open(fname)
    n = parse.(Int, readline(f))
    W = parse.(Int, readline(f))
    P = Vector{Vector{Int64}}(undef, n)
    Q = Vector{Int64}(undef, n)
    for i=1:n
        (x, y) = parse.(Int, split(readline(f)))
        P[i]=[x, y]
        Q[i]=1
    end
    close(f)
    return (n, W, P, Q)
end

"""
Verifie si la solution est admissible en la printant (plots doit être inclut).
@param solution la solution.
"""
function validationSolution(solution)
    rectangle(w, h, x, y) = Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])
    plot()
    for (xplot, yplot, wplot, hplot) in solution 
        plot!(rectangle(wplot,hplot,xplot,yplot))#, color=15)
        plot!([xplot, xplot+wplot], [yplot, yplot+hplot], color=1)
        plot!([xplot, xplot+wplot], [yplot+hplot, yplot], color=1)
    end
    plot!(rectangle(W,z,0,0), opacity=.10, legend=false, aspect_ratio=:equal)
    savefig("validation")
end
function rectangle(w, h, x, y)
    return Shape(x + [0,w,w,0], y + [0,0,h,h])
end