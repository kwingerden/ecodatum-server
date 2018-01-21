1. Set SERVER environment variable:

    export SERVER="0.0.0.0:8080"

2. Authenticate root user:

    env EMAIL="admin@ecodatum.org" \
      PASSWORD="password" \
      ./AutheniticateUser.sh

    HTTP/1.1 200 OK
    Content-Length: 54
    Content-Type: application/json; charset=utf-8
    Date: Sat, 20 Jan 2018 22:09:54 GMT

    {
        "id": 1,
        "token": "4SFcIrAoUxCy52AJ2fpEnQ==",
        "userId": 1
    }

3. Grab token from step 2 and set the AUTH_TOKEN environment variable and 
   create a new user:

    env AUTH_TOKEN="4SFcIrAoUxCy52AJ2fpEnQ==" \
      FULL_NAME="Ken Wingerden" \
      EMAIL="ken.wingerden@gmail.com" \
      PASSWORD="password" \
      ./NewUserAccount.sh

4. Authenticate new user:

    env EMAIL="ken.wingerden@gmail.com" \
      PASSWORD="password" \
      ./AutheniticateUser.sh

    HTTP/1.1 200 OK
    Content-Length: 54
    Content-Type: application/json; charset=utf-8
    Date: Sat, 20 Jan 2018 22:15:23 GMT

    {
        "id": 2,
        "token": "ygiot+kWNn6b8IEZ9hL+uQ==",
        "userId": 2
    }

5. Grab new user token from step 4, and create a new organization:

    env AUTH_TOKEN="ygiot+kWNn6b8IEZ9hL+uQ==" \
      NAME="Ken Wingerden's Organization" \
      DESCRIPTION="The is Ken's cool new Organization" \
      ./NewOrganization.sh

    HTTP/1.1 200 OK
    Content-Length: 115
    Content-Type: application/json; charset=utf-8
    Date: Sat, 20 Jan 2018 23:20:29 GMT

    [
        {
            "code": "PZZTPK",
            "description": "The is Ken's cool new Organization",
            "id": 1,
            "name": "Ken Wingerden's Organization"
        }
    ]

6. Show all organizations owned by new user in step 4:

    env AUTH_TOKEN="ygiot+kWNn6b8IEZ9hL+uQ==" \
      ./GetAllOrganizations.sh

7. Create user and add to organization using the orgnization code from step 4:

    env FULL_NAME="Test User1" \
      EMAIL="test1@email.com" \
      PASSWORD="password" \
      CODE="PZZTPK" \
      ./NewOrganizationUserAccount.sh