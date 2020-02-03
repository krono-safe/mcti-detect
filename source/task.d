/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import std.json;
import std.file;

alias stringsmap = string[][string];

class Task
{
  /** Map that associates a node to a list of nodes that can be reached from it */
  stringsmap graph;
  /** Map that associates a node to a list of temporal transitions */
  stringsmap transitions_at_node;
  /** Map a transition to a list of nodes that trigger this transition */
  stringsmap nodes_for_transition;
  /** Matrix of transitions: [source][destination] => transition */
  string[string][string] transitions;
  /** Name of the node that is used as the unique entry point */
  string start;
  /** Number of nodes in the task (includes the start node) */
  size_t nodes;

  this(in string json_file)
  {
    const text = readText(json_file);
    const json = parseJSON(text);

    start = json["start"].str;

    foreach (node; json["graph"].array())
    {
      const source = node["source"].str;
      graph[source] = [];
      transitions_at_node[source] = [];
      foreach (target; node["targets"].array())
      {
        const dest = target["node"].str;
        const tr = target["transition"].str;
        graph[source] ~= dest;
        transitions_at_node[source] ~= tr;
        transitions[source][dest] = tr;

        nodes_for_transition[tr] ~= source;
      }
    }
    nodes = graph.length;
  }
}
