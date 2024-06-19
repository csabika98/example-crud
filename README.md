# Example-CRUD

## Information:
## In order to build and use this APP on Windows 
* install MSYS2

Steps:
* https://www.msys2.org/
* Open MSYS2 MSYS and update the packages
```
1. pacman -Syu
```
* Terminal will be closed, Open MYSYS2 MYSYS again
```
2. pacman -Su
```
```
3. pacman -Sy
```
* Open MSYS2 MinGW x64, and install these packages
```
4. pacman -S mingw-w64-x86_64-gcc
5. pacman -S mingw-w64-x86_64-gdb
6. pacman -S mingw-w64-x86_64-make
7. pacman -S mingw-w64-x86_64-cmake
```
* Set ```C:\msys64\mingw64\bin``` as PATH (ENV in Windows)  
* Run the Powershell script which can be found in the ```utility``` folder
* Done



A complete example of a "CRUD" service (UserService) built with Oat++.

In this example:

- How to create CRUD endpoint.
- How to use [oatpp ORM](https://oatpp.io/docs/components/orm/#high-level-overview) - SQLite example.
- How to document API with Swagger-UI and OpenApi 3.0.0.

More about Oat++:

- [Oat++ Website](https://oatpp.io/)
- [Oat++ Github Repository](https://github.com/oatpp/oatpp)
- [Get Started](https://oatpp.io/docs/start)

## Overview

This project is using the following oatpp modules:

- [oatpp](https://github.com/oatpp/oatpp) 
- [oatpp-swagger](https://github.com/oatpp/oatpp-swagger)
- [oatpp-sqlite](https://github.com/oatpp/oatpp-sqlite)

### Project layout

```
|- CMakeLists.txt                        // projects CMakeLists.txt
|- sql/                                  // SQL migration scripts for SQLite database
|- src/
|   |
|   |- controller/                       // Folder containing REST Controllers (UserController)
|   |- db/                               // Folder containing the database client
|   |- dto/                              // DTOs are declared here
|   |- service/                          // Service business logic classes (UserService)
|   |- AppComponent.hpp                  // Service config
|   |- DatabaseComponent.hpp             // Database config
|   |- SwaggerComponent.hpp              // Swagger-UI config
|   |- App.cpp                           // main() is here
|
|- test/                                 // test folder
|- utility/install-oatpp-modules.sh      // utility script to install required oatpp-modules.
```

---

### Build and Run

#### Using CMake

##### Pre Requirements

- `oatpp` 
- `oatpp-swagger`
- `oatpp-sqlite` with `-DOATPP_SQLITE_AMALGAMATION=ON` cmake flag.

**Note:** You may run `utility/install-oatpp-modules.sh` script to install required oatpp modules.

##### Build Project

```
$ mkdir build && cd build
$ cmake ..
$ make 
$ ./crud-exe        # - run application.
```

#### In Docker

```
$ docker build -t example-crud .
$ docker run -p 8000:8000 -t example-crud
```

---

### Endpoints 

#### HTML

|HTTP Method|URL|Description|
|---|---|---|
|`GET`|http://localhost:8000/ | Root page |
|`GET`|http://localhost:8000/swagger/ui | Swagger UI page |

#### User Service

|HTTP Method|URL|Description|
|---|---|---|
|`POST`|http://localhost:8000/users | Create new User |
|`PUT`|http://localhost:8000/users/{userId} | Update User by ID |
|`GET`|http://localhost:8000/users/{userId} | Get User by ID |
|`DELETE`|http://localhost:8000/users/{userId} | Delete User by ID |
|`GET`|http://localhost:8000/users/offset/{offset}/limit/{limit} | Get All Users with Paging |
