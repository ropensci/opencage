# oc_check_between works

    Code
      oc_check_between(symbol, 0, 10)
    Condition
      Error:
      ! Every `symbol` must be between 0 and 10.

---

    Code
      oc_check_between(symbol, 11.0001, 11.0002)
    Condition
      Error:
      ! Every `symbol` must be between 11.0001 and 11.0002.

---

    Code
      oc_check_between(symbol, 0L, 10L)
    Condition
      Error:
      ! Every `symbol` must be between 0 and 10.

---

    Code
      oc_check_between(symbol, 11.0001, 11.0002)
    Condition
      Error:
      ! Every `symbol` must be between 11.0001 and 11.0002.

---

    Code
      oc_check_between(symbol, 0, 11)
    Condition
      Error:
      ! Every `symbol` must be numeric.

---

    Code
      oc_check_between(symbol, 0, 11)
    Condition
      Error:
      ! Every `symbol` must be numeric.

