; extends

; Shared predicates used in all patterns below:
;   (#match? ...) (#gsub! ...) x3 (#set! injection.combined)

; Comment before a non-first binding — handles direct strings AND one level of wrapping
; (function_expression, binary_expression, etc.) via the _ wildcard branch
((comment) @injection.language
 .
 (binding
   attrpath: (_)
   [(string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
    (_ [(string_expression (string_fragment) @injection.content)
        (indented_string_expression (string_fragment) @injection.content)])])
 (#match? @injection.language "^(#|/\\*)[ \\t]*(lang:[ \\t]*)?(bash|sh|python|lua|nu|fish|zsh|ruby|perl|js|javascript|json|yaml|toml)[ \\t]*(\\*/)?[ \\t]*$")
 (#gsub! @injection.language "^[#/*]+%s*lang:%s*" "")
 (#gsub! @injection.language "^[#/*]+%s*" "")
 (#gsub! @injection.language "%s*%*?/?%s*$" "")
 (#set! injection.combined))

; Comment before the first binding (comment is a sibling of binding_set in attrset_expression)
((comment) @injection.language
 .
 (binding_set
   .
   (binding
     attrpath: (_)
     [(string_expression (string_fragment) @injection.content)
      (indented_string_expression (string_fragment) @injection.content)
      (_ [(string_expression (string_fragment) @injection.content)
          (indented_string_expression (string_fragment) @injection.content)])]))
 (#match? @injection.language "^(#|/\\*)[ \\t]*(lang:[ \\t]*)?(bash|sh|python|lua|nu|fish|zsh|ruby|perl|js|javascript|json|yaml|toml)[ \\t]*(\\*/)?[ \\t]*$")
 (#gsub! @injection.language "^[#/*]+%s*lang:%s*" "")
 (#gsub! @injection.language "^[#/*]+%s*" "")
 (#gsub! @injection.language "%s*%*?/?%s*$" "")
 (#set! injection.combined))
