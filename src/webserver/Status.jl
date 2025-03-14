module Status


Base.@kwdef mutable struct Business
    name::Symbol=:ignored
    started_at::Union{Nothing,Float64}=nothing
    finished_at::Union{Nothing,Float64}=nothing
    subtasks::Dict{Symbol,Business}=Dict{Symbol,Business}()
    update_listener_ref::Ref{Union{Nothing,Function}}=Ref{Union{Nothing,Function}}(nothing)
    lock::Threads.SpinLock=Threads.SpinLock()
end



tojs(b::Business) = Dict{String,Any}(
    "name" => b.name,
    "started_at" => b.started_at,
    "finished_at" => b.finished_at,
    "subtasks" => Dict{String,Any}(
        String(s) => tojs(r)
        for (s, r) in b.subtasks
    ),
)


function report_business_started!(business::Business)
    lock(business.lock) do
        business.started_at = time()
        business.finished_at = nothing
        
        empty!(business.subtasks)
    end
    
    isnothing(business.update_listener_ref[]) || business.update_listener_ref[]()
    return business
end



function report_business_finished!(business::Business)
    lock(business.lock) do
        # if it never started, then lets "start" it now
        business.started_at = something(business.started_at, time())
        # if it already finished, then leave the old finish time. 
        business.finished_at = something(business.finished_at, max(business.started_at, time()))
    end
    
    # also finish all subtasks (this can't be inside the same lock)
    for v in values(business.subtasks)
        report_business_finished!(v)
    end
    
    isnothing(business.update_listener_ref[]) || business.update_listener_ref[]()
    
    return business
end



create_for_child(parent::Business, name::Symbol) = function()
    Business(; name, update_listener_ref=parent.update_listener_ref, lock=parent.lock)
end

get_child(parent::Business, name::Symbol) = lock(parent.lock) do
    get!(create_for_child(parent, name), parent.subtasks, name)
end

report_business_finished!(parent::Business, name::Symbol) = get_child(parent, name) |> report_business_finished!
report_business_started!(parent::Business, name::Symbol) = get_child(parent, name) |> report_business_started!
report_business_planned!(parent::Business, name::Symbol) = get_child(parent, name)


report_business!(f::Function, parent::Business, args...) = try
    report_business_started!(parent, args...)
    f()
finally
    report_business_finished!(parent, args...)
end



# GLOBAL

# registry update
## once per process

# waiting for other notebook packages










# PER NOTEBOOK

# notebook process starting

# installing packages
# updating packages

# running cells






end



