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

(fn tbl? [x]
  "Returns true if the given value is table, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (table? [:a :b]) true))
  (assert (= (table? 1) false))
  ```"
  (= :table (type x)))

(fn str? [x]
  "Returns true if the given value is a string, false otherwise.
  Arguments:
  * `x`: a value

  Example:
  ```fennel
  (assert (= (str? \"hello world\") true))
  (assert (= (str? 1) false))
  ```"
  (= :string (type x)))

(fn num? [x]
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

(fn fn? [x]
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

{: nil?
 : tbl?
 : str?
 : bool?
 : num?
 : fn?
 : executable?
  }
