#! /usr/bin/env wolframscript


(* wolframscript -file sumargs.wls 1 2 3 4.5 *)

(* sumargs.wls *)
args = ToExpression /@ Rest[$ScriptCommandLine];
sum = Total[args];
Print[sum];