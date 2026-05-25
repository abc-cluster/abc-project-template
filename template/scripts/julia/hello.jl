function add_one!(V)
    for i in eachindex(V)
        V[i] += 1
    end
    return nothing
end


my_data = [1,2,3]

add_one!(my_data)

my_data
