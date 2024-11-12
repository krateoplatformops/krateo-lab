# Handling Resources with Non-Standard APIs

The Operator Generator requires only 5 API endpoints/verbs to perform actions:
- `create`
- `update`
- `findby`
- `get`
- `delete`

Note: Some endpoints may be optional. For example, if `findby` is not specified in the RestDefinition, you won't be able to retrieve existing external resources, but you can still create and manage resources from scratch.

## API Endpoint Requirements

### 1. Field Naming Consistency
- Field names must be consistent across all actions (`create`, `update`, `findby`, `get`, `delete`)

### 2. Response Consistency with Custom Resource Definition (CRD)
- API endpoint responses must align with the fields in the Custom Resource Definition (CRD)
- GET (`get` action) and LIST (`findby` action) API responses must include all fields present in the CRD specification, including authentication references

## Example: Managing GitHub Repository Collaborators

This example demonstrates how to handle inconsistencies in the GitHub API, specifically with the endpoint:
```
https://api.github.com/repos/{owner}/{repo}/collaborators/{username}/permission
```

### Available Endpoints
```yaml
- action: create
  method: PUT
  path: /repos/{owner}/{repo}/collaborators/{username}

- action: delete
  method: DELETE
  path: /repos/{owner}/{repo}/collaborators/{username}

- action: get
  method: GET
  path: /repository/{owner}/{repo}/collaborators/{username}/permission

- action: update
  method: PUT
  path: /repos/{owner}/{repo}/collaborators/{username}
```

### Known Issue
When checking a collaborator's permissions using the GET endpoint:
```
/repository/{owner}/{repo}/collaborators/{username}/permission
```

The API returns a 200 status code even if the username is no longer a collaborator, when a 404 would be expected. This behavior prevents the controller from detecting when a collaborator has been removed, making it unable to re-add them to the list to maintain the representation of the resource defined in the CR.

A potential solution would be to:
1. First call `/repository/{owner}/{repo}/collaborators/{username}` (returns 204 if the username is a collaborator, 404 if not)
2. Then call `/repos/{owner}/{repo}/collaborators/{username}/permission` only if the first call returns 204