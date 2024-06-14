using Pluto

s = Pluto.ServerSession()

nb_file = "plotly_static.jl"

nb = Pluto.SessionActions.open(s, nb_file; run_async=false)

# Generate the HTML file
html_content = Pluto.generate_html(nb)

# Write the HTML content to a file
open("notebook_plotly.html", "w") do io
    write(io, html_content)
end