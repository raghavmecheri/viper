module StringMap = Map.Make(String)

let rec toi scope s =
    if StringMap.mem s scope.variables then
      StringMap.find s scope.variables 
    else match scope.parent with
      Some(parent) -> toi parent s 
    | _ -> raise (Failure "Variable not found") 