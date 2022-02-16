"""
Gets a dictionary of all symbols and the respective cells which are dependent on the given cell.

Changes in the given cell cause re-evaluation of these cells.
Note that only direct dependents are given here, not indirect dependents.
"""
function downstream_cells_map(cell::Cell, topology::NotebookTopology)::Dict{Symbol,Vector{Cell}}
    defined_symbols = let node = topology.nodes[cell]
        node.definitions ∪ node.funcdefs_without_signatures
    end
    return Dict{Symbol,Vector{Cell}}(
        sym => where_referenced(topology, Set([sym]))
        for sym in defined_symbols
    )
end
@deprecate downstream_cells_map(cell::Cell, notebook::Notebook) downstream_cells_map(cell, notebook.topology)

"""
Gets a dictionary of all symbols and the respective cells on which the given cell depends.

Changes in these cells cause re-evaluation of the given cell.
Note that only direct dependencies are given here, not indirect dependencies.
"""
function upstream_cells_map(cell::Cell, topology::NotebookTopology)::Dict{Symbol,Vector{Cell}}
    referenced_symbols = topology.nodes[cell].references
    return Dict{Symbol,Vector{Cell}}(
        sym => where_assigned(topology, Set([sym]) )
        for sym in referenced_symbols
    )
end
@deprecate upstream_cells_map(cell::Cell, notebook::Notebook) upstream_cells_map(cell, notebook.topology)

"Fills cell dependency information for display in the GUI"
function update_dependency_cache!(cell::Cell, topology::NotebookTopology)
    cell.cell_dependencies = CellDependencies(
        downstream_cells_map(cell, topology), 
        upstream_cells_map(cell, topology), 
        cell_precedence_heuristic(topology, cell),
    )
end

"Fills dependency information on notebook and cell level."
function update_dependency_cache!(notebook::Notebook)
    notebook._cached_topological_order = topological_order(notebook)
    for cell in values(notebook.cells_dict)
        update_dependency_cache!(cell, notebook.topology)
    end
end
