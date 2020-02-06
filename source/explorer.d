/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import std.algorithm.mutation;
import std.algorithm.searching;
import std.algorithm.sorting;
import std.algorithm.comparison;
import std.algorithm : canFind;
import std.algorithm.setops;

import task;
import date;

private dateset[string] explore_nondeterministic(in Task task)
{
  /* Shortcuts */
  const N = task.nodes;
  const START = task.start;
  const GRAPH = task.graph;
  const TRANSITIONS = task.transitions_at_node;

  /* First, find all the strongly connected components */
  import mir.graph;
  import mir.graph.tarjan;
  const GS = GRAPH.graphSeries;
  const SCC = GS.data.tarjan();

  /* For an easier access: find the precessors of each node */
  stringsmap PRED;
  foreach (key, data; GRAPH)
  { PRED[key] = []; }
  foreach (key, data; GRAPH)
  {
    foreach (node; data)
    { if (! PRED[node].canFind(key)) { PRED[node] ~= key; } }
  }

  alias nodeset = string[];
  nodeset[] S;
  nodeset[][string] T;
  size_t[string] sl;
  bool[string] Imp;
  string[] Qimp;
  size_t[] D;

  /* Static sizing of arrays, for slightly better performance */
  S.length = N * N;

  /***************************************************************************/
  /* We find below a set of contextual functions that allow to build each
   * remarkable set as described by Sawa and our work */

  void build_Si()
  {
    bool[string] prev = [START: true];
    S[0] = prev.keys;
    for (size_t i = 1; i < S.length; i++)
    {
      bool[string] cache;
      foreach (node; prev.keys)
      {
        foreach (succ; GRAPH[node])
        { cache[succ] = true; }
      }
      S[i] = cache.keys;
      prev = cache;
    }
  }

  void build_Tq(nodeset[] Tq, in string qf)
  {
    bool[string] prev = [qf: true];
    Tq[0] = prev.keys;
    for (size_t i = 1; i < N; i++)
    {
      bool[string] cache;
      foreach (node; prev.keys)
      {
        foreach (pred; PRED[node])
        { cache[pred] = true; }
      }
      Tq[i] = cache.keys;
      prev = cache;
    }
  }

  void build_sl(in string node)
  {
    bool[string] visited;
    size_t[] completed_paths;

    void visit(in string n, size_t len)
    {
      if ((n in visited) !is null)
      {
        if (node == n)
        { completed_paths ~= len; }
        return;
      }
      visited[n] = true;

      foreach (next; GRAPH[n])
      { visit(next, len + 1); }
    }

    visit(node, 0);
    sl[node] = (completed_paths.length == 0) ? 0 : completed_paths.minElement();
  }

  void build_imp()
  {
    foreach (scc; SCC)
    {
      size_t min_len = size_t.max;
      size_t[string] imp;
      foreach (node_idx; scc)
      {
        const node = GS.index[node_idx];
        const len = sl[node];
        if ((len > 0) && (len <= min_len))
        {
          min_len = len;
          imp[node] = len;
        }
      }

      foreach (node, value; imp)
      { if (value <= min_len) { Imp[node] = true; } }
    }
  }

  void build_qimp()
  {
    foreach (node; S[N - 1])
    { if (node in Imp) { Qimp ~= node; } }
  }

  void build_d()
  {
    bool[size_t] cache;
    foreach (q; Qimp)
    { cache[sl[q]] = true; }
    D = cache.keys;
  }

  /***************************************************************************/
  /* Cal the functions above to actually build the sets */

  /* Build sets of accepting states */
  foreach (qf; GRAPH.keys)
  {
    nodeset[] nodes;
    nodes.length = N;
    build_Tq(nodes, qf);
    T[qf] = nodes;
  }

  /* Build sets Si */
  build_Si();

  /* Build sl(q) functions */
  foreach (node; GRAPH.keys)
  { build_sl(node); }

  /* Build set of important nodes Qimp */
  build_imp();
  build_qimp();

  /* Build set D */
  build_d();

  /***************************************************************************/
  /* We will now construct the dates */

  dateset[string] dates;

  foreach (node, transitions; TRANSITIONS)
  {
    foreach (transition; transitions)
    { dates[transition] = []; }
  }

  foreach (transition; TRANSITIONS[START])
  { dates[transition] ~= Date(0, 0); }

  /* Construction of D1 */
  foreach (i, nodes; S)
  {
    if ((nodes.length == 1 && nodes[0] == START)) /* S[i] == {start} */
    {
      assert(i == 0);
      continue;
    }

    foreach (node; nodes) /* for q in S[i] */
    {
      foreach (transition; TRANSITIONS[node])
      {
        auto d = Date(i, 0);
        if (! dates[transition].canFind(d))
        { dates[transition] ~= d; }
      }
    }
  }

  // For extensive debug
  //import std.stdio;
  //writeln("================================================");
  //write("Qimp = ");
  //foreach(q; Qimp) { write(q, ' '); }
  //writeln("");
  //write("D = ");
  //foreach(d; D) { write(d, ' '); }
  //writeln("");
  //writeln("sl = ");
  //foreach (key, val ; sl)
  //{
  //  writeln("    ", key, ": ", val);
  //}
  //writeln("T[k] = ");
  //foreach (idx, it; T["k"])
  //{
  //  write("    ", idx, ":");
  //  foreach (val; it)
  //  { write(' ', val); }
  //  writeln("");
  //}

  /* Construction of D2 */
  const F = remove!(a => a == START)(GRAPH.keys);
  const cprime_min = (N * N) - (2 * N);
  const cprime_max = (N * N) - N - 1;
  foreach(q; Qimp)
  {
    const d = sl[q];
    for (size_t cprime = cprime_min; cprime <= cprime_max; cprime++)
    {
      const cprime_bound = (N * N) - N - d;
      foreach (qf; F)
      {
        /* q in Tq,c' AND c' >= n^2-n-d */
        if ((cprime >= cprime_bound) && (T[qf][cprime - cprime_min].canFind(q)))
        {
          foreach (transition; TRANSITIONS[qf])
          {
            auto date = Date(cprime + N - 1, d);
            if (! dates[transition].canFind(date))
            { dates[transition] ~= date; }
          }
        }
      }
    }
  }

  return dates;
}

dateset[string] explore(in Task task)
{
  size_t[string] visited;
  string[size_t] transitions;
  string current = task.start;
  size_t index = 0;

  while (! (current in visited))
  {
    const next_nodes = task.graph[current];
    if (next_nodes.length > 1)
    { return explore_nondeterministic(task); }

    /* XXX This assumes the JSON is valid (only one transition) */
    transitions[index] = task.transitions_at_node[current][0];

    visited[current] = index;
    index += 1;
    current = next_nodes[0];
  }

  /* Now that we have explored the whole graph, and now that we are sure the
   * task is deterministic, compute the dates */
  dateset[string] dates;
  const size_t l = visited[current];
  const size_t p = task.nodes - l;

  for (size_t n = 0; n < l; n++)
  {
    const tt = transitions[n];
    dates[tt] ~= Date(n, 0);
  }

  for (size_t n = l; n < task.nodes; n++)
  {
    const tt = transitions[n];
    const ln = n - l;
    dates[tt] ~= Date(l + ln, p);
  }
  return dates;
}
