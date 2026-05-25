open System

[<EntryPoint>]
let main argv =
    if argv.Length < 2 then
        printfn "Usage: dotnet run <num1> <num2>"
        1
    else
        let num1 = Int32.Parse(argv.[0])
        let num2 = Int32.Parse(argv.[1])
        let sum = num1 + num2
        printfn "%d + %d = %d" num1 num2 sum
        0
