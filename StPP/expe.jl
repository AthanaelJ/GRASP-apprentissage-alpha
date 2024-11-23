include("parseStPP.jl")
include("RG.jl")
include("RG_Tabu.jl")
include("RG_Seuil.jl")
include("roulette.jl")
include("plotProbaRGrasp.jl")

function xFoisRG(xItt, n, W, P, Q, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP(n, W, P, Q, La, Na, itt)
        sommeZ+=z
        listZ[i]=z
        print(".")
    end
    println()
    sort!(listZ)
	open(f, "a") do file
		print(file, "\$\\substack{ ", round(sommeZ/xItt, digits=2), " \\\\ ")#moyenne
		if mod(xItt, 2)==0
			stockPair::Int64=xItt/2
			print(file, (listZ[stockPair]+listZ[stockPair + 1])/2, " \\\\ ")#medianne
		else
			stockImpair::Int64=(xItt+1)/2
			print(file, (listZ[stockImpair]), " \\\\ ")#medianne
		end
		print(file, listZ[1], " | ")#minimum
		print(file, listZ[length(listZ)], " }\$ & ")#maximum
		#print(file, listZ)
	end
end

function xFoisTabu(xItt, n, W, P, Q, La, Na, itt, yparam, zparam, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP_tabu(n, W, P, Q, La, Na, itt, yparam, zparam)
        sommeZ+=z
        listZ[i]=z
        print(".")
    end
    println()
    sort!(listZ)
	open(f, "a") do file
		print(file, "\$\\substack{ ", round(sommeZ/xItt, digits=2), " \\\\ ")#moyenne
		if mod(xItt, 2)==0
			stockPair::Int64=xItt/2
			print(file, (listZ[stockPair]+listZ[stockPair + 1])/2, " \\\\ ")#medianne
		else
			stockImpair::Int64=(xItt+1)/2
			print(file, (listZ[stockImpair]), " \\\\ ")#medianne
		end
		print(file, listZ[1], " | ")#minimum
		print(file, listZ[length(listZ)], " }\$ & ")#maximum
		#print(file, listZ)
	end
end

function xFoisT3(xItt, n, W, P, Q, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP_Seuil(n, W, P, Q, La, Na, itt)
        sommeZ+=z
        listZ[i]=z
        print(".")
    end
    println()
    sort!(listZ)
	open(f, "a") do file
		print(file, "\$\\substack{ ", round(sommeZ/xItt, digits=2), " \\\\ ")#moyenne
		if mod(xItt, 2)==0
			stockPair::Int64=xItt/2
			print(file, (listZ[stockPair]+listZ[stockPair + 1])/2, " \\\\ ")#medianne
		else
			stockImpair::Int64=(xItt+1)/2
			print(file, (listZ[stockImpair]), " \\\\ ")#medianne
		end
		print(file, listZ[1], " | ")#minimum
		print(file, listZ[length(listZ)], " }\$ & ")#maximum
		#print(file, listZ)
	end
end

function xFoisRoulette(xItt, n, W, P, Q, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z)=roulette(n, W, P, Q, La, itt)
        sommeZ+=z
        listZ[i]=z
        print(".")
    end
    println()
    sort!(listZ)
	open(f, "a") do file
		print(file, "\$\\substack{ ", round(sommeZ/xItt, digits=2), " \\\\ ")#moyenne
		if mod(xItt, 2)==0
			stockPair::Int64=xItt/2
			print(file, (listZ[stockPair]+listZ[stockPair + 1])/2, " \\\\ ")#medianne
		else
			stockImpair::Int64=(xItt+1)/2
			print(file, (listZ[stockImpair]), " \\\\ ")#medianne
		end
		print(file, listZ[1], " | ")#minimum
		print(file, listZ[length(listZ)], " }\$ &  & ")#maximum
		#print(file, listZ)
	end
end

function xFoisBandit(xItt, epsilon, n, W, P, Q, La, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
		rewards::Vector{Int64} = ones(itt)
        (_, _, z, _)=BanditM_GRASP(epsilon, n, W, P, Q, itt, La, rewards)
        sommeZ+=z
        listZ[i]=z
        print(".")
    end
    println()
    sort!(listZ)
	open(f, "a") do file
		print(file, "\$\\substack{ ", round(sommeZ/xItt, digits=2), " \\\\ ")#moyenne
		if mod(xItt, 2)==0
			stockPair::Int64=xItt/2
			print(file, (listZ[stockPair]+listZ[stockPair + 1])/2, " \\\\ ")#medianne
		else
			stockImpair::Int64=(xItt+1)/2
			print(file, (listZ[stockImpair]), " \\\\ ")#medianne
		end
		print(file, listZ[1], " | ")#minimum
		print(file, listZ[length(listZ)], " }\$")#maximum
		#print(file, listZ)
	end
end

function xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	open(f, "a") do file
		print(file, fname, " & ")
	end
	(n, W, P, Q)=parserStPP(fname)
	xFoisRG(xItt, n, W, P, Q, La, Na, Itt, f)
	xFoisTabu(xItt, n, W, P, Q, La, Na, Itt, yparam, zparam, f)
	xFoisT3(xItt, n, W, P, Q, La, Na, Itt, f)
	xFoisRoulette(xItt, n, W, P, Q, La, Na, Itt, f)
	xFoisBandit(xItt, epsilon, n, W, P, Q, La, Itt, f)
	open(f, "a") do file
		println(file,  "\\\\ \\hline")
	end
end

function expe()
	xItt=29
    La=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
    Na=50
    Itt=1000
	yparam=3
	zparam=0.33
	f="log.txt"
	touch(f)
	open(f, "w") do file
		print(f, "")
	end

    fname = "Data/strip20_1"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip20_2"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip20_3"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip40_1"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip40_2"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip40_3"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip60_1"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip60_2"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip60_3"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip80_1"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip80_2"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip80_3"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip160_1"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip160_2"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/strip160_3"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
end
@time expe()
#=
La=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
Na=50
itt=1000
fname = "Data/strip160_1"
(n, W, P, Q)=parserStPP(fname)
(S, z, pourcent)=reactiveGRASP_T3(n, W, P, Q, La, Na, itt)
println(z)
using PyPlot
plotProbaRGrasp(pourcent)
println("fini")=#

#=
Data/strip20\_1 & $\substack{ 20.03 \\ 20 \\ 20 | 21 }$ & $\substack{ 20.07 \\ 20 \\ 20 | 21 }$ & $\substack{ 20.07 \\ 20 \\ 20 | 21 }$ & $\substack{ 20.0 \\ 20 \\ 20 | 20 }$ &  $\substack{ 20.0 \\ 20 \\ 20 | 20 }$ \\ \hline
Data/strip20\_2 & $\substack{ 21.59 \\ 22 \\ 21 | 22 }$ & $\substack{ 21.38 \\ 21 \\ 21 | 22 }$ & $\substack{ 21.52 \\ 22 \\ 21 | 22 }$ & $\substack{ 21.48 \\ 21 \\ 21 | 22 }$ & $\substack{ 21.45 \\ 21 \\ 21 | 22 }$ \\ \hline
Data/strip20\_3 & $\substack{ 20.1 \\ 20 \\ 20 | 21 }$ & $\substack{ 20.1 \\ 20 \\ 20 | 21 }$ & $\substack{ 20.17 \\ 20 \\ 20 | 21 }$ & $\substack{ 20.17 \\ 20 \\ 20 | 21 }$ &  $\substack{ 20.31 \\ 20 \\ 20 | 21 }$ \\ \hline
Data/strip40\_1 & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ &  $\substack{ 15.97 \\ 16 \\ 15 | 16 }$ \\ \hline
Data/strip40\_2 & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ &  $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ \\ \hline
Data/strip40\_3 & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 15.97 \\ 16 \\ 15 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$ & $\substack{ 15.93 \\ 16 \\ 15 | 16 }$ & $\substack{ 16.0 \\ 16 \\ 16 | 16 }$  \\ \hline
Data/strip60\_1 & $\substack{ 31.86 \\ 32 \\ 31 | 32 }$ & $\substack{ 31.83 \\ 32 \\ 31 | 32 }$ & $\substack{ 31.76 \\ 32 \\ 31 | 32 }$ & $\substack{ 31.62 \\ 32 \\ 31 | 32 }$ &  $\substack{ 31.69 \\ 32 \\ 31 | 32 }$ \\ \hline
Data/strip60\_2 & $\substack{ 32.21 \\ 32 \\ 31 | 33 }$ & $\substack{ 32.21 \\ 32 \\ 31 | 33 }$ & $\substack{ 32.24 \\ 32 \\ 32 | 33 }$ & $\substack{ 32.17 \\ 32 \\ 32 | 33 }$ &  $\substack{ 32.07 \\ 32 \\ 32 | 33 }$ \\ \hline
Data/strip60\_3 & $\substack{ 31.83 \\ 32 \\ 31 | 32 }$ & $\substack{ 31.97 \\ 32 \\ 31 | 32 }$ & $\substack{ 31.9 \\ 32 \\ 31 | 32 }$ & $\substack{ 31.93 \\ 32 \\ 31 | 33 }$ & $\substack{ 31.83 \\ 32 \\ 31 | 32 }$  \\ \hline
Data/strip80\_1 & $\substack{ 127.41 \\ 128 \\ 125 | 128 }$ & $\substack{ 127.17 \\ 127 \\ 125 | 128 }$ & $\substack{ 127.45 \\ 128 \\ 126 | 128 }$ & $\substack{ 127.34 \\ 127 \\ 125 | 128 }$ & $\substack{ 127.34 \\ 128 \\ 126 | 128 }$  \\ \hline
Data/strip80\_2 & $\substack{ 127.72 \\ 128 \\ 125 | 129 }$ & $\substack{ 127.93 \\ 128 \\ 125 | 129 }$ & $\substack{ 127.79 \\ 128 \\ 126 | 130 }$ & $\substack{ 128.07 \\ 128 \\ 126 | 130 }$ &  $\substack{ 127.72 \\ 128 \\ 126 | 130 }$ \\ \hline
Data/strip80\_3 & $\substack{ 128.1 \\ 128 \\ 126 | 129 }$ & $\substack{ 128.14 \\ 128 \\ 126 | 129 }$ & $\substack{ 127.97 \\ 128 \\ 126 | 129 }$ & $\substack{ 128.03 \\ 128 \\ 126 | 129 }$ &  $\substack{ 127.69 \\ 128 \\ 126 | 129 }$ \\ \hline
Data/strip160\_1 & $\substack{ 253.76 \\ 254 \\ 251 | 256 }$ & $\substack{ 253.34 \\ 254 \\ 251 | 255 }$ & $\substack{ 253.34 \\ 253 \\ 251 | 257 }$ & $\substack{ 253.93 \\ 254 \\ 250 | 256 }$ & $\substack{ 254.55 \\ 254 \\ 252 | 258 }$  \\ \hline
Data/strip160\_2 & $\substack{ 253.79 \\ 254 \\ 250 | 256 }$ & $\substack{ 253.41 \\ 254 \\ 251 | 256 }$ & $\substack{ 252.62 \\ 253 \\ 248 | 255 }$ & $\substack{ 253.55 \\ 254 \\ 250 | 257 }$ &  $\substack{ 253.21 \\ 253 \\ 250 | 257 }$ \\ \hline
Data/strip160\_3 & $\substack{ 253.9 \\ 254 \\ 251 | 256 }$ & $\substack{ 253.41 \\ 254 \\ 248 | 255 }$ & $\substack{ 253.1 \\ 253 \\ 250 | 257 }$ & $\substack{ 253.21 \\ 253 \\ 249 | 256 }$ & $\substack{ 254.17 \\ 254 \\ 252 | 257 }$  \\ \hline
=#