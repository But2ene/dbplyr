# frame is checked

    Code
      translate_sql(sum(x, na.rm = TRUE), vars_frame = c(1, 0))
    Condition
      Warning:
      Windowed expression `SUM(`x`)` does not have explicit order.
      i Please use `arrange()` or `window_order()` to make deterministic.
      Error in `rows()`:
      ! `from` (1) must be less than `to` (0)

# window_frame()

    Code
      lf %>% window_frame(-3, 0) %>% window_order(x) %>% mutate(z = sum(y, na.rm = TRUE)) %>%
        show_query()
    Output
      <SQL>
      SELECT *, SUM(`y`) OVER (ORDER BY `x` ROWS 3 PRECEDING) AS `z`
      FROM `df`

---

    Code
      lf %>% window_frame(-3) %>% window_order(x) %>% mutate(z = sum(y, na.rm = TRUE)) %>%
        show_query()
    Output
      <SQL>
      SELECT
        *,
        SUM(`y`) OVER (ORDER BY `x` ROWS BETWEEN 3 PRECEDING AND UNBOUNDED FOLLOWING) AS `z`
      FROM `df`

# window_frame() checks arguments

    Code
      window_frame(lf, "a")
    Condition
      Error in `window_frame()`:
      ! `from` must be a whole number, not the string "a".

---

    Code
      window_frame(lf, 1:2)
    Condition
      Error in `window_frame()`:
      ! `from` must be a whole number, not an integer vector.

---

    Code
      window_frame(lf, 1, "a")
    Condition
      Error in `window_frame()`:
      ! `to` must be a whole number, not the string "a".

---

    Code
      window_frame(lf, 1, 1:2)
    Condition
      Error in `window_frame()`:
      ! `to` must be a whole number, not an integer vector.

