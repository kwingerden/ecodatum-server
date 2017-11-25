# EcoDatum Web Application Server

## Mac OS X EcoDatum Server First Time Development Installation

1. Install [XCode 9.1](https://developer.apple.com/xcode/downloads/), which will also install Swift 4.
Make sure to also install the XCode command-line tools so that Git is also installed and available 
from the command line.

2. Download and install [Docker for Mac OS X](https://download.docker.com/mac/stable/Docker.dmg).

3. Run the MySQL Docker Container for development with the following command:

```bash
./bin/docker-run-mysql
```

4. Install Homebrew with the following command:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

5. Verify that Vapor can now be installed with following command:

```bash
eval "$(curl -sL check.vapor.sh)"
```
```
✅  Compatible Xcode
✅  Compatible with Vapor 2
```

6. Install Vapor (and corresponding MySQL client) with the following commands:

```bash
brew tap vapor/homebrew-tap
brew update
brew install vapor
brew install vapor/tap/cmysql
```

7. Build a debug version of the EcoDatum Server:


```bash
./bin/vapor-build-debug
```

8. Set the EcoDatum Server cipher key:


```bash
./bin/vapor-gen-cipher-key
```

9. Run the development version of EcoDatum Server:


```bash
./bin/vapor-run-development
```

10. Access the EcoDatum Server with a browser:

```bash
open http://0.0.0.0:8080
```

