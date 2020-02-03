/******************************************************************************
 * Authors: Jean Guyomarc'h
 * Copyright: Krono-Safe S.A. 2020, All rights reserved
 */

import std.getopt;
import std.stdio;

import date;
import dot;
import task;
import group;
import explorer;
import intersect;

private void run(string[] argv)
{
  string[] task_files;
  string group_file;
  bool show_dates = false;
  string dot_file;

  auto opts_info = getopt(
    argv,
    "show-dates", "Displays the dates for each transition", &show_dates,
    "dot-output", "Generate a dot file with the problem statement", &dot_file,
    std.getopt.config.required,
    "task|t", "JSON file describing a task", &task_files,
    std.getopt.config.required,
    "groups|g", "JSON file describing exclusion groups", &group_file);

  if (opts_info.helpWanted)
  {
    defaultGetoptPrinter("Multi-Core Time-Interferences Detector",
      opts_info.options);
    return;
  }

  /* Dates for each TT */
  dateset[string] dates;
  const(Task)[] tasks;

  const groups = groups_parse(group_file);
  foreach (task_file; task_files)
  {
    const task = new Task(task_file);
    tasks ~= task;
    auto task_dates = explore(task);
    foreach (tt, tt_dates; task_dates)
    { dates[tt] = tt_dates; }
  }

  /* If we were asked to print the dates for each reachable transition, print
   * that information */
  if (show_dates)
  {
    foreach (transition, date_list; dates)
    { writeln(transition, ": ", date_list); }
  }

  const intersect = find_intersect(dates, groups);
  if (intersect.exists)
  {
    writeln("Found intersection between '", intersect.tt1, "' and '",
        intersect.tt2, "' at date '", intersect.date, "'");
  }
  else
  {
    writeln("No intersection found");
  }

  if (dot_file.length != 0)
  {
    dotify(dot_file, tasks, groups, intersect);
  }
}

int main(string[] argv)
{
  try
  {
    run(argv);
  }
  catch (std.getopt.GetOptException err)
  {
    stderr.writeln(err.msg);
    stderr.writeln("Run again with --help for details");
    return 1;
  }
  return 0;
}
