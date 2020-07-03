/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import date;
import group;
import task;

struct Intersect
{
  /** Is false if no intersection exists */
  bool exists = false;
  /** If [exists] is true, [tt1] contains the name of one temporal transition
   * that insersects with [tt2] */
  string tt1;
  /** If [exists] is true, [tt2] contains the name of one temporal transition
   * that insersects with [tt1] */
  string tt2;
  /** If [exists] is true, contains a date at which [tt1] and [tt2] intersect */
  size_t date;
}

/**
 * Solve a linear diophantine equation of the form ax + by = c.
 * If the equation has (at least) a solution, this function returns true.
 * [date] will then be set with one possible solution
 */
private bool _solve_linear_diophantine(
  in long a, in long b, in long c,
  out long x, out long y)
{
  import std.numeric : gcd;
  import std.math;
  const long sign = ((a < 0) || (b < 0)) * (-1);

  /* Find the greatest common divisor of a and b. The diophantine admits an
   * solution if c can be divided by the gcd */
  const eq_gcd = gcd(abs(a), abs(b)) * sign;
  if (c % eq_gcd != 0)
  { return false; }

  /* Solutions are of the form:
   *     (x' + m (b / gcd) , y' - m (a / gcd))
   * or: (x' + mp , y' - mq)
   *
   * with (x' , y') = ( c / gcd , c / gcd )
   *
   * In N, we want: x' + mp >= 0
   *                      m >= -x' / p
   *                y' - mq >= 0
   *                      m <= y' / q
   *
   * -x'/p <= m <= y'/q
   */
  const sol = c / eq_gcd;
  const p = b / eq_gcd;
  const q = a / eq_gcd;

  const m = (sol % p == 0) ? (-sol / p) : (-sol / p + 1);
  assert(m <= (sol / q));

  x = sol + m * p;
  y = sol - m * q;

  return true;
}

private bool _mixed_intersect(in Date d1, in Date d2, out size_t date)
in
{
  assert(d1.d == 0);
  assert(d2.d != 0);
}
do
{
  /* d1.c = d2.c + d2.d*k */
  if ((d1.c >= d2.c) && ((d1.c - d2.c) % d2.d == 0))
  {
    date = d1.c;
    return true;
  }
  return false;
}

private bool _find_intersect(in dateset d1_list, in dateset d2_list, out size_t date)
{
  foreach (d1; d1_list)
  {
    foreach (d2; d2_list)
    {
      /* (1) Intersect of two constants */
      if ((d1.d == 0) && (d2.d == 0))
      {
        if (d1.c == d2.c)
        {
          date = d1.c;
          return true;
        }
      }
      /* (2) Mixed intersect */
      else if (d1.d == 0)
      {
        if (_mixed_intersect(d1, d2, date))
        { return true; }
      }
      else if (d2.d == 0)
      {
        if (_mixed_intersect(d2, d1, date))
        { return true; }
      }
      /* (3) arithmetic progressions */
      else
      {
        const a = long(d1.d);
        const b = -long(d2.d);
        const c = long(d2.c) - long(d1.c);
        long x, y;
        if (_solve_linear_diophantine(a, b, c, x, y))
        {
          const date1 = d1.c + x * d1.d;
          const date2 = d2.c + y * d2.d;
          date = (date1 < date2) ? date1 : date2;
          return true;
        }
      }
    }
  }

  return false;
}

Intersect find_intersect(
  in dateset[string] dates,
  in group[] groups,
  in string[string] transition_to_task)
{
  Intersect isect;

  foreach (group; groups)
  {
    foreach (tt1; group)
    {
      foreach (tt2; group)
      {
        assert(tt1 in transition_to_task, "failed to find transition '" ~ tt1 ~ "'" );
        assert(tt2 in transition_to_task, "failed to find transition '" ~ tt2 ~ "'" );

        /* Transitions that belong to the same task, by definition, cannot
         * be executed simultaneously */
        if (transition_to_task[tt1] == transition_to_task[tt2])
        { continue; }
        if (tt1 != tt2)
        {
          size_t d;
          if (_find_intersect(dates[tt1], dates[tt2], d))
          { return Intersect(true, tt1, tt2, d); }
        }
      }
    }
  }

  return Intersect(false, "", "", 0);
}
