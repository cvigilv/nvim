;; [nfnl-macro]

(fn nil? [x]
  "Returns true if the given value is nil, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (nil? nil) true))
  (assert (= (nil? 1) false))
  ```"
  (= nil x))

(fn table? [x]
  "Returns true if the given value is table, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (table? [:a :b]) true))
  (assert (= (table? 1) false))
  ```"
  (= :table (type x)))

(fn string? [x]
  "Returns true if the given value is a string, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (str? \"hello world\") true))
  (assert (= (str? 1) false))
  ```"
  (= :string (type x)))

(fn number? [x]
  "Returns true if the given value is a number, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (num? 1) true))
  (assert (= (num? \"hello world\") false))
  ```"
  (= :number (type x)))

(fn bool? [x]
  "Returns true if the given value is a boolean, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (bool? true) true))
  (assert (= (bool? \"hello\") false))
  ```"
  (= :boolean (type x)))

(fn function? [x]
  "Returns true if the given value is a function, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (fn? (fn [])) true))
  (assert (= (fn? \"hello world\") false))
  ```"
  (= :function (type x)))

(fn executable? [...]
  "Returns true if the input is executable, false otherwise.
  Arguments:
  * `...`: a string

  Example:
  ```fennel
  (assert (= (executable? :python3) true))
  (assert (= (executable? :python3) false))
  ```"
  (= 1 (vim.fn.executable ...)))

(fn ++ [num]
  (+ num 1))

(fn tx [& args]
  "Mixed sequential and associative tables at compile time. Because the Neovim ecosystem
   loves them but Fennel has no neat way to express them (which I think is fine, I don't
   like the idea of them in general).

   Stolen from: https://github.com/Olical/dotfiles/blob/fee71756d4a509429f7d954c1e846eaa5b58dc90/stowed/.config/nvim/fnl/config/macros.fnl"
  (let [to-merge (when (table? (. args (length args)))
                   (table.remove args))]
    (if to-merge
      (do
        (each [key value (pairs to-merge)]
          (tset args key value))
        args)
      args)))

{: tx
 : nil?
 : table?
 : string?
 : bool?
 : number?
 : function?
 : executable?
 : ++
  }
