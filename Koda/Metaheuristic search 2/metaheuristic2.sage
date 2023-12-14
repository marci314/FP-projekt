import numpy as np
import math
from scipy.special import comb


def stevilo_povezav(x):
    prvi_del = sum(x[i] * x[i + 1] for i in range(len(x) - 1))
    drugi_del = sum(comb(x[i], 2) for i in range(len(x)))
    return prvi_del + drugi_del


def nakljucna_zamenjava(trenutna_resitev):
    x = trenutna_resitev.copy()
    index_ki_se_zmanjsa = np.random.randint(len(x))
    x[index_ki_se_zmanjsa] -= 1
    while True:
        index_ki_se_zveca = np.random.randint(len(x))
        if index_ki_se_zveca != index_ki_se_zmanjsa:
            x[index_ki_se_zveca] += 1
            return x

def zacetni_niz(n, d):
    niz = [1] * (d + 1)
    for i in range(n - d - 1):
        index = np.random.randint(d + 1)
        niz[index] += 1
    return niz

def preveri_povezanost_oziroma_premer(niz):
    for element in niz:
        if element < 1:
            return False
    return True

def poveca_min_element(niz):
    min_index = niz.index(min(niz))
    niz[min_index] += 1
    return niz

def zmanjsa_max_element(niz):
    max_index = niz.index(max(niz))
    niz[max_index] -= 1
    return niz

# Metahurističnni algoritem
def simulirano_hlajenje(n, max_iteracij, zacetna_temperatura, stopnja_hlajenja, d):
    # Preveri ali je izbrani premer ustrezen
    if d >= n:
        return 'Izbrani premer je prevelik'
    elif d < 1:
        return 'Izbrani premer je premajhen'
    elif d == 1:
        st_povezav = n * (n - 1) / 2
        niz = [n]
        return st_povezav, niz
    elif d == n - 1:
        st_povezav = d
        niz = [1] * (d + 1)
        return st_povezav, niz
    else:
        trenutni_niz = zacetni_niz(n, d)
        najboljsi_niz = trenutni_niz.copy()
        temperatura = zacetna_temperatura
        for iteracija in range(max_iteracij):
            if sum(trenutni_niz) == n and preveri_povezanost_oziroma_premer(trenutni_niz):
                novi_niz = nakljucna_zamenjava(trenutni_niz)
                delta = stevilo_povezav(novi_niz) - stevilo_povezav(trenutni_niz)
                if (delta >= 0 and sum(novi_niz) == n and preveri_povezanost_oziroma_premer(novi_niz)) or np.random.random() < math.exp(-delta / temperatura):
                    trenutni_niz = novi_niz.copy()
                    if stevilo_povezav(novi_niz) >= stevilo_povezav(najboljsi_niz) and sum(novi_niz) == n and preveri_povezanost_oziroma_premer(novi_niz):
                        najboljsi_niz = novi_niz.copy()
            else:
                novi_niz = poveca_min_element(trenutni_niz)
                while sum(novi_niz) > n:
                    novi_niz = zmanjsa_max_element(novi_niz)
                trenutni_niz = novi_niz.copy()
                if stevilo_povezav(novi_niz) >= stevilo_povezav(najboljsi_niz) and sum(novi_niz) == n and preveri_povezanost_oziroma_premer(novi_niz):
                        najboljsi_niz = novi_niz.copy()
            temperatura *= stopnja_hlajenja
        najbolse_st_povezav = stevilo_povezav(najboljsi_niz)
    return najbolse_st_povezav, najboljsi_niz



n = 45
d = 4
max_iteracij = 10000
zacetna_temperatura = 1
stopnja_hlajenja = 0.99999

y = simulirano_hlajenje(n, max_iteracij, zacetna_temperatura, stopnja_hlajenja, d)
print(y)


import networkx as nx
import matplotlib.pyplot as plt
from itertools import combinations


def construct_graph(subgraph_sizes):
    G = nx.Graph()
    nodes = 0
    for size in subgraph_sizes:
        subgraph_nodes = range(nodes, nodes + size)
        G.add_nodes_from(subgraph_nodes)

        # Povezi vozlisca znotraj trenutnega podgrafa
        G.add_edges_from(combinations(subgraph_nodes, 2))

        # Poveži vsa vozlisca med prejsnjim in trenutnim podgrafom
        if nodes > 0:
            prev_subgraph_nodes = range(nodes - subgraph_sizes[-2], nodes)
            G.add_edges_from([(u, v) for u in prev_subgraph_nodes for v in subgraph_nodes])

        nodes += size

    return G


# Primer uporabe
subgraph_sizes = y[1]
graph = construct_graph(subgraph_sizes)

# Narisemo graf
nx.draw(graph, with_labels=True, font_weight='bold', node_color='skyblue', font_color='black', node_size=500)
plt.show()