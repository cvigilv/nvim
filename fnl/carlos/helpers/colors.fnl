;;; colors helpers
;; author: Carlos Vigil-Vásquez
;; license: MIT 2025
;; compiles: lua/carlos/helpers/colors.lua

(fn get-hl [group]
  (let [(ok hl) (pcall (vim.api.nvim_get_hl 0 {:name group
                                              :link true
                                              :create false}))]
    (if ok
      (icollect [k v (pairs hl)]
        (if 
          (or (= k :fg) (= k :guifg) (= k :bg) (= k :guibg))
          :

        (when g 
  )

(fn get-hlgroup-table [group]
  (get-hl group))

{: get-hl
 : get-hlgroup-table ; TODO: deprecate
 }
