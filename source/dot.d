/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import std.stdio;
import std.algorithm.searching : canFind;
import std.conv : text;
import std.array;

import task;
import group;
import intersect;

void dotify(in string filename, in Task[] tasks, in group[] groups, in Intersect intersect)
{
  auto file = File(filename, "w");
  file.writeln("digraph application {");

  foreach (task_id, task; tasks)
  {
    /* First, dump all the nodes */
    foreach (source_node; task.graph.keys)
    {
      file.write("  T", task_id, source_node, " [label=\"", source_node, "\"]");
      if (source_node == task.start)
      { file.write(" [shape=box]"); }
      file.writeln(';');
    }

    /* Now, join them */
    foreach (source_node, target_nodes; task.graph)
    {
      foreach (target_node; target_nodes)
      {
        const tr = task.transitions[source_node][target_node];
        file.write(
          "  T", task_id, source_node,
          " -> T", task_id, target_node);
        auto label = appender!string;
        label.put(tr);

        /* If the transition is in the exclusion group, there is either an
         * overlap, or there is not (duh!). */
        foreach (group; groups)
        {
          if (group.canFind(tr))
          {
            if ((tr == intersect.tt1) || (tr == intersect.tt2))
            {
              /* Overlap: mark the arc as red, with the intersect date */
              file.write(" [color=red]");
              label.put(" (at ");
              label.put(text(intersect.date));
              label.put(')');
            }
            else /* No overlap */
            { file.write(" [color=green]"); }
          }
        }
        /* Name of the transition */
        file.writeln("[label=\"", label[], "\"];");
      }
    }
  }

  file.writeln("}");
}
