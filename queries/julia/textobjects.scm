;; extends

; Julia treats a string immediately before a definition as its docstring.
((string_literal) @docstring.outer
  .
  [
    (module_definition)
    (abstract_definition)
    (primitive_definition)
    (struct_definition)
    (function_definition)
    (macro_definition)
    (assignment)
    (const_statement)
    (call_expression)
    (macrocall_expression)
    (identifier)
  ])

((string_literal
   .
   (_) @docstring.inner
   (_)? @docstring.inner .)
  .
  [
    (module_definition)
    (abstract_definition)
    (primitive_definition)
    (struct_definition)
    (function_definition)
    (macro_definition)
    (assignment)
    (const_statement)
    (call_expression)
    (macrocall_expression)
    (identifier)
  ])

; Do not fold macro definitions into the function object, as the upstream
; Julia query does. Functions and macro calls have separate nouns here.
(function_definition) @julia_function.outer

(function_definition
  (signature)
  .
  (_) @julia_function.inner
  (_)? @julia_function.inner .)

(assignment
  (call_expression)
  (operator)
  (_) @julia_function.inner) @julia_function.outer

(arrow_function_expression
  [
    (identifier)
    (argument_list)
  ]
  "->"
  (_) @julia_function.inner) @julia_function.outer

(macrocall_expression) @macro.outer

(macrocall_expression
  (macro_identifier)
  .
  (_) @macro.inner
  (_)? @macro.inner .)

; Julia type definitions. Only structs have an inner body.
[
  (abstract_definition)
  (primitive_definition)
  (struct_definition)
] @type.outer

(struct_definition
  (type_head)
  .
  (_) @type.inner
  (_)? @type.inner .)

(module_definition) @module.outer

(module_definition
  name: (_)
  .
  (_) @module.inner
  (_)? @module.inner .)

; Keep ordinary calls separate from macro calls.
[
  (call_expression)
  (broadcast_call_expression)
] @function_call.outer

(call_expression
  (argument_list
    .
    "("
    .
    (_) @function_call.inner
    (_)? @function_call.inner
    .
    ")"))

(broadcast_call_expression
  (argument_list
    .
    "("
    .
    (_) @function_call.inner
    (_)? @function_call.inner
    .
    ")"))

; One argument, preferring its trailing delimiter as the "around" form.
(argument_list
  (_) @argument.inner @argument.outer
  .
  [
    ","
    ";"
  ] @argument.outer)

(argument_list
  [
    ","
    ";"
  ] @argument.outer
  .
  (_) @argument.inner @argument.outer
  .)

(argument_list
  .
  (_) @argument.inner @argument.outer
  .)

; Assignment inner means its value, not the operator or left-hand side.
[
  (assignment
    .
    (_)
    (operator)
    (_) @julia_assignment.inner .)
  (compound_assignment_expression
    .
    (_)
    (operator)
    (_) @julia_assignment.inner .)
] @julia_assignment.outer

; A single block noun covers Julia's delimited executable clauses.
[
  (compound_statement)
  (let_statement)
  (if_statement)
  (for_statement)
  (while_statement)
  (try_statement)
  (do_clause)
] @julia_block.outer

(compound_statement
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(let_statement
  [
    (identifier)
    (let_binding)
  ]
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(if_statement
  condition: (_)
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner
  .
  [
    "end"
    (elseif_clause)
    (else_clause)
  ])

(elseif_clause
  condition: (_)
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(else_clause
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(for_statement
  (for_binding)
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(while_statement
  condition: (_)
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(try_statement
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner
  .
  [
    (catch_clause)
    (finally_clause)
  ])

(catch_clause
  (identifier)
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(finally_clause
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)

(do_clause
  (argument_list)
  .
  (_) @julia_block.inner
  (_)? @julia_block.inner .)
