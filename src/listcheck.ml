open SAST

let eval_list = List.map (expr scope deepscope) l in 

let rec check_types = function
        (t1, _) :: [] -> (t1, SListLiteral(eval_list))
      |	((t1,_) :: (t2,_) :: _) when n1 != n2 ->
	  raise (Failure "List types are inconsistent")
      | _ :: t -> check_types t
    in check_types eval_list