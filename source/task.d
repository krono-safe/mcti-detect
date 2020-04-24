/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import std.json;
import std.file;

alias stringsmap = string[][string];

class Task
{
  /** Identifier of a task. It is actually the path of the file that contains
   * the description of the task. */
  string id;
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
  /** List of all the transitions in the task */
  string[] transitions_list;

  this(in string json_file)
  {
    const text = readText(json_file);
    const json = parseJSON(text);
    bool[string] transitions_set;

    id = json_file;
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
        transitions_set[tr] = true;
        nodes_for_transition[tr] ~= source;
      }
    }
    transitions_list = transitions_set.keys;
    nodes = graph.length;
  }
}
