/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import std.array;

/**
 * A Date structure represents an arithmetic progression such that
 * Date = {c + dk | k in N}
 */
struct Date
{
  /* Initial offset value */
  size_t c;
  /* Difference between two terms */
  size_t d;

  /* Pretty representation */
  string toString() const pure @safe
  {
    import std.conv : to_text = text;
    auto text = appender!string;
    text.put("{ ");
    text.put(to_text(c));
    if (d != 0)
    {
      text.put(" + ");
      text.put(to_text(d));
      text.put("k");
    }
    text.put(" }");
    return text.data;
  }
}

alias dateset = Date[];
