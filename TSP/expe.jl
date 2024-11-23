include("parseTSP.jl")
include("RG.jl")
include("RG_Tabu.jl")
include("RG_Seuil.jl")
include("roulette.jl")
include("plotProbaRGrasp.jl")

function xFoisRG(xItt, C, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP(C, La, Na, itt)
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

function xFoisTabu(xItt, C, La, Na, itt, yparam, zparam, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP_Tabu(C, La, Na, itt, yparam, zparam)
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

function xFoisT3(xItt, C, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP_Seuil(C, La, Na, itt)
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

function xFoisRoulette(xItt, C, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z)=roulette(C, La, itt)
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

function xFoisBandit(xItt, epsilon, C, La, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
		rewards::Vector{Int64} = ones(itt)
        (_, _, z, _)=BanditM_GRASP(epsilon, C, itt, La, rewards)
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
	C=parseTSP(fname)
	xFoisRG(xItt, C, La, Na, Itt, f)
	xFoisTabu(xItt, C, La, Na, Itt, yparam, zparam, f)
	xFoisT3(xItt, C, La, Na, Itt, f)
	xFoisRoulette(xItt, C, La, Na, Itt, f)
	xFoisBandit(xItt, epsilon, C, La, Itt, f)
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

    fname = "Data/bayg29.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    #=fname = "Data/bays29.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/brazil58.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/dantzig42.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/fri26.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/gr17.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/gr21.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/gr24.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/gr48.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/gr120.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/hk48.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/pa561.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/si175.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/si535.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/si1032.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/swiss42.tsp"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)=#
end

@time expe()
#=La=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
Na=50
itt=1000
fname = "Data/si1032.tsp"
C=parseTSP(fname)
(S, z, pourcent)=reactiveGRASP(C, La, Na, itt)
println(z)
using PyPlot
plotProbaRGrasp(pourcent)
println("fini")=#

#=
Data/bayg29.tsp & $\substack{ 1610.0 \\ 1610 \\ 1610 | 1610 }$ & $\substack{ 1610.0 \\ 1610 \\ 1610 | 1610 }$ & $\substack{ 1610.0 \\ 1610 \\ 1610 | 1610 }$ & $\substack{ 1610.0 \\ 1610 \\ 1610 | 1610 }$ & $\substack{ 1610.0 \\ 1610 \\ 1610 | 1610 }$ & 1610 \\ \hline
Data/bays29.tsp & $\substack{ 2020.0 \\ 2020 \\ 2020 | 2020 }$ & $\substack{ 2020.0 \\ 2020 \\ 2020 | 2020 }$ & $\substack{ 2020.0 \\ 2020 \\ 2020 | 2020 }$ & $\substack{ 2020.0 \\ 2020 \\ 2020 | 2020 }$ & $\substack{ 2020.0 \\ 2020 \\ 2020 | 2020 }$ & 2020 \\ \hline
Data/brazil58.tsp & $\substack{ 25395.17 \\ 25395 \\ 25395 | 25400 }$ & $\substack{ 25395.52 \\ 25395 \\ 25395 | 25400 }$ & $\substack{ 25398.28 \\ 25395 \\ 25395 | 25480 }$ & $\substack{ 25400.86 \\ 25395 \\ 25395 | 25475 }$ & $\substack{ 25395.17 \\ 25395 \\ 25395 | 25400 }$ & 25395\\ \hline
Data/dantzig42.tsp & $\substack{ 699.0 \\ 699 \\ 699 | 699 }$ & $\substack{ 699.0 \\ 699 \\ 699 | 699 }$ & $\substack{ 699.0 \\ 699 \\ 699 | 699 }$ & $\substack{ 699.0 \\ 699 \\ 699 | 699 }$ & $\substack{ 699.0 \\ 699 \\ 699 | 699 }$ & 699\\ \hline
Data/fri26.tsp & $\substack{ 937.0 \\ 937 \\ 937 | 937 }$ & $\substack{ 937.0 \\ 937 \\ 937 | 937 }$ & $\substack{ 937.0 \\ 937 \\ 937 | 937 }$ & $\substack{ 937.0 \\ 937 \\ 937 | 937 }$ & $\substack{ 937.0 \\ 937 \\ 937 | 937 }$ & 937\\ \hline
Data/gr17.tsp & $\substack{ 2085.72 \\ 2085 \\ 2085 | 2088 }$ & $\substack{ 2085.41 \\ 2085 \\ 2085 | 2088 }$ & $\substack{ 2086.34 \\ 2085 \\ 2085 | 2088 }$ & $\substack{ 2085.41 \\ 2085 \\ 2085 | 2088 }$ & $\substack{ 2086.14 \\ 2085 \\ 2085 | 2088 }$ & 2085\\ \hline
Data/gr21.tsp & $\substack{ 2707.0 \\ 2707 \\ 2707 | 2707 }$ & $\substack{ 2707.0 \\ 2707 \\ 2707 | 2707 }$ & $\substack{ 2707.0 \\ 2707 \\ 2707 | 2707 }$ & $\substack{ 2707.0 \\ 2707 \\ 2707 | 2707 }$ & $\substack{ 2707.0 \\ 2707 \\ 2707 | 2707 }$ & 2707\\ \hline
Data/gr24.tsp & $\substack{ 1272.0 \\ 1272 \\ 1272 | 1272 }$ & $\substack{ 1272.0 \\ 1272 \\ 1272 | 1272 }$ & $\substack{ 1272.0 \\ 1272 \\ 1272 | 1272 }$ & $\substack{ 1272.0 \\ 1272 \\ 1272 | 1272 }$ & $\substack{ 1272.0 \\ 1272 \\ 1272 | 1272 }$ & 1272\\ \hline
Data/gr48.tsp & $\substack{ 5065.52 \\ 5066 \\ 5049 | 5080 }$ & $\substack{ 5066.93 \\ 5066 \\ 5055 | 5080 }$ & $\substack{ 5069.41 \\ 5074 \\ 5046 | 5080 }$ & $\substack{ 5063.07 \\ 5063 \\ 5046 | 5080 }$ & $\substack{ 5068.34 \\ 5074 \\ 5046 | 5078 }$ & 5046\\ \hline
Data/gr120.tsp & $\substack{ 7133.24 \\ 7133 \\ 7088 | 7187 }$ & $\substack{ 7130.14 \\ 7136 \\ 7060 | 7194 }$ & $\substack{ 7133.34 \\ 7139 \\ 7063 | 7187 }$ & $\substack{ 7133.14 \\ 7136 \\ 7041 | 7175 }$ & $\substack{ 7123.31 \\ 7131 \\ 7058 | 7169 }$ & 6942\\ \hline
Data/hk48.tsp & $\substack{ 11546.79 \\ 11545 \\ 11461 | 11624 }$ & $\substack{ 11525.76 \\ 11511 \\ 11470 | 11611 }$ & $\substack{ 11530.1 \\ 11532 \\ 11461 | 11603 }$ & $\substack{ 11535.41 \\ 11532 \\ 11461 | 11614 }$ & $\substack{ 11527.69 \\ 11532 \\ 11461 | 11617 }$ & 11461\\ \hline
Data/pa561.tsp & $\substack{ 3005.07 \\ 3006 \\ 2979 | 3028 }$ & $\substack{ 3010.59 \\ 3012 \\ 2973 | 3031 }$ & $\substack{ 3005.07 \\ 3007 \\ 2971 | 3024 }$ & $\substack{ 3004.97 \\ 3007 \\ 2984 | 3029 }$ & $\substack{ 3007.28 \\ 3008 \\ 2976 | 3024 }$ & 2763\\ \hline
Data/si175.tsp & $\substack{ 21486.72 \\ 21485 \\ 21465 | 21511 }$ & $\substack{ 21489.93 \\ 21491 \\ 21454 | 21521 }$ & $\substack{ 21492.93 \\ 21495 \\ 21456 | 21519 }$ & $\substack{ 21489.72 \\ 21492 \\ 21456 | 21522 }$ & $\substack{ 21491.21 \\ 21495 \\ 21454 | 21519 }$ & 21407\\ \hline
Data/si535.tsp & $\substack{ 48760.07 \\ 48765 \\ 48725 | 48785 }$ & $\substack{ 48764.72 \\ 48769 \\ 48708 | 48806 }$ & $\substack{ 48760.03 \\ 48761 \\ 48707 | 48811 }$ & $\substack{ 48770.03 \\ 48774 \\ 48716 | 48810 }$ & $\substack{ 48754.0 \\ 48760 \\ 48688 | 48792 }$ & 48450\\ \hline
Data/si1032.tsp & $\substack{ 93168.24 \\ 93169 \\ 93022 | 93308 }$ & $\substack{ 93181.66 \\ 93193 \\ 93032 | 93346 }$ & $\substack{ 93160.38 \\ 93170 \\ 92983 | 93285 }$ & $\substack{ 93168.24 \\ 93160 \\ 93039 | 93300 }$ & $\substack{ 93181.07 \\ 93211 \\ 92996 | 93269 }$ & 92650\\ \hline
Data/swiss42.tsp & $\substack{ 1273.0 \\ 1273 \\ 1273 | 1273 }$ & $\substack{ 1273.03 \\ 1273 \\ 1273 | 1274 }$ & $\substack{ 1273.03 \\ 1273 \\ 1273 | 1274 }$ & $\substack{ 1273.03 \\ 1273 \\ 1273 | 1274 }$ & $\substack{ 1273.0 \\ 1273 \\ 1273 | 1273 }$ & 1273\\ \hline
=#