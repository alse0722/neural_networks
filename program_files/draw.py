import sys
import networkx as nx
import matplotlib.pyplot as plt

def read_graph_from_file(file_path):
    G = nx.DiGraph()  # Используем направленный граф
    with open(file_path, 'r') as file:
        for line in file:
            start, end, weight = map(int, line.strip('()\n').split(','))
            G.add_edge(start, end, weight=weight)
    return G

def draw_graph(graph):
    pos = nx.planar_layout(graph)  # Размещение узлов по кругу
    labels = nx.get_edge_attributes(graph, 'weight')  # Получение весов ребер для подписей

    nx.draw(graph, pos, with_labels=True, font_weight='bold', node_size=700, node_color='skyblue', font_color='black', connectionstyle='arc3,rad=0.1', arrowsize=20)
    nx.draw_networkx_edge_labels(graph, pos, edge_labels=labels)

    plt.show()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python draw.py <file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    graph = read_graph_from_file(file_path)
    draw_graph(graph)
