/************ Copyright Krono-Safe S.A. 2020, All rights reserved ************/

import std.json;
import std.file : readText;

alias group = string[];

const(group)[] groups_parse(in string json_file)
{
  const text = readText(json_file);
  const json = parseJSON(text);

  const groups_value = json["groups"].array();
  group[] groups;
  groups.length = groups_value.length;

  foreach (idx, val; groups_value)
  {
    foreach (item; val.array())
    { groups[idx] ~= item.str; }
  }
  return groups;
}
