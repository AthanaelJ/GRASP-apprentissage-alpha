include("parseSPP.jl")
include("RG.jl")
include("RG_Tabu.jl")
include("RG_Seuil.jl")
include("roulette.jl")
include("plotProbaRGrasp.jl")

function xFoisRG(xItt, C, A, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP(C, A, La, Na, itt)
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

function xFoisTabu(xItt, C, A, La, Na, itt, yparam, zparam, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP_tabu(C, A, La, Na, itt, yparam, zparam)
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

function xFoisT3(xItt, C, A, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z, _)=reactiveGRASP_Seuil(C, A, La, Na, itt)
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

function xFoisRoulette(xItt, C, A, La, Na, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
        (_, z)=roulette(C, A, La, itt)
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

function xFoisBandit(xItt, epsilon, C, A, La, itt, f)
    sommeZ=0
    listZ=Vector{Int64}(undef,xItt)
    for i in 1:xItt
		rewards::Vector{Int64} = ones(itt)
        (_, _, z, _)=BanditM_GRASP(epsilon, C, A, itt, La, rewards)
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
	C, A = parseSPP(fname)
	xFoisRG(xItt, C, A, La, Na, Itt, f)
	xFoisTabu(xItt, C, A, La, Na, Itt, yparam, zparam, f)
	xFoisT3(xItt, C, A, La, Na, Itt, f)
	xFoisRoulette(xItt, C, A, La, Na, Itt, f)
	xFoisBandit(xItt, epsilon, C, A, La, Itt, f)
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

    fname = "Data/pb_100rnd0100.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/pb_100rnd0300.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
    fname = "Data/pb_100rnd0900.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_200rnd0100.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_200rnd0300.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_200rnd0500.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_500rnd0100.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_500rnd0300.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_500rnd0500.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_1000rnd0300.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_1000rnd0500.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_2000rnd0300.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
	fname = "Data/pb_2000rnd0500.dat"
	xFois(xItt, fname, La, Na, Itt, yparam, zparam, f)
end

expe()

#=La=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
Na=50
itt=1000
fname = "Data/pb_1000rnd0300.dat"
C, A = parseSPP(fname)
(S, z, pourcent)=reactiveGRASP_Seuil(C, A, La, Na, itt)
println(z)
using PyPlot
plotProbaRGrasp(pourcent)
println("fini")=#

#=
Data/pb\_100rnd0100.dat & $\substack{ 372.0 \\ 372 \\ 372 | 372 }$ & $\substack{ 372.0 \\ 372 \\ 372 | 372 }$ & $\substack{ 372.0 \\ 372 \\ 372 | 372 }$ & $\substack{ 372.0 \\ 372 \\ 372 | 372 }$ & $\substack{ 372.0 \\ 372 \\ 372 | 372 }$ & 372\\ \hline
Data/pb\_100rnd0300.dat & $\substack{ 203.0 \\ 203 \\ 203 | 203 }$ & $\substack{ 203.0 \\ 203 \\ 203 | 203 }$ & $\substack{ 203.0 \\ 203 \\ 203 | 203 }$ & $\substack{ 203.0 \\ 203 \\ 203 | 203 }$ & $\substack{ 203.0 \\ 203 \\ 203 | 203 }$ & 203\\ \hline
Data/pb\_100rnd0900.dat & $\substack{ 463.0 \\ 463 \\ 463 | 463 }$ & $\substack{ 463.0 \\ 463 \\ 463 | 463 }$ & $\substack{ 463.0 \\ 463 \\ 463 | 463 }$ & $\substack{ 463.0 \\ 463 \\ 463 | 463 }$ & $\substack{ 463.0 \\ 463 \\ 463 | 463 }$ & 463\\ \hline
Data/pb\_200rnd0100.dat & $\substack{ 410.97 \\ 411 \\ 404 | 416 }$ & $\substack{ 410.86 \\ 411 \\ 406 | 414 }$ & $\substack{ 410.62 \\ 411 \\ 404 | 416 }$ & $\substack{ 408.24 \\ 408 \\ 402 | 414 }$ & $\substack{ 408.14 \\ 407 \\ 404 | 414 }$ & 416\\ \hline
Data/pb\_200rnd0300.dat & $\substack{ 714.34 \\ 715 \\ 706 | 722 }$ & $\substack{ 715.66 \\ 716 \\ 702 | 723 }$ & $\substack{ 716.59 \\ 718 \\ 708 | 722 }$ & $\substack{ 712.69 \\ 712 \\ 706 | 720 }$ & $\substack{ 710.72 \\ 710 \\ 703 | 723 }$ & 731\\ \hline
Data/pb\_200rnd0500.dat & $\substack{ 183.28 \\ 184 \\ 177 | 184 }$ & $\substack{ 182.41 \\ 184 \\ 176 | 184 }$ & $\substack{ 182.59 \\ 184 \\ 173 | 184 }$ & $\substack{ 183.83 \\ 184 \\ 183 | 184 }$ & $\substack{ 182.86 \\ 184 \\ 173 | 184 }$ & 184\\ \hline
Data/pb\_500rnd0100.dat & $\substack{ 316.66 \\ 317 \\ 310 | 319 }$ & $\substack{ 316.62 \\ 316 \\ 315 | 320 }$ & $\substack{ 316.55 \\ 317 \\ 311 | 319 }$ & $\substack{ 315.28 \\ 315 \\ 310 | 318 }$ & $\substack{ 315.41 \\ 315 \\ 315 | 319 }$ & 323*\\ \hline
Data/pb\_500rnd0300.dat & $\substack{ 744.62 \\ 746 \\ 735 | 748 }$ & $\substack{ 744.76 \\ 746 \\ 736 | 748 }$ & $\substack{ 745.24 \\ 746 \\ 736 | 751 }$ & $\substack{ 742.97 \\ 746 \\ 735 | 752 }$ & $\substack{ 746.34 \\ 747 \\ 741 | 751 }$ & 776*\\ \hline
Data/pb\_500rnd0500.dat & $\substack{ 122.0 \\ 122 \\ 122 | 122 }$ & $\substack{ 122.0 \\ 122 \\ 122 | 122 }$ & $\substack{ 122.0 \\ 122 \\ 122 | 122 }$ & $\substack{ 122.0 \\ 122 \\ 122 | 122 }$ & $\substack{ 121.86 \\ 122 \\ 118 | 122 }$ & 122\\ \hline
Data/pb\_1000rnd0300.dat & $\substack{ 605.28 \\ 604 \\ 594 | 629 }$ & $\substack{ 607.76 \\ 607 \\ 594 | 633 }$ & $\substack{ 605.45 \\ 605 \\ 596 | 619 }$ & $\substack{ 604.0 \\ 602 \\ 592 | 621 }$ & $\substack{ 603.34 \\ 602 \\ 594 | 626 }$ & 661*\\ \hline
Data/pb\_1000rnd0500.dat & $\substack{ 217.93 \\ 222 \\ 212 | 222 }$ & $\substack{ 217.93 \\ 222 \\ 212 | 222 }$ & $\substack{ 217.86 \\ 222 \\ 211 | 222 }$ & $\substack{ 216.21 \\ 214 \\ 212 | 222 }$ & $\substack{ 218.48 \\ 222 \\ 212 | 222 }$ & 222*\\ \hline
Data/pb\_2000rnd0300.dat & $\substack{ 440.69 \\ 441 \\ 430 | 456 }$ & $\substack{ 443.59 \\ 441 \\ 432 | 459 }$ &  & $\substack{ 439.21 \\ 437 \\ 423 | 459 }$ & $\substack{ 445.97 \\ 443 \\ 436 | 465 }$ & 478* \\ \hline
Data/pb\_2000rnd0500.dat & $\substack{ 133.52 \\ 131 \\ 131 | 140 }$ & $\substack{ 133.21 \\ 131 \\ 130 | 140 }$ &  & $\substack{ 133.31 \\ 131 \\ 131 | 140 }$ & $\substack{ 131.79 \\ 131 \\ 130 | 140 }$ & 140* \\ \hline
=#