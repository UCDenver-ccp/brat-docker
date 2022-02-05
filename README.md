
# brat docker

This is a docker container deploying an instance of [brat](http://brat.nlplab.org/) based on the original work of https://github.com/cassj/brat-docker.


### Installation


1. Create a `.env` file in the base directory of this repository that contains the admin user info for BRAT. In the example below, replace `[USERNAME]`,`[PASSWORD]`, and `[EMAIL]` with appropriate values.
```
BRAT_USERNAME=[USERNAME]
BRAT_PASSWORD=[PASSWORD]
BRAT_EMAIL=[EMAIL]
```

2. Build and run an instance of brat
```bash
docker compose up -d
```

3. Add apache users to the running instance to allow entry to the brat application
```bash
docker exec -ti brat bash
> htpasswd -c /etc/apache2/.htpasswd [USERNAME]
```
Replace `[USERNAME]` with the user name and follow the prompts to enter a password. Once complete, the user/password entered will allow the user to access BRAT, but not login to brat.

4. Add brat users by creating a `users.json` file (see below) and placing it in `/bratcfg` inside the running container.

```javascript
{
    "user1": "password",
    "user2": "password",
    ...
}
```
