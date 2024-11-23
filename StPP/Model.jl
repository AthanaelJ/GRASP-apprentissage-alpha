using JuMP, GLPK

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

function resolution(n, W, P, Q)
	m=Model(GLPK.Optimizer)
    set_optimizer_attribute(m, "msg_lev", GLPK.GLP_MSG_ALL)
	@variable(m, x[1:n]>=0)
	@variable(m, y[1:n]>=0)
    @variable(m, H>=0)
    @variable(m, bool1[i=1:n, j=1:n]>=0, binary=true)
    @variable(m, bool2[i=1:n, j=1:n]>=0, binary=true)
    @variable(m, bool3[i=1:n, j=1:n]>=0, binary=true)
    @variable(m, bool4[i=1:n, j=1:n]>=0, binary=true)
	@objective(m, Min, H)
	@constraint(m, nom1[i=1:n], x[i]+P[i][1]<=W)
	@constraint(m, nom2[i=1:n], y[i]+P[i][2]<=H)
    #@constraint(m, nom3[i=1:n, j=1:n; i!=j], (x[i]+P[i][1])*bool1[i,j]+(x[j]+P[j][1])*bool2[i,j]+(y[i]+P[i][2])*bool3[i,j]+(y[j]+P[j][2])*bool4[i,j]<=x[j]*bool1[i,j]+x[i]*bool2[i,j]+y[j]*bool3[i,j]+y[i]*bool4[i,j]) 
    
	@constraint(m, nom3[i=1:n, j=1:n; i!=j], x[i]+P[i][1]<=x[j]+W*(1-bool1[i,j])) 
	
    @constraint(m, nom4[i=1:n, j=1:n; i!=j], x[j]+P[j][1]<=x[i]+W*(1-bool2[i,j])) 
	@constraint(m, nom5[i=1:n, j=1:n; i!=j], y[i]+P[i][2]<=y[j]+20*(1-bool3[i,j])) 
	@constraint(m, nom6[i=1:n, j=1:n; i!=j], y[j]+P[j][2]<=y[i]+20*(1-bool4[i,j])) 
	@constraint(m, nom7[i=1:n, j=1:n; i!=j], bool1[i,j]+bool2[i,j]+bool3[i,j]+bool4[i,j]>=1) 
	println("start")
    optimize!(m)
    println("end")
    status = termination_status(m)

    @show m

    if status == MOI.OPTIMAL
		println("Optimale !!!")
	
		println("z =", objective_value(m))
	elseif status == MOI.INFEASIBLE
		println("Pb non-borné")
	elseif status == MOI.INFEASIBLE_OR_UNBOUNDED
		println("Pb impossible")
	end

end
fname = "Data/strip20_1"
(n, W, P, Q)=parserStPP(fname)
@time resolution(n, W, P, Q)