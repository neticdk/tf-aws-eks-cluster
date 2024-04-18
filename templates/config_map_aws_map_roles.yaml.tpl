%{ for r in map_roles ~}
- rolearn: ${r.role_arn}
  username: ${r.username}
  groups:
    - ${lookup(r, "group", "system:authenticated")}
%{ endfor ~}
