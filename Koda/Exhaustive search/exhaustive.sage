from sage.graphs.graph_generators import graphs

def find_connected_graph_with_diameter(n, d):
    max_edges = 0
    max_edges_graph = None
    
    
    for G in graphs.nauty_geng(str(n) + " -c"):
        
        diameter = G.diameter()
        
        
        if diameter == d:
            num_edges = G.size()
            
            
            if num_edges > max_edges:
                max_edges = num_edges
                max_edges_graph = G.copy()  
    
    return max_edges_graph, max_edges


n = 8
d = 1


max_edges_graph, max_edges = find_connected_graph_with_diameter(n, d)

if max_edges_graph:
    print(f"Connected graph with {n} vertices and diameter {d} with {max_edges} edges:")
    print(max_edges_graph)
    
    max_edges_graph.show()
else:
    print(f"No connected graph found with {n} vertices and diameter {d}.")


import pandas as pd
import matplotlib.pyplot as plt

results = []



for n in range(1, 10):
    for d in range(1, n):
        max_edges_graph, max_edges = find_connected_graph_with_diameter(n, d)
        result_dict = {
            'n': n,
            'd': d,
            'max_edges': max_edges
        }
        results.append(result_dict)


df = pd.DataFrame(results)


print(df)


plt.figure(figsize=(10, 6))
for n in range(1, 9):
    subset = df[df['n'] == n]
    plt.plot(subset['d'], subset['max_edges'], label=f'n={n}')
plt.xlabel('diameter (d)')
plt.ylabel('maximum Edges')
plt.legend()
plt.title('max_edges(d) for different n')
plt.show()


