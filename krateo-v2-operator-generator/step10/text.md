### Testing the Web Service

As previously explained, the web service resolves inconsistencies in the GitHub APIs that can occur when a username is removed from the list of collaborators without updating the Custom Resource (CR). At this point, we expect the controller to call the endpoint:

```
/repository/{owner}/{repo}/collaborators/{username}/permission
```

with the `GET` method. If the collaborator is no longer part of the repository, it should return a `404` status code.

To test this:

1. **Remove the User from the List of Collaborators:**
   - Navigate to the repository settings: **Repository → Settings → Collaborators and Teams**.
   - Remove the user specified in the CR from the list of collaborators.
   - Note: A collaborator is officially added to the list only after accepting the invitation.

2. **Check the Controller Logs:**
   - After deleting the username, open the logs for the dynamic controller to verify the actions performed. Run the following command:

     ```bash
     kubectl logs deployments/collaborators-v1alpha1-controller -n gh-system | grep -C 7 "404 NOT FOUND" | tail -15
     ```{{exec}}

   - You should see a log entry similar to this:

     ```
     GET /repository/operator-generator-testing/test-collaborators/collaborators/your-username/permission HTTP/1.1
     Host: github-plugin.krateo-system.svc.cluster.local:8080
     User-Agent: Go-http-client/1.1
     Authorization: Bearer ghp_yourtoken
     Accept-Encoding: gzip

     HTTP/1.1 404 NOT FOUND
     Content-Length: 163
     Content-Type: application/json
     Date: Tue, 12 Nov 2024 07:54:45 GMT
     Server: waitress
     
     {"documentation_url":"https://docs.github.com/rest/collaborators/collaborators#check-if-a-user-is-a-repository-collaborator","message":"Not Found","status":"404"}
     ```

   - This output confirms that the controller detected the `404` response after the collaborator was removed from the repository.

3. **Verify the Re-Addition of the Collaborator:**
   - Upon detecting the `404` status, the controller should automatically issue a `PUT` request to re-add the username as a collaborator. To confirm this action, run:

     ```bash
     kubectl logs deployments/collaborators-v1alpha1-controller -n gh-system | grep -B 10 -A 5 "201 Created" | tail -15
     ```{{exec}}

   - You should see a log entry similar to the following:

     ```
     PUT /repos/operator-generator-testing/test-collaborators/collaborators/your-username HTTP/1.1
     Host: api.github.com
     User-Agent: Go-http-client/1.1
     Content-Length: 21
     Authorization: Bearer ghp_yourtoken
     Content-Type: application/json
     Accept-Encoding: gzip

     {"permission":"read"}

     HTTP/2.0 201 Created
     Content-Length: 7508
     Access-Control-Allow-Origin: *
     Access-Control-Expose-Headers: ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Used, X-RateLimit-Resource, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type, X-GitHub-SSO, X-GitHub-Request-Id, Deprecation, Sunset
     Cache-Control: private, max-age=60, s-maxage=60
     Content-Security-Policy: default-src 'none'
     ```

   - This indicates that the controller successfully performed a `PUT` request to add the user back with the specified permissions.

By following these steps, you can confirm that the controller correctly identifies when a collaborator is missing and subsequently re-adds them to the repository as needed.