# bahmni-ai configuration

`mcp-servers.json` lists the MCP servers the Bahmni AI assistant (`bahmni-ai` service) may use. It is read from
`/etc/bahmni_config/ai/mcp-servers.json`. The shipped `mcp-servers.json` configures `documents`, `fhir` and `confluence`;
its URLs come from `MCP_DOCUMENTS_URL` and `MCP_FHIR_URL`, and the Confluence token from `MCP_ATLASSIAN_TOKEN` (set these
in the bahmni-ai container, otherwise it refuses to start). `mcp-servers.example.json` shows Documents, Jira and OpenMRS entries.

This file format is specific to bahmni-ai (it is not the generic MCP client format).

**Never put secrets here.** Use references: `"credentialRef": "MCP_JIRA_TOKEN"` names an environment variable of the
bahmni-ai container, and `"url": "${MCP_JIRA_URL}"` expands a variable. Only variables starting with `MCP_` are visible
to this file.

Rules (see the bahmni-ai repo, `docs/OPERATIONS.md`, for the full reference):
- Server names: lowercase letters, digits, `-`.
- `auth.type`: `none`, `bearer`, `api-key-header` (shared service credential), `openmrs-session` (the logged-in user's
  OpenMRS session is forwarded; the MCP server must be a trusted first-party server).
- Tools are hidden unless matched by `tools.allow` or `tools.overrides` (and not by `deny`).
- `requiredPrivilege` names an OpenMRS privilege the user must hold. Create these privileges in OpenMRS
  (`Use AI Chatbot` for all users of the assistant, plus one per sensitive action) and assign them to roles.
- Write tools need `"confirm": true` and a privilege. The user is asked to confirm each write.
- `argumentConstraints` restrict argument values (for example the Jira project).
- `propagateTrace` (optional, default `false`): send OpenTelemetry trace context (`traceparent`) to this server. Set
  `true` only for trusted, first-party servers; third-party servers must stay `false`.
- `trustToolAnnotations` (optional, default `false`): believe the server's own read-only/destructive hints. Without it, a
  tool matched only by `allow` needs the user's confirmation; list read tools under `overrides` with `"access": "read"`
  instead. Set `true` only for first-party servers (here: `documents`, `fhir`).
- Credentials and the user's session are only sent over `https`, or `http` to `localhost`, `host.docker.internal` or a
  single-label container name.
