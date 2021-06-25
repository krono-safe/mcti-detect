/************ Copyright Krono-Safe S.A. 2020, All rights reserved ************/

import std.json;
import std.file : readText;

alias group = string[];

const(group)[] groups_parse(in string json_file)
{
  group[] groups;

  if (json_file.length == 0) {
    return groups;
  }

  const text = readText(json_file);
  const json = parseJSON(text);

  const groups_value = json["groups"].array();
  groups.length = groups_value.length;

  foreach (idx, val; groups_value)
  {
    foreach (item; val.array())
    { groups[idx] ~= item.str; }
  }
  return groups;
}
