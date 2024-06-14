using Pluto

"""
    pluto_static_export(nb; outfile=replace(nb, r"\\.jl\$" => ".html"))

Run the given notebook `nb` and export it to static HTML.

"""
function pluto_static_export(nb; outfile=replace(nb, r"\.jl$" => ".html"))

    s = Pluto.ServerSession()

    nb = Pluto.SessionActions.open(s, nb; run_async=false)

    # Generate the HTML file
    html_content = Pluto.generate_html(nb)

    # Write the HTML content to a file
    open(outfile, "w") do io
        write(io, html_content)
    end
end


pluto_static_export(joinpath(@__DIR__, "plotly_static.jl"))